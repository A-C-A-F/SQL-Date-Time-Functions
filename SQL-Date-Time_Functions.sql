###############################################################
###############################################################
-- Project: SQL Date-Time Functions
###############################################################
###############################################################

-- Personal note: I used the database employees_ser7 for this project.

#############################
-- Task One: Getting Started
-- In this task, we will retrieve data from the tables in the
-- employees database
#############################

-- 1.1: Retrieve all the data in the employees, sales, dept_manager, salaries table
SELECT * FROM employees;
SELECT * FROM sales;
SELECT * FROM dept_manager;
SELECT * FROM salaries;
#############################
-- Task Two: Current Date & Time
-- In this task, we will learn how to use a number of functions 
-- that return values related to the current date and time. 
#############################

/*
CURRENT_DATE delivers the current date. CURRENT_TIME delivers values with timezone. 
CURRENT_TIME optionally takes a precision parameter, which causes the results to be rounded to that 
many fractional digits in the second field. CURRENT_TIMESTAMP delivers values with timezones also, 
just like CURRENT_TIME. It also takes a precision parameter, which also causes the result to be rounded 
up to the number of digits in the seconds field that you specify.
*/

-- 2.1: Retrieve the current date
SELECT CURRENT_DATE; --this will return the current date when this was executed.

-- 2.2: Retrieve the current time
SELECT CURRENT_TIME; --this will return the current time when this was executed.

--- Let's try putting a precision parameter.
SELECT CURRENT_TIME(1); -- the (1) specifies the number of digit after the seconds (microseconds)

SELECT CURRENT_TIME(3); -- the result of this is 3 digits after the seconds.

-- 2.3: Retrieve the current timestamp
SELECT CURRENT_TIMESTAMP; -- this one returns the date and the time.

-- 2.4: Retrieve the current date, current date, time, and timestamp
SELECT CURRENT_DATE, CURRENT_TIME, CURRENT_TIME(1), CURRENT_TIME(3), CURRENT_TIMESTAMP;
/* After running this code, you will get the information in table format. */

/* 
PostgreSQL also provides functions that return that time of the
current statement as well as the actual current time as at
the instant the function is called, these are called non-SQL
standard time functions. See queries in 2.5.
*/

-- 2.5: Retrieve the time of the day
SELECT transaction_timestamp();
SELECT timeofday(); -- this will return timestamp in text format
SELECT now();

#############################
-- Task Three: AGE() - Part One
-- In this task, we will learn how to use the AGE() function to subtract arguments, 
-- producing a "symbolic" result that uses years and months
#############################

/* 
In this task, we will learn how to use the AGE() function to subtract arguments,
producing a symbolic result that uses years and months.

AGE() subtracts arguments. So, AGE can take two time stamps or just
one time stamp. When invoked with two timestamps, that is there
is a second timestamp as the second argument, AGE subtracts
arguments, producing a symbolic result that uses years and
months, and it's a type of interval.
When you specify only one time stamp or year, what AGE does is
that it invokes this timestamp as an argument and AGE 
subtracts this from the current date, that is, at midnight.
*/

-- 3.1: Check the difference between February 28th, 2021 and December 31st, 2019
SELECT AGE('2021-02-28', '2019-12-31');
/* The result of this query is below:
"1 year 1 mon 28 days"
*/

-- 3.2: How old is the Batman movie that was released March 30, 1939
SELECT AGE(CURRENT_DATE, '1939-03-30') AS Batman_Age;
/* 
This shows that the difference between the current date and this
year that this movie was released is 83 years and 2 months and 25 days. 
So, it gives that granularity in the dates.
*/

-- 3.3: Retrieve a list of the current age of all employees
SELECT * FROM employees;

SELECT first_name, last_name, birth_date, AGE(CURRENT_DATE, birth_date) AS Age
FROM employees;

-- 3.4: Retrieve a list of all employees ages as at when they were employed
SELECT first_name, last_name, birth_date, hire_date, AGE(hire_date, birth_date) AS Age_Employed
FROM employees;

-- 3.5: Retrieve a list of how long a manager worked at the company
SELECT * FROM dept_manager;

SELECT emp_no, AGE(to_date, from_date) AS Age
FROM dept_manager;
/*
This will retrieved a table of manager and length of their work in the company.
If we see a result of 8007 year, that could mean that the employee is still employed.
*/

-- 3.6: Retrieve a list of how long a manager have been working at the company
SELECT emp_no, AGE(CURRENT_DATE, from_date) AS Age
FROM dept_manager
WHERE emp_no IN ('110039', '110114', '110228', '110420', '110567', '110854', '111133', '111534','111939'); 
-- these emp nos., I looked up in the table before who are still employed.
/*
After running the query above, it will show us how many
years that a particular manager has been working for in this
department manager table.
*/


#############################
-- Task Four: AGE() - Part Two
-- In this task, we will learn how the AGE() function to subtract arguments, 
-- producing a "symbolic" result that uses years and months
#############################

/*
We'll take it a step further in the use of AGE function
to subtract arguments. We know what the AGE function does by now, as we have seen
in task three. We remember in task three, we were trying to retrieve a
list of how long a manager worked at the company, however, we saw
that it didn't give us the exact results that we want.
Let's solve that issue now. We will employ the use of the CASE
statement to solve this problem.
*/

-- 4.1: Retrieve a list of how long a manager worked at the company
SELECT emp_no,
CASE
	WHEN AGE(to_date, from_date) < AGE(CURRENT_DATE, from_date) THEN AGE(to_date, from_date)
	ELSE AGE(CURRENT_DATE, from_date)
END
FROM dept_manager;
/*
Now, we would see that we do not have 8000 plus years like we have before.
*/

-- 4.2: Retrieve a list of how long it took to ship a product to a customer
SELECT * FROM sales;

SELECT order_line, ordeR_date, ship_date, AGE(ship_date, order_date) AS time_taken
FROM sales
ORDER BY time_taken DESC;
/*
Note: We can save a copy in csv format of every query result we get. By clicking the "Save results to file" button
or by pressing F8.
*/

-- 4.3: Retrieve all the data from the salaries table
SELECT * FROM salaries;


-- 4.4: Retrieve a list of the first name, last name, salary 
-- and how long the employee earned that salary
SELECT e.first_name, e.last_name, s.salary, s.from_date, s.to_date, AGE(s.to_date, s.from_date)
FROM employees e
JOIN salaries s
ON e.emp_no = s.emp_no;

-- A better result
SELECT e.first_name, e.last_name, s.salary, s.from_date, s.to_date,
CASE
	WHEN AGE(to_date, from_date) < AGE(CURRENT_DATE, from_date) THEN AGE(to_date, from_date)
	ELSE AGE(CURRENT_DATE, from_date)
END 
FROM employees e
JOIN salaries s
ON e.emp_no = s.emp_no;

#############################
-- Task Five: EXTRACT() - Part One
-- In this task, we will see how the EXTRACT() function 
-- to retrieve subfields like year or hour from date/time values
#############################

/*
The EXTRACT function basically extracts the field from a source which is very similar to the way DATE_PART() function
retrieves subfields as years or hour from date time values. The source must be a value expression of type
that is timestamp, time or an interval. The field is an identifier or string that selects what part
to extract from the source value. The EXTRACT function returns values of type, double precision. 
It's similar to the DATE_PART() function.
The following are valid field names that is similar to the DATE_PART() functions field names. 
We can retrieve:
- century from a date or from a time,
- day, decade, day of the week,
- day of the year, epoch, hour, microseconds,
- millennium, milliseconds, minutes, month, quarter,
- second, timezone, timezone hour, timezone
- minute, week, or year. 
*/

-- 5.1: Extract the day of the month from the current date
SELECT EXTRACT(DAY FROM CURRENT_DATE);

-- 5.2: Extract the day of the week from the current date
SELECT EXTRACT(ISODOW FROM CURRENT_DATE);
/*
1 represents Monday,
2 represents Tuesday,
so on and so forth...
*/

-- 5.3: Extract the hour of the day from the current date
SELECT CURRENT_TIMESTAMP, EXTRACT(HOUR FROM CURRENT_TIMESTAMP);
/* This will return a table with two columns where the 2nd column will show the extracted hour from the timestamp.*/

-- 5.4: Extract the day from a date.
SELECT EXTRACT(DAY FROM DATE('2019-12-31'));

-- 5.5: Extract the year from a date.
SELECT EXTRACT(YEAR FROM DATE('2019-12-31'));

-- 5.6: Extract minute from a time.
SELECT EXTRACT(MINUTE from '084412'::TIME); -- the 084412 can be red as 08:44:12.

-- 5.7: Retrieve a list of the ship mode and how long (in seconds) it took to ship a product to a customer
/* Note: Since th question is how long in seconds, EPOCH is used to retrieve the seconds.*/
SELECT order_line, order_date, ship_date,
(EXTRACT(EPOCH FROM ship_date) - EXTRACT(EPOCH FROM order_date)) AS  secs_taken
FROM sales;
/*
What this does is, it extracts
the seconds from ship date, keeps that value and then minus, it
extracts or EPOCH or the seconds from the order_date and
then checks the difference in the seconds.
That's because we can now do numerical calculation on that
value. We will see the secs_taken column, we can check the hour, check the day,
by dividing by the appropriate measure. And so we can perform mathematical operations 
on this sec_taken column unlike AGE. And that's difference between EXTRACT and AGE.
*/


-- 5.8: Retrieve a list of the ship mode and how long (in days) it took to ship a product to a customer
SELECT order_line, order_date, ship_date, ship_mode,
(EXTRACT(DAY FROM ship_date) - EXTRACT(DAY FROM order_date)) AS days_taken
FROM sales
ORDER BY days_taken DESC;

-- 5.9: Retrieve a list of the current age of all employees
SELECT first_name, last_name, birth_date,
(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date)) AS emp_age
FROM employees;


-- 5.10: Retrieve a list of the current age of all employees
SELECT first_name, last_name, birth_date, 
(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date)) || ' years' AS emp_age
FROM employees;
/*
What we did in this last part here is to just concatenate
the extracted value by adding years to it using double pipe function.
*/

#############################
-- Task Six: EXTRACT() - Part Two
-- In this task, we will see how the EXTRACT() function 
-- to retrieve subfields like year or hour from date/time values
#############################

-- 6.1: Retrieve a list of all employees ages as at when they were employed
SELECT first_name, last_name, birth_date, hire_date,
(EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date)) AS Age_Employed
FROM employees;

-- 6.2: Retrieve a list of all employees who were 25 or less than 25 years as at when they were employed
SELECT first_name, last_name, birth_date, hire_date, 
(EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date)) AS Employed_25
FROM employees
WHERE (EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date)) <= 25;

-- 6.3: How many employees were 25 or less than 25 years as at when they were employed
SELECT COUNT((EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date))) AS Num_employed_25
FROM employees
WHERE (EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date)) <= 25;
/* This will give us a result of 1585. It just counted the number of rows we retrieved prior this query.*/

-- 6.4: What do you think will be the result of this query?
SELECT (EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date)) || ' years' AS Age_group,
COUNT((EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date))) AS Num_Employed -- this will count how many people employed of the same age group.
FROM employees
WHERE (EXTRACT(YEAR FROM hire_date) - EXTRACT(YEAR FROM birth_date)) <= 25
GROUP BY age_group
ORDER BY age_group;

-- 6.5: Retrieve all data from the sales table
SELECT * FROM sales;

-- 6.6: Retrieve a list of the product_id, the month of sales and sales
-- for chair sub category in the year 2015
SELECT product_id, sub_category, (EXTRACT(MONTH FROM ship_date)) AS sales_month, sales
FROM sales
WHERE sub_category = 'Chairs' AND order_id LIKE '%2015%';


-- 6.7: Retrieve a list of the month of sales and sum of sales
-- for each month for chair sub category in the year 2015
SELECT (EXTRACT(MONTH FROM ship_date)) AS sales_month, SUM(sales)
FROM sales
WHERE sub_category = 'Chairs' AND order_id LIKE '%2015%'
GROUP BY sales_month
ORDER BY sales_month;


#############################
-- Task Seven: Converting Date to Strings
-- In this task, we will see how to convert dates to strings
#############################

/*
TO_CHAR function converts a number or date to a string.
Often, you don't want to show the full raw timestamp but rather
a nicely formatted, potentially truncated version. TO_CHAR takes
two arguments. The value and the format mask. The value is the field
or the column. Then, the format mask, we have several of these format masks.
For example, Y, YY, YYY, four Y's in capital letter signifies four-digit years, 
M, M signifies months in numbers like zero representing January.
Mon in abbreviation represents the abbreviated name
of the month and so on. Day, for example- if we write DD
for example, the format says I want the day of the month
in numbers. So, 01 for the first day of the month,
31 for the last day of the month and so on.
*/

-- 7.1: Change the order date in the sales table to strings
SELECT order_date, TO_CHAR(order_date, 'MMDDYY')
FROM sales;

--- we can put a slash "/"
SELECT order_date, TO_CHAR(order_date, 'MM/DD/YY')
FROM sales;

-- 7.2: Change the order date in the sales table to strings
SELECT order_date, TO_CHAR(order_date, 'Month DD, YYYY')
FROM sales;

--- we can add suffix to the date
SELECT order_date, TO_CHAR(order_date, 'Month FMDDth, YYYY')
FROM sales;

-- 7.3: Change the order date in the sales table to strings
SELECT order_date, TO_CHAR(order_date, 'Month Day, YYYY') -- this will print the Day of the week and not the date of the month
FROM sales;

-- 7.4: Query same above but upper case the DAY
SELECT order_date, TO_CHAR(order_date, 'Month DAY, YYYY') -- same above but will be CAPITALIZED.
FROM sales;

-- 7.5: Query the day of the week, month, numeric date and 4 digit year
SELECT *, TO_CHAR(hire_date, 'Day, Month DD YYYY') AS hired_date
FROM employees;

-- 7.6: Retrieve a list of the month of sales and sum of sales
-- for each month for chair sub category in the year 2015
SELECT TO_CHAR(ship_date, 'Month') AS full_sales_month, SUM(sales) AS monthly_total
FROM sales
WHERE sub_category = 'Chairs' AND order_id LIKE '%2015%'
GROUP BY full_sales_month
ORDER BY full_sales_month;

-- 7.7: Retrieve a list of the month of sales and sum of sales
-- for each month in the right order for chair sub category in the year 2015
SELECT EXTRACT(MONTH FROM ship_date) AS sales_month,
TO_CHAR(ship_date, 'Month') AS full_sales_month, SUM(sales) AS monthly_total
FROM sales
WHERE sub_category = 'Chairs' AND order_id LIKE '%2015%'
GROUP BY full_sales_month, sales_month
ORDER BY sales_month;

-- 7.8: Add a currency (dollars) to the sum of monthly sales
SELECT EXTRACT(MONTH FROM ship_date) AS sales_month, 
TO_CHAR(ship_date, 'Month') AS full_sales_month, TO_CHAR(SUM(sales), 'L99999.99') AS monthly_total -- the L is an alternative to dollar sign. I put the L99999.99 to reduce the decimal number. The number 9 here means that I checked that one of the values has that kind of count.
FROM sales
WHERE sub_category = 'Chairs' AND order_id LIKE '%2015%'
GROUP BY full_sales_month, sales_month
ORDER BY sales_month;
/* Note that when using
functions within other functions, it is important to remember
that the innermost functions will be evaluated first and then
followed by the functions that encapsulate it.
*/


#############################
-- Task Eight: Converting Strings to Date
-- In this task, we will see how to convert strings to dates
#############################

-- 8.1: Change '2019/12/31' to the correct date format
SELECT TO_DATE('2019/12/31', 'YYYY/MM/DD');

-- 8.2: Change '20191231' to the correct date format
SELECT TO_DATE('20191231', 'YYYYMMDD');

-- 8.3: Change '191231' to the correct date format
SELECT TO_DATE('191231', 'YYMMDD');

-- 8.4: Change '123119' to the correct date format
SELECT TO_DATE('123119', 'MMDDYY');

-- 8.5: Retrieve all the data from the employees table
SELECT * FROM employees;

-- Start transaction
BEGIN;
/* Any transactions here will be temporarily applied to my table but not necessarily commit it to the table.
When performing ALTER function, SQL commits it automatically to the table. But by using BEGIN, this will not be committed.
We just have to use ROLLBACK function to use the original values in our table.
*/

ALTER TABLE employees
ALTER COLUMN hire_date TYPE CHAR(10);

SELECT * FROM employees;

-- Change the hire_date to a correct date format
SELECT *, TO_DATE(hire_date, 'YYYY-MM-DD') AS hire_date
FROM employees;

-- End the transaction
ROLLBACK;