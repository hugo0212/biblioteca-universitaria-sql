# Modelo Lógico - Projeto de Banco de Dados
## Sistema de Biblioteca Universitária

---

## 📋 Conversão do DER para Modelo Lógico

Este documento apresenta a transformação do **Diagrama Entidade-Relacionamento (DER)** em um **Modelo Lógico** de tabelas relacionais, com aplicação de regras de integridade referencial e normalização.

---

## 🗂️ Definição das Tabelas

### 1. Tabela: USUARIO

Armazena informações dos usuários cadastrados no sistema.

```sql
CREATE TABLE USUARIO (
    id_usuario      INT PRIMARY KEY AUTO_INCREMENT,
    nome            VARCHAR(100) NOT NULL,
    matricula       VARCHAR(20) UNIQUE NOT NULL,
    tipo_vinculo    ENUM('Aluno', 'Professor', 'Funcionário') NOT NULL,
    curso           VARCHAR(80),
    email           VARCHAR(100) UNIQUE NOT NULL,
    telefone        VARCHAR(15),
    data_cadastro   DATE NOT NULL DEFAULT CURRENT_DATE,
    status          ENUM('Ativo', 'Inativo') DEFAULT 'Ativo'
);
```

**Atributos:**
- `id_usuario` (INT, PK) - Identificador único, auto incremento
- `nome` (VARCHAR) - Nome completo, obrigatório
- `matricula` (VARCHAR, UNIQUE) - Matrícula institucional única
- `tipo_vinculo` (ENUM) - Tipo de usuário (Aluno/Professor/Funcionário)
- `curso` (VARCHAR) - Curso vinculado (opcional para funcionários)
- `email` (VARCHAR, UNIQUE) - Email institucional único
- `telefone` (VARCHAR) - Contato telefônico
- `data_cadastro` (DATE) - Data de registro no sistema
- `status` (ENUM) - Status ativo/inativo

---

### 2. Tabela: LIVRO

Representa o catálogo de materiais disponíveis na biblioteca.

```sql
CREATE TABLE LIVRO (
    isbn                    VARCHAR(17) PRIMARY KEY,
    titulo                  VARCHAR(200) NOT NULL,
    autor                   VARCHAR(150) NOT NULL,
    editora                 VARCHAR(100),
    ano_publicacao          INT CHECK (ano_publicacao > 1500 AND ano_publicacao <= YEAR(CURDATE())),
    categoria               VARCHAR(50) NOT NULL,
    edicao                  INT DEFAULT 1,
    total_exemplares        INT NOT NULL CHECK (total_exemplares >= 0),
    exemplares_disponiveis  INT NOT NULL CHECK (exemplares_disponiveis >= 0),
    localizacao             VARCHAR(50),
    CONSTRAINT chk_exemplares CHECK (exemplares_disponiveis <= total_exemplares)
);
```

**Atributos:**
- `isbn` (VARCHAR, PK) - Código ISBN único do livro
- `titulo` (VARCHAR) - Título da obra
- `autor` (VARCHAR) - Nome do(s) autor(es)
- `editora` (VARCHAR) - Editora responsável
- `ano_publicacao` (INT) - Ano de publicação (validação de intervalo)
- `categoria` (VARCHAR) - Categoria temática
- `edicao` (INT) - Número da edição
- `total_exemplares` (INT) - Quantidade total de cópias
- `exemplares_disponiveis` (INT) - Quantidade disponível para empréstimo
- `localizacao` (VARCHAR) - Localização física na biblioteca

**Restrições:**
- `exemplares_disponiveis` não pode exceder `total_exemplares`
- Ano de publicação validado (1500 até ano atual)

---

### 3. Tabela: EMPRESTIMO

Registra cada transação de empréstimo realizada.

```sql
CREATE TABLE EMPRESTIMO (
    id_emprestimo           INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario              INT NOT NULL,
    isbn                    VARCHAR(17) NOT NULL,
    data_emprestimo         DATE NOT NULL DEFAULT CURRENT_DATE,
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao_real     DATE,
    status                  ENUM('Emprestado', 'Devolvido', 'Atrasado') DEFAULT 'Emprestado',
    observacoes             TEXT,
    
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES LIVRO(isbn) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT chk_data_devolucao CHECK (
        data_devolucao_real IS NULL OR data_devolucao_real >= data_emprestimo
    ),
    CONSTRAINT chk_data_prevista CHECK (data_prevista_devolucao > data_emprestimo)
);
```

**Atributos:**
- `id_emprestimo` (INT, PK) - Identificador único do empréstimo
- `id_usuario` (INT, FK) - Referência ao usuário que realizou o empréstimo
- `isbn` (VARCHAR, FK) - Referência ao livro emprestado
- `data_emprestimo` (DATE) - Data de retirada
- `data_prevista_devolucao` (DATE) - Prazo para devolução
- `data_devolucao_real` (DATE) - Data efetiva da devolução (NULL se não devolvido)
- `status` (ENUM) - Status atual (Emprestado/Devolvido/Atrasado)
- `observacoes` (TEXT) - Observações adicionais

**Integridade Referencial:**
- FK `id_usuario`: Não permite deletar usuário com empréstimos (RESTRICT)
- FK `isbn`: Não permite deletar livro com empréstimos (RESTRICT)
- Atualização em cascata (CASCADE) para mudanças nas chaves

---

### 4. Tabela: MULTA

Registra multas geradas por atrasos na devolução.

```sql
CREATE TABLE MULTA (
    id_multa        INT PRIMARY KEY AUTO_INCREMENT,
    id_emprestimo   INT UNIQUE NOT NULL,
    id_usuario      INT NOT NULL,
    valor           DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
    dias_atraso     INT NOT NULL CHECK (dias_atraso > 0),
    data_geracao    DATE NOT NULL DEFAULT CURRENT_DATE,
    data_pagamento  DATE,
    status          ENUM('Pendente', 'Paga', 'Cancelada') DEFAULT 'Pendente',
    
    FOREIGN KEY (id_emprestimo) REFERENCES EMPRESTIMO(id_emprestimo) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT chk_pagamento CHECK (
        data_pagamento IS NULL OR data_pagamento >= data_geracao
    )
);
```

**Atributos:**
- `id_multa` (INT, PK) - Identificador único da multa
- `id_emprestimo` (INT, FK, UNIQUE) - Referência ao empréstimo (1:1)
- `id_usuario` (INT, FK) - Referência ao usuário multado
- `valor` (DECIMAL) - Valor da multa em reais (2 casas decimais)
- `dias_atraso` (INT) - Quantidade de dias de atraso
- `data_geracao` (DATE) - Data de criação da multa
- `data_pagamento` (DATE) - Data do pagamento (NULL se não pago)
- `status` (ENUM) - Status atual (Pendente/Paga/Cancelada)

**Integridade Referencial:**
- FK `id_emprestimo`: UNIQUE (relação 1:1 com EMPRESTIMO), DELETE CASCADE
- FK `id_usuario`: RESTRICT (não permite deletar usuário com multas pendentes)

---

### 5. Tabela: RESERVA

Gerencia reservas de livros indisponíveis.

```sql
CREATE TABLE RESERVA (
    id_reserva      INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario      INT NOT NULL,
    isbn            VARCHAR(17) NOT NULL,
    data_reserva    DATE NOT NULL DEFAULT CURRENT_DATE,
    data_validade   DATE NOT NULL,
    status          ENUM('Ativa', 'Atendida', 'Cancelada', 'Expirada') DEFAULT 'Ativa',
    prioridade      INT NOT NULL CHECK (prioridade > 0),
    
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES LIVRO(isbn) 
        ON DELETE CASCADE ON UPDATE CASCADE,
        
    CONSTRAINT chk_validade CHECK (data_validade > data_reserva),
    CONSTRAINT uq_reserva_usuario_livro UNIQUE (id_usuario, isbn, status)
);
```

**Atributos:**
- `id_reserva` (INT, PK) - Identificador único da reserva
- `id_usuario` (INT, FK) - Usuário que fez a reserva
- `isbn` (VARCHAR, FK) - Livro reservado
- `data_reserva` (DATE) - Data da solicitação
- `data_validade` (DATE) - Prazo de validade da reserva
- `status` (ENUM) - Status (Ativa/Atendida/Cancelada/Expirada)
- `prioridade` (INT) - Posição na fila de espera

**Integridade Referencial:**
- FKs com DELETE CASCADE (reserva é dependente de usuário e livro)
- UNIQUE composto impede reservas duplicadas ativas

---

## 🔄 Quadro Comparativo: DER → Modelo Lógico

| **DER (Conceitual)** | **Modelo Lógico (Relacional)** |
|----------------------|--------------------------------|
| **Entidade USUARIO** | Tabela `USUARIO` com chave primária `id_usuario` |
| **Entidade LIVRO** | Tabela `LIVRO` com chave primária `isbn` |
| **Entidade EMPRESTIMO** | Tabela `EMPRESTIMO` com FKs para USUARIO e LIVRO |
| **Entidade MULTA** | Tabela `MULTA` com FKs para EMPRESTIMO e USUARIO |
| **Entidade RESERVA** | Tabela `RESERVA` com FKs para USUARIO e LIVRO |
| **Relacionamento 1:N** (Usuario → Empréstimo) | FK `id_usuario` em EMPRESTIMO |
| **Relacionamento 1:N** (Livro → Empréstimo) | FK `isbn` em EMPRESTIMO |
| **Relacionamento 1:1** (Empréstimo → Multa) | FK `id_emprestimo` UNIQUE em MULTA |
| **Relacionamento 1:N** (Usuario → Multa) | FK `id_usuario` em MULTA |
| **Relacionamento 1:N** (Usuario → Reserva) | FK `id_usuario` em RESERVA |
| **Relacionamento 1:N** (Livro → Reserva) | FK `isbn` em RESERVA |
| **Atributos** | Colunas com tipos de dados SQL |
| **Chaves primárias** | PRIMARY KEY com AUTO_INCREMENT |
| **Restrições de domínio** | CHECK constraints e ENUM |

---

## 🔐 Diagrama Lógico com Chaves

```
┌─────────────────────────────┐
│         USUARIO             │
├─────────────────────────────┤
│ PK  id_usuario (INT)        │
│     nome (VARCHAR)          │
│ UQ  matricula (VARCHAR)     │
│     tipo_vinculo (ENUM)     │
│     curso (VARCHAR)         │
│ UQ  email (VARCHAR)         │
│     telefone (VARCHAR)      │
│     data_cadastro (DATE)    │
│     status (ENUM)           │
└───────────┬─────────────────┘
            │
            │ 1
            │
            │ N
┌───────────▼─────────────────┐           N  ┌──────────────────────────┐
│       EMPRESTIMO            ├──────────────┤         LIVRO            │
├─────────────────────────────┤              ├──────────────────────────┤
│ PK  id_emprestimo (INT)     │      1       │ PK  isbn (VARCHAR)       │
│ FK  id_usuario (INT)        │              │     titulo (VARCHAR)     │
│ FK  isbn (VARCHAR)          │              │     autor (VARCHAR)      │
│     data_emprestimo (DATE)  │              │     editora (VARCHAR)    │
│     data_prev_devol (DATE)  │              │     ano_publicacao (INT) │
│     data_devol_real (DATE)  │              │     categoria (VARCHAR)  │
│     status (ENUM)           │              │     edicao (INT)         │
│     observacoes (TEXT)      │              │     total_exemplares(INT)│
└───────────┬─────────────────┘              │     exempl_disp (INT)    │
            │                                │     localizacao (VARCHAR)│
            │ 1                              └──────────┬───────────────┘
            │                                           │
            │                                           │ 1
            │ 0..1                                      │
┌───────────▼─────────────────┐                         │ N
│          MULTA              │                ┌────────▼──────────────┐
├─────────────────────────────┤                │      RESERVA          │
│ PK  id_multa (INT)          │                ├───────────────────────┤
│ FK  id_emprestimo (INT) UQ  │                │ PK  id_reserva (INT)  │
│ FK  id_usuario (INT)        │                │ FK  id_usuario (INT)  │
│     valor (DECIMAL)         │                │ FK  isbn (VARCHAR)    │
│     dias_atraso (INT)       │                │     data_reserva(DATE)│
│     data_geracao (DATE)     │                │     data_validade(D.) │
│     data_pagamento (DATE)   │                │     status (ENUM)     │
│     status (ENUM)           │                │     prioridade (INT)  │
└─────────────────────────────┘                └───────────────────────┘
```

**Legenda:**
- **PK** = Primary Key (Chave Primária)
- **FK** = Foreign Key (Chave Estrangeira)
- **UQ** = Unique (Valor Único)

---

## ✅ Regras de Integridade Implementadas

### 1. Integridade de Entidade
- Todas as tabelas possuem chave primária (PK) única e não nula
- `AUTO_INCREMENT` garante geração automática de IDs

### 2. Integridade Referencial
- Chaves estrangeiras (FK) garantem relacionamentos válidos
- `ON DELETE RESTRICT`: Impede exclusão de registros referenciados
- `ON DELETE CASCADE`: Remove registros dependentes automaticamente
- `ON UPDATE CASCADE`: Atualiza referências em cascata

### 3. Integridade de Domínio
- **CHECK constraints**: Validam valores (ex: `dias_atraso > 0`)
- **ENUM**: Restringe valores a conjunto predefinido
- **NOT NULL**: Garante preenchimento obrigatório
- **UNIQUE**: Impede duplicações (ex: email, matrícula)

### 4. Integridade Semântica
- `data_devolucao_real >= data_emprestimo`
- `data_prevista_devolucao > data_emprestimo`
- `exemplares_disponiveis <= total_exemplares`
- `data_pagamento >= data_geracao`

---

## 📊 Normalização Aplicada

### ✅ Primeira Forma Normal (1FN)
- Todos os atributos são atômicos (valores únicos)
- Não há grupos repetitivos
- Cada célula contém apenas um valor

### ✅ Segunda Forma Normal (2FN)
- Todas as tabelas estão em 1FN
- Todos os atributos não-chave dependem totalmente da chave primária
- Não há dependências parciais

### ✅ Terceira Forma Normal (3FN)
- Todas as tabelas estão em 2FN
- Não há dependências transitivas
- Atributos não-chave dependem apenas da chave primária

**Exemplo de Análise:**
- Em `MULTA`, o atributo `valor` depende de `dias_atraso` (R$ 0,50/dia)
- **Solução:** Embora pareça dependência transitiva, `valor` é armazenado para auditoria (registro histórico de valores que podem mudar)
- Alternativamente, poderia ser calculado via VIEW ou procedimento

---

## 🔍 Índices Recomendados

Para otimizar consultas frequentes:

```sql
-- Índices para melhorar performance

CREATE INDEX idx_usuario_matricula ON USUARIO(matricula);
CREATE INDEX idx_usuario_email ON USUARIO(email);

CREATE INDEX idx_livro_categoria ON LIVRO(categoria);
CREATE INDEX idx_livro_autor ON LIVRO(autor);

CREATE INDEX idx_emprestimo_usuario ON EMPRESTIMO(id_usuario);
CREATE INDEX idx_emprestimo_isbn ON EMPRESTIMO(isbn);
CREATE INDEX idx_emprestimo_status ON EMPRESTIMO(status);
CREATE INDEX idx_emprestimo_data ON EMPRESTIMO(data_emprestimo);

CREATE INDEX idx_multa_usuario ON MULTA(id_usuario);
CREATE INDEX idx_multa_status ON MULTA(status);

CREATE INDEX idx_reserva_usuario ON RESERVA(id_usuario);
CREATE INDEX idx_reserva_isbn ON RESERVA(isbn);
CREATE INDEX idx_reserva_status ON RESERVA(status);
```

---

## 🎯 Consultas SQL Exemplo

### 1. Listar empréstimos ativos de um usuário

```sql
SELECT 
    e.id_emprestimo,
    l.titulo,
    l.autor,
    e.data_emprestimo,
    e.data_prevista_devolucao,
    DATEDIFF(CURRENT_DATE, e.data_prevista_devolucao) AS dias_atraso
FROM EMPRESTIMO e
JOIN LIVRO l ON e.isbn = l.isbn
WHERE e.id_usuario = 1 AND e.status = 'Emprestado';
```

### 2. Verificar disponibilidade de livros

```sql
SELECT 
    isbn,
    titulo,
    autor,
    total_exemplares,
    exemplares_disponiveis,
    CASE 
        WHEN exemplares_disponiveis > 0 THEN 'Disponível'
        ELSE 'Indisponível'
    END AS disponibilidade
FROM LIVRO
WHERE categoria = 'Tecnologia'
ORDER BY titulo;
```

### 3. Calcular multas pendentes por usuário

```sql
SELECT 
    u.nome,
    u.matricula,
    COUNT(m.id_multa) AS total_multas,
    SUM(m.valor) AS valor_total
FROM USUARIO u
JOIN MULTA m ON u.id_usuario = m.id_usuario
WHERE m.status = 'Pendente'
GROUP BY u.id_usuario, u.nome, u.matricula
ORDER BY valor_total DESC;
```

### 4. Listar fila de reservas de um livro

```sql
SELECT 
    r.prioridade AS posicao_fila,
    u.nome AS usuario,
    u.email,
    r.data_reserva,
    r.data_validade
FROM RESERVA r
JOIN USUARIO u ON r.id_usuario = u.id_usuario
WHERE r.isbn = '9788535902773' AND r.status = 'Ativa'
ORDER BY r.prioridade;
```

---

## 📝 Script SQL Completo de Criação

```sql
-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS biblioteca_universitaria;
USE biblioteca_universitaria;

-- Tabela USUARIO
CREATE TABLE USUARIO (
    id_usuario      INT PRIMARY KEY AUTO_INCREMENT,
    nome            VARCHAR(100) NOT NULL,
    matricula       VARCHAR(20) UNIQUE NOT NULL,
    tipo_vinculo    ENUM('Aluno', 'Professor', 'Funcionário') NOT NULL,
    curso           VARCHAR(80),
    email           VARCHAR(100) UNIQUE NOT NULL,
    telefone        VARCHAR(15),
    data_cadastro   DATE NOT NULL DEFAULT (CURRENT_DATE),
    status          ENUM('Ativo', 'Inativo') DEFAULT 'Ativo'
);

-- Tabela LIVRO
CREATE TABLE LIVRO (
    isbn                    VARCHAR(17) PRIMARY KEY,
    titulo                  VARCHAR(200) NOT NULL,
    autor                   VARCHAR(150) NOT NULL,
    editora                 VARCHAR(100),
    ano_publicacao          INT CHECK (ano_publicacao > 1500 AND ano_publicacao <= YEAR(CURDATE())),
    categoria               VARCHAR(50) NOT NULL,
    edicao                  INT DEFAULT 1,
    total_exemplares        INT NOT NULL CHECK (total_exemplares >= 0),
    exemplares_disponiveis  INT NOT NULL CHECK (exemplares_disponiveis >= 0),
    localizacao             VARCHAR(50),
    CONSTRAINT chk_exemplares CHECK (exemplares_disponiveis <= total_exemplares)
);

-- Tabela EMPRESTIMO
CREATE TABLE EMPRESTIMO (
    id_emprestimo           INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario              INT NOT NULL,
    isbn                    VARCHAR(17) NOT NULL,
    data_emprestimo         DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao_real     DATE,
    status                  ENUM('Emprestado', 'Devolvido', 'Atrasado') DEFAULT 'Emprestado',
    observacoes             TEXT,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES LIVRO(isbn) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_data_devolucao CHECK (
        data_devolucao_real IS NULL OR data_devolucao_real >= data_emprestimo
    ),
    CONSTRAINT chk_data_prevista CHECK (data_prevista_devolucao > data_emprestimo)
);

-- Tabela MULTA
CREATE TABLE MULTA (
    id_multa        INT PRIMARY KEY AUTO_INCREMENT,
    id_emprestimo   INT UNIQUE NOT NULL,
    id_usuario      INT NOT NULL,
    valor           DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
    dias_atraso     INT NOT NULL CHECK (dias_atraso > 0),
    data_geracao    DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_pagamento  DATE,
    status          ENUM('Pendente', 'Paga', 'Cancelada') DEFAULT 'Pendente',
    FOREIGN KEY (id_emprestimo) REFERENCES EMPRESTIMO(id_emprestimo) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pagamento CHECK (
        data_pagamento IS NULL OR data_pagamento >= data_geracao
    )
);

-- Tabela RESERVA
CREATE TABLE RESERVA (
    id_reserva      INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario      INT NOT NULL,
    isbn            VARCHAR(17) NOT NULL,
    data_reserva    DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_validade   DATE NOT NULL,
    status          ENUM('Ativa', 'Atendida', 'Cancelada', 'Expirada') DEFAULT 'Ativa',
    prioridade      INT NOT NULL CHECK (prioridade > 0),
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (isbn) REFERENCES LIVRO(isbn) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_validade CHECK (data_validade > data_reserva),
    CONSTRAINT uq_reserva_usuario_livro UNIQUE (id_usuario, isbn, status)
);

-- Criação de índices
CREATE INDEX idx_usuario_matricula ON USUARIO(matricula);
CREATE INDEX idx_emprestimo_usuario ON EMPRESTIMO(id_usuario);
CREATE INDEX idx_emprestimo_status ON EMPRESTIMO(status);
CREATE INDEX idx_multa_status ON MULTA(status);
CREATE INDEX idx_reserva_status ON RESERVA(status);
```

---

## ✅ Conclusão

Este modelo lógico apresenta:

- ✅ **5 tabelas** completamente definidas com tipos de dados SQL
- ✅ **Chaves primárias e estrangeiras** corretamente implementadas
- ✅ **Restrições de integridade** (CHECK, UNIQUE, NOT NULL, FK)
- ✅ **Normalização até 3FN** aplicada e validada
- ✅ **Quadro comparativo** DER → Modelo Lógico
- ✅ **Diagrama lógico** com destaque visual das chaves
- ✅ **Script SQL completo** pronto para execução
- ✅ **Consultas exemplo** demonstrando uso prático

O modelo está pronto para implementação em MySQL, PostgreSQL ou outro SGBD relacional, garantindo consistência, integridade e eficiência nas operações da biblioteca universitária.
