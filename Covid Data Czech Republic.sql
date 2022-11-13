SELECT *
FROM ShemtovPortfolioProject.DBO.covidDeaths
ORDER BY 3,4

--SELECT *
--FROM ShemtovPortfolioProject.DBO.CovidVaccinations
--ORDER BY 3,4

SELECT location, total_cases, new_cases, total_deaths, total_deaths, population
FROM ShemtovPortfolioProject.DBO.covidDeaths
ORDER BY 1,2

 --looking at total cases vs total deaths 
 --understanding death rate of countries e.g CzechRepublic
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ShemtovPortfolioProject.DBO.covidDeaths
WHERE location like '%czech%'and continent is not NULL
ORDER BY 1,2

--looking at total cases vs population
--understanding what percentage of population got covid in Czech
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM ShemtovPortfolioProject.DBO.covidDeaths
WHERE location like '%czech%'and continent is not NULL
ORDER BY 1,2

--what country has the highest infection rate
SELECT location,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM ShemtovPortfolioProject.DBO.covidDeaths
--WHERE location like '%czech%'
GROUP BY  location, population
ORDER BY PercentagePopulationInfected desc

--Countries With Highest Death count By Population
SELECT location,  population, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM ShemtovPortfolioProject.DBO.covidDeaths
WHERE continent is not NULL
GROUP BY  location, population
ORDER BY  TotalDeathCount desc

----death count by continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM ShemtovPortfolioProject.DBO.covidDeaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY  TotalDeathCount desc

--showing the continent with highest death count By Population
SELECT DISTINCT continent,  population, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM ShemtovPortfolioProject.DBO.covidDeaths
WHERE continent is not NULL
GROUP BY  continent, population
ORDER BY  TotalDeathCount desc



--Global Counts
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) 
AS TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM ShemtovPortfolioProject.DBO.covidDeaths
WHERE continent is NOT NULL 
GROUP BY date
ORDER BY  date desc

--Loking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
FROM ShemtovPortfolioProject.DBO.covidDeaths D
JOIN ShemtovPortfolioProject.DBO.CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent is NOT NULL 
order by 2,3

--Loking at Total Population vs Vaccinations per location

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations as int))
OVER(partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ShemtovPortfolioProject.DBO.covidDeaths D
JOIN ShemtovPortfolioProject.DBO.CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent is NOT NULL 
order by 2,3


--percentage of vaccinated using CTE
With POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations as int))
OVER(partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ShemtovPortfolioProject.DBO.covidDeaths D
JOIN ShemtovPortfolioProject.DBO.CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent is NOT NULL)
SELECT*, RollingPeopleVaccinated/population*100 AS percentageOfPopulationVaccinated
FROM POPvsVAC

--Creating a Temp table to store  percentageOfPopulationVaccinated

DROP TABLE IF EXISTS percentageOfPopulationVaccinated 
CREATE TABLE percentageOfPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into percentageOfPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations as int))
OVER(partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ShemtovPortfolioProject.DBO.covidDeaths D
JOIN ShemtovPortfolioProject.DBO.CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent is NOT NULL

SELECT*, RollingPeopleVaccinated/population*100 AS percentageOfPopulationVaccinated
FROM percentageOfPopulationVaccinated

--Creating a VIEW to store  percentageOfPopulationVaccinated

CREATE VIEW percentageOfPopulationVaccinatedView AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations as int))
OVER(partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ShemtovPortfolioProject.DBO.covidDeaths D
JOIN ShemtovPortfolioProject.DBO.CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent is NOT NULL

DROP VIEW  percentageOfPopulationVaccinatedView

SELECT*
FROM percentageOfPopulationVaccinatedView 



