-- Exercise 1

-- Create function
DELIMITER $$
CREATE FUNCTION fn_maxSalary (department_number INT)
RETURNS CHAR(9) NOT DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE max_sal DECIMAL(6, 0);  -- maximum salary
  DECLARE max_ssn CHAR(9);  -- SSN of employee whose salary is maximum
  
  -- get maximum salary
  SELECT MAX(salary) into max_sal
  FROM employee
  WHERE dno = department_number;
  
  -- search for SSN
  SELECT ssn INTO max_ssn
  FROM employee
  WHERE dno = department_number AND salary = max_sal;
  
  RETURN max_ssn;
END $$

DELIMITER ;

-- Use function

SELECT dnumber, dname, fname, salary
FROM department
JOIN employee
ON dnumber = dno
WHERE ssn = fn_maxSalary(dnumber);

--------------------------------------------

-- Exercise 2

-- Create materialized view

CREATE TABLE dept_avg_salary
SELECT dnumber, dname, avg(salary) AS avg_salary
FROM department JOIN employee
ON dnumber = dno
GROUP BY dnumber, dname;

-- Use trigger to sync data

DELIMITER $$
CREATE TRIGGER trg_avg_sal
AFTER UPDATE ON employee
FOR EACH ROW
BEGIN
  DECLARE avg_sal DECIMAL(9, 2);  -- updated average salary

  SELECT AVG(salary) INTO avg_sal
  FROM employee
  WHERE dno = new.dno;

  UPDATE dept_avg_salary SET avg_salary = avg_sal
  WHERE dnumber = new.dno;
END $$
DELIMITER ;

--------------------------------------------

-- Exercise 3

DELIMITER $$
CREATE TRIGGER trg_prevent_overwork
BEFORE INSERT ON works_on
FOR EACH ROW
BEGIN
  DECLARE current_hours DECIMAL(5, 1);  -- current total hours

  SELECT SUM(hours) INTO current_hours
  FROM works_on
  WHERE essn = new.essn;
  
  IF current_hours + new.hours > 40 THEN
    SIGNAL SQLSTATE '45000' SET message_text = 'Overworked!';
  END IF;
END $$
DELIMITER ;
