/*
===============================================================================
Relatório de Clientes (Customer Report)
===============================================================================
Objetivo:
    - Esta View consolida as principais métricas e comportamentos dos clientes em um único lugar.
    - Facilita a análise de perfil, segmentação e valor do cliente (LTV).

Destaques Analíticos:
    1. Dados Cadastrais: Nomes, idades e localização.
    2. Segmentação de Clientes: Classifica em VIP, Regular ou Novo com base no gasto e tempo de casa.
    3. Métricas de Transação: Total de pedidos, receita gerada, quantidade de itens e diversidade de produtos.
    4. KPIs de Performance: 
        - Recência: Meses desde a última compra (quanto menor, mais ativo).
        - Ticket Médio (AVO): Valor médio gasto por pedido.
        - Gasto Mensal Médio: Consumo médio do cliente ao longo do seu tempo de vida (lifespan).
===============================================================================
*/

CREATE OR ALTER VIEW gold.report_customers AS
WITH base_query AS (
    -- 1) Query Base: Une a tabela fato de vendas com a dimensão de clientes
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL -- Garante que apenas vendas válidas sejam processadas
)

, customer_aggregation AS (
    -- 2) Agregações por Cliente: Consolida os indicadores de performance por indivíduo
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    -- Agrupamento por faixa etária para análises demográficas
    CASE 
        WHEN age < 20 THEN 'Menor de 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 ou mais'
    END AS age_group,
    -- Lógica de Segmentação de Clientes (Regras de Negócio)
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'Novo' -- Clientes com menos de 1 ano de histórico
    END AS customer_segment,
    -- Cálculo de Recência (Meses desde a última atividade)
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    last_order_date,
    lifespan,
    -- KPI: Ticket Médio por Pedido (Average Order Value)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    -- KPI: Gasto Médio Mensal (Average Monthly Spend)
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;
