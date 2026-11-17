-- =====================================================================
--  File 3 of 3 : MIS / DSS analytics + control tests
--  Run after 01_schema.sql and 02_sample_data.sql
-- =====================================================================
USE ap_system;
DELIMITER $$

-- ---------------------------------------------------------------------
-- A1. DAYS PAYABLE OUTSTANDING (DPO) for a period
--     DPO = Average AP balance / Credit purchases in period x Days in period
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_dpo(IN p_start DATE, IN p_end DATE)
BEGIN
    DECLARE v_open  DECIMAL(16,2);
    DECLARE v_close DECIMAL(16,2);
    DECLARE v_purch DECIMAL(16,2);
    DECLARE v_days  INT;

    SET v_open  = fn_ap_balance(DATE_SUB(p_start, INTERVAL 1 DAY));
    SET v_close = fn_ap_balance(p_end);
    SET v_days  = DATEDIFF(p_end, p_start) + 1;
    SELECT COALESCE(SUM(total_amount),0) INTO v_purch
      FROM invoices
     WHERE invoice_date BETWEEN p_start AND p_end AND status <> 'REJECTED';

    SELECT p_start AS period_start, p_end AS period_end, v_days AS days,
           v_open  AS opening_ap, v_close AS closing_ap,
           ROUND((v_open + v_close)/2, 2) AS average_ap,
           v_purch AS credit_purchases,
           ROUND(((v_open + v_close)/2) / v_purch * v_days, 1) AS dpo_days;
END$$

-- ---------------------------------------------------------------------
-- A2. EARLY-PAYMENT DISCOUNT YIELD for a period
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_discount_yield(IN p_start DATE, IN p_end DATE, IN p_asof DATE)
BEGIN
    SELECT COUNT(*)                                             AS discount_eligible_invoices,
           SUM(total_amount)                                    AS eligible_spend,
           SUM(discount_available)                              AS discount_offered,
           SUM(discount_taken)                                  AS discount_captured,
           SUM(CASE WHEN discount_deadline < p_asof
                    THEN discount_available - discount_taken END) AS discount_missed,
           ROUND(SUM(discount_taken)/SUM(discount_available)*100, 1) AS capture_rate_pct,
           ROUND(SUM(discount_taken)/SUM(total_amount)*100, 2)       AS early_discount_yield_pct
      FROM invoices
     WHERE invoice_date BETWEEN p_start AND p_end
       AND discount_available > 0 AND status IN ('APPROVED','PARTIALLY_PAID','PAID');
END$$

-- ---------------------------------------------------------------------
-- A3. AP AGING as at a date (current / 1-30 / 31-60 / 61-90 / 90+ days past due)
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_ap_aging(IN p_asof DATE)
BEGIN
    SELECT v.vendor_code, v.vendor_name,
           SUM(CASE WHEN d.days_past_due <= 0                    THEN d.os ELSE 0 END) AS current_not_due,
           SUM(CASE WHEN d.days_past_due BETWEEN 1  AND 30       THEN d.os ELSE 0 END) AS days_1_30,
           SUM(CASE WHEN d.days_past_due BETWEEN 31 AND 60       THEN d.os ELSE 0 END) AS days_31_60,
           SUM(CASE WHEN d.days_past_due BETWEEN 61 AND 90       THEN d.os ELSE 0 END) AS days_61_90,
           SUM(CASE WHEN d.days_past_due > 90                    THEN d.os ELSE 0 END) AS days_90_plus,
           SUM(d.os) AS total_outstanding
      FROM (SELECT i.vendor_id, DATEDIFF(p_asof, i.due_date) AS days_past_due,
                   i.total_amount - COALESCE(s.settled,0) AS os
              FROM invoices i
              LEFT JOIN (SELECT invoice_id, SUM(amount_paid + discount_taken) AS settled
                           FROM payments WHERE payment_date <= p_asof GROUP BY invoice_id) s
                     ON s.invoice_id = i.invoice_id
             WHERE i.invoice_date <= p_asof AND i.status <> 'REJECTED') d
      JOIN vendors v ON v.vendor_id = d.vendor_id
     WHERE d.os > 0
     GROUP BY v.vendor_id, v.vendor_code, v.vendor_name
     ORDER BY total_outstanding DESC;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- A4. Vendor-wise DPO (amount-weighted days taken to pay) and discount behaviour
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_vendor_dpo AS
SELECT v.vendor_code, v.vendor_name, pt.term_code, pt.net_days AS terms_days,
       ROUND(SUM((p.amount_paid + p.discount_taken) * DATEDIFF(p.payment_date, i.invoice_date))
             / SUM(p.amount_paid + p.discount_taken), 1)             AS avg_days_to_pay,
       ROUND(SUM((p.amount_paid + p.discount_taken) * DATEDIFF(p.payment_date, i.invoice_date))
             / SUM(p.amount_paid + p.discount_taken) - pt.net_days, 1) AS days_vs_terms,
       SUM(i.discount_available)                                       AS discount_offered,
       SUM(i.discount_taken)                                           AS discount_captured
  FROM payments p
  JOIN invoices i ON i.invoice_id = p.invoice_id
  JOIN vendors  v ON v.vendor_id  = i.vendor_id
  JOIN payment_terms pt ON pt.term_id = i.term_id
 GROUP BY v.vendor_id, v.vendor_code, v.vendor_name, pt.term_code, pt.net_days;

-- ---------------------------------------------------------------------
-- A5. Implied annual return of taking an early-payment discount
--     Annualised return = d / (1 - d) x 365 / (net_days - discount_days)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_discount_annualised_return AS
SELECT term_code,
       ROUND( (discount_pct/100) / (1 - discount_pct/100)
              * 365 / (net_days - discount_days) * 100, 2) AS annualised_return_pct
  FROM payment_terms WHERE discount_pct > 0;

-- ---------------------------------------------------------------------
-- A6. Payment pipeline: what must be paid in the next 14 days (cash planning)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_payment_pipeline AS
SELECT invoice_number, vendor_name, due_date,
       DATEDIFF(due_date, CURDATE()) AS days_to_due, outstanding
  FROM vw_invoice_balance
 WHERE status IN ('APPROVED','PARTIALLY_PAID') AND outstanding > 0
 ORDER BY due_date;

-- =====================================================================
-- SAMPLE REPORT CALLS  (period = 1 Aug 2026 - 31 Oct 2026, as-of = 14 Nov 2026)
-- =====================================================================
CALL sp_dpo('2026-08-01','2026-10-31');
CALL sp_discount_yield('2026-08-01','2026-10-31','2026-11-14');
CALL sp_ap_aging('2026-11-14');
SELECT * FROM vw_vendor_dpo ORDER BY avg_days_to_pay DESC;
SELECT * FROM vw_discount_annualised_return;
SELECT * FROM vw_vendor_scorecard ORDER BY total_billed DESC;

-- =====================================================================
-- CONTROL TESTS  (each statement below is EXPECTED TO FAIL with the shown message)
-- Run them one at a time; they prove the database enforces the business rules.
-- =====================================================================
-- T1 duplicate invoice number for the same vendor  -> ERROR 1062 Duplicate entry
-- INSERT INTO invoices(invoice_number,vendor_id,po_id,term_id,invoice_date,received_date,subtotal,tax_amount,entered_by)
--   SELECT invoice_number,vendor_id,po_id,term_id,invoice_date,received_date,subtotal,tax_amount,entered_by FROM invoices WHERE invoice_id=1;

-- T2 invoice from a BLOCKED vendor (V011)           -> 'Vendor is BLOCKED - invoice cannot be booked'
-- INSERT INTO invoices(invoice_number,vendor_id,po_id,term_id,invoice_date,received_date,subtotal,tax_amount,entered_by)
--   VALUES ('K-0001',11,NULL,3,'2026-11-01','2026-11-01',50000,9000,1);

-- T3 paying a disputed / unapproved invoice         -> 'Invoice is not approved for payment'
-- CALL sp_pay_invoice((SELECT invoice_id FROM invoices WHERE status='DISPUTED' LIMIT 1),'2026-11-14','NEFT','UTR-TEST-1',1,0);

-- T4 claiming a discount after the window closed    -> 'Early-payment discount window has closed'
-- INSERT INTO payments(invoice_id,payment_date,amount_paid,discount_taken,method,reference_no,paid_by)
--   SELECT invoice_id,'2026-11-14',1000,500,'NEFT','UTR-TEST-2',1 FROM invoices
--    WHERE status='APPROVED' AND discount_deadline < '2026-11-14' LIMIT 1;

-- T5 over-payment                                   -> 'Payment exceeds outstanding invoice balance'
-- INSERT INTO payments(invoice_id,payment_date,amount_paid,discount_taken,method,reference_no,paid_by)
--   SELECT invoice_id,'2026-11-14',total_amount*2,0,'NEFT','UTR-TEST-3',1 FROM invoices WHERE status='APPROVED' LIMIT 1;
