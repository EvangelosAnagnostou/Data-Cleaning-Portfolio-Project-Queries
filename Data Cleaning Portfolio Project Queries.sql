/*

Cleaning Data in SQL Queries

*/

Select * from [dbo].[NashvilleHousing]




-- Standarize Date format

Select saledate, cast(saledate as date)
from [dbo].[NashvilleHousing]

Alter table [dbo].[NashvilleHousing]
Add SaleDateConverted Date

Update [dbo].[NashvilleHousing]
Set SaleDateConverted = cast(Saledate as date)




-- Populate Property Address data

/*
Some of the PropertyAddress cells are Null.
The rows that have the same ParcelId, they have identical PropertyAddress as well as shown in the spreadsheet.
UniqueId is different for every property even if ParcedId is the same.
*/

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
Inner Join [dbo].[NashvilleHousing] b
On a.ParcelID = b.ParcelID 
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
Set PropertyAddress = coalesce(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
Inner Join [dbo].[NashvilleHousing] b
On a.ParcelID = b.ParcelID 
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null




-- Breaking out Address into Individual Columns (Address, City)

Select 
SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as City
from [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
Add PropertySplitAddress nvarchar(255)

Update [dbo].[NashvilleHousing]
Set PropertySplitAddress = SUBSTRING(propertyaddress, 1, charindex(',',PropertyAddress)-1)

ALTER TABLE [dbo].[NashvilleHousing]
Add PropertySplitCity nvarchar(255)

Update [dbo].[NashvilleHousing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))


Select * from [dbo].[NashvilleHousing]




-- Splitting one column (OwnerAddress) into three columns (OwnerSplitAddress, OwnerSplitCity, OwnerSplitState)

Select OwnerAddress from [dbo].[NashvilleHousing]

Select 
Parsename (Replace(OwnerAddress, ',','.'), 3),
Parsename (Replace(OwnerAddress, ',','.'), 2),
Parsename (Replace(OwnerAddress, ',','.'), 1)
from [dbo].[NashvilleHousing]


ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitAddress nvarchar(255)

Update [dbo].[NashvilleHousing]
Set OwnerSplitAddress = Parsename (Replace(OwnerAddress, ',', '.'), 3)


ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitCity nvarchar(255)

Update [dbo].[NashvilleHousing]
Set OwnerSplitCity = Parsename (Replace(OwnerAddress, ',', '.'), 2)


ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitState nvarchar(255)

Update [dbo].[NashvilleHousing]
Set OwnerSplitState = Parsename (Replace(OwnerAddress, ',', '.'), 1)


Select * from [dbo].[NashvilleHousing]




-- Change Y and N to Yes and No in ''Sold as Vacant'' field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from [dbo].[NashvilleHousing]
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE
  When SoldAsVacant = 'Y' then 'Yes'
  When SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
End
from [dbo].[NashvilleHousing]


Update [dbo].[NashvilleHousing]
Set SoldAsVacant = CASE
  When SoldAsVacant = 'Y' then 'Yes'
  When SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
End




-- Remove Duplicates

With RowNumCTE AS (
Select *,
ROW_NUMBER() over (Partition by
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID) 
				as row_num
from [dbo].[NashvilleHousing]
-- Order by ParcelID
)
Select * from RowNumCTE
where row_num > 1
Order by PropertyAddress

Delete from RowNumCTE
where row_num > 1  




-- Delete Unused Columns

ALTER TABLE [dbo].[NashvilleHousing]
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate