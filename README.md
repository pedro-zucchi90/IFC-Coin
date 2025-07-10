# IFC Coin - Estrutura do Projeto

Este projeto é composto por um backend Node.js e um frontend Flutter. Abaixo está a estrutura de diretórios e exemplos dos principais arquivos de cada parte:

```
IFC-Coin-testes/
├── android/                # Projeto Android nativo (gerado pelo Flutter)
│   └── ...
├── assets/                 # Imagens e recursos estáticos
│   ├── ifc_coin_logo.png
│   └── ifc_coin_logo - Copia.png
├── backend/                # Backend Node.js (API, modelos, rotas, etc)
│   ├── data/
│   │   └── ...             # Dados do banco (MongoDB)
│   ├── middleware/
│   │   └── auth.js         # Middleware de autenticação
│   ├── models/
│   │   ├── achievementModel.js
│   │   ├── goalModel.js
│   │   ├── transactionModel.js
│   │   └── userModel.js
│   ├── routes/
│   │   ├── achievement.js
│   │   ├── auth.js
│   │   ├── goal.js
│   │   ├── transaction.js
│   │   └── user.js
│   ├── scripts/
│   │   └── seed.js         # Script para popular o banco
│   ├── server.js           # Ponto de entrada do backend
│   ├── package.json        # Dependências do backend
│   └── ...
├── ios/                    # Projeto iOS nativo (gerado pelo Flutter)
│   └── ...
├── lib/                    # Código principal do app Flutter
│   ├── config.dart         # Configurações globais (ex: baseUrl)
│   ├── main.dart           # Ponto de entrada do app Flutter
│   ├── models/
│   │   ├── achievement_model.dart
│   │   ├── goal_model.dart
│   │   └── user_model.dart
│   ├── particle_background.dart # Efeito visual de fundo
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── screens/
│   │   ├── admin_conquistas_screen.dart
│   │   ├── admin_metas_screen.dart
│   │   ├── como_ganhar.dart
│   │   ├── conquistas_screen.dart
│   │   ├── faq.dart
│   │   ├── home.dart
│   │   ├── metas_screen.dart
│   │   ├── perfil_screen.dart
│   │   ├── primeira_tela.dart
│   │   ├── tela_aluno_criar_conta.dart
│   │   ├── tela_login.dart
│   │   └── tela_professor_criar_conta.dart
│   ├── services/
│   │   ├── achievement_service.dart
│   │   ├── auth_service.dart
│   │   ├── goal_service.dart
│   │   └── user_service.dart
│   └── ...
├── linux/                  # Projeto Linux (gerado pelo Flutter)
│   └── ...
├── macos/                  # Projeto macOS (gerado pelo Flutter)
│   └── ...
├── test/                   # Testes do Flutter
│   └── widget_test.dart
├── web/                    # Projeto Web (gerado pelo Flutter)
│   ├── favicon.png
│   ├── index.html
│   ├── manifest.json
│   └── icons/
│       └── ...
├── windows/                # Projeto Windows (gerado pelo Flutter)
│   └── ...
├── pubspec.yaml            # Dependências do Flutter
├── README.md               # Este arquivo
└── ...
```

## Descrição das principais pastas/arquivos

- **backend/**: Código do servidor Node.js, responsável pela API REST, autenticação, regras de negócio e persistência de dados.
- **lib/**: Código Dart do app Flutter, incluindo telas, modelos, providers e serviços.
- **assets/**: Imagens e ícones usados no app.
- **android/**, **ios/**, **linux/**, **macos/**, **windows/**, **web/**: Códigos gerados automaticamente pelo Flutter para cada plataforma.
- **pubspec.yaml**: Gerenciador de dependências do Flutter.

## Como rodar o projeto

1. **Backend**: Entre na pasta `backend/` e siga as instruções para instalar dependências e rodar o servidor Node.js.
2. **Frontend**: No diretório raiz, rode `flutter pub get` e depois `flutter run` para iniciar o app.

---

Se precisar de mais detalhes sobre cada parte, consulte os arquivos e comentários no código.
