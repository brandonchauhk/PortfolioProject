--select * from PortfolioProject..CovidDeaths order by 3,4

--select * from PortfolioProject..CovidVaccinations order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population 
--From PortfolioProject..CovidDeaths
--Order by 1,2

--looking at total cases vs total death

--select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--order by 1,2

--looking at total cases vs population
select location, date, population, total_cases, (total_cases / population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths and 
--where location like '%states%'
where continent is not null
order by 1,2

select location, population, max(total_cases) as HigestInfectionCount, max((total_cases / population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc;

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

-- break things down by continent
-- Showing contintents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continents with the highest death count per population

--Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


select * from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and 
dea.location = vac.location

--Looking at total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and 
dea.location = vac.location
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and 
dea.location = vac.location
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and 
dea.location = vac.location
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.date = vac.date and 
dea.location = vac.location
where dea.continent is not null
--order by 2,3

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null