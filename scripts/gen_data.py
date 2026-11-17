# Regenerates sql/02_sample_data.sql (fixed random seed -> identical output every run).
# Run from the repository root:  python3 scripts/gen_data.py
import random, datetime as dt
random.seed(30)
TODAY = dt.date(2026,11,14)
out = []
w = out.append
w("-- =====================================================================")
w("--  File 2 of 3 : Sample data (reproducible, generated for the project)")
w("--  Load AFTER 01_schema.sql on a FRESH database (IDs are assumed sequential)")
w("-- =====================================================================")
w("USE ap_system;\n")

w("INSERT INTO departments(dept_name,cost_centre) VALUES")
w("('Information Technology','CC-IT01'),('Operations','CC-OP02'),('Marketing','CC-MK03'),('Facilities','CC-FC04'),('Human Resources','CC-HR05');\n")
depts = {1:'IT',2:'OPS',3:'MKT',4:'FAC',5:'HR'}

w("INSERT INTO users(full_name,email,role,dept_id) VALUES")
w("('Ritu Sharma','ritu.sharma@acmecorp.in','AP_CLERK',NULL),")
w("('Arjun Mehta','arjun.mehta@acmecorp.in','AP_CLERK',NULL),")
w("('Neha Kapoor','neha.kapoor@acmecorp.in','DEPT_MANAGER',1),")
w("('Sanjay Rao','sanjay.rao@acmecorp.in','DEPT_MANAGER',2),")
w("('Meera Iyer','meera.iyer@acmecorp.in','FINANCE_HEAD',NULL),")
w("('System Admin','admin@acmecorp.in','ADMIN',NULL);\n")
dept_mgr = {1:3,2:4,3:3,4:4,5:4}

w("INSERT INTO payment_terms(term_code,discount_pct,discount_days,net_days) VALUES")
terms = [("2/10 Net 30",2.0,10,30),("1/10 Net 45",1.0,10,45),("Net 30",0,0,30),
         ("Net 45",0,0,45),("Net 60",0,0,60),("1.5/15 Net 45",1.5,15,45)]
w(",\n".join(f"('{c}',{p},{d},{n})" for c,p,d,n in terms)+";\n")
T = {i+1:t for i,t in enumerate(terms)}

vendors = [
 ("V001","Apex Office Supplies Pvt Ltd","Stationery & Supplies",1,"Pune"),
 ("V002","BlueWave IT Solutions","IT Services",2,"Bengaluru"),
 ("V003","Cargo Link Logistics","Logistics",3,"Mumbai"),
 ("V004","Delta Packaging Industries","Packaging",1,"Ahmedabad"),
 ("V005","EverGreen Facility Services","Facilities",4,"Delhi"),
 ("V006","FlexiPrint Media","Printing & Marketing",6,"Chennai"),
 ("V007","GlobalTech Hardware Traders","IT Hardware",1,"Hyderabad"),
 ("V008","Horizon Cloud Hosting","Cloud Services",5,"Bengaluru"),
 ("V009","Indus Raw Materials Co","Raw Materials",2,"Surat"),
 ("V010","Jupiter Consulting LLP","Consulting",3,"Gurugram"),
 ("V011","Kestrel Traders","General Trading",3,"Kolkata"),
]
w("INSERT INTO vendors(vendor_code,vendor_name,tax_id,contact_email,phone,city,bank_account,bank_ifsc,term_id,category,status) VALUES")
# simple formatting fix for phone/ifsc
rows=[]
for i,(c,n,cat,t,city) in enumerate(vendors,1):
    gst=f"27AAC{chr(65+i)}{1000+i*37:04d}A1Z{i%9+1}"
    mail=n.split()[0].lower()
    phone=f"98{(10000000+i*1111111)%100000000:08d}"
    ifsc=f"HDFC0{1000+i:06d}"[:11]
    st='BLOCKED' if c=='V011' else 'ACTIVE'
    rows.append(f"('{c}','{n}','{gst}','accounts@{mail}.example','{phone}','{city}','{50100000000+i*7919}','{ifsc}',{t},'{cat}','{st}')")
w(",\n".join(rows)+";\n")
V = {i+1:v for i,v in enumerate(vendors)}
desc = {"Stationery & Supplies":["Office stationery bulk pack","Printer consumables"],
 "IT Services":["Managed service retainer","Application support hours"],
 "Logistics":["Freight - inbound lots","Last-mile delivery batch"],
 "Packaging":["Corrugated boxes","Packaging film rolls"],
 "Facilities":["Housekeeping contract","Facility maintenance"],
 "Printing & Marketing":["Brochure printing","Event branding material"],
 "IT Hardware":["Laptops","Network switches"],
 "Cloud Services":["Cloud hosting - monthly","Backup storage"],
 "Raw Materials":["Polymer granules","Steel sheet lots"],
 "Consulting":["Process audit engagement","Advisory retainer"]}
dept_of = {1:[1,2],2:[2],3:[2],4:[2,4],5:[4,5],6:[3],7:[1],8:[1],9:[2],10:[5,3]}

N=48
inv=[]
for k in range(N):
    vid = random.choice([1,2,3,4,5,6,7,8,9,10,1,4,7,9,2,6])
    d = dt.date(2026,7,6)+dt.timedelta(days=random.randint(0,116))
    sub = random.randint(400,9000)*100
    inv.append(dict(vid=vid,date=d,sub=sub))
inv.sort(key=lambda x:(x['date'],x['vid']))
# special-case flags
variance_idx = {9, 27, 40}
reject_idx   = {14}
nopo_idx     = {5, 21, 33}   # utilities / rent style, no PO
overdue_unpaid = {11, 18, 25, 36}
partial_idx  = {29}

po_rows=[]; item_rows=[]; grn_rows=[]; inv_rows=[]; calls=[]; pay_calls=[]
po_id=0; pay_serial=0; partial_done=False
for idx,x in enumerate(inv):
    inv_id=idx+1
    v=V[x['vid']]; t=T[v[3]]
    has_po = idx not in nopo_idx
    po=None
    if has_po:
        po_id+=1; po=po_id
        pdate = x['date']-dt.timedelta(days=random.randint(10,25))
        dep = random.choice(dept_of[x['vid']])
        po_rows.append(f"('PO-2026-{po:04d}',{x['vid']},{dep},{[1,2][po%2]+0},'{pdate}',{x['sub']}.00,'CLOSED')")
        n1=random.randint(2,20); u1=round(x['sub']*0.6/n1,2)
        line1=round(n1*u1,2); rest=round(x['sub']-line1,2)
        d0=desc[v[2]]
        item_rows.append(f"({po},'{d0[0]}',{n1},{u1})")
        item_rows.append(f"({po},'{d0[1]}',1,{rest})")
        recv = x['sub'] if idx not in variance_idx else round(x['sub']*0.90,2)
        gdate = x['date']-dt.timedelta(days=random.randint(1,4))
        grn_rows.append(f"({po},'{gdate}',{recv},{dept_mgr[dep]})")
        mgr=dept_mgr[dep]
    else:
        mgr=4
    tax=round(x['sub']*0.18,2)
    recv_d = x['date']+dt.timedelta(days=random.randint(0,2))
    inv_rows.append(f"('{v[0]}-{2600+idx:04d}',{x['vid']},{po if po else 'NULL'},{v[3]},'{x['date']}','{recv_d}',{x['sub']}.00,{tax},{[1,2][idx%2]})")
    calls.append(f"CALL sp_three_way_match({inv_id});")
    if idx in variance_idx: continue            # disputed - stays on hold
    if idx in reject_idx:
        calls.append(f"CALL sp_approve_invoice({inv_id},{mgr},1,'REJECTED','Duplicate of earlier billing - returned to vendor');")
        continue
    calls.append(f"CALL sp_approve_invoice({inv_id},{mgr},1,'APPROVED','Goods/services accepted');")
    calls.append(f"CALL sp_approve_invoice({inv_id},5,2,'APPROVED','Cleared for payment');")
    # payment behaviour
    disc = t[1]>0
    due = x['date']+dt.timedelta(days=t[3])
    if idx in overdue_unpaid and due < TODAY:
        continue
    if disc and random.random()<0.58:
        pdate = x['date']+dt.timedelta(days=random.randint(4,t[2]))
        take=1
    else:
        off = random.choice([-6,-4,-2,0,0,2,5,9,12]) if not disc else random.choice([0,2,5,10])
        pdate = max(recv_d, due+dt.timedelta(days=off)); take=0
        if disc: pdate = max(pdate, x['date']+dt.timedelta(days=t[2]+1))
    if pdate>TODAY: continue                    # not yet due -> still outstanding
    pay_serial+=1
    meth = random.choice(['NEFT','NEFT','RTGS','UPI','WIRE'])
    if idx>=29 and not partial_done:
        partial_done=True
        pdate1=pdate; half=round((x['sub']+tax)*0.5,2)
        pay_calls.append(f"INSERT INTO payments(invoice_id,payment_date,amount_paid,discount_taken,method,reference_no,paid_by) VALUES ({inv_id},'{pdate1}',{half},0,'NEFT','UTR{pay_serial:06d}',1);")
        continue
    pay_calls.append(f"CALL sp_pay_invoice({inv_id},'{pdate}','{meth}','UTR{pay_serial:06d}',{[1,2][pay_serial%2]},{take});")

w("INSERT INTO purchase_orders(po_number,vendor_id,dept_id,created_by,po_date,po_value,status) VALUES")
w(",\n".join(po_rows)+";\n")
w("INSERT INTO po_items(po_id,description,quantity,unit_price) VALUES")
w(",\n".join(item_rows)+";\n")
w("INSERT INTO goods_receipts(po_id,received_date,received_value,received_by) VALUES")
w(",\n".join(grn_rows)+";\n")
w("-- Invoices: due_date, discount_deadline and discount_available are filled by trigger trg_invoice_before_insert")
w("INSERT INTO invoices(invoice_number,vendor_id,po_id,term_id,invoice_date,received_date,subtotal,tax_amount,entered_by) VALUES")
w(",\n".join(inv_rows)+";\n")
w("-- Workflow: 3-way match -> two-level approval")
w("\n".join(calls)+"\n")
w("-- Payments (discount captured only when paid inside the discount window)")
w("\n".join(pay_calls)+"\n")
open('sql/02_sample_data.sql','w').write("\n".join(out))
print(len(inv),"invoices;",po_id,"POs;",len(pay_calls),"payments")
