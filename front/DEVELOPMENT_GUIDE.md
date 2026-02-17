# Guia de Desenvolvimento - EventoWeb Inscrições

## 🔄 Padrão MVVM Implementado

Este projeto segue o padrão MVVM (Model-View-ViewModel) conforme recomendado pela documentação oficial do Flutter.

### Estrutura MVVM

#### 1. Model (`lib/models/`)
- Contém todas as classes de dados (DTOs)
- Enums para tipos e situações
- Métodos `fromJson()` e `toJson()` para serialização
- Métodos `copyWith()` para criação de cópias imutáveis

```dart
class DTOPessoa {
  final String nome;
  final String cpf;
  // ...
  
  factory DTOPessoa.fromJson(Map<String, dynamic> json) { }
  Map<String, dynamic> toJson() { }
  DTOPessoa copyWith({...}) { }
}
```

#### 2. View (`lib/views/screens/`)
- Componentes UI puros que reagem a mudanças
- Usam `Consumer<ViewModel>` do Provider
- Chamam métodos do ViewModel em resposta a ações do usuário
- Não contêm lógica de negócio

```dart
Consumer<EventsViewModel>(
  builder: (context, viewModel, _) {
    return ListView(
      children: viewModel.eventos.map(...).toList(),
    );
  },
)
```

#### 3. ViewModel (`lib/viewmodels/`)
- Herda de `ChangeNotifier` do Provider
- Contém lógica de negócio e estado
- Notifica Views de mudanças via `notifyListeners()`
- Faz chamadas para serviços (ApiService)
- Manipula erros e estado de carregamento

```dart
class EventsViewModel extends ChangeNotifier {
  List<DTOEvento> _eventos = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters para acesso ao estado
  List<DTOEvento> get eventos => _eventos;
  
  // Métodos que modificam estado
  Future<void> loadEventos() async {
    _isLoading = true;
    notifyListeners();
    // ... lógica
    _isLoading = false;
    notifyListeners();
  }
}
```

## 🏗️ Arquitetura em Camadas

```
Request → View → ViewModel → Service → API → Backend
         ↓       ↓           ↓        ↓
        UI    Business   HTTP    Server
        Logic  Logic     Client
```

### Fluxo de Dados

1. **Usuário interage com View** → clica em botão
2. **View chama método do ViewModel**
3. **ViewModel executa lógica** → validação, cálculos
4. **ViewModel chama Service** → requisição HTTP
5. **Service faz requisição para API** → backend processa
6. **Resposta retorna para ViewModel** → atualiza estado
7. **ViewModel notifica View** → UI atualiza

## 📡 Integração com API

### Estrutura de Requisições

Todas as requisições são centralizadas em `lib/services/api_service.dart`:

```dart
class ApiService {
  Future<List<DTOEvento>> getEventos() async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/api/eventos/listar'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body)
          .map((json) => DTOEvento.fromJson(json))
          .toList();
    } else {
      throw ApiException(message: 'Erro ao carregar eventos');
    }
  }
}
```

### Endpoints Implementados

| Método | Endpoint | ViewModel | Descrição |
|--------|----------|-----------|-----------|
| GET | `/api/eventos/listar` | EventsViewModel | Lista eventos |
| GET | `/api/inscrições/pesquisar/evento/{id}/cpf/{cpf}` | RegistrationViewModel | Busca pessoa |
| GET | `/api/eventos/{id}/obter-idade/{data}` | RegistrationViewModel | Calcula idade |
| POST | `/api/inscricoes/incluir` | RegistrationViewModel | Cria inscrição |
| PUT | `/api/inscricoes/atualizar` | RegistrationViewModel | Atualiza inscrição |
| GET | `/api/precosinscricao/evento/{id}/obter/nascimento/{data}` | PaymentViewModel | Obtém preços |
| POST | `/api/pedidos/incluir` | PaymentViewModel | Cria pedido |

## 🎨 Sistema de Tema

### Cores Centralizadas

Todas as cores estão definidas em `lib/core/theme.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF6200EA);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  // ...
}
```

### Usando Cores

```dart
Container(
  color: AppColors.primary,
  child: Text('Texto', style: TextStyle(color: AppColors.white)),
)
```

## 🔐 Validação de Formulários

### Validadores Personalizados

Em `lib/common/input_validators.dart`:

```dart
class InputValidators {
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }
    // ... validação com check digits
    return null;
  }
}
```

### Usando em FormFields

```dart
TextFormField(
  decoration: InputDecoration(labelText: 'CPF'),
  inputFormatters: [InputFormatters.cpfFormatter],
  validator: (value) => InputValidators.validateCPF(value),
  onChanged: viewModel.setCpf,
)
```

## 🎯 Fluxo de Inscrição Detalhado

### Passo 1: Busca de CPF
```
User digita CPF → RegistrationViewModel.pesquisarCPF()
→ ApiService.pesquisarCPF()
→ Retorna DTOInscricaoPesquisaPessoa
→ ViewModel verifica situação:
   - Já inscrito? Mostrar erro
   - Inscrição no limbo? Carregar form com dados
   - Não existe? Pedir data de nascimento
```

### Passo 2: Cálculo de Idade
```
User confirma DOB → RegistrationViewModel.calcularIdade()
→ ApiService.obterIdade()
→ Determina tipo: Infantil ou Adulto
→ Carrega formulário apropriado
```

### Passo 3: Preenchimento do Formulário
```
User preenche campos → ViewModel.setNome(), setCpf(), etc
→ notifyListeners() → UI atualiza em tempo real
→ Validação ao sair do campo
```

### Passo 4: Salvar Inscrição
```
User clica Salvar → ViewModel.salvarInscricao()
→ Validação geral do formulário
→ Cria DTOInscricao com todos os dados
→ Escolhe incluir ou atualizar baseado em pesquisa anterior
→ ApiService.incluirInscricao() ou .atualizarInscricao()
→ Retorna para OrdersScreen com inscrição adicionada
```

## 💳 Fluxo de Pagamento

### Tipos de Pagamento

1. **Débito** - Integração com gateway de pagamento
   - Formas: Crédito à vista, Crédito parcelado, PIX
   - Campos específicos por forma

2. **Desconto** - Requer justificativa
   - Campo: Descrição do desconto
   - Valores zerados

3. **Isenção** - Requer justificativa
   - Campo: Descrição da isenção
   - Valores zerados

### Resposta do Pagamento

```dart
DTOResultadoPedido {
  idPedido,
  valor,
  tipo,
  debito: {
    tipoTransacao,
    status,
    imagemQRCodePixBase64,  // Para PIX
    pixCopiaECola           // Para PIX
  }
}
```

## 📦 Dependency Injection

### Registrando Dependências

Em `lib/core/service_locator.dart`:

```dart
class ServiceLocator {
  static Future<void> setup() async {
    getIt.registerSingleton<ApiService>(
      ApiService(baseUrl: 'http://seu-url'),
    );
    
    // Registrar outros serviços aqui
  }
}
```

### Usando Dependências

```dart
// No ViewModel
_viewModel = RegistrationViewModel(
  apiService: getIt<ApiService>(),
  idEvento: eventId,
);

// No Service
final apiService = getIt<ApiService>();
```

## 🚀 Navegação com GoRouter

### Definindo Rotas

Em `lib/core/router.dart`:

```dart
GoRoute(
  path: Routes.registration,
  name: 'registration',
  builder: (context, state) {
    final eventId = state.extra as int?;
    return RegistrationScreen(eventId: eventId ?? 0);
  },
)
```

### Navegando

```dart
// Push (com volta)
context.pushNamed('registration', extra: eventId);

// Go (sem volta na pilha)
context.go('/');

// Pop
context.pop();
```

## 🔄 Provider para Estado

### Consumindo Estado

```dart
// Reconstruir quando muda
Consumer<EventsViewModel>(
  builder: (context, viewModel, _) {
    return Text(viewModel.isLoading ? 'Carregando...' : '');
  },
)

// Apenas ler sem reconstruir
viewModel = context.read<EventsViewModel>();

// Assistir mudanças
viewModel = context.watch<EventsViewModel>();
```

## 🎭 Dialog Helper Functions

Utilitários para mostrar diálogos padronizados:

```dart
// Erro
showErrorDialog(context, message: 'Algo deu errado');

// Confirmação
showConfirmDialog(
  context,
  title: 'Confirmar',
  message: 'Deseja continuar?',
  onConfirm: () { },
)

// Sucesso
showSuccessDialog(context, message: 'Operação realizada!');

// Informação
showInfoDialog(context, message: 'Aqui está uma informação');
```

## 🧪 Dicas de Debug

### Ver logs JSON
```dart
print(jsonEncode(meuObject.toJson()));
```

### Inspecionar estado do ViewModel
```dart
print('Estado: ${viewModel.eventos.length}, Erro: ${viewModel.error}');
```

### Debugar requisições HTTP
Adicionar logger no ApiService:
```dart
print('Requisição: ${response.request.url}');
print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

## 📱 Layout Responsivo

### Detecção de Tamanho

```dart
final isMobile = MediaQuery.of(context).size.width < 768;

if (isMobile) {
  // Layout para mobile
} else {
  // Layout para desktop
}
```

### Usando Padding Responsivo

```dart
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: isMobile ? 16 : 32,
  ),
  child: MyWidget(),
)
```

## 🛡️ Tratamento de Erros

### Padrão para Requisições

```dart
try {
  final resultado = await apiService.minhaRequisicao();
  _erro = null;
} on ApiException catch (e) {
  _erro = e.message;
} catch (e) {
  _erro = 'Erro desconhecido: $e';
} finally {
  notifyListeners();
}
```

### Exibindo Erros para Usuário

```dart
if (viewModel.error != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showErrorDialog(
      context,
      message: viewModel.error!,
      onClose: viewModel.clearError,
    );
  });
}
```

## 📝 Convenções de Código

### Nomenclatura
- Classes: PascalCase (`EventsViewModel`)
- Variáveis: camelCase (`_eventos`, `isLoading`)
- Constantes: camelCase (`primaryColor`)
- Privadas: prefixo `_` (`_eventos`)

### Organização
- Imports: dart → flutter → packages → projeto
- Getters/Setters: após construtores
- Métodos públicos: antes dos privados
- Métodos assincronos: notificar antes e depois

### Documentação
```dart
/// Descrição do método
/// 
/// Retorna [bool] indicando sucesso
/// Throws [ApiException] se falhar
Future<bool> meuMetodo() async { }
```

## 🔄 Ciclo de Vida do ViewModel

```
init() → carrega dados iniciais
  ↓
notifyListeners() → UI se reconstrói
  ↓
usuário interage → chama método
  ↓
setState interno → notifyListeners()
  ↓
UI reage
  ↓
dispose() → limpeza (via Consumer)
```

## 🚀 Próximas Etapas para Desenvolvimento

1. **Testar com Backend Real**
   - Atualizar URL da API em ServiceLocator
   - Validar respostas JSON

2. **Adicionar Mais Validações**
   - Validar formato de cartão
   - Validar datas

3. **Implementar Cache**
   - Armazenar eventos localmente
   - Sincronizar quando conectado

4. **Testes**
   - Testes unitários para ViewModels
   - Testes de widget para telas
   - Testes de integração

5. **Performance**
   - Lazy loading para listas
   - Caching de imagens
   - Otimizar rebuilds

6. **Segurança**
   - Validar tokens
   - Criptografia de dados sensíveis
   - HTTPS obrigatório
