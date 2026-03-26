# Catálogo de Dados - Camada Gold

## Visão Geral
A Camada Gold representa a camada de entrega de dados para o negócio, estruturada para suportar casos de uso analíticos e relatórios. É composta por **tabelas de dimensão** e **tabelas de fatos** organizadas em um modelo Star Schema (Esquema Estrela).

---

### 1. **gold.dim_customers**
- **Propósito:** Armazena detalhes dos clientes enriquecidos com dados demográficos e geográficos.
- **Colunas:**

| Nome da Coluna   | Tipo de Dado  | Descrição                                                                                     |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key     | INT           | Chave substituta (Surrogate Key) que identifica exclusivamente cada registro de cliente.       |
| customer_id      | INT           | Identificador numérico único original atribuído ao cliente.                                   |
| customer_number  | NVARCHAR(50)  | Identificador alfanumérico que representa o cliente, usado para rastreamento e referência.    |
| first_name       | NVARCHAR(50)  | O primeiro nome do cliente, conforme registrado no sistema.                                   |
| last_name        | NVARCHAR(50)  | O sobrenome ou nome de família do cliente.                                                    |
| country          | NVARCHAR(50)  | O país de residência do cliente (ex: 'Australia').                                            |
| marital_status   | NVARCHAR(50)  | O estado civil do cliente (ex: 'Married', 'Single').                                          |
| gender           | NVARCHAR(50)  | O gênero do cliente (ex: 'Male', 'Female', 'n/a').                                            |
| birthdate        | DATE          | A data de nascimento do cliente, formatada como AAAA-MM-DD.                                   |
| create_date      | DATE          | A data em que o registro do cliente foi criado no sistema de origem.                          |

---

### 2. **gold.dim_products**
- **Propósito:** Fornece informações detalhadas sobre os produtos e seus atributos técnicos e comerciais.
- **Colunas:**

| Nome da Coluna      | Tipo de Dado  | Descrição                                                                                     |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_key         | INT           | Chave substituta que identifica exclusivamente cada registro de produto na tabela dimensão.    |
| product_id          | INT           | Identificador numérico único atribuído ao produto para rastreamento interno.                   |
| product_number      | NVARCHAR(50)  | Código alfanumérico estruturado que representa o produto, usado para categorização.            |
| product_name        | NVARCHAR(50)  | Nome descritivo do produto (inclui tipo, cor e tamanho).                                       |
| category_id         | NVARCHAR(50)  | Identificador único da categoria, vinculando o produto à sua classificação de alto nível.      |
| category            | NVARCHAR(50)  | Classificação abrangente (ex: Bikes, Components) para agrupar itens relacionados.             |
| subcategory         | NVARCHAR(50)  | Classificação detalhada do produto dentro da categoria (ex: tipo específico de produto).       |
| maintenance_required| NVARCHAR(50)  | Indica se o produto requer manutenção periódica (ex: 'Yes', 'No').                            |
| cost                | INT           | O custo base ou de aquisição do produto em unidades monetárias.                               |
| product_line        | NVARCHAR(50)  | A linha ou série específica à qual o produto pertence (ex: Road, Mountain).                    |
| start_date          | DATE          | A data em que o produto tornou-se disponível para comercialização.                            |

---

### 3. **gold.fact_sales**
- **Propósito:** Armazena dados transacionais de vendas (métricas e chaves) para análise de performance.
- **Colunas:**

| Nome da Coluna  | Tipo de Dado  | Descrição                                                                                     |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | Identificador alfanumérico único para cada pedido de venda (ex: 'SO54496').                   |
| product_key     | INT           | Chave substituta que vincula o fato à dimensão de produtos (gold.dim_products).               |
| customer_key    | INT           | Chave substituta que vincula o fato à dimensão de clientes (gold.dim_customers).               |
| order_date      | DATE          | A data em que o pedido foi registrado.                                                        |
| shipping_date   | DATE          | A data em que o pedido foi enviado ao cliente.                                                |
| due_date        | DATE          | A data de vencimento para o pagamento do pedido.                                              |
| sales_amount    | INT           | O valor monetário total da venda para o item de linha.                                        |
| quantity        | INT           | O número de unidades do produto solicitadas no item de linha.                                 |
| price           | INT           | O preço unitário do produto praticado no momento da venda.                                    |