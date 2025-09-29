USE citydata;
-- MISSING PROPERTY ADDRESS

-- Find rows in 'property_data' where the PropertyAddress is missing (NULL),
-- and there exists another row with the same ParcelID but a different UniqueID.
-- This is used to identify which records are eligible to be filled in.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM property_data as a
JOIN property_data as b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update rows in 'property_data' that are missing a PropertyAddress.
-- For each such row (a), find a matching row (b) with the same ParcelID
-- and a non-null PropertyAddress, then copy b's address into a.

UPDATE property_data as a
JOIN property_data as b 
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL
AND b.PropertyAddress IS NOT NULL;


-- BREAKING ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE)

-- Preview
/*SELECT
  SUBSTRING_INDEX(PropertyAddress, ',', 1) AS PropertySplitAddress,
  TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) AS PropertySplitCity
FROM property_data;*/

-- Add new columns to store split address and city
ALTER TABLE property_data
ADD COLUMN PropertySplitAddress VARCHAR(255),
ADD COLUMN PropertySplitCity VARCHAR(255);

-- Update new columns by splitting 'PropertyAddress' at the comma
UPDATE property_data
SET 
  PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
  PropertySplitCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));
  
-- Preview
/*SELECT
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS OwnerSplitCity,
TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS OwnerSplitState
FROM property_data;*/

-- Add new columns to store owner split address, city, and state
ALTER TABLE property_data
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

-- Update new columns by splitting 'OwnerAddress' at the comma
UPDATE property_data
SET 
	OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
	OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
	OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) ;
    
-- Change 'N' to 'No' and 'Y' to 'Yes' in SoldAsVacant 

-- Preview
/*ELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM property_data;*/

UPDATE property_data
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END;
    
-- Remove Duplicates

-- Identify potential duplicate rows in the property_data table
-- based on specific columns that define uniqueness.

/*SELECT * FROM (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ORDER BY UniqueID
         ) AS row_num
  FROM property_data
) AS sub
WHERE row_num > 1;*/

-- Delete all duplicate rows from the property_data table

DELETE FROM property_data
WHERE UniqueID IN (
  SELECT UniqueID FROM (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
             PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
             ORDER BY UniqueID 
           ) AS row_num
    FROM property_data
  ) AS sub
  WHERE row_num > 1 
);

-- Delete unused columns

ALTER TABLE property_data
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;



    
    


