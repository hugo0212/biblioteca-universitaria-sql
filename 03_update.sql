-- ============================================
-- 3. COMANDOS UPDATE - ATUALIZAÇÃO DE DADOS
-- ============================================

-- Update 1: Registrar devolução de um livro
UPDATE EMPRESTIMO 
SET 
    data_devolucao_real = date('now'),
    status = 'Devolvido',
    observacoes = 'Devolvido em ' || date('now')
WHERE id_emprestimo = 3 
  AND status = 'Emprestado';

-- Atualizar disponibilidade do livro após devolução
UPDATE LIVRO
SET exemplares_disponiveis = exemplares_disponiveis + 1
WHERE isbn = (
    SELECT isbn 
    FROM EMPRESTIMO 
    WHERE id_emprestimo = 3
);

-- Update 2: Marcar empréstimos como atrasados
UPDATE EMPRESTIMO
SET status = 'Atrasado'
WHERE data_prevista_devolucao < date('now')
  AND data_devolucao_real IS NULL
  AND status = 'Emprestado';

-- Update 3: Atualizar dados de contato do usuário
UPDATE USUARIO
SET 
    email = 'joao.silva.novo@univ.br',
    telefone = '11999888777'
WHERE matricula = '20231001';

-- Update 4: Registrar pagamento de multa
UPDATE MULTA
SET 
    data_pagamento = date('now'),
    status = 'Paga'
WHERE id_multa = 1
  AND status = 'Pendente';

-- Update 5: Cancelar reservas expiradas
UPDATE RESERVA
SET status = 'Expirada'
WHERE data_validade < date('now')
  AND status = 'Ativa';

-- Update 6: Estender prazo de devolução para professor
UPDATE EMPRESTIMO
SET data_prevista_devolucao = date(data_prevista_devolucao, '+15 days')
WHERE id_usuario IN (
    SELECT id_usuario 
    FROM USUARIO 
    WHERE tipo_vinculo = 'Professor'
)
AND status = 'Emprestado';
