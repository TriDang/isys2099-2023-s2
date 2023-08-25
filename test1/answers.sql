-- Problem 1
-- You must join Employee table with itself to
-- get employee first name and supervisor first name,
-- then join with Department to get department name,
-- then join with Employee to get manager first name

SELECT emp.Fname AS Emp_Fname,
       sup.Fname AS Sup_Fname,
       Dname,
       mgr.Fname AS Mgr_Fname
FROM Employee emp JOIN Employee sup
ON emp.Super_ssn = sup.Ssn
JOIN Department
ON emp.Dno = Dnumber
JOIN Employee Mgr
ON Mgr_ssn = Mgr.Ssn;

-- Based on the JOIN conditions, the following indices
-- should be created to improve the query performance
-- Employee(Ssn)
-- Employee(Super_ssn)
-- Employee(Dno)
-- Department(Dnumber)
-- Department(Mgr_ssn)

ALTER TABLE Employee
ADD INDEX idx_ssn (Ssn);

ALTER TABLE Employee
ADD INDEX idx_sup_ssn (Super_ssn);

ALTER TABLE Employee
ADD INDEX idx_dno (Dno);

ALTER TABLE Department
ADD INDEX idx_dnumber (Dnumber);

ALTER TABLE Department
ADD INDEX idx_mgr (Mgr_ssn);

-- Explanation using EXPLAIN output:
-- Before: for all tables (there are four), the access type is ALL
-- After: only the first table has the access type ALL, others
-- have the access type ref, where indices can be used

----------------------------
-- Problem 2

-- According to the requirements, the projects managed by 'Research'
-- (Dnum = 5) must be in one partition, the projects managed by
-- 'RMIT' (any number that you chose, for example, 10) must be in one partition, and
-- projects managed by 'Administration' (Dnum = 4) and 'Headquarters'
-- (Dnum = 1) must be in one partition.

ALTER TABLE Project
PARTITION BY LIST (Dnum) (
  PARTITION pResearch VALUES IN (5),
  PARTITION pRMIT VALUES IN (10),
  PARTITION pOther VALUES IN (1, 4)
);

-- To view the estimated number of records in each partitions
-- Switch to INFORMATION_SCHEMA, then execute the SQL below

SELECT PARTITION_NAME, TABLE_ROWS FROM PARTITIONS
WHERE TABLE_SCHEMA = 'company_nokey' AND TABLE_NAME = 'Project';

----------------------------
-- Problem 3

-- First, the SQL statement
SELECT emp.Fname AS Emp_Fname,
       sup.Fname AS Sup_Fname
FROM Employee emp JOIN Employee sup
ON emp.Super_ssn = sup.Ssn
WHERE emp.Salary > 30000;

-- Based on the assumption:
-- Number of emp records (without WHERE) = number of sup records = 1000
-- Number of emp records (with WHERE) = 750

-- Execution plan 1: (emp JOIN sup) => SELECT (this is the SELECT operation, not the SELECT clause in SQL) => Project
-- JOIN: (1000 + 1000) reads, 1000 writes (because there is one supervisor for every employee)
-- SELECT: 1000 reads, 750 writes
-- Project: 750 reads
-- Note: if you stop after 1000 reads in SELECT, similar to the lecture slide, it is OK, too


-- Execution plan 2: (SELECT on emp) => JOIN with sup => Project
-- SELECT: 1000 reads, 750 writes
-- JOIN: (750 + 1000) reads, 750 writes
-- Project: 750 reads
-- Note: if you stop after (750 + 1000) reads in JOIN, similar to the lecture slide, it is OK, too

-- If you use EXPLAIN for the SQL statement, you can see that MySQL
-- applies SELECT on emp first, then JOIN with sup;
-- This is similar to plan 2, which is better than plan 1

-- Note: if you use EXPLAIN ANALYZE, you can see that MySQL expands
-- the SELECT condition to
-- (emp.Salary > 30000) and (emp.Super_ssn is not null)
-- in order to possibly reduce the number of matching records
