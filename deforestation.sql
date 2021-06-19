-- Create a View called “forestation” by joining all three tables - 
-- forest_area, land_area and regions in the workspace.
-- Sanity Check (Drop View if Exists)
DROP VIEW IF EXISTS forestation;


-- The forest_area and land_area tables join on both country_code AND year.
-- The regions table joins these based on only country_code
-- All of the columns of the origin tables
-- A new column that provides the percent of the land area that is designated as forest.
-- Keep in mind that the column forest_area_sqkm in the forest_area table and the
-- land_area_sqmi in the land_area table are in different units
-- (square kilometers and square miles, respectively), so an adjustment will
-- need to be made in the calculation you write (1 sq mi = 2.59 sq km).

CREATE VIEW forestation AS
SELECT fa.country_code,
       fa.country_name,
       fa.forest_area_sqkm,
       fa.year,
       la.total_area_sq_mi,
       r.region,
       r.income_group,
       100.0*(fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59))
FROM forest_area fa, land_area la, regions r
WHERE fa.country_code = la.country_code
AND fa.year = la.year
AND r.country_code = la.country_code
AND r.country_code = fa.country_code;


SELECT * FROM forestation;

-- GLOBAL SITUATION
-- What was the total forest area (in sq km) of the world in 1990?
-- Please keep in mind that you can use the country record denoted as “World" in the region table.
SELECT forest_area_sqkm
FROM forestation
WHERE year = '1990'::int
AND country_name = 'World';
-- RESULT: 41282694.9

-- What was the total forest area (in sq km) of the world in 2016?
-- Please keep in mind that you can use the country record in the table is denoted as “World.”
SELECT forest_area_sqkm
FROM forest_area
WHERE country_name = 'World'
AND year = '2016'::int;
-- RESULT: 39958245.9

-- ALSO CAN DO
SELECT forest_area_sqkm
FROM forest_area
WHERE country_name = 'World'
AND (year = '1990'::int OR year = '2016'::int);
-- RESULT: 39958245.9
-- RESULT: 41282694.9

-- What was the change (in sq km) in the forest area of the world from 1990 to 2016?
SELECT recent.forest_area_sqkm - past.forest_area_sqkm
FROM forest_area AS recent
JOIN forest_area AS past
ON recent.year = '2016'::int AND past.year = '1990'::int
AND recent.country_name = 'World' AND past.country_name = 'World';
-- RESULT: -1324449

-- What was the percent change in forest area of the world between 1990 and 2016
SELECT ROUND(CAST(
  100.0*(recent.forest_area_sqkm - past.forest_area_sqkm) / past.forest_area_sqkm AS NUMERIC), 2)
FROM forestation as recent
JOIN forestation as past
ON recent.year = '2016'::int AND past.year = '1990'
AND recent.country_name = 'World' AND past.country_name = 'World';

-- If you compare the amount of forest area lost between 1990 and 2016, 
-- to which country's total area in 2016 is it closest to
SELECT country_name,
       (total_area_sq_mi * 2.59) AS total_area_sqkm
FROM forestation
WHERE year = 2016::int
AND (total_area_sq_mi * 2.59) < (SELECT ABS(recent.forest_area_sqkm - past.forest_area_sqkm)
FROM forest_area AS recent
JOIN forest_area AS past
ON recent.year = '2016'::int AND past.year = '1990'::int
AND recent.country_name = 'World' AND past.country_name = 'World')
ORDER BY 2 DESC
LIMIT 1;


-- REGIONAL OUTLOOK
-- COUNTRY-LEVEL DETAIL
-- 
