drop database hr_analytics;
create database hr_analytics;
use hr_analytics;
select database();
use hr_analytics;
select count(*) as total_rows from hr_employee_raw;
select*from hr_employee_raw limit 10;
select count(*) as total_rows,count(distinct Age,attrition,businesstravel,dailyrate,department,distancefromhome,education,educationfield) as distinct_rows from hr_employee_raw;
alter table hr_employee_raw change column `ï»¿Age` Age int;
describe hr_employee_raw;
select sum(age is null) as missing_age,sum(attrition is null) as missing_attrition,sum(department is null) as missing_department,sum(dailyrate is null) as missing_daily_rate from hr_employee_raw;
use hr_analytics;
create table hr_employee_clean as select*from hr_employee_raw;
select count(*) as total_employee from hr_employee_clean;
select count(*) as total_rows,count(distinct Age,Attrition,BusinessTravel,DailyRate,Department,DistanceFromHome,Education,Educationfield) as distinct_combinations from hr_employee_clean;
describe hr_employee_clean;
select count(*) as total_rows,count(*)-count(Distinct MD5(concat_ws('|',Age,Attrition,BusinessTravel,DailyRate,Department,DistanceFromHome,Education,EducationField)))as possible_duplicates from hr_employee_clean;
select attrition,count(*) as employee_count from hr_employee_clean group by attrition;
select department,count(*) as total_employees from hr_employee_clean group by department order by total_employees desc;
select count(*) as total_employees,sum(case when attrition='yes' then 1 else 0 end) as employees_left,round(sum(case when attrition='yes' then 1 else 0 end)*100.0/count(*),2)as attrition_rate from hr_employee_clean;
select department,count(*) as total_employees,sum(case when attrition='yes' then 1 else 0 end) as employees_left,round(sum(case when attrition='yes' then 1 else 0 end)*100.0/count(*),2)as attrition_rate from hr_employee_clean group by department order by attrition_rate desc;
select attrition,count(*) as employee_count, round(avg(monthlyincome),2) as avg_monthly_income from hr_employee_clean group by attrition;
select case when age < 25 then 'Below 25' when age between 25 and 34 then '25-34' when age between 35 and 44 then '35-44' when age between 45 and 54 then '45-54'else '55 and above'end as age_group, count(*) as total_employees,sum(case when attrition='yes' then 1 else 0 end) as employees_left,round(sum(case when attrition='yes' then 1 else 0 end)*100.0/count(*),2) as attrition_rate from hr_employee_clean group by age_group order by attrition_rate desc;
select overtime, count(*) as total_employees, sum(case when attrition='yes' then 1 else 0 end) as employees_left,round(sum(case when attrition='yes' then 1 else 0 end)*100.0/count(*),2) as attrition_rate from hr_employee_clean group by overtime order by attrition_rate desc;
select jobsatisfaction,count(*) as total_employees,sum(case when attrition='yes' then 1 else 0 end) as employees_left from hr_employee_clean group by jobsatisfaction order by jobsatisfaction;
select jobrole,count(*) as total_employees,sum(case when attrition='yes' then 1 else 0 end) as employees_left, round(100.0*sum(case when attrition='yes' then 1 else 0 end)/count(*),2) as attrition_rate_pct from hr_employee_clean group by jobrole order by attrition_rate_pct desc;
select count(*) as final_employee_count from hr_employee_clean;
select attrition,count(*) as employee_count from hr_employee_clean group by attrition;
use hr_analytics;
create table Department_details(Department VARCHAR(100) PRIMARY KEY,DepartmentHead VARCHAR(100),DepartmentLocation VARCHAR(100));  
insert into department_details values('Sales','ManagerA','Chennai'),('Research&Development','ManagerB','Bengaluru'),('HumanResources','ManagerC','Chennai');
select e.EmployeeNumber,e.Department,e.JobRole,e.MonthlyIncome,d.DepartmentHead,d.DepartmentLocation from hr_employee_clean AS e INNER JOIN department_details AS d ON e.Department=d.Department;
SELECT * FROM hr_employee_clean;
select * from department_details;
use hr_analytics;
select e.EmployeeNumber,e.Department,e.JobRole,d.DepartmentHead,d.DepartmentLocation from hr_employee_clean AS e LEFT JOIN department_details AS d ON e.Department=d.Department;
select e.EmployeeNumber,e.Department,e.JobRole,d.DepartmentHead,d.DepartmentLocation from hr_employee_clean AS e RIGHT JOIN department_details AS d ON e.Department=d.Department;
select e1.EmployeeNumber AS employee_1,e1.Department,e2.EmployeeNumber AS employee_2 from hr_employee_clean AS e1 INNER JOIN hr_employee_clean AS e2 ON e1.Department=e2.Department AND e1.EmployeeNumber < e2.EmployeeNumber LIMIT 20; 	
select EmployeeNumber, Department,JobRole,MonthlyIncome from hr_employee_clean where MonthlyIncome>(select avg(MONTHLYINCOME)from hr_employee_clean);
select e.EmployeeNumber,e.Department,e.JobRole,e.MonthlyIncome from hr_employee_clean AS e where e.MonthlyIncome > (select avg(e2.MonthlyIncome) from hr_employee_clean AS e2 where e2.Department=e.Department);
select EmployeeNumber,Department,JobRole,MonthlyIncome from hr_employee_clean where MonthlyIncome=(select max(MonthlyIncome) from hr_employee_clean);
With Department_Salary AS(select department,avg (MonthlyIncome) AS avg_salary from hr_employee_clean group by department) select Department,Round(avg_salary,2) AS average_salary from Department_Salary order by avg_salary DESC;
select EmployeeNumber,Department,JobRole,MonthlyIncome,Row_Number() OVER( PARTITION by Department order by MonthlyIncome DESC) AS salary_row_number from hr_employee_clean; 
SELECT EmployeeNumber,Department,MonthlyIncome,RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS salary_rank FROM hr_employee_clean; 
SELECT EmployeeNumber,Department,MonthlyIncome,DENSE_RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS salary_rank FROM hr_employee_clean;
SELECT EmployeeNumber,Department,MonthlyIncome,LAG(MonthlyIncome) OVER (PARTITION BY Department ORDER BY EmployeeNumber) AS previous_salary,MonthlyIncome -LAG(MonthlyIncome) OVER ( PARTITION BY Department ORDER BY EmployeeNumber) AS salary_difference  FROM hr_employee_clean;
USE hr_analytics;
CREATE OR REPLACE VIEW vw_department_attrition AS SELECT Department,COUNT(*) AS total_employees,SUM(Attrition = 'Yes') AS employees_left,ROUND(100.0 * SUM(Attrition = 'Yes') / COUNT(*),2) AS attrition_rate FROM hr_employee_clean GROUP BY Department;
SELECT *FROM vw_department_attrition ORDER BY attrition_rate DESC;
SHOW INDEX FROM hr_employee_clean;
USE hr_analytics;
DESCRIBE hr_employee_clean;
ALTER TABLE hr_employee_clean MODIFY Department VARCHAR(100);
CREATE INDEX idx_hr_department ON hr_employee_clean(Department);
SHOW INDEX FROM hr_employee_clean;
EXPLAIN SELECT Department, COUNT(*) AS total_employees FROM hr_employee_clean GROUP BY Department;
SELECT COUNT(*) AS total_employees FROM hr_employee_clean;
SELECT Department, COUNT(*) AS total_employees FROM hr_employee_clean GROUP BY Department;
USE hr_analytics;
SELECT Department,COUNT(*) AS total_employees,ROUND(AVG(MonthlyIncome), 2) AS avg_salary,MAX(MonthlyIncome) AS highest_salary,MIN(MonthlyIncome) AS lowest_salary FROM hr_employee_clean GROUP BY Department ORDER BY avg_salary DESC;
SELECT EmployeeNumber,Department,JobRole,MonthlyIncome FROM hr_employee_clean WHERE MonthlyIncome > (SELECT AVG(MonthlyIncome)FROM hr_employee_clean)ORDER BY MonthlyIncome DESC;
SELECT Department,COUNT(*) AS total_employees,SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_percentage FROM hr_employee_clean GROUP BY Department ORDER BY attrition_percentage DESC;
USE hr_analytics;
SELECT JobRole,COUNT(*) AS total_employees,SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2 )AS attrition_percentage FROM hr_employee_clean group by JobRole order by attrition_percentage DESC;
SELECT YearsAtCompany,COUNT(*) AS total_employees,ROUND(AVG(MonthlyIncome), 2) AS average_salary FROM hr_employee_clean GROUP BY YearsAtCompany ORDER BY YearsAtCompany;
USE hr_analytics;
SELECT EmployeeNumber,Department,MonthlyIncome,CASE WHEN MonthlyIncome >= 10000 THEN 'High Salary'WHEN MonthlyIncome >= 5000 THEN 'Medium Salary'ELSE 'Low Salary'END AS salary_category FROM hr_employee_clean;
USE hr_analytics;
SELECT EmployeeNumber,Department,MonthlyIncome,IF(MonthlyIncome >= 5000,'Above 5000','Below 5000') AS salary_status FROM hr_employee_clean;
USE hr_analytics;
SELECT e.EmployeeNumber,e.Department,e.JobRole,e.MonthlyIncome FROM hr_employee_clean e WHERE EXISTS (SELECT 1 FROM hr_employee_clean X WHERE x.Department = e.Department AND x.MonthlyIncome > 1000);
USE hr_analytics;
SELECT EmployeeNumber,Department,'High Salary' AS salary_category FROM hr_employee_clean WHERE MonthlyIncome >= 10000 UNION SELECT EmployeeNumber,Department,'Low Salary' AS salary_category FROM hr_employee_clean WHERE MonthlyIncome < 5000;
USE hr_analytics;
SELECT Department,COUNT(*) AS total_employees,ROUND(AVG(MonthlyIncome), 2) AS avg_salary FROM hr_employee_clean GROUP BY Department HAVING COUNT(*) > 50 ORDER BY total_employees DESC;
USE hr_analytics;
-- 1. Unique departments
SELECT DISTINCT Department FROM hr_employee_clean;
-- 2. Unique job roles
SELECT DISTINCT JobRole FROM hr_employee_clean;
-- 3. Department + Job Role combinations
SELECT DISTINCT Department, JobRole FROM hr_employee_clean ORDER BY Department, JobRole;
USE hr_analytics;
DELIMITER //
CREATE PROCEDURE GetDepartmentSummary()
BEGIN SELECT Department,COUNT(*) AS total_employees,ROUND(AVG(MonthlyIncome), 2) AS avg_salary FROM hr_employee_clean GROUP BY Department ORDER BY total_employees DESC;END //DELIMITER ;
CALL GetDepartmentSummary();
USE hr_analytics;
DELIMITER //
CREATE PROCEDURE GetEmployeesByDepart(IN dept_name VARCHAR(100))
BEGIN SELECT EmployeeNumber,Department,JobRole,MonthlyIncome,Attrition FROM hr_employee_clean WHERE Department = dept_name;
END //
DELIMITER ;
CALL GetEmployeesByDepart('Sales');
USE hr_analytics;
DELIMITER //
CREATE FUNCTION GetSalaryCategory(salary DECIMAL(10,2))RETURNS VARCHAR(20)DETERMINISTIC
 BEGIN
    IF salary >= 10000 THEN
        RETURN 'High Salary';
    ELSEIF salary >= 5000 THEN
        RETURN 'Medium Salary';
    ELSE
        RETURN 'Low Salary';
    END IF;
END //
DELIMITER ;
SELECT GetSalaryCategory(12000) AS salary_category;
SELECT EmployeeNumber,Department,MonthlyIncome,GetSalaryCategory(MonthlyIncome) AS salary_category FROM hr_employee_clean LIMIT 10;
use hr_analytics;
USE hr_analytics;
CREATE TABLE IF NOT EXISTS hr_employee_audit (audit_id INT AUTO_INCREMENT PRIMARY KEY,employee_id INT,action_type VARCHAR(20),action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
DELIMITER //
CREATE TRIGGER trg_employee_update AFTER UPDATE ON hr_employee_clean FOR EACH ROW BEGIN INSERT INTO hr_employee_audit(employee_id, action_type) VALUES(NEW.EmployeeNumber, 'UPDATE');
END //
DELIMITER ;
show tables;
SHOW DATABASES;
show tables;
show procedure status where db='hr_analytics';
SELECT EmployeeNumber, Department FROM hr_employee_clean LIMIT 5;
SHOW TRIGGERS FROM hr_analytics;
USE hr_analytics;
DELIMITER //
CREATE TRIGGER trg_validate_salary BEFORE UPDATE ON hr_employee_clean FOR EACH ROW BEGIN IF NEW.MonthlyIncome < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Monthly income cannot be negative';
END IF;
END //
DELIMITER ;
SHOW TRIGGERS FROM hr_analytics;
USE hr_analytics;
DELIMITER //
CREATE TRIGGER trg_employee_insert AFTER INSERT ON hr_employee_clean FOR EACH ROW BEGIN INSERT INTO hr_employee_audit(employee_id, action_type)VALUES(NEW.EmployeeNumber, 'INSERT');
END //
DELIMITER ;
SHOW TRIGGERS FROM hr_analytics;
SELECT *FROM hr_employee_audit;
USE hr_analytics;
DELIMITER //
CREATE TRIGGER trg_employee_delete AFTER DELETE ON hr_employee_clean FOR EACH ROW BEGIN INSERT INTO hr_employee_audit(employee_id, action_type)VALUES(OLD.EmployeeNumber, 'DELETE');
END //
DELIMITER ;
SHOW TRIGGERS FROM hr_analytics;
SELECT *FROM hr_employee_audit ORDER BY audit_id DESC;
USE hr_analytics;
DELIMITER //
CREATE TRIGGER trg_before_employee_insert BEFORE INSERT ON hr_employee_clean FOR EACH ROW BEGIN IF NEW.MonthlyIncome < 0 THEN SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'Monthly income cannot be negative';
END IF;
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER trg_before_employee_delete BEFORE DELETE ON hr_employee_clean FOR EACH ROW BEGIN INSERT INTO hr_employee_audit(employee_id, action_type)VALUES(OLD.EmployeeNumber, 'BEFORE DELETE');
END //
DELIMITER ;
SHOW TRIGGERS FROM hr_analytics;
USE hr_analytics;
CREATE TABLE IF NOT EXISTS transaction_practice (id INT PRIMARY KEY,employee_name VARCHAR(50),salary DECIMAL(10,2));
INSERT IGNORE INTO transaction_practice VALUES (1, 'Test Employee', 5000);
SELECT * FROM transaction_practice;
START TRANSACTION;
UPDATE transaction_practice SET salary = 6000 WHERE id = 1;
SELECT * FROM transaction_practice;
ROLLBACK;
SELECT * FROM transaction_practice;
START TRANSACTION;
UPDATE transaction_practice SET salary = 7000 WHERE id = 1;
COMMIT;
SELECT * FROM transaction_practice;
USE hr_analytics;
DELIMITER //
CREATE PROCEDURE TestErrorHandling() BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SELECT 'An error occurred' AS error_message;
SELECT 10 / 2 AS result;
END //
DELIMITER ;
CALL TestErrorHandling();
DELIMITER //
CREATE PROCEDURE TestErrorHandler() BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SELECT 'Error handled successfully' AS message;
INSERT INTO transaction_practice(id, employee_name, salary)VALUES(1, 'Duplicate Test', 9000);
SELECT 'Procedure continued' AS status;
END //
DELIMITER ;
CALL TestErrorHandler();
USE hr_analytics;
DELIMITER //
CREATE PROCEDURE TestExitHandler()BEGIN DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SELECT 'Error handled; procedure stopped'AS message;
END;
INSERT INTO transaction_practice(id, employee_name, salary)VALUES(1, 'Duplicate Test', 9000);
SELECT 'This statement will not run'AS status;
END //
DELIMITER ;
CALL TestExitHandler();
USE hr_analytics;
SHOW TABLES;
SELECT COUNT(*) AS total_employees FROM hr_employee_clean;
SELECT *FROM hr_employee_clean LIMIT 10;
SELECT Department,COUNT(*) AS total_employees,ROUND(AVG(MonthlyIncome), 2) AS avg_salary,SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left FROM hr_employee_clean GROUP BY Department ORDER BY employees_left DESC;
EXPLAIN SELECT *FROM hr_employee_clean WHERE Department = 'Sales';