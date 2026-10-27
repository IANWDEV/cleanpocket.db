-- =============================================================================
-- Database Schema: Clean Your Pockets LLC
-- Tables: CUSTOMER, SERVICE_ADDRESS, SERVICE_PLAN, SUBSCRIPTION,
--         EMPLOYEE, CLEANING_JOB, PAYMENT
-- =============================================================================

CREATE DATABASE IF NOT EXISTS clean_your_pockets;
USE clean_your_pockets;

-- Drop dependent tables in reverse order to avoid foreign key conflicts
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS CLEANING_JOB;
DROP TABLE IF EXISTS SUBSCRIPTION;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS SERVICE_PLAN;
DROP TABLE IF EXISTS SERVICE_ADDRESS;
DROP TABLE IF EXISTS CUSTOMER;

-- 1. CUSTOMER TABLE
CREATE TABLE CUSTOMER (
    customer_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_customer PRIMARY KEY (customer_id)
);

-- 2. SERVICE_ADDRESS TABLE
CREATE TABLE SERVICE_ADDRESS (
    address_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    street_address VARCHAR(150) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    square_footage INT,
    CONSTRAINT pk_service_address PRIMARY KEY (address_id),
    CONSTRAINT fk_service_address_customer 
        FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. SERVICE_PLAN TABLE
CREATE TABLE SERVICE_PLAN (
    plan_id INT AUTO_INCREMENT,
    plan_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    base_price DECIMAL(10, 2) NOT NULL,
    frequency ENUM('Weekly', 'Bi-Weekly', 'Monthly', 'One-Time') NOT NULL,
    CONSTRAINT pk_service_plan PRIMARY KEY (plan_id)
);

-- 4. SUBSCRIPTION TABLE
CREATE TABLE SUBSCRIPTION (
    subscription_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('Active', 'Paused', 'Cancelled') NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_subscription PRIMARY KEY (subscription_id),
    CONSTRAINT fk_subscription_customer 
        FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_subscription_address 
        FOREIGN KEY (address_id) REFERENCES SERVICE_ADDRESS(address_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_subscription_plan 
        FOREIGN KEY (plan_id) REFERENCES SERVICE_PLAN(plan_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 5. EMPLOYEE TABLE
CREATE TABLE EMPLOYEE (
    employee_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL DEFAULT 'Cleaner',
    hire_date DATE NOT NULL,
    CONSTRAINT pk_employee PRIMARY KEY (employee_id)
);

-- 6. CLEANING_JOB TABLE
CREATE TABLE CLEANING_JOB (
    job_id INT AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    employee_id INT NOT NULL,
    scheduled_datetime DATETIME NOT NULL,
    completed_datetime DATETIME,
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Scheduled',
    notes TEXT,
    CONSTRAINT pk_cleaning_job PRIMARY KEY (job_id),
    CONSTRAINT fk_job_subscription 
        FOREIGN KEY (subscription_id) REFERENCES SUBSCRIPTION(subscription_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_job_employee 
        FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 7. PAYMENT TABLE
CREATE TABLE PAYMENT (
    payment_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    job_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Credit Card', 'Debit Card', 'Bank Transfer', 'Cash') NOT NULL,
    payment_status ENUM('Paid', 'Pending', 'Failed', 'Refunded') NOT NULL DEFAULT 'Paid',
    CONSTRAINT pk_payment PRIMARY KEY (payment_id),
    CONSTRAINT fk_payment_customer 
        FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_payment_job 
        FOREIGN KEY (job_id) REFERENCES CLEANING_JOB(job_id) 
        ON DELETE SET NULL ON UPDATE CASCADE
);
