/*
===============================================================================
Script de Auditoria: Validação de Qualidade de Dados (Data Quality - Gold)
===============================================================================
Objetivo:
    Este script realiza testes de integridade e conectividade na camada 'gold'.
    O foco principal é validar o Modelo Dimensional (Star Schema) e garantir 
    que não existam "registros órfãos" na tabela de fatos.

Verificações Realizadas:
    - Unicidade das Surrogate Keys (Chaves Substitutas) nas dimensões.
    - Integridade Referencial (Conectividade) entre Fato e Dimensões.

Instruções:
    - Se a query de integridade referencial retornar qualquer linha, significa
      que existem vendas apontando para produtos ou clientes que não existem 
      nas tabelas de dimensão.
===============================================================================
*/

-- ====================================================================
-- 1. Verificação de Unicidade: gold.dim_customers
-- ====================================================================
-- Expectativa: Zero resultados (Garante que não há clientes duplicados)
SELECT 
    customer_key,
    COUNT(*) AS total_duplicatas
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- 2. Verificação de Unicidade: gold.dim_products
-- ====================================================================
-- Expectativa: Zero resultados (Garante que não há produtos duplicados)
SELECT 
    product_key,
    COUNT(*) AS total_duplicatas
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- 3. Verificação de Integridade Referencial (Conectividade do Modelo)
-- ====================================================================
-- Objetivo: Identificar registros na Fato que não possuem correspondência nas Dimensões.
-- Expectativa: Zero resultados.
-- Se retornar linhas: Investigue os IDs retornados para corrigir a carga na Silver/Bronze.

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;