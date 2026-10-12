-- RECYCLE MANAGEMENT SYSTEM
-- DBMS Project
-- Team 15

-- 1. CREATE DATABASE

CREATE DATABASE IF NOT EXISTS recycling_management;
USE recycling_management;


-- 2. CREATE TABLES
-- Users table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL
);

-- Collector table
CREATE TABLE Collector (
    collector_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    assigned_area VARCHAR(100) NOT NULL,
    contact_info VARCHAR(100) NOT NULL UNIQUE
);

-- Recycling Center table
CREATE TABLE Recycling_Center (
    center_id INT PRIMARY KEY AUTO_INCREMENT,
    location VARCHAR(150) NOT NULL UNIQUE,
    capacity DECIMAL(10,2) NOT NULL CHECK (capacity >= 0),
    contact_info VARCHAR(100) NOT NULL
);

-- Collection Request table
CREATE TABLE Collection_Request (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    collector_id INT,
    waste_type VARCHAR(50) NOT NULL,
    requested_date DATE NOT NULL,
    status ENUM('Pending','Assigned','Collected','Completed','Cancelled')
           DEFAULT 'Pending',

    FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (collector_id)
        REFERENCES Collector(collector_id)
        ON DELETE SET NULL
);

-- Waste table
CREATE TABLE Waste (
    waste_id INT PRIMARY KEY AUTO_INCREMENT,
    request_id INT NOT NULL,
    center_id INT,
    waste_type VARCHAR(50) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity >= 0),
    category ENUM('Recyclable','Reusable','Hazardous','Organic') NOT NULL,

    FOREIGN KEY (request_id)
        REFERENCES Collection_Request(request_id)
        ON DELETE CASCADE,

    FOREIGN KEY (center_id)
        REFERENCES Recycling_Center(center_id)
        ON DELETE SET NULL
);

-- Transactions table
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    waste_id INT NOT NULL,
    collector_id INT NOT NULL,
    center_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    quantity_processed DECIMAL(10,2) NOT NULL
    CHECK (quantity_processed >= 0),
    
    FOREIGN KEY (waste_id)
        REFERENCES Waste(waste_id),
    FOREIGN KEY (collector_id)
        REFERENCES Collector(collector_id),
    FOREIGN KEY (center_id)
        REFERENCES Recycling_Center(center_id)
);
-- 3. CREATE INDEXES

CREATE INDEX idx_request_status ON Collection_Request(status);
CREATE INDEX idx_request_date ON Collection_Request(requested_date);
CREATE INDEX idx_waste_type ON Waste(waste_type);
CREATE INDEX idx_transaction_date ON Transactions(transaction_date);

-- 4. TRIGGER
-- This trigger checks whether the processed quantity
-- is greater than the available waste quantity.

DELIMITER $$

CREATE TRIGGER check_quantity
BEFORE INSERT ON Transactions
FOR EACH ROW
BEGIN

    DECLARE collected DECIMAL(10,2);
    DECLARE processed DECIMAL(10,2);

    SELECT quantity
    INTO collected
    FROM Waste
    WHERE waste_id = NEW.waste_id;

    SELECT COALESCE(SUM(quantity_processed),0)
    INTO processed
    FROM Transactions
    WHERE waste_id = NEW.waste_id;

    IF processed + NEW.quantity_processed > collected THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Processed quantity is greater than waste quantity';

    END IF;

END$$

DELIMITER ;

-- 5. INSERT SAMPLE DATA
-- Data can also be insert by importing the required datasets

-- Insert into Users


INSERT INTO Users (name, contact_info, address) VALUES
('Ravi Kumar', '9876543210', 'Vijayawada'),
('Priya Sharma', '9876543211', 'Guntur'),
('Arjun Reddy', '9876543212', 'Hyderabad'),
('Sneha Rao', '9876543213', 'Rajahmundry'),
('Kiran Das', '9876543214', 'Visakhapatnam'),
('Manoj', '9876543215', 'Eluru'),
('Divya', '9876543216', 'Kakinada'),
('Pavan', '9876543217', 'Ongole');

-- Insert into Collector


INSERT INTO Collector (name, assigned_area, contact_info) VALUES
('Ramesh', 'Vijayawada', '9000000001'),
('Suresh', 'Guntur', '9000000002'),
('Mahesh', 'Hyderabad', '9000000003'),
('Karthik', 'Eluru', '9000000004'),
('Naveen', 'Kakinada', '9000000005');

-- Insert into Recycling_Center


INSERT INTO Recycling_Center
(location, capacity, contact_info) VALUES
('Vijayawada Center', 1000.00, '8000000001'),
('Guntur Center', 800.00, '8000000002'),
('Hyderabad Center', 1500.00, '8000000003'),
('Eluru Center', 900.00, '8000000004'),
('Kakinada Center', 1100.00, '8000000005');

-- Insert into Collection_Request


INSERT INTO Collection_Request
(user_id, collector_id, waste_type, requested_date, status) VALUES
(1, 1, 'Plastic', '2026-09-01', 'Completed'),
(2, 2, 'Paper', '2026-09-02', 'Collected'),
(3, 3, 'Metal', '2026-09-03', 'Assigned'),
(4, NULL, 'Glass', '2026-09-04', 'Pending'),
(5, 1, 'Plastic', '2026-09-05', 'Completed'),
(6, 4, 'Paper', '2026-09-10', 'Completed'),
(7, 5, 'Glass', '2026-09-11', 'Pending'),
(8, 4, 'Metal', '2026-09-12', 'Assigned');


-- Insert into Waste


INSERT INTO Waste
(request_id, center_id, waste_type, quantity, category) VALUES
(1, 1, 'Plastic Bottles', 50.00, 'Recyclable'),
(2, 2, 'Paper Waste', 30.00, 'Reusable'),
(3, 3, 'Metal Cans', 20.00, 'Recyclable'),
(4, NULL, 'Glass Bottles', 15.00, 'Recyclable'),
(5, 1, 'Plastic Containers', 40.00, 'Recyclable'),
(6, 4, 'Cardboard', 25.00, 'Reusable'),
(7, NULL, 'Glass Bottles', 18.00, 'Recyclable'),
(8, 5, 'Aluminum Cans', 35.00, 'Recyclable');

-- Insert into Transactions

INSERT INTO Transactions
(waste_id, collector_id, center_id,
 transaction_date, quantity_processed) VALUES
(1, 1, 1, '2026-09-06', 40.00),
(2, 2, 2, '2026-09-07', 25.00),
(3, 3, 3, '2026-09-08', 15.00),
(5, 1, 1, '2026-09-09', 30.00),
(6, 4, 4, '2026-09-13', 20.00),
(8, 4, 5, '2026-09-14', 30.00);

-- 6. VIEWS
-- View 1: Request details
CREATE VIEW request_details AS
SELECT
    r.request_id,
    u.name AS user_name,
    c.name AS collector_name,
    r.waste_type,
    w.quantity,
    r.requested_date,
    r.status
FROM Collection_Request r
JOIN Users u
ON r.user_id = u.user_id
LEFT JOIN Collector c
ON r.collector_id = c.collector_id
LEFT JOIN Waste w
ON r.request_id = w.request_id;

-- View 2: Recycling center usage
CREATE VIEW center_utilization AS
SELECT
    rc.center_id,
    rc.location,
    rc.capacity,
    COALESCE(SUM(t.quantity_processed),0) AS total_processed
FROM Recycling_Center rc
LEFT JOIN Transactions t
ON rc.center_id = t.center_id
GROUP BY
    rc.center_id,
    rc.location,
    rc.capacity;

-- View 3: Collector summary
CREATE VIEW collector_summary AS
SELECT
    c.collector_id,
    c.name,
    c.assigned_area,
    COUNT(r.request_id) AS requests_handled
FROM Collector c
LEFT JOIN Collection_Request r
ON c.collector_id = r.collector_id
GROUP BY
    c.collector_id,
    c.name,
    c.assigned_area;

-- 7. STORED PROCEDURE
-- Assign a collector to a pending request

DELIMITER $$

CREATE PROCEDURE assign_collector(
    IN request_no INT,
    IN collector_no INT
)
BEGIN
    UPDATE Collection_Request
    SET collector_id = collector_no,
        status = 'Assigned'
    WHERE request_id = request_no
    AND status = 'Pending';
END$$

DELIMITER ;

-- 8. QUERIES



SELECT * FROM Users;

SELECT * FROM Collection_Request;

SELECT request_id, waste_type, requested_date, status
FROM Collection_Request
WHERE status = 'Pending';


SELECT waste_id, waste_type, quantity, category
FROM Waste
WHERE quantity > 20;

SELECT u.name, r.waste_type,
       r.requested_date, r.status
FROM Users u
JOIN Collection_Request r
ON u.user_id = r.user_id;


SELECT * FROM Transactions;


SELECT rc.location,
       SUM(t.quantity_processed) AS total_processed
FROM Recycling_Center rc
JOIN Transactions t
ON rc.center_id = t.center_id
GROUP BY rc.center_id, rc.location;


SELECT waste_type,
       SUM(quantity) AS total_quantity
FROM Waste
GROUP BY waste_type
ORDER BY total_quantity DESC;