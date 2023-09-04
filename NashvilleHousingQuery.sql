--Cleaning Data in SQL Queries
--I'll be working with a data on Nashvile Housing. This data holds information such as Property Address, sale price, owner's name e.t.c on Housing projects in this area.
--I'll be cleaning the data by getting rid of unwanted and duplicate data and also filling blank or null values within the data.

SELECT * 
FROM [SQL Project].dbo.NashvilleHousing


--------------------------------------------------------------------------------------
--Standardizing the date format

SELECT SaleDate, CONVERT(date, saledate)
FROM [SQL Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD DateOfSale date

UPDATE NashvilleHousing
SET DateOfSale = CONVERT (Date, SaleDate)

select SaleDate, DateOfSale
FROM NashvilleHousing


----------------------------------------------------------------------------------
--Filling NULL values in the Address column
SELECT *
FROM [SQL Project].dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM [SQL Project].dbo.NashvilleHousing AS A
JOIN [SQL Project].dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [SQL Project].dbo.NashvilleHousing AS A
JOIN [SQL Project].dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

--------------------------------------------------------------------------------------
--Breaking out addrress into individual columns i.e Address, City, State

SELECT PropertyAddress
FROM [SQL Project].dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM [SQL Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


SELECT 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
From [SQL Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD City Nvarchar (255)

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [SQL Project].dbo.NashvilleHousing



SELECT OwnerAddress
FROM [SQL Project].dbo.NashvilleHousing

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [SQL Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT DISTINCT(SoldAsVacant)
FROM [SQL Project].dbo.NashvilleHousing

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM [SQL Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

-----------------------------------------------------------------------------------------------------------
--Removing duplicates
--To perform this operation, I'll be using the SQL ROW-NUMBER() function and creating a CTE to house this query
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY uniqueID) AS row_num
FROM [SQL Project].dbo.NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------------------------
--Deleting Unwanted columns
SELECT *
FROM [SQL Project].dbo.NashvilleHousing

ALTER TABLE [SQL Project].dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict


