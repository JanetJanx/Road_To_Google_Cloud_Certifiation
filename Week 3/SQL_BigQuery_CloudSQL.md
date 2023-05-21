# SQL for BigQuery and CloudSQL
SQL (Structured Query Language) is a standard language for data operations that allows you to ask questions and get insights from structured datasets. 

It's commonly used in database management and allows you to perform tasks like transaction record writing into relational databases and petabyte-scale data analysis.

## Objectives
1. Distinguish databases from tables and projects.
2. Use the SELECT, FROM, and WHERE keywords to construct simple queries.
3. Identify the different components and hierarchies within the BigQuery console.
4. Load databases and tables into BigQuery.
5. Execute simple queries on tables.
6. Learn about the COUNT, GROUP BY, AS, and ORDER BY keywords.
7. Execute and chain the above commands to pull meaningful data from datasets.
8. Export a subset of data into a CSV file and store that file into a new Cloud Storage bucket.
9. Create a new Cloud SQL instance and load your exported CSV file as a new table.
10. Run CREATE DATABASE, CREATE TABLE, DELETE, INSERT INTO, and UNION queries in Cloud SQL.

### Task 1. The basics of SQL: Databases and Tables
Structured datasets have clear rules and formatting and often times are organized into tables, or data that's formatted in rows and columns.

Unstructured data is inoperable with SQL and cannot be stored in BigQuery datasets or tables. An example of unstructured data would be an image file.

##### NB: A Database is essentially a collection of one or more tables. SQL is a structured database management tool

#### Keywords
1. Use SELECT to specify what fields you want to pull from your dataset.
2. Use FROM to specify what table or tables we want to pull our data from.
```
SELECT USER FROM example_table
SELECT USER, SHIPPED FROM example_table
```
3. Use WHERE to filter tables for specific column values
```
SELECT USER FROM example_table WHERE SHIPPED='YES'
```

### Task 2. Exploring the BigQuery console
BigQuery is a fully-managed petabyte-scale data warehouse that runs on the Google Cloud. 

Data analysts and data scientists can quickly query and filter large datasets, aggregate results, and perform complex operations without having to worry about setting up and managing servers.

##### NB: In BigQuery, projects contain datasets, and datasets contain tables.

#### Use the steps below to pull publicly accessible project that contains datasets and tables into BigQuery for analysis
1. Go to Navigation menu > BigQuery and click "Add"
2. Choose Star a project by name.
3. Enter project name of choice and click STAR. #NB: you didn't switch over to that project.
4. You now have access to:-
    - Google Cloud Project → bigquery-public-data
    - Dataset → london_bicycles
5. Using the data from cycle_hire. Open the cycle_hire table, then click the Preview tab

### Task 3. More SQL Keywords: GROUP BY, COUNT, AS, and ORDER BY
1. GROUP BY: aggregates result-set rows that share common criteria (e.g. a column value) and will return all of the unique entries found for such criteria. GROUP BY will output the unique column values found in the table.
```
SELECT start_station_name FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY start_station_name;
```
2.  COUNT(): a function that will return the number of rows that share the same criteria (e.g. column value). This can be very useful in tandem with a GROUP BY.
```
SELECT start_station_name, COUNT(*) FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY start_station_name;
```

3. AS: creates an alias of a table or column. An alias is a new name that's given to the returned column or table—whatever AS specifies.
```
SELECT start_station_name, COUNT(*) AS num_starts FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY start_station_name;
```
4. ORDER BY: sorts the returned data from a query in ascending or descending order based on a specified criteria or column value.
```
SELECT start_station_name, COUNT(*) AS num FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY start_station_name ORDER BY start_station_name;

SELECT start_station_name, COUNT(*) AS num FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY start_station_name ORDER BY num;

SELECT start_station_name, COUNT(*) AS num FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY start_station_name ORDER BY num DESC;
```

### Task 4. Working with Cloud SQL
Cloud SQL is a fully-managed database service that makes it easy to set up, maintain, manage, and administer your relational PostgreSQL and MySQL databases in the cloud.
Data formats accepted by Cloud SQL:
    - dump files (.sql)
    - CSV files (.csv).
Let's get some data from Bigquery in acceptable Cloud SQL Formats and upload it to Cloud Storage
1. Run the command below:
```
SELECT start_station_name, COUNT(*) AS num FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY start_station_name ORDER BY num DESC;

SELECT end_station_name, COUNT(*) AS num FROM `bigquery-public-data.london_bicycles.cycle_hire` GROUP BY end_station_name ORDER BY num DESC;
```
2. For each query result, click SAVE RESULTS > CSV(local file).

#### Upload CSV files to Cloud Storage
1. Go Navigation menu > Cloud Storage > Buckets, and then click CREATE BUCKET. # NB: If prompted, click LEAVE for Unsaved work.
2. Enter a unique bucket name of choice, keep all other settings as default, and click Create.
3. Click Confirm for Public access will be prevented dialog.
4. Click UPLOAD FILES and select the CSV files that contained the data you downloaded from BigQuery.
5. Rename the files accordingly as directed in the lab instructions

### Task 5. Create a Cloud SQL instance
Follow the steps below:-
1. select Navigation menu > SQL and click CREATE INSTANCE > Choose MySQL 
2. Enter instance id [given name] / name of your choice for cases outside this lab
3. Enter a secure password in the Password field. Recommend use of the Generate option. Make sure you rememberit.
4. Select the database version [given in the lab] / version of your choice for cases outside this lab
5. For lab region, set the Multi zones (Highly available)
6. Click CREATE INSTANCE.
Wait between 3 - 5 minutes. Once it is ready, you will see a green checkmark next to the instance name.

### Task 6. New queries in Cloud SQL
Our Cloud SQL instance is now up. Let's create a database inside of it using the Cloud Shell Command Line and the run some queries.
1. Copy the Cloud Shell link below and paste in a new browser incognito tab.
```
https://shell.cloud.google.com/?show=terminal
```
2. Set your project ID:
```
gcloud config set project [PROJECT_ID]
```
3. Setup gcloud auth without opening up a browser, open the generated link and cope the authentication code
```
gcloud auth login --no-launch-browser
```
4. Configure your project
```
gcloud config set project [PROJECT_ID]
```
5. Connect to our SQL instance. NB: It may take a minute to connect to your instance. When prompted, enter the root password you set for the instance
```
gcloud sql connect <SQL Instance Name> --user=root --quiet
```
6. Create database named [given lab name] and two tables inside that database using the given names
```
CREATE DATABASE bike;
USE bike;
CREATE TABLE london1 (start_station_name VARCHAR(255), num INT);
CREATE TABLE london2 (end_station_name VARCHAR(255), num INT);
```
7. Confirm the newly created tables are empty
```
SELECT * FROM london1;
SELECT * FROM london2;
```
8. Return to the Cloud SQL console. Upload the start_station_name and end_station_name CSV files into your newly created london1 and london2 tables following the lab instructions below for each file
    - In your Cloud SQL instance page, click IMPORT.
    - click Browse, and then click the arrow next to your bucket name, and then click start_station_data.csv. Click Select.
    - Select CSV as File format.
    - Select the bike database and type in "london1" as your table.
    - Click Import.

9. Confirm the newly added content in the tables
```
SELECT * FROM london1;
SELECT * FROM london2;
```

#### More SQL keywords that help us with data management.
1. DELETE keyword:
    - delete the first row of the london1 and london2:
    ```
    DELETE FROM london1 WHERE num=0;
    DELETE FROM london2 WHERE num=0;
    ```
2. INSERT INTO keyword:
    - insert a new row into london1, which sets start_station_name to "test destination" and num to "1":
    ```
    INSERT INTO london1 (start_station_name, num) VALUES ("test destination", 1);
    ```
3. UNION keyword: combines the output of two or more SELECT queries into a result-set.
    ```
    SELECT start_station_name AS top_stations, num FROM london1 WHERE num>100000
    UNION
    SELECT end_station_name, num FROM london2 WHERE num>100000
    ORDER BY top_stations DESC;
    ```
Note:
The first SELECT query selects the two columns from the "london1" table and creates an alias for "start_station_name", which gets set to "top_stations". It uses the WHERE keyword to only pull rideshare station names where over 100,000 bikes start their journey.

The second SELECT query selects the two columns from the "london2" table and uses the WHERE keyword to only pull rideshare station names where over 100,000 bikes end their journey.

The UNION keyword in between combines the output of these queries by assimilating the "london2" data with "london1". Since "london1" is being unioned with "london2", the column values that take precedence are "top_stations" and "num".

ORDER BY will order the final, unioned table by the "top_stations" column value alphabetically and in descending order.