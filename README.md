#  Sistema de Biblioteca Universitária - SQL Scripts

Projeto prático de banco de dados relacional para gerenciamento de biblioteca universitária, desenvolvido como parte da disciplina de Modelagem de Banco de Dados.

##  Descrição do Projeto

Este repositório contém a implementação completa de um sistema de biblioteca com scripts SQL para:
- Criação de estrutura de banco de dados (DDL)
- Manipulação de dados (DML)
- Consultas avançadas com JOINs, subconsultas e agregações
- Operações de atualização e exclusão com integridade referencial

##  Estrutura do Repositório

```
├── biblioteca.db.sql       # Script completo de criação do banco
├── 01_insert.sql          # Scripts de INSERT (população de dados)
├── 02_select.sql          # Consultas SELECT (6 exemplos)
├── 03_update.sql          # Comandos UPDATE (6 exemplos)
├── 04_delete.sql          # Comandos DELETE (6 exemplos)
└── README.md              # Este arquivo
```

##  Estrutura do Banco de Dados

### Tabelas Principais

1. **USUARIO** - Cadastro de usuários (alunos, professores, funcionários)
2. **LIVRO** - Catálogo de livros e materiais
3. **EMPRESTIMO** - Registro de empréstimos
4. **MULTA** - Controle de multas por atraso
5. **RESERVA** - Gerenciamento de reservas

### Diagrama Entidade-Relacionamento

```
USUARIO (1) ──── (N) EMPRESTIMO (N) ──── (1) LIVRO
   │                    │
   │                    │
   │                   (1)
   │                    │
  (1)                MULTA
   │
   │
  (N)
   │
RESERVA (N) ──── (1) LIVRO
```

##  Como Executar

### Pré-requisitos

- **SQLite** (recomendado para testes locais)
- **MySQL** ou **PostgreSQL** (para ambientes de produção)
- **VS Code** com extensão MySQL/SQLite (opcional)

### Opção 1: SQLite Online (Mais Fácil)

1. Acesse: https://sqliteonline.com/
2. Cole o conteúdo de `biblioteca.db.sql`
3. Clique em **"Run"** para criar o banco
4. Execute os demais scripts na ordem

### Opção 2: VS Code com Extensão SQLite

1. Instale a extensão **"SQLite"** no VS Code
2. Abra a pasta do projeto
3. Execute `biblioteca.db.sql` para criar o banco
4. Execute os scripts na seguinte ordem:
   - `01_insert.sql` (popular dados)
   - `02_select.sql` (consultas)
   - `03_update.sql` (atualizações)
   - `04_delete.sql` (exclusões)

### Opção 3: Linha de Comando (SQLite)

```bash
# Criar o banco de dados
sqlite3 biblioteca.db < biblioteca.db.sql

# Executar scripts adicionais
sqlite3 biblioteca.db < 01_insert.sql
sqlite3 biblioteca.db < 02_select.sql
sqlite3 biblioteca.db < 03_update.sql
sqlite3 biblioteca.db < 04_delete.sql

# Consultar o banco
sqlite3 biblioteca.db
```

### Opção 4: MySQL

```bash
# Criar banco de dados
mysql -u root -p -e "CREATE DATABASE biblioteca_universitaria;"

# Importar estrutura (ajuste o script para sintaxe MySQL)
mysql -u root -p biblioteca_universitaria < biblioteca.db.sql

# Executar scripts
mysql -u root -p biblioteca_universitaria < 01_insert.sql
```

##  Exemplos de Scripts

### INSERT - Popular Dados

```sql
-- Adicionar novo usuário
INSERT INTO USUARIO (nome, matricula, tipo_vinculo, curso, email, telefone, data_cadastro) 
VALUES ('Lucas Mendes', '20234004', 'Aluno', 'Análise de Sistemas', 'lucas.mendes@univ.br', '11987654327', '2025-03-01');
```

### SELECT - Consultas

```sql
-- Livros disponíveis de Tecnologia
SELECT titulo, autor, exemplares_disponiveis 
FROM LIVRO 
WHERE categoria = 'Tecnologia' AND exemplares_disponiveis > 0
ORDER BY titulo;
```

### UPDATE - Atualizações

```sql
-- Registrar devolução
UPDATE EMPRESTIMO 
SET data_devolucao_real = date('now'), status = 'Devolvido'
WHERE id_emprestimo = 3;
```

### DELETE - Exclusões

```sql
-- Remover reservas canceladas antigas
DELETE FROM RESERVA
WHERE status = 'Cancelada' AND julianday('now') - julianday(data_reserva) > 30;
```

##  Funcionalidades Implementadas

###  Consultas SELECT

- [x] Filtros com WHERE
- [x] Ordenação com ORDER BY
- [x] Limitação de resultados com LIMIT
- [x] JOINs (INNER, LEFT)
- [x] Agregações (COUNT, SUM, GROUP BY)
- [x] Subconsultas

###  Comandos UPDATE

- [x] Atualização de status de empréstimos
- [x] Registro de devoluções
- [x] Atualização de dados de usuários
- [x] Pagamento de multas
- [x] Atualização em lote (múltiplos registros)

###  Comandos DELETE

- [x] Exclusão com condições de data
- [x] Remoção de registros inativos
- [x] Limpeza de dados históricos
- [x] Exclusões com subconsultas
- [x] Segurança: sempre com WHERE

##  Regras de Integridade

- **Chaves Primárias**: Garantem unicidade de registros
- **Chaves Estrangeiras**: Mantêm consistência entre tabelas
- **CHECK Constraints**: Validam domínio de valores
- **UNIQUE**: Impedem duplicações (email, matrícula)
- **NOT NULL**: Garantem campos obrigatórios

##  Dados de Teste

O banco vem populado com:
- **6 usuários** (alunos, professores, funcionário)
- **6 livros** (categorias: Tecnologia, Matemática, Física)
- **6 empréstimos** (ativos, devolvidos, atrasados)
- **2 multas** pendentes
- **3 reservas** ativas

##  Conceitos Aplicados

- Modelagem relacional normalizada (3FN)
- DML (Data Manipulation Language)
- DDL (Data Definition Language)
- Integridade referencial
- Consultas com múltiplas tabelas
- Subconsultas correlacionadas
- Funções de agregação
- Operações de data/hora

##  Tecnologias Utilizadas

- **SQLite** - Banco de dados relacional leve
- **SQL** - Linguagem de consulta estruturada
- **VS Code** - Editor de código
- **Git/GitHub** - Controle de versão

##  Referências

- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [SQL Tutorial - W3Schools](https://www.w3schools.com/sql/)
- Ramakrishnan & Gehrke - Banco de Dados
- Elmasri & Navathe - Sistemas de Banco de Dados

##  Autor

Desenvolvido como projeto acadêmico da disciplina de **Modelagem de Banco de Dados**.

##  Licença

Este projeto é de uso educacional e está disponível para fins de aprendizado.

---

##  Como Testar os Scripts

### Teste Rápido (Online)

1. Acesse https://sqliteonline.com/
2. Cole o conteúdo completo de `biblioteca.db.sql`
3. Clique em **Run**
4. Explore as tabelas criadas no painel esquerdo
5. Execute consultas personalizadas

### Teste Completo (Local)

```bash
# 1. Criar banco
sqlite3 biblioteca.db < biblioteca.db.sql

# 2. Verificar tabelas
sqlite3 biblioteca.db "SELECT name FROM sqlite_master WHERE type='table';"

# 3. Ver dados
sqlite3 biblioteca.db "SELECT * FROM USUARIO;"

# 4. Executar consultas
sqlite3 biblioteca.db < 02_select.sql
```

##  Suporte

Para dúvidas ou sugestões, abra uma issue no repositório.

---

**⭐ Se este projeto foi útil, deixe uma estrela no repositório!**
