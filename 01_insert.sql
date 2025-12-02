-- ============================================
-- 1. SCRIPTS DE INSERT - POPULAR TABELAS
-- ============================================

-- Inserir mais usuários
INSERT INTO USUARIO (nome, matricula, tipo_vinculo, curso, email, telefone, data_cadastro) VALUES
('Lucas Mendes', '20234004', 'Aluno', 'Análise de Sistemas', 'lucas.mendes@univ.br', '11987654327', '2025-03-01'),
('Fernanda Alves', '20235005', 'Aluno', 'Ciência da Computação', 'fernanda.alves@univ.br', '11987654328', '2025-03-15'),
('Prof. Ricardo Santos', 'P-0003', 'Professor', 'Engenharia', 'ricardo.santos@univ.br', '11987654329', '2021-02-10');

-- Inserir mais livros
INSERT INTO LIVRO (isbn, titulo, autor, editora, ano_publicacao, categoria, edicao, total_exemplares, exemplares_disponiveis, localizacao) VALUES
('9788575225127', 'Python Para Análise de Dados', 'Wes McKinney', 'Novatec', 2018, 'Tecnologia', 2, 4, 4, 'Prateleira A-18'),
('9788582605127', 'Redes de Computadores', 'Tanenbaum', 'Pearson', 2011, 'Tecnologia', 5, 5, 3, 'Prateleira A-25'),
('9788535290929', 'Estruturas de Dados', 'Loiane Groner', 'Novatec', 2018, 'Tecnologia', 1, 3, 3, 'Prateleira A-30');

-- Inserir novos empréstimos
INSERT INTO EMPRESTIMO (id_usuario, isbn, data_emprestimo, data_prevista_devolucao, status, observacoes) VALUES
(7, '9788575225127', '2025-11-28', '2025-12-12', 'Emprestado', 'Primeiro empréstimo do aluno'),
(8, '9788582605127', '2025-11-29', '2025-12-13', 'Emprestado', 'Empréstimo ativo');
