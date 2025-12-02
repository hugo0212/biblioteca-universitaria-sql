-- ============================================
-- 2. CONSULTAS SELECT - MANIPULAÇÃO DE DADOS
-- ============================================

-- Consulta 1: Listar todos os livros de Tecnologia disponíveis
SELECT 
    isbn,
    titulo,
    autor,
    ano_publicacao,
    exemplares_disponiveis,
    localizacao
FROM LIVRO
WHERE categoria = 'Tecnologia' 
  AND exemplares_disponiveis > 0
ORDER BY titulo;

-- Consulta 2: Buscar empréstimos atrasados com informações do usuário e livro
SELECT 
    u.nome AS usuario,
    u.email,
    l.titulo AS livro,
    e.data_emprestimo,
    e.data_prevista_devolucao,
    julianday('now') - julianday(e.data_prevista_devolucao) AS dias_atraso
FROM EMPRESTIMO e
INNER JOIN USUARIO u ON e.id_usuario = u.id_usuario
INNER JOIN LIVRO l ON e.isbn = l.isbn
WHERE e.status = 'Atrasado'
ORDER BY dias_atraso DESC;

-- Consulta 3: Top 5 livros mais emprestados
SELECT 
    l.titulo,
    l.autor,
    l.categoria,
    COUNT(e.id_emprestimo) AS total_emprestimos
FROM LIVRO l
LEFT JOIN EMPRESTIMO e ON l.isbn = e.isbn
GROUP BY l.isbn, l.titulo, l.autor, l.categoria
ORDER BY total_emprestimos DESC
LIMIT 5;

-- Consulta 4: Usuários com multas pendentes e valor total
SELECT 
    u.nome,
    u.matricula,
    u.email,
    COUNT(m.id_multa) AS quantidade_multas,
    SUM(m.valor) AS valor_total_multas
FROM USUARIO u
INNER JOIN MULTA m ON u.id_usuario = m.id_usuario
WHERE m.status = 'Pendente'
GROUP BY u.id_usuario, u.nome, u.matricula, u.email
ORDER BY valor_total_multas DESC;

-- Consulta 5: Reservas ativas com posição na fila
SELECT 
    r.id_reserva,
    u.nome AS usuario,
    u.email,
    l.titulo AS livro,
    r.data_reserva,
    r.data_validade,
    r.prioridade AS posicao_fila,
    julianday(r.data_validade) - julianday('now') AS dias_restantes
FROM RESERVA r
INNER JOIN USUARIO u ON r.id_usuario = u.id_usuario
INNER JOIN LIVRO l ON r.isbn = l.isbn
WHERE r.status = 'Ativa'
  AND r.data_validade >= date('now')
ORDER BY l.titulo, r.prioridade;

-- Consulta 6: Histórico completo de empréstimos por usuário (com LIMIT)
SELECT 
    u.nome AS usuario,
    l.titulo AS livro,
    e.data_emprestimo,
    e.data_prevista_devolucao,
    e.data_devolucao_real,
    e.status,
    CASE 
        WHEN e.data_devolucao_real IS NOT NULL 
        THEN julianday(e.data_devolucao_real) - julianday(e.data_emprestimo)
        ELSE julianday('now') - julianday(e.data_emprestimo)
    END AS dias_com_livro
FROM EMPRESTIMO e
INNER JOIN USUARIO u ON e.id_usuario = u.id_usuario
INNER JOIN LIVRO l ON e.isbn = l.isbn
WHERE u.matricula = '20231001'
ORDER BY e.data_emprestimo DESC
LIMIT 10;
