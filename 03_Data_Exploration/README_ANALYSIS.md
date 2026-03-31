# 📈 Analytics Engineering: Da Exploração ao Insight Estratégico

[![SQL](https://img.shields.io/badge/SQL-Expert-blue?style=for-the-badge&logo=microsoft-sql-server)](./03_Data_Exploration/)
[![Analytics](https://img.shields.io/badge/Analytics-Advanced-orange?style=for-the-badge)](./03_Data_Exploration/)
[![Insights](https://img.shields.io/badge/Insights-Actionable-green?style=for-the-badge)](./03_Data_Exploration/)

Este módulo representa a "ponta final" do valor de dados. Enquanto a Engenharia de Dados foca na estrutura, aqui o foco é o **conhecimento**. Esta documentação detalha como transformamos as tabelas dimensionais da camada Gold em inteligência de negócio através de três fases fundamentais: **Exploração (EDA)**, **Análise Avançada (Ad-hoc)** e **Reporting (Camada Semântica)**.

---

## 🧠 O Processo de Pensamento Analítico

Nossa estratégia seguiu uma progressão lógica para garantir que a análise fosse completa e não apenas uma lista de consultas:

1.  **Observação (EDA):** Qual é o estado atual? (Volume, Receita, Mix de Clientes).
2.  **Contextualização (Advanced):** Como mudamos ao longo do tempo? (Tendências, YoY, Sazonalidade).
3.  **Ação (Reporting):** Como o negócio pode consumir isso diariamente? (Indicadores de Recência, Valor e Segmentação).

---

## 🔍 Fase 1: Análise Exploratória de Dados (EDA)
**Arquivo:** `01_eda_overview.sql`

O objetivo desta fase é realizar um "Check-up de Saúde" do negócio. Antes de prever o futuro, precisamos entender o presente.

### Principais Dimensões Analisadas:
*   **KPIs de Volume:** Consolidação de Receita, Quantidade de Itens e Ticket Médio. Aqui identificamos se o negócio é movido por volume (muitas vendas baratas) ou valor (poucas vendas caras).
*   **Densidade Geográfica:** Mapeamos onde nossos clientes estão concentrados. Isso impacta decisões de logística e expansão de mercado.
*   **Mix de Categorias:** Analisamos a profundidade do catálogo. Descobrimos quais categorias dominam o estoque e quais dominam a receita (nem sempre são as mesmas).
*   **Ranking de Performance:**
    *   **Top 5 Produtos:** Os "carros-chefe" que sustentam o faturamento.
    *   **Bottom 5 Produtos:** Itens "cauda longa" ou obsoletos que podem estar gerando custo de armazenagem desnecessário.

---

## 🚀 Fase 2: Análise Avançada e Tendências
**Arquivo:** `02_adhoc_trends_analysis.sql`

Nesta fase, elevamos o nível técnico utilizando **SQL Avançado** para encontrar padrões ocultos que consultas simples não revelam.

### Técnicas de Destaque:
#### 1. Análise de Crescimento YoY (Year-over-Year)
Utilizamos a função de janela **`LAG()`** para comparar o faturamento de um produto no ano atual com o ano anterior.
> **Insight:** Isso isola a sazonalidade e mostra se o produto está realmente crescendo ou apenas vendendo bem no Natal, por exemplo.

#### 2. Running Totals (Acumulados)
Implementamos **`SUM() OVER (ORDER BY date)`** para visualizar a curva de crescimento da empresa. 
> **Valor:** Permite identificar em qual mês do ano a empresa geralmente atinge seu "Break-even" (ponto de equilíbrio).

#### 3. Part-to-Whole (Participação no Todo)
Calculamos o percentual de contribuição de cada categoria para o faturamento global usando **`SUM() OVER()`**.
> **Decisão:** Ajuda a diretoria a decidir onde investir mais orçamento de marketing.

#### 4. Segmentação Comportamental de Clientes
Criamos um modelo de segmentação baseado em **Lifespan (Tempo de Vida)** e **Spending (Gasto)**:
*   **VIP:** Clientes fiéis (>12 meses) e de alto valor (>$5.000).
*   **Regular:** Clientes estáveis, mas com gasto moderado.
*   **Novos:** Clientes recém-adquiridos que precisam de estratégias de retenção.

---

## 📊 Fase 3: Criação da Camada de Reporting (Semântica)
**Arquivos:** `01_view_report_customers.sql` e `02_view_report_products.sql`

Esta é a etapa final de **Analytics Engineering**. Em vez de forçar o analista de BI a escrever SQL complexo, entregamos **Views Gold** já processadas.

### O que entregamos nestas Views:
1.  **Recência:** Calculamos há quantos meses ocorreu a última interação. No varejo, um cliente que não compra há 6 meses é um forte candidato a *Churn* (cancelamento/abandono).
2.  **Métricas de Vida (Lifespan):** Medimos o tempo total de relacionamento em meses.
3.  **Indicadores Médios:** Ticket Médio por Pedido (AVO) e Gasto Médio Mensal já calculados e prontos para virar gráfico.

---

## 🛠️ Tecnologias e Domínio Técnico
Para este projeto, demonstramos maestria em:
*   **Window Functions:** `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `SUM() OVER()`.
*   **CTEs (Common Table Expressions):** Para modularização de consultas complexas, tornando o código legível e fácil de manter.
*   **Lógica Condicional Avançada:** `CASE WHEN` aninhados para segmentação dinâmica de mercado.
*   **Date Functions:** `DATEDIFF`, `DATETRUNC`, `YEAR/MONTH` para manipulação temporal precisa.

---
🔗 **[Voltar para a Documentação Principal](../README.md)** | 🧱 **[Ver Detalhes da Engenharia (DW)](../01_Data_Warehouse/README_DW.md)**
