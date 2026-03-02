-- Ranqueando clientes do mais arriscado para o menos arriscado
SELECT
    c.id_cliente,
    c.tipo_moradia,
    c.renda_anual,
    e.rating,
    e.taxa_juros,
    e.valor_solicitado,
    hc.default_anterior,

    -- RANK: classifica cada cliente dentro do seu grupo de moradia
    -- do mais caro (maior juros = maior risco) para o mais barato
    RANK() OVER (
        PARTITION BY c.tipo_moradia
        ORDER BY e.taxa_juros DESC nulls last
    ) AS ranking_risco_por_moradia,

    -- RANK geral ignorando moradia — posição na carteira toda
    RANK() OVER (
        ORDER BY e.taxa_juros DESC nulls last
    ) AS ranking_risco_geral

FROM clientes c
JOIN emprestimos e ON c.id_cliente = e.id_cliente
JOIN historico_credito hc ON c.id_cliente = hc.id_cliente
ORDER BY ranking_risco_geral
LIMIT 20;

-- NTILE divide toda a carteira em N grupos iguais
-- Aqui criamos 4 quartis de risco (como um score interno do banco)
SELECT
    id_cliente,
    tipo_moradia,
    renda_anual,
    rating,
    taxa_juros,
    status_default,

    -- Divide em 4 grupos: 1 = menor risco, 4 = maior risco
    NTILE(4) OVER (ORDER BY taxa_juros DESC NULLS LAST) AS quartil_risco,

    -- Percentual acumulado de onde esse cliente está na carteira
    ROUND(
        100.0 * ROW_NUMBER() OVER (ORDER BY taxa_juros DESC NULLS LAST)
        / COUNT(*) OVER (),
    2) AS percentil

FROM clientes c
JOIN emprestimos e ON c.id_cliente = e.id_cliente
ORDER BY taxa_juros DESC NULLS LAST
LIMIT 20;