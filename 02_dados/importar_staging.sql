insert into clientes (idade, renda_anual, tipo_moradia, tempo_emprego_anos)
select person_age,
    person_income,
    person_home_ownership,
    person_emp_length
from staging_credit_risk;

select count(*) from clientes;

-- Após a inserção dos dados na tabela clientes, precisamos inserir os dados relacionados nas tabelas emprestimos e historico_credito.
-- Para isso, utilizaremos a função row_number() para criar uma correspondência entre as linhas da tabela staging_credit_risk e os clientes recém-inseridos, garantindo que os dados sejam relacionados corretamente.

insert into emprestimos (id_cliente, finalidade, rating, valor_solicitado, taxa_juros, pct_renda, status_default)
select 
    c.id_cliente,
    scr.loan_intent,
    scr.loan_grade,
    scr.loan_amnt,
    scr.loan_int_rate,
    scr.loan_percent_income,
    scr.loan_status
    FROM (Select row_number() over (order by (select null)) as rn, * from staging_credit_risk) scr
    JOIN (Select row_number() over (order by (select null)) as rn, id_cliente from clientes) c
    ON scr.rn = c.rn;
-- O mesmo processo é aplicado para a tabela historico_credito, garantindo que os dados de histórico de crédito sejam relacionados corretamente com os clientes.
    insert into historico_credito (id_cliente, default_anterior, anos_historico_credito)
select
    c.id_cliente,
    scr.cb_person_default_on_file,
    scr.cb_cred_hist_length
    FROM (Select row_number() over (order by (select null)) as rn, * from staging_credit_risk) scr
    JOIN (Select row_number() over (order by (select null)) as rn, id_cliente from clientes) c
    ON scr.rn = c.rn;

--Visualização dos dados inseridos

select count(*) from emprestimos;
select count(*) from historico_credito;