SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--- How many cases vs death
--- likelihood of dying from covid
SELECT 
   location,
   date,
   population,
   total_cases,
   total_deaths,
   (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%gambia%'
Order by 1, 2;

--- Looking at Total cases vs population
--- shows what % of population has gotten covid

SELECT 
   location,
   population,
   date,
   total_cases,
   total_deaths,
   (total_cases/population)*100 AS PopulationInfectionRate
FROM CovidDeaths
WHERE location like '%gambia%'
Order by 1, 2;

--- Countries with highest population infection
SELECT 
   location,
   population,
   MAX(total_cases) as highest_infection_count,
   MAX((total_cases/population))*100 AS PopulationInfectionRate
FROM CovidDeath
GROUP BY location, population
--- WHERE location like '%gambia%'
Order by PopulationInfectionRate DESC

--- Countries with highest death count per population

SELECT 
   location,
   MAX(cast(total_deaths as INT)) AS DeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY DeathCount DeSC

--- By continent

SELECT 
   location,
   MAX(cast(total_deaths as INT)) AS DeathCount
FROM CovidDeaths
WHERE continent IS NULL 
GROUP BY location
ORDER BY DeathCount DeSC

--- Alex missing some points
SELECT 
   continent,
   MAX(cast(total_deaths as INT)) AS DeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY DeathCount DeSC

---- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;

USE ProjectPortfolio;
select dea.continent, dea.location, dea.date. dea.population, vac.new_vaccinations
from coviddeaths dea
JOIN covidvaccination vac
   ON dea.location = vac.location
   AND dea.date = vac.date;

   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
    ON dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null 
order by 2,3;

SELECT * from CovidDeaths


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

