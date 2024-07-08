--Describe Columns
exec sp_columns 'nashvillehousing';

--Checking Data
Select * From msplayground..nashvillehousing;

--Some of the rows are corrupted, and cant be populated
--I will drop them
Delete From msplayground..nashvillehousing Where UniqueID is null;

--Populating Data
Select * From msplayground..nashvillehousing Order By ParcelID;

--Selects rows with same ParcelID and different UniqueID's
--Checks if any rows has property adress, so we can populate it
--I tried to populate other columns with same way, but it didn't work
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From msplayground..nashvillehousing a
JOIN msplayground..nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From msplayground..nashvillehousing a
JOIN msplayground..nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Substring PropertyAddress'es and OwnerAddress'es
ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(50),
    OwnerSplitCity NVARCHAR(50),
    OwnerSplitState NVARCHAR(50);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(50),
    PropertySplitCity NVARCHAR(50);

UPDATE nashvillehousing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
    PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1);

--Change 0 to No and 1 to Yes
--Change data type bit to varchar
ALTER TABLE nashvillehousing
ALTER COLUMN SoldAsVacant NVARCHAR(50);

Select Distinct(SoldAsVacant)
From msplayground..nashvillehousing;

Select SoldAsVacant
, CASE When SoldAsVacant = 1 THEN 'Yes'
	   When SoldAsVacant = 0 THEN 'No'
	   ELSE SoldAsVacant
	   END
From msplayground..nashvillehousing;

	
Update nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 1 THEN 'Yes'
	   When SoldAsVacant = 0 THEN 'No'
	   ELSE SoldAsVacant
	   END


--Finds and Removes Duplicates
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM msplayground..nashvillehousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1;


--Deletes Unnecessary Columns
ALTER TABLE msplayground..nashvillehousing
DROP COLUMN OwnerAddress, PropertyAddress

