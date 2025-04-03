COVID-19 Data Analysis Queries
This project involves analyzing COVID-19 data to extract key insights, including death rates, infection rates, and vaccination progress across various locations and continents. The queries are based on two datasets: coviddeaths and covidvaccinations.\

## Tableau Project: COVID-19 Dashboard

I have visualized COVID-19 data in Tableau. You can explore the project by clicking on the link below:

[View the Tableau project on Tableau Public](https://public.tableau.com/app/profile/kasra.hosseini/viz/CovidDashboard_17434919896530/Coviddashboard?publish=yes)


Key Queries
Below is a collection of queries used to explore COVID-19 data and generate insights.

1. Filter Data by Continent and Sort
This query filters out rows where the continent is null and sorts the data by specific columns.

```sql
SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;
```
2. Total Cases vs. Total Deaths (Iran)
This query calculates the likelihood of dying from COVID-19 by comparing total deaths to total cases in a specific location (Iran).

```sql
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%Iran%'
ORDER BY 2;
```
3. Total Cases vs. Population (Iran)
This query calculates the percentage of the population that got infected with COVID-19 in Iran by dividing total cases by the population.

```sql
SELECT location, date, population, total_cases, MAX(total_cases/population)*100 AS PercentOfPopulationInfected
FROM coviddeaths
WHERE location LIKE '%Iran%'
ORDER BY 2;
```
4. Countries with Highest Infection Rate (by Population)
This query finds the countries with the highest infection rate, which is calculated by dividing total cases by population.

```sql
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)::numeric / population) * 100 AS PercentagePopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;
```
5. Countries with Highest Death Count (per Population)
This query identifies countries with the highest death count relative to their population.

```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC;
```
6. Breakdown of Death Counts by Continent
This query groups death counts by location in cases where the continent is NULL, showing death counts in regions that are not associated with a continent.

```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC;
```
7. Countries with Highest Death Count (Summed per Location)
This query sums the total deaths per location and orders them by the highest values.

```sql
SELECT location, SUM(total_deaths)
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY SUM(total_deaths) DESC;
```
8. Global COVID-19 Numbers
This query calculates global COVID-19 statistics, including total cases, total deaths, and death percentage (death cases relative to total cases).

```sql
SELECT sum(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(new_deaths) / sum(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 2;
```
9. Vaccination Data and Total Population Comparison
This query calculates the rolling total of vaccinations over time, grouped by location. It joins coviddeaths and covidvaccinations to provide insights into vaccination progress.

```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;
```
10. Common Table Expression (CTE) for Population vs Vaccinations
This CTE creates a temporary result set for calculating rolling vaccinations and then calculates the percentage of the population vaccinated.

```sql
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM coviddeaths AS dea
    JOIN covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentagePopulationVaccinated
FROM PopvsVac;
```
11. Temporary Table to Store Vaccination Data
This query demonstrates how to create a temporary table to store vaccination data and later calculate the percentage of the population vaccinated.

```sql
DROP TABLE IF EXISTS Percentagepopulationvaccinated;

CREATE TABLE Percentagepopulationvaccinated (
    Continent VARCHAR(225),
    Location VARCHAR(255),
    Data TIMESTAMP,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);
```
```sql
INSERT INTO Percentagepopulationvaccinated (Continent, Location, Data, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentagePopulationVaccinated
FROM Percentagepopulationvaccinated;
```
12. Creating a View for Vaccination Data
This query creates a view that joins coviddeaths and covidvaccinations and provides a rolling sum of new vaccinations, making the query reusable for future analysis.

```sql
DROP VIEW IF EXISTS Percentagepopulationvaccinated;

CREATE VIEW Percentagepopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM Percentagepopulationvaccinated;
```

13. Total Death Count by Non-Country Entities (e.g., Continents)
``` sql
Copy
Edit
SELECT Location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;
```
14. Highest Infection Rate vs. Population by Country (Over Time)
``` sql
Copy
Edit
SELECT location,
       date,
       population,
       MAX(total_cases) AS HIGHESTINFECTIONCOUNT,
       (MAX(total_cases)::numeric / population) * 100 AS Percentagepopulationinfected
FROM coviddeaths
GROUP BY location, population, date
ORDER BY Percentagepopulationinfected DESC, location;
```

## 📌 Summary
This project performs a variety of COVID-19 data analysis tasks using SQL, including:

Infection and death rate calculations

Vaccination progress tracking

Trend analysis by country and continent

Creating views, CTEs, and temporary tables

Data visualization using Tableau

By using advanced SQL techniques (joins, window functions, aggregation, etc.), this project extracts valuable public health insights from real-world COVID-19 data sources.



