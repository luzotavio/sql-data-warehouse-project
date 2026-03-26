/*
===============================================================================
Script DDL: Criação das Tabelas da Camada Silver (Cleansed)
===============================================================================
Objetivo:
    Este script define a estrutura física das tabelas na camada 'silver'.
    A camada Silver é o estágio de "limpeza" e "padronização" (Cleansed/Standardized).
    Aqui, os dados brutos da camada Bronze são validados, as tipagens são 
    corrigidas e metadados de auditoria são adicionados.

Diferenciais Técnicos:
    - Uso de DATETIME2 para precisão em colunas de auditoria.
    - Padronização de datas (DATE) para otimização de consultas e armazenamento.
    - Implementação de colunas de linhagem (dwh_create_date) para rastreabilidade.

AVISO:
    A execução deste script recriará toda a estrutura da camada Silver. 
    Dados processados anteriormente nesta camada serão removidos.
===============================================================================
*/

-- ===========================================================================
-- Sistema de Origem: CRM
-- ===========================================================================

-- Tabela: silver.crm_cust_info (Dados de Clientes Limpos)
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date    DATETIME2 DEFAULT GETDATE() -- Auditoria: Data de inserção no DW
);
GO

-- Tabela: silver.crm_prd_info (Catálogo de Produtos Padronizado)
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,
    cat_id          NVARCHAR(50),
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabela: silver.crm_sales_details (Transações de Vendas Validadas)
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- ===========================================================================
-- Sistema de Origem: ERP
-- ===========================================================================

-- Tabela: silver.erp_loc_a101 (Localizações Geográficas Padronizadas)
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),
    cntry           NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabela: silver.erp_cust_az12 (Dados Demográficos ERP Limpos)
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),
    bdate           DATE,
    gen             NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Tabela: silver.erp_px_cat_g1v2 (Hierarquia de Categorias Consolidada)
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),
    cat             NVARCHAR(50),
    subcat          NVARCHAR(50),
    maintenance     NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO