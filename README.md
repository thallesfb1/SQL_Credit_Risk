# 📊 FinRisk Bank — Análise de Crédito e Risco com SQL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Avançado-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Concluído-green?style=for-the-badge)

Projeto de análise de dados com foco em **crédito e risco**, desenvolvido para demonstrar domínio de SQL aplicado a um contexto financeiro real. Utilizei um dataset público com **32.581 empréstimos reais** para identificar padrões de inadimplência e construir uma visão de risco da carteira.

---

## 🎯 Objetivo

Simular o ambiente analítico de uma fintech ou banco, respondendo perguntas reais de negócio sobre inadimplência, perfil de clientes e risco de crédito — do tipo que analistas de crédito e cientistas de dados enfrentam no dia a dia.

---

## 🗂️ Estrutura do Projeto

```
finrisk-sql/
│
├── 01_estrutura/
│   └── criar_tabelas.sql          # DDL: criação do banco e tabelas
│
├── 02_dados/
│   └── importar_staging.sql       # Pipeline: staging → tabelas finais
│
├── 03_queries/
│   ├── analise_inadimplencia.sql  # Análises de risco e default
│   └── ranking_clientes.sql       # Window Functions e quartis
│
└── README.md
```
## Diagrama das tabelas
![Diagrama das Tabelas](postgres%20-%20finrisk_bank%20-%20public.png)
---

## 🗄️ Modelagem de Dados

O banco é composto por **4 tabelas relacionais**:

| Tabela | Descrição | Registros |
|---|---|---|
| `staging_credit_risk` | Dados brutos importados do CSV | 32.581 |
| `clientes` | Perfil de cada tomador de crédito | 32.581 |
| `emprestimos` | Dados de cada operação de crédito | 32.581 |
| `historico_credito` | Histórico financeiro do cliente | 32.581 |

> 💡 A separação entre staging e tabelas finais segue boas práticas de engenharia de dados — nunca trabalhar diretamente sobre o dado bruto.

---

## 📦 Dataset

**Fonte:** [Credit Risk Dataset — Kaggle](https://www.kaggle.com/datasets/laotse/credit-risk-dataset)

Dataset público com informações reais de empréstimos pessoais, contendo variáveis como idade, renda, tipo de moradia, finalidade do empréstimo, rating de risco, taxa de juros e status de default.

---

## 🔍 Perguntas de Negócio Respondidas

### 1. Qual é a taxa de default geral da carteira?

> **21,8% dos empréstimos resultaram em default** — quase 1 em cada 5 operações.

```sql
SELECT
    status_default,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentual
FROM emprestimos
GROUP BY status_default;
```

---

### 2. Tipo de moradia influencia o risco?

> **Sim — e de forma expressiva.** Clientes com imóvel próprio têm taxa de default 4x menor do que quem aluga.

| Moradia | Taxa de Default |
|---|---|
| RENT (aluguel) | 31,57% |
| OTHER | 30,84% |
| MORTGAGE (financiamento) | 12,57% |
| OWN (imóvel próprio) | **7,47%** |

```sql
SELECT
    c.tipo_moradia,
    COUNT(*) AS total_emprestimos,
    ROUND(SUM(e.status_default) * 100.0 / COUNT(*), 2) AS taxa_default_pct
FROM clientes c
JOIN emprestimos e ON c.id_cliente = e.id_cliente
GROUP BY c.tipo_moradia
ORDER BY taxa_default_pct DESC;
```

---

### 3. Histórico de default prediz inadimplência futura?

> **Sim — quem já deu default antes tem o dobro de chance de repetir.**

| Default Anterior | Taxa de Default |
|---|---|
| Y (sim) | 37,81% |
| N (não) | 18,39% |

---

### 4. O sistema de rating do banco está bem calibrado?

> **Sim — a progressão é quase perfeita**, do rating A (menor risco) ao G (maior risco).

| Rating | Juros Médio | Taxa de Default |
|---|---|---|
| A | 7,33% | ~10% |
| B | 11,00% | ~16% |
| C | 13,46% | ~21% |
| D | 15,36% | ~59% |
| E | 17,01% | ~64% |
| F | 18,61% | ~70% |
| G | 20,25% | ~98% |

---

### 5. Qual finalidade de empréstimo concentra mais inadimplência?

> **MEDICAL lidera** — quem pega crédito para despesa médica já está em situação de vulnerabilidade financeira.

| Finalidade | Qtd. Defaults |
|---|---|
| MEDICAL | 1.621 |
| DEBTCONSOLIDATION | 1.490 |
| EDUCATION | 1.111 |
| PERSONAL | 1.098 |

---

### 6. Como a carteira se divide em quartis de risco?

> **O quartil de maior risco tem taxa de default 5,7x maior que o de menor risco** — e renda média similar, provando que renda sozinha não prediz inadimplência.

| Quartil | Juros Médio | Renda Média | Taxa de Default |
|---|---|---|---|
| 1 (menor risco) | 7% | R$ 66.318 | **9,39%** |
| 2 | 10,19% | R$ 65.977 | 15,69% |
| 3 | 12,82% | R$ 65.751 | 21,20% |
| 4 (maior risco) | 15,91% | R$ 66.042 | **53,57%** |

```sql
WITH quartis AS (
    SELECT
        e.taxa_juros,
        e.status_default,
        c.renda_anual,
        NTILE(4) OVER (ORDER BY e.taxa_juros ASC NULLS LAST) AS quartil_risco
    FROM clientes c
    JOIN emprestimos e ON c.id_cliente = e.id_cliente
)
SELECT
    quartil_risco,
    ROUND(AVG(taxa_juros), 2) AS juros_medio,
    ROUND(AVG(renda_anual), 2) AS renda_media,
    ROUND(SUM(status_default) * 100.0 / COUNT(*), 2) AS taxa_default_pct
FROM quartis
WHERE taxa_juros IS NOT NULL
GROUP BY quartil_risco
ORDER BY quartil_risco;
```

---

## 🛠️ Técnicas SQL Utilizadas

| Técnica | Aplicação no Projeto |
|---|---|
| `DDL` (CREATE TABLE) | Modelagem do banco relacional com 4 tabelas |
| `DML` (INSERT, UPDATE) | Pipeline de staging para tabelas finais |
| `SELECT` + `WHERE` | Filtros e exploração dos dados |
| `JOIN` duplo e triplo | Cruzamento de clientes, empréstimos e histórico |
| `GROUP BY` + `HAVING` | Agregações por perfil de cliente |
| `CTE` (WITH) | Análises em camadas com queries encadeadas |
| `Window Functions` | RANK, NTILE, ROW_NUMBER para ranking e quartis |
| `NULLS LAST` | Tratamento de dados ausentes em dados reais |

---

## 🚀 Como Reproduzir

### Pré-requisitos
- PostgreSQL instalado localmente
- DBeaver (ou qualquer client SQL)

### Passo a passo

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/finrisk-sql.git

# 2. Acesse a pasta
cd finrisk-sql
```

1. Execute `01_estrutura/criar_tabelas.sql` para criar o banco e as tabelas
2. Baixe o dataset no [Kaggle](https://www.kaggle.com/datasets/laotse/credit-risk-dataset) e importe o CSV na tabela `staging_credit_risk` via DBeaver
3. Execute `02_dados/importar_staging.sql` para popular as tabelas finais
4. Explore as queries em `03_queries/`

---

## 👤 Autor 

Desenvolvido como projeto de portfólio durante migração de carreira para a área de **Dados com foco em Crédito e Risco**.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Conectar-0077B5?style=for-the-badge&logo=linkedin)](www.linkedin.com/in/thalles-freitas-brettas)
[![GitHub](https://img.shields.io/badge/GitHub-Seguir-181717?style=for-the-badge&logo=github)](https://github.com/thallesfb1)
