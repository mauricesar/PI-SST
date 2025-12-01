import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aplicação Flutter composta apenas por elementos visuais
/// para estudo de formulários.
///
/// O foco aqui é mostrar a estrutura de widgets e estilos que se
/// aproximam do protótipo fornecido, sem implementar regras de
/// negócio ou validação real. Os diversos comentários destacados
/// ao longo do arquivo explicam a intenção de cada parte para que
/// o código possa ser estudado em sala de aula ou evoluído depois.
void main() {
  runApp(const RegistrationShowcaseApp());
}

class RegistrationShowcaseApp extends StatelessWidget {
  const RegistrationShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp encapsula todo o tema e roteamento da aplicação.
    // Aqui desabilitamos a tarja de debug e definimos o tema base
    // para todos os formulários.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Telas de Cadastro',
      theme: ThemeData(
        // Swatch azul reflete o padrão cromático do protótipo.
        primarySwatch: Colors.blue,
        // Família tipográfica configurada via Google Fonts para
        // manter a consistência visual.
        textTheme: GoogleFonts.interTextTheme(),
        // Tema padrão para todos os campos de formulário.
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD8D8D8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1E88E5), width: 1.4),
          ),
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      // A tela inicial usa um TabController para alternar entre os
      // cadastros de Usuário comum e Usuário coletor.
      home: const RegistrationTabs(),
    );
  }
}

/// Tela inicial que apresenta as duas opções de cadastro em abas.
class RegistrationTabs extends StatelessWidget {
  const RegistrationTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController simplifica o gerenciamento de abas sem
    // precisar criar um controlador manual.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Fundo cinza-claro para destacar os cartões brancos.
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Text(
            'Telas de Cadastro',
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // TabBar alterna entre formulários reutilizando o mesmo
          // layout, apenas trocando textos e ajustes específicos.
          bottom: TabBar(
            indicatorColor: const Color(0xFF1E88E5),
            labelColor: const Color(0xFF1E88E5),
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(text: 'Usuário comum'),
              Tab(text: 'Usuário coletor'),
            ],
          ),
        ),
        // Cada aba apresenta um RegistrationForm com rótulos e
        // mensagens customizadas. Nada de lógica de backend aqui.
        body: const TabBarView(
          children: [
            RegistrationForm(title: 'Criar Conta', isCollector: false),
            RegistrationForm(title: 'Cadastro Profissional', isCollector: true),
          ],
        ),
      ),
    );
  }
}

/// Formulário genérico usado tanto para o cadastro de usuário quanto de coletor.
class RegistrationForm extends StatelessWidget {
  const RegistrationForm({super.key, required this.title, required this.isCollector});

  final String title;
  final bool isCollector;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            // Limita a largura máxima para manter o layout legível em
            // telas maiores (ex.: web ou tablet) sem perder o aspecto
            // de cartão estreito do protótipo.
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho dinâmico com título e subtítulo.
                _Header(title: title, isCollector: isCollector),
                const SizedBox(height: 16),
                // Campos de entrada reutilizam um mesmo widget
                // para padronizar margens e tipografia.
                _LabeledField(
                  label: 'Nome completo',
                  hint: isCollector ? 'Seu Nome Completo' : 'Seu Nome',
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Email',
                  hint: 'Seu Melhor Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                // Linha com data de nascimento e gênero. O
                // espaçamento de 12 mantém proporcionalidade.
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'Data de nascimento',
                        hint: 'dd/mm/aaaa',
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledDropdown(
                        label: 'Gênero',
                        hint: 'Selecione',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Cidade e endereço em colunas lado a lado.
                Row(
                  children: const [
                    Expanded(child: _LabeledField(label: 'Cidade', hint: 'Cidade - Estado')),
                    SizedBox(width: 12),
                    Expanded(child: _LabeledField(label: 'Endereço', hint: 'Rua, Número, Complemento')),
                  ],
                ),
                const SizedBox(height: 12),
                // Dados de CEP e país, mantendo consistência de alturas.
                Row(
                  children: const [
                    Expanded(child: _LabeledField(label: 'Cep', hint: 'Digite seu Cep')),
                    SizedBox(width: 12),
                    Expanded(child: _LabeledField(label: 'País', hint: 'Digite seu País')),
                  ],
                ),
                const SizedBox(height: 12),
                // Dupla de campos de senha com obscureText ativo.
                Row(
                  children: const [
                    Expanded(child: _LabeledField(label: 'Senha', hint: 'Digite a sua senha', obscureText: true)),
                    SizedBox(width: 12),
                    Expanded(child: _LabeledField(label: 'Confirmar senha', hint: 'Digite a senha novamente', obscureText: true)),
                  ],
                ),
                const SizedBox(height: 12),
                // Campo multilinha para observações adicionais.
                _LabeledField(
                  label: 'Observações',
                  hint: 'Observações',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                // Botão fictício de upload de foto (apenas visual).
                _PhotoButton(label: 'Adicionar uma foto'),
                const SizedBox(height: 12),
                // Checkbox de aceite de termos; não implementa
                // seleção real, servindo apenas para demonstração.
                _TermsAndPolicyCheckbox(isCollector: isCollector),
                const SizedBox(height: 16),
                // Botão principal com texto alterado conforme a aba.
                _PrimaryButton(text: isCollector ? 'Cadastrar coletor' : 'Criar Conta'),
                if (!isCollector) ...[
                  const SizedBox(height: 14),
                  // Botão secundário ilustrativo. No protótipo ele
                  // repete o texto "Criar Conta" para reforçar o CTA.
                  _SecondaryButton(text: 'Criar Conta'),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Já é cadastrado? Entrar Login',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1E88E5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (isCollector)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Já é cadastrado? Entrar Login',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1E88E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho da tela com título e subtítulo ajustados para cada tipo de usuário.
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.isCollector});

  final String title;
  final bool isCollector;

  @override
  Widget build(BuildContext context) {
    // Subtítulo muda conforme o perfil para reforçar o fluxo correto.
    final subtitle = isCollector
        ? 'Complete seus dados para atuar como coletor'
        : 'Cadastre-se para começar a usar o app';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

/// Campo de texto reutilizável com rótulo e dicas padronizadas.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          // obscureText é útil para senhas; quando false, campo normal.
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }
}

/// Combobox estilizado que mantém o visual do protótipo.
class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        InputDecorator(
          // Usamos InputDecorator para simular um dropdown estático
          // sem acionar menus reais; mantém bordas e padding.
          decoration: const InputDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: GoogleFonts.inter(color: const Color(0xFFB0B0B0)),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFFB0B0B0)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botão secundário que abre espaço para upload de foto.
class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            // onTap vazio: apenas efeito visual de botão/hover.
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF1E88E5)),
                const SizedBox(width: 10),
                Text(
                  'Adicionar uma foto',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1E88E5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Caixa de seleção para aceitar termos e política de dados.
class _TermsAndPolicyCheckbox extends StatelessWidget {
  const _TermsAndPolicyCheckbox({required this.isCollector});

  final bool isCollector;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox sem estado real; sempre falso para reforçar
        // que este arquivo é apenas visual.
        Checkbox(value: false, onChanged: (_) {}),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(color: Colors.black87),
              children: const [
                TextSpan(text: 'Concordo com os Termos de Uso e Política de privacidade.\n'),
                TextSpan(text: 'Concordo com a Política de dados.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão principal com cor sólida.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        // ElevatedButton destaca a ação principal em contraste.
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: () {},
        child: Text(text),
      ),
    );
  }
}

/// Botão secundário com borda azul.
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        // OutlinedButton cria hierarquia visual abaixo do botão principal.
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1E88E5),
          side: const BorderSide(color: Color(0xFF1E88E5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: () {},
        child: Text(text),
      ),
    );
  }
}
