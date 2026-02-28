-- =============================================
-- FINRISK BANK - Criação das Tabelas
-- Módulo 1: Estrutura do Banco de Dados
-- =============================================


-- STAGING: recebe o CSV bruto sem transformações
CREATE TABLE staging_credit_risk (
    person_age              INT,
    person_income           DECIMAL(12, 2),
    person_home_ownership   VARCHAR(20),
    person_emp_length       DECIMAL(5, 1),
    loan_intent             VARCHAR(30),
    loan_grade              CHAR(1),
    loan_amnt               DECIMAL(12, 2),
    loan_int_rate           DECIMAL(5, 2),
    loan_status             SMALLINT,
    loan_percent_income     DECIMAL(5, 4),
    cb_default_on_file      CHAR(1),
    cb_cred_hist_length     INT
);

-- TABELA FINAL: clientes
CREATE TABLE clientes (
    id_cliente          SERIAL PRIMARY KEY,
    idade               INT,
    renda_anual         DECIMAL(12, 2),
    tipo_moradia        VARCHAR(20),
    tempo_emprego_anos  DECIMAL(5, 1)
);

-- TABELA FINAL: historico_credito
CREATE TABLE historico_credito (
    id_historico            SERIAL PRIMARY KEY,
    id_cliente              INT NOT NULL REFERENCES clientes(id_cliente),
    default_anterior        CHAR(1),
    anos_historico_credito  INT
);

-- TABELA FINAL: emprestimos
CREATE TABLE emprestimos (
    id_emprestimo       SERIAL PRIMARY KEY,
    id_cliente          INT NOT NULL REFERENCES clientes(id_cliente),
    finalidade          VARCHAR(30),
    rating              CHAR(1),
    valor_solicitado    DECIMAL(12, 2),
    taxa_juros          DECIMAL(5, 2),
    pct_renda           DECIMAL(5, 4),
    status_default      SMALLINT
);