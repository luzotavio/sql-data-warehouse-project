/*
===============================================================================
Stored Procedure: Carga da Camada Bronze (Source -> Bronze) - Estrutura GitHub
===============================================================================
Objetivo:
    Este procedimento realiza a carga de dados no esquema 'bronze' a partir de 
    arquivos CSV, utilizando uma estrutura de caminhos alinhada ao repositório Git.

Diferencial Técnico:
    - SQL Dinâmico para portabilidade do projeto.
    - Estrutura de pastas padronizada: /sql-data-warehouse-project/datasets/
    - Log de execução detalhado com medição de performance.

Exemplo de Uso:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    -- Variáveis de controle
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    DECLARE @base_path NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX);

    -- =========================================================================
    -- CONFIGURAÇÃO: Caminho base seguindo a estrutura do repositório GitHub
    -- =========================================================================
    SET @base_path = 'C:\sql-data-warehouse-project\datasets\';

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=======================================================================';
        PRINT 'Iniciando Ingestão: Camada Bronze (Repositório Git)';
        PRINT '=======================================================================';

        -- ---------------------------------------------------------------------
        -- Processando Tabelas do CRM
        -- ---------------------------------------------------------------------
        PRINT '-----------------------------------------------------------------------';
        PRINT 'Origem: CRM';
        PRINT '-----------------------------------------------------------------------';

        -- Tabela: crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Populando: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        SET @sql = 'BULK INSERT bronze.crm_cust_info FROM ''' + @base_path + 'crm\cust_info.csv'' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Status: Concluído | Duração: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- Tabela: crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Populando: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        SET @sql = 'BULK INSERT bronze.crm_prd_info FROM ''' + @base_path + 'crm\prd_info.csv'' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Status: Concluído | Duração: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- Tabela: crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Populando: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        SET @sql = 'BULK INSERT bronze.crm_sales_details FROM ''' + @base_path + 'crm\sales_details.csv'' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Status: Concluído | Duração: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- ---------------------------------------------------------------------
        -- Processando Tabelas do ERP
        -- ---------------------------------------------------------------------
        PRINT '-----------------------------------------------------------------------';
        PRINT 'Origem: ERP';
        PRINT '-----------------------------------------------------------------------';

        -- Tabela: erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '>> Populando: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        SET @sql = 'BULK INSERT bronze.erp_loc_a101 FROM ''' + @base_path + 'erp\loc_a101.csv'' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Status: Concluído | Duração: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- Tabela: erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> Populando: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        SET @sql = 'BULK INSERT bronze.erp_cust_az12 FROM ''' + @base_path + 'erp\cust_az12.csv'' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Status: Concluído | Duração: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        -- Tabela: erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>> Populando: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        SET @sql = 'BULK INSERT bronze.erp_px_cat_g1v2 FROM ''' + @base_path + 'erp\px_cat_g1v2.csv'' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Status: Concluído | Duração: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';

        SET @batch_end_time = GETDATE();
        PRINT '=======================================================================';
        PRINT 'CARGA DA CAMADA BRONZE FINALIZADA';
        PRINT 'DURAÇÃO TOTAL: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' segundos';
        PRINT '=======================================================================';

    END TRY
    BEGIN CATCH
        PRINT '=======================================================================';
        PRINT 'ERRO DETECTADO';
        PRINT 'Mensagem: ' + ERROR_MESSAGE();
        PRINT 'Código: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '=======================================================================';
    END CATCH
END