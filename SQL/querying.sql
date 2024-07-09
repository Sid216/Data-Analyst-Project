--select data to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--total cases vs total deaths
select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as Death_Percentage
from PortfolioProject..CovidDeaths$
where location='India'
order by 1,2

--total cases vs population
select location, date, total_cases, population, ((total_cases/population)*100) as Population_Percentage
from PortfolioProject..CovidDeaths$
where location='India'
order by 1,2

--looking at countries with the highest infection rate compared to population
select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population)*100) as Percent_Population_Infected
from PortfolioProject..CovidDeaths$
group by population, location
order by Percent_Population_Infected desc

--looking at countries with highest death count/population
select location, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths$
where continent is not null
group by  location
order by  Total_Death_Count desc

--looking at countries with highest death count/population using continents
select continent, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths$
where continent is not null
group by  continent
order by  Total_Death_Count desc

-- global numbers
select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, (sum(new_cases)/sum(cast(new_deaths as int)))/100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location='India'
where continent is not null
group by date
order by DeathPercentage desc

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Count
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using cte for the previous query because we can't use Rolling_Count to calculate
--percent of population vaccinated
with PopvsVac (Continent, location, Date, Population, new_vaccinations, Rolling_Count)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Count
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Rolling_Count/Population)*100 from PopvsVac

--temp table or previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_Count numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Count
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (Rolling_Count/Population)*100 from #PercentPopulationVaccinated

--creating a view

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Count
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidDeaths$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3