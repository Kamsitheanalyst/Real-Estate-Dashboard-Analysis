
/* ============================================================
   PROJECT: Real Estate Sales Analytics Dashboard
   AUTHOR: Kamsi Chaidi (Data Analyst)
   TOOLS: Microsoft SQL Server (T-SQL), Power BI
   PURPOSE:
     - Clean and standardize raw CRM-style real estate datasets
     - Create clean reporting tables for Power BI dashboarding
     - Build a reporting view for executive-level analytics
 

/* ============================================================
   1. DATABASE SETUP 

-- Drop database if it already exists (use with caution)
-- IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RealEstateDB')
-- DROP DATABASE RealEstateDB;

-- CREATE DATABASE RealEstateDB;
-- GO

-- USE RealEstateDB;
-- GO



/* ============================================================
   2. CREATE STAGING TABLES
   NOTE: Staging tables are created to avoid modifying raw data.

SELECT * INTO stg_Leads FROM Leads;
SELECT * INTO stg_Deals FROM Deals;
SELECT * INTO stg_Properties FROM Properties;
SELECT * INTO stg_Agents FROM Agents;



/* ============================================================
   3. DATA QUALITY CHECKS (BEFORE CLEANING)

-- Check row counts
SELECT COUNT(*) AS Leads_Count FROM stg_Leads;
SELECT COUNT(*) AS Deals_Count FROM stg_Deals;
SELECT COUNT(*) AS Properties_Count FROM stg_Properties;
SELECT COUNT(*) AS Agents_Count FROM stg_Agents;

-- Check duplicates in Leads
SELECT LeadID, COUNT(*) AS DuplicateCount
FROM stg_Leads
GROUP BY LeadID
HAVING COUNT(*) > 1;



/* ============================================================
   4. CLEANING: LEADS TABLE

-- Remove duplicate LeadIDs
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY LeadID ORDER BY LeadID) AS rn
    FROM stg_Leads
)
DELETE FROM cte WHERE rn > 1;


-- Trim LeadName and standardize casing
UPDATE stg_Leads
SET LeadName = LTRIM(RTRIM(LeadName));


-- Standardize LeadSource
UPDATE stg_Leads
SET LeadSource = UPPER(LTRIM(RTRIM(LeadSource)));


-- Standardize AgentAssigned formatting (optional)
UPDATE stg_Leads
SET AgentAssigned = LTRIM(RTRIM(AgentAssigned));


-- Replace empty contact values
UPDATE stg_Leads
SET [Phone/Email] = 'UNKNOWN'
WHERE [Phone/Email] IS NULL OR [Phone/Email] = '';



/* ============================================================
   5. CLEANING: DEALS TABLE

-- Trim DealStage and PaymentStatus
UPDATE stg_Deals
SET DealStage = UPPER(LTRIM(RTRIM(DealStage))),
    PaymentStatus = UPPER(LTRIM(RTRIM(PaymentStatus)));


-- Clean DealAmount (remove ₦ symbol and commas)
UPDATE stg_Deals
SET DealAmount = REPLACE(REPLACE(DealAmount, '₦', ''), ',', '');


-- Remove trailing spaces
UPDATE stg_Deals
SET DealAmount = LTRIM(RTRIM(DealAmount));


-- Optional: Remove invalid rows
-- DELETE FROM stg_Deals
-- WHERE DealAmount IS NULL OR DealAmount = '';



/* ============================================================
   6. CLEANING: PROPERTIES TABLE

-- Standardize text columns
UPDATE stg_Properties
SET Location = UPPER(LTRIM(RTRIM(Location))),
    PropertyType = UPPER(LTRIM(RTRIM(PropertyType))),
    Status = UPPER(LTRIM(RTRIM(Status)));


-- Clean Price (remove ₦ symbol and commas)
UPDATE stg_Properties
SET Price = REPLACE(REPLACE(Price, '₦', ''), ',', '');

UPDATE stg_Properties
SET Price = LTRIM(RTRIM(Price));


-- Replace missing Bedrooms for LAND
UPDATE stg_Properties
SET Bedrooms = 0
WHERE PropertyType = 'LAND' AND (Bedrooms IS NULL OR Bedrooms = '');



/* ============================================================
   7. CLEANING: AGENTS TABLE
   ============================================================ */

UPDATE stg_Agents
SET AgentName = LTRIM(RTRIM(AgentName)),
    Region = UPPER(LTRIM(RTRIM(Region)));



/* ============================================================
   8. CONVERT DATA TYPES (IMPORTANT FOR REPORTING)
   NOTE: Conversion depends on original column types.
   ============================================================ */

-- Convert DealAmount to numeric
-- If conversion fails, inspect bad values using TRY_CONVERT checks.

ALTER TABLE stg_Deals
ALTER COLUMN DealAmount FLOAT;

-- Convert Price to numeric
ALTER TABLE stg_Properties
ALTER COLUMN Price FLOAT;



/* ============================================================
   9. CREATE CLEAN REPORTING TABLES (DIM / FACT)

SELECT * INTO dim_Leads FROM stg_Leads;
SELECT * INTO dim_Deals FROM stg_Deals;
SELECT * INTO dim_Properties FROM stg_Properties;
SELECT * INTO dim_Agents FROM stg_Agents;



/* ============================================================
   10. RELATIONSHIP VALIDATION CHECKS
  
-- Deals with missing LeadID matches
SELECT COUNT(*) AS Deals_With_No_LeadMatch
FROM dim_Deals d
LEFT JOIN dim_Leads l ON d.LeadID = l.LeadID
WHERE l.LeadID IS NULL;

-- Deals with missing AgentID matches
SELECT COUNT(*) AS Deals_With_No_AgentMatch
FROM dim_Deals d
LEFT JOIN dim_Agents a ON d.AgentID = a.AgentID
WHERE a.AgentID IS NULL;

-- Deals with missing PropertyID matches
SELECT COUNT(*) AS Deals_With_No_PropertyMatch
FROM dim_Deals d
LEFT JOIN dim_Properties p ON d.PropertyID = p.PropertyID
WHERE p.PropertyID IS NULL;



/* ============================================================
   11. CREATE POWER BI REPORTING VIEW
   PURPOSE: Provide a clean dataset for dashboard reporting.

CREATE VIEW vw_SalesDashboard AS
SELECT
    d.DealID,
    d.LeadID,
    d.PropertyID,
    d.AgentID,
    d.DealStage,
    d.DealAmount,
    d.ClosingDate,
    d.PaymentStatus,
    l.LeadName,
    l.LeadSource,
    a.AgentName,
    a.Region,
    p.Location,
    p.PropertyType,
    p.Price,
    p.Bedrooms,
    p.Status AS PropertyStatus
FROM dim_Deals d
LEFT JOIN dim_Leads l ON d.LeadID = l.LeadID
LEFT JOIN dim_Agents a ON d.AgentID = a.AgentID
LEFT JOIN dim_Properties p ON d.PropertyID = p.PropertyID;



/* ============================================================
   12. FINAL QUICK TEST

SELECT TOP 20 * FROM vw_SalesDashboard;