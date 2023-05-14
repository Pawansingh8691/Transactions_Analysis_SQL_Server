-- First of all I created these 04 table (Customers, Branches, Accounts, Transactions) and then did my analysis using SQL Server.
==================================================================================================================

CREATE TABLE Customers (
				CustomerID INT PRIMARY KEY
				,FirstName VARCHAR(50) NOT NULL
				,LastName VARCHAR(50) NOT NULL
				,City VARCHAR(50) NOT NULL
				,State VARCHAR(2) NOT NULL
				);

INSERT INTO Customers (CustomerID, FirstName, LastName, City, State)
			VALUES (1, 'John', 'Doe', 'New York', 'NY')
				,(2, 'Jane', 'Doe', 'New York', 'NY')
				,(3, 'Bob', 'Smith', 'San Francisco', 'CA')
				,(4, 'Alice', 'Johnson', 'San Francisco', 'CA')
				,(5, 'Michael', 'Lee', 'Los Angeles', 'CA')
				,(6, 'Jennifer', 'Wang', 'Los Angeles', 'CA'
				);

==================================================================================================================

CREATE TABLE Branches (
				BranchID INT PRIMARY KEY
				,BranchName VARCHAR(50) NOT NULL
				,City VARCHAR(50) NOT NULL
				,State VARCHAR(2) NOT NULL
				);

INSERT INTO Branches (BranchID, BranchName, City, State)
			VALUES (1, 'Main', 'New York', 'NY')
				,(2, 'Downtown', 'San Francisco', 'CA')
				,(3, 'West LA', 'Los Angeles', 'CA')
				,(4, 'East LA', 'Los Angeles', 'CA')
				,(5, 'Uptown', 'New York', 'NY')
				,(6, 'Financial District', 'San Francisco', 'CA')
				,(7, 'Midtown', 'New York', 'NY')
				,(8, 'South Bay', 'San Francisco', 'CA')
				,(9, 'Downtown', 'Los Angeles', 'CA')
				,(10, 'Chinatown', 'New York', 'NY')
				,(11, 'Marina', 'San Francisco', 'CA')
				,(12, 'Beverly Hills', 'Los Angeles', 'CA')
				,(13, 'Brooklyn', 'New York', 'NY')
				,(14, 'North Beach', 'San Francisco', 'CA')
				,(15, 'Pasadena', 'Los Angeles', 'CA'
				);

==================================================================================================================

CREATE TABLE Accounts (
				AccountID INT PRIMARY KEY
				,CustomerID INT NOT NULL
				,BranchID INT NOT NULL
				,AccountType VARCHAR(50) NOT NULL
				,Balance DECIMAL(10, 2) NOT NULL
				,FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
				,FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
				);

INSERT INTO Accounts (AccountID, CustomerID, BranchID, AccountType, Balance)
			VALUES (1, 1, 5, 'Checking', 1000.00)
				,(2, 1, 5, 'Savings', 5000.00)
				,(3, 2, 1, 'Checking', 2500.00)
				,(4, 2, 1, 'Savings', 10000.00)
				,(5, 3, 2, 'Checking', 7500.00)
				,(6, 3, 2, 'Savings', 15000.00)
				,(7, 4, 8, 'Checking', 5000.00)
				,(8, 4, 8, 'Savings', 20000.00)
				,(9, 5, 14, 'Checking', 10000.00)
				,(10, 5, 14, 'Savings', 50000.00)
				,(11, 6, 2, 'Checking', 5000.00)
				,(12, 6, 2, 'Savings', 10000.00)
				,(13, 1, 5, 'Credit Card', -500.00)
				,(14, 2, 1, 'Credit Card', -1000.00)
				,(15, 3, 2, 'Credit Card', -2000.00);

==================================================================================================================

CREATE TABLE Transactions (
					TransactionID INT PRIMARY KEY
					,AccountID INT NOT NULL
					,TransactionDate DATE NOT NULL
					,Amount DECIMAL(10, 2) NOT NULL
					,FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
					);

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount)
				VALUES (1, 1, '2022-01-01', -500.00)
					,(2, 1, '2022-01-02', -250.00)
					,(3, 2, '2022-01-03', 1000.00)
					,(4, 3, '2022-01-04', -1000.00)
					,(5, 3, '2022-01-05', 500.00)
					,(6, 4, '2022-01-06', 1000.00)
					,(7, 4, '2022-01-07', -500.00)
					,(8, 5, '2022-01-08', -2500.00)
					,(9, 6, '2022-01-09', 500.00)
					,(10, 6, '2022-01-10', -1000.00)
					,(11, 7, '2022-01-11', -500.00)
					,(12, 7, '2022-01-12', -250.00)
					,(13, 8, '2022-01-13', 1000.00)
					,(14, 8, '2022-01-14', -1000.00)
					,(15, 9, '2022-01-15', 500.00
					);


-- Questions:

==================================================================================================================

-- 1. What are the names of all the customers who live in New York?

SELECT CONCAT(Customers.FirstName, ' ', Customers.LastName) AS Customer_Name
FROM Customers
WHERE Customers.City = 'New York';

==================================================================================================================

-- 2. What is the total number of accounts in the Accounts table?

SELECT COUNT(Accounts.AccountID) AS 'Total Accounts'
FROM Accounts;

==================================================================================================================

-- 3. What is the total balance of all checking accounts?

SELECT SUM(Accounts.Balance) AS 'Total Balance'
FROM Accounts
WHERE Accounts.AccountType = 'Checking';

==================================================================================================================

-- 4. What is the total balance of all accounts associated with customers who live in Los Angeles?

SELECT SUM(Accounts.Balance) AS 'Total Balance'
FROM Accounts
WHERE Accounts.CustomerID IN (
					SELECT Customers.CustomerID
					FROM Customers
					WHERE Customers.City = 'Los Angeles');
==================================================================================================================

-- 5. Which branch has the highest average account balance?

WITH CTE AS (
		SELECT Accounts.BranchID
			,Branches.BranchName
			,COUNT(Accounts.BranchID) AS 'Total_Branches'
			,SUM(Accounts.Balance) AS 'Total_Balance'
			,ROUND(SUM(Accounts.Balance) / COUNT(Accounts.BranchID),0) AS 'Average_Balance'
		FROM Accounts
		INNER JOIN Branches ON
		Accounts.BranchID = Branches.BranchID
		GROUP BY Accounts.BranchID, Branches.BranchName
		)
SELECT BranchName 
FROM CTE
WHERE Average_Balance = (SELECT MAX(Average_Balance) FROM CTE);

==================================================================================================================

-- 6. Which customer has the highest current balance in their accounts?

WITH Max_Balance AS (
				SELECT Accounts.CustomerID
					,CONCAT(Customers.FirstName, ' ', Customers.LastName) AS Customer_Name
					,SUM(Accounts.Balance) AS Total_Balance
				FROM Accounts
				INNER JOIN Customers ON
				Accounts.CustomerID = Customers.CustomerID
				GROUP BY Accounts.CustomerID
				,CONCAT(Customers.FirstName, ' ', Customers.LastName)
				ORDER BY Total_Balance DESC
				OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
			)
SELECT Customer_Name FROM Max_Balance;

==================================================================================================================

-- 7. Which customer has made the most transactions in the Transactions table?

WITH Most_Transactions AS (
					SELECT Transactions.AccountID
						,Accounts.CustomerID
						,CONCAT(Customers.FirstName, ' ', Customers.LastName) AS Customer_Name
						,Count(Transactions.AccountID) AS Total_Transactions
					FROM Transactions
					INNER JOIN Accounts ON
					Transactions.AccountID = Accounts.AccountID
					INNER JOIN Customers ON
					Customers.CustomerID = Accounts.CustomerID
					GROUP BY Transactions.AccountID, Accounts.CustomerID,
					CONCAT(Customers.FirstName, ' ', Customers.LastName)
					ORDER BY Total_Transactions DESC
					OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
				)
SELECT Customer_Name FROM Most_Transactions;

==================================================================================================================

-- 8.Which branch has the highest total balance across all of its accounts?


WITH Highest_Balance AS (
					SELECT Accounts.BranchID
						,Branches.BranchName
						,MAX(accounts.balance) AS Highest_Balance
					FROM Accounts
					INNER JOIN Branches ON
					Accounts.BranchID = Branches.BranchID
					GROUP BY Accounts.BranchID, Branches.BranchName
					ORDER BY Highest_Balance DESC
					OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
				)
SELECT BranchName FROM Highest_Balance;

==================================================================================================================

-- 9. Which customer has the highest total balance across all of their accounts, including savings and checking accounts?


WITH Highest_Total_Balance AS (
						SELECT CONCAT(Customers.FirstName, ' ', Customers.LastName) AS Customer_Name
							,SUM(CASE WHEN Accounts.Balance > 0 THEN Accounts.Balance ELSE 0 END)									AS Total_Balance
						FROM Customers
						INNER JOIN Accounts ON
						Customers.CustomerID = Accounts.CustomerID
						GROUP BY CONCAT(Customers.FirstName, ' ', Customers.LastName)
						ORDER BY Total_Balance DESC
						OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
					)
SELECT Customer_Name FROM Highest_Total_Balance;

==================================================================================================================

-- 10. Which branch has the highest number of transactions in the Transactions table?

WITH Branch_With_Most_Transactions AS (
							SELECT Accounts.BranchID
								COUNT(Transactions.AccountID) AS Total_Transactions
								,Branches.BranchName
							FROM Transactions
							INNER JOIN Accounts ON
							Transactions.AccountID = Accounts.AccountID
							INNER JOIN Branches ON
							Accounts.BranchID = Branches.BranchID
							GROUP BY Accounts.BranchID, Branches.BranchName
							ORDER BY Total_Transactions DESC
							OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
						)
SELECT BranchName FROM Branch_With_Most_Transactions;

==================================================================================================================

Thanks.
				