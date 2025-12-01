# Telas de cadastro em Flutter

Este guia descreve como recriar as duas telas de cadastro do protótipo (usuário comum e usuário coletor) usando somente elementos visuais em Flutter/Dart. O código está concentrado em `flutter_ui/lib/main.dart` e utiliza o pacote `google_fonts` para aproximar a tipografia do design.

## Pré-requisitos
- Flutter SDK 3.x instalado e configurado (inclui Dart SDK).
- Dispositivo ou emulador configurado (Android, iOS ou web) para visualizar as telas.

## Passo a passo para executar
1. **Crie um novo projeto Flutter (caso ainda não tenha um):**
   ```bash
   flutter create cadastro_visual
   cd cadastro_visual
   ```

2. **Substitua o conteúdo do `pubspec.yaml`** pelo arquivo [`flutter_ui/pubspec.yaml`](../flutter_ui/pubspec.yaml) deste repositório. Mantenha as entradas padrão do Flutter e acrescente a dependência `google_fonts`.

3. **Copie o código das telas:**
   - Crie a pasta `lib` (se ainda não existir) e substitua `lib/main.dart` pelo arquivo [`flutter_ui/lib/main.dart`](../flutter_ui/lib/main.dart).

4. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

5. **Rode o aplicativo em modo debug:**
   ```bash
   flutter run
   ```
   - Se preferir a visualização web, use `flutter run -d chrome` (requer suporte web habilitado).

## Como o código está organizado
- **Tabs**: a tela inicial usa `DefaultTabController` com duas abas para alternar entre "Usuário comum" e "Usuário coletor".
- **Formulário reutilizável**: a classe `RegistrationForm` recebe o título e uma flag `isCollector` para ajustar textos e cores sem duplicação de layout.
- **Componentes reutilizáveis**: `_LabeledField`, `_LabeledDropdown`, `_PhotoButton`, `_TermsAndPolicyCheckbox`, `_PrimaryButton` e `_SecondaryButton` encapsulam estilos e espaçamentos do protótipo.
- **Somente UI**: os botões e campos não possuem validação ou integração com backend; foram mantidos apenas para fins visuais e de estudo.

## Próximos passos sugeridos
- Adicionar controladores e validações (`TextEditingController`, `Form`/`GlobalKey`) caso queira tornar os campos funcionais.
- Conectar o botão de foto a um seletor de imagem usando `image_picker`.
- Encadear as ações dos botões a fluxos de autenticação ou navegação reais conforme a necessidade do curso.
