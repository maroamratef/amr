Select *
From [dbo].[NashvilleHousing]

-- Standardize Date Format removing nulls

--Your SQL query is converting the SaleDate column to the DATE data type and displaying it alongside the original value.

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--ALTER TABLE modifies an existing table.
--ADD adds a new column.
--SaleDateConverted is the name of the new column.
--DATE stores only the date (no time).
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

--UPDATE NashvilleHousing updates every row in the table.
--SET SaleDateConverted = CONVERT(DATE, SaleDate) converts the SaleDate value to the DATE data type (removing the time portion) and stores it in SaleDateConverted.
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select *
From [dbo].[NashvilleHousing]
--Where PropertyAddress is null
order by ParcelID

--a and b are aliases for the same table (NashvilleHousing).
--a.ParcelID = b.ParcelID
--Matches records that refer to the same property.
--a.[UniqueID ] <> b.[UniqueID ]
--Prevents a row from matching itself.
--WHERE a.PropertyAddress IS NULL
--Only returns rows where the address is missing.
--ISNULL(a.PropertyAddress, b.PropertyAddress)
--Since a.PropertyAddress is NULL, it returns b.PropertyAddress.
SELECT
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS FilledPropertyAddress
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--This updates every row with a missing PropertyAddress by copying the address from another row with the same ParcelID.
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select *
From [dbo].[NashvilleHousing]

-- Breaking out Address into Individual Columns (Address, City, State)
--Step 1: View the split values
--SELECT
--    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
--    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
--FROM PortfolioProject.dbo.NashvilleHousing;
--Suppose the data is:
--PropertyAddress
--123 Main St, Nashville
--456 Oak Ave, Franklin
--CHARINDEX()
--CHARINDEX(',', PropertyAddress)

--Finds the position of the comma.

--For:

--123 Main St, Nashville

--It returns:

--12

--because the comma is the 12th character.

--First SUBSTRING()
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

--Syntax:

--SUBSTRING(string, start_position, number_of_characters)

--Here:

--String = PropertyAddress
--Start = 1
--Length = CHARINDEX(...) - 1

--Example:

--123 Main St, Nashville
--123 Main St

--It extracts everything before the comma.

--Second SUBSTRING()
--SUBSTRING(PropertyAddress,
--         CHARINDEX(',', PropertyAddress)+1,
--          LEN(PropertyAddress))

--Start position:

--CHARINDEX(...) + 1

--This begins right after the comma.

--For:

--123 Main St, Nashville

--it starts at

--N

--and returns

-- Nashville

--Notice the leading space.

--A cleaner version is:

--LTRIM(
--    SUBSTRING(PropertyAddress,
--              CHARINDEX(',', PropertyAddress)+1,
--              LEN(PropertyAddress))
--)

--which returns

--Nashville
--Step 2: Add a new column for the address
--ALTER TABLE NashvilleHousing
--ADD PropertySplitAddress NVARCHAR(255);
--What this does

--It changes the table structure.

--Before:

--PropertyAddress
--123 Main St, Nashville

--After:

--PropertyAddress	PropertySplitAddress
--123 Main St, Nashville	NULL

--The new column exists but is empty.

--Step 3: Fill the address column
--UPDATE NashvilleHousing
--SET PropertySplitAddress =
--SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

--This copies the street portion into the new column.

--Result:

--PropertyAddress	PropertySplitAddress
--123 Main St, Nashville	123 Main St
--Step 4: Add another column for the city
--ALTER TABLE NashvilleHousing
--ADD PropertySplitCity NVARCHAR(255);

--Now the table looks like

--PropertyAddress	PropertySplitAddress	PropertySplitCity
--123 Main St, Nashville	123 Main St	NULL
--Step 5: Fill the city column
--UPDATE NashvilleHousing
--SET PropertySplitCity =
--SUBSTRING(PropertyAddress,
--          CHARINDEX(',',PropertyAddress)+1,
--          LEN(PropertyAddress));

--Now the table becomes

--PropertyAddress	PropertySplitAddress	PropertySplitCity
--123 Main St, Nashville	123 Main St	Nashville

--Notice the leading space before "Nashville".

--A better version is:

--UPDATE NashvilleHousing
--SET PropertySplitCity =
--LTRIM(
--    SUBSTRING(PropertyAddress,
--              CHARINDEX(',', PropertyAddress)+1,
--              LEN(PropertyAddress))
--);

--Result:

--PropertyAddress	PropertySplitAddress	PropertySplitCity
--123 Main St, Nashville	123 Main St	Nashville
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [dbo].[NashvilleHousing]


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From [dbo].[NashvilleHousing]

--This query is another data cleaning technique. It separates the OwnerAddress column into Address, City, and State using the PARSENAME() function.

--Suppose the OwnerAddress column contains:

--OwnerAddress
--123 Main St, Nashville, TN
--456 Oak Ave, Franklin, TN
--The query
--SELECT
--    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
--    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
--    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
--FROM PortfolioProject.dbo.NashvilleHousing;
--Step 1: REPLACE()
--REPLACE(OwnerAddress, ',', '.')

--REPLACE() substitutes every comma with a period.

--Example:

--Before:

--123 Main St, Nashville, TN

--After:

--123 Main St. Nashville. TN

--Why replace commas with periods?

--Because PARSENAME() only splits strings that use periods (.) as separators.

--Step 2: PARSENAME()

--Syntax:

--PARSENAME('part1.part2.part3.part4', piece)

--piece is counted from right to left.

--For the string:

--123 Main St. Nashville. TN

--The parts are:

--Part 3      Part 2      Part 1
---------   ---------   ------
--123 Main St Nashville   TN
--PARSENAME(..., 1)
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Returns the rightmost part.

--Result:

--TN

--This is the State.

--PARSENAME(..., 2)
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--Returns the second part from the right.

--Result:

--Nashville

--This is the City.

--PARSENAME(..., 3)
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--Returns the third part from the right.

--Result:

--123 Main St

--This is the Street Address.

--Complete Example

--Suppose your table contains:

--OwnerAddress
--123 Main St, Nashville, TN
--After REPLACE()
--123 Main St. Nashville. TN
--Then PARSENAME()
--Expression	Result
--PARSENAME(...,3)	123 Main St
--PARSENAME(...,2)	Nashville
--PARSENAME(...,1)	TN

--The final output is:

--OwnerSplitAddress	OwnerSplitCity	OwnerSplitState
--123 Main St	Nashville	TN
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [dbo].[NashvilleHousing]



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [dbo].[NashvilleHousing]



-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [dbo].[NashvilleHousing]


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
--Step 1: Create a Common Table Expression (CTE)
--WITH RowNumCTE AS (

--A CTE (Common Table Expression) is a temporary result set that exists only for the next query.

--Think of it like creating a temporary table named RowNumCTE.

--Step 2: Select all columns
--SELECT *,

--This returns every column from the NashvilleHousing table.

--Step 3: Generate row numbers
--ROW_NUMBER() OVER (

--ROW_NUMBER() assigns a unique number to each row within a group.

--For example:

--Name	Row Number
--John	1
--John	2
--John	3
--Step 4: Define what counts as a duplicate
--PARTITION BY
--    ParcelID,
--    PropertyAddress,
--    SalePrice,
--    SaleDate,
--    LegalReference

--PARTITION BY groups rows that have the same values in all these columns.

--Imagine your data:

--ParcelID	Address	SalePrice	SaleDate	LegalReference
--100	123 Main St	250000	2020-01-01	ABC
--100	123 Main St	250000	2020-01-01	ABC
--100	123 Main St	250000	2020-01-01	ABC
--101	456 Oak St	300000	2021-03-10	XYZ

--The first three rows belong to the same partition because all five columns match.

--Step 5: Decide which row is first
--ORDER BY UniqueID

--Within each partition, rows are sorted by UniqueID.

--Suppose:

--UniqueID	ParcelID
--15	100
--28	100
--43	100

--After sorting:

--UniqueID	Row Number
--15	1
--28	2
--43	3

--The row with the smallest UniqueID is treated as the original record.

--Step 6: Save the row number
--) AS row_num

--This creates a new column named row_num.

--The CTE now looks like:

--UniqueID	ParcelID	Address	row_num
--15	100	123 Main St	1
--28	100	123 Main St	2
--43	100	123 Main St	3
--50	101	456 Oak St	1
--Step 7: Query the CTE
--SELECT *
--FROM RowNumCTE

--Now you're selecting from the temporary result instead of the original table.

--Step 8: Keep only duplicates
--WHERE row_num > 1

--This removes the first occurrence (row_num = 1) and returns only duplicate rows.

--Example result:

--UniqueID	ParcelID	row_num
--28	100	2
--43	100	3

-- These are the duplicate records.
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
    FROM [dbo].[NashvilleHousing]
    )
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;
--to delete dublicates
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1;

Select *
From [dbo].[NashvilleHousing]

-- Delete Unused Columns



Select *
From [dbo].[NashvilleHousing]


ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate