/*
===============================================================================
Análise Exploratória de Dados (EDA) - Visão Geral do Negócio
===============================================================================
Objetivo:
    - Realizar um mergulho profundo na camada 'Gold' para extrair insights acionáveis.
    - Analisar performance de vendas, demografia de clientes e tendências de produtos.

Escopo da Análise:
    1. Base de Clientes e Alcance Geográfico.
    2. KPIs Executivos (Dashboard Tabular).
    3. Segmentação Demográfica (Gênero).
    4. Distribuição e Estrutura de Custos por Categoria.
    5. Ranking de Rentabilidade (Clientes e Produtos).
    6. Identificação de "Gargalos" (Produtos com baixo desempenho).

Banco de Dados: SQL Server / Compatível com T-SQL
===============================================================================
*/

-------------------------------------------------------------------------------
-- 1. ALCANCE DA BASE DE CLIENTES
-------------------------------------------------------------------------------
-- Objetivo: Calcular o volume total de clientes únicos que realizaram compras.
-- Insight de Negócio: Estabelece o tamanho real da base de clientes ativa.

SELECT 
    COUNT(DISTINCT customer_key) AS total_clientes_unicos
FROM gold.fact_sales;


-------------------------------------------------------------------------------
-- 2. RESUMO EXECUTIVO (DASHBOARD DE KPIs)
-------------------------------------------------------------------------------
-- Objetivo: Consolidar métricas de alto nível em uma única visualização.
-- Insight de Negócio: Fornece um "Check-up Rápido" da saúde da empresa, 
-- cobrindo receita, volume e variedade de estoque.

SELECT 
    'Receita Total de Vendas' AS nome_metrica,
    SUM(sales_amount)         AS valor_metrica 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Quantidade Total Vendida' AS nome_metrica,
    SUM(quantity)              AS valor_metrica 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Preço Médio de Venda'     AS nome_metrica, 
    AVG(sales_amount)          AS valor_metrica 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total de Pedidos Realizados' AS nome_metrica, 
    COUNT(DISTINCT order_number)  AS valor_metrica 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total de Produtos Únicos'    AS nome_metrica, 
    COUNT(product_key)            AS valor_metrica 
FROM gold.dim_products

UNION ALL

SELECT 
    'Total de Clientes Cadastrados' AS nome_metrica, 
    COUNT(customer_key)             AS valor_metrica 
FROM gold.dim_customers;


-------------------------------------------------------------------------------
-- 3. SEGMENTAÇÃO GEOGRÁFICA
-------------------------------------------------------------------------------
-- Objetivo: Identificar a densidade de clientes em diferentes países.
-- Insight de Negócio: Ajuda a priorizar regiões para logística e foco de marketing.

SELECT 
    country, 
    COUNT(customer_key) AS total_clientes
FROM gold.dim_customers
GROUP BY 
    country
ORDER BY 
    total_clientes DESC;


-------------------------------------------------------------------------------
-- 4. ANÁLISE DEMOGRÁFICA (GÊNERO)
-------------------------------------------------------------------------------
-- Objetivo: Quebra da base de clientes por gênero.
-- Insight de Negócio: Informa o desenvolvimento de produtos e estratégias de comunicação.

SELECT
    gender,
    COUNT(customer_key) AS total_clientes
FROM gold.dim_customers
GROUP BY 
    gender
ORDER BY 
    total_clientes DESC;


-------------------------------------------------------------------------------
-- 5. DISTRIBUIÇÃO DE CATEGORIAS DE PRODUTOS
-------------------------------------------------------------------------------
-- Objetivo: Analisar a variedade de produtos dentro de cada categoria.
-- Insight de Negócio: Visualiza a amplitude e profundidade do catálogo atual.

SELECT 
    category,
    COUNT(product_key) AS total_produtos
FROM gold.dim_products
GROUP BY 
    category
ORDER BY 
    total_produtos DESC;


-------------------------------------------------------------------------------
-- 6. ESTRUTURA DE CUSTOS POR CATEGORIA
-------------------------------------------------------------------------------
-- Objetivo: Calcular o custo médio de aquisição por categoria.
-- Insight de Negócio: Avalia o capital imobilizado em estoque e tendências de custo unitário.

SELECT 
    category,
    AVG(cost) AS custo_medio_produto
FROM gold.dim_products
GROUP BY 
    category
ORDER BY 
    custo_medio_produto DESC;


-------------------------------------------------------------------------------
-- 7. RECEITA POR CATEGORIA DE PRODUTO
-------------------------------------------------------------------------------
-- Objetivo: Correlacionar volume de vendas com categorias para encontrar os maiores geradores de receita.
-- Insight de Negócio: Identifica os segmentos mais lucrativos do negócio.

SELECT 
    dp.category,
    SUM(fs.sales_amount) AS receita_total
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON dp.product_key = fs.product_key
GROUP BY 
    dp.category
ORDER BY 
    receita_total DESC;


-------------------------------------------------------------------------------
-- 8. RANKING DE LUCRATIVIDADE POR CLIENTE
-------------------------------------------------------------------------------
-- Objetivo: Rankear clientes com base no gasto histórico total (LTV).
-- Insight de Negócio: Permite programas de fidelidade direcionados para clientes VIP.

SELECT 
    dc.customer_number,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount) AS receita_total_historica
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
GROUP BY 
    dc.customer_number, 
    dc.first_name, 
    dc.last_name
ORDER BY 
    receita_total_historica DESC;


-------------------------------------------------------------------------------
-- 9. VOLUME DE VENDAS POR GEOGRAFIA
-------------------------------------------------------------------------------
-- Objetivo: Quantificar o número total de itens vendidos por país.
-- Insight de Negócio: Destaca a demanda física, independente do valor da moeda.

SELECT 
    dc.country,
    SUM(fs.quantity) AS quantidade_total_vendida
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
GROUP BY 
    dc.country
ORDER BY 
    quantidade_total_vendida DESC;


-------------------------------------------------------------------------------
-- 10. OS MAIS VENDIDOS (TOP 5 PRODUTOS POR RECEITA)
-------------------------------------------------------------------------------
-- Objetivo: Listar os 5 produtos individuais que geram mais receita.
-- Insight de Negócio: Foco em produtos de alto impacto para reposição de estoque.

SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS receita_total
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON dp.product_key = fs.product_key
GROUP BY 
    dp.product_name
ORDER BY 
    receita_total DESC;


-------------------------------------------------------------------------------
-- 11. BAIXO DESEMPENHO (OS 5 PRODUTOS COM MENOR RECEITA)
-------------------------------------------------------------------------------
-- Objetivo: Identificar produtos com a menor contribuição financeira.
-- Insight de Negócio: Destaca estoque potencial para liquidação ou descontinuação.

SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS receita_total
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON dp.product_key = fs.product_key
GROUP BY 
    dp.product_name
ORDER BY 
    receita_total ASC;
