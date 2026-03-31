/*
===============================================================================
Relatório de Produtos (Product Report)
===============================================================================
Objetivo:
    - Esta View consolida as principais métricas de performance e ciclo de vida dos produtos.
    - Ajuda na identificação de produtos rentáveis, lentos e tendências de venda.

Destaques Analíticos:
    1. Atributos do Produto: Nome, Categoria, Subcategoria e Custo Unitário.
    2. Segmentação de Produtos: Classifica em High-Performer, Mid-Range ou Low-Performer com base na receita.
    3. Métricas de Transação: Volume total de pedidos, vendas brutas e quantidade de itens vendidos.
    4. Alcance de Mercado: Total de clientes únicos que adquiriram o produto.
    5. KPIs de Performance:
        - Recência: Meses desde a última venda (identifica obsolescência).
        - Ticket Médio por Produto (AOR): Receita média gerada por pedido do produto.
        - Receita Mensal Média: Faturamento diluído ao longo do tempo de vida do produto.
===============================================================================
*/

CREATE OR ALTER VIEW gold.report_products AS
WITH base_query AS (
    -- 1) Query Base: Une as vendas com as informações técnicas dos produtos
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL -- Filtro para garantir integridade temporal
),

product_aggregations AS (
    -- 2) Agregações por Produto: Consolida as vendas e métricas agregadas por item
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        -- Calcula o preço médio de venda praticado (considerando possíveis descontos/variações)
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    -- Recência em meses (mede há quanto tempo o produto não vende)
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    -- Segmentação por Receita (Identificação de Curva ABC simplificada)
    CASE   
        WHEN total_sales > 50000 THEN 'Alto Desempenho (High-Performer)'
        WHEN total_sales >= 10000 THEN 'Desempenho Médio (Mid-Range)'
        ELSE 'Baixo Desempenho (Low-Performer)'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- KPI: Receita Média por Pedido (Average Order Revenue)
    CASE   
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    -- KPI: Receita Mensal Média (Average Monthly Revenue)
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregations;
