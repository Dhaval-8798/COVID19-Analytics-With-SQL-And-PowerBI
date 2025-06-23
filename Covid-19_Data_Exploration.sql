/*
Covid 19 Data Exploration 

Platform used: pgAdmin (PostgreSQL)
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

This project involved creating tables, importing data from CSV files, and performing SQL-based analysis 
on global COVID-19 cases, deaths, and vaccination trends using pgAdmin.
Author: Dhaval Pandya
*/

-- Creating the Covid_Deaths table to store global COVID-19 case and death statistics,
-- and importing the corresponding data from a CSV file into the table.
CREATE TABLE Covid_Deaths(
iso_code VARCHAR(50),
continent VARCHAR(100),
location VARCHAR(100),
date DATE,
population BIGINT ,
total_cases BIGINT,
new_cases BIGINT,
new_cases_smoothed NUMERIC,
total_deaths BIGINT,
new_deaths BIGINT,
new_deaths_smoothed NUMERIC ,
total_cases_per_million	NUMERIC ,
new_cases_per_million NUMERIC,
new_cases_smoothed_per_million NUMERIC,
total_deaths_per_million NUMERIC,
new_deaths_per_million NUMERIC,
new_deaths_smoothed_per_million NUMERIC,
reproduction_rate DECIMAL(10,2),
icu_patients BIGINT ,
icu_patients_per_million NUMERIC,
hosp_patients BIGINT,
hosp_patients_per_million NUMERIC,
weekly_icu_admissions NUMERIC,
weekly_icu_admissions_per_million NUMERIC,
weekly_hosp_admissions NUMERIC,
weekly_hosp_admissions_per_million NUMERIC
)

SELECT * FROM Covid_Deaths;

/*
Creating the Covid_Vaccinations table to store country-level COVID-19 vaccination data,
including test counts, vaccination rates, population demographics, and health indicators.
The data is then imported from a CSV file into the table for further analysis.
*/

CREATE TABLE Covid_Vaccinations(
iso_code VARCHAR(50),
continent VARCHAR(100),
location VARCHAR(100),
date DATE,
new_tests BIGINT,
total_tests BIGINT,
total_tests_per_thousand NUMERIC,
new_tests_per_thousand NUMERIC,
new_tests_smoothed BIGINT,
new_tests_smoothed_per_thousand NUMERIC,
positive_rate NUMERIC,
tests_per_case NUMERIC,
tests_units VARCHAR(100),
total_vaccinations BIGINT,
people_vaccinated BIGINT,
people_fully_vaccinated BIGINT,
new_vaccinations BIGINT,
new_vaccinations_smoothed BIGINT,
total_vaccinations_per_hundred NUMERIC,
people_vaccinated_per_hundred NUMERIC,
people_fully_vaccinated_per_hundred NUMERIC,
new_vaccinations_smoothed_per_million NUMERIC,
stringency_index NUMERIC,
population_density NUMERIC,
median_age NUMERIC,
aged_65_older NUMERIC,
aged_70_older NUMERIC, 
gdp_per_capita NUMERIC,
extreme_poverty NUMERIC,
cardiovasc_death_rate NUMERIC,
diabetes_prevalence NUMERIC,
female_smokers NUMERIC,
male_smokers NUMERIC,
handwashing_facilities NUMERIC,
hospital_beds_per_thousand NUMERIC,
life_expectancy NUMERIC,
human_development_index NUMERIC
)

SELECT * FROM Covid_Vaccinations;



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date,
total_cases, total_deaths,
ROUND((total_deaths * 100.0 / total_cases), 5) AS death_percentage
FROM Covid_Deaths
WHERE location LIKE '%India%'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date,
population, total_deaths,
ROUND((total_cases * 100.0 / population), 5) AS Percent_Population_Infected
FROM Covid_Deaths
ORDER BY location,date;


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, 
MAX(total_cases) AS Highest_Infection_Count,
ROUND(MAX(total_cases) * 100.0 / Population, 4) AS Percent_Population_Infected
FROM Covid_Deaths
WHERE total_cases IS NOT NULL AND Population IS NOT NULL
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC;


-- Countries with Highest Death Count (excluding NULL death values)

SELECT location, 
MAX(CAST(total_deaths AS INTEGER)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- Breaking Things Down by Continent
-- Showing continents with the highest total death count per population

SELECT continent, 
MAX(CAST(total_deaths AS INTEGER)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Numbers
-- Summarizing total cases, total deaths, and global death percentage

SELECT SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS INTEGER)) AS total_deaths, 
ROUND(SUM(CAST(new_deaths AS INTEGER)) * 100.0 / SUM(new_cases), 5) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one COVID vaccine
-- Only includes records where new_vaccinations is not null

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INTEGER)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
        AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULLAND vac.new_vaccinations IS NOT NULL
ORDER BY dea.location, dea.date;

-- CTE to calculate Rolling Vaccinations and % Population Vaccinated
WITH PopVsVac AS (
  SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INTEGER)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)

-- Final SELECT with percentage calculation
SELECT *, 
ROUND((rolling_people_vaccinated * 100.0) / population, 4) AS percent_population_vaccinated
FROM PopVsVac;

-- Create View to store the result for dashboards/queries

CREATE OR REPLACE VIEW percent_population_vaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INTEGER))  OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL;


--COVID-19 Advanced Data Analysis

-- Global Vaccination Trend Over Time
-- Tracks daily and cumulative new vaccinations worldwide

SELECT date,
SUM(CAST(new_vaccinations AS INT)) AS daily_vaccinations,
SUM(SUM(CAST(new_vaccinations AS INT))) OVER (ORDER BY date) AS cumulative_vaccinations
FROM covid_vaccinations
WHERE new_vaccinations IS NOT NULL
GROUP BY date
ORDER BY date;


-- ICU Stress vs New Cases Over Time
-- Useful to study hospital burden during waves

SELECT 
    location,
    date,
    new_cases,
    icu_patients
FROM covid_deaths
WHERE icu_patients IS NOT NULL
AND new_cases IS NOT NULL
AND location LIKE '%State%' -- Change to any country
ORDER BY date;


-- Daily Deaths Trend for a Country
-- Can be plotted as a line graph for better visualization

SELECT 
    date,
    SUM(new_deaths) AS daily_deaths
FROM covid_deaths
WHERE location = 'India' -- Change as needed
AND new_deaths IS NOT NULL
GROUP BY date
ORDER BY date;


-- Stringency Index vs New Cases/Deaths
-- Helps analyze effect of government policies

SELECT 
    vac.location,
    vac.date,
    vac.stringency_index,
    dea.new_cases,
    dea.new_deaths
FROM covid_vaccinations vac
JOIN covid_deaths dea ON vac.location = dea.location AND vac.date = dea.date
WHERE vac.stringency_index IS NOT NULL
AND dea.new_cases IS NOT NULL
AND dea.location = 'India' -- Change to any country
ORDER BY vac.date;


-- Rolling People Vaccinated vs Population
-- Using a CTE (Common Table Expression)

WITH PopVsVac AS (
  SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INTEGER)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
  FROM covid_deaths dea
  JOIN covid_vaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL 
    AND vac.new_vaccinations IS NOT NULL
)
SELECT *, 
       ROUND((rolling_people_vaccinated::decimal / population) * 100, 2) AS percent_vaccinated
FROM PopVsVac;

-- Creating View for Dashboard Integration

CREATE OR REPLACE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INTEGER)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL;

/*
--------------------------------------------------------------------------------------
Covid-19 Data Exploration Project - Summary

Author  : Dhaval Pandya  
Date    : June 16, 2025

This SQL project performs comprehensive exploratory data analysis (EDA) on global 
COVID-19 data using PostgreSQL (pgAdmin). It utilizes real-world datasets covering 
COVID-19 cases, deaths, vaccinations, and government policy responses across countries.

Key Focus Areas:
- Trend analysis of total cases, deaths, and vaccinations globally and per country
- Death percentage and infection rates relative to population
- Vaccination progress over time using rolling totals and percentage calculations
- Continent-wise summaries of impact (deaths and infections)
- Daily trends in new cases, deaths, ICU admissions, and policy stringency
- Advanced use of CTEs, Window Functions, Joins, Aggregates, and Views
- Preparation of data for visualization dashboards

Key SQL Concepts Used:
✓ Joins  
✓ CTEs (Common Table Expressions)  
✓ Window Functions  
✓ Aggregate Functions  
✓ Type Casting and Data Conversion  
✓ Views for reporting and dashboard integration  

Tools Used:
- pgAdmin (PostgreSQL)
- Data imported via CSV files into custom-created tables

This project demonstrates the use of SQL for real-time health analytics and prepares
a clean, query-ready dataset for further visualization in BI tools like Tableau or Power BI.

--------------------------------------------------------------------------------------
*/
