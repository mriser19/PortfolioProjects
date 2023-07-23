Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3, 4


--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject.dbo.CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (Total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%states%'
order by 1, 2


--Looking at Countries with HIghest Infection Rate campared to Population 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Let's break things down by continent 

--Showing continents with the highest death count per population

Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
order by 1, 2


Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1, 2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated 
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3


-- Use CTE

With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated)
From PopvsVac



-- Temp Table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Laction nvarchar(255),
Date datetime,
Population numeric,
new_vaccincation numeric, 
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data fro later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated 
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated