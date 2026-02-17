# EventoWeb Inscrições - Documentação da Aplicação

## 📚 Guias de Referência Rápida

Este projeto contém toda a documentação necessária para entender, modificar e manter a aplicação. Escolha o guia conforme sua necessidade:

### 🚀 Primeiro Acesso?
**→ Comece aqui:** [QUICKSTART.md](QUICKSTART.md)
- Setup em 5 minutos
- Primeiros passos
- Teste rápido de funcionalidade
- Atalhos e dicas

### 📖 Entender Tudo Sobre o Projeto?
**→ Leia:** [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
- O que foi implementado
- Estrutura completa
- Fluxo de usuário
- Próximos passos recomendados

### 🔧 Desenvolvendo Recursos Novos?
**→ Consulte:** [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
- Padrão MVVM explicado em detalhes
- Como adicionar novas features
- Padrões de código
- Melhores práticas

### 🔍 Referência Rápida?
**→ Use:** [README.md](README.md)
- Características gerais
- Estrutura de pastas
- Como instalar
- Configuração e customização

---

## 📁 Estrutura de Documentos

```
📄 DOCUMENTATION.md             ← Você está aqui
├── QUICKSTART.md              ← Iniciar em 5 min (👈 COMECE AQUI)
├── IMPLEMENTATION_SUMMARY.md  ← Visão geral completa
├── DEVELOPMENT_GUIDE.md       ← Guia técnico detalhado
├── README.md                  ← Referência geral
└── CÓDIGO
    ├── lib/main.dart         ← Entrada da aplicação
    ├── lib/core/
    │   ├── router.dart       ← Configuração de rotas
    │   ├── theme.dart        ← Cores e temas
    │   └── service_locator.dart ← Dependency injection
    ├── lib/models/
    │   └── models.dart       ← Todos os DTOs
    ├── lib/services/
    │   └── api_service.dart  ← Cliente HTTP
    ├── lib/viewmodels/
    │   ├── events_viewmodel.dart
    │   ├── registration_viewmodel.dart
    │   ├── orders_viewmodel.dart
    │   └── payment_viewmodel.dart
    └── lib/views/screens/
        ├── events_screen.dart
        ├── orders_screen.dart
        ├── registration_screen.dart
        ├── payment_screen.dart
        └── payment_success_screen.dart
```

---

## 🎯 Roteiros de Aprendizado

### Para Iniciante em Flutter
1. Ler [QUICKSTART.md](QUICKSTART.md)
2. Executar `flutter run` e brincar
3. Ler [README.md](README.md) para entender estrutura
4. Modificar cores em `lib/core/theme.dart`

### Para Desenvolvedor Experiente
1. Ler [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) rapidamente
2. Explorar código em `lib/viewmodels/`
3. Ler [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) seções relevantes
4. Começar a desenvolver novos recursos

### Para Code Review / QA
1. Ler [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
2. Verificar fluxo em [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) seção "Fluxo Detalhado"
3. Executar checklist de deployment
4. Testar em vários devices

---

## 🔑 Tópicos Rápidos

### Trocar URL da API
Arquivo: `lib/core/service_locator.dart`
```dart
ApiService(baseUrl: 'http://sua-url')
```

### Adicionar Campo no Formulário
1. Criar getter/setter no ViewModel correspondente
2. Adicionar TextField na tela
3. Adicionar validador se obrigatório

### Criar Nova Tela
Seguir o padrão MVVM:
1. Criar `widget_viewmodel.dart` em `lib/viewmodels/`
2. Criar `widget_screen.dart` em `lib/views/screens/`
3. Adicionar rota em `lib/core/router.dart`
4. Navegar usando `context.pushNamed('nome')`

### Adicionar Novo Endpoint
1. Adicionar método em `lib/services/api_service.dart`
2. Chamar de um ViewModel
3. Tratar erro com `ApiException`
4. Notificar UI com `notifyListeners()`

---

## 📞 Troubleshooting Rápido

**Problema:** "pubspec.yaml not found"
- **Solução:** Execute `cd front` no terminal

**Problema:** "Could not find Flutter"
- **Solução:** Adicione Flutter ao PATH ou use caminho completo

**Problema:** "API não conecta"
- **Solução:** Verifique URL em `service_locator.dart`

**Problema:** "Widget não atualiza"
- **Solução:** Verifique se `notifyListeners()` é chamado

**Problema:** "Formulário não valida"
- **Solução:** Verifique se validator está definido

Veja seção de troubleshooting em [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) para mais soluções.

---

## ✅ Checklist de Setup Inicial

- [ ] Clonar projeto
- [ ] Executar `flutter pub get`
- [ ] Executar `flutter run`
- [ ] Ver aplicação rodando
- [ ] Ler [QUICKSTART.md](QUICKSTART.md)
- [ ] Configurar URL da API
- [ ] Testar fluxo completo
- [ ] Fazer primeiro commit

---

## 📊 Status do Projeto

| Componente | Status | Notas |
|-----------|--------|-------|
| Estrutura MVVM | ✅ Completo | Pronto para uso |
| Telas | ✅ Completo | 5 telas implementadas |
| Validações | ✅ Completo | CPF, Email, Phone, etc |
| API Service | ✅ Completo | Pronto para integração |
| Navegação | ✅ Completo | GoRouter configurado |
| Tema/Cores | ✅ Completo | Centralizados |
| Responsividade | ✅ Completo | Mobile e desktop |
| Documentação | ✅ Completo | 5 guias diferentes |
| Tests | ⏳ Futuro | Não implementado ainda |

---

## 🚀 Próximos Passos

1. **Hoje:**
   - [ ] Setup local
   - [ ] Executar projeto
   - [ ] Entender estrutura

2. **Amanhã:**
   - [ ] Integrar com backend
   - [ ] Testar fluxos
   - [ ] Ajustar UI conforme necessário

3. **Esta Semana:**
   - [ ] Implementar testes
   - [ ] Code review
   - [ ] Deploy ambiente de testes

4. **Próximas Semanas:**
   - [ ] Feedback de beta testers
   - [ ] Melhorias e fixes
   - [ ] Deploy para produção

---

## 💡 Dicas Importantes

### Desenvolvimento Local
- Use `dart run` ou Flutter DevTools para debug
- Use hot reload (tecla `r`) para iteração rápida
- Inspecione widgets com inspector (`Ctrl+Shift+D`)

### Antes de Commitar
- Execute `flutter analyze` para checks
- Execute `flutter test` se houver testes
- Formatar código com `dart format .`

### Melhor Prática
- Sempre use const constructors
- Sempre valide inputs do usuário
- Sempre trate erros de API
- Sempre notifique mudanças de estado

---

## 📧 Contato e Suporte

Para dúvidas técnicas sobre o projeto:
1. Verifique primeiro a documentação relevante
2. Procure por exemplos no código
3. Consulte a equipe de desenvolvimento

---

**Versão:** 1.0.0  
**Última atualização:** Fevereiro, 2026  
**Status:** ✅ Pronto para desenvolvimento

**[🏠 Voltar ao README.md](README.md)**
