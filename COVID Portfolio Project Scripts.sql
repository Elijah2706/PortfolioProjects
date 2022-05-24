select *
From PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Selecting Fields required

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Comparing Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%Canada%'
order by 1,2

-- Total Cases vs Population

Select Location, date, Population, total_cases, (total_cases / population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
-- Where Location like '%Canada%'
order by 1,2

-- Countries with Highest infection rates compared to its population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by Location, Population desc

-- Countries with highest Death Counts per Populations

Select Location, population, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by TotalDeathsCount desc

-- Breakup by continents

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathsCount desc

-- Global Number

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
-- Group by date
order by 1,2

-- Total World Vaccination vs Population

Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations
, SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Deaths.location Order by Deaths.location, Deaths.date) as CummulativeVaccinated
from PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations Vac
	On Deaths.location = Vac.location
	and Deaths.date = Vac.date
Where Deaths.continent is not null
order by 2,3

--- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, CummulativeVaccinated)
as
(
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations
, SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Deaths.location Order by Deaths.location, Deaths.date) as CummulativeVaccinated
-- , (CummulativeVaccinated/population)*100
from PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations Vac
	On Deaths.location = Vac.location
	and Deaths.date = Vac.date
Where Deaths.continent is not null
)
Select *, (CummulativeVaccinated/population)*100
From PopvsVac

-- Temp Table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
