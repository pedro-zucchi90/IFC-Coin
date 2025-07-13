# Sistema de Notificações Simples - IFC Coin

Este guia explica como funciona o sistema de notificações locais do IFC Coin.

## 📋 Como Funciona

O sistema usa **notificações locais** do Flutter, que são muito mais simples de configurar e não requerem Firebase ou configurações complexas.

### ✅ Vantagens:
- **Configuração zero**: Funciona imediatamente
- **Sem dependências externas**: Não precisa de Firebase
- **Notificações instantâneas**: Aparecem no momento da ação
- **Funciona offline**: Não depende de internet
- **Fácil de manter**: Código simples e direto

## 📨 Tipos de Notificações

### 1. Professor Aprovado
- **Quando**: Admin aprova solicitação de professor
- **Mensagem**: "🎉 Conta Aprovada! Parabéns [nome]! Sua solicitação foi aprovada..."
- **Local**: Aparece na tela do admin que aprovou

### 2. Meta Concluída
- **Quando**: Usuário conclui uma meta
- **Mensagem**: "🎯 Meta Concluída! Parabéns [nome]! Você concluiu a meta [título]..."
- **Local**: Aparece na tela do usuário que concluiu

### 3. Nova Conquista
- **Quando**: Usuário desbloqueia uma conquista
- **Mensagem**: "🏆 Nova Conquista! Parabéns [nome]! Você desbloqueou a conquista [nome]..."
- **Local**: Aparece na tela do usuário que desbloqueou

## 🔧 Configuração

### 1. Instalar Dependência
```bash
flutter pub get
```

### 2. Pronto! 🎉
Não precisa de mais nada! O sistema já está funcionando.

## 🚀 Como Testar

### 1. Iniciar Backend
```bash
cd backend
npm run dev
```

### 2. Iniciar App Flutter
```bash
flutter run
```

### 3. Testar Notificações

#### Professor Aprovado:
1. Cadastre um professor
2. Faça login como admin
3. Aprove o professor na tela de solicitações
4. **Notificação aparece na tela do admin!**

#### Meta Concluída:
1. Faça login como usuário
2. Vá para "Metas"
3. Conclua uma meta
4. **Notificação aparece na tela do usuário!**

## 📱 Como Funciona Tecnicamente

### Flutter (Frontend)
- `NotificationService`: Gerencia notificações locais
- `flutter_local_notifications`: Plugin para mostrar notificações
- Notificações aparecem como **toast** na tela

### Backend
- **Sem dependências especiais**
- Apenas processa as ações (aprovar, concluir, etc.)
- O Flutter mostra a notificação localmente

## 🔍 Debug

### Verificar Logs do Flutter
No console do Flutter, procure por:
- ✅ Serviço de notificações inicializado com sucesso
- 📱 Notificação mostrada: [título]

### Problemas Comuns

#### 1. Notificação não aparece
**Solução**: Verificar se o app tem permissão para notificações

#### 2. Erro de inicialização
**Solução**: 
```bash
flutter clean
flutter pub get
```

## 📝 Arquivos Importantes

### Flutter
- `lib/services/notification_service.dart` - Serviço de notificações
- `lib/screens/admin_solicitacoes_professores_screen.dart` - Notifica aprovação
- `lib/screens/metas_screen.dart` - Notifica conclusão de meta

### Backend
- `backend/routes/admin.js` - Processa aprovação de professor
- `backend/routes/goal.js` - Processa conclusão de meta

## 🎯 Diferenças do Sistema Anterior

### Antes (Firebase):
- ❌ Configuração complexa
- ❌ Dependência do Firebase
- ❌ Tokens FCM
- ❌ Arquivos de configuração
- ❌ Notificações push (externas)

### Agora (Local):
- ✅ Configuração zero
- ✅ Sem dependências externas
- ✅ Notificações locais simples
- ✅ Funciona imediatamente
- ✅ Notificações instantâneas

## 🚀 Próximos Passos

1. **Adicionar mais tipos de notificação**:
   - Transação realizada
   - Saldo atualizado
   - Novo evento disponível

2. **Melhorar a interface**:
   - Notificações mais bonitas
   - Sons personalizados
   - Animações

3. **Configurações do usuário**:
   - Ligar/desligar notificações
   - Escolher tipos de notificação
   - Horário de silêncio

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs do Flutter
2. Confirme se o app tem permissões
3. Teste com `flutter doctor`
4. Reinicie o app se necessário

---

**🎉 Sistema muito mais simples e fácil de usar!** 