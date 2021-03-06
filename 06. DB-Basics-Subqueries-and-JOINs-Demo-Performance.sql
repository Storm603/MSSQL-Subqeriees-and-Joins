/*============================================================================
	File:		ManyIndices.sql

	Summary:	The script demonstrates what is the effect on the DML operations
				when there are a lot of indexes on the table.

				THIS SCRIPT IS PART OF THE Lecture: 
				"Performance Tuning" for SoftUni, Sofia;
				"Joins, Subqueries, CTE and Indices"

	Date:		February 2015, January 2017

	SQL Server Version: 2008 / 2012 / 2014 / 2016
------------------------------------------------------------------------------
	Written by Boris Hristov, SQL Server MVP

	This script is intended only as a supplement to demos and lectures
	given by SoftUni Team.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

USE tempdb
GO
-- Create Table
CREATE TABLE FirstIndex (ID INT, 
						FirstName VARCHAR(100), 
						LastName VARCHAR(100), 
						City VARCHAR(100))
GO
-- Insert One Hundred Thousand Records
-- INSERT 1
INSERT INTO FirstIndex (ID,FirstName,LastName,City)
SELECT TOP 100000 ROW_NUMBER() OVER (ORDER BY a.name) RowID, 
					'Bob', 
					CASE WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%2 = 1 THEN 'Smith' 
					ELSE 'Brown' END,
					CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 1 THEN 'New York' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 5 THEN 'San Marino' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 3 THEN 'Los Angeles' 
					ELSE 'Houston' END
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
GO
-- Truncate Table
TRUNCATE TABLE FirstIndex
GO
-- Create 10 indexes
CREATE NONCLUSTERED INDEX [IX_FirstIndex_ID] ON [dbo].[FirstIndex] 
(
	[ID] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_FirstName] ON [dbo].[FirstIndex] 
(
	[FirstName] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_LastName] ON [dbo].[FirstIndex] 
(
	[LastName] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_City] ON [dbo].[FirstIndex] 
(
	[City] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_ID_FirstName] ON [dbo].[FirstIndex] 
(
	[ID] ASC,
	[FirstName] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_ID_LastName] ON [dbo].[FirstIndex] 
(
	[ID] ASC,
	[LastName] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_ID_City] ON [dbo].[FirstIndex] 
(
	[ID] ASC,
	[City] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_FirstName_LastName] ON [dbo].[FirstIndex] 
(
	[FirstName] ASC,
	[LastName] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_FirstName_City] ON [dbo].[FirstIndex] 
(
	[FirstName] ASC,
	[City] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FirstIndex_LastName_City] ON [dbo].[FirstIndex] 
(
	[LastName] ASC,
	[City] ASC
) ON [PRIMARY]
GO
-- Insert One Hundred Thousand Records
-- INSERT 2
INSERT INTO FirstIndex (ID,FirstName,LastName,City)
SELECT TOP 100000 ROW_NUMBER() OVER (ORDER BY a.name) RowID, 
					'Bob', 
					CASE WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%2 = 1 THEN 'Smith' 
					ELSE 'Brown' END,
					CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 1 THEN 'New York' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 5 THEN 'San Marino' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 3 THEN 'Los Angeles' 
					ELSE 'Houston' END
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
GO
/*
Question 1: Which insert took most the time INSERT 1 or INSERT 2
WHY?
*/
-- Truncate Table
TRUNCATE TABLE FirstIndex
GO

SELECT * FROM [FirstIndex]

USE [SoftUni]

SELECT * FROM [Employees]
SELECT * FROM [Addresses]
SELECT * FROM [Towns]
SELECT * FROM [Departments]
SELECT * FROM [Projects]
SELECT * FROM [EmployeesProjects]

--1st
SELECT TOP 5 e.EmployeeID, e.JobTitle, e.AddressId, a.AddressText FROM [Employees] AS e JOIN Addresses AS a ON e.AddressID = a.AddressID ORDER BY [AddressID]

--2nd
SELECT TOP(50) e.FirstName, e.LastName, t.[Name] AS Town, A.AddressText FROM [Employees] AS e 
JOIN [Addresses] AS a ON e.AddressID = a.AddressID 
JOIN [Towns] AS t ON a.TownID = T.TownID
ORDER BY e.FirstName ASC, e.LastName

--3rd like a turd
SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID WHERE d.[Name] = 'Sales' ORDER BY e.EmployeeID

--4th like come forth
SELECT TOP 5 e.EmployeeID, e.FirstName, e.Salary, d.Name FROM [Employees] AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID WHERE e.Salary > 15000
ORDER BY e.DepartmentID

--5th
SELECT TOP(3) e.EmployeeID, e.FirstName FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL ORDER BY e.EmployeeID

--6th
SELECT e.FirstName, e.LastName, e.HireDate, d.[Name] FROM [Employees] AS e JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] IN ('Sales', 'Finance') AND e.HireDate > '1999/01/01' ORDER BY e.HireDate

--7th
SELECT TOP(5) e.EmployeeID, e.FirstName, P.[Name] FROM [Employees] AS e
JOIN EmployeesProjects AS ep 
ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p 
ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > '2002/08/13' AND p.EndDate IS NULL ORDER BY e.EmployeeID

SELECT  e.EmployeeID, e.FirstName, P.[Name] FROM [Employees] AS e
FULL JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
FULL JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE E.EmployeeID = 24

--8TH
SELECT e.EmployeeID, e.FirstName, 
CASE
	WHEN YEAR(p.StartDate) >= 2005 THEN NULL
	ELSE p.[Name]
	END AS [ProjectName]
FROM [Employees] AS e
INNER JOIN EmployeesProjects AS ep 
ON e.EmployeeID = ep.EmployeeID
INNER JOIN Projects AS p 
ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24

select * from [Projects] WHERE Projects.[Name] IN ('LL Touring Frame', 'Road-650', 'Touring Front Wheel', 'Bike Wash')



--9TH
--SELECT e1.EmployeeID, e1.FirstName, e1.ManagerID,
--CASE
--	WHEN e1.ManagerID = 3 THEN 'Roberto'
--	else 'JoLynn'
--	END AS ManagerName
--FROM [Employees] AS e1 WHERE E1.[ManagerID] In (3, 7)

--where [ManagerID] In (3, 7)
--SELECT [FirstName] FROM [Employees] WHERE [EmployeeID] In (3, 7)

--correct query below top 2
SELECT e.EmployeeID, e.FirstName, e.ManagerID, e2.FirstName FROM [Employees] AS e JOIN 
[Employees] as e2 ON e.ManagerID = e2.EmployeeID WHERE e2.EmployeeID IN (3, 7) ORDER BY E.EmployeeID

select e.EmployeeID, e.FirstName, e.ManagerID as ManagerName from Employees as e JOIN
Employees as d ON e.FirstName = d.FirstName

SELECT [FirstName] FROM Employees where EmployeeID IN (3,7)

SELECT * FROM [Employees]

SELECT e.EmployeeID, e.FirstName, e.ManagerID, e1.FirstName FROM [Employees] as e JOIN 
[Employees] AS e1 ON e.EmployeeID = e1.EmployeeID WHERE e.ManagerID IN (3, 7) ORDER BY e.EmployeeID

--10th
SELECT TOP(50) e.EmployeeID, CONCAT(e.FirstName, ' ' , e.LastName) AS [EmployeeName], CONCAT(e2.FirstName, ' ' , e2.LastName) AS [ManagerName], d.[Name] AS [DepartmentName] FROM Employees AS e
JOIN Employees AS e2 on E.ManagerID = E2.EmployeeID
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

SELECT * FROM [Departments]

--SELECT e1.EmployeeID, CONCAT(e1.FirstName, ' ', e1.LastName), e2.FirstName FROM Employees AS e1
--LEFT JOIN Employees as e2 ON e1.EmployeeID = e2.EmployeeID

SELECT MIN(AVER) AS MinAverageSalary FROM (
	SELECT DEPARTMENTID, AVG(SALARY) AS AverageSalary FROM Employees
)

--11th
SELECT * FROM Employees
SELECT * FROM Departments

SELECT sum(Salary) FROM Employees WHERE DepartmentID IN (
SELECT Salary FROM Employees AS E 
)



USE [Geography]

--12th
SELECT * FROM Mountains

SELECT * FROM [MountainsCountries] AS m JOIN
[Mountains] AS m2 ON m.MountainId = m2.Id 
JOIN [Peaks] AS p ON m2.Id = p.Id

--CORRECT QUERY BELOW
SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM [Mountains] as m 
JOIN [Peaks] AS p ON m.Id = p.MountainId 
JOIN MountainsCountries AS mc ON mc.MountainId = m.Id
WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835 ORDER BY p.Elevation DESC


SELECT * FROM Peaks

SELECT * FROM Mountains as m JOIN Peaks as p ON m.Id = p.MountainId

--13TH
SELECT mc.CountryCode, m.MountainRange, COUNT(m.MountainRange) FROM MountainsCountries AS mc JOIN [Mountains] as m ON mc.MountainId = m.Id GROUP BY m.MountainRange

SELECT mc.CountryCode FROM MountainsCountries AS mc 
 
 SELECT e. FROM (
 SELECT * FROM Mountains
 ) as e

SELECT * FROM [Mountains]

go
--11th
SELECT MIN(a.AverageSalary) as MinAverageSalary FROM (
select e.DepartmentID, avg(e.Salary) AS AverageSalary FROM Employees as e GROUP BY e.DepartmentID) as a

go