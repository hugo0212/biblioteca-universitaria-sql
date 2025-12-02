-- ============================================
-- 4. COMANDOS DELETE - REMOÇÃO DE DADOS
-- ============================================

-- Delete 1: Remover reservas canceladas há mais de 30 dias
DELETE FROM RESERVA
WHERE status = 'Cancelada'
  AND julianday('now') - julianday(data_reserva) > 30;

-- Delete 2: Remover empréstimos devolvidos há mais de 1 ano (histórico antigo)
DELETE FROM EMPRESTIMO
WHERE status = 'Devolvido'
  AND data_devolucao_real IS NOT NULL
  AND julianday('now') - julianday(data_devolucao_real) > 365;

-- Delete 3: Remover multas pagas há mais de 6 meses (arquivamento)
DELETE FROM MULTA
WHERE status = 'Paga'
  AND data_pagamento IS NOT NULL
  AND julianday('now') - julianday(data_pagamento) > 180;

-- Delete 4: Remover usuários inativos sem empréstimos ou multas pendentes
DELETE FROM USUARIO
WHERE status = 'Inativo'
  AND id_usuario NOT IN (
      SELECT DISTINCT id_usuario 
      FROM EMPRESTIMO 
      WHERE status IN ('Emprestado', 'Atrasado')
  )
  AND id_usuario NOT IN (
      SELECT DISTINCT id_usuario 
      FROM MULTA 
      WHERE status = 'Pendente'
  );

-- Delete 5: Remover reservas de livros que foram retirados do acervo
DELETE FROM RESERVA
WHERE isbn NOT IN (SELECT isbn FROM LIVRO);

-- Delete 6: Cancelar reservas duplicadas do mesmo usuário para o mesmo livro
DELETE FROM RESERVA
WHERE id_reserva NOT IN (
    SELECT MIN(id_reserva)
    FROM RESERVA
    GROUP BY id_usuario, isbn, status
    HAVING status = 'Ativa'
);

-- ============================================
-- IMPORTANTE: Segurança nos DELETEs
-- ============================================
-- Sempre use WHERE com condições específicas!
-- Nunca faça DELETE sem WHERE em produção!
-- Faça backup antes de executar DELETEs em massa!
