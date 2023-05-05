
--Selecting data from both tables and listing location and date in ascending order
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL 
ORDER BY 3, 4

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3, 4

--Looking at total cases, deaths, population everyday in different locations. Then adding a new column subtracting death by the population.
--Adding a new column subtracting death by the population.
SELECT location, date, total_cases, total_deaths, population, (population - total_deaths) AS PopulationAfterDeath
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at death percentage when infected with COVID
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%state%'
ORDER BY 1,2

--Looking at what percentage of population infected with COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentageInfectedWithCOVID
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%state%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases)/population)*100 AS PercentOfHighestInfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%state%'
GROUP BY Location, population
ORDER BY PercentOfHighestInfectionRate

--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%state%'
WHERE continent is not NULL
GROUP BY Location 
ORDER BY HighestDeathCount DESC

--Breaking things down by highest death count for continents.
SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%state%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Global Numbers of all cases, deaths, and percentages 
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%state%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

--Joining both CovidDeaths and CovidVaccination tables together
SELECT *
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject.dbo.CovidDeaths cd
ON vac.Location = cd.Location
AND vac.date = cd.date

--Looking at Total Population vs Vaccinations
--Using a CTE as well to look at the rolling vaccinations on a daily basis 
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingSumOfVac)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by cd.Location ORDER BY cd.location, cd.date) AS RollingSumOfVac
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject.dbo.CovidDeaths cd
ON cd.Location = vac.Location
AND cd.date = vac.date
WHERE cd.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingSumOfVac/Population)*100 AS RollingVaccinations
FROM PopVsVac


--Replacing CTE for Temp Table for people who understand those better.
DROP TABLE IF EXISTS #new_Population
CREATE TABLE #new_Population (
Location nvarchar(50),
Continent nvarchar(50),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingSumOfVac numeric
)
INSERT INTO #new_Population 
SELECT cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by cd.Location ORDER BY cd.location, cd.date) AS RollingSumOfVac
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject.dbo.CovidDeaths cd
ON cd.Location = vac.Location
AND cd.date = vac.date
WHERE cd.continent is not NULL
--ORDER BY 2,3
SELECT *, (RollingSumOfVac/Population)*100 AS RollingVaccinations
FROM #new_Population


--Creating views to store this data into viz application
--1st view
CREATE VIEW new_Population AS
SELECT cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by cd.Location ORDER BY cd.location, cd.date) AS RollingSumOfVac
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject.dbo.CovidDeaths cd
ON cd.Location = vac.Location
AND cd.date = vac.date
WHERE cd.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM new_Population

--2nd View
CREATE VIEW PopulationAfterDeath AS
SELECT location, date, total_cases, total_deaths, population, (population - total_deaths) AS PopulationAfterDeath
FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 1,2

--3rd view
CREATE VIEW DeathPercentageCOVID AS 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%state%'
--ORDER BY 1,2

--4th view 
CREATE VIEW PopWithCOVID AS 
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentageInfectedWithCOVID
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%state%'
--ORDER BY 1,2

--5th View 
CREATE VIEW HighestInfectionWithPop AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases)/population)*100 AS PercentOfHighestInfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%state%'
GROUP BY Location, population
--ORDER BY PercentOfHighestInfectionRate




