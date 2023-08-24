

Select * from 
PortfolioProject..CovidDeathscsv
where continent is null
-- Selecting Data that is going to use

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeathscsv


-- Looking at total cases vs total deaths

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeathscsv


-- Looking at the countries with highest infection rate

Select location, 
max(total_cases) as 'Total infected',population
from PortfolioProject..CovidDeathscsv
where location like 'india'
group by location,population;


Select  continent,max(cast(total_deaths as int)) as 'Total infected'     
from PortfolioProject..CovidDeathscsv
where continent is not null
group by continent

--- Breaking things down by continent..
-- Showing countries with highest deat rate per population

Select location, max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeathscsv
-- where location like 'india'
where continent is null
group by location,population
order by TotalDeaths desc;


-- Global numbers

Select SUM(cast (new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast (new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeathscsv
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by convert(varchar(10),dea.location), dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeathscsv dea 
join PortfolioProject..CovidVaccinationscsv vac
On dea.location = vac.location
	and dea.date = vac.date

	where dea.continent is not null
	order by 2,3;


	-- Using CTE to perform Calculation on Partition By in previous query

	With PopvsLoc (continent,llocation,date,population,new_vaccinations,RollingPeopleVaccinated)
	as(
	Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by convert(varchar(10),dea.location), dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeathscsv dea 
join PortfolioProject..CovidVaccinationscsv vac
On dea.location = vac.location
	and dea.date = vac.date

	where dea.continent is not null
	)

	Select *, (RollingPeopleVaccinated/convert(float,population)) *100
	from PopvsLoc;


	-- temp tables
	Drop Table  if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	continent nvarchar(255),
	locaton nvarchar(255),
	date Datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)


	Insert into #PercentPopulationVaccinated

	Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by convert(varchar(10),dea.location), dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeathscsv dea 
join PortfolioProject..CovidVaccinationscsv vac
On dea.location = vac.location
	and dea.date = vac.date

	where dea.continent is not null

	Select *, (RollingPeopleVaccinated/convert(float,population)) *100
	from #PercentPopulationVaccinated;


	-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by convert(varchar(10),dea.location), dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeathscsv dea 
join PortfolioProject..CovidVaccinationscsv vac
On dea.location = vac.location
	and dea.date = vac.date

	where dea.continent is not null