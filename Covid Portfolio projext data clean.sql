/*

Cleaning Data in SQL Queries

*/

Select * from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate,CONVERT(Date,SaleDate) 
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted,CONVERT(Date,SaleDate) 
from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order By parcelid

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) as IfbothPropertyAddressNull
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
 Where a.PropertyAddress is null

 Update a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
 Where a.PropertyAddress is null
-----------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Inddivdual Columns (Address, City, State)

Select PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select * from PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress From PortfolioProject.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

Select * from PortfolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant),count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant ='Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END



-----------------------------------------------------------------------------------------------------------------------------

--Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
		UniqueID
		) row_num
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

Select * From RowNumCTE
Where row_num > 1
Order by PropertyAddress

DELETE
From RowNumCTE
Where row_num > 1



Select * from PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * 
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

-----------------------------------------------------------------------------------------------------------------------------

