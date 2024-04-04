SELECT *
  FROM [Project].[dbo].[CovidDeaths]
  where continent is not null
  order by 3,4

  SELECT location, date,total_cases, new_cases, total_deaths, population
  FROM [Project].[dbo].[CovidDeaths]
  where continent is not null
  order by 3,4

-- list of countries and continent that reported
select location
from Project.dbo.CovidDeaths
group by location
order by 1

--Total cases vs Total deaths
-- shows liklihood of dying from contracting covid
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM [Project].[dbo].[CovidDeaths]
  where continent is not null and location like '%states%' 
  order by 1,2
  
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM [Project].[dbo].[CovidDeaths]
  where continent is not null and location like '%Nigeria%' 
  order by 1,2

--Total cases vs Population
-- shows what percentage of population got covid
SELECT location, date,population,total_cases,  (total_cases/population)*100 as InfectionPercentage
  FROM [Project].[dbo].[CovidDeaths]
  where location like '%Nigeria%'
  and continent is not null
  order by 1,2

--Countries wuth highest infection rate compared with population
SELECT location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as InfectionPercentage
  FROM [Project].[dbo].[CovidDeaths]
  --where location like '%Nigeria%'
  group by location, population
  order by 4 desc


--Countries with highest death rate compared with population
SELECT location, max(cast(total_deaths as int)) as HighestDeathRate
  FROM [Project].[dbo].[CovidDeaths]
  --where location like '%Nigeria%'
  where continent is not null
  group by  location
  order by 2 desc




--continent with highest death rate compared with population
SELECT location, max(cast(total_deaths as int)) as HighestDeathRate
  FROM [Project].[dbo].[CovidDeaths]
  --where location like '%Nigeria%'
  where continent is null
  group by  location
  order by 2 desc


SELECT Continent, max(cast(total_deaths as int)) as HighestDeathRate
  FROM [Project].[dbo].[CovidDeaths]
  --where location like '%Nigeria%'
  where continent is not null
  group by  continent
  order by 2 desc

--Global Rate of infection, date per day
SELECT date, SUM(new_cases) as TotalInfectionRate, 
	SUM(cast( new_deaths as int)) as TotalDeathRate,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
  FROM [Project].[dbo].[CovidDeaths]
  where continent is not null
  group by date
  order by 1,2

SELECT  SUM(new_cases) as TotalInfectionRate, 
	SUM(cast(new_deaths as int)) as TotalDeathRate,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
  FROM [Project].[dbo].[CovidDeaths]
  where continent is not null
  order by 1,2

  SELECT  SUM(new_cases) as TotalInfectionRate, 
	SUM(cast(new_deaths as int)) as TotalDeathRate,
	sum(cast(total_deaths as int))/sum(total_cases)*100 as DeathPercentage
  FROM [Project].[dbo].[CovidDeaths]
  where location like 'world'
  order by 1,2


  -- total population vs vaccination

 select *
 from Project.dbo.CovidDeaths as dea
 join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- create a cte to enable us use the data we got from rollingPeopleVaccinated

with PopvsVac (Continent, Date, location, Populaion, New_vaccinations, RollingPeopleVaccinated) as
(
 select dea.continent, 
 dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert (int, vac.new_vaccinations)) 
 over (partition  by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from Project.dbo.CovidDeaths as dea
 join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated / Populaion) *100 as PercentageRollingPeopleVaccinated
from PopvsVac
order by 2,3

-- create a temp table to enable us use the data we got from rollingPeopleVaccinated

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
  select dea.continent, 
 dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert (int, vac.new_vaccinations)) 
 over (partition  by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from Project.dbo.CovidDeaths as dea
 join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccinated / population) *100 as PercentageRollingPeopleVaccinated
from #PercentagePopulationVaccinated


-- CEATING A VIEW FOR THE PURPOSE OF VISUALING

drop view if exists PercentagePopulationVaccinated
create view PercentagePopulationVaccinated as
 select dea.continent, 
 dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert (int, vac.new_vaccinations)) 
 over (partition  by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from Project.dbo.CovidDeaths as dea
 join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select*
from PercentagePopulationVaccinated