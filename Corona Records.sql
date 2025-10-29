select * from Portfolio_Project ..CovidDeaths$
order by 3,4

--select * from Portfolio_Project ..CovidVaccinations$
--order by 3,4

--select data that we are going to use

select Location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project ..CovidDeaths$
order by 1,2

--Look at Total cases vs Total deaths
--likelihood of dying in your country if you contract covid 
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths$
where Location like '%pakistan%'
order by 1,2


--Look at Total cases vs Population
--what percentage of population got covid

select Location,date,Population,total_cases,(total_cases/Population)*100 as Populationpercentage
from CovidDeaths$
where Location like '%pakistan%'
order by 1,2

--Looking at the countries with highest infection rate with respect to population

select Location,Population,max(total_cases) as max_cases,max(total_cases/Population)*100 as maxPopulationpercentage
from CovidDeaths$
group by Location,Population
order by 4 desc

--Showing countries with highest death counts per population

select Location,Population,max(cast(total_deaths as int)) as max_deaths,max(total_deaths/Population)*100 as maxPopulationpercentage
from CovidDeaths$
where continent is not null
group by Location,Population
order by 3 desc

--Lets break thiings down by continent

select location,max(cast(total_deaths as int)) as max_deaths
from CovidDeaths$
where continent is null
group by location
order by max_deaths desc

---Think Globally

select date,sum(new_cases) as totalcase,sum(cast(new_deaths as int)) as totaldeath,(sum(cast(new_deaths as int))/sum(new_cases) ) as percentagetotal
from Portfolio_Project ..CovidDeaths$
where continent is not null
group by date
order by 1,2 desc

--Now Joining two tables on date and location
--Looking at total population vs vaccination

select cd.continent,cd.location, cd.date ,cd.population,cv.new_vaccinations from Portfolio_Project ..CovidDeaths$ as cd
join Portfolio_Project ..CovidVaccinations$ as cv
  on cd.location=cv.location
  and cd.date=cv.date
  where cd.continent is not null
order by 1,2 desc

--now,for this above query,i need to add these new_vaccination as a rolling sum therefore i will use the window function

select cd.continent,cd.location, cd.date ,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date) as rolling_sum_vaccinated
from Portfolio_Project ..CovidDeaths$ as cd
join Portfolio_Project ..CovidVaccinations$ as cv
  on cd.location=cv.location
  and cd.date=cv.date
  where cd.continent is not null
order by 2,3

--now,i want to use the rollingsum to check much of population in that country got vaccinated

--USE OF CTE FOR POPULATION VERSUS Vaccination 

with CTE_1(continent,location,date ,population,new_vaccinations,rolling_sum_vaccinated)
as
(select cd.continent,cd.location, cd.date ,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date) as rolling_sum_vaccinated
from Portfolio_Project ..CovidDeaths$ as cd
join Portfolio_Project ..CovidVaccinations$ as cv
  on cd.location=cv.location
  and cd.date=cv.date
  where cd.continent is not null
--order by 2,3
)
select *,(rolling_sum_vaccinated/population)*100 as percentvaccinated
from CTE_1

--Temp Table (we can create temporary table instead of CTE as well in order to access)

Drop table if exists total_percentage_vaccinated
Create table total_percentage_vaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_sum_vaccinated numeric
)

Insert into total_percentage_vaccinated
select cd.continent,cd.location, cd.date ,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date) as rolling_sum_vaccinated
from Portfolio_Project ..CovidDeaths$ as cd
join Portfolio_Project ..CovidVaccinations$ as cv
  on cd.location=cv.location
  and cd.date=cv.date
 where cd.continent is not null
--order by 2,3
select *,(rolling_sum_vaccinated/population)*100 as percentvaccinated
from total_percentage_vaccinated

--creating view to store data for later view

CREATE VIEW Populatedvaccine1 as 
select cd.continent,cd.location, cd.date ,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date) as rolling_sum_vaccinated
from Portfolio_Project ..CovidDeaths$ as cd
join Portfolio_Project ..CovidVaccinations$ as cv
  on cd.location=cv.location
  and cd.date=cv.date
 where cd.continent is not null
--order by 2,3

select* from Populatedvaccine1


