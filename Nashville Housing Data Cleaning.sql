/*

Cleaning Data in SQL Queries

*/

Select *
From Portfolio..NashvilleHousing


--- Standarize Data Format

Select SaleDate, Convert(Date, SaleDate)
From Portfolio..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted, Convert(Date, SaleDate)
From Portfolio..NashvilleHousing

--- Populate Property Address Data

Select *
From Portfolio..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio..NashvilleHousing a
Join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio..NashvilleHousing a
Join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From Portfolio..NashvilleHousing

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 ) as Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) as City
From Portfolio..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
From Portfolio..NashvilleHousing

Select OwnerAddress
From Portfolio..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
From Portfolio..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

---Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
From Portfolio..NashvilleHousing

UPDATE NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--- Remove Duplicate

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From Portfolio..NashvilleHousing
---order by ParcelID
)
---Delete 
Select*
From RowNumCTE
where row_num > 1
Order By PropertyAddress

--- Delete Unused Columns

Select *
From Portfolio..NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
