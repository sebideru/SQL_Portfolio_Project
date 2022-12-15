select * from dbo.CovidDeaths$
order by 1,2

select location,date,total_cases,new_cases,total_deaths from dbo.CovidDeaths$
order by 1,2

--total cases vs total Deaths 

select location,date,total_cases,total_deaths,round((total_deaths/total_cases) * 100,2) as Death_Percentage from dbo.CovidDeaths$
where location like '%states%'
order by 1,2

----looking at the total cases vs population
select location,date,population,total_cases,total_deaths,round((total_cases/population) * 100,2) as Death_Percentage from dbo.CovidDeaths$
where location like '%states%'
order by 1,2

--Looking for Countries with higest infection rate

select location, population,max(total_cases) as higestinfectionCount, max(round((total_cases/population) * 100,2)) as PercentPopulationInfected from dbo.CovidDeaths$
--where location like '%states%'
group by population,location
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per popuations

select location,max(cast(total_deaths as int)) as higestDeathCount, max(round((total_deaths/total_cases) * 100,2)) as PercentPopulationInfected from dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by higestDeathCount desc

--Highest death by continent
select location,max(cast(total_deaths as int)) as higestDeathCount from dbo.CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by higestDeathCount desc

--showing the contintents with the highest death count per population 

select continent,max(cast(total_deaths as int)) as higestDeathCount from dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by higestDeathCount desc

--Global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage from dbo.CovidDeaths$--,total_deaths,round((total_deaths/total_cases) * 100,2) as Death_Percentage from dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum( cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations$ vac on 
dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with popvsvac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum( cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations$ vac on 
dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from popvsvac

--TEMP Table

drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric 
)

insert into #PercentPopulationVaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations$ vac on 
dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *,round((RollingPeopleVaccinated/population)* 100,2) as VaccinatedPercentage
from #PercentPopulationVaccinated 

--Creating view to store for later data visulazations
drop view if exists PercentPopulationVaccinated
Go
create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum( cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations$ vac on 
dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
Go
	
select * from PercentPopulationVaccinated 