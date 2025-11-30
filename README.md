# PI-SST

Construção da plataforma referente ao Projeto Integrador da turma de SST - Senac Alagoas

## Visão geral
Esta prova de conceito mostra como implementar rapidamente um módulo web para coleta de clima/SST usando Python (Flask), HTML/CSS e banco de dados SQL (SQLite por padrão). Agora há autenticação e perfis de acesso:
- **Início**: resumo da proposta
- **Login/Cadastro**: cadastros públicos criam sempre um perfil de Colaborador; usuários técnicos (ADM) são semeados e podem criar novos usuários (colaboradores ou ADM)
  - O cadastro solicita também "Como prefere ser chamado?" para usar um nome curto em toda a navegação
  - Cadastros públicos criam sempre um perfil de **Colaborador**; usuários técnicos (ADM) são semeados e podem criar novos usuários (colaboradores ou ADM)
- **Questionário**: formulário simples para captar percepções (apenas para usuários logados)
- **Ouvidoria**: qualquer usuário logado (colaborador ou ADM) envia mensagens categorizadas (reclamação, ocorrência, sugestão ou elogio)
- **Dashboard**: contagens agregadas das respostas enviadas (apenas perfil ADM)
- **Responder Ouvidoria (ADM)**: administração consulta mensagens e registra respostas; o dashboard mostra totais por tipo e mensagens respondidas
- **Guia**: referência de tratamento para mensagens da ouvidoria (apenas perfil ADM)

## Como rodar localmente
1. Crie um ambiente virtual (opcional, mas recomendado):
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # Windows: .venv\\Scripts\\activate
   ```
2. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
3. Execute o servidor Flask (por padrão na porta 5000):
   ```bash
   flask --app app run
   ```
   Ou, se preferir recarregamento automático em desenvolvimento:
   ```bash
   flask --app app --debug run
   ```
4. Acesse `http://localhost:5000` no navegador.
   - Use o usuário ADM padrão (ou defina via variáveis de ambiente):
   - `ADMIN_EMAIL=admin@guidetec.local`
   - `ADMIN_PASSWORD=admin123`
   - `ADMIN_NAME=Administrador GuiaTEC`
   - `ADMIN_PREFERRED_NAME=ADM GuiaTEC`
   - Cadastros públicos (aba Cadastro) sempre geram um perfil de **Colaborador**.
   - Usuários técnicos (ADM) podem acessar o botão **Cadastrar usuários** para criar novos perfis, inclusive outros ADMs.
   - Colaboradores podem responder o questionário e enviar mensagens na **Ouvidoria**.
   - Usuários técnicos (ADM) podem acessar questionário, dashboard, guia, **Responder Ouvidoria** e visualizar as métricas da ouvidoria.

### Solução de problemas comuns
- Caso a interface apareça sem imagens ou com espaços vazios, verifique se os JPEGs estão na pasta `static/` com os nomes:
  - `guidetec-logo.jpeg`, `imagem1.jpeg`, `imagem2.jpeg`, `imagem3.jpeg`, `imagem4.jpeg`, `imagem5.jpeg`
- A aplicação exibe um aviso no console ao iniciar se algum desses arquivos estiver faltando.
- Execute o servidor a partir da raiz do projeto (onde está `app.py`) para garantir que os caminhos de `static/` sejam resolvidos corretamente.

### Configurações
- **Banco**: a aplicação cria automaticamente `instance/pi_sst.db` (SQLite). Para usar outro banco, defina `DATABASE_URL` com uma URL suportada pelo SQLAlchemy.
- **Segredo de sessão**: defina `SECRET_KEY` para um valor seguro em produção.

## Documentação
- [Opinião sobre a construção da plataforma a partir do questionário](docs/opiniao_questionario.md)
- [Opinião geral considerando o guia de identificação de riscos psicossociais](docs/analise_guia_projeto.md)