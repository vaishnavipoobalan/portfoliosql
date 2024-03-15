
Select * 
from PortfolioProject..CovidDeaths$
order by 3,4


--Select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2

-- Shows perecntage for population to cases got covid

Select Location, Date, total_cases, population, (total_cases/population)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$
--where location like '%india%'
order by 1,2

--- Show highest infected country

Select Location, population, Max(total_cases) as HInfected, max((total_cases/population))*100 as Infectedpercentage
from PortfolioProject..CovidDeaths$
--where location like '%india%'
group  by location, population
order by Infectedpercentage desc

--- Countries with the highest death count per population

Select Location, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
group  by location
order by Totaldeathcount desc

--- Break down by continent

Select continent, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
group  by continent
order by Totaldeathcount desc

--- Global numbers

Select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--- joining two tables

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.continent = vac.continent
	and dea.location = vac.location

--- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevac
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.date = vac.date
	and dea.location = vac.location
	where dea.continent is not null
	order by 2,3

-- with CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevac)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevac
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.date = vac.date
	and dea.location = vac.location
	where dea.continent is not null
	--order by 2,3
)
select *,(rollingpeoplevac/population)*100
from popvsvac


--- create  table for visualization 

Create table #peoplepopvacinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevcacinated numeric
)
Insert into #peoplepopvacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevac
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.date = vac.date
	and dea.location = vac.location
	where dea.continent is not null
	--order by 2,3

-- create view table

CREATE VIEW peoplepopvacinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevac
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.date = vac.date
	and dea.location = vac.location
	where dea.continent is not null
	--order by 2,3
