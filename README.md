# PI-SST

Construção da plataforma referente ao Projeto Integrador da turma de SST - Senac Alagoas

## Visão geral
Esta prova de conceito mostra como implementar rapidamente um módulo web para coleta de clima/SST usando Python (Flask), HTML/CSS e banco de dados SQL (SQLite por padrão). Há três páginas principais:
- **Início**: resumo da proposta
- **Questionário**: formulário simples para captar percepções
- **Dashboard**: contagens agregadas das respostas enviadas

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
4. Acesse `http://localhost:5000` no navegador para usar o formulário e ver o dashboard.

### Configurações
- **Banco**: a aplicação cria automaticamente `instance/pi_sst.db` (SQLite). Para usar outro banco, defina `DATABASE_URL` com uma URL suportada pelo SQLAlchemy.
- **Segredo de sessão**: defina `SECRET_KEY` para um valor seguro em produção.

## Documentação
- [Opinião sobre a construção da plataforma a partir do questionário](docs/opiniao_questionario.md)
- [Opinião geral considerando o guia de identificação de riscos psicossociais](docs/analise_guia_projeto.md)