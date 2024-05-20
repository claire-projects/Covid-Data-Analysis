/*
Covid Project - Data Exploration in SQL (Google BigQuery)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



SELECT *
FROM `covid-423717.CovidData.CovidDeaths` 
WHERE continent is not null
ORDER BY 3,4;


SELECT *
FROM `covid-423717.CovidData.CovidVaccinations` 
ORDER BY 3,4
LIMIT 5;



-- Select Data 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid-423717.CovidData.CovidDeaths` 
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of death if contract by countries

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `covid-423717.CovidData.CovidDeaths` 
WHERE location LIKE '%States%'
ORDER BY 1,2;



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, total_cases, Population, (total_cases/population)*100 AS PercentPopulationInfected
FROM `covid-423717.CovidData.CovidDeaths` 
-- WHERE location LIKE '%States%'
ORDER BY 1,2;



-- Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX (total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM `covid-423717.CovidData.CovidDeaths` 
GROUP BY location, Population
ORDER BY 4 DESC;


-- Countries with Highest Death Count per Population


SELECT location, MAX (total_deaths) AS TotalDeathCount
FROM `covid-423717.CovidData.CovidDeaths` 
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC;




-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT location, MAX (total_deaths) AS TotalDeathCount
FROM `covid-423717.CovidData.CovidDeaths` 
WHERE continent is  null
GROUP BY location
ORDER BY 2 DESC;



-- GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, Sum(new_deaths)AS total_death , (sum(new_deaths)/sum(new_cases))*100 AS DeathPercentage
FROM `covid-423717.CovidData.CovidDeaths` 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM 
    `covid-423717.CovidData.CovidDeaths` dea
JOIN 
    `covid-423717.CovidData.CovidVaccinations` vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    2,3;




-- Shows Percentage of Population that has recieved at least one Covid Vaccine, order by location by date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT64)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
    `covid-423717.CovidData.CovidDeaths` dea
JOIN 
    `covid-423717.CovidData.CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;




-- Using CTE to perform Calculation on Partition By in previous query


WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM 
        `covid-423717.CovidData.CovidDeaths` dea
    JOIN 
        `covid-423717.CovidData.CovidVaccinations` vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL 
)
SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationRate
FROM 
    PopvsVac;




-- Using Temp Table to perform Calculation on Partition By in previous query

-- Create the temporary table
CREATE TEMP TABLE PercentPopulationVaccinated (
  Continent STRING,
  Location STRING,
  Date DATE,
  Population NUMERIC, 
  New_vaccinations NUMERIC, 
  RollingPeopleVaccinated NUMERIC
);

-- Insert data into the temporary table
INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CAST(vac.new_vaccinations AS NUMERIC), -- Ensure the correct data type
    SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM 
    `covid-423717.CovidData.CovidDeaths` dea
JOIN 
    `covid-423717.CovidData.CovidVaccinations` vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

-- Query the temporary table with the calculated VaccinationRate
SELECT 
    *,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationRate
FROM 
    PercentPopulationVaccinated;




---Create View to store data for later visualizations


Create View covid-423717.CovidData.PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
    `covid-423717.CovidData.CovidDeaths` dea
JOIN 
    `covid-423717.CovidData.CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 





