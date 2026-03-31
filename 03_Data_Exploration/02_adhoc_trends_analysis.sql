/*
===============================================================================
Análise de Tendências e Comportamento (Ad-hoc)
===============================================================================
Objetivo:
    - Analisar mudanças ao longo do tempo, performance relativa e segmentação avançada.
    - Utiliza funções de janela (Window Functions) para cálculos complexos.

Análises Incluídas:
    1. Evolução Mensal: Vendas, Clientes e Quantidades.
    2. Análise Acumulada (Running Total): Crescimento da receita mês a mês.
    3. Performance de Produtos (YoY): Compara vendas atuais com a média e com o ano anterior.
    4. Participação no Todo (Part-to-Whole): % de contribuição de cada categoria.
    5. Segmentação de Clientes por Valor e Tempo: VIP, Regular e Novos.
===============================================================================
*/

-- 1. EVOLUÇÃO TEMPORAL (MÊS A MÊS)
-- Objetivo: Identificar sazonalidade e tendências de crescimento mensal.

SELECT 
    YEAR(order_date) AS ano_pedido,
    MONTH(order_date) AS mes_pedido,
    SUM(sales_amount) AS total_vendas,
    COUNT(DISTINCT customer_key) AS total_clientes,
    SUM(quantity) AS total_quantidade
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- 2. ANÁLISE ACUMULADA (RUNNING TOTAL)
-- Objetivo: Calcular o faturamento total acumulado ao longo dos meses.

SELECT 
    data_mes,
    vendas_mensais,
    SUM(vendas_mensais) OVER (ORDER BY data_mes) AS faturamento_acumulado
FROM (
    SELECT 
        DATETRUNC(month, order_date) AS data_mes,
        SUM(sales_amount) AS vendas_mensais
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t;


-- 3. ANÁLISE DE PERFORMANCE DE PRODUTOS (ANUAL)
-- Objetivo: Comparar as vendas anuais de cada produto com sua própria média e com o ano anterior.

WITH vendas_anuais_produto AS (
    SELECT
        YEAR(f.order_date) AS ano_pedido,
        p.product_name,
        SUM(f.sales_amount) AS vendas_atuais
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
) 

SELECT 
    ano_pedido,
    product_name,
    vendas_atuais,
    AVG(vendas_atuais) OVER (PARTITION BY product_name) AS media_historica,
    vendas_atuais - AVG(vendas_atuais) OVER (PARTITION BY product_name) AS diferenca_media,
    CASE 
        WHEN vendas_atuais > AVG(vendas_atuais) OVER (PARTITION BY product_name) THEN 'Acima da Média'
        WHEN vendas_atuais < AVG(vendas_atuais) OVER (PARTITION BY product_name) THEN 'Abaixo da Média'
        ELSE 'Na Média'
    END AS status_media,
    LAG(vendas_atuais) OVER (PARTITION BY product_name ORDER BY ano_pedido) AS vendas_ano_anterior,
    vendas_atuais - LAG(vendas_atuais) OVER (PARTITION BY product_name ORDER BY ano_pedido) AS variacao_ano_anterior,
    CASE 
        WHEN vendas_atuais > LAG(vendas_atuais) OVER (PARTITION BY product_name ORDER BY ano_pedido) THEN 'Aumento'
        WHEN vendas_atuais < LAG(vendas_atuais) OVER (PARTITION BY product_name ORDER BY ano_pedido) THEN 'Queda'
        ELSE 'Sem Alteração'
    END AS tendencia_anual
FROM vendas_anuais_produto
ORDER BY product_name, ano_pedido;


-- 4. ANÁLISE DE PARTICIPAÇÃO (PERCENTUAL DO TOTAL)
-- Objetivo: Descobrir quais categorias mais contribuem para o faturamento total.

WITH vendas_por_categoria AS (
    SELECT
        category,
        SUM(sales_amount) AS vendas_categoria
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    GROUP BY category
)

SELECT
    category,
    vendas_categoria,
    SUM(vendas_categoria) OVER() AS faturamento_total_global,
    CONCAT(ROUND((CAST(vendas_categoria AS FLOAT) / SUM(vendas_categoria) OVER()) * 100, 2), '%') AS percentual_participacao
FROM vendas_por_categoria
ORDER BY vendas_categoria DESC;


-- 5. SEGMENTAÇÃO DE PRODUTOS POR FAIXA DE CUSTO
-- Objetivo: Agrupar produtos em categorias de custo para entender o perfil do catálogo.

WITH segmentos_produtos AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Abaixo de 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Acima de 1000'
        END AS faixa_custo
    FROM gold.dim_products
)

SELECT 
    faixa_custo,
    COUNT(product_key) AS total_produtos
FROM segmentos_produtos
GROUP BY faixa_custo
ORDER BY total_produtos DESC;


-- 6. SEGMENTAÇÃO DE CLIENTES (MODELO DE FIDELIDADE)
-- Objetivo: Agrupar clientes em VIP, Regular e Novos com base no comportamento de gasto e tempo.
/* 
Regras:
    - VIP: Pelo menos 12 meses de histórico e gasto > 5.000;
    - Regular: Pelo menos 12 meses de histórico mas gasto <= 5.000.
    - Novo: Tempo de vida (lifespan) menor que 12 meses.
*/

WITH gasto_cliente AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS gasto_total,
        MIN(order_date) AS primeira_compra,
        MAX(order_date) AS ultima_compra,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS tempo_vida_meses
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT 
    segmento_cliente,
    COUNT(customer_key) AS total_clientes
FROM (
    SELECT
        customer_key,
        CASE 
            WHEN tempo_vida_meses >= 12 AND gasto_total > 5000 THEN 'VIP'
            WHEN tempo_vida_meses >= 12 AND gasto_total <= 5000 THEN 'Regular'
            ELSE 'Novo'
        END AS segmento_cliente
    FROM gasto_cliente
) t
GROUP BY segmento_cliente
ORDER BY total_clientes DESC;
