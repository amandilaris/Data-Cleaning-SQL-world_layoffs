-- Data Cleaning

Select *
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize Data
-- 3. Null/Blank Values
-- 4. Remove Any Columns or Rows


-- Removing Duplicates

#for unecessary data   #create a copy to not mess anything up
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
from layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

#end of making a copy

Select *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
from layoffs_staging;

WITH duplicate_cte AS
(
Select *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage,
 country, funds_raised_millions) AS row_num
from layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

#checking if they are duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Oda' ;

#we need to go back and partition by every single column since they are not dupllicates

#now we are checking again

SELECT *
FROM layoffs_staging
WHERE company = 'Casper' ;

#they are duplicates so the query is working well

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
(
Select *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage,
 country, funds_raised_millions) AS row_num
from layoffs_staging
)
;

#Checking that we are deleting the right data

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
; 

DELETE
FROM layoffs_staging2
WHERE row_num > 1
;


# Checking to see if it worked

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
; 

SELECT *
FROM layoffs_	staging2
;

-- Standardizing Data 

SELECT company, TRIM(company)      #trim removes the whitespace
FROM layoffs_staging2
; 

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry   
FROM layoffs_staging2
ORDER BY 1;
; 

#Crypto and CryptoCurrency should be grouped together

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
; 

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

#Checking the results

SELECT DISTINCT industry   
FROM layoffs_staging2
;

#We check all the columns 

SELECT DISTINCT country   
FROM layoffs_staging2
ORDER BY 1
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)           #to remove the '.' afet the 'United States'
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

SELECT *
FROM layoffs_staging2;

#change the date column from text to date

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2date
;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

#Check that date is of the correct type on the left of the UI

SELECT *
FROM layoffs_staging2;

-- Null and Blank Values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'
; 

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL
;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

#everything is fixed but 'Bally's Interactive'

SELECT *
from layoffs_staging2
WHERE company LIKE 'Bally%';


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;