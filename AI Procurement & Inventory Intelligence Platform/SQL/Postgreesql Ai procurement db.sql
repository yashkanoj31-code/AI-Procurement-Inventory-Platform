
-- AI Procurement & Inventory Intelligence Platform Project

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    material_code VARCHAR(30) UNIQUE NOT NULL,
    sku VARCHAR(50) UNIQUE,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    brand VARCHAR(100),
    uom VARCHAR(20),
    hsn_code VARCHAR(20),
    gst_percentage NUMERIC(5,2),
    unit_price NUMERIC(12,2),
    reorder_level INTEGER,
    max_stock_level INTEGER,
    expiry_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (
    material_code,
    sku,
    product_name,
    description,
    category,
    brand,
    uom,
    hsn_code,
    gst_percentage,
    unit_price,
    reorder_level,
    max_stock_level
)
VALUES (
    'MAT001',
    'SKU001',
    'HP Laptop',
    'HP ProBook 450 G10',
    'Electronics',
    'HP',
    'Piece',
    '84713010',
    18,
    52000,
    10,
    100
);

SELECT * FROM products;

CREATE TABLE vendors (
    vendor_id SERIAL PRIMARY KEY,
    vendor_code VARCHAR(20) UNIQUE NOT NULL,
    vendor_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    email VARCHAR(255) UNIQUE,
    gst_number VARCHAR(20) UNIQUE NOT NULL,
    pan_number VARCHAR(10) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    lead_time_days INTEGER DEFAULT 7,
    payment_terms VARCHAR(50) DEFAULT '30 Days',
    vendor_rating NUMERIC(3,2) DEFAULT 5.00,
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO vendors (
vendor_code,
vendor_name,
contact_person,
mobile_number,
email,
gst_number,
pan_number,
address,
city,
state,
pincode
)
VALUES
(
'VEN001',
'ABC Traders',
'Rahul Sharma',
'+919876543210',
'abc@gmail.com',
'27ABCDE1234F1Z5',
'ABCDE1234F',
'Andheri East',
'Mumbai',
'Maharashtra',
'400069'
),
(
'VEN002',
'Tech Supplies Pvt Ltd',
'Priya Mehta',
'+919812345678',
'tech@gmail.com',
'29PQRSX5678L1Z3',
'PQRSX5678L',
'Electronic City',
'Bengaluru',
'Karnataka',
'560100'
);

SELECT * FROM vendors;

CREATE TABLE product_vendor (
    product_vendor_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    vendor_id INTEGER NOT NULL,
    vendor_price NUMERIC(12,2) NOT NULL,
    minimum_order_qty INTEGER DEFAULT 1,
    lead_time_days INTEGER,
    contract_start_date DATE,
    contract_end_date DATE,
    preferred_vendor BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id),

    CONSTRAINT fk_vendor
        FOREIGN KEY(vendor_id)
        REFERENCES vendors(vendor_id)
);

INSERT INTO product_vendor (
    product_id,
    vendor_id,
    vendor_price,
    minimum_order_qty,
    lead_time_days,
    contract_start_date,
    contract_end_date,
    preferred_vendor
)
VALUES
(1,1,52000,5,7,'2026-01-01','2027-01-01',TRUE),
(1,2,51500,10,10,'2026-01-01','2027-01-01',FALSE);

SELECT * FROM product_vendor;

select p.product_name, v.vendor_name, pv.vendor_price from products p
left join product_vendor pv  on pv.product_id = p.product_id
left join vendors v  on pv.vendor_id = v.vendor_id;

CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_code VARCHAR(20) UNIQUE NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    manager_name VARCHAR(100),
    contact_number VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO warehouses
(
warehouse_code,
warehouse_name,
city,
state,
manager_name,
contact_number
)

VALUES

(
'WH001',
'Mumbai Central Warehouse',
'Mumbai',
'Maharashtra',
'Rakesh Sharma',
'+919999111111'
),

(
'WH002',
'Bengaluru Warehouse',
'Bengaluru',
'Karnataka',
'Anita Rao',
'+919888222222'
);

SELECT * FROM warehouses;

CREATE TABLE inventory (

inventory_id SERIAL PRIMARY KEY,

product_id INTEGER NOT NULL,

warehouse_id INTEGER NOT NULL,

current_stock INTEGER NOT NULL,

reserved_stock INTEGER DEFAULT 0,

available_stock INTEGER,

reorder_level INTEGER,

maximum_stock INTEGER,

last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT fk_inventory_product
FOREIGN KEY(product_id)
REFERENCES products(product_id),

CONSTRAINT fk_inventory_warehouse
FOREIGN KEY(warehouse_id)
REFERENCES warehouses(warehouse_id)

);

INSERT INTO inventory
(
product_id,
warehouse_id,
current_stock,
reserved_stock,
available_stock,
reorder_level,
maximum_stock
)

VALUES

(
1,
1,
120,
20,
100,
25,
200
),

(
1,
2,
80,
10,
70,
20,
150
);

select p.product_name, w.warehouse_name, i.current_stock, i.available_stock from products p
left join inventory i  on i.product_id = p.product_id
left join warehouses w  on w.warehouse_id = i.warehouse_id;

CREATE TABLE purchase_orders (

    po_id SERIAL PRIMARY KEY,

    po_number VARCHAR(20) UNIQUE NOT NULL,

    vendor_id INTEGER NOT NULL,

    order_date DATE NOT NULL,

    expected_delivery DATE,

    total_amount NUMERIC(15,2),

    status VARCHAR(20) DEFAULT 'Pending',

    created_by VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_po_vendor
    FOREIGN KEY(vendor_id)
    REFERENCES vendors(vendor_id)

);

INSERT INTO purchase_orders
(
po_number,
vendor_id,
order_date,
expected_delivery,
total_amount,
created_by
)

VALUES

(
'PO2026001',
1,
'2026-08-15',
'2026-08-22',
260000,
'Yash'
),

(
'PO2026002',
2,
'2026-08-16',
'2026-08-25',
515000,
'Yash'
);

SELECT * FROM purchase_orders;

CREATE TABLE purchase_order_items (

    po_item_id SERIAL PRIMARY KEY,

    po_id INTEGER NOT NULL,

    product_id INTEGER NOT NULL,

    quantity INTEGER NOT NULL,

    unit_price NUMERIC(12,2) NOT NULL,

    total_price NUMERIC(15,2),

    CONSTRAINT fk_po
        FOREIGN KEY(po_id)
        REFERENCES purchase_orders(po_id),

    CONSTRAINT fk_product_po
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)

);

INSERT INTO purchase_order_items
(
po_id,
product_id,
quantity,
unit_price,
total_price
)

VALUES

(
1,
1,
5,
52000,
260000
),

(
2,
1,
10,
51500,
515000
);

SELECT

po.po_number,

v.vendor_name,

p.product_name,

poi.quantity,

poi.unit_price,

poi.total_price,

po.status

FROM purchase_orders po

INNER JOIN vendors v
ON po.vendor_id = v.vendor_id

INNER JOIN purchase_order_items poi
ON po.po_id = poi.po_id

INNER JOIN products p
ON poi.product_id = p.product_id;

CREATE TABLE purchase_requisitions (

    pr_id SERIAL PRIMARY KEY,

    pr_number VARCHAR(20) UNIQUE NOT NULL,

    requested_by VARCHAR(100) NOT NULL,

    department VARCHAR(100),

    request_date DATE DEFAULT CURRENT_DATE,

    status VARCHAR(20) DEFAULT 'Pending',

    remarks TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

INSERT INTO purchase_requisitions
(
pr_number,
requested_by,
department,
remarks
)

VALUES

(
'PR2026001',
'Yash',
'IT',
'Need laptops for new employees'
),

(
'PR2026002',
'Rohit',
'Accounts',
'Printer cartridges required'
);

CREATE TABLE purchase_requisition_items (

    pr_item_id SERIAL PRIMARY KEY,

    pr_id INTEGER NOT NULL,

    product_id INTEGER NOT NULL,

    quantity INTEGER NOT NULL,

    estimated_price NUMERIC(12,2),

    CONSTRAINT fk_pr
        FOREIGN KEY(pr_id)
        REFERENCES purchase_requisitions(pr_id),

    CONSTRAINT fk_pr_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)

);

INSERT INTO purchase_requisition_items
(
pr_id,
product_id,
quantity,
estimated_price
)

VALUES

(
1,
1,
5,
52000
);

CREATE TABLE goods_receipts (

    grn_id SERIAL PRIMARY KEY,

    grn_number VARCHAR(20) UNIQUE NOT NULL,

    po_id INTEGER NOT NULL,

    receipt_date DATE DEFAULT CURRENT_DATE,

    received_by VARCHAR(100),

    warehouse_id INTEGER NOT NULL,

    status VARCHAR(20) DEFAULT 'Received',

    remarks TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_grn_po
        FOREIGN KEY(po_id)
        REFERENCES purchase_orders(po_id),

    CONSTRAINT fk_grn_warehouse
        FOREIGN KEY(warehouse_id)
        REFERENCES warehouses(warehouse_id)

);

CREATE TABLE goods_receipt_items (

    grn_item_id SERIAL PRIMARY KEY,

    grn_id INTEGER NOT NULL,

    product_id INTEGER NOT NULL,

    ordered_quantity INTEGER NOT NULL,

    received_quantity INTEGER NOT NULL,

    rejected_quantity INTEGER DEFAULT 0,

    accepted_quantity INTEGER,

    remarks TEXT,

    CONSTRAINT fk_grn_item_grn
        FOREIGN KEY(grn_id)
        REFERENCES goods_receipts(grn_id),

    CONSTRAINT fk_grn_item_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)

);

INSERT INTO goods_receipts
(
    grn_number,
    po_id,
    receipt_date,
    received_by,
    warehouse_id,
    status,
    remarks
)
VALUES
(
    'GRN2026001',
    1,
    '2026-08-15',
    'Yash',
    1,
    'Received',
    'One laptop damaged during inspection'
);

INSERT INTO goods_receipt_items
(
    grn_id,
    product_id,
    ordered_quantity,
    received_quantity,
    rejected_quantity,
    accepted_quantity,
    remarks
)
VALUES
(
    1,
    1,
    5,
    5,
    1,
    4,
    'One unit rejected due to physical damage'
);

SELECT * FROM goods_receipts;

SELECT * FROM goods_receipt_items;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.available_stock
FROM inventory i
INNER JOIN products p
    ON i.product_id = p.product_id
INNER JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

CREATE OR REPLACE FUNCTION update_inventory_after_grn()
RETURNS TRIGGER
AS $$
DECLARE
    warehouse_id_value INTEGER;
BEGIN

    -- Find the warehouse associated with this GRN
    SELECT warehouse_id
    INTO warehouse_id_value
    FROM goods_receipts
    WHERE grn_id = NEW.grn_id;

    -- Increase current stock
    UPDATE inventory
    SET
        current_stock = current_stock + NEW.accepted_quantity,
        available_stock = available_stock + NEW.accepted_quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id
      AND warehouse_id = warehouse_id_value;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_inventory_after_grn()
RETURNS TRIGGER
AS $$
DECLARE
    warehouse_id_value INTEGER;
BEGIN

    -- Find the warehouse associated with this GRN
    SELECT warehouse_id
    INTO warehouse_id_value
    FROM goods_receipts
    WHERE grn_id = NEW.grn_id;

    -- Increase current stock
    UPDATE inventory
    SET
        current_stock = current_stock + NEW.accepted_quantity,
        available_stock = available_stock + NEW.accepted_quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id
      AND warehouse_id = warehouse_id_value;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_inventory_after_grn
AFTER INSERT
ON goods_receipt_items
FOR EACH ROW
EXECUTE FUNCTION update_inventory_after_grn();

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE trigger_name = 'trg_update_inventory_after_grn';

SELECT *
FROM goods_receipts
ORDER BY grn_id;

SELECT *
FROM goods_receipt_items
ORDER BY grn_item_id;

SELECT *
FROM purchase_order_items
ORDER BY po_item_id;

SELECT *
FROM purchase_orders
ORDER BY po_id;

BEGIN;

-- Create a temporary test GRN
INSERT INTO goods_receipts
(
    grn_number,
    po_id,
    receipt_date,
    received_by,
    warehouse_id,
    status,
    remarks
)
VALUES
(
    'TEST-GRN-001',
    1,
    CURRENT_DATE,
    'Yash',
    1,
    'Received',
    'Trigger testing - rollback after verification'
)
RETURNING grn_id;

INSERT INTO goods_receipt_items
(
    grn_id,
    product_id,
    ordered_quantity,
    received_quantity,
    rejected_quantity,
    accepted_quantity,
    remarks
)
VALUES
(
    2,
    1,
    40,
    40,
    0,
    40,
    'Trigger testing'
)
RETURNING *;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE i.product_id = 1
  AND i.warehouse_id = 1;

Rollback;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE i.product_id = 1
  AND i.warehouse_id = 1;

CREATE TABLE inventory_transactions (
    transaction_id SERIAL PRIMARY KEY,

    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,

    transaction_type VARCHAR(50) NOT NULL,

    quantity INT NOT NULL,

    reference_type VARCHAR(50),

    reference_id INT,

    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    remarks TEXT,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
);

INSERT INTO inventory_transactions
(
    product_id,
    warehouse_id,
    transaction_type,
    quantity,
    reference_type,
    reference_id,
    remarks
)
VALUES
(
    1,
    1,
    'GRN',
    80,
    'GRN',
    1,
    'Stock received through GRN'
);

SELECT *
FROM inventory_transactions;

CREATE OR REPLACE FUNCTION record_inventory_transaction()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    -- Record only accepted quantity
    IF NEW.accepted_quantity > 0 THEN

        INSERT INTO inventory_transactions
        (
            product_id,
            warehouse_id,
            transaction_type,
            quantity,
            reference_type,
            reference_id,
            remarks
        )
        SELECT
            NEW.product_id,
            grn.warehouse_id,
            'GRN',
            NEW.accepted_quantity,
            'GRN',
            NEW.grn_id,
            'Stock received through GRN'
        FROM goods_receipts grn
        WHERE grn.grn_id = NEW.grn_id;

    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_record_inventory_transaction
AFTER INSERT
ON goods_receipt_items
FOR EACH ROW
EXECUTE FUNCTION record_inventory_transaction();

SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE trigger_name = 'trg_record_inventory_transaction';

SELECT *
FROM goods_receipts
ORDER BY grn_id;

SELECT *
FROM goods_receipt_items
ORDER BY grn_item_id;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE i.product_id = 1
  AND i.warehouse_id = 1;

INSERT INTO goods_receipts
(
    grn_number,
    po_id,
    receipt_date,
    received_by,
    warehouse_id,
    status,
    remarks
)
VALUES
(
    'GRN2026002',
    1,
    CURRENT_DATE,
    'Yash',
    1,
    'Received',
    'Second GRN - automatic transaction testing'
)
RETURNING grn_id;

INSERT INTO goods_receipt_items
(
    grn_id,
    product_id,
    ordered_quantity,
    received_quantity,
    rejected_quantity,
    accepted_quantity,
    remarks
)
VALUES
(
    2,
    1,
    10,
    10,
    0,
    10,
    'All 10 units accepted'
)
RETURNING *;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE i.product_id = 1
  AND i.warehouse_id = 1;

SELECT
    transaction_id,
    product_id,
    warehouse_id,
    transaction_type,
    quantity,
    reference_type,
    reference_id,
    transaction_date,
    remarks
FROM inventory_transactions
ORDER BY transaction_id;

CREATE OR REPLACE FUNCTION log_grn_inventory_transaction()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO inventory_transactions (
        product_id,
        warehouse_id,
        transaction_type,
        quantity,
        reference_type,
        reference_id,
        remarks
    )
    SELECT
        NEW.product_id,
        gr.warehouse_id,
        'GRN',
        NEW.accepted_quantity,
        'GRN',
        NEW.grn_id,
        'Stock received through GRN'
    FROM goods_receipts gr
    WHERE gr.grn_id = NEW.grn_id;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_log_grn_inventory_transaction
AFTER INSERT ON goods_receipt_items
FOR EACH ROW
EXECUTE FUNCTION log_grn_inventory_transaction();

CREATE OR REPLACE FUNCTION log_inventory_transaction()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO inventory_transactions (
        product_id,
        warehouse_id,
        transaction_type,
        quantity,
        reference_type,
        reference_id,
        remarks
    )
    VALUES (
        NEW.product_id,
        (
            SELECT warehouse_id
            FROM goods_receipts
            WHERE grn_id = NEW.grn_id
        ),
        'GRN',
        NEW.accepted_quantity,
        'GRN',
        NEW.grn_id,
        'Stock received through GRN'
    );

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_log_inventory_transaction
AFTER INSERT ON goods_receipt_items
FOR EACH ROW
EXECUTE FUNCTION log_inventory_transaction();

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

SELECT
    p.product_name,
    w.warehouse_name,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE i.available_stock < 50;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

ALTER TABLE inventory
ADD COLUMN reorder_level INT NOT NULL DEFAULT 0;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock,
    i.reorder_level
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

SELECT
    p.product_name,
    w.warehouse_name,
    i.available_stock,
    i.reorder_level,
    p.max_stock_level
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock,
    i.reorder_level
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
WHERE i.available_stock <= i.reorder_level;

SELECT
    p.product_name,
    w.warehouse_name,
    i.available_stock,
    i.reorder_level,
    (i.reorder_level - i.available_stock) AS recommended_order_qty
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

SELECT *
FROM product_vendor;

SELECT *
FROM vendors;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'product_vendors'
ORDER BY ordinal_position;

ALTER TABLE product_vendor
ADD COLUMN unit_price NUMERIC(12,2);

ALTER TABLE product_vendor
ADD COLUMN minimum_order_quantity INT;

ALTER TABLE product_vendor
ADD COLUMN lead_time_days INT;

ALTER TABLE product_vendor
ADD COLUMN vendor_rating NUMERIC(3,2);

SELECT * FROM product_vendor;

SELECT
    pv.product_id,
    p.product_name,
    pv.vendor_id,
    pv.unit_price,
    pv.minimum_order_quantity,
    pv.lead_time_days,
    pv.vendor_rating
FROM product_vendor pv
JOIN products p
    ON pv.product_id = p.product_id
ORDER BY pv.product_id, pv.vendor_id;

SELECT
    pv.product_id,
    p.product_name,
    pv.vendor_id,
    pv.unit_price,
    pv.minimum_order_quantity,
    pv.lead_time_days,
    pv.vendor_rating
FROM product_vendor pv
JOIN products p
    ON pv.product_id = p.product_id
ORDER BY pv.product_id, pv.vendor_id;

SELECT
    p.product_name,
    pv.vendor_id,
    pv.unit_price,
    pv.minimum_order_quantity,
    pv.lead_time_days,
    pv.vendor_rating,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.unit_price ASC
    ) AS price_rank,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.lead_time_days ASC
    ) AS lead_time_rank,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.minimum_order_quantity ASC
    ) AS moq_rank,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.vendor_rating DESC
    ) AS rating_rank

FROM product_vendor pv

JOIN products p
    ON pv.product_id = p.product_id;

UPDATE product_vendor
SET
    unit_price = 52000,
    minimum_order_quantity = 5,
    vendor_rating = 4.5
WHERE product_id = 1
  AND vendor_id = 1;


UPDATE product_vendor
SET
    unit_price = 51500,
    minimum_order_quantity = 10,
    vendor_rating = 4.2
WHERE product_id = 1
  AND vendor_id = 2;

SELECT
    product_id,
    vendor_id,
    unit_price,
    minimum_order_quantity,
    lead_time_days,
    vendor_rating
FROM product_vendor
ORDER BY product_id, vendor_id;

SELECT
    p.product_name,
    pv.vendor_id,
    pv.unit_price,
    pv.minimum_order_quantity,
    pv.lead_time_days,
    pv.vendor_rating,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.unit_price ASC
    ) AS price_rank,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.lead_time_days ASC
    ) AS lead_time_rank,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.minimum_order_quantity ASC
    ) AS moq_rank,

    RANK() OVER (
        PARTITION BY pv.product_id
        ORDER BY pv.vendor_rating DESC
    ) AS rating_rank

FROM product_vendor pv
JOIN products p
    ON pv.product_id = p.product_id;

SELECT
    p.product_name,
    pv.vendor_id,
    pv.unit_price,

    MAX(pv.unit_price) OVER (
        PARTITION BY pv.product_id
    ) AS max_price,

    MIN(pv.unit_price) OVER (
        PARTITION BY pv.product_id
    ) AS min_price,

    ROUND(
        (
            MAX(pv.unit_price) OVER (
                PARTITION BY pv.product_id
            ) - pv.unit_price
        )
        /
        NULLIF(
            MAX(pv.unit_price) OVER (
                PARTITION BY pv.product_id
            )
            -
            MIN(pv.unit_price) OVER (
                PARTITION BY pv.product_id
            ),
            0
        ),
        2
    ) AS price_score

FROM product_vendor pv
JOIN products p
    ON pv.product_id = p.product_id;

SELECT
    p.product_name,
    w.warehouse_name,
    i.available_stock,
    i.reorder_level,

    CASE
        WHEN i.available_stock <= i.reorder_level
            THEN 'Procurement Required'

        WHEN i.available_stock <= i.reorder_level * 1.5
            THEN 'Reorder Soon'

        ELSE 'Healthy'
    END AS stock_status

FROM inventory i

JOIN products p
    ON i.product_id = p.product_id

JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id;

SELECT
    w.warehouse_name,
    SUM(i.current_stock) AS total_current_stock,
    SUM(i.reserved_stock) AS total_reserved_stock,
    SUM(i.available_stock) AS total_available_stock
FROM inventory i
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name;

SELECT
    w.warehouse_name,
    COUNT(DISTINCT i.product_id) AS total_products,
    SUM(i.current_stock) AS total_current_stock,
    SUM(i.reserved_stock) AS total_reserved_stock,
    SUM(i.available_stock) AS total_available_stock
FROM inventory i
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name
ORDER BY total_available_stock DESC;

-- CTE (Common Table Expression)

SELECT
    w.warehouse_name,
    SUM(i.current_stock) AS total_current_stock,
    SUM(i.reserved_stock) AS total_reserved_stock,
    SUM(i.available_stock) AS total_available_stock
FROM inventory i
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name
HAVING SUM(i.available_stock) > 100
ORDER BY total_available_stock DESC;

WITH warehouse_summary AS (
    SELECT
        w.warehouse_name,
        SUM(i.available_stock) AS total_available_stock
    FROM inventory i
    JOIN warehouses w
        ON i.warehouse_id = w.warehouse_id
    GROUP BY w.warehouse_name
)

-- Subquery

SELECT *
FROM warehouse_summary
WHERE total_available_stock > 100;

SELECT
    p.product_name,
    i.available_stock
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
WHERE i.available_stock < (
    SELECT AVG(available_stock)
    FROM inventory
);

-- Which products require procurement?

SELECT
    p.product_id,
    p.product_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock,
    i.reorder_level
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
WHERE i.available_stock <= i.reorder_level
ORDER BY i.available_stock ASC;

-- Give me the complete current inventory position of every product.

SELECT
    p.product_id,
    p.product_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock,
    i.reorder_level,

	CASE
		WHEN i.available_stock <= i.reorder_level
			THEN 'Procurement Required'
		WHEN i.available_stock <= i.reorder_level * 1.5
			THEN 'Reorder Soon'
		ELSE 'Healthy'
	END AS stock_status

FROM inventory i

JOIN products p ON i.product_id = p.product_id

ORDER BY i.available_stock ASC;

-- How much quantity did we order, how much have we received, and how much is still pending?

WITH received_quantity AS (
    SELECT
        poi.po_item_id,
        SUM(gri.accepted_quantity) AS total_received
    FROM purchase_order_items poi
    LEFT JOIN goods_receipt_items gri
  ON poi.po_item_id = gri.purchase_order_item_id

    GROUP BY poi.po_item_id
)
WITH received_quantity AS (
    SELECT
        poi.po_item_id,
        COALESCE(SUM(gri.accepted_quantity), 0) AS total_received
    FROM purchase_order_items poi
    LEFT JOIN goods_receipt_items gri
        ON poi.po_item_id = gri.po_item_id
    GROUP BY poi.po_item_id
)

SELECT
    poi.po_item_id,
    poi.po_id,
    poi.product_id,
    SUM(gri.accepted_quantity) AS total_received
FROM purchase_order_items poi

JOIN goods_receipts gr
    ON poi.po_id = gr.po_id

JOIN goods_receipt_items gri
    ON gr.grn_id = gri.grn_id
    AND poi.product_id = gri.product_id

GROUP BY
    poi.po_item_id,
    poi.po_id,
    poi.product_id;

SELECT
    po.po_id,
    poi.po_item_id,
    p.product_name,
    poi.quantity AS ordered_quantity
FROM purchase_orders po
JOIN purchase_order_items poi
    ON po.po_id = poi.po_id
JOIN products p
    ON poi.product_id = p.product_id
ORDER BY po.po_id, poi.po_item_id;

WITH received AS (
    SELECT
        gr.po_id,
        gri.product_id,
        SUM(gri.accepted_quantity) AS total_accepted
    FROM goods_receipts gr
    JOIN goods_receipt_items gri
        ON gr.grn_id = gri.grn_id
    GROUP BY
        gr.po_id,
        gri.product_id
)

SELECT
    poi.po_id,
    poi.po_item_id,
    p.product_name,

    poi.quantity AS ordered_quantity,

    COALESCE(r.total_accepted, 0) AS accepted_quantity,

    poi.quantity
        - COALESCE(r.total_accepted, 0) AS pending_quantity

FROM purchase_order_items poi

JOIN products p
    ON poi.product_id = p.product_id

LEFT JOIN received r
    ON poi.po_id = r.po_id
    AND poi.product_id = r.product_id

ORDER BY
    poi.po_id,
    poi.po_item_id;

SELECT
    gr.grn_id,
    gr.grn_number,
    gr.po_id,
    gri.grn_item_id,
    gri.product_id,
    gri.ordered_quantity,
    gri.received_quantity,
    gri.rejected_quantity,
    gri.accepted_quantity
FROM goods_receipts gr
JOIN goods_receipt_items gri
    ON gr.grn_id = gri.grn_id
WHERE gr.po_id = 1
  AND gri.product_id = 1
ORDER BY gr.grn_id;

SELECT
    po.po_id,
    poi.po_item_id,
    p.product_name,
    poi.quantity AS po_quantity,
    gr.grn_id,
    gr.grn_number,
    gri.ordered_quantity AS grn_ordered,
    gri.received_quantity,
    gri.rejected_quantity,
    gri.accepted_quantity
FROM purchase_orders po
JOIN purchase_order_items poi
    ON po.po_id = poi.po_id
JOIN products p
    ON poi.product_id = p.product_id
LEFT JOIN goods_receipts gr
    ON po.po_id = gr.po_id
LEFT JOIN goods_receipt_items gri
    ON gr.grn_id = gri.grn_id
    AND poi.product_id = gri.product_id
ORDER BY
    po.po_id,
    gr.grn_id;

SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    i.reserved_stock,
    i.available_stock,
    i.reorder_level,
    
    i.reorder_level - i.available_stock AS shortage_quantity

FROM inventory i

JOIN products p
    ON i.product_id = p.product_id

JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id

WHERE i.available_stock < i.reorder_level;

SELECT
    v.vendor_id,
    v.vendor_name,
    COUNT(DISTINCT po.po_id) AS total_orders,
    SUM(poi.quantity) AS total_ordered_quantity,
    COALESCE(SUM(gri.accepted_quantity), 0) AS total_accepted_quantity
FROM vendors v

JOIN purchase_orders po
    ON v.vendor_id = po.vendor_id

JOIN purchase_order_items poi
    ON po.po_id = poi.po_id

LEFT JOIN goods_receipts gr
    ON po.po_id = gr.po_id

LEFT JOIN goods_receipt_items gri
    ON gr.grn_id = gri.grn_id
    AND poi.product_id = gri.product_id

GROUP BY
    v.vendor_id,
    v.vendor_name

ORDER BY
    total_accepted_quantity DESC;

SELECT
    v.vendor_id,
    v.vendor_name,
    p.product_name,
    SUM(poi.quantity) AS total_quantity,
    pv.unit_price,
    SUM(poi.quantity * pv.unit_price) AS total_spend
FROM purchase_orders po
JOIN vendors v
    ON po.vendor_id = v.vendor_id
JOIN purchase_order_items poi
    ON po.po_id = poi.po_id
JOIN products p
    ON poi.product_id = p.product_id
JOIN product_vendor pv
    ON poi.product_id = pv.product_id
    AND po.vendor_id = pv.vendor_id
GROUP BY
    v.vendor_id,
    v.vendor_name,
    p.product_name,
    pv.unit_price
ORDER BY
    total_spend DESC;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('purchase_orders', 'vendors', 'product_vendor')
ORDER BY table_name, ordinal_position;



