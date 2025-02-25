Nashville Housing Data Cleaning


Project Overview

This project focuses on cleaning and standardizing the Nashville Housing Dataset using SQL. The goal is to ensure data consistency, remove duplicates, and structure the dataset for better analysis.

Key Data Cleaning Steps
1. Standardizing Date FormatConverted different date formats (e.g., DD/MM/YY, DD-MMM-YYYY, Month DD, YYYY) into a uniform SQL date format using STR_TO_DATE().
Checked for invalid date conversions after transformation.

2. Handling Missing Property AddressesUsed COALESCE() and JOIN on ParcelID to fill in missing property addresses where possible.
   
3. Breaking Address Into Separate ColumnsSplit PropertyAddress into PropertyStreetAddress and PropertyCity.
Split OwnerAddress into OwnerStreetAddress, OwnerCity, and OwnerState using SUBSTRING_INDEX().

4. Standardizing 'Sold as Vacant' ColumnReplaced Y and N values with Yes and No for better readability.
   
5. Removing DuplicatesIdentified duplicate records based on ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference.
Used ROW_NUMBER() to remove duplicate entries while keeping the first occurrence.

6. Dropping Unnecessary ColumnsRemoved OwnerAddress, Taxdistrict, and PropertyAddress as they were either redundant or split into new columns.
   
Checking Data 
IntegrityUsed SELECT COUNT(*) before and after updates to ensure correct transformations.
Verified duplicate removal by running a GROUP BY query on key columns.

Usage Instructions
Clone the repository.
Execute the SQL script on MySQL Workbench (ensure SQL_SAFE_UPDATES = 0 is set).
Validate data changes using provided SELECT queries.

Technologies Used
SQL (MySQL Workbench) for data cleaning and transformation.
This cleaned dataset can now be used for data analysis, visualization, and predictive modeling.
