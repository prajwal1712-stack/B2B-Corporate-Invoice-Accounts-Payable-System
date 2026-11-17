-- =====================================================================
--  File 2 of 3 : Sample data (reproducible, generated for the project)
--  Load AFTER 01_schema.sql on a FRESH database (IDs are assumed sequential)
-- =====================================================================
USE ap_system;

INSERT INTO departments(dept_name,cost_centre) VALUES
('Information Technology','CC-IT01'),('Operations','CC-OP02'),('Marketing','CC-MK03'),('Facilities','CC-FC04'),('Human Resources','CC-HR05');

INSERT INTO users(full_name,email,role,dept_id) VALUES
('Ritu Sharma','ritu.sharma@acmecorp.in','AP_CLERK',NULL),
('Arjun Mehta','arjun.mehta@acmecorp.in','AP_CLERK',NULL),
('Neha Kapoor','neha.kapoor@acmecorp.in','DEPT_MANAGER',1),
('Sanjay Rao','sanjay.rao@acmecorp.in','DEPT_MANAGER',2),
('Meera Iyer','meera.iyer@acmecorp.in','FINANCE_HEAD',NULL),
('System Admin','admin@acmecorp.in','ADMIN',NULL);

INSERT INTO payment_terms(term_code,discount_pct,discount_days,net_days) VALUES
('2/10 Net 30',2.0,10,30),
('1/10 Net 45',1.0,10,45),
('Net 30',0,0,30),
('Net 45',0,0,45),
('Net 60',0,0,60),
('1.5/15 Net 45',1.5,15,45);

INSERT INTO vendors(vendor_code,vendor_name,tax_id,contact_email,phone,city,bank_account,bank_ifsc,term_id,category,status) VALUES
('V001','Apex Office Supplies Pvt Ltd','27AACB1037A1Z2','accounts@apex.example','9811111111','Pune','50100007919','HDFC0001001',1,'Stationery & Supplies','ACTIVE'),
('V002','BlueWave IT Solutions','27AACC1074A1Z3','accounts@bluewave.example','9812222222','Bengaluru','50100015838','HDFC0001002',2,'IT Services','ACTIVE'),
('V003','Cargo Link Logistics','27AACD1111A1Z4','accounts@cargo.example','9813333333','Mumbai','50100023757','HDFC0001003',3,'Logistics','ACTIVE'),
('V004','Delta Packaging Industries','27AACE1148A1Z5','accounts@delta.example','9814444444','Ahmedabad','50100031676','HDFC0001004',1,'Packaging','ACTIVE'),
('V005','EverGreen Facility Services','27AACF1185A1Z6','accounts@evergreen.example','9815555555','Delhi','50100039595','HDFC0001005',4,'Facilities','ACTIVE'),
('V006','FlexiPrint Media','27AACG1222A1Z7','accounts@flexiprint.example','9816666666','Chennai','50100047514','HDFC0001006',6,'Printing & Marketing','ACTIVE'),
('V007','GlobalTech Hardware Traders','27AACH1259A1Z8','accounts@globaltech.example','9817777777','Hyderabad','50100055433','HDFC0001007',1,'IT Hardware','ACTIVE'),
('V008','Horizon Cloud Hosting','27AACI1296A1Z9','accounts@horizon.example','9818888888','Bengaluru','50100063352','HDFC0001008',5,'Cloud Services','ACTIVE'),
('V009','Indus Raw Materials Co','27AACJ1333A1Z1','accounts@indus.example','9819999999','Surat','50100071271','HDFC0001009',2,'Raw Materials','ACTIVE'),
('V010','Jupiter Consulting LLP','27AACK1370A1Z2','accounts@jupiter.example','9821111110','Gurugram','50100079190','HDFC0001010',3,'Consulting','ACTIVE'),
('V011','Kestrel Traders','27AACL1407A1Z3','accounts@kestrel.example','9822222221','Kolkata','50100087109','HDFC0001011',3,'General Trading','BLOCKED');

INSERT INTO purchase_orders(po_number,vendor_id,dept_id,created_by,po_date,po_value,status) VALUES
('PO-2026-0001',6,3,2,'2026-06-23',273800.00,'CLOSED'),
('PO-2026-0002',7,1,1,'2026-06-19',447300.00,'CLOSED'),
('PO-2026-0003',8,1,2,'2026-06-26',159000.00,'CLOSED'),
('PO-2026-0004',1,1,1,'2026-07-04',73100.00,'CLOSED'),
('PO-2026-0005',9,2,2,'2026-06-27',663700.00,'CLOSED'),
('PO-2026-0006',10,3,1,'2026-07-03',545600.00,'CLOSED'),
('PO-2026-0007',3,2,2,'2026-07-13',438400.00,'CLOSED'),
('PO-2026-0008',5,5,1,'2026-06-30',678400.00,'CLOSED'),
('PO-2026-0009',10,3,2,'2026-07-17',898000.00,'CLOSED'),
('PO-2026-0010',1,2,1,'2026-07-17',707600.00,'CLOSED'),
('PO-2026-0011',7,1,2,'2026-07-14',119400.00,'CLOSED'),
('PO-2026-0012',10,5,1,'2026-07-26',870600.00,'CLOSED'),
('PO-2026-0013',4,4,2,'2026-07-26',757700.00,'CLOSED'),
('PO-2026-0014',4,2,1,'2026-07-23',888500.00,'CLOSED'),
('PO-2026-0015',1,2,2,'2026-08-05',44200.00,'CLOSED'),
('PO-2026-0016',7,1,1,'2026-08-10',259600.00,'CLOSED'),
('PO-2026-0017',10,5,2,'2026-08-16',409400.00,'CLOSED'),
('PO-2026-0018',3,2,1,'2026-08-10',52400.00,'CLOSED'),
('PO-2026-0019',4,4,2,'2026-08-20',835600.00,'CLOSED'),
('PO-2026-0020',6,3,1,'2026-08-21',582700.00,'CLOSED'),
('PO-2026-0021',9,2,2,'2026-08-24',455600.00,'CLOSED'),
('PO-2026-0022',10,5,1,'2026-08-19',565500.00,'CLOSED'),
('PO-2026-0023',4,4,2,'2026-08-30',150800.00,'CLOSED'),
('PO-2026-0024',2,2,1,'2026-09-07',455800.00,'CLOSED'),
('PO-2026-0025',4,4,2,'2026-09-06',850100.00,'CLOSED'),
('PO-2026-0026',10,5,1,'2026-09-10',89200.00,'CLOSED'),
('PO-2026-0027',2,2,2,'2026-09-09',50900.00,'CLOSED'),
('PO-2026-0028',7,1,1,'2026-09-04',666300.00,'CLOSED'),
('PO-2026-0029',4,2,2,'2026-09-11',496100.00,'CLOSED'),
('PO-2026-0030',1,2,1,'2026-09-22',349300.00,'CLOSED'),
('PO-2026-0031',5,4,2,'2026-09-25',299900.00,'CLOSED'),
('PO-2026-0032',3,2,1,'2026-09-19',584400.00,'CLOSED'),
('PO-2026-0033',9,2,2,'2026-09-24',868600.00,'CLOSED'),
('PO-2026-0034',6,3,1,'2026-09-27',773200.00,'CLOSED'),
('PO-2026-0035',8,1,2,'2026-09-18',519300.00,'CLOSED'),
('PO-2026-0036',9,2,1,'2026-09-19',742500.00,'CLOSED'),
('PO-2026-0037',4,4,2,'2026-09-24',588200.00,'CLOSED'),
('PO-2026-0038',10,5,1,'2026-09-22',62700.00,'CLOSED'),
('PO-2026-0039',10,5,2,'2026-09-23',812200.00,'CLOSED'),
('PO-2026-0040',5,4,1,'2026-09-26',853400.00,'CLOSED'),
('PO-2026-0041',6,3,2,'2026-10-08',346200.00,'CLOSED'),
('PO-2026-0042',2,2,1,'2026-10-01',584300.00,'CLOSED'),
('PO-2026-0043',9,2,2,'2026-10-16',318400.00,'CLOSED'),
('PO-2026-0044',9,2,1,'2026-10-12',530600.00,'CLOSED'),
('PO-2026-0045',6,3,2,'2026-10-10',698200.00,'CLOSED');

INSERT INTO po_items(po_id,description,quantity,unit_price) VALUES
(1,'Brochure printing',17,9663.53),
(1,'Event branding material',1,109519.99),
(2,'Laptops',14,19170.0),
(2,'Network switches',1,178920.0),
(3,'Cloud hosting - monthly',5,19080.0),
(3,'Backup storage',1,63600.0),
(4,'Office stationery bulk pack',13,3373.85),
(4,'Printer consumables',1,29239.95),
(5,'Polymer granules',6,66370.0),
(5,'Steel sheet lots',1,265480.0),
(6,'Process audit engagement',8,40920.0),
(6,'Advisory retainer',1,218240.0),
(7,'Freight - inbound lots',10,26304.0),
(7,'Last-mile delivery batch',1,175360.0),
(8,'Housekeeping contract',19,21423.16),
(8,'Facility maintenance',1,271359.96),
(9,'Process audit engagement',8,67350.0),
(9,'Advisory retainer',1,359200.0),
(10,'Office stationery bulk pack',10,42456.0),
(10,'Printer consumables',1,283040.0),
(11,'Laptops',17,4214.12),
(11,'Network switches',1,47759.96),
(12,'Process audit engagement',4,130590.0),
(12,'Advisory retainer',1,348240.0),
(13,'Corrugated boxes',7,64945.71),
(13,'Packaging film rolls',1,303080.03),
(14,'Corrugated boxes',3,177700.0),
(14,'Packaging film rolls',1,355400.0),
(15,'Office stationery bulk pack',11,2410.91),
(15,'Printer consumables',1,17679.99),
(16,'Laptops',15,10384.0),
(16,'Network switches',1,103840.0),
(17,'Process audit engagement',7,35091.43),
(17,'Advisory retainer',1,163759.99),
(18,'Freight - inbound lots',14,2245.71),
(18,'Last-mile delivery batch',1,20960.06),
(19,'Corrugated boxes',9,55706.67),
(19,'Packaging film rolls',1,334239.97),
(20,'Brochure printing',18,19423.33),
(20,'Event branding material',1,233080.06),
(21,'Polymer granules',12,22780.0),
(21,'Steel sheet lots',1,182240.0),
(22,'Process audit engagement',18,18850.0),
(22,'Advisory retainer',1,226200.0),
(23,'Corrugated boxes',7,12925.71),
(23,'Packaging film rolls',1,60320.03),
(24,'Managed service retainer',9,30386.67),
(24,'Application support hours',1,182319.97),
(25,'Corrugated boxes',19,26845.26),
(25,'Packaging film rolls',1,340040.06),
(26,'Process audit engagement',17,3148.24),
(26,'Advisory retainer',1,35679.92),
(27,'Managed service retainer',20,1527.0),
(27,'Application support hours',1,20360.0),
(28,'Laptops',9,44420.0),
(28,'Network switches',1,266520.0),
(29,'Corrugated boxes',17,17509.41),
(29,'Packaging film rolls',1,198440.03),
(30,'Office stationery bulk pack',15,13972.0),
(30,'Printer consumables',1,139720.0),
(31,'Housekeeping contract',18,9996.67),
(31,'Facility maintenance',1,119959.94),
(32,'Freight - inbound lots',13,26972.31),
(32,'Last-mile delivery batch',1,233759.97),
(33,'Polymer granules',10,52116.0),
(33,'Steel sheet lots',1,347440.0),
(34,'Brochure printing',11,42174.55),
(34,'Event branding material',1,309279.95),
(35,'Cloud hosting - monthly',14,22255.71),
(35,'Backup storage',1,207720.06),
(36,'Polymer granules',15,29700.0),
(36,'Steel sheet lots',1,297000.0),
(37,'Corrugated boxes',13,27147.69),
(37,'Packaging film rolls',1,235280.03),
(38,'Process audit engagement',5,7524.0),
(38,'Advisory retainer',1,25080.0),
(39,'Process audit engagement',2,243660.0),
(39,'Advisory retainer',1,324880.0),
(40,'Housekeeping contract',3,170680.0),
(40,'Facility maintenance',1,341360.0),
(41,'Brochure printing',7,29674.29),
(41,'Event branding material',1,138479.97),
(42,'Managed service retainer',14,25041.43),
(42,'Application support hours',1,233719.98),
(43,'Polymer granules',6,31840.0),
(43,'Steel sheet lots',1,127360.0),
(44,'Polymer granules',20,15918.0),
(44,'Steel sheet lots',1,212240.0),
(45,'Brochure printing',4,104730.0),
(45,'Event branding material',1,279280.0);

INSERT INTO goods_receipts(po_id,received_date,received_value,received_by) VALUES
(1,'2026-07-02',273800,3),
(2,'2026-07-08',447300,3),
(3,'2026-07-07',159000,3),
(4,'2026-07-11',73100,3),
(5,'2026-07-12',663700,4),
(6,'2026-07-19',545600,3),
(7,'2026-07-22',438400,4),
(8,'2026-07-22',678400,4),
(9,'2026-07-27',808200.0,3),
(10,'2026-07-29',707600,4),
(11,'2026-08-03',119400,3),
(12,'2026-08-05',870600,4),
(13,'2026-08-05',757700,4),
(14,'2026-08-13',888500,4),
(15,'2026-08-15',44200,4),
(16,'2026-08-21',259600,3),
(17,'2026-08-24',409400,4),
(18,'2026-09-01',52400,4),
(19,'2026-09-01',835600,4),
(20,'2026-09-01',582700,3),
(21,'2026-09-04',455600,4),
(22,'2026-09-09',565500,4),
(23,'2026-09-11',150800,4),
(24,'2026-09-16',455800,4),
(25,'2026-09-20',850100,4),
(26,'2026-09-20',80280.0,4),
(27,'2026-09-24',50900,4),
(28,'2026-09-24',666300,3),
(29,'2026-09-26',496100,4),
(30,'2026-09-28',349300,4),
(31,'2026-10-05',299900,4),
(32,'2026-10-07',584400,4),
(33,'2026-10-05',868600,4),
(34,'2026-10-07',773200,3),
(35,'2026-10-08',519300,3),
(36,'2026-10-07',742500,4),
(37,'2026-10-08',588200,4),
(38,'2026-10-08',56430.0,4),
(39,'2026-10-12',812200,4),
(40,'2026-10-15',853400,4),
(41,'2026-10-15',346200,3),
(42,'2026-10-21',584300,4),
(43,'2026-10-27',318400,4),
(44,'2026-10-28',530600,4),
(45,'2026-10-27',698200,3);

-- Invoices: due_date, discount_deadline and discount_available are filled by trigger trg_invoice_before_insert
INSERT INTO invoices(invoice_number,vendor_id,po_id,term_id,invoice_date,received_date,subtotal,tax_amount,entered_by) VALUES
('V006-2600',6,1,6,'2026-07-06','2026-07-08',273800.00,49284.0,1),
('V007-2601',7,2,1,'2026-07-09','2026-07-09',447300.00,80514.0,2),
('V008-2602',8,3,5,'2026-07-09','2026-07-09',159000.00,28620.0,1),
('V001-2603',1,4,1,'2026-07-14','2026-07-14',73100.00,13158.0,2),
('V009-2604',9,5,2,'2026-07-14','2026-07-15',663700.00,119466.0,1),
('V001-2605',1,NULL,1,'2026-07-21','2026-07-23',87000.00,15660.0,2),
('V010-2606',10,6,3,'2026-07-22','2026-07-22',545600.00,98208.0,1),
('V003-2607',3,7,3,'2026-07-23','2026-07-24',438400.00,78912.0,2),
('V005-2608',5,8,4,'2026-07-23','2026-07-24',678400.00,122112.0,1),
('V010-2609',10,9,3,'2026-07-28','2026-07-28',898000.00,161640.0,2),
('V001-2610',1,10,1,'2026-07-30','2026-08-01',707600.00,127368.0,1),
('V007-2611',7,11,1,'2026-08-07','2026-08-08',119400.00,21492.0,2),
('V010-2612',10,12,3,'2026-08-07','2026-08-07',870600.00,156708.0,1),
('V004-2613',4,13,1,'2026-08-08','2026-08-08',757700.00,136386.0,2),
('V004-2614',4,14,1,'2026-08-14','2026-08-16',888500.00,159930.0,1),
('V001-2615',1,15,1,'2026-08-18','2026-08-18',44200.00,7956.0,2),
('V007-2616',7,16,1,'2026-08-23','2026-08-25',259600.00,46728.0,1),
('V010-2617',10,17,3,'2026-08-28','2026-08-28',409400.00,73692.0,2),
('V003-2618',3,18,3,'2026-09-03','2026-09-05',52400.00,9432.0,1),
('V004-2619',4,19,1,'2026-09-04','2026-09-05',835600.00,150408.0,2),
('V006-2620',6,20,6,'2026-09-04','2026-09-06',582700.00,104886.0,1),
('V007-2621',7,NULL,1,'2026-09-05','2026-09-05',645900.00,116262.0,2),
('V009-2622',9,21,2,'2026-09-05','2026-09-05',455600.00,82008.0,1),
('V010-2623',10,22,3,'2026-09-11','2026-09-12',565500.00,101790.0,2),
('V004-2624',4,23,1,'2026-09-12','2026-09-12',150800.00,27144.0,1),
('V002-2625',2,24,2,'2026-09-18','2026-09-20',455800.00,82044.0,2),
('V004-2626',4,25,1,'2026-09-22','2026-09-24',850100.00,153018.0,1),
('V010-2627',10,26,3,'2026-09-22','2026-09-24',89200.00,16056.0,2),
('V002-2628',2,27,2,'2026-09-28','2026-09-29',50900.00,9162.0,1),
('V007-2629',7,28,1,'2026-09-28','2026-09-29',666300.00,119934.0,2),
('V004-2630',4,29,1,'2026-09-30','2026-09-30',496100.00,89298.0,1),
('V001-2631',1,30,1,'2026-10-02','2026-10-02',349300.00,62874.0,2),
('V005-2632',5,31,4,'2026-10-06','2026-10-06',299900.00,53982.0,1),
('V007-2633',7,NULL,1,'2026-10-06','2026-10-06',100500.00,18090.0,2),
('V003-2634',3,32,3,'2026-10-09','2026-10-11',584400.00,105192.0,1),
('V009-2635',9,33,2,'2026-10-09','2026-10-10',868600.00,156348.0,2),
('V006-2636',6,34,6,'2026-10-11','2026-10-11',773200.00,139176.0,1),
('V008-2637',8,35,5,'2026-10-11','2026-10-11',519300.00,93474.0,2),
('V009-2638',9,36,2,'2026-10-11','2026-10-12',742500.00,133650.0,1),
('V004-2639',4,37,1,'2026-10-12','2026-10-12',588200.00,105876.0,2),
('V010-2640',10,38,3,'2026-10-12','2026-10-14',62700.00,11286.0,1),
('V010-2641',10,39,3,'2026-10-16','2026-10-16',812200.00,146196.0,2),
('V005-2642',5,40,4,'2026-10-19','2026-10-19',853400.00,153612.0,1),
('V006-2643',6,41,6,'2026-10-19','2026-10-20',346200.00,62316.0,2),
('V002-2644',2,42,2,'2026-10-24','2026-10-25',584300.00,105174.0,1),
('V009-2645',9,43,2,'2026-10-28','2026-10-30',318400.00,57312.0,2),
('V009-2646',9,44,2,'2026-10-29','2026-10-29',530600.00,95508.0,1),
('V006-2647',6,45,6,'2026-10-30','2026-11-01',698200.00,125676.0,2);

-- Workflow: 3-way match -> two-level approval
CALL sp_three_way_match(1);
CALL sp_approve_invoice(1,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(1,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(2);
CALL sp_approve_invoice(2,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(2,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(3);
CALL sp_approve_invoice(3,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(3,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(4);
CALL sp_approve_invoice(4,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(4,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(5);
CALL sp_approve_invoice(5,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(5,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(6);
CALL sp_approve_invoice(6,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(6,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(7);
CALL sp_approve_invoice(7,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(7,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(8);
CALL sp_approve_invoice(8,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(8,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(9);
CALL sp_approve_invoice(9,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(9,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(10);
CALL sp_three_way_match(11);
CALL sp_approve_invoice(11,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(11,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(12);
CALL sp_approve_invoice(12,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(12,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(13);
CALL sp_approve_invoice(13,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(13,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(14);
CALL sp_approve_invoice(14,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(14,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(15);
CALL sp_approve_invoice(15,4,1,'REJECTED','Duplicate of earlier billing - returned to vendor');
CALL sp_three_way_match(16);
CALL sp_approve_invoice(16,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(16,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(17);
CALL sp_approve_invoice(17,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(17,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(18);
CALL sp_approve_invoice(18,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(18,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(19);
CALL sp_approve_invoice(19,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(19,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(20);
CALL sp_approve_invoice(20,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(20,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(21);
CALL sp_approve_invoice(21,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(21,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(22);
CALL sp_approve_invoice(22,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(22,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(23);
CALL sp_approve_invoice(23,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(23,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(24);
CALL sp_approve_invoice(24,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(24,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(25);
CALL sp_approve_invoice(25,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(25,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(26);
CALL sp_approve_invoice(26,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(26,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(27);
CALL sp_approve_invoice(27,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(27,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(28);
CALL sp_three_way_match(29);
CALL sp_approve_invoice(29,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(29,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(30);
CALL sp_approve_invoice(30,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(30,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(31);
CALL sp_approve_invoice(31,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(31,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(32);
CALL sp_approve_invoice(32,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(32,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(33);
CALL sp_approve_invoice(33,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(33,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(34);
CALL sp_approve_invoice(34,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(34,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(35);
CALL sp_approve_invoice(35,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(35,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(36);
CALL sp_approve_invoice(36,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(36,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(37);
CALL sp_approve_invoice(37,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(37,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(38);
CALL sp_approve_invoice(38,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(38,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(39);
CALL sp_approve_invoice(39,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(39,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(40);
CALL sp_approve_invoice(40,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(40,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(41);
CALL sp_three_way_match(42);
CALL sp_approve_invoice(42,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(42,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(43);
CALL sp_approve_invoice(43,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(43,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(44);
CALL sp_approve_invoice(44,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(44,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(45);
CALL sp_approve_invoice(45,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(45,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(46);
CALL sp_approve_invoice(46,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(46,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(47);
CALL sp_approve_invoice(47,4,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(47,5,2,'APPROVED','Cleared for payment');
CALL sp_three_way_match(48);
CALL sp_approve_invoice(48,3,1,'APPROVED','Goods/services accepted');
CALL sp_approve_invoice(48,5,2,'APPROVED','Cleared for payment');

-- Payments (discount captured only when paid inside the discount window)
CALL sp_pay_invoice(1,'2026-08-20','NEFT','UTR000001',2,0);
CALL sp_pay_invoice(2,'2026-07-18','NEFT','UTR000002',1,1);
CALL sp_pay_invoice(3,'2026-09-19','RTGS','UTR000003',2,0);
CALL sp_pay_invoice(4,'2026-08-15','WIRE','UTR000004',1,0);
CALL sp_pay_invoice(5,'2026-07-19','RTGS','UTR000005',2,1);
CALL sp_pay_invoice(6,'2026-07-26','NEFT','UTR000006',1,1);
CALL sp_pay_invoice(7,'2026-08-26','RTGS','UTR000007',2,0);
CALL sp_pay_invoice(8,'2026-08-22','NEFT','UTR000008',1,0);
CALL sp_pay_invoice(9,'2026-09-02','NEFT','UTR000009',2,0);
CALL sp_pay_invoice(11,'2026-09-03','NEFT','UTR000010',1,0);
CALL sp_pay_invoice(13,'2026-08-31','NEFT','UTR000011',2,0);
CALL sp_pay_invoice(14,'2026-09-12','WIRE','UTR000012',1,0);
CALL sp_pay_invoice(16,'2026-08-24','NEFT','UTR000013',2,1);
CALL sp_pay_invoice(17,'2026-08-29','UPI','UTR000014',1,1);
CALL sp_pay_invoice(18,'2026-09-29','NEFT','UTR000015',2,0);
CALL sp_pay_invoice(20,'2026-09-13','NEFT','UTR000016',1,1);
CALL sp_pay_invoice(21,'2026-10-21','WIRE','UTR000017',2,0);
CALL sp_pay_invoice(22,'2026-10-07','NEFT','UTR000018',1,0);
CALL sp_pay_invoice(23,'2026-09-09','RTGS','UTR000019',2,1);
CALL sp_pay_invoice(24,'2026-10-09','RTGS','UTR000020',1,0);
CALL sp_pay_invoice(25,'2026-09-21','NEFT','UTR000021',2,1);
CALL sp_pay_invoice(27,'2026-10-01','WIRE','UTR000022',1,1);
CALL sp_pay_invoice(29,'2026-11-12','NEFT','UTR000023',2,0);
INSERT INTO payments(invoice_id,payment_date,amount_paid,discount_taken,method,reference_no,paid_by) VALUES (30,'2026-10-06',393117.0,0,'NEFT','UTR000024',1);
CALL sp_pay_invoice(31,'2026-10-05','NEFT','UTR000025',2,1);
CALL sp_pay_invoice(32,'2026-10-12','NEFT','UTR000026',1,1);
CALL sp_pay_invoice(34,'2026-10-10','WIRE','UTR000027',2,1);
CALL sp_pay_invoice(35,'2026-11-13','NEFT','UTR000028',1,0);
CALL sp_pay_invoice(36,'2026-10-15','RTGS','UTR000029',2,1);
CALL sp_pay_invoice(37,'2026-10-15','NEFT','UTR000030',1,1);
CALL sp_pay_invoice(39,'2026-10-18','UPI','UTR000031',2,1);
CALL sp_pay_invoice(44,'2026-11-02','RTGS','UTR000032',1,1);
