-- ============================================
-- SCRIPT DE TESTE - BIBLIOTECA UNIVERSITÁRIA
-- Versão SQLite (compatível com VS Code)
-- ============================================

-- Limpar tabelas existentes
DROP TABLE IF EXISTS RESERVA;
DROP TABLE IF EXISTS MULTA;
DROP TABLE IF EXISTS EMPRESTIMO;
DROP TABLE IF EXISTS LIVRO;
DROP TABLE IF EXISTS USUARIO;

-- Criação das tabelas
CREATE TABLE USUARIO (
    id_usuario      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome            TEXT NOT NULL,
    matricula       TEXT UNIQUE NOT NULL,
    tipo_vinculo    TEXT NOT NULL CHECK(tipo_vinculo IN ('Aluno', 'Professor', 'Funcionário')),
    curso           TEXT,
    email           TEXT UNIQUE NOT NULL,
    telefone        TEXT,
    data_cadastro   DATE NOT NULL DEFAULT (date('now')),
    status          TEXT DEFAULT 'Ativo' CHECK(status IN ('Ativo', 'Inativo'))
);

CREATE TABLE LIVRO (
    isbn                    TEXT PRIMARY KEY,
    titulo                  TEXT NOT NULL,
    autor                   TEXT NOT NULL,
    editora                 TEXT,
    ano_publicacao          INTEGER CHECK (ano_publicacao > 1500 AND ano_publicacao <= 2025),
    categoria               TEXT NOT NULL,
    edicao                  INTEGER DEFAULT 1,
    total_exemplares        INTEGER NOT NULL CHECK (total_exemplares >= 0),
    exemplares_disponiveis  INTEGER NOT NULL CHECK (exemplares_disponiveis >= 0),
    localizacao             TEXT,
    CHECK (exemplares_disponiveis <= total_exemplares)
);

CREATE TABLE EMPRESTIMO (
    id_emprestimo           INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario              INTEGER NOT NULL,
    isbn                    TEXT NOT NULL,
    data_emprestimo         DATE NOT NULL DEFAULT (date('now')),
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao_real     DATE,
    status                  TEXT DEFAULT 'Emprestado' CHECK(status IN ('Emprestado', 'Devolvido', 'Atrasado')),
    observacoes             TEXT,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
    FOREIGN KEY (isbn) REFERENCES LIVRO(isbn),
    CHECK (data_devolucao_real IS NULL OR data_devolucao_real >= data_emprestimo),
    CHECK (data_prevista_devolucao > data_emprestimo)
);

CREATE TABLE MULTA (
    id_multa        INTEGER PRIMARY KEY AUTOINCREMENT,
    id_emprestimo   INTEGER UNIQUE NOT NULL,
    id_usuario      INTEGER NOT NULL,
    valor           REAL NOT NULL CHECK (valor >= 0),
    dias_atraso     INTEGER NOT NULL CHECK (dias_atraso > 0),
    data_geracao    DATE NOT NULL DEFAULT (date('now')),
    data_pagamento  DATE,
    status          TEXT DEFAULT 'Pendente' CHECK(status IN ('Pendente', 'Paga', 'Cancelada')),
    FOREIGN KEY (id_emprestimo) REFERENCES EMPRESTIMO(id_emprestimo) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
    CHECK (data_pagamento IS NULL OR data_pagamento >= data_geracao)
);

CREATE TABLE RESERVA (
    id_reserva      INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario      INTEGER NOT NULL,
    isbn            TEXT NOT NULL,
    data_reserva    DATE NOT NULL DEFAULT (date('now')),
    data_validade   DATE NOT NULL,
    status          TEXT DEFAULT 'Ativa' CHECK(status IN ('Ativa', 'Atendida', 'Cancelada', 'Expirada')),
    prioridade      INTEGER NOT NULL CHECK (prioridade > 0),
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (isbn) REFERENCES LIVRO(isbn) ON DELETE CASCADE,
    CHECK (data_validade > data_reserva)
);

-- Inserção de dados de teste
INSERT INTO USUARIO (nome, matricula, tipo_vinculo, curso, email, telefone, data_cadastro) VALUES
('João Silva', '20231001', 'Aluno', 'Ciência da Computação', 'joao.silva@univ.br', '11987654321', '2025-01-15'),
('Maria Santos', '20232002', 'Aluno', 'Engenharia de Software', 'maria.santos@univ.br', '11987654322', '2025-01-20'),
('Pedro Costa', '20233003', 'Aluno', 'Sistemas de Informação', 'pedro.costa@univ.br', '11987654323', '2025-02-10'),
('Dr. Carlos Oliveira', 'P-0001', 'Professor', 'Computação', 'carlos.oliveira@univ.br', '11987654324', '2020-03-01'),
('Dra. Ana Paula', 'P-0002', 'Professor', 'Matemática', 'ana.paula@univ.br', '11987654325', '2019-08-15'),
('Roberto Lima', 'F-0001', 'Funcionário', NULL, 'roberto.lima@univ.br', '11987654326', '2018-06-20');

INSERT INTO LIVRO (isbn, titulo, autor, editora, ano_publicacao, categoria, edicao, total_exemplares, exemplares_disponiveis, localizacao) VALUES
('9788535902773', 'Banco de Dados', 'Ramakrishnan & Gehrke', 'McGraw-Hill', 2005, 'Tecnologia', 3, 5, 3, 'Prateleira A-12'),
('9788573076905', 'Inteligência Artificial', 'Russell & Norvig', 'Elsevier', 2013, 'Tecnologia', 3, 4, 2, 'Prateleira A-15'),
('9788522106356', 'Algoritmos', 'Cormen et al.', 'Campus', 2012, 'Tecnologia', 3, 6, 4, 'Prateleira A-08'),
('9788582600320', 'Engenharia de Software', 'Sommerville', 'Pearson', 2011, 'Tecnologia', 9, 5, 5, 'Prateleira A-20'),
('9788535235487', 'Cálculo Vol. 1', 'Stewart', 'Cengage', 2013, 'Matemática', 7, 8, 6, 'Prateleira B-05'),
('9788521618690', 'Física Quântica', 'Eisberg & Resnick', 'Campus', 1979, 'Física', 1, 3, 1, 'Prateleira C-10');

INSERT INTO EMPRESTIMO (id_usuario, isbn, data_emprestimo, data_prevista_devolucao, data_devolucao_real, status, observacoes) VALUES
(1, '9788535902773', '2025-10-01', '2025-10-15', '2025-10-14', 'Devolvido', 'Devolução no prazo'),
(2, '9788573076905', '2025-10-05', '2025-10-19', '2025-10-18', 'Devolvido', 'Devolução no prazo'),
(3, '9788522106356', '2025-11-20', '2025-12-04', NULL, 'Emprestado', 'Empréstimo ativo'),
(4, '9788535235487', '2025-11-15', '2025-12-15', NULL, 'Emprestado', 'Professor - prazo estendido'),
(1, '9788573076905', '2025-11-01', '2025-11-15', NULL, 'Atrasado', 'Atraso de 16 dias'),
(2, '9788521618690', '2025-11-05', '2025-11-19', NULL, 'Atrasado', 'Atraso de 12 dias');

INSERT INTO MULTA (id_emprestimo, id_usuario, valor, dias_atraso, data_geracao, data_pagamento, status) VALUES
(5, 1, 8.00, 16, '2025-11-16', NULL, 'Pendente'),
(6, 2, 6.00, 12, '2025-11-20', NULL, 'Pendente');

INSERT INTO RESERVA (id_usuario, isbn, data_reserva, data_validade, status, prioridade) VALUES
(3, '9788573076905', '2025-11-25', '2025-12-10', 'Ativa', 1),
(1, '9788521618690', '2025-11-28', '2025-12-12', 'Ativa', 2),
(2, '9788535902773', '2025-11-29', '2025-12-13', 'Ativa', 1);
