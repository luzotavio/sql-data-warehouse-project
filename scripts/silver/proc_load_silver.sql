/*
===============================================================================
Stored Procedure: Processamento da Camada Silver (Bronze -> Silver)
===============================================================================
Objetivo:
    Este procedimento realiza o processo ETL (Extração, Transformação e Carga)
    para transpor os dados da camada 'bronze' para a camada 'silver'.

Regras de Negócio e Transformações:
    - Limpeza de Strings: Remoção de espaços em branco (TRIM).
    - Padronização: Normalização de categorias, gêneros e estados civis.
    - Deduplicação: Seleção do registro mais recente por chave primária.
    - Integridade de Datas: Conversão de inteiros/strings para tipos DATE e 
      validação de cronologia.
    - Recomposição de Cálculos: Auditoria e correção de valores de vendas e preços.

Parâmetros:
    Nenhum.

Exemplo de Uso:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=======================================================================';
        PRINT 'Iniciando Processamento da Camada Silver';
        PRINT '=======================================================================';

        PRINT '-----------------------------------------------------------------------';
        PRINT 'Processando Tabelas do CRM';
        PRINT '-----------------------------------------------------------------------';

        -- Tabela: silver.crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Limpando Tabela: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserindo Dados: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id, 
            cst_key, 
            cst_firstname, 
            cst_lastname, 
            cst_marital_status, 
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status, -- Normalização do estado civil para formato legível
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr, -- Normalização de gênero
            cst_create_date
        FROM (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1; -- Seleção do registro mais recente por cliente (Deduplicação)
        SET @end_time = GETDATE();
        PRINT '>> Duração: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- Tabela: silver.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Limpando Tabela: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserindo Dados: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Derivação da ID de Categoria
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extração da Chave do Produto
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line, -- Mapeamento descritivo da linha de produtos
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(
                LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
                AS DATE
            ) AS prd_end_dt -- Lógica de histórico: data fim baseada no início do próximo registro
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Duração: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- Tabela: silver.crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Limpando Tabela: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserindo Dados: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt, -- Conversão de INT para DATE (YYYYMMDD)
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales, -- Recálculo de vendas para garantir integridade financeira
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price 
            END AS sls_price -- Derivação de preço unitário em caso de inconsistência
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Duração: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        PRINT '-----------------------------------------------------------------------';
        PRINT 'Processando Tabelas do ERP';
        PRINT '-----------------------------------------------------------------------';

        -- Tabela: silver.erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> Limpando Tabela: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserindo Dados: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
                ELSE cid
            END AS cid, -- Higienização do prefixo 'NAS'
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate, -- Tratamento de datas de nascimento futuras (Anomalias)
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen -- Padronização de Gênero
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Duração: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- Tabela: silver.erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '>> Limpando Tabela: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserindo Dados: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid, 
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry -- Normalização de nomes de países e tratamento de vazios
        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Duração: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        
        -- Tabela: silver.erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>> Limpando Tabela: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserindo Dados: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Duração: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        SET @batch_end_time = GETDATE();
        PRINT '=======================================================================';
        PRINT 'Processamento da Camada Silver Concluído';
        PRINT 'DURAÇÃO TOTAL DO LOTE: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' segundos';
        PRINT '=======================================================================';
        
    END TRY
    BEGIN CATCH
        PRINT '=======================================================================';
        PRINT 'ERRO DETECTADO DURANTE O PROCESSAMENTO DA CAMADA SILVER';
        PRINT 'Mensagem de Erro: ' + ERROR_MESSAGE();
        PRINT 'Código do Erro: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Estado do Erro: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '=======================================================================';
    END CATCH
END