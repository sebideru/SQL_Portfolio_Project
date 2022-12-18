
--Populate the Nashvillehousing Table 
SELECT * from [NashvilleHousing ].dbo.NashvilleHousing
--Standardize the SaleDate Column
SELECT SaleDate,CONVERT(Date,SaleDate) as Std_SaleDate from [NashvilleHousing ].dbo.NashvilleHousing 

ALTER TABLE [NashvilleHousing ].dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE [NashvilleHousing ].dbo.NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

--Populate Property Address Data

SELECT PropertyAddress from [NashvilleHousing ].dbo.NashvilleHousing
WHERE PropertyAddress is null

--Check if there are rows of the same ParcellD with one of them not having the Proerty Address

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [NashvilleHousing ].dbo.NashvilleHousing  a
JOIN [NashvilleHousing ].dbo.NashvilleHousing  b
	on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--Update the Null Value with ProertyAddress Avaliable

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [NashvilleHousing ].dbo.NashvilleHousing  a
JOIN [NashvilleHousing ].dbo.NashvilleHousing  b
	on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null	


--Breaking out Address into Individual Columns(Address,City,State)

SELECT PropertyAddress From [NashvilleHousing ].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',  PropertyAddress)+1,LEN(PropertyAddress)) as City
From [NashvilleHousing ].dbo.NashvilleHousing

ALTER TABLE [NashvilleHousing ].dbo.NashvilleHousing
ADD Address NVARCHAR(255),City NVARCHAR(255)

UPDATE [NashvilleHousing ].dbo.NashvilleHousing
SET
Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
City=SUBSTRING(PropertyAddress,CHARINDEX(',',  PropertyAddress)+1,LEN(PropertyAddress))

SELECT * from [NashvilleHousing ].dbo.NashvilleHousing

--Split the Owner Address into(Address,City and State)

SELECT 
ParseNAME(Replace(OwnerAddress,',','.'),3), --3 indicates the State ParseName works from backwards
ParseNAME(Replace(OwnerAddress,',','.'),2),
ParseNAME(Replace(OwnerAddress,',','.'),1)
from [NashvilleHousing ].dbo.NashvilleHousing

ALTER TABLE [NashvilleHousing ].dbo.NashvilleHousing
ADD OwnerSplitaddress NVARCHAR(255),OwnerSplitcity NVARCHAR(255) ,OwnerSplitstate NVARCHAR(255)


UPDATE [NashvilleHousing ].dbo.NashvilleHousing
SET OwnerSplitaddress=ParseNAME(Replace(OwnerAddress,',','.'),3),
	OwnerSplitcity=ParseNAME(Replace(OwnerAddress,',','.'),2),
	OwnerSplitstate=ParseNAME(Replace(OwnerAddress,',','.'),1)

SELECT * FROM [NashvilleHousing ].dbo.NashvilleHousing

--Change Y and N to Yes and No in 'SoldAsVacant'
Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From [NashvilleHousing ].dbo.NashvilleHousing
group by SoldAsVacant 
order by 2

SELECT SoldAsVacant,
CASE when SoldAsVacant='Y' THEN 'Yes'
	 When SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
END
From [NashvilleHousing ].dbo.NashvilleHousing


UPDATE [NashvilleHousing ].dbo.NashvilleHousing
SET SoldAsVacant=	CASE when SoldAsVacant='Y' THEN 'Yes'
						 When SoldAsVacant='N' THEN 'No'
						 ELSE SoldAsVacant
					END


--Remove Duplicates/Not recommended to remove duplicates since it is data
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID) row_num
From [NashvilleHousing ].dbo.NashvilleHousing
)
Delete from RowNumCTE
where row_num >1

--Delete Unused Columns

ALTER TABLE [NashvilleHousing ].dbo.NashvilleHousing
Drop Column ownerAddress,TaxDistrict,PropertyAddress,SaleDate

Select * from 
[NashvilleHousing ].dbo.NashvilleHousing










	












