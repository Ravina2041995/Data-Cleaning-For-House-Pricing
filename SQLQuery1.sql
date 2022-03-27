--Select everything
Select *
from [Data Exploration Housing society]..Housing

--Selecting sales date 
Select saleDate, CONVERT(date,saleDate)
from [Data Exploration Housing society]..Housing

--Changing date format to standard
Update Housing
SET saleDate = CONVERT(date,saleDate)

--Using Alter
Alter table Housing
Add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(date,saleDate)

--Property adress data-Check null value
Select *
from [Data Exploration Housing society]..Housing
Where PropertyAddress is null

--Checking data
--Obsereved for duplicate ParcelID, we can replace null value with the given adress from other one

Select *
from [Data Exploration Housing society]..Housing
order by ParcelID

--Want to update null propertyAdress with, propertyadress from duplicate 
--PracelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [Data Exploration Housing society]..Housing a
Join [Data Exploration Housing society]..Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a 
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Data Exploration Housing society]..Housing a
Join [Data Exploration Housing society]..Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking adress into Individual adress, city, state
Select PropertyAddress
from [Data Exploration Housing society]..Housing

--CHARINDEX(substring, string, start)
--SUBSTRING(string, start, length)

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
from [Data Exploration Housing society]..Housing

ALTER TABLE Housing
Add SplitAddress Nvarchar(255);

Update Housing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housing
Add SplitAddressCity Nvarchar(255);

Update Housing
SET SplitAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Seperate ownerAdress

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [Data Exploration Housing society]..Housing

ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
SET OwnerSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housing
Add OwnerSplitAddressCity Nvarchar(255);

Update Housing
SET OwnerSplitAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
from [Data Exploration Housing society]..Housing

--Change Y and N to Yes and No in 'Sold as vacant' field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Data Exploration Housing society]..Housing
Group by SoldAsVacant
Order by 2
 
Select SoldAsVacant
, CASE when SoldAsVacant= 'Y' Then 'YES'
		when SoldAsVacant= 'N' Then 'No'
		Else SoldAsVacant
		end
from [Data Exploration Housing society]..Housing

Update Housing
SET  SoldAsVacant = CASE when SoldAsVacant= 'Y' Then 'YES'
		when SoldAsVacant= 'N' Then 'No'
		Else SoldAsVacant
		end
from [Data Exploration Housing society]..Housing

--Remove Duplicates

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

from [Data Exploration Housing society]..Housing
--order by ParcelID
)

--Delete
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
from [Data Exploration Housing society]..Housing

--Delete unused columns


ALTER TABLE [Data Exploration Housing society]..Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

