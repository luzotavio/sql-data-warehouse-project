/*
===============================================================================
Main Pipeline Execution Script
===============================================================================
This script orchestrates the full ETL process by executing the stored 
procedures for each layer (Bronze, Silver, Gold).
===============================================================================
*/

-- 1. Load Bronze Layer (Raw Data Ingestion)
PRINT '---------------------------------------------------';
PRINT 'Loading Bronze Layer...';
PRINT '---------------------------------------------------';
EXEC bronze.load_bronze;

-- 2. Load Silver Layer (Data Cleansing & Standardization)
PRINT '---------------------------------------------------';
PRINT 'Loading Silver Layer...';
PRINT '---------------------------------------------------';
EXEC silver.load_silver;

-- 3. Load Gold Layer (Dimensional Modeling)
PRINT '---------------------------------------------------';
PRINT 'Loading Gold Layer...';
PRINT '---------------------------------------------------';
EXEC gold.load_gold;

PRINT '---------------------------------------------------';
PRINT 'Pipeline Completed Successfully!';
PRINT '---------------------------------------------------';
