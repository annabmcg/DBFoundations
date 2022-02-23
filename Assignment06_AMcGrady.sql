--*************************************************************************--
-- Title: Assignment06
-- Author: AMcGrady
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-02-21,AMcGrady,Completed Questions 1-10
-- 2022-02-22,AMcGrady,Pushed SQL Code to GitHub
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AMcGrady')
	 Begin 
	  Alter Database [Assignment06DB_AMcGrady] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AMcGrady;
	 End
	Create Database Assignment06DB_AMcGrady;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AMcGrady;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Create the Basic View for Categories (vCategories)
GO
CREATE VIEW vCategories
WITH SCHEMABINDING
	AS 
		SELECT CategoryID, CategoryName
		FROM dbo.Categories;
GO

-- Create the Basic View for Products (vProducts)
GO
CREATE VIEW vProducts
WITH SCHEMABINDING
	AS 
		SELECT ProductID, ProductName, CategoryID, UnitPrice
		FROM dbo.Products;
GO

-- Create the Basic View for Inventories (vInventories)
GO
CREATE VIEW vInventories
WITH SCHEMABINDING
	AS 
		SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
		FROM dbo.Inventories;
GO

-- Create the Basic View for Employees (vEmployees)
GO
CREATE VIEW vEmployees
WITH SCHEMABINDING
	AS 
		SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
		FROM dbo.Employees;
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Set permissions for Categories and vCategories
GO
DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC;
GO

-- Set permissions for Products and vProducts
GO
DENY SELECT ON Products TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;
GO

-- Set permissions for Inventories and vInventories
GO
DENY SELECT ON Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;
GO

-- Set permissions for Employees and vEmployees
GO
DENY SELECT ON Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

-- Inspect the tables to see the underlying structure and column names
-- Need CategoryName from Categories / ProductName and UnitPrice from Products
-- The common value to join the two tables will be the CategoryID
-- SELECT * FROM Categories
-- SELECT * FROM Products;

-- Select the desired columns from the two tables
-- SELECT CategoryName FROM Categories
-- SELECT ProductName,UnitPrice FROM Products;

-- Join the tables on the CategoryID value with an inner join
-- SELECT CategoryName, ProductName, UnitPrice
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID;

-- Add table aliases / Answer key spreadsheet doesn't use column aliases
-- SELECT C.CategoryName, P.ProductName, P.UnitPrice
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID;

-- Sort results by CategoryName
-- SELECT C.CategoryName, P.ProductName, P.UnitPrice
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- ORDER BY C.CategoryName;

-- Add a secondary sort by ProductName to get the final results for the SELECT statement for the View
-- SELECT C.CategoryName, P.ProductName, P.UnitPrice
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- ORDER BY C.CategoryName, P.ProductName;

-- Create the final vProductsByCategories view
GO
CREATE
VIEW vProductsByCategories
	AS 
		SELECT TOP 1000000000
    		C.CategoryName, 
    		P.ProductName, 
    		P.UnitPrice
		FROM 
    		vCategories AS C
		JOIN 
    		vProducts AS P
		ON 
    		C.CategoryID = P.CategoryID
		ORDER BY 
    		C.CategoryName, 
    		P.ProductName;
GO


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

-- Inspect the Product and Inventory Tables to see structure and column names
-- SELECT * FROM Products
-- SELECT * FROM Inventories;

-- The final results require the ProductName from Products and the Count & InventoryDate from Inventories
-- SELECT ProductName FROM Products
-- SELECT InventoryDate, [Count] FROM Inventories;

-- Join the above results on the common ProductID column with an inner join
-- SELECT ProductName, InventoryDate, [Count]
-- FROM Products
-- JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- Add table aliases / Answer key spreadsheet doesn't use column aliases
-- SELECT P.ProductName, I.InventoryDate, I.[Count]
-- FROM Products AS P
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID;

-- Sort results by Product Name
-- SELECT P.ProductName, I.InventoryDate, I.[Count]
-- FROM Products AS P
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY P.ProductName;

-- Sort results by Date
-- SELECT P.ProductName, I.InventoryDate, I.[Count]
-- FROM Products AS P
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY P.ProductName, I.InventoryDate;

-- Sort results by Count to achieve the final results for the view's SELECT statement
-- SELECT P.ProductName, I.InventoryDate, I.[Count]
-- FROM Products AS P
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY P.ProductName, I.InventoryDate, I.[Count];

-- Create the final view
GO
CREATE
VIEW vInventoriesByProductsByDates
	AS 
		SELECT TOP 1000000000
    		P.ProductName, 
    		I.InventoryDate, 
    		I.[Count]
		FROM 
    		vProducts AS P
		JOIN 
    		vInventories AS I
		ON 
    		P.ProductID = I.ProductID
		ORDER BY 
    		P.ProductName,
			I.InventoryDate, 
    		I.[Count];
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Inspect the Inventories and Employees tables for structure and column names
-- SELECT * FROM Inventories
-- SELECT * FROM Employees;

-- The final results will need the InventoryDate from Inventories and the two employee name columns from Employees
-- The connecting column between the two tables is the EmployeeID
-- SELECT InventoryDate FROM Inventories
-- SELECT EmployeeFirstName, EmployeeLastName FROM Employees;

-- Join the two tables together with an inner join on the EmployeeID column
-- SELECT InventoryDate, EmployeeFirstName, EmployeeLastName
-- FROM Inventories
-- JOIN Employees
-- ON Inventories.EmployeeID = Employees.EmployeeID;

-- Create a new EmployeeName column using an expression to join the first and last names
-- SELECT InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
-- FROM Inventories
-- JOIN Employees
-- ON Inventories.EmployeeID = Employees.EmployeeID;

-- Add table aliases / Answer key spreadsheet doesn't use column aliases
-- SELECT I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Inventories AS I
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID;

-- Order results by Date
-- SELECT I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Inventories AS I
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- ORDER BY I.InventoryDate;

-- Select the distinct results to only get one result per unique row
-- SELECT DISTINCT I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Inventories AS I
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- ORDER BY I.InventoryDate;

-- Create the final view
GO
CREATE
VIEW vInventoriesByEmployeesByDates
	AS 
		SELECT DISTINCT TOP 1000000000
            I.InventoryDate, 
            E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
        FROM 
            vInventories AS I
        JOIN 
            vEmployees AS E
        ON 
            I.EmployeeID = E.EmployeeID
        ORDER BY 
            I.InventoryDate;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

-- Inspect the Categories, Products, and Inventories tables for structure and columns
-- SELECT * FROM Categories
-- SELECT * FROM Products
-- SELECT * FROM Inventories;

-- Select the desired columns from each table for the final results
-- SELECT CategoryName FROM Categories
-- SELECT ProductName FROM Products
-- SELECT InventoryDate, [Count] FROM Inventories;

-- The final results will require two joins: Catories to Products and then those results to Inventories
-- Join Categories to Products with an inner join on CategoryID
-- SELECT CategoryName, ProductName
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID;

-- Join the above results to Inventories with an inner join on ProductID
-- SELECT CategoryName, ProductName, InventoryDate, [Count]
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- Add table aliases / Answer key spreadsheet doesn't use column aliases
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID;

-- Order results by Category
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY C.CategoryName;

-- Order results by Product
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY C.CategoryName, P.ProductName;

-- Order results by InventoryDate
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY C.CategoryName, P.ProductName, I.InventoryDate;

-- Order by Count to achieve the final results for the view's SELECT statement
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.[Count];

-- Create the final view
GO
CREATE
VIEW vInventoriesByProductsByCategories
	AS 
		SELECT TOP 1000000000
            C.CategoryName, 
            P.ProductName, 
            I.InventoryDate, 
            I.[Count]
        FROM 
            vCategories AS C
        JOIN 
            vProducts AS P
        ON 
            C.CategoryID = P.CategoryID
        JOIN 
            vInventories AS I
        ON 
            P.ProductID = I.ProductID
        ORDER BY 
            C.CategoryName, 
            P.ProductName, 
            I.InventoryDate, 
            I.[Count];
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan

-- Inspect the Categories, Products, Inventories, and Employees tables for structure and column names
-- SELECT * FROM Categories
-- SELECT * FROM Products
-- SELECT * FROM Inventories
-- SELECT * FROM Employees;

-- Select the desired columns from each table for the final results
-- SELECT CategoryName FROM Categories
-- SELECT ProductName FROM Products
-- SELECT InventoryDate, [Count] FROM Inventories
-- SELECT EmployeeFirstName, EmployeeLastName FROM Employees;

-- Create an expression for the EmployeeName by combining first name and last name
-- SELECT EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName FROM Employees;

-- Join Categories to Products with an inner join on the CategoryID
-- SELECT CategoryName, ProductName
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID;

-- Join the above results to Inventories with an inner join on Product ID
-- SELECT CategoryName, ProductName, InventoryDate, [Count]
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- Join the above results to Employees with an inner join on EmployeeID
-- SELECT CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID
-- JOIN Employees 
-- ON Inventories.EmployeeID = Employees.EmployeeID;

-- Create table aliases
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID;

-- Order results by InventoryDate
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- ORDER BY I.InventoryDate;

-- Order results by CategoryName
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- ORDER BY I.InventoryDate, C.CategoryName;

-- Order results by ProductName
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- ORDER BY I.InventoryDate, C.CategoryName, P.ProductName;

-- Order by EmployeeName to achieve the final results
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;

-- Create the final view
GO
CREATE
VIEW vInventoriesByProductsByEmployees
	AS 
		SELECT TOP 1000000000
            C.CategoryName, 
            P.ProductName, 
            I.InventoryDate, 
            I.[Count], 
            E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
        FROM 
            vCategories AS C
        JOIN 
            vProducts AS P
        ON 
            C.CategoryID = P.CategoryID
        JOIN 
            vInventories AS I
        ON 
            P.ProductID = I.ProductID
        JOIN 
            vEmployees AS E
        ON 
            I.EmployeeID = E.EmployeeID
        ORDER BY 
            I.InventoryDate, 
            C.CategoryName, 
            P.ProductName, 
            EmployeeName;
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

-- Inspect the Categories, Products, Inventories, and Employees tables for structure and column names
-- SELECT * FROM Categories
-- SELECT * FROM Products
-- SELECT * FROM Inventories
-- SELECT * FROM Employees;

-- Select the desired columns from each table for the final results
-- SELECT CategoryName FROM Categories
-- SELECT ProductName FROM Products
-- SELECT InventoryDate, [Count] FROM Inventories
-- SELECT EmployeeFirstName, EmployeeLastName FROM Employees;

-- Create an expression for the EmployeeName by combining first name and last name
-- SELECT EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName FROM Employees;

-- Join Categories to Products with an inner join on the CategoryID
-- SELECT CategoryName, ProductName
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID;

-- Join the above results to Inventories with an inner join on Product ID
-- SELECT CategoryName, ProductName, InventoryDate, [Count]
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- Join the above results to Employees with an inner join on EmployeeID
-- SELECT CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
-- FROM Categories
-- JOIN Products
-- ON Categories.CategoryID = Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID
-- JOIN Employees 
-- ON Inventories.EmployeeID = Employees.EmployeeID;

-- Create table aliases
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID;

-- Create the subquery that will limit the results to just 'Chai' and 'Chang' products
-- SELECT ProductID FROM Products WHERE ProductName IN ('Chai','Chang');

-- Add the subquery to the outer query using a WHERE clause
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- WHERE P.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai','Chang'));

-- Order results by InventoryDate
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- WHERE P.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai','Chang'))
-- ORDER BY I.InventoryDate;

-- Order the results by CategoryName
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- WHERE P.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai','Chang'))
-- ORDER BY I.InventoryDate, C.CategoryName;

-- Order by ProductName to achieve the final results for the view's SELECT statement
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- WHERE P.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai','Chang'))
-- ORDER BY I.InventoryDate, C.CategoryName, P.ProductName;

-- Create the final view
GO
CREATE
VIEW vInventoriesForChaiAndChangByEmployees
	AS 
		SELECT TOP 1000000000
            C.CategoryName, 
            P.ProductName, 
            I.InventoryDate, 
            I.[Count], 
            E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
        FROM 
            vCategories AS C
        JOIN 
            vProducts AS P
        ON 
            C.CategoryID = P.CategoryID
        JOIN 
            vInventories AS I
        ON 
            P.ProductID = I.ProductID
        JOIN 
            vEmployees AS E
        ON 
            I.EmployeeID = E.EmployeeID
        WHERE 
            P.ProductID IN 
                (SELECT ProductID FROM dbo.Products WHERE ProductName IN ('Chai','Chang'))
        ORDER BY 
            I.InventoryDate, 
            C.CategoryName, 
            P.ProductName;
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

-- Inspect the Employees table for structure and column names
-- SELECT * FROM Employees;

-- Create a column for Employee that will combine the first and last name fields
-- SELECT EmployeeID, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName, ManagerID FROM Employees;

-- Use a self join to match the ManagerID column with the corresponding manager name
-- SELECT * FROM Employees AS E JOIN Employees AS M ON E.ManagerID = M.EmployeeID;

-- Create column aliases to add clarity to the joined results
-- SELECT 
    -- M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager, 
    -- E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
-- FROM Employees AS E
-- JOIN Employees AS M
-- ON E.ManagerID = M.EmployeeID;

-- Order by manager name to achieve the final results for the view's SELECT statement
-- SELECT 
    -- M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager, 
    -- E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
-- FROM Employees AS E
-- JOIN Employees AS M
-- ON E.ManagerID = M.EmployeeID
-- ORDER BY Manager;

-- Create the final view. It appears that the results in the example above also inlude sorting my Employee, which is added
GO
CREATE
VIEW vEmployeesByManager
	AS 
		SELECT TOP 1000000000
            M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager, 
            E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
        FROM 
            vEmployees AS E
        JOIN 
            vEmployees AS M
        ON 
            E.ManagerID = M.EmployeeID
        ORDER BY 
            Manager, Employee;
GO


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

-- Inspect all of the involved tables for structure and column names
-- SELECT * FROM Categories;
-- SELECT * FROM Products;
-- SELECT * FROM Inventories;
-- SELECT * FROM Employees;

-- Complete the first join for the Categories and Products tables on the CategoryID field
-- SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- ORDER BY C.CategoryID, P.ProductID;

-- Join this data to the Inventories Table on the common ProductID field between Products and Inventories
-- SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.[Count]
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY C.CategoryID, P.ProductID, I.InventoryID;

-- Join this data to the Employees Table on the common EmployeeID field between Inventories and Employees
-- SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.[Count], E.EmployeeID, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- ORDER BY C.CategoryID, P.ProductID, I.InventoryID, E.EmployeeID;

-- Join this data again to the Employeess Table to get the Manager name
-- SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.[Count], E.EmployeeID, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee, M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
-- FROM Categories AS C
-- JOIN Products AS P
-- ON C.CategoryID = P.CategoryID
-- JOIN Inventories AS I
-- ON P.ProductID = I.ProductID
-- JOIN Employees AS E
-- ON I.EmployeeID = E.EmployeeID
-- JOIN Employees AS M
-- ON E.ManagerID = M.EmployeeID
-- ORDER BY C.CategoryID, P.ProductID, I.InventoryID, E.EmployeeID;

-- Create the final view
GO
CREATE
VIEW vInventoriesByProductsByCategoriesByEmployees
	AS 
		SELECT TOP 1000000000 
            C.CategoryID, 
            C.CategoryName, 
            P.ProductID, 
            P.ProductName, 
            P.UnitPrice, 
            I.InventoryID, 
            I.InventoryDate, 
            I.[Count], 
            E.EmployeeID, 
            E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee,
            M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
        FROM 
            vCategories AS C
        JOIN 
            vProducts AS P
        ON 
            C.CategoryID = P.CategoryID
        JOIN 
            vInventories AS I
        ON 
            P.ProductID = I.ProductID
        JOIN 
            vEmployees AS E
        ON 
            I.EmployeeID = E.EmployeeID
        JOIN 
            vEmployees AS M
        ON 
            E.ManagerID = M.EmployeeID
        ORDER BY 
            C.CategoryID, 
            P.ProductID, 
            I.InventoryID, 
            E.EmployeeID;
GO


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/