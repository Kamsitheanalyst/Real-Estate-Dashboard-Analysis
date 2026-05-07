# Real-Estate-Dashboard-Analysis
End-to-end real estate sales analytics project using SQL Server and Power BI: data cleaning, modeling, dashboarding, and executive insights.

## Project Overview
This project simulates a real-world real estate analytics task. Messy CRM sales data was cleaned and structured in **Microsoft SQL Server**, then modeled and visualized in **Power BI** to deliver an executive-level dashboard with key sales insights.

## Objectives
- Clean and standardize raw real estate datasets (Leads, Deals, Properties, Agents)
- Build a structured SQL reporting layer for analysis
- Create an interactive Power BI executive dashboard
- Provide insights and recommendations to improve sales performance

## Tools Used
- Microsoft SQL Server (T-SQL)
- Power BI Desktop (Power Query, DAX)
- Microsoft Excel
- PowerPoint (Executive Insights Report)

## Dataset Tables
- **Leads**
- **Deals**
- **Properties**
- **Agents**
- **DateTable (created in Power BI)**

## Data Cleaning (SQL + Power Query)
Key cleaning steps included:
- Created staging tables for safe editing (`stg_` tables)
- Removed duplicates
- Trimmed spaces and standardized casing
- Cleaned currency fields (₦ symbols, commas)
- Converted date and numeric fields into proper formats
- Built clean reporting tables (`dim_` tables)
- Created a reporting view for analysis

## Data Model (Star Schema)
- **Fact Table:** dim_Deals  
- **Dimension Tables:** dim_Leads, dim_Agents, dim_Properties, DateTable

## Dashboard KPIs
- Total Revenue (Closed Won)
- Total Leads
- Total Deals
- Closed Won Deals
- Conversion Rate
- Pipeline Revenue
- Revenue Trend (Monthly)
- Revenue by Lead Source
- Top Performing Agents
- Payment Status Breakdown

## Deliverables
- Clean SQL tables + reporting view
- Power BI dashboard (.pbix)
- PowerPoint report containing insights and recommendations

## AI Support
Claude AI was used as a support tool for debugging SQL scripts and validating logic. All solutions were tested and customized.

## Author 
Kamsi Chiadi

## 👤 Author
**Your Name** – Data Analyst  
