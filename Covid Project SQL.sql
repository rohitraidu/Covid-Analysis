USE [Portfolio project];

--------------------------------------------------------------------------------------------------------------------------------------
SELECT*
FROM CovidVaccinations;

--------------------------------------------------------------------------------------------------------------------------------------

-- Selecting specific columns to view the data properly
SELECT 
	location,
	date, 
	total_cases,
	new_cases, 
	total_deaths,
	population
FROM CovidDeaths;

--------------------------------------------------------------------------------------------------------------------------------------
-- Total Cases vs total deaths

SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS Death_percentage
FROM CovidDeaths
WHERE location like '%states%'
 AND continent IS NOT NULL;
--------------------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Population

SELECT location, 
       date, 
       total_cases, 
       population, 
       (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS Infected_perc
FROM CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL

--------------------------------------------------------------------------------------------------------------------------------------

---Countries with highest infection rate compared to popution

SELECT Location, 
       MAX(total_cases) AS InfectedCount, 
       population, 
       (CAST(MAX(total_cases) AS FLOAT) / CAST(population AS FLOAT)) * 100 AS Infected_perc
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
	location,
	population
ORDER BY Infected_perc desc;
--------------------------------------------------------------------------------------------------------------------------------------


-- Countries with hishest death count per population

SELECT location,
       MAX(total_deaths) AS totalDeathCount
FROM CovidDeaths
Where continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC;

--------------------------------------------------------------------------------------------------------------------------------------

--Continent with highest death count


SELECT continent,
       MAX(total_deaths) AS totalDeathCount
FROM CovidDeaths
Where continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC;


-- Filtering Single Continent 
SELECT 
    SUM(new_cases) AS total_new_cases, 
    SUM(new_deaths) AS total_new_deaths, 
    CAST(SUM(new_deaths) AS FLOAT) / NULLIF(CAST(SUM(new_cases) AS FLOAT), 0) * 100 AS Death_percentage
FROM 
    CovidDeaths
WHERE 
    continent = 'Europe';


--------------------------------------------------------------------------------------------------------------------------------------
--Global numbers

SELECT 
    SUM(new_cases) AS total_new_cases, 
    SUM(new_deaths) AS total_new_deaths, 
    CAST(SUM(new_deaths) AS FLOAT) / NULLIF(CAST(SUM(new_cases) AS FLOAT), 0)*100 AS Death_percentage
FROM 
    CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 
    1,2;

--------------------------------------------------------------------------------------------------------------------------------------
--Total population vs vaccinations

SELECT d.continent, d.location, d.date, d.population,v.new_vaccinations,
SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location,d.date) AS cumulative_new_vaccinations 
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 
    2,3

--------------------------------------------------------------------------------------------------------------------------------------
-- USE CTE

WITH POPvsVAC (continent, location,date,population,new_vaccinations,cumulative_new_vaccinations)
AS
(
SELECT d.continent, d.location, d.date, d.population,v.new_vaccinations,
SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location,d.date) AS cumulative_new_vaccinations 
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY  2,3
)
SELECT*, CAST(cumulative_new_vaccinations AS FLOAT) / CAST(population AS FLOAT) * 100 AS vaccination_percentage
FROM POPvsVAC

--------------------------------------------------------------------------------------------------------------------------------------

-- tempt table
--------------------------------------------------------------------------------------------------------------------------------------
-- Create the temporary table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    cumulative_new_vaccinations NUMERIC
);

-- Insert data into the temporary table
INSERT INTO #PercentPopulationVaccinated (continent, location, date, population, new_vaccinations, cumulative_new_vaccinations)
SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.date) AS cumulative_new_vaccinations
FROM 
    CovidDeaths d
JOIN 
    CovidVaccinations v ON d.location = v.location AND d.date = v.date
WHERE 
    d.continent IS NOT NULL;

-- Select data from the temporary table with vaccination percentage calculation
SELECT 
    *, 
    CAST(cumulative_new_vaccinations AS FLOAT) / CAST(population AS FLOAT) * 100 AS vaccination_percentage
FROM 
    #PercentPopulationVaccinated
--------------------------------------------------------------------------------------------------------------------------------------




CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.date) AS cumulative_new_vaccinations
FROM 
    CovidDeaths d
JOIN 
    CovidVaccinations v ON d.location = v.location AND d.date = v.date
WHERE 
	d.continent IS NOT NULL;








