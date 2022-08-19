/****** Script for SelectTopNRows command from SSMS  ******/
Select * FROM PortifolioProject..CovidVaccines
WHERE Location in ('United States')
order by 3,4

Select * FROM PortifolioProject..CovidDeaths
WHERE Location in ('United States')
WHERE continent is not null
order by 3,4


Select Location,date, total_cases, new_cases, total_deaths AS deaths,population
FROM PortifolioProject..CovidDeaths 
order by 1,2

--Looking at total Cases vs total deaths
--Shows liklihood of dying if COVID is Contracted in US.
Select Location,date, total_cases, total_deaths AS deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortifolioProject..CovidDeaths 
WHERE Location like '%states%' and continent is not null
order by 1,2

--Look at total caases vx Population
--shows percentage of people who have contracted COVID
Select Location,date, total_cases, population, total_deaths AS deaths,(total_cases/population)*100 as ContractedPercentage,
FROM PortifolioProject..CovidDeaths 
WHERE Location like '%states%'
order by 1,2

--Looking at Coountries with highest Infection Rate compared to population
Select Location, MAX(total_cases) as HighestInfectionCount, population,MAX((total_cases/population)*100 )as ContractedPercentage
FROM PortifolioProject..CovidDeaths
WHERE continent is not null
group by Location,population
order by ContractedPercentage desc

--Showing Countries with highest death count pewr population
Select Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortifolioProject..CovidDeaths
WHERE continent is not null
group by Location
order by TotalDeathCount desc

--showing continent with highest death count per population
Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortifolioProject..CovidDeaths
WHERE continent is not null AND location not in ('Upper middle income','High income','Lower middle income','Low income')
group by continent
order by TotalDeathCount desc

--Global Numbers
select date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortifolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--global numbers without dates
select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortifolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
    Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccines vac
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null 
Order by 2,3

-- to call (RollingPeopleVaccinated/population)*100 need CTE
With PopvsVac (Continent, Location, Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccines vac
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null 
--Order by 2,3)
)
select *, (RollingPeopleVaccinated/population)*100 from PopvsVac

--Creating View to store data for visulizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccines vac
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null 
--Order by 2,3)

select * from PercentPopulationVaccinated


Create View OverallGlobalPercentage as
select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortifolioProject..CovidDeaths
where continent is not null
--group by date
--order by 1,2

Create View HighestInfRatePerPopulation as
Select Location, MAX(total_cases) as HighestInfectionCount, population,MAX((total_cases/population)*100 )as ContractedPercentage
FROM PortifolioProject..CovidDeaths
WHERE continent is not null
group by Location,population
--order by ContractedPercentage desc

Create View CasevsDeathUSA as
Select Location,date, total_cases, total_deaths AS deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortifolioProject..CovidDeaths 
WHERE Location like '%states%' and continent is not null
--order by 1,2