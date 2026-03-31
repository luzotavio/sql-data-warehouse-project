# **Convenções de Nomenclatura**

Este documento descreve as convenções de nomenclatura usadas para esquemas, tabelas, views, colunas e outros objetos no data warehouse.

## **Índice**

- [**Convenções de Nomenclatura**](#convenções-de-nomenclatura)
  - [**Índice**](#índice)
  - [**Princípios Gerais**](#princípios-gerais)
  - [**Convenções para Nomes de Tabelas**](#convenções-para-nomes-de-tabelas)
    - [**Regras da Camada Bronze**](#regras-da-camada-bronze)
    - [**Regras da Camada Silver**](#regras-da-camada-silver)
    - [**Regras da Camada Gold**](#regras-da-camada-gold)
      - [**Glossário de Padrões de Categoria**](#glossário-de-padrões-de-categoria)
  - [**Convenções para Nomes de Colunas**](#convenções-para-nomes-de-colunas)
    - [**Chaves Substitutas (Surrogate Keys)**](#chaves-substitutas-surrogate-keys)
    - [**Colunas Técnicas**](#colunas-técnicas)
  - [**Procedimentos Armazenados (Stored Procedures)**](#procedimentos-armazenados-stored-procedures)
---

## **Princípios Gerais**

- **Padrão de Escrita**: Use `snake_case`, com letras minúsculas e sublinhados (`_`) para separar as palavras.
- **Idioma**: Use Inglês para todos os nomes de objetos (tabelas, colunas, etc.).
- **Evite Palavras Reservadas**: Não utilize palavras reservadas do SQL como nomes de objetos.

## **Convenções para Nomes de Tabelas**

### **Regras da Camada Bronze**
- Todos os nomes devem começar com o nome do sistema de origem, e os nomes das tabelas devem corresponder aos nomes originais sem renomeação.
- **`<sistema_origem>_<entidade>`**  
  - `<sistema_origem>`: Nome do sistema de origem (ex: `crm`, `erp`).  
  - `<entidade>`: Nome exato da tabela no sistema de origem.  
  - Exemplo: `crm_customer_info` → Informações de clientes do sistema CRM.

### **Regras da Camada Silver**
- Segue a mesma lógica da camada Bronze para manter a rastreabilidade.
- **`<sistema_origem>_<entidade>`**  
  - `<sistema_origem>`: Nome do sistema de origem (ex: `crm`, `erp`).  
  - `<entidade>`: Nome exato da tabela vinda da camada Bronze.  
  - Exemplo: `crm_customer_info` → Dados higienizados do cliente do CRM.

### **Regras da Camada Gold**
- Todos os nomes devem ser significativos e alinhados ao negócio, começando com o prefixo da categoria.
- **`<categoria>_<entidade>`**  
  - `<categoria>`: Descreve o papel da tabela, como `dim` (dimensão) ou `fact` (tabela de fatos).  
  - `<entidade>`: Nome descritivo da tabela, alinhado ao domínio de negócio (ex: `customers`, `products`, `sales`).  
  - Exemplos:
    - `dim_customers` → Tabela de dimensão para dados de clientes.  
    - `fact_sales` → Tabela de fatos contendo transações de vendas.  

#### **Glossário de Padrões de Categoria**

| Padrão      | Significado                       | Exemplo(s)                              |
|-------------|-----------------------------------|-----------------------------------------|
| `dim_`      | Tabela de Dimensão                | `dim_customer`, `dim_product`           |
| `fact_`     | Tabela de Fatos                   | `fact_sales`                            |
| `report_`   | Tabela de Relatório (Consolidada) | `report_customers`, `report_sales_monthly` |

## **Convenções para Nomes de Colunas**

### **Chaves Substitutas (Surrogate Keys)**  
- Todas as chaves primárias em tabelas de dimensão devem usar o sufixo `_key`.
- **`<nome_tabela>_key`**  
  - `<nome_tabela>`: Refere-se ao nome da tabela ou entidade à qual a chave pertence.  
  - `_key`: Sufixo indicando que esta coluna é uma chave substituta (surrogate key).  
  - Exemplo: `customer_key` → Chave substituta na tabela `dim_customers`.
  
### **Colunas Técnicas**
- Todas as colunas técnicas devem começar com o prefixo `dwh_`, seguido por um nome descritivo indicando o propósito da coluna.
- **`dwh_<nome_coluna>`**  
  - `dwh`: Prefixo exclusivo para metadados gerados pelo sistema.  
  - `<nome_coluna>`: Nome descritivo indicando a finalidade da coluna.  
  - Exemplo: `dwh_load_date` → Coluna gerada pelo sistema para armazenar a data em que o registro foi carregado.
 
## **Procedimentos Armazenados (Stored Procedures)**

- Todos os procedimentos armazenados usados para carregar dados devem seguir o padrão:
- **`load_<camada>`**.
  
  - `<camada>`: Representa a camada que está sendo carregada, como `bronze`, `silver` ou `gold`.
  - Exemplo: 
    - `load_bronze` → Stored procedure para carregar dados na camada Bronze.
    - `load_silver` → Stored procedure para carregar dados na camada Silver.