# Opinião sobre a construção da plataforma a partir do questionário de Avaliação Psicossocial Ocupacional

## 1. Impressões gerais do questionário
- Estrutura em escala Likert de 1 a 5 com opção de pulo, cobrindo seis domínios principais: Condições de Trabalho, Gestão e Liderança, Organização do Trabalho, Comunicação, Saúde Mental e Bem-estar, Considerações Finais.
- O instrumento já traz interpretação automatizável (média < 2 = baixo risco, 2 a 3 = moderado, > 3 = alto) e perguntas críticas (12, 18, 22) marcadas para atenção.
- Blocos de perguntas mapeiam facilmente para temas de dashboards e playbooks de intervenção: clima (Q1–8), liderança (Q9–13), organização e mudanças (Q14–16), saúde mental (Q17–21), aprendizado e reconhecimento (Q23–26).

## 2. Requisitos funcionais sugeridos
- **Gestão de questionários**: cadastro de ciclos (turma, período), versionamento do formulário, bloqueio de edição após envio, e possibilidade de pular perguntas.
- **Anonimato e agregação**: separar identificadores de respostas, aplicar limites mínimos por grupo (p.ex., >= 7 respostas para exibir médias) e armazenar consentimento.
- **Cálculo automático**: motores para calcular médias por domínio, sinalizar perguntas críticas (12, 18, 22) e classificar risco (baixo/moderado/alto) com base no limiar fornecido.
- **Dashboards**: visão para RH/SST com heatmap por pergunta, tendência por ciclo e cortes seguros (equipe/unidade) respeitando thresholds de anonimato.
- **Trilhas de ação**: quando um domínio fica em alto risco, sugerir protocolos do manual de boas práticas (acolhimento, red flag de assédio, ergonomia, saúde mental) e registrar follow-ups.
- **Fluxos de comunicação**: campo opcional para feedback qualitativo (se permitido) e registros de tratativas com controle de acesso e trilha de auditoria.

## 3. Dados e privacidade
- Armazenar respostas em tabela separada de usuários, usando pseudonimização (ID temporário por ciclo) e chaves de correspondência guardadas em cofre/segredo.
- Criptografia em repouso e em trânsito, logs de acesso e retenção de dados alinhada à LGPD; manter trilhas de consentimento e de uso dos resultados.
- Para resultados agregados, descartar metadados granulares que permitam reidentificação (times muito pequenos, combinações de filtros raras).

## 4. Experiência do usuário
- Questionário curto e responsivo (mobile-friendly), com barra de progresso e mensagens de confidencialidade antes do início.
- Permitir retomar sessão e exibir estimativa de tempo; oferecer botão "Pular" coerente com a instrução.
- Após a coleta, comunicar ações tomadas (feed de melhorias) para reforçar confiança e adesão.

## 5. Conclusão sobre viabilidade
- O questionário é direto e está pronto para digitalização; a plataforma pode operacionalizar cálculos e alertas com lógica simples de médias.
- O principal cuidado é garantir anonimato, thresholds mínimos e governança de acesso; tecnicamente, é viável com stack web comum (API + SPA) e banco relacional.
- Conectar resultados aos protocolos do manual de SST adiciona valor prático e favorece ações rápidas de prevenção.