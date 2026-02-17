# 🚀 Quick Start Guide - EventoWeb Inscrições

## ⚡ Iniciar em 5 Minutos

### 1️⃣ Prerequisitos
```bash
# Verificar Flutter
flutter --version

# Verificar Dart
dart --version

# Já deve estar com Flutter 3.3.0+
```

### 2️⃣ Configurar Projeto
```bash
# Ir para pasta do projeto
cd front

# Instalar dependências
flutter pub get
```

### 3️⃣ Configurar API
Editar: `lib/core/service_locator.dart`

```dart
ApiService(baseUrl: 'http://localhost:3000')  // Trocar URL aqui
```

### 4️⃣ Executar
```bash
# Executar no chrome
flutter run -d chrome

# Ou em outro navegador
flutter run -d edge
flutter run -d firefox
```

### 5️⃣ Testar
- Abrir `http://localhost:xxxxx` no navegador
- Deve ver a tela de eventos
- Se houver erro na API, configure a URL corretamente

---

## 📁 Arquivos Importantes

| Arquivo | Propósito | Quando Editar |
|---------|-----------|---------------|
| `lib/core/service_locator.dart` | Configuração da API | Para trocar URL |
| `lib/core/theme.dart` | Cores e estilos | Para customizar visual |
| `lib/models/models.dart` | Estrutura de dados | Se API retornar diferentes dados |
| `pubspec.yaml` | Dependências | Para adicionar packages |

---

## 🔍 Estrutura do Código

### Views (Telas)
Localização: `lib/views/screens/`
- `events_screen.dart` - Lista de eventos
- `orders_screen.dart` - Meus pedidos
- `registration_screen.dart` - Formulário de inscrição
- `payment_screen.dart` - Formulário de pagamento
- `payment_success_screen.dart` - Confirmação

### ViewModels (Lógica)
Localização: `lib/viewmodels/`
- `events_viewmodel.dart` - Lógica de eventos
- `registration_viewmodel.dart` - Lógica de inscrição
- `orders_viewmodel.dart` - Lógica de pedidos
- `payment_viewmodel.dart` - Lógica de pagamento

---

## 🐛 Debug

### Ver logs da API
```dart
// Em api_service.dart, adicionar:
print('Requisição: ${response.request.url}');
print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

### Ver estado do ViewModel
```dart
// Em qualquer tela:
print('Eventos: ${viewModel.eventos.length}');
print('Erro: ${viewModel.error}');
print('Loading: ${viewModel.isLoading}');
```

### Inspecionar elementos
```
Ctrl+Shift+D - Abre widget inspector
```

---

## 📝 Adicionar Nova Tela

### Passo 1: Criar ViewModel
`lib/viewmodels/minha_viewmodel.dart`
```dart
class MinhaViewModel extends ChangeNotifier {
  String _status = '';
  bool get status => _status;
  
  void fazer() {
    _status = 'fazendo';
    notifyListeners();
  }
}
```

### Passo 2: Criar Tela
`lib/views/screens/minha_screen.dart`
```dart
class MinhaScreen extends StatelessWidget {
  const MinhaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MinhaViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(title: Text('Minha Tela')),
          body: Center(child: Text(viewModel.status)),
        );
      },
    );
  }
}
```

### Passo 3: Adicionar Rota
`lib/core/router.dart`
```dart
GoRoute(
  path: '/minha',
  name: 'minha',
  builder: (context, state) => const MinhaScreen(),
),
```

### Passo 4: Navegar
```dart
context.pushNamed('minha');
```

---

## ✅ Checklist de Deployment

- [ ] URL da API atualizada
- [ ] Testado em Chrome
- [ ] Testado em Firefox
- [ ] Testado em Safari
- [ ] Testado em mobile (responsivo)
- [ ] Sem erros de console
- [ ] Sem warnings no analyzer
- [ ] Imagens/logos carregando
- [ ] Formulários validando
- [ ] Navegação funcionando
- [ ] Diálogos de erro aparecendo

---

## 🔑 Atalhos Úteis

| Comando | Resultado |
|---------|-----------|
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Sair |
| `d` | Desconectar do device |
| `p` | Abrir performance overlay |
| `i` | Abrir widget inspector |

---

## 🎯 Fluxo Rápido de Teste

1. **Tela de Eventos**
   - Deve carregar lista de eventos
   - Clique em "Inscrever-se"

2. **Tela de Pedidos**
   - Deve estar vazia
   - Clique em "Nova Inscrição"

3. **Tela de Inscrição - Passo 1**
   - Digite um CPF
   - Clique em "Prosseguir"
   - Deve fazer requisição à API

4. **Tela de Inscrição - Passo 2 ou 3**
   - Dependendo da resposta da API
   - Preencha o formulário
   - Clique em "Salvar Inscrição"

5. **Tela de Pedidos**
   - Deve mostrar inscrição adicionada
   - Clique em "Pagamento"

6. **Tela de Pagamento**
   - Preencha dados
   - Clique em "Finalizar Pedido"

7. **Tela de Sucesso**
   - Deve mostrar ID do pedido
   - Botão para voltar aos eventos

---

## 📞 Erros Comuns e Soluções

**Erro: "Could not get the type of 'SomeClass'"**
- Execute `flutter clean && flutter pub get`

**API retorna 404**
- Verifique URL da API
- Verifique se o backend está rodando
- Verifique o endpoint

**Imagens não carregam**
- Verifique URL em `eventos.logotipo`
- Verifique CORS se backend está em domínio diferente

**Form não valida**
- Verifique se `validator` está preenchido
- Verifique se `currentState!.validate()` é chamado

**Formulário trava ao salvar**
- Verifique endpoint de inscrição
- Verifique estrutura de dados enviados
- Veja logs da API

---

## 📦 Build para Produção

```bash
# Build web otimizado
flutter build web --release

# O build fica em: build/web/

# Para servir localmente
cd build/web
python -m http.server 8000

# Ou com http-server
npx http-server
```

---

## 🎨 Customizações Comuns

### Trocar Cor Primária
`lib/core/theme.dart`
```dart
static const Color primary = Color(0xFFNOVACOR);
```

### Trocar Nome da App
`pubspec.yaml`
```yaml
name: meu_novo_nome
```

### Trocar URL da API
`lib/core/service_locator.dart`
```dart
ApiService(baseUrl: 'http://minha-api.com')
```

### Adicionar Requisição HTTP
`lib/services/api_service.dart`
```dart
Future<MinhaResposta> minhaRequisicao() async {
  final response = await _httpClient.get(
    Uri.parse('$baseUrl/meu-endpoint'),
  );
  // ... processar resposta
}
```

---

## 🆘 Precisa de Ajuda?

1. **Verificar logs**
   - Abrir Debug Console no VS Code
   - Procurar por mensagens de erro

2. **Ler documentação**
   - [README.md](README.md) - Visão geral
   - [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Guia completo
   - [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - O que foi feito

3. **Verificar código**
   - Procurar por `// TODO` comments
   - Ver exemplos em outras telas
   - Comparar com implementação similar

4. **Flutter Doctor**
   ```bash
   flutter doctor
   ```
   - Mostra status da instalação
   - Ajuda a identificar problemas

---

## ✨ Dicas Pro

- Use `Ctrl+P` (VS Code) para navegar entre arquivos rápido
- Use `Shift+Alt+F` para formatar arquivo
- Use `Ctrl+I` para autocompletar código
- Use `Ctrl+Space` para ver sugestões
- Sempre use `hot reload` em dev (tecla `r`)

---

## 📈 Performance Tips

- Use `const` constructors sempre que possível
- Use `ListView.builder` para listas grandes
- Implemente `shouldRebuild` em Consumers opcionais
- Use `Provider.of` se não precisar rebuild
- Minimize rebuilds desnecessários

---

## 🎉 Você está pronto!

A aplicação está totalmente estruturada e pronta para desenvolvimento. 

**Próximo passo:** Configure sua API backend e teste o fluxo completo!

Boa codificação! 🚀
