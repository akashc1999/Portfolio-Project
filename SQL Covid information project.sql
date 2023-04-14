Select *
From [Portfolio project]..Coviddeaths
where continent is not null
order by 3,4

Select *
From [Portfolio project]..Covidvaccination
order by 3,4

--Select Data that we are going to be using...

Select Location, date, total_cases, new_cases, total_deaths, population_density
From [Portfolio project]..Coviddeaths
order by 1,2


--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, population_density, total_cases,  (total_cases/population_density)*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population_density, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/Population_density))*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population_density
order by 1,2

Select Location, Population_density, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/Population_density))*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population_density
order by PercentPopulationInfected desc

-- Countries with Highest Infection Rate compared to Population

Select Location,MAX(cast(Total_Deaths as int))as TotalDeathCount
From [Portfolio project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Lets Break Things Down By Continent

-- Showing contintents with the highest death count per population


Select continent, MAX(cast(Total_Deaths as int))as TotalDeathCount
From [Portfolio project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2 

--Join Coviddeaths and Covidvaccination table

Select *
from [Portfolio project]..Coviddeaths dea
join [Portfolio project]..Covidvaccination vac
    On dea.location = vac.location
	and dea.date = vac.date


--Looking at Total population vs vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.Population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..Coviddeaths dea
join [Portfolio project]..Covidvaccination vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..Coviddeaths dea
Join [Portfolio project]..Covidvaccination vac
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
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..Coviddeaths dea 
Join [Portfolio project]..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for for later visualization--

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..Coviddeaths dea 
Join [Portfolio project]..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From PercentPopulationVaccinated





