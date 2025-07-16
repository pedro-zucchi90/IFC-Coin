# IFC Coin

<div align="center">
  <img src="assets/ifc_coin_logo.png" width="120" alt="IFC Coin Logo"/>
  <br/><br/>
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/REST%20API-005571?style=for-the-badge">
</div>

---

## Visão Geral

O **IFC Coin** é um sistema de gamificação para instituições de ensino, composto por um backend Node.js (API REST) e um app Flutter multiplataforma. Alunos e professores acumulam moedas virtuais ao participarem de atividades, eventos e projetos.

---

## Funcionalidades 🚀

- **Sistema de Metas e Conquistas**: Criação, gerenciamento e conclusão de metas, com recompensas automáticas em coins.
- **Aprovação de Professores**: Professores precisam ser aprovados por um admin antes de acessar funcionalidades exclusivas.
- **Notificações Locais**: Alerta de conquistas, aprovações e metas concluídas diretamente no app.
- **Histórico de Transações**: Visualização detalhada de todas as moedas recebidas/enviadas.
- **Gestão de Usuários**: Perfis de aluno, professor e admin, com permissões diferenciadas.
- **Evidências para Metas**: Possibilidade de exigir foto, documento ou texto como comprovação para conclusão de metas.
- **Filtro e Busca de Metas/Conquistas**: Filtragem por tipo, categoria e status.
- **Login Seguro com JWT**: Autenticação robusta e armazenamento seguro de tokens.
- **Upload de Foto de Perfil**: Usuários podem personalizar seu avatar.
- **Administração via Painel**: Telas exclusivas para admins gerenciarem conquistas, metas e solicitações de professores.

---

## Estrutura do Projeto

```plaintext
backend/
├── server.js
├── env.example
├── package.json
├── package-lock.json
├── scripts/
│   ├── update_users_status.js
│   ├── seed.js
│   └── add_solicitacao_professores.js
├── routes/
│   ├── user.js
│   ├── admin.js
│   ├── auth.js
│   ├── goal.js
│   ├── achievement.js
│   └── transaction.js
├── data/
├── models/
│   ├── userModel.js
│   ├── goalModel.js
│   ├── achievementModel.js
│   └── transactionModel.js
├── middleware/
│   └── auth.js

lib/
├── main.dart
├── config.dart
├── particle_background.dart
├── widgets/
│   └── user_avatar.dart
├── services/
│   ├── user_service.dart
│   ├── notification_service.dart
│   ├── auth_service.dart
│   ├── goal_service.dart
│   ├── achievement_service.dart
│   └── admin_service.dart
├── screens/
│   ├── perfil_screen.dart
│   ├── como_ganhar.dart
│   ├── faq.dart
│   ├── metas_screen.dart
│   ├── conquistas_screen.dart
│   ├── home.dart
│   ├── admin_conquistas_screen.dart
│   ├── admin_metas_screen.dart
│   ├── admin_solicitacoes_professores_screen.dart
│   ├── tela_professor_criar_conta.dart
│   ├── tela_login.dart
│   ├── tela_aluno_criar_conta.dart
│   └── primeira_tela.dart
├── models/
│   ├── user_model.dart
│   ├── goal_model.dart
│   └── achievement_model.dart
├── providers/
│   └── auth_provider.dart
```

---

## Como rodar o projeto

### Backend (Node.js)
```bash
cd backend
npm install
npm start
```

### Frontend (Flutter)
```bash
flutter pub get
flutter run
```

---

Se tiver mais dúvidas, consulte os comentários no código.
