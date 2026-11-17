-- =====================================================================
--  B2B CORPORATE INVOICE & ACCOUNTS PAYABLE SYSTEM
--  File 1 of 3 : Schema (tables, constraints, triggers, procedures, views)
--  Target      : MySQL 8.0+ (also tested on MariaDB 10.11)
-- =====================================================================

DROP DATABASE IF EXISTS ap_system;
CREATE DATABASE ap_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ap_system;

-- ---------------------------------------------------------------------
-- 1. MASTER / REFERENCE TABLES
-- ---------------------------------------------------------------------
CREATE TABLE departments (
    dept_id      INT AUTO_INCREMENT PRIMARY KEY,
    dept_name    VARCHAR(60) NOT NULL UNIQUE,
    cost_centre  VARCHAR(10) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE users (
    user_id      INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(80)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    role         ENUM('AP_CLERK','DEPT_MANAGER','FINANCE_HEAD','ADMIN') NOT NULL,
    dept_id      INT NULL,
    is_active    TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_users_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
) ENGINE=InnoDB;

-- Payment terms such as "2/10 Net 30" = 2% discount if paid within 10 days, else full by day 30
CREATE TABLE payment_terms (
    term_id        INT AUTO_INCREMENT PRIMARY KEY,
    term_code      VARCHAR(20) NOT NULL UNIQUE,
    discount_pct   DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    discount_days  INT NOT NULL DEFAULT 0,
    net_days       INT NOT NULL,
    CONSTRAINT chk_terms CHECK (discount_pct >= 0 AND discount_pct < 100
                                AND discount_days <= net_days AND net_days > 0)
) ENGINE=InnoDB;

CREATE TABLE vendors (
    vendor_id      INT AUTO_INCREMENT PRIMARY KEY,
    vendor_code    VARCHAR(12)  NOT NULL UNIQUE,
    vendor_name    VARCHAR(100) NOT NULL,
    tax_id         VARCHAR(15)  NOT NULL UNIQUE,          -- GSTIN
    contact_email  VARCHAR(100) NOT NULL,
    phone          VARCHAR(15),
    city           VARCHAR(50),
    bank_account   VARCHAR(20)  NOT NULL,
    bank_ifsc      VARCHAR(11)  NOT NULL,
    term_id        INT NOT NULL,                          -- default payment term
    category       VARCHAR(40),
    status         ENUM('ACTIVE','ON_HOLD','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vendor_term FOREIGN KEY (term_id) REFERENCES payment_terms(term_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. PURCHASING
-- ---------------------------------------------------------------------
CREATE TABLE purchase_orders (
    po_id         INT AUTO_INCREMENT PRIMARY KEY,
    po_number     VARCHAR(15) NOT NULL UNIQUE,
    vendor_id     INT NOT NULL,
    dept_id       INT NOT NULL,
    created_by    INT NOT NULL,
    po_date       DATE NOT NULL,
    po_value      DECIMAL(14,2) NOT NULL,                 -- pre-tax value
    status        ENUM('OPEN','PARTIALLY_RECEIVED','CLOSED','CANCELLED') NOT NULL DEFAULT 'OPEN',
    CONSTRAINT fk_po_vendor FOREIGN KEY (vendor_id)  REFERENCES vendors(vendor_id),
    CONSTRAINT fk_po_dept   FOREIGN KEY (dept_id)    REFERENCES departments(dept_id),
    CONSTRAINT fk_po_user   FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT chk_po_value CHECK (po_value > 0)
) ENGINE=InnoDB;

CREATE TABLE po_items (
    po_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    po_id        INT NOT NULL,
    description  VARCHAR(120) NOT NULL,
    quantity     DECIMAL(10,2) NOT NULL,
    unit_price   DECIMAL(12,2) NOT NULL,
    line_total   DECIMAL(14,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    CONSTRAINT fk_poi_po FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    CONSTRAINT chk_poi CHECK (quantity > 0 AND unit_price >= 0)
) ENGINE=InnoDB;

CREATE TABLE goods_receipts (
    grn_id          INT AUTO_INCREMENT PRIMARY KEY,
    po_id           INT NOT NULL,
    received_date   DATE NOT NULL,
    received_value  DECIMAL(14,2) NOT NULL,               -- pre-tax value of goods/services accepted
    received_by     INT NOT NULL,
    CONSTRAINT fk_grn_po   FOREIGN KEY (po_id)       REFERENCES purchase_orders(po_id),
    CONSTRAINT fk_grn_user FOREIGN KEY (received_by) REFERENCES users(user_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. INVOICES
-- ---------------------------------------------------------------------
CREATE TABLE invoices (
    invoice_id         INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number     VARCHAR(25) NOT NULL,              -- vendor's own number
    vendor_id          INT NOT NULL,
    po_id              INT NULL,
    term_id            INT NOT NULL,
    invoice_date       DATE NOT NULL,
    received_date      DATE NOT NULL,
    due_date           DATE NULL,                          -- set by trigger
    discount_deadline  DATE NULL,                          -- set by trigger
    subtotal           DECIMAL(14,2) NOT NULL,
    tax_amount         DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    total_amount       DECIMAL(14,2) GENERATED ALWAYS AS (subtotal + tax_amount) STORED,
    discount_available DECIMAL(14,2) NOT NULL DEFAULT 0.00, -- set by trigger
    paid_amount        DECIMAL(14,2) NOT NULL DEFAULT 0.00, -- cash paid, maintained by trigger
    discount_taken     DECIMAL(14,2) NOT NULL DEFAULT 0.00, -- maintained by trigger
    match_status       ENUM('PENDING','MATCHED','VARIANCE','NO_PO') NOT NULL DEFAULT 'PENDING',
    status             ENUM('RECEIVED','MATCHED','APPROVED','PARTIALLY_PAID','PAID','DISPUTED','REJECTED')
                       NOT NULL DEFAULT 'RECEIVED',
    entered_by         INT NOT NULL,
    CONSTRAINT uq_vendor_invoice UNIQUE (vendor_id, invoice_number),   -- duplicate-invoice control
    CONSTRAINT fk_inv_vendor FOREIGN KEY (vendor_id)  REFERENCES vendors(vendor_id),
    CONSTRAINT fk_inv_po     FOREIGN KEY (po_id)      REFERENCES purchase_orders(po_id),
    CONSTRAINT fk_inv_term   FOREIGN KEY (term_id)    REFERENCES payment_terms(term_id),
    CONSTRAINT fk_inv_user   FOREIGN KEY (entered_by) REFERENCES users(user_id),
    CONSTRAINT chk_inv_amt   CHECK (subtotal > 0 AND tax_amount >= 0),
    INDEX idx_inv_status_due (status, due_date),
    INDEX idx_inv_vendor_date (vendor_id, invoice_date)
) ENGINE=InnoDB;

CREATE TABLE invoice_approvals (
    approval_id   INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id    INT NOT NULL,
    approver_id   INT NOT NULL,
    level_no      TINYINT NOT NULL,                        -- 1 = Dept Manager, 2 = Finance Head
    decision      ENUM('APPROVED','REJECTED','QUERY') NOT NULL,
    decided_on    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remarks       VARCHAR(200),
    CONSTRAINT fk_apr_inv  FOREIGN KEY (invoice_id)  REFERENCES invoices(invoice_id),
    CONSTRAINT fk_apr_user FOREIGN KEY (approver_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. PAYMENTS
-- ---------------------------------------------------------------------
CREATE TABLE payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id      INT NOT NULL,
    payment_date    DATE NOT NULL,
    amount_paid     DECIMAL(14,2) NOT NULL,                -- cash leaving the bank
    discount_taken  DECIMAL(14,2) NOT NULL DEFAULT 0.00,   -- early-payment discount claimed
    method          ENUM('NEFT','RTGS','CHEQUE','UPI','WIRE') NOT NULL,
    reference_no    VARCHAR(30) NOT NULL UNIQUE,
    paid_by         INT NOT NULL,
    CONSTRAINT fk_pay_inv  FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    CONSTRAINT fk_pay_user FOREIGN KEY (paid_by)    REFERENCES users(user_id),
    CONSTRAINT chk_pay CHECK (amount_paid > 0 AND discount_taken >= 0)
) ENGINE=InnoDB;

CREATE TABLE audit_log (
    log_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name  VARCHAR(30) NOT NULL,
    record_id   INT NOT NULL,
    action      VARCHAR(20) NOT NULL,
    details     VARCHAR(255),
    logged_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. TRIGGERS (business rules enforced inside the database)
-- ---------------------------------------------------------------------
DELIMITER $$

-- T1: block blocked vendors; derive due date, discount deadline and discount amount
CREATE TRIGGER trg_invoice_before_insert
BEFORE INSERT ON invoices FOR EACH ROW
BEGIN
    DECLARE v_pct    DECIMAL(5,2);
    DECLARE v_dd     INT;
    DECLARE v_net    INT;
    DECLARE v_status VARCHAR(10);

    SELECT status INTO v_status FROM vendors WHERE vendor_id = NEW.vendor_id;
    IF v_status = 'BLOCKED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendor is BLOCKED - invoice cannot be booked';
    END IF;

    SELECT discount_pct, discount_days, net_days
      INTO v_pct, v_dd, v_net
      FROM payment_terms WHERE term_id = NEW.term_id;

    SET NEW.due_date = DATE_ADD(NEW.invoice_date, INTERVAL v_net DAY);
    IF v_pct > 0 THEN
        SET NEW.discount_deadline  = DATE_ADD(NEW.invoice_date, INTERVAL v_dd DAY);
        SET NEW.discount_available = ROUND((NEW.subtotal + NEW.tax_amount) * v_pct / 100, 2);
    ELSE
        SET NEW.discount_deadline  = NULL;
        SET NEW.discount_available = 0.00;
    END IF;
    IF NEW.po_id IS NULL THEN
        SET NEW.match_status = 'NO_PO';
    END IF;
END$$

-- T2: audit every new invoice
CREATE TRIGGER trg_invoice_after_insert
AFTER INSERT ON invoices FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, record_id, action, details)
    VALUES ('invoices', NEW.invoice_id, 'BOOKED',
            CONCAT('Invoice ', NEW.invoice_number, ' total ', NEW.total_amount));
END$$

-- T3: validate payment (status, balance, discount eligibility) BEFORE it is saved
CREATE TRIGGER trg_payment_before_insert
BEFORE INSERT ON payments FOR EACH ROW
BEGIN
    DECLARE v_total    DECIMAL(14,2);
    DECLARE v_paid     DECIMAL(14,2);
    DECLARE v_disc     DECIMAL(14,2);
    DECLARE v_disc_av  DECIMAL(14,2);
    DECLARE v_deadline DATE;
    DECLARE v_status   VARCHAR(20);

    SELECT total_amount, paid_amount, discount_taken, discount_available, discount_deadline, status
      INTO v_total, v_paid, v_disc, v_disc_av, v_deadline, v_status
      FROM invoices WHERE invoice_id = NEW.invoice_id;

    IF v_status NOT IN ('APPROVED','PARTIALLY_PAID') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invoice is not approved for payment';
    END IF;

    IF NEW.discount_taken > 0 THEN
        IF v_deadline IS NULL OR NEW.payment_date > v_deadline THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Early-payment discount window has closed';
        END IF;
        IF v_disc + NEW.discount_taken > v_disc_av THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Discount claimed exceeds discount available';
        END IF;
    END IF;

    IF v_paid + v_disc + NEW.amount_paid + NEW.discount_taken > v_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment exceeds outstanding invoice balance';
    END IF;
END$$

-- T4: roll payment into the invoice and update its status
CREATE TRIGGER trg_payment_after_insert
AFTER INSERT ON payments FOR EACH ROW
BEGIN
    -- NOTE: MySQL evaluates SET assignments left-to-right, so status must be
    -- computed BEFORE paid_amount / discount_taken are overwritten.
    UPDATE invoices
       SET status = CASE
                      WHEN paid_amount + NEW.amount_paid + discount_taken + NEW.discount_taken >= total_amount
                      THEN 'PAID' ELSE 'PARTIALLY_PAID' END,
           paid_amount    = paid_amount + NEW.amount_paid,
           discount_taken = discount_taken + NEW.discount_taken
     WHERE invoice_id = NEW.invoice_id;

    INSERT INTO audit_log(table_name, record_id, action, details)
    VALUES ('payments', NEW.payment_id, 'PAID',
            CONCAT('Invoice ', NEW.invoice_id, ' cash ', NEW.amount_paid,
                   ' discount ', NEW.discount_taken));
END$$

-- ---------------------------------------------------------------------
-- 6. STORED PROCEDURES (the transaction-processing workflow)
-- ---------------------------------------------------------------------

-- P1: three-way match  (Purchase Order  <->  Goods Receipt  <->  Invoice), 2% tolerance
CREATE PROCEDURE sp_three_way_match(IN p_invoice_id INT)
BEGIN
    DECLARE v_po INT;
    DECLARE v_sub DECIMAL(14,2);
    DECLARE v_po_value DECIMAL(14,2);
    DECLARE v_grn DECIMAL(14,2);

    SELECT po_id, subtotal INTO v_po, v_sub FROM invoices WHERE invoice_id = p_invoice_id;

    IF v_po IS NULL THEN
        UPDATE invoices SET match_status = 'NO_PO' WHERE invoice_id = p_invoice_id;
    ELSE
        SELECT po_value INTO v_po_value FROM purchase_orders WHERE po_id = v_po;
        SELECT COALESCE(SUM(received_value),0) INTO v_grn FROM goods_receipts WHERE po_id = v_po;

        IF v_sub <= v_po_value * 1.02 AND v_sub <= v_grn * 1.02 THEN
            UPDATE invoices SET match_status = 'MATCHED', status = 'MATCHED'
             WHERE invoice_id = p_invoice_id AND status = 'RECEIVED';
        ELSE
            UPDATE invoices SET match_status = 'VARIANCE', status = 'DISPUTED'
             WHERE invoice_id = p_invoice_id AND status = 'RECEIVED';
        END IF;
    END IF;
END$$

-- P2: two-level approval (1 = Dept Manager, 2 = Finance Head)
CREATE PROCEDURE sp_approve_invoice(IN p_invoice_id INT, IN p_approver INT, IN p_level TINYINT,
                                    IN p_decision VARCHAR(10), IN p_remarks VARCHAR(200))
BEGIN
    INSERT INTO invoice_approvals(invoice_id, approver_id, level_no, decision, remarks)
    VALUES (p_invoice_id, p_approver, p_level, p_decision, p_remarks);

    IF p_decision = 'REJECTED' THEN
        UPDATE invoices SET status = 'REJECTED' WHERE invoice_id = p_invoice_id;
    ELSEIF p_decision = 'APPROVED' AND p_level = 2 THEN
        UPDATE invoices SET status = 'APPROVED'
         WHERE invoice_id = p_invoice_id AND status IN ('MATCHED','RECEIVED');
    END IF;
END$$

-- P3: pay an invoice in full; optionally capture the early-payment discount
CREATE PROCEDURE sp_pay_invoice(IN p_invoice_id INT, IN p_date DATE, IN p_method VARCHAR(10),
                                IN p_ref VARCHAR(30), IN p_user INT, IN p_take_discount TINYINT)
BEGIN
    DECLARE v_total DECIMAL(14,2);
    DECLARE v_paid  DECIMAL(14,2);
    DECLARE v_disc  DECIMAL(14,2);
    DECLARE v_disc_av DECIMAL(14,2);
    DECLARE v_deadline DATE;
    DECLARE v_new_disc DECIMAL(14,2) DEFAULT 0;

    SELECT total_amount, paid_amount, discount_taken, discount_available, discount_deadline
      INTO v_total, v_paid, v_disc, v_disc_av, v_deadline
      FROM invoices WHERE invoice_id = p_invoice_id;

    IF p_take_discount = 1 AND v_deadline IS NOT NULL AND p_date <= v_deadline THEN
        SET v_new_disc = v_disc_av - v_disc;
    END IF;

    INSERT INTO payments(invoice_id, payment_date, amount_paid, discount_taken, method, reference_no, paid_by)
    VALUES (p_invoice_id, p_date, v_total - v_paid - v_disc - v_new_disc, v_new_disc,
            p_method, p_ref, p_user);
END$$

-- ---------------------------------------------------------------------
-- 7. FUNCTIONS used by the MIS / DSS reports
-- ---------------------------------------------------------------------

-- Outstanding payable balance of all (non-rejected) invoices as at a date
CREATE FUNCTION fn_ap_balance(p_asof DATE) RETURNS DECIMAL(16,2)
READS SQL DATA
BEGIN
    DECLARE v_bal DECIMAL(16,2);
    SELECT COALESCE(SUM(i.total_amount - COALESCE(s.settled,0)),0) INTO v_bal
      FROM invoices i
      LEFT JOIN (SELECT invoice_id, SUM(amount_paid + discount_taken) AS settled
                   FROM payments WHERE payment_date <= p_asof GROUP BY invoice_id) s
             ON s.invoice_id = i.invoice_id
     WHERE i.invoice_date <= p_asof AND i.status <> 'REJECTED';
    RETURN v_bal;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 8. VIEWS
-- ---------------------------------------------------------------------
CREATE VIEW vw_invoice_balance AS
SELECT i.invoice_id, i.invoice_number, v.vendor_code, v.vendor_name,
       i.invoice_date, i.due_date, i.discount_deadline,
       i.total_amount, i.paid_amount, i.discount_taken,
       (i.total_amount - i.paid_amount - i.discount_taken) AS outstanding,
       i.status
  FROM invoices i JOIN vendors v ON v.vendor_id = i.vendor_id;

CREATE VIEW vw_vendor_scorecard AS
SELECT v.vendor_code, v.vendor_name, pt.term_code,
       COUNT(i.invoice_id)                         AS invoices,
       SUM(i.total_amount)                         AS total_billed,
       SUM(i.paid_amount)                          AS cash_paid,
       SUM(i.discount_taken)                       AS discount_captured,
       SUM(i.total_amount - i.paid_amount - i.discount_taken) AS outstanding,
       SUM(i.match_status = 'VARIANCE')            AS match_exceptions
  FROM vendors v
  JOIN payment_terms pt ON pt.term_id = v.term_id
  LEFT JOIN invoices i  ON i.vendor_id = v.vendor_id AND i.status <> 'REJECTED'
 GROUP BY v.vendor_id, v.vendor_code, v.vendor_name, pt.term_code;
