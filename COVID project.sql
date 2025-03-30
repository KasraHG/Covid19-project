
SELECT *
FROM coviddeaths
where 
continent IS NOT NULL
order by 
    3,4






-- SELECT location, date, total_cases, total_cases, total_deaths, population
-- FROM coviddeaths
-- ORDER BY 1,2

-- looking at Total Cases vs Total Deaths 
-- shows likelihood of dying if you contract covid in your country (Iran)

-- SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentsge
-- FROM coviddeaths
-- WHERE location like '%Iran%'
-- ORDER BY 2 

--looking at total cases vs population 
--shows what percentage of population got covid

-- SELECT location, date, population, total_cases,MAX(total_cases/population)* 100 AS PERSENTOFPOPULATIONINFECTED
-- FROM coviddeaths
-- WHERE location like '%Iran%'
-- ORDER BY 2 


-- looking at countries with highest infection rate compared to popualation

SELECT location, population, MAX(total_cases) AS HIGHESTINFECTIONCOUNT,(MAX(total_cases)::numeric/population)* 100 AS Percentagepopulationinfected
FROM coviddeaths
-- WHERE location like '%Iran%'

-- GROUP BY location, population
-- HAVING
--      (MAX(total_cases)::numeric/population)* 100 IS NOT NULL
-- ORDER BY Percentagepopulationinfected desc 


-- Showing countries with highest death count per population


-- SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
-- FROM coviddeaths
-- -- WHERE location like '%Iran%'
-- where 
-- continent IS NOT NULL
-- GROUP BY location
-- HAVING
--     MAX(total_deaths) IS NOT NULL 
-- ORDER BY TotalDeathCount desc 




-- BREAKING DOWN BY CONTINENT

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM coviddeaths
-- WHERE location like '%Iran%'
where 
continent IS NULL
GROUP BY location
HAVING
    MAX(total_deaths) IS NOT NULL 
ORDER BY TotalDeathCount desc 


-- Showing continents with highest death count per population
SELECT location, SUM(total_deaths)
from coviddeaths
where 
    continent is NULL
GROUP BY 
    location
ORDER BY 
    SUM(total_deaths) DESC



-- Global NUMBERS
SELECT  sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/sum(new_cases)*100 as DeathPercentsge
FROM coviddeaths
where continent is not null
ORDER BY 2 


--=========================================================================================================
-- looking at total population vs vaccinations

SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location order by 
dea.location,
dea.date) AS RollingPeopleVaccinated

from
    coviddeaths as dea
join
    covidvaccinations as vac
    on
        dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

WITH PopvsVac(continent, location, date, popualation, new_vaccinations, RollingPeopleVaccinated)
as 
( SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location order by 
dea.location,
dea.population,
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location order by 
dea.location,
dea.date) AS RollingPeopleVaccinated ))
from
    coviddeaths as dea
join
    covidvaccinations as vac
    on
        dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not null
-- order by 2,3



-- Temp Table

-- Step 1: Drop the table if it exists
DROP TABLE IF EXISTS Percentagepopulationvaccinated;

-- Step 2: Create the new table
CREATE TABLE Percentagepopulationvaccinated (
    Continent VARCHAR(225),
    Location VARCHAR(255),
    Data TIMESTAMP,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Step 3: Insert data into the table from a SELECT query
INSERT INTO Percentagepopulationvaccinated (Continent, Location, Data, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths AS dea
JOIN
    covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Step 4: Select the data with the calculated percentage
SELECT *, (RollingPeopleVaccinated / population) * 100 AS Percentagepopulationvaccinated
FROM Percentagepopulationvaccinated;




-- Creating view to store data for later visualization
DROP TABLE IF EXISTS Percentagepopulationvaccinated;

CREATE View Percentagepopulationvaccinated AS
SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location order by 
dea.location,
dea.date) AS RollingPeopleVaccinated

from
    coviddeaths as dea
join
    covidvaccinations as vac
    on
        dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not null

SELECT * 
FROM Percentagepopulationvaccinated;
