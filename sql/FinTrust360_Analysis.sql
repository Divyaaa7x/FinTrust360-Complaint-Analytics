-- =====================================================================
-- FinTrust 360 – Financial Customer Complaints & Response Analytics
-- SQL Analysis (MySQL 8.0)
-- Author: Sree
--
-- Data used: FinTrust360_cleaned.csv (exported from the Cleaned_Data
-- sheet of my Excel workbook, 4,975 complaints after cleaning)
-- =====================================================================


-- ---------------------------------------------------------------------
-- STEP 1: Create the database and table
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS fintrust360;
USE fintrust360;

DROP TABLE IF EXISTS complaints;

CREATE TABLE complaints (
    complaint_id            VARCHAR(20) PRIMARY KEY,
    date_received           DATE,
    financial_product       VARCHAR(50),
    issue_category          VARCHAR(50),
    issue_detail            VARCHAR(60),
    company_name            VARCHAR(50),
    state                   VARCHAR(10),
    submission_channel      VARCHAR(20),
    response_due_date       DATE,
    date_company_responded  DATE,          -- empty for Open complaints
    response_status         VARCHAR(10),   -- Open / Closed
    company_response        VARCHAR(50),
    timely_response         VARCHAR(5),    -- Yes / No, empty for Open
    short_complaint_summary VARCHAR(200)
);


-- ---------------------------------------------------------------------
-- STEP 2: Load the cleaned CSV
-- (start the MySQL client with:  mysql --local-infile=1 -u root -p )
-- Change the file path to where the CSV is saved on your computer.
-- NULLIF turns empty text into NULL so empty dates load correctly.
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/FinTrust360/data/FinTrust360_cleaned.csv'
INTO TABLE complaints
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(complaint_id, date_received, financial_product, issue_category, issue_detail,
 company_name, state, submission_channel, response_due_date,
 @responded, response_status, company_response, @timely, short_complaint_summary)
SET date_company_responded = NULLIF(@responded, ''),
    timely_response        = NULLIF(@timely, '');

-- Quick check: should show 4975
SELECT COUNT(*) AS rows_loaded FROM complaints;


-- =====================================================================
-- ANALYSIS QUERIES
-- =====================================================================

-- ---------------------------------------------------------------------
-- Query 1: Total number of complaints
-- Counts every row in the table (one row = one complaint).
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total_complaints
FROM complaints;


-- ---------------------------------------------------------------------
-- Query 2: Open vs Closed complaints
-- Groups complaints by their status to see how many are still open.
-- ---------------------------------------------------------------------
SELECT response_status,
       COUNT(*) AS complaints
FROM complaints
GROUP BY response_status;


-- ---------------------------------------------------------------------
-- Query 3: Monthly complaint trend
-- DATE_FORMAT turns the date into year-month so I can count per month.
-- Note: October 2026 only has data up to 15 Oct, so it looks lower.
-- ---------------------------------------------------------------------
SELECT DATE_FORMAT(date_received, '%Y-%m') AS month,
       COUNT(*) AS complaints
FROM complaints
GROUP BY DATE_FORMAT(date_received, '%Y-%m')
ORDER BY month;


-- ---------------------------------------------------------------------
-- Query 4: Complaints by financial product
-- Shows which products get the most complaints (highest first).
-- ---------------------------------------------------------------------
SELECT financial_product,
       COUNT(*) AS complaints
FROM complaints
GROUP BY financial_product
ORDER BY complaints DESC;


-- ---------------------------------------------------------------------
-- Query 5: Top 10 most frequently reported issues
-- ---------------------------------------------------------------------
SELECT issue_category,
       COUNT(*) AS complaints
FROM complaints
GROUP BY issue_category
ORDER BY complaints DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Query 6: Complaints by company
-- Note: a company with more complaints is not always worse –
-- bigger companies have more customers, so they get more complaints.
-- ---------------------------------------------------------------------
SELECT company_name,
       COUNT(*) AS complaints
FROM complaints
GROUP BY company_name
ORDER BY complaints DESC;


-- ---------------------------------------------------------------------
-- Query 7: Top 10 customer states by complaints
-- 'Unknown' = state was missing in the raw data (filled during cleaning).
-- ---------------------------------------------------------------------
SELECT state,
       COUNT(*) AS complaints
FROM complaints
GROUP BY state
ORDER BY complaints DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Query 8: Overall timely-response percentage
-- Only Closed complaints are used, because Open ones have no response yet.
-- SUM(timely_response = 'Yes') counts the Yes rows (true = 1).
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS closed_complaints,
       SUM(timely_response = 'Yes') AS timely_yes,
       ROUND(SUM(timely_response = 'Yes') * 100.0 / COUNT(*), 2) AS timely_pct
FROM complaints
WHERE response_status = 'Closed';


-- ---------------------------------------------------------------------
-- Query 9: Timely-response percentage by company (Closed only)
-- Sorted lowest first so the slowest companies are at the top.
-- ---------------------------------------------------------------------
SELECT company_name,
       COUNT(*) AS closed_complaints,
       ROUND(SUM(timely_response = 'Yes') * 100.0 / COUNT(*), 2) AS timely_pct
FROM complaints
WHERE response_status = 'Closed'
GROUP BY company_name
ORDER BY timely_pct ASC;


-- ---------------------------------------------------------------------
-- Query 10: Average response time in days (Closed only)
-- DATEDIFF gives the number of days between two dates.
-- ---------------------------------------------------------------------
SELECT ROUND(AVG(DATEDIFF(date_company_responded, date_received)), 2) AS avg_response_days
FROM complaints
WHERE response_status = 'Closed';


-- ---------------------------------------------------------------------
-- Query 11: Average response time and timely % by financial product
-- Helps see which product type is handled slowest.
-- ---------------------------------------------------------------------
SELECT financial_product,
       COUNT(*) AS closed_complaints,
       ROUND(AVG(DATEDIFF(date_company_responded, date_received)), 2) AS avg_response_days,
       ROUND(SUM(timely_response = 'Yes') * 100.0 / COUNT(*), 2) AS timely_pct
FROM complaints
WHERE response_status = 'Closed'
GROUP BY financial_product
ORDER BY timely_pct ASC;


-- ---------------------------------------------------------------------
-- Query 12: How old are the Open complaints?
-- Counts open complaints by the month they were received.
-- If old months still have open complaints, there is a backlog.
-- ---------------------------------------------------------------------
SELECT DATE_FORMAT(date_received, '%Y-%m') AS month_received,
       COUNT(*) AS open_complaints
FROM complaints
WHERE response_status = 'Open'
GROUP BY DATE_FORMAT(date_received, '%Y-%m')
ORDER BY month_received;
