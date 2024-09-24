--Cleaning data in sql queries

select *
from Portfolio_Project ..Nashvillehousing

--Standardize data format

select SaleDate_converted,convert(Date,SaleDate) as new_date
FROM Nashvillehousing

Update Nashvillehousing 
set SaleDate=convert(Date,SaleDate)

ALTER Table Nashvillehousing 
Add SaleDate_converted date;

Update Nashvillehousing 
set SaleDate_converted=convert(Date,SaleDate)

--Populate Property Address Data

select * from Portfolio_Project ..Nashvillehousing
--where PropertyAddress is null
order by ParcelID

--we can see there are multiple addresses wit same parcel id,so we need to first locate the ID's which have null and some other address then we can populate those columns

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project ..Nashvillehousing a
join Portfolio_Project ..Nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project ..Nashvillehousing a
join Portfolio_Project ..Nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Property address into address and city

select 
substring (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
substring (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from portfolio_project ..Nashvillehousing

Alter table Portfolio_Project ..Nashvillehousing
Add addressDetail varchar(255);

Update Portfolio_Project ..Nashvillehousing
Set addressDetail=substring (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


Alter table Portfolio_Project ..Nashvillehousing
Add city_address varchar(255);

Update Portfolio_Project ..Nashvillehousing
Set city_address=substring (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


--Owner Address(now we will use parsename instead of string to break down our address)

select OwnerAddress
from Portfolio_Project ..Nashvillehousing 

select 
PARSENAME(replace(OwnerAddress,',','.'),3),--parsename works with period,therefore we need to change the commas to periods and it works backwards as well
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from Portfolio_Project ..Nashvillehousing

Alter table Portfolio_Project ..Nashvillehousing
Add Owner_address varchar(255);

Update Portfolio_Project ..Nashvillehousing
Set Owner_address=PARSENAME(replace(OwnerAddress,',','.'),3)


Alter table Portfolio_Project ..Nashvillehousing
Add owner_city varchar(255);

Update Portfolio_Project ..Nashvillehousing
Set owner_city=PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table Portfolio_Project ..Nashvillehousing
Add owner_state varchar(255);

Update Portfolio_Project ..Nashvillehousing
Set owner_state=PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from Portfolio_Project ..Nashvillehousing

--Now,we change the Y and N to Yes and NO in field "sold as Vacant"

select distinct(SoldAsVacant),count(SoldAsVacant)
from Portfolio_Project ..Nashvillehousing
group by SoldAsVacant
order by 2;

select SoldAsVacant=
    (Case When SoldAsVacant='N' THEN 'NO'
         When SoldAsVacant='Y' THEN 'yes'
	   else
	   SoldAsVacant
	   end)
from Portfolio_Project ..Nashvillehousing

Update Portfolio_Project ..Nashvillehousing
Set SoldAsVacant=Case When SoldAsVacant='N' THEN 'NO'
         When SoldAsVacant='Y' THEN 'yes'
	   else
	   SoldAsVacant
	   end


--Removing the Duplicates


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

From Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)
sELECT* --I Used delete before select statement here to delete the entries where row number is greater than 1
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From Portfolio_Project.dbo.NashvilleHousing



--Deleting the unused columns

Select *
From Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
