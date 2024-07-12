select * 
from dbo.NashvilleHousing

-- standardize date format
select dbo.NashvilleHousing.SaleDate
from dbo.NashvilleHousing

update dbo.NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table dbo.nashvillehousing
add SaleDateConverted Date

update dbo.nashvillehousing
set SaleDateConverted = convert(date, saledate)

-- populate property address data
select propertyaddress
from dbo.NashvilleHousing
where PropertyAddress is null

select uniqueid, parcelid, propertyaddress, saledate, LegalReference
from dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

-- it was found that where the parcel id are the same, the property address are also the same. 
-- to populate the property address that are null, we can use the parcelid column as a reference point. 
-- we'll be joining the table on itself.

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null 

update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null 

--- Breaking out Address into individual columns (Address, City, State)
select PropertyAddress
from dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyaddress)) as Address
from dbo.NashvilleHousing

-- updating it, we are creating two new columns
-- the first one
alter table dbo.nashvillehousing
add PropertySplitAddress nvarchar(255)

update dbo.nashvillehousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- the second one
alter table dbo.nashvillehousing
add PropertySplitCity nvarchar(255)

update dbo.nashvillehousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyaddress))

select * 
from dbo.NashvilleHousing

-- working on the owner address column
select owneraddress
from dbo.NashvilleHousing
where OwnerAddress is not null

select 
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)
from dbo.NashvilleHousing

-- adding new columns for the new update
-- first one
alter table dbo.nashvillehousing
add OwnerSplitAddress nvarchar(255)

update dbo.nashvillehousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3)

-- second one
alter table dbo.nashvillehousing
add OwnerSplitCity nvarchar(255)

update dbo.nashvillehousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2)


-- third one
alter table dbo.nashvillehousing
add OwnerSplitState nvarchar(255)

update dbo.nashvillehousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)

select * 
from dbo.NashvilleHousing


-- change Y and N to Yes and No in the "SoldAsVacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End



-- Remove duplicates

with RowNumCTE AS (
select *, 
	ROW_NUMBER() Over(
	partition by parcelid, 
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference 
				 order by 
					uniqueid
					) row_num
from dbo.NashvilleHousing
-- order by ParcelID
)
-- delete
select *
from RowNumCTE
where row_num > 1
-- order by PropertyAddress


-- Delete unused columns
alter table dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress, saledate

select *
from dbo.NashvilleHousing

