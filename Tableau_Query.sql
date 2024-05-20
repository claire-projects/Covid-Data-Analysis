/*

Queries used for Tableau Project

*/



-- 1. Global numbers of infected case and death

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From `covid-423717.CovidData.CovidDeaths`
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;


-- 2. The number of death per continent


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From `covid-423717.CovidData.CovidDeaths`
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;


-- 3. Worldwide infection rate per country

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `covid-423717.CovidData.CovidDeaths`
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4. Time series analysis for infected rate per country


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `covid-423717.CovidData.CovidDeaths`
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;




