USE portfolioproject ;

-- total cases vs total death
SELECT location , date , total_cases , total_deaths , ( total_deaths / total_cases )*100 AS DeathPercentage
FROM coviddeaths
ORDER BY 1,2

--total cases vs population
SELECT location , date , total_cases , population , 
	   ( total_cases / population )*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE LOCATION = 'India'
ORDER BY 1,2

--countries with highest infected ratio to population
SELECT location , MAX(total_cases) AS InfectedPeople , population ,
	   MAX(( total_cases / population ))*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE continent is not null
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC

--continents with highest death count 
SELECT location , MAX(cast (total_deaths as int) ) AS DeathCount 
FROM coviddeaths
WHERE continent is null
GROUP BY location 
ORDER BY DeathCount DESC

--countries with highest death count
SELECT location , MAX(cast (total_deaths as int) ) AS DeathCount 
FROM coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount DESC

--GLOBAL NUMBERS
SELECT date , SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS INT)) AS total_deaths , 
	   SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1 DESC

--population vs vaccination
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
       SUM( CAST(new_vaccinations as bigint)) 
	   OVER (PARTITION BY dea.location  ORDER BY dea.location , dea.date  ) 
	   AS RollingVaccintaioncount
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON  dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null


--CTE TABLE
WITH PopvsVac ( continent , location , date , population , new_vaccinations , RollingVaccintaioncount )
as
( SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
       SUM( CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location) AS RollingVaccintaioncount
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON  dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
)
SELECT * , RollingVaccintaioncount/population*100 AS PercentPopulationVaccinated 
FROM PopvsVac 

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	continent nvarchar(255),
	location  nvarchar(255),
	date      datetime,
	population numeric,
	new_vaccinations numeric,
	RollingVaccintaioncount numeric )
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
       SUM( CAST(new_vaccinations as bigint)) OVER (PARTITION BY dea.location) AS RollingVaccintaioncount
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON  dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null

SELECT * , RollingVaccintaioncount/population*100 AS PercentPopulationVaccinated 
FROM #PercentPopulationVaccinated
ORDER BY 1,2



--CREATING VIEWS FOR OUR VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , 
       SUM( CAST(new_vaccinations as bigint)) 
	   OVER (PARTITION BY dea.location  ORDER BY dea.location , dea.date  ) 
	   AS RollingVaccintaioncount
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON  dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null

SELECT * FROM PercentPopulationVaccinated


