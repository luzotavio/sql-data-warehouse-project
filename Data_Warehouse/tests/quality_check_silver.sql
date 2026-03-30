/*
===============================================================================
Script de Auditoria: Validação de Qualidade de Dados (Data Quality - Silver)
===============================================================================
Objetivo:
    Realizar testes de integridade, consistência e padronização na camada 'silver'.
    Este script assegura que as transformações aplicadas durante o processo ETL
    seguiram as premissas de negócio e as regras de saneamento de dados.

Tipos de Verificações:
    - Unicidade e Integridade (Chaves Primárias).
    - Higienização de Strings (Espaços em branco).
    - Padronização de Domínios (Consistência de categorias).
    - Regras Cronológicas (Ordenação de datas).
    - Consistência Financeira (Cálculos de vendas).

Observações:
    - Executar este script após o processamento da procedure 'silver.load_silver'.
    - Qualquer resultado retornado indica uma anomalia que deve ser investigada.
===============================================================================
*/

-- ====================================================================
-- Auditoria: silver.crm_cust_info
-- ====================================================================

-- 1. Validação de Unicidade e Integridade da Chave Primária
-- Expectativa: Zero resultados (Garante que não há duplicatas ou IDs nulos)
SELECT 
    cst_id,
    COUNT(*) AS total_ocorrencias
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- 2. Detecção de Falhas na Higienização (Espaços Sobressalentes)
-- Expectativa: Zero resultados (Garante que o TRIM foi aplicado corretamente)
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- 3. Verificação de Padronização: Estado Civil
-- Objetivo: Validar se todos os valores foram normalizados conforme o domínio definido
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;


-- ====================================================================
-- Auditoria: silver.crm_prd_info
-- ====================================================================

-- 1. Validação de Unicidade da Chave Primária
-- Expectativa: Zero resultados
SELECT 
    prd_id,
    COUNT(*) AS total_ocorrencias
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- 2. Detecção de Espaços em Branco no Nome do Produto
-- Expectativa: Zero resultados
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- 3. Auditoria de Custos: Valores Nulos ou Negativos
-- Expectativa: Zero resultados (Custos devem ser positivos e preenchidos)
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- 4. Verificação de Padronização: Linha de Produto
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- 5. Validação Cronológica: Data de Início vs. Data de Fim
-- Expectativa: Zero resultados (Data fim não pode ser anterior à data início)
SELECT 
    * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- Auditoria: silver.crm_sales_details
-- ====================================================================

-- 1. Identificação de Datas Inválidas ou Fora de Escopo
-- Objetivo: Capturar anos anômalos ou formatos incorretos (Range: 1900 a 2050)
-- Nota: Checagem baseada na fonte original (bronze) para validar a conversão
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- 2. Validação de Fluxo Temporal (Cronologia do Pedido)
-- Expectativa: Zero resultados (Pedido deve ocorrer antes do envio e do vencimento)
SELECT 
    * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- 3. Consistência Financeira: Validação do Cálculo (Total = Qtd * Preço)
-- Expectativa: Zero resultados (Crucial para integridade dos relatórios de receita)
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- Auditoria: silver.erp_cust_az12
-- ====================================================================

-- 1. Filtro de Anomalias em Datas de Nascimento
-- Expectativa: Datas dentro de um limite biológico aceitável (1924 até hoje)
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- 2. Verificação de Padronização: Gênero
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;


-- ====================================================================
-- Auditoria: silver.erp_loc_a101
-- ====================================================================

-- 1. Consistência de Nomes de Países (Standardization)
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ====================================================================
-- Auditoria: silver.erp_px_cat_g1v2
-- ====================================================================

-- 1. Detecção de Falhas de Higienização em Categorias
-- Expectativa: Zero resultados
SELECT 
    * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- 2. Padronização de Flags de Manutenção
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;