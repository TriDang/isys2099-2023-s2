-- Exercise 1

-- Creating views

CREATE VIEW dept_stats
AS
SELECT dnumber, dname, mgr.fname AS manager_name, COUNT(*) AS noOfEmp
FROM department JOIN employee mgr
ON mgr_ssn = mgr.ssn
JOIN employee emp
ON Dnumber = emp.Dno
GROUP BY dnumber, dname, mgr.fname;

-- Using views

SELECT * FROM dept_stats
WHERE noOfEmp > 3;

-- Check views updatable property

SELECT * FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = 'dept_stats';

--------------------------------------------

-- Exercise 2

-- Create MVs

CREATE TABLE Project_Resources
SELECT Pnumber AS ProjectNumber, Pname AS ProjectName,
       Plocation AS ProjectLocation, COUNT(*) AS TotalEmployees
FROM project JOIN works_on
ON Pnumber = Pno
GROUP BY ProjectNumber, ProjectName, ProjectLocation;

-- Using MVs

SELECT * FROM project_resources;

--------------------------------------------

-- Exercise 3

-- Create stored procedures

DELIMITER $$$
CREATE PROCEDURE sp_update_salary(IN EmpID CHAR(9),
                                  IN IncAmt DECIMAL(5,0))
BEGIN
  UPDATE employee SET salary = salary + IncAmt
  WHERE ssn = EmpID;
END $$$
DELIMITER ;

-- A stored procedure to do full refresh
DELIMITER $$$

CREATE PROCEDURE sp_refresh()
BEGIN
  TRUNCATE TABLE project_resources;

  INSERT INTO project_resources
  SELECT Pnumber AS ProjectNumber, Pname AS ProjectName,
         Plocation AS ProjectLocation, COUNT(*) AS TotalEmployees
  FROM project JOIN works_on
  ON Pnumber = Pno
  GROUP BY ProjectNumber, ProjectName, ProjectLocation;
END $$$
DELIMITER ;

-- Store procedures with transaction


DELIMITER $$$
CREATE PROCEDURE sp_update_salary_advanced(IN EmpID char(9),
                                  IN IncAmt decimal(5,0),
                                  OUT success int)
BEGIN
  DECLARE `_rollback` INT DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
  START TRANSACTION;
  
  UPDATE employee SET salary = salary + IncAmt
  WHERE ssn = EmpID;

  SELECT emp.salary, sup.salary INTO @emp_sal, @sup_sal
  FROM employee emp JOIN employee sup
  ON emp.super_ssn = sup.ssn
  WHERE emp.ssn = EmpID;
  
  IF `_rollback` = 1 THEN
    ROLLBACK;
    SET success = 0;
  ELSE IF @emp_sal > @sup_sal THEN
    ROLLBACK;
    SET success = 0;
  ELSE
    COMMIT;
    SET success = 1;
  END IF;
END $$$
DELIMITER ;
