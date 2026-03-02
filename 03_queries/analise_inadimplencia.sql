-- Quantos clientes por tipo de moradia ?
select 
    tipo_moradia, 
    count(*) as quantidade_clientes
from 
    clientes
group by 
    tipo_moradia
order by
    quantidade_clientes desc;

-- De todos empréstimos, quantos deram default e quantos não deram ?
select 
    status_default, 
    count(*) as quantidade_emprestimos
from 
    emprestimos
group by 
    status_default
order by
    quantidade_emprestimos desc;

-- Qual finalidade de crédito mais tem inadimplentes ?
select 
    finalidade, 
    count(*) as quantidade_inadimplentes
from 
    emprestimos
where
    status_default = 1
group by
    finalidade
order by
    quantidade_inadimplentes desc;

-- Qual tipo de moradia tem mais taxa de inadimplencia?
SELECT
    c.tipo_moradia,
    COUNT(*) AS total_emprestimos,
    SUM(e.status_default) AS total_default,
    ROUND(SUM(e.status_default) * 100.0 / COUNT(*), 2) AS taxa_default_pct
FROM clientes c
JOIN emprestimos e ON c.id_cliente = e.id_cliente
GROUP BY c.tipo_moradia
ORDER BY taxa_default_pct DESC;

-- Quem já deu default anterior tem mais chance de dar default novamente?
Select
    hc.default_anterior,
    count(*) as quantidade_emprestimos,
    sum(e.status_default) as quantidade_inadimplentes,
    round(sum(e.status_default) * 100.0 / count(*), 2) as taxa_default_pct
from historico_credito hc
join emprestimos e on hc.id_cliente = e.id_cliente
join clientes c on c.id_cliente = e.id_cliente
group by hc.default_anterior
order by taxa_default_pct desc;

-- Será que o rating dos clientes está correto? Qual é a taxa de inadimplência por rating?
Select 
    e.rating,
    Count(*) as quantidade_emprestimos,
    round(avg(c.renda_anual),2) as renda_anual_media,
    round(avg(e.taxa_juros),2) as taxa_juros_media,
    Sum(e.status_default) as quantidade_inadimplentes,
    Round(Sum(e.status_default) * 100.0 / Count(*), 2) as taxa_default_pct
from clientes c
join emprestimos e on c.id_cliente = e.id_cliente
group by e.rating
order by taxa_default_pct desc;

-- Visão 360° do risco: combinando moradia, histórico e rating
WITH base AS (
    SELECT
        c.tipo_moradia,
        e.rating,
        hc.default_anterior,
        e.status_default,
        c.renda_anual,
        e.taxa_juros,
        e.valor_solicitado
    FROM clientes c
    JOIN emprestimos e ON c.id_cliente = e.id_cliente
    JOIN historico_credito hc ON c.id_cliente = hc.id_cliente
),
resumo AS (
    SELECT
        tipo_moradia,
        rating,
        default_anterior,
        COUNT(*) AS total,
        ROUND(SUM(status_default) * 100.0 / COUNT(*), 2) AS taxa_default_pct,
        ROUND(AVG(renda_anual), 2) AS renda_media,
        ROUND(AVG(taxa_juros), 2) AS juros_medio
    FROM base
    GROUP BY tipo_moradia, rating, default_anterior
)
SELECT *
FROM resumo
WHERE total >= 50  -- filtra combinações com volume relevante
ORDER BY taxa_default_pct DESC
LIMIT 20;
