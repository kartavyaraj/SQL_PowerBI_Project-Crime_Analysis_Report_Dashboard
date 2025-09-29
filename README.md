# Crime Analysis and Dashboard Project

_Interactive Crime Analysis Report & Dashboard built with SQL, Power BI, and DAX, visualizing 40,000+ crime cases in India (2020–2024). Explore trends, city-wise distribution, victim demographics, weapon usage, and temporal patterns for actionable insights._


## Table of Contents  

1. <u>[Overview](#overview)</u>  
2. <u>[Screenshot](#screenshot)</u>  
3. <u>[Project Description](#project-description)</u>  
4. <u>[Project Objective](#project-objective)</u>  
5. <u>[Dataset Description](#dataset-description)</u>  
6. <u>[Data Exploration & Analysis](#data-exploration--analysis)</u>
7. <u>[Dashboard Highlights](#dashboard-highlights)</u> 
8. <u>[Key Insights](#key-insights)</u>  
8. <u>[Tools & Skills Used](#tools--skills-used)</u>  
9. <u>[How to Use This Project](#how-to-use-this-project)</u>  
10. <u>[Conclusion](#conclusion)</u>  
11. <u>[Author](#author)</u>  
12. <u>[Contact](#contact)</u>  



## Overview
A dynamic dashboard providing actionable insights into crime patterns, helping authorities and analysts make data-driven decisions.

Highlights:

- **Data Cleaning & SQL Analysis**: Prepared and analyzed crime data for key trends.

- **KPIs & DAX Metrics**: Tracked peak crime periods, hotspots, and case closures.

- **Interactive Power BI Visuals**: Visualized crime by location, type, time, and demographics.

- **Insights Delivered**: Supports strategic planning and efficient resource allocation.


## Screenshot
![Dashboard Demo](<Dashboard Demonstration/Dashboard_Screenshot.jpg>)


## Project Description

Crime analysis is essential for understanding public safety, identifying patterns, and supporting strategic decision-making. This project leverages SQL and Power BI to clean and pre-process crime data, analyze multiple metrics, and create a dynamic dashboard that visualizes key performance indicators (KPIs) such as crime trends by day, month, and hour, hotspots by city, crime types, victim demographics, weapon usage, and case closure rates.


## Project Objective

The goal of this project is to analyze and visualize crime data, uncover patterns, and identify hotspots, enabling authorities and analysts to make data-driven decisions. The project leverages SQL and Power BI to transform raw data into actionable insights that enhance public safety and support effective decision-making and planning.


## Dataset Description

The Dataset used in this project is a CSV file contains detailed records of reported crimes and includes both original and derived columns to support comprehensive analysis and visualization. Key columns include:

- _report_number_: Unique identifier for each crime report.
- _date_reported / date_of_occurrence_: Dates when the crime was reported and when it occurred.
- _time_of_occurrence / hour_: Time and hour of the crime occurrence.
- _city_: Location where the crime took place.
- _crime_code / crime_description_: Classification and description of the crime.
- _victim_age / victim_age_group / victim_gender_: Demographic details of the victim.
- _weapon_used_: Weapon involved in the crime.
- _crime_domain_: Category or type of crime (e.g., theft, assault).
- _police_deployed_: Law enforcement units assigned to the case.
- _case_status / date_case_closed_: Status of the case and closure date.
- _year_: Year extracted from the date of occurrence for trend analysis.

This dataset combines raw data and derived columns such as victim_age_group and hour, enabling effective trend analysis, KPI computation, and interactive dashboard visualizations.

## Data Exploration & Analysis

The data exploration and analysis process was carried out in multiple steps to ensure accuracy and extract actionable insights from the crime dataset.

1. **Data Cleaning**
    - Initial cleaning was done using Power Query in Power BI.
    - Handled missing values, corrected data types, and standardized column names.

2. **Database Setup & Basic Analysis**
    - Imported the cleaned dataset into PostgreSQL (pgAdmin) and created the main table.
    - Performed basic checks:
        - Counted rows to verify completeness.
        - Checked for missing values in critical columns.
        - Explored unique/distinct values for categorical columns like crime_code, city, and crime_description.

3. **Exploratory Insights Using SQL**
Some key insights extracted through SQL queries include:

    - _Crime Trends_: Analyzed total crimes by year, month, day of the week, and hour to identify peak crime periods.
    - _Crime Types_: Identified the most frequent crime categories and descriptions.
    - _Location Analysis_: Determined crime hotspots by city.
    - _Victim Demographics_: Studied distribution by age group and gender.
    - _Case Status & Police Deployment_: Explored open vs closed cases and resource allocation.
    - _Weapon Usage_: Found the most commonly used weapons in crimes.

These insights informed the creation of KPIs and interactive visualizations in the Power BI dashboard, providing a comprehensive view of crime patterns and trends.

**Key SQL Queries & Insights**

1. <u>Total Crimes by Year & Month with Monthly Change</u>: Shows overall crime trends and seasonal patterns.

```SQL
WITH monthly_crimes AS (
    SELECT 
        year,
        EXTRACT(MONTH FROM date_of_occurrence) AS month_num,
        TO_CHAR(date_of_occurrence, 'FMMonth') AS month_name,
        COUNT(*) AS total_crimes
    FROM crime_report
    GROUP BY year, month_num, month_name
)
SELECT 
    year,
    month_num,
    month_name,
    total_crimes,
    COALESCE(total_crimes - LAG(total_crimes) OVER (ORDER BY year, month_num), 0) AS month_over_month_change
FROM monthly_crimes
ORDER BY year, month_num;
```

2. <u>Top 5 Most Common Crime Types</u>: Identifies most frequent crime types.

```SQL
SELECT 
    crime_description, 
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY crime_description
ORDER BY total_crimes DESC
LIMIT 5;
```

3. <u>Top 5 Crime Cities</u>: Identifies hotspots where most crimes occur.

```SQL
SELECT 
    city, 
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY city
ORDER BY total_crimes DESC
LIMIT 5;
```

4. <u>Crimes by Victim Gender</u>: Shows gender distribution among victims.

```SQL
SELECT 
    victim_gender,
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY victim_gender
ORDER BY victim_gender;
```

5. <u>Crimes by Victim Age</u>: Highlights vulnerable age groups.

```SQL
SELECT 
    victim_age_group, 
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY victim_age_group
ORDER BY victim_age_group;
```

6. <u>Top 5 Peak Crime</u>: Identifies times of day when crimes are most frequent.

```SQL
SELECT 
    hour, 
    COUNT(*) AS total_crimes
FROM crime_report
GROUP BY hour
ORDER BY total_crimes DESC
LIMIT 5;
```

7. <u>Percentage wise case analysis per city</u>: Shows effectiveness of case resolution.

```SQL
SELECT 
    city,
    COUNT(*) AS total_cases,
    SUM(CASE WHEN case_status = 'Closed' THEN 1 ELSE 0 END) AS closed_cases,
    ROUND(100.0 * SUM(CASE WHEN case_status = 'Closed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS closure_rate_percent
FROM crime_report
GROUP BY city
ORDER BY closure_rate_percent DESC;
```

8. <u>Top Weapon Used in Crimes</u>: Identifies most commonly used weapons in crimes.

```SQL
SELECT 
    weapon_used, 
    COUNT(*) AS total_crimes
FROM crime_report
WHERE weapon_used NOT IN('None','Other')
GROUP BY weapon_used
ORDER BY total_crimes DESC
LIMIT 5;
```

9. <u>Most Common Crime by City</u>: Shows the dominant crime type in each city.

```SQL
WITH most_common_crime AS (
    SELECT city, crime_description AS crime_type,
           COUNT(*) AS total_crimes,
           DENSE_RANK() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY city, crime_description
)
SELECT city, crime_type, total_crimes
FROM most_common_crime
WHERE rnk = 1
ORDER BY city, rnk;
```

10. <u>Average case closure time per city</u>: Shows the average duration of case.

```SQL
SELECT 
    city,
    ROUND(AVG(date_case_closed - date_of_occurrence), 2) AS avg_days_to_close
FROM crime_report
WHERE case_status = 'Closed'
  AND date_case_closed IS NOT NULL
  AND date_of_occurrence IS NOT NULL
GROUP BY city
ORDER BY avg_days_to_close;
```

11. <u>Peak Weekday Crime per City</u>: Shows the peak crime of that weekday in that city.

```SQL
WITH most_crime_per_day_of_week AS (
    SELECT 
        city,
        TO_CHAR(date_of_occurrence, 'FMDay') AS day_name,
        COUNT(*) AS total_crimes,
        DENSE_RANK() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS rnk
    FROM crime_report
    GROUP BY city, day_name
)
SELECT
    city,
    day_name,
    total_crimes
FROM most_crime_per_day_of_week
WHERE rnk = 1
ORDER BY total_crimes DESC;
```

12. <u>Most common crime during Day & Night</u>: Shows the peak crime of that weekday in that city.

```SQL
WITH crime_shifts_detail AS (
    SELECT
        crime_description AS crime_type,
        CASE
            WHEN hour BETWEEN 8 AND 19 THEN 'DAY'
            WHEN hour BETWEEN 20 AND 23 
              OR hour BETWEEN 0 AND 7 THEN 'NIGHT'
        END AS crime_shift,
        COUNT(*) AS total_crime
    FROM crime_report
    GROUP BY crime_type, crime_shift
),
ranked_crimes AS (
    SELECT
        crime_shift,
        crime_type,
        total_crime,
        DENSE_RANK() OVER (
            PARTITION BY crime_shift
            ORDER BY total_crime DESC
        ) AS rnk
    FROM crime_shifts_detail
)
SELECT
    crime_shift,
    crime_type,
    total_crime
FROM ranked_crimes
WHERE rnk <= 5
ORDER BY crime_shift, rnk;
```

Note: All other SQL queries and detailed analysis are available in the repository (SQL Query/_crime_analysis_queries.sql_) for further exploration.

4. **KPI Calculation & Dashboard Metrics with DAX**

    - Leveraged Power BI’s DAX (Data Analysis Expressions) to create dynamic and interactive KPIs that summarize key aspects of the crime data.
    - Derived useful columns such as victim_age_group, year, and hour for further analysis.
    - Calculated metrics such as Total Case, Open vs. Closed Case counts, Average Victim Age, Weapon Use % and Average Duration.
    - Developed ratio and percentage-based KPIs to evaluate trends, like the proportion of open cases, gender-wise victimization, and weapon-related crimes.
    - Enabled real-time filtering and slicing in the dashboard, allowing stakeholders to analyze crime patterns by year, month, city, crime type, or victim demographics.

## Dashboard Highlights

The Crime Analysis Dashboard provides interactive insights into crime patterns using dynamic slicers, KPIs, and visualizations, enabling stakeholders to monitor key metrics, identify hotspots, and make data-driven decisions to improve public safety.

1. Dynamic Slicers

    - ***Time: Year & Month*** — analyze both yearly trends and detailed monthly crime patterns.

    - ***Crime Type & City***: Filter data by specific crime types or cities to identify high-risk areas.

    - ***Gender & Age Group***: Explore trends based on victim demographics to understand vulnerable segments.

2. Key Performance Indicators (KPIs)

    - ***Total Case***: Displays the overall number of reported cases, providing an overview of crime volume.

    - ***Open & Closed Case***: Tracks unresolved versus resolved cases to evaluate law enforcement efficiency.

    - **Average Victim Age**: Helps identify age groups most affected by crime.

    - ***Weapon Use %***: Indicates the proportion of crimes involving weapons, highlighting threat levels.

    - ***Average Duration***: Shows the typical time taken to close a case, providing insights into case management.

3. Visualizations

    - ***Peak Crime Hours (Top 5)***: Identifies the most active hours for criminal activity, aiding law enforcement resource allocation.

    - ***Crime Distribution by Gender***: Visualizes the proportion of victims by gender, highlighting demographic trends.

    - ***Crime Domain Breakdown***: Shows the share of different crime domains, helping prioritize intervention strategies.

    - ***Monthly Case Trend***: Highlights fluctuations in crime cases over the months to spot seasonal trends.

    - ***Crime Hotspots by City***: Maps cities with high crime density, facilitating targeted policing and preventive measures.


## Key Insights

Between **January 2020 and July 2024**, a total of **40,160 crime** cases were reported across India. The analysis uncovers geographical hotspots, demographic patterns, weapon usage, and temporal crime behavior, providing a holistic view of the crime landscape.

- ***Case Status & Resolution***

    - Cases were almost evenly split between **open (~50%)** and **closed (~50%)**.

    - The average case closure duration was **88 days**, though this varied significantly across cities.

    - Some cities demonstrated efficient closure processes, resolving cases within weeks, while others lagged, leaving a high backlog of open cases.

- ***Geographical Crime Distribution***

    - **Delhi** consistently emerged as **India’s crime capital**, with **5,400+ reported cases**, far surpassing other cities.

    - Major metros like **Pune and Surat** also recorded higher crime rates, particularly **violent and weapon-related crimes**.

    - Smaller cities such as **Rajkot, Faridabad, and Varanasi** reported significantly fewer cases, indicating either **lower crime** prevalence or underreporting.

    - Urban centers showed higher incidents of **fraud, burglary, and domestic violence**, while smaller towns leaned towards **property damage and localized disputes**.  

- ***Demographics of Victims***
    - Women were the most frequent victims, accounting for **22,423 cases (55.8%)**.

    - Age Group 19–40: Dominated by **burglary and fraud**-related crimes.

    - Age Group 41–60: More exposed to **homicide, fraud, and firearm offenses**.

    - Age Group 60+: Faced high levels of **vandalism and property-related crimes**.

    - Gender and age analysis reveals that young to middle-aged women are the most vulnerable demographic segment.

- ***Weapons in Crime***
    - **71.4%** of all crimes **involved weapons**, underscoring the seriousness of incidents.

    - **Knives** were the most commonly used weapon, frequently linked to **burglary and domestic violence** cases.

    - **Firearms** dominated in **violent crimes (homicide, armed robbery, and gang-related violence)**.

    - **Firearm**-heavy cities included **Delhi, Pune, and Surat**, reflecting urban gang activity and organized crime.

    - Non-lethal weapons **(rods, blunt objects)** were more common in **vandalism and street disputes**.

- ***Temporal Analysis – When Crimes Happen***

    - Peak crime hour: **11 AM**, often associated with ***fraud, theft, and daytime domestic disputes***.

    - Peak crime day: **Wednesdays**, possibly linked to mid-week activity spikes.

    - Peak crime month: **March**, across multiple years, suggesting seasonal or socio-economic triggers.

    - Daytime crimes: **Fraud, homicide, and domestic violence** were more prevalent.

    - Nighttime crimes: **Burglary, vandalism, and firearm offenses** dominated.  

- ***Crime Trends Over the Years***

    - **2021** recorded the **highest crime volume**, possibly linked to post-pandemic socio-economic stress.

    - After 2021, some categories **(like fraud) declined**, while violent crimes **(firearm offenses, homicide) maintained** steady rates.

    - Top recurring crimes across all years:
        - Burglary 
        - Vandalism 
        - Fraud 
        - Domestic Violence 
        - Firearm Offenses 



#### Key Takeaways & Suggestions

1. Delhi remains the crime hotspot → Increase patrolling, CCTV coverage, and rapid response in high-risk zones.

2. Peak crime hours (11AM, 5PM, 9AM, 4AM, 3AM) → Align police shifts and patrols with high-risk timings.

3. Mid-week crimes (Wednesdays highest) → Launch awareness drives and community policing initiatives.

4. Women & age group 19–40 most vulnerable → Prioritize safety programs, emergency helplines, and self-defense initiatives.

5. Allocate police resources, surveillance, and outreach to high-crime cities and at-risk demographics
6. High firearm usage cities (Delhi, Pune, Surat, Rajkot) → Enforce strict weapon checks, audits, and firearm policing.

7. Case closure efficiency varies → Adopt best practices from fast cities (Varanasi, Faridabad, Kanpur) and improve processes in slow cities (Vasai, Ludhiana, Meerut).

8. Top crimes: Burglary, Vandalism, Fraud → Implement neighborhood watch programs, fraud alerts, and smart lock technologies.

9. Violent crimes & firearm offenses → Require stricter law enforcement, conflict resolution workshops, and special task forces.

10. Day vs. Night patterns → Adjust deployment: daytime (fraud, domestic violence), nighttime (burglary, vandalism, firearm offenses).

## Tools & Skills Used

- **Data Analysis, Cleaning & Visualization**: Power BI, Power Query

- **Data Modeling & Calculations**:  DAX

- **Database & Querying**: SQL (PostgreSQL), pgAdmin 


## How to Use This Project

1. Navigate to the Dashboard/ folder and open the Power BI file (_Crime_Analysis_Dashboard.pbix_).

2. Explore dashboard in Report View, interact with slicers and visualizations to analyze crime trends.
3. In Table View, explore the dataset, DAX measures, and KPIs used for analysis.
4. Check SQL Insights

    - Import _cleaned_crime_dataset_india.csv_ into your SQL database of choice (e.g., PostgreSQL, MySQL, SQL Server) and create a table to execute the queries.

    - Run the queries in _crime_analysis_queries.sql_ (found in the SQL Query/ folder) to reproduce insights and analysis results.

## Conclusion

This Crime Analysis Dashboard project demonstrates my proficiency in data analysis, SQL, and interactive visualization using Power BI. It showcases my ability to:

1. Preprocess, Clean and Transform raw messy crime data using Power Query, handle missing values, and create calculated columns for accurate analysis.

2. Perform Exploratory Analysis using SQL to uncover patterns in crime types, city-wise distribution, victim demographics, weapon usage, and temporal trends.
3. Generating Insights with SQL Queries like to Identify top crimes, high-risk cities, peak crime hours, and age/gender-specific crime trends through advanced queries.

4. Developing Interactive dashboard and designing dynamic visualizations with Power BI using slicers, KPIs, and DAX measures to present key findings effectively.

5. Deliver actionable Recommendations that provides insights for crime prevention, targeted policing, and community safety initiatives.

This project highlights my ability to transform raw crime data into clear, actionable insights for data-driven decision-making and strategic planning.


## Author

***Kartavya Raj*** – Aspiring Data Analyst

Passionate about data analysis, visualization, and business insights. Skilled in Excel, SQL, Power BI, Python (Pandas, NumPy, Matplotlib, Seaborn, Plotly) and data visualization


## Contact

For any questions or further information, please contact me.

[![LinkedIn](https://skillicons.dev/icons?i=linkedin&theme=light)](https://www.linkedin.com/in/kartavyaraj) [![Gmail](https://skillicons.dev/icons?i=gmail&theme=light)](mailto:kartavyarajput108@gmail.com)

---

[🔼 Back to Top](#crime-analysis-and-dashboard-project)
