SET SQL_SAFE_UPDATES = 0;



SELECT * FROM ProjectPortfolio.nashville_housing_data_cleaned;

-- Standardized Date format

UPDATE ProjectPortfolio.nashville_housing_data_cleaned
SET SaleDate = CASE
    WHEN SaleDate LIKE '%/%' THEN STR_TO_DATE(SaleDate, '%d/%m/%y')   -- For `DD/MM/YY`
    WHEN SaleDate LIKE '%-%' THEN STR_TO_DATE(SaleDate, '%d-%b-%Y')   -- For `DD-MMM-YYYY`
    WHEN SaleDate LIKE '% %' THEN STR_TO_DATE(SaleDate, '%M %d, %Y')  -- For `Month DD, YYYY`
    ELSE NULL
  END;


SELECT COUNT(*) AS InvalidDates
FROM ProjectPortfolio.nashville_housing_data_cleaned
WHERE Saledate IS NULL;


-- Populate Property address data 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(a.propertyaddress, b.propertyaddress)
FROM ProjectPortfolio.nashville_housing_data_cleaned a
JOIN ProjectPortfolio.nashville_housing_data_cleaned b
ON a.ParcelID = b.ParcelID
AND a.uniqueID <> b.uniqueID 
WHERE a.PropertyAddress IS NULL; 


UPDATE ProjectPortfolio.nashville_housing_data_cleaned a
JOIN ProjectPortfolio.nashville_housing_data_cleaned b
ON a.ParcelID = b.ParcelID
AND a.uniqueID <> b.uniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)

 SELECT
 substring(Propertyaddress, 1, locate(',', PropertyAddress) - 1) AS Address,
 substring(PropertyAddress, locate(',', PropertyAddress) + 1, char_length(PropertyAddress)) AS Address
 FROM ProjectPortfolio.nashville_housing_data_cleaned;

ALTER TABLE ProjectPortfolio.nashville_housing_data_cleaned
ADD COLUMN  PropertyStreetAddress VARCHAR(255) CHARACTER SET utf8mb4, 
ADD COLUMN PropertyCity VARCHAR(255) CHARACTER SET utf8mb4;


UPDATE ProjectPortfolio.nashville_housing_data_cleaned
SET StreetAddress = substring(Propertyaddress, 1, locate(',', PropertyAddress) - 1),
CityAddress = substring(PropertyAddress, locate(',', PropertyAddress) + 1, char_length(PropertyAddress));


SELECT OwnerAddress
FROM ProjectPortfolio.nashville_housing_data_cleaned;


SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    SUBSTRING_INDEX(OwnerAddress, ',', -1) 
FROM ProjectPortfolio.nashville_housing_data_cleaned;

ALTER TABLE ProjectPortfolio.nashville_housing_data_cleaned
ADD COLUMN OwnerStreetAddress VARCHAR(255) CHARACTER SET utf8mb4,
ADD COLUMN OwnerCity VARCHAR(255) CHARACTER SET utf8mb4,
ADD COLUMN OwnerState VARCHAR(255) CHARACTER SET utf8mb4;


UPDATE ProjectPortfolio.nashville_housing_data_cleaned
SET OwnerStreetAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


-- Change Y and N to YES and NO

SELECT Distinct(Soldasvacant) , COUNT(SoldAsVacant)
FROM ProjectPortfolio.nashville_housing_data_cleaned
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant,
CASE When Soldasvacant = 'Y' THEN 'Yes'
	When Soldasvacant = 'N' THEN 'No'
    ELSE Soldasvacant
    END
FROM ProjectPortfolio.nashville_housing_data_cleaned;

UPDATE ProjectPortfolio.nashville_housing_data_cleaned
SET SoldAsVacant = 
CASE When Soldasvacant = 'Y' THEN 'Yes'
	When Soldasvacant = 'N' THEN 'No'
    ELSE Soldasvacant
    END;
    

-- Remove Duplicates


DELETE FROM ProjectPortfolio.nashville_housing_data_cleaned
WHERE UniqueID IN (
    SELECT UniqueID FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM ProjectPortfolio.nashville_housing_data_cleaned
    ) AS subquery
    WHERE row_num > 1
);

SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, COUNT(*) AS duplicate_count
FROM ProjectPortfolio.nashville_housing_data_cleaned
GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
HAVING COUNT(*) > 1;

-- DELETE Unused columns

SELECT * FROM ProjectPortfolio.nashville_housing_data_cleaned;

ALTER TABLE ProjectPortfolio.nashville_housing_data_cleaned
DROP COLUMN OwnerAddress,
DROP COLUMN Taxdistrict,
DROP COLUMN PropertyAddress;

