# Diagrama Entidade-Relacionamento (DER)
## Sistema de Biblioteca Universitária

---

##  Entidades e Atributos

### 1. USUÁRIO
Representa os usuários cadastrados no sistema (alunos, professores e funcionários).

**Atributos:**
- **id_usuario** (PK) - Chave primária, identificador único
- nome - Nome completo do usuário
- matricula - Matrícula institucional (única)
- tipo_vinculo - Tipo: Aluno, Professor ou Funcionário
- curso - Curso ao qual está vinculado
- email - Email institucional
- telefone - Telefone de contato
- data_cadastro - Data de cadastro no sistema
- status - Ativo/Inativo

---

### 2. LIVRO
Representa os materiais do acervo (livros, periódicos, etc.).

**Atributos:**
- **isbn** (PK) - Código ISBN, chave primária
- titulo - Título do livro
- autor - Autor(es) do livro
- editora - Editora responsável
- ano_publicacao - Ano de publicação
- categoria - Categoria (Tecnologia, Humanas, etc.)
- edicao - Número da edição
- total_exemplares - Quantidade total de exemplares
- exemplares_disponiveis - Quantidade disponível para empréstimo
- localizacao - Localização física na biblioteca

---

### 3. EMPRÉSTIMO
Registra cada empréstimo realizado.

**Atributos:**
- **id_emprestimo** (PK) - Identificador único do empréstimo
- id_usuario (FK) - Referência ao usuário
- isbn (FK) - Referência ao livro
- data_emprestimo - Data de retirada
- data_prevista_devolucao - Data prevista para devolução
- data_devolucao_real - Data real da devolução (NULL se não devolvido)
- status - Emprestado/Devolvido/Atrasado
- observacoes - Observações sobre o empréstimo

---

### 4. MULTA
Registra as multas geradas por atrasos.

**Atributos:**
- **id_multa** (PK) - Identificador único da multa
- id_emprestimo (FK) - Referência ao empréstimo
- id_usuario (FK) - Referência ao usuário
- valor - Valor da multa em reais
- dias_atraso - Quantidade de dias em atraso
- data_geracao - Data de geração da multa
- data_pagamento - Data do pagamento (NULL se não pago)
- status - Pendente/Paga/Cancelada

---

### 5. RESERVA
Registra as reservas de livros que estão emprestados.

**Atributos:**
- **id_reserva** (PK) - Identificador único da reserva
- id_usuario (FK) - Referência ao usuário
- isbn (FK) - Referência ao livro
- data_reserva - Data da solicitação da reserva
- data_validade - Data até quando a reserva é válida
- status - Ativa/Atendida/Cancelada/Expirada
- prioridade - Número na fila de espera

---

##  Relacionamentos e Cardinalidades

### 1. USUÁRIO **realiza** EMPRÉSTIMO
- **Cardinalidade:** 1:N (Um usuário para muitos empréstimos)
- Um usuário pode realizar vários empréstimos ao longo do tempo
- Cada empréstimo pertence a apenas um usuário

### 2. LIVRO **está em** EMPRÉSTIMO
- **Cardinalidade:** 1:N (Um livro para muitos empréstimos)
- Um livro pode ser emprestado várias vezes (histórico)
- Cada empréstimo refere-se a apenas um livro

### 3. EMPRÉSTIMO **gera** MULTA
- **Cardinalidade:** 1:1 ou 1:0 (Um empréstimo pode gerar no máximo uma multa)
- Nem todo empréstimo gera multa (apenas os atrasados)
- Cada multa está associada a apenas um empréstimo

### 4. USUÁRIO **possui** MULTA
- **Cardinalidade:** 1:N (Um usuário para várias multas)
- Um usuário pode ter várias multas ao longo do tempo
- Cada multa pertence a apenas um usuário

### 5. USUÁRIO **faz** RESERVA
- **Cardinalidade:** 1:N (Um usuário para várias reservas)
- Um usuário pode fazer várias reservas
- Cada reserva pertence a apenas um usuário

### 6. LIVRO **tem** RESERVA
- **Cardinalidade:** 1:N (Um livro para várias reservas)
- Um livro pode ter várias reservas em fila de espera
- Cada reserva é de apenas um livro

---

##  Diagrama Entidade-Relacionamento (Representação Textual)

```
┌─────────────────┐
│    USUÁRIO      │
├─────────────────┤
│ PK id_usuario   │
│    nome         │
│    matricula    │
│    tipo_vinculo │
│    curso        │
│    email        │
│    telefone     │
│    data_cadastro│
│    status       │
└────────┬────────┘
         │ 1
         │
         │ realiza
         │
         │ N
┌────────▼────────┐         N  ┌─────────────────┐
│   EMPRÉSTIMO    ├────────────┤     LIVRO       │
├─────────────────┤ está em 1  ├─────────────────┤
│PK id_emprestimo │            │ PK isbn         │
│FK id_usuario    │            │    titulo       │
│FK isbn          │            │    autor        │
│data_emprestimo  │            │    editora      │
│data_prev_devol  │            │    ano_public.  │
│data_devol_real  │            │    categoria    │
│status           │            │    edicao       │
│observacoes      │            │    total_exempl │
└────────┬────────┘            │    exempl_disp  │
         │ 1                   │    localizacao  │
         │                     └────────┬────────┘
         │ gera                         │ 1
         │                              │
         │ 0..1                         │ tem
         │                              │
┌────────▼────────┐                     │ N
│     MULTA       │            ┌────────▼────────┐
├─────────────────┤            │    RESERVA      │
│ PK id_multa     │            ├─────────────────┤
│ FK id_emprestimo│            │ PK id_reserva   │
│ FK id_usuario   │            │ FK id_usuario   │
│    valor        │            │ FK isbn         │
│    dias_atraso  │            │    data_reserva │
│    data_geracao │            │    data_validade│
│    data_pagamento│           │    status       │
│    status       │            │    prioridade   │
└─────────────────┘            └─────────────────┘
         ▲                              ▲
         │ N                            │ N
         │                              │
         │ possui                       │ faz
         │                              │
         │ 1                            │ 1
         └──────────────────────────────┘
                  (USUÁRIO)
```

---

##  Normalização

### Primeira Forma Normal (1FN)
 **Aplicada:** Todos os atributos são atômicos (sem valores múltiplos ou compostos)
- Não há listas ou arrays nos atributos
- Cada campo contém apenas um valor
- Exemplo: `autor` armazena "Cormen, T. et al." como texto único

### Segunda Forma Normal (2FN)
 **Aplicada:** Todos os atributos não-chave dependem totalmente da chave primária
- `EMPRÉSTIMO`: Todos os atributos dependem de `id_emprestimo`
- `MULTA`: Todos os atributos dependem de `id_multa`
- Não há dependências parciais

### Terceira Forma Normal (3FN)
 **Aplicada:** Não há dependências transitivas
- `exemplares_disponiveis` em `LIVRO` poderia ser calculado, mas é mantido por performance
- Não há atributos que dependem de outros atributos não-chave
- Cada entidade representa um conceito único e coeso

---

##  Regras de Negócio Implementadas no DER

1. **Limite de Empréstimos:**
   - Alunos: máximo 3 livros simultâneos
   - Professores: máximo 5 livros simultâneos
   - Prazo: 14 dias (alunos) / 30 dias (professores)

2. **Cálculo de Multas:**
   - R$ 0,50 por dia de atraso
   - Bloqueio de novos empréstimos com multas pendentes

3. **Sistema de Reservas:**
   - Reserva válida por 48h após disponibilidade
   - Fila de espera por ordem de chegada
   - Máximo 2 reservas ativas por usuário

4. **Controle de Disponibilidade:**
   - Atualização automática de `exemplares_disponiveis`
   - Bloqueio de empréstimo quando estoque zerado
   - Disparo de notificações para reservas

---

##  Integridade Referencial

### Chaves Estrangeiras (Foreign Keys):

1. `EMPRÉSTIMO.id_usuario` → `USUÁRIO.id_usuario`
   - **ON DELETE:** RESTRICT (não permite excluir usuário com empréstimos)
   - **ON UPDATE:** CASCADE (atualiza referências)

2. `EMPRÉSTIMO.isbn` → `LIVRO.isbn`
   - **ON DELETE:** RESTRICT (não permite excluir livro com empréstimos)
   - **ON UPDATE:** CASCADE

3. `MULTA.id_emprestimo` → `EMPRÉSTIMO.id_emprestimo`
   - **ON DELETE:** CASCADE (exclui multa se empréstimo for excluído)
   - **ON UPDATE:** CASCADE

4. `MULTA.id_usuario` → `USUÁRIO.id_usuario`
   - **ON DELETE:** RESTRICT
   - **ON UPDATE:** CASCADE

5. `RESERVA.id_usuario` → `USUÁRIO.id_usuario`
   - **ON DELETE:** CASCADE
   - **ON UPDATE:** CASCADE

6. `RESERVA.isbn` → `LIVRO.isbn`
   - **ON DELETE:** CASCADE
   - **ON UPDATE:** CASCADE

---

##  Diagrama Final Normalizado (até 3FN)

O diagrama apresentado está em conformidade com a **Terceira Forma Normal (3FN)**, garantindo:

-  Eliminação de redundâncias
-  Dependência funcional adequada
-  Integridade referencial
-  Estrutura otimizada para consultas
-  Facilidade de manutenção e evolução

---

##  Consultas Comuns Suportadas pelo Modelo

1. **Listar todos os empréstimos ativos de um usuário**
2. **Verificar disponibilidade de um livro**
3. **Calcular multas pendentes de um usuário**
4. **Consultar fila de reservas de um livro**
5. **Gerar relatório de empréstimos por período**
6. **Identificar usuários com empréstimos atrasados**
7. **Listar livros mais emprestados por categoria**
8. **Verificar histórico completo de um livro**

---

##  Conclusão

O DER apresentado representa de forma completa e normalizada o minimundo do **Sistema de Biblioteca Universitária**, contemplando:

- **5 entidades principais** com atributos bem definidos
- **6 relacionamentos** com cardinalidades corretas
- **Normalização até 3FN** aplicada e validada
- **Regras de negócio** implementadas na estrutura
- **Integridade referencial** garantida por chaves estrangeiras

Este modelo está pronto para ser implementado em um SGBD relacional (MySQL, PostgreSQL, SQL Server, etc.) e suporta todas as operações necessárias para o funcionamento completo do sistema de biblioteca.
