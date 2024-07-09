select * from PortfolioProject..NashvilleHousing

--Standardize Date Format
select SaleDate--, CONVERT(Date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

--Populating property address

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

--added property address to corresponding ParcelID where property address was null
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null

select 
substring(PropertyAddress, 1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set  PropertySplitAddress = substring(PropertyAddress, 1,charindex(',',PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set  PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress));

select OwnerAddress
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1);

select * from PortfolioProject..NashvilleHousing

--changing Y & N to Yes & No
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

--removing duplicates

with rownumCTE as(
select * ,
ROW_NUMBER()over(
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
delete from rownumCTE where row_num > 1

--deleting unused columns

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select * from PortfolioProject..NashvilleHousing







