# COVID19-Analytics-With-SQL-And-PowerBI
An end-to-end data analysis and visualization project using SQL and Power BI

COVID-19 Global Impact Dashboard | Data Exploration using PostgreSQL and Power BI | Advanced Visualizations and Insights


---

##  Tools & Technologies Used

- **pgAdmin (PostgreSQL)** – for querying and data exploration
- **Power BI Desktop** – for creating visual dashboards
- **SQL** – Joins, CTEs, Temp Tables, Views, Window Functions, Aggregations

---

##  SQL Data Exploration

Performed in PostgreSQL using raw CSV files (not uploaded for size/privacy). Key operations:

- Created tables from CSV files (`covid_deaths`, `covid_vaccinations`)
- Cleaned nulls and unnecessary columns
- Created Views for percentage metrics
- Calculated key insights like:
  - Global Death Rate
  - Countries with highest death/infection counts
  - Percent of population infected/vaccinated
  - Daily trends in cases, deaths, vaccinations
  - Government stringency vs case trends

📄 SQL script: [`Covid-19_Data_Exploration.sql`](./Covid-19_Data_Exploration.sql)


---

##  Power BI Dashboard Highlights

🔹 **Filters**: Slicers by Continent, Country, and Month  
🔹 **KPIs**:  
- Total Cases  
- Total Deaths  
- Death Rate  
- Total Vaccinations  

🔹 **Visuals**:
- Total Cases, Deaths, Death Rate, and Vaccination KPIs (card visuals)
- Global COVID-19 Total Cases (map visual)
- COVID-19 New Cases Trend Over Time (line chart)
- COVID-19 Deaths by Continent (bar chart)
- COVID-19 Vaccination Progress Over Time (line-area chart)
- Top 10 Locations by Vaccination Rate (horizontal bar chart)
- Monthly New COVID-19 Cases and MoM % Change (clustered column + line combo chart)

🗂 PBIX File: [`Covid_Trend_and_Case_Analysis.pbix`](./Covid_Trend_and_Case_Analysis.pbix)


---

##  How to View Power BI Dashboard

1. Download `Covid_Trend_and_Case_Analysis.pbix`
2. Open it using **Power BI Desktop**
3. Interact with the slicers and visuals


---

##  Author

**Dhaval Pandya**  
Final Year Computer Science Student | SQL & Power BI Enthusiast  

---

##  License

This project is for learning and portfolio purposes only. Data credits go to [Our World In Data](https://ourworldindata.org/coronavirus-source-data).

