/*
===============================================================================
Script: Inicialização do Data Warehouse e Camadas de Dados
===============================================================================
Objetivo:
    Este script é responsável pela criação do banco de dados 'DataWarehouse'.
    Ele implementa a estrutura inicial de esquemas baseada na Arquitetura 
    Medallion, garantindo um ambiente limpo para o pipeline de dados.

Descrição:
    1. Verifica a existência prévia do banco de dados 'DataWarehouse'.
    2. Encerra conexões ativas e recria o banco de dados do zero.
    3. Define os esquemas lógicos: 
       - 'bronze': Dados brutos (Raw/Staging).
       - 'silver': Dados limpos e transformados (Cleansed/Enriched).
       - 'gold': Dados agregados prontos para consumo (Analytics/Reporting).

AVISO:
    A execução deste script resultará na exclusão permanente de todos os dados 
    contidos no banco 'DataWarehouse' atual. Certifique-se de que possui backups 
    ou que este é um ambiente de desenvolvimento/teste.
===============================================================================
*/

USE master;
GO

-- Reinicialização do Banco de Dados (Garantia de Idempotência)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    -- Forçar o encerramento de conexões ativas antes da exclusão
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Criação da instância principal do Data Warehouse
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- ===========================================================================
-- Criação dos Esquemas (Camadas da Arquitetura Medallion)
-- ===========================================================================

-- Camada Bronze: Armazenamento de dados em seu estado original/bruto
CREATE SCHEMA bronze;
GO

-- Camada Silver: Dados padronizados, validados e integrados
CREATE SCHEMA silver;
GO

-- Camada Gold: Modelagem dimensional e métricas de negócio para BI
CREATE SCHEMA gold;
GO
