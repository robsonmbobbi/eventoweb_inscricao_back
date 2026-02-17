# EventoWeb Inscrições - Flutter Web Application

Sistema de inscrição para eventos CEOMG desenvolvido em Flutter com padrão MVVM.

## 🎯 Características

- ✅ **MVVM Architecture** - Separação clara entre UI e lógica de negócio
- ✅ **GoRoute Navigation** - Roteamento tipado e seguro
- ✅ **Dependency Injection** - GetIt para gerenciamento de dependências
- ✅ **Responsivo** - Mobile-first design que funciona em desktops
- ✅ **Validação de Formulários** - Validação de CPF, Email, telefone, etc.
- ✅ **Máscaras de Entrada** - CPF, celular, CEP, cartão de crédito, etc.
- ✅ **Tema Centralizado** - Cores e estilos em um único lugar
- ✅ **Rest API Integration** - Comunicação com backend via HTTP
- ✅ **Tratamento de Erros** - Diálogos de erro em toda a aplicação
- ✅ **Loading Indicators** - Feedback visual durante processamento

## 📋 Estrutura do Projeto

```
lib/
├── core/                 # Configurações centrais
│   ├── router.dart      # Rotas e navegação GoRouter
│   ├── theme.dart       # Temas e cores da aplicação
│   ├── service_locator.dart  # Dependency Injection (GetIt)
│
├── models/              # Modelos de dados e DTOs
│   └── models.dart      # Todos os DTOs e enums
│
├── services/            # Serviços e APIs
│   └── api_service.dart # Integração com REST API
│
├── viewmodels/          # Lógica de negócio (MVVM)
│   ├── events_viewmodel.dart
│   ├── registration_viewmodel.dart
│   ├── orders_viewmodel.dart
│   ├── payment_viewmodel.dart
│
├── views/               # Interface do usuário
│   └── screens/
│       ├── events_screen.dart       # Listagem de eventos
│       ├── orders_screen.dart       # Gerenciamento de pedidos
│       ├── registration_screen.dart # Formulário de inscrição
│       ├── payment_screen.dart      # Formulário de pagamento
│       └── payment_success_screen.dart  # Confirmação de pagamento
│
├── common/              # Componentes reutilizáveis
│   ├── widgets.dart     # Diálogos e widgets comuns
│   └── input_validators.dart  # Validadores e formatadores
│
└── main.dart           # Entrada da aplicação
```

## 🚀 Como Iniciar

### Pré-requisitos
- Flutter 3.3.0 ou superior
- Dart 3.3.0 ou superior
- Editor: VS Code, Android Studio ou IntelliJ

### Instalação

1. **Clonar o repositório**
```bash
cd front
flutter pub get
```

2. **Configurar URL da API**

Abra `lib/core/service_locator.dart` e atualize a URL da API:

```dart
class ServiceLocator {
  static Future<void> setup() async {
    getIt.registerSingleton<ApiService>(
      ApiService(baseUrl: 'http://seu-backend-url'), // Atualize aqui
    );
  }
}
```

3. **Executar a aplicação**

```bash
# Web
flutter run -d web

# Dispositivo específico
flutter run -d chrome
```

## 📱 Fluxo da Aplicação

### 1. Tela de Eventos
- Exibe lista de eventos disponíveis para inscrição
- Mostra imagem, períodos e botão para inscrição
- Busca dados de: `GET /api/eventos/listar`

### 2. Tela de Pedidos
- Exibe inscrições realizadas para um evento
- Permite adicionar novas inscrições
- Habilita pagamento quando há inscrições

### 3. Tela de Inscrição
**Passo 1: CPF**
- Entrada do CPF
- Busca em: `GET /api/inscrições/pesquisar/evento/{id}/cpf/{cpf}`

**Passo 2: Data de Nascimento** (se novo)
- Entrada da data de nascimento
- Cálculo da idade em: `GET /api/eventos/{id}/obter-idade/{data-nascimento}`

**Passo 3: Dados Completos**
- Formulário com campos da pessoa
- Campos específicos por tipo (Infantil/Adulto)
- Salvo em: `POST /api/inscricoes/incluir` ou `PUT /api/inscricoes/atualizar`

### 4. Tela de Pagamento
- Seleciona tipo de pagamento (Débito, Desconto, Isenção)
- Dados do pagador
- Formas de pagamento em: `GET /api/precosinscricao/evento/{id}/obter/nascimento/{data}`
- Submissão em: `POST /api/pedidos/incluir`

### 5. Tela de Sucesso
- Confirmação de pedido
- PIX QR Code (se aplicável)
- Informações sobre próximas etapas

## 🔧 Configuração e Customização

### Ajustar Cores do Tema

Edite `lib/core/theme.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF6200EA); // Ajuste aqui
  static const Color secondary = Color(0xFF03DAC6);
  // ... mais cores
}
```

### Adicionar Novo Validador

Adicione em `lib/common/input_validators.dart`:

```dart
static String? validateMeuCampo(String? value) {
  if (value == null || value.isEmpty) {
    return 'Campo obrigatório';
  }
  // sua lógica de validação
  return null;
}
```

### Adicionar Nova Tela

1. Crie o arquivo em `lib/views/screens/nova_screen.dart`
2. Crie o ViewModel em `lib/viewmodels/nova_viewmodel.dart`
3. Adicione a rota em `lib/core/router.dart`
4. Use `context.pushNamed('nome-rota')` para navegar

## 📦 Dependências Principais

- **flutter**: Framework UI
- **provider**: Gerenciamento de estado
- **go_router**: Roteamento
- **get_it**: Dependency Injection
- **http**: Cliente HTTP
- **mask_text_input_formatter**: Máscaras de entrada
- **intl**: Formatação de datas

## 🔐 Segurança

- Senhas e tokens não são armazenados no código
- URLs de API devem ser configuradas por ambiente
- Validação de entrada em todos os formulários
- Tratamento apropriado de erros sem expor detalhes internos

## 📝 Padrão de Código

### ViewModel
```dart
class MeuViewModel extends ChangeNotifier {
  // Estado privado
  String _campo = '';
  bool _isLoading = false;
  
  // Getters públicos
  String get campo => _campo;
  bool get isLoading => _isLoading;
  
  // Setters com notificação
  void setCampo(String value) {
    _campo = value;
    notifyListeners();
  }
  
  // Ações assincronas
  Future<void> minhaAcao() async {
    _isLoading = true;
    notifyListeners();
    // ... lógica
    _isLoading = false;
    notifyListeners();
  }
}
```

### View
```dart
Consumer<MeuViewModel>(
  builder: (context, viewModel, _) {
    return LoadingOverlay(
      isLoading: viewModel.isLoading,
      child: MyWidget(),
    );
  },
)
```

## 🚧 Melhorias Futuras

- [ ] Modo offline com sincronização
- [ ] Temas escuro/claro
- [ ] Suporte a múltiplos idiomas
- [ ] Integração com câmera (documento)
- [ ] Histórico de pedidos
- [ ] Cancelamento de inscrição
- [ ] Testes unitários e integração

## 📧 Contato e Suporte

Para dúvidas ou sugestões sobre o desenvolvimento, entre em contato com a equipe de desenvolvimento.

## 📄 Licença

Este projeto é propriedade da CEOMG. Todos os direitos reservados.
