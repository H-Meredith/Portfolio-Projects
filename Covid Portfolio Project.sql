select *
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from [Portfolio Project].dbo.CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases, (Total_cases/population)*100 as PercentagePopulation
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as 
	PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
--where location like '%states'
Group by location, population
Order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int )) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states'
where continent is not null
Group by location 
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

Select continent, Max(cast(total_deaths as int )) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states'
where continent is not null
Group by continent 
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int )) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states'
where continent is not null
Group by continent 
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Looking at total population vs vaccinations
-- Use CTE

with PopsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (rollingpeoplevaccinated/population)*100
from PopsVac

-- Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

--order by 2,3

select*, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later for visualizations

Use [Portfolio Project]
Go
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated