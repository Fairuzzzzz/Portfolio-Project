Select *
From Portfolio..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From Portfolio..CovidVaccinations$
--order by 3,4

---Select data that going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths$
where continent is not null
order by 1,2

--- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths$
where location like 'Indonesia'
and continent is not null
order by 1,2

--- Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
where location like 'Indonesia'
order by 1,2

--- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
Group by Location, population
order by PercentPopulationInfected desc

--- Showing Countries with Highest Deaths Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc

--- Breaks Things Down By Continent


--- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


--- Global Numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths$
where continent is not null
order by 1,2


--- Total Poplation vs Vaccinations

With PopvcVac (Continent, Location, Date, Population, New_Vaccinations,  RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingpeopleVaccinated/Population)*100
From PopvcVac


--- Tempt Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingpeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
