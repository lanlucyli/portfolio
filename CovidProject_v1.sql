select *
from Portfolio..CovidDeaths
order by 3,4

--select *
--from Portfolio..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolio..CovidDeaths
order by 1,2

select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolio..CovidDeaths
where location like '%states%'
order by 1,2

select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolio..CovidDeaths
where location like 'Afghan%'
order by 1,2

--total cases vs population
select location, date, total_cases, population, total_deaths,(total_cases/population)*100 as percentpopulationinfected
from portfolio..CovidDeaths
where location like '%states%'
order by 1,2

select location, date, total_cases, population, total_deaths,(total_cases/population)*100 as percentpopulationinfected
from portfolio..CovidDeaths
where location ='Brazil'
order by 1,2

--highest infection rate per population
select location, population, Max(total_cases) highestinfectioncount, max(total_cases/population)*100 as highestinfectionrate
from portfolio..CovidDeaths
group by location, population
order by highestinfectionrate desc

--highest death count per population
select location,  max(cast(total_deaths as int)) as totaldeathcount
from portfolio..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

--by continent
select location,  max(cast(total_deaths as int)) as totaldeathcount
from portfolio..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc

select continent,  max(cast(total_deaths as int)) as totaldeathcount
from portfolio..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--highest death rate per location
select location, population, max(cast(total_deaths as int)/population)*100 as totaldeathpercentage
from portfolio..CovidDeaths
where continent is not null /*and location like '%states%'*/
group by location, population
order by totaldeathpercentage desc

--global number

select date, sum(new_cases)as totalcases, sum(cast(new_deaths as int))as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolio..CovidDeaths
where continent is not null
group by date
order by 4 desc

select sum(new_cases)as totalcases, sum(cast(new_deaths as int))as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolio..CovidDeaths
where continent is not null


select distinct location, avg(population) over (partition by location) as populationpercountry
from Portfolio..CovidDeaths
where continent is not null


select sum(population) totalpopulation
from Portfolio..CovidDeaths
where continent is not null


select * 
from Portfolio..CovidVaccinations


--looking at total population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location)
from Portfolio..CovidDeaths dea 
join Portfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--rollingpeoplevaccinated/population*100
from Portfolio..CovidDeaths dea 
join Portfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE
with popvsvac (continent, location, date, population, new_vaccinations,rollingpeoplevaccinated)
as 
(
select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--rollingpeoplevaccinated/population*100
from Portfolio..CovidDeaths dea 
join Portfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as vaccinatedpercentage
from popvsvac


--temp
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--rollingpeoplevaccinated/population*100
from Portfolio..CovidDeaths dea 
join Portfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100 as vaccinatedpercentage
from #percentpopulationvaccinated

--create view to store datea for later
create view percentpopulationvaccinated
as
select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--rollingpeoplevaccinated/population*100
from Portfolio..CovidDeaths dea 
join Portfolio..CovidVaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null

select * from percentpopulationvaccinated
