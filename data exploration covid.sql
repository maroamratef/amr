SELECT *
FROM [portoflio project].[dbo].[CovidDeaths]
order by 3,4;
-- 2. The Sorting Mechanism (ORDER BY 3, 4)The ORDER BY clause sorts your query results. Instead of typing out the actual names of the columns, you used numerical shortcuts (3, 4), which refer to the column positions from left to right:3 (Column 3 - location): SQL Server looks at the 3rd column in your dataset—which in this specific Covid dataset is the country/location. It sorts all rows alphabetically by country (e.g., Afghanistan, Albania, Algeria...).4 (Column 4 - date): SQL Server looks at the 4th column—which is the date. Because it comes second in your command, it acts as a secondary sort. For every specific country, it will sort the rows chronologically from the oldest date to the newest date.

--SELECT *
--FROM [portoflio project].[dbo].[CovidVaccinations]
--order by 3,4;

--select data that we are using
select location,date,total_cases,new_cases,total_deaths,population
from [portoflio project].[dbo].[CovidDeaths] 
order by 1,2;

--looking at total cases vs total deaths
--shows the likelihood of deaths if contract the covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentpopulationinfected
from [portoflio project].[dbo].[CovidDeaths] 
where location like '%states%'
order by 1,2;

--looking at total cases vs populations
--shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as percentpopulationinfected
from [portoflio project].[dbo].[CovidDeaths] 
--where location like '%states%'
order by 1,2;

--looking to countries with highest infection rate compared to population
select location ,population ,max(total_cases) as highestinfectioncount ,max((total_cases/population))*100 as percentpopulationinfected
from [portoflio project].[dbo].[CovidDeaths] 
group by location ,population
order by percentpopulationinfected desc ;
--GROUP BY bundles all rows that have the same country and population together into a single row 

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [portoflio project].[dbo].[CovidDeaths] 
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [portoflio project].[dbo].[CovidDeaths] 
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [portoflio project].[dbo].[CovidDeaths] 
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 .,1. SUM(...) OVER (...)The OVER clause turns a normal SUM() function into a window function. Instead of collapsing all rows into a single summary row (like a standard GROUP BY), it calculates a total across a set of rows while keeping every individual daily row visible in your output [0.4, 0.5].2. CONVERT(int, vac.new_vaccinations)This forces the new_vaccinations column data type to become an integer (whole number) before adding them together [0.8]. This is done because numeric data imported from Excel or CSV files often enters SQL Server as text (varchar), which you cannot mathematically add up [0.8].3. Partition by dea.LocationThis acts like a local boundary line. It tells SQL Server to calculate the running total only within the current country.As long as the location is "Afghanistan", the total keeps growing day by day.The moment the row changes to "Albania", the calculator resets back to 0 and starts a brand new rolling sum for Albania.4. Order by dea.location, dea.DateThis establishes the sequential timeline for your calculator. It tells SQL Server to add the numbers chronologically day-by-day. Without this Order by statement inside the window function, SQL would just add all the data for that country together at once and show the final, static grand total on every single row instead of a daily rolling sum [0.4].How the Output Looks Under the HoodLocationDateNew_VaccinationsRollingPeopleVaccinatedCanada2021-01-011,0001,000Canada2021-01-021,5002,500 (1000 + 1500)Canada2021-01-032,0004,500 (2500 + 2000)Egypt2021-01-01500500 (Resets here!)
From [portoflio project].[dbo].[CovidDeaths]dea
Join[portoflio project].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portoflio project].[dbo].[CovidDeaths]dea
Join[portoflio project].[dbo].[CovidVaccinations] vac
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portoflio project].[dbo].[CovidDeaths]dea
Join[portoflio project].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portoflio project].[dbo].[CovidDeaths]dea
Join[portoflio project].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
