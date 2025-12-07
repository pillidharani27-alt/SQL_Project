show databases;
use classicmodels;

-- Q.NO:-1
-- A
select * from employees;
SELECT employeeNumber, firstName, lastName FROM employees
WHERE jobTitle = 'Sales Rep'
AND reportsTo = 1102;
-- B
SHOW TABLES;
SELECT * FROM PRODUCTS;
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%Cars';

-- Q.NO:-2
  SELECT * FROM customers;
  SELECT customerNumber, customerName,CASE 
        WHEN country IN ('USA', 'Canada') THEN 'North America'
        WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
        ELSE 'Other'
    END AS CustomerSegment FROM customers;
    
-- Q.NO:-3
-- A
SELECT * FROM orderdetails;
SELECT productCode, SUM(quantityOrdered) AS TotalQuantity
FROM OrderDetails
GROUP BY productCode
ORDER BY TotalQuantity DESC
LIMIT 10;
-- B
SELECT * FROM payments;
SELECT MONTHNAME(paymentDate) AS PaymentMonth,COUNT(*) AS TotalPayments
FROM Payments
GROUP BY PaymentMonth
HAVING COUNT(*) > 20
ORDER BY TotalPayments DESC;

-- Q.NO:-4
-- A
show databases;
SHOW TABLES;
CREATE DATABASE Customers_Orders;
USE Customers_Orders ;
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);
SELECT * FROM Customers;
DESC customers;
-- B
USE Customers_Orders ;
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT chk_total_amount
        CHECK (total_amount > 0)
);
SELECT * from ORDERS;
DESC orders;

-- Q.NO:-5
USE CLASSICMODELS;
SELECT * FROM customers;
SELECT * FROM orders;
SELECT  c.country,count(o.ordernumber) as order_count from customers c join orders o 
on c.customernumber=o.customernumber group by c.country order by order_count desc limit 5;

-- Q.NO:-6
Drop  table if exists project;
create table project( EmployeeID int primary key auto_increment,
 Full_Name varchar(50) not null,
 Gender Enum("Male","Female") not null,
 ManagerID int);
insert into project values
(1,"Pranaya","male",3),
(2,"Priyanka","female",1),
(3,"Preety","female",null),
(4,"Anurag","Male",1),
(5,"Sambit","Male",1),
(6,"Rajesh","Male",3),
(7,"Hina","Female",3);
select * from project;
select m.full_name as manager_Name,e.full_name as EMP_Name from project e join 
project m on e.managerid= m.employeeid;

-- Q.NO:-7
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(50),
    Country VARCHAR(50)
);
ALTER TABLE facility
MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE facility
ADD COLUMN City VARCHAR(50) NOT NULL AFTER Name;
SELECT * FROM facility;
DESC facility;

-- Q.NO:-8
USE CLASSICMODELS;
CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine,                                
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,   
    COUNT(DISTINCT o.orderNumber) AS number_of_orders        
FROM productlines pl
JOIN products p 
    ON pl.productLine = p.productLine
JOIN orderdetails od 
    ON p.productCode = od.productCode
JOIN orders o 
    ON od.orderNumber = o.orderNumber
GROUP BY pl.productLine;
SELECT * FROM product_category_sales;

-- Q.NO:-9
DELIMITER $$
CREATE PROCEDURE Get_country_payments (
    IN in_year INT,
    IN in_country VARCHAR(50)
)
BEGIN SELECT 
        YEAR(p.paymentDate) AS payment_year,
        c.country AS customer_country,
        CONCAT(ROUND(SUM(p.amount)/1000, 0), 'K') AS total_amount
    FROM payments p
    JOIN customers c 
        ON p.customerNumber = c.customerNumber
    WHERE YEAR(p.paymentDate) = in_year
      AND c.country = in_country
    GROUP BY YEAR(p.paymentDate), c.country;
END$$
DELIMITER ;
CALL Get_country_payments(2003, 'France');

-- Q.NO:-10
-- A
SELECT c.customerName,
    COUNT(o.orderNumber) AS order_count,
    DENSE_RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequencey_rnk
FROM customers c
JOIN orders o ON 
c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY order_count DESC;

-- B
select * from orders;
select year(orderdate) as year,monthname(orderdate) as month, count(ordernumber) as total_orders,
concat(round((count(ordernumber)-lag(count(ordernumber)) over (order by year(orderdate),month(orderdate))) 
/ lag(count(ordernumber))over(order by year(orderdate),
month(orderdate))*100,0),"%" )as yoy_change from orders
group by year(orderdate),month(orderdate),monthname(orderdate)
order by year,month(orderdate);


-- Q.NO:-11
SELECT 
ProductLine,
    COUNT(*) AS ProductCount
FROM Products
WHERE BuyPrice > (
        SELECT AVG(BuyPrice) 
        FROM Products)
GROUP BY ProductLine;


-- Q.NO:-12
-- Step 1: Create Table
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    EmailAddress VARCHAR(100)
);

-- Step 2: Create Procedure with Error Handling
DELIMITER $$

CREATE PROCEDURE InsertEmp_EH (
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(50),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred' AS Message;
    END;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    SELECT 'Record inserted successfully' AS Message;
END$$

DELIMITER ;

-- Step 3: Execute Procedure
CALL InsertEmp_EH(101, 'Dharani', 'dharani@gmail.com');  
CALL InsertEmp_EH(101, 'DuplicateID', 'dup@gmail.com');  


-- Q.NO:-13
-- Step 1: Create the table
CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

-- Step 2: Insert initial values
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

-- Step 3: Create the BEFORE INSERT trigger
DELIMITER $$

CREATE TRIGGER trg_before_insert_empbit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
-- If working_hours is negative, make it positive
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END$$
DELIMITER ;
INSERT INTO Emp_BIT VALUES ('Sam', 'Developer', '2020-10-05', -9);

SELECT * FROM Emp_BIT WHERE Name='Sam';