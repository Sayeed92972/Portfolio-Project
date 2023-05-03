select *
from covid_death

select location, date, total_cases, new_cases, total_deaths, population
from covid_death
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from covid_death
where location like 'Bangladesh'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of people got covid
select location, date,  population, total_cases, (total_cases/population)*100 as percentPopulationInfected
from covid_death
where location like 'Bangladesh'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location,  population, max(total_cases) as highestInfectedCount, max((total_cases/population)*100) as percentPopulationInfected
from covid_death
--where location like 'Bangladesh'
where continent is not null
group by location, population
order by percentPopulationInfected desc

-- Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from covid_death
--where location like 'Bangladesh'
where continent is not null
group by location
order by TotalDeathCount desc

--Let's check total death count by continent
--showing the continents with highest death per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covid_death
--where location like 'Bangladesh'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Total cases vs total deaths globally

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as Death_Percentage
from covid_death
--where location like 'Bangladesh'
where continent is not null
--group by date
--order by 1,2

--Looking at Total Population vs Vaccination
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from covid_death as dea
join covid_vac as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

--Use CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
	select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
	,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/dea.population)*100
	from covid_death as dea
	join covid_vac as vac
		on dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac

--Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
  continent VARCHAR,
  location VARCHAR,
  date DATE,
  population NUMERIC,
  new_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

insert into PercentPopulationVaccinated

select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
	,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/dea.population)*100
	from covid_death as dea
	join covid_vac as vac
		on dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null;
	
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

--Create view to store data for later visualization
Create view PercentPopulationVaccinated as
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
	,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/dea.population)*100
	from covid_death as dea
	join covid_vac as vac
		on dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null;

select * 
from PercentPopulationVaccinated