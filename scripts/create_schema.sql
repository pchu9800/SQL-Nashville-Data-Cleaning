-- Step 1: Create and select the database
CREATE DATABASE citydata;
USE citydata;

-- Step 2: Create the table to match your CSV structure
CREATE TABLE property_data (
  UniqueID INT,
  ParcelID VARCHAR(50),
  LandUse VARCHAR(50),
  PropertyAddress VARCHAR(255),
  SaleDate DATE,
  SalePrice INT,
  LegalReference VARCHAR(50),
  SoldAsVacant VARCHAR(10),
  OwnerName VARCHAR(100),
  OwnerAddress VARCHAR(255),
  Acreage DECIMAL(5,2),
  TaxDistrict VARCHAR(100),
  LandValue INT,
  BuildingValue INT,
  TotalValue INT,
  YearBuilt INT,
  Bedrooms INT,
  FullBath INT,
  HalfBath INT
);
