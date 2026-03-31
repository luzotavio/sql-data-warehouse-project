/*
===============================================================================
Script Mestre de Execução do Pipeline (ETL)
===============================================================================
Este script orquestra o processo de carga das camadas Bronze e Silver.
A camada Gold é composta por VIEWS e não requer carga física.
===============================================================================
*/

-- 1. Carga da Camada Bronze (Ingestão de Dados Brutos)
PRINT '---------------------------------------------------';
PRINT 'Iniciando Carga da Camada Bronze...';
PRINT '---------------------------------------------------';
EXEC bronze.load_bronze;

-- 2. Carga da Camada Silver (Limpeza e Padronização)
PRINT '---------------------------------------------------';
PRINT 'Iniciando Carga da Camada Silver...';
PRINT '---------------------------------------------------';
EXEC silver.load_silver;

PRINT '---------------------------------------------------';
PRINT 'Pipeline de Dados Finalizado com Sucesso!';
PRINT '---------------------------------------------------';
