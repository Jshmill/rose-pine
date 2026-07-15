/*
T-SQL REFERENCE CHEAT SHEET
Covers many commonly used SQL Server / T-SQL features.
*/

-- =========================
-- DATABASES
-- =========================
CREATE DATABASE DemoDB;
GO

USE DemoDB;
GO

-- =========================
-- TABLES
-- =========================
CREATE TABLE dbo.Departments
(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    CreatedDate DATETIME2 DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.Employees
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(255) UNIQUE,
    Salary DECIMAL(12,2),
    HireDate DATE,
    DepartmentID INT,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Employees_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES dbo.Departments(DepartmentID)
);
GO

-- =========================
-- INSERT
-- =========================
INSERT INTO dbo.Departments (DepartmentName)
VALUES ('IT'), ('HR'), ('Finance');

INSERT INTO dbo.Employees
(
    FirstName,
    LastName,
    Email,
    Salary,
    HireDate,
    DepartmentID
)
VALUES
('John', 'Smith', 'john@example.com', 80000, '2024-01-15', 1),
('Jane', 'Doe', 'jane@example.com', 95000, '2023-05-10', 2);
GO

-- =========================
-- SELECT
-- =========================
SELECT *
FROM dbo.Employees;

SELECT TOP (10)
       EmployeeID,
       FirstName,
       Salary
FROM dbo.Employees
ORDER BY Salary DESC;
GO

-- =========================
-- FILTERING
-- =========================
SELECT *
FROM dbo.Employees
WHERE Salary > 75000
  AND IsActive = 1;

SELECT *
FROM dbo.Employees
WHERE FirstName LIKE 'J%';

SELECT *
FROM dbo.Employees
WHERE DepartmentID IN (1,2,3);
GO

-- =========================
-- JOINS
-- =========================
SELECT e.FirstName,
       e.LastName,
       d.DepartmentName
FROM dbo.Employees e
INNER JOIN dbo.Departments d
    ON e.DepartmentID = d.DepartmentID;
GO

-- =========================
-- AGGREGATES
-- =========================
SELECT DepartmentID,
       COUNT(*) AS EmployeeCount,
       AVG(Salary) AS AvgSalary,
       MIN(Salary) AS MinSalary,
       MAX(Salary) AS MaxSalary
FROM dbo.Employees
GROUP BY DepartmentID
HAVING COUNT(*) > 0;
GO

-- =========================
-- CASE
-- =========================
SELECT FirstName,
       Salary,
       CASE
           WHEN Salary >= 100000 THEN 'High'
           WHEN Salary >= 75000 THEN 'Medium'
           ELSE 'Low'
       END AS SalaryBand
FROM dbo.Employees;
GO

-- =========================
-- VARIABLES
-- =========================
DECLARE @EmployeeCount INT;

SELECT @EmployeeCount = COUNT(*)
FROM dbo.Employees;

PRINT 'Employee Count: ' + CAST(@EmployeeCount AS VARCHAR(20));
GO

-- =========================
-- IF / ELSE
-- =========================
DECLARE @Count INT = 10;

IF @Count > 5
    PRINT 'Greater than 5';
ELSE
    PRINT '5 or less';
GO

-- =========================
-- UPDATE
-- =========================
UPDATE dbo.Employees
SET Salary = Salary * 1.05
WHERE DepartmentID = 1;
GO

-- =========================
-- DELETE
-- =========================
DELETE FROM dbo.Employees
WHERE EmployeeID = -1;
GO

-- =========================
-- COMMON TABLE EXPRESSION (CTE)
-- =========================
WITH EmployeeCTE AS
(
    SELECT EmployeeID,
           FirstName,
           Salary
    FROM dbo.Employees
)
SELECT *
FROM EmployeeCTE;
GO

-- =========================
-- WINDOW FUNCTIONS
-- =========================
SELECT EmployeeID,
       FirstName,
       Salary,
       ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum,
       RANK() OVER (ORDER BY Salary DESC) AS SalaryRank,
       AVG(Salary) OVER () AS OverallAverage
FROM dbo.Employees;
GO

-- =========================
-- TEMP TABLES
-- =========================
CREATE TABLE #TempEmployees
(
    EmployeeID INT,
    EmployeeName NVARCHAR(100)
);

DROP TABLE #TempEmployees;
GO

-- =========================
-- TABLE VARIABLES
-- =========================
DECLARE @Temp TABLE
(
    ID INT,
    Name NVARCHAR(100)
);
GO

-- =========================
-- STRING FUNCTIONS
-- =========================
SELECT CONCAT(FirstName, ' ', LastName) AS FullName,
       UPPER(FirstName),
       LOWER(LastName),
       LEN(FirstName)
FROM dbo.Employees;
GO

-- =========================
-- DATE FUNCTIONS
-- =========================
SELECT GETDATE() AS CurrentDateTime,
       SYSDATETIME() AS PreciseDateTime,
       DATEADD(DAY, 30, GETDATE()) AS Plus30Days,
       DATEDIFF(DAY, HireDate, GETDATE()) AS DaysEmployed
FROM dbo.Employees;
GO

-- =========================
-- TRY CATCH
-- =========================
BEGIN TRY
    SELECT 10 / 2 AS Result;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- =========================
-- TRANSACTIONS
-- =========================
BEGIN TRANSACTION;

UPDATE dbo.Employees
SET Salary = Salary + 1000
WHERE EmployeeID = 1;

COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;
GO

-- =========================
-- STORED PROCEDURE
-- =========================
CREATE OR ALTER PROCEDURE dbo.GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.Employees
    WHERE DepartmentID = @DepartmentID;
END;
GO

EXEC dbo.GetEmployeesByDepartment @DepartmentID = 1;
GO

-- =========================
-- USER DEFINED FUNCTION
-- =========================
CREATE OR ALTER FUNCTION dbo.GetAnnualSalary
(
    @Salary DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN @Salary * 12;
END;
GO

-- =========================
-- VIEW
-- =========================
CREATE OR ALTER VIEW dbo.vwEmployeeSummary
AS
SELECT e.EmployeeID,
       e.FirstName,
       e.LastName,
       d.DepartmentName
FROM dbo.Employees e
LEFT JOIN dbo.Departments d
    ON e.DepartmentID = d.DepartmentID;
GO

-- =========================
-- MERGE
-- =========================
MERGE dbo.Departments AS Target
USING (SELECT 1 AS DepartmentID, 'Technology' AS DepartmentName) AS Source
ON Target.DepartmentID = Source.DepartmentID
WHEN MATCHED THEN
    UPDATE SET DepartmentName = Source.DepartmentName
WHEN NOT MATCHED THEN
    INSERT (DepartmentName)
    VALUES (Source.DepartmentName);
GO

-- =========================
-- INDEXES
-- =========================
CREATE INDEX IX_Employees_LastName
ON dbo.Employees (LastName);
GO

-- =========================
-- DYNAMIC SQL
-- =========================
DECLARE @Sql NVARCHAR(MAX);
SET @Sql = N'SELECT TOP 5 * FROM dbo.Employees';
EXEC sp_executesql @Sql;
GO

-- =========================
-- SYSTEM FUNCTIONS
-- =========================
SELECT @@VERSION AS SqlServerVersion,
       DB_NAME() AS CurrentDatabase,
       SUSER_NAME() AS CurrentUser;
GO
