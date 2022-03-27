Select*
From PortfolioProject..covidVaccinations
where continent is not null
order by 3,4

--Select*
--From PortfolioProject..covidDeaths
--order by 3,4

--Select data that we ae going to b using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covidDeaths
order by 1, 2


-- Looking at the Total Case vs Total Deaths
-- Shows likihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths
where location like 'Brazil'
order by 1, 2

-- looking at the total cases vs population
-- shows the percentage of population that has received covid

Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..covidDeaths
where location like 'Brazil'
order by 1, 2

--looking at Countries with the highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/total_cases))*100 as PercentPopulationInfected
From PortfolioProject..covidDeaths
--where location like 'Brazil'
Group by location, population
order by PercentPopulationInfected desc


--showing the countries with the hightest Death count per population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covidDeaths
where continent is not null
--where location like 'Brazil'
Group by location
order by TotalDeathCount desc

--global numbers

Select date, SUM(new_cases) as totalNewWordlyCases, Sum(cast(new_deaths as int)) as TotalNewWorldlyDeaths, Sum(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..covidDeaths
where continent is not null
group by date
order by 1, 2

--Total World Death Percentage
Select SUM(new_cases) as totalNewWordlyCases, Sum(cast(new_deaths as int)) as TotalNewWorldlyDeaths, Sum(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..covidDeaths
where continent is not null
order by 1, 2

--joining two datasets together by location and date
select *
from PortfolioProject..covidVaccinations vac
join PortfolioProject..covidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..covidVaccinations vac
join PortfolioProject..covidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--have a running count of vaccines per location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccCount
, (RollingVaccCount/population)*100
from PortfolioProject..covidVaccinations vac
join PortfolioProject..covidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingVaccCount
--, (RollingVaccCount/population)*100
from PortfolioProject..covidVaccinations vac
join PortfolioProject..covidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingVaccCount/Population)*100
From PopVsVac

-- Temp Table

drop Table if exists #PercPopuVacc
Create Table #PercPopuVacc
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccCount numeric
)

Insert into #PercPopuVacc
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingVaccCount
--, (RollingVaccCount/population)*100
from PortfolioProject..covidVaccinations vac
join PortfolioProject..covidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from #PercPopuVacc

--creating View to store data for later Visualizations

create view #PercPopuVacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingVaccCount
--, (RollingVaccCount/population)*100
from PortfolioProject..covidVaccinations vac
join PortfolioProject..covidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
