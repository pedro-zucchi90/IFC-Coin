# IFC Coin

<div align="center">
  <img src="assets/ifc_coin_logo.png" width="400" alt="IFC Coin Logo"/>
  <br/><br/>
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/REST%20API-005571?style=for-the-badge">
</div>

---

## Visão Geral

O **IFC Coin** é um sistema de gamificação para instituições de ensino, composto por um backend Node.js (API REST) e um aplicativo Flutter multiplataforma. O sistema permite que alunos e professores acumulem moedas virtuais através da participação em atividades, eventos e projetos acadêmicos.

---

## Funcionalidades Principais

### Sistema de Usuários
- **Perfis diferenciados**: Aluno, Professor e Administrador
- **Sistema de aprovação**: Professores necessitam aprovação administrativa
- **Upload de foto de perfil**: Personalização de avatar
- **Autenticação segura**: Login com JWT e armazenamento seguro de tokens

### Sistema de Metas e Conquistas
- **Criação e gerenciamento**: Metas personalizáveis com recompensas em moedas
- **Sistema de evidências**: Suporte a foto, documento ou texto como comprovação
- **Conquistas automáticas**: Badges atribuídos por atividades realizadas
- **Filtros e busca**: Filtragem por tipo, categoria e status

### Sistema de Transações
- **Transferências entre usuários**: Envio e recebimento de IFC Coins
- **Histórico detalhado**: Visualização completa de todas as transações
- **QR Code**: Transferências rápidas via código QR
- **Controle administrativo**: Aprovação de transferências (configurável)

### Sistema de Notificações
- **Notificações locais**: Alertas de conquistas, aprovações e metas concluídas
- **Notificações push**: Sistema de notificações em tempo real

### Painel Administrativo
- **Gestão de conquistas**: Criação e edição de badges
- **Gestão de metas**: Aprovação e gerenciamento de metas
- **Solicitações de professores**: Aprovação de novos professores
- **Relatórios e estatísticas**: Métricas e relatórios do sistema

---

## Pré-requisitos

### Backend
- **Node.js** (versão 18 ou superior)
- **MongoDB** (versão 5.0 ou superior)
- **npm** ou **yarn**

### Frontend
- **Flutter SDK** (versão 3.7.0 ou superior)
- **Dart** (versão 3.0 ou superior)
- **Android Studio** ou **VS Code** com extensões Flutter

### Sistema Operacional
- **Windows 10/11**, **macOS** ou **Linux**

---

## Instalação e Configuração

### 1. Clone do Repositório

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/IFC-Coin-testes.git

# Entre no diretório do projeto
cd IFC-Coin-testes

# Verifique se está na branch principal
git checkout main
```

### 2. Configuração do Backend

```bash
# Entre no diretório do backend
cd backend

# Instale as dependências
npm install

# Copie o arquivo de exemplo de variáveis de ambiente
cp env.example .env
```

#### 2.1 Configuração do Arquivo .env

Edite o arquivo `backend/.env` com suas configurações:

```env
# Configurações do Servidor
PORT=3000
NODE_ENV=development

# Configurações do MongoDB
MONGODB_URI=mongodb://localhost:27017/ifc_coin_db

# Configurações JWT
JWT_SECRET=sua_chave_secreta_muito_segura_aqui_2024

# Configurações de Segurança
BCRYPT_ROUNDS=12
JWT_EXPIRES_IN=7d

# Configurações de Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Configurações CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080,http://localhost:8000

# Configurações de Email (opcional)
EMAIL=seuemail@gmail.com
SENHA_EMAIL=suasenha
```

#### 2.2 Configuração do MongoDB

```bash
# Inicie o MongoDB (Windows)
# Certifique-se de que o MongoDB está instalado e rodando
# Ou use MongoDB Atlas para uma instância na nuvem

# Para desenvolvimento local, o MongoDB deve estar rodando na porta 27017
```

### 3. Configuração do Frontend

```bash
# Volte para o diretório raiz
cd ..

# Instale as dependências do Flutter
flutter pub get

# Copie o arquivo de configuração
cp lib/config.example lib/config.dart
```

#### 3.1 Configuração do Arquivo config.dart

Edite o arquivo `lib/config.dart` com a URL da sua API:

```dart
// Para desenvolvimento local
const String baseUrl = 'http://localhost:3000/api';

// Para desenvolvimento com emulador Android
const String baseUrl = 'http://10.0.2.2:3000/api';

// Para desenvolvimento com dispositivo físico
const String baseUrl = 'http://SEU_IP_LOCAL:3000/api';
```

---

## Executando o Projeto

### 1. Inicialização do Backend

```bash
# Entre no diretório do backend
cd backend

# Inicie o servidor
npm start

# Para desenvolvimento com auto-reload
npm run dev
```

O servidor estará disponível em: `http://localhost:3000`

### 2. Inicialização do Frontend

```bash
# Em outro terminal, entre no diretório raiz
cd IFC-Coin-testes

# Execute o app Flutter
flutter run

# Para especificar uma plataforma
flutter run -d chrome  # Web
flutter run -d windows # Windows
flutter run -d android # Android
```

---

## Scripts de Seed e Configuração Inicial

### 1. Criar Administrador Padrão

```bash
# Entre no diretório do backend
cd backend

# Execute o script para criar o admin
node scripts/create_admin.js
```

**Credenciais do Administrador:**
- **Matrícula**: `1234002`
- **Senha**: `admin12`
- **Email**: `admin@ifc.edu.br`

### 2. Criar Conquistas Padrão

```bash
# Execute o script para criar conquistas padrão
node scripts/criar_conquistas_padrao.js
```

Este script cria automaticamente:
- Conquistas por transferências enviadas (1, 10, 50, 100)
- Conquistas por transferências recebidas (1, 10, 50, 100)
- Conquistas por metas concluídas (1, 10, 50, 100)
- Conquistas por saldo acumulado (100, 500, 1000, 5000)
- Conquistas especiais (primeiro login, perfil completo)

### 3. Scripts Adicionais Disponíveis

```bash
# Adicionar solicitações de professores (para testes)
node scripts/add_solicitacao_professores.js

# Verificar e atribuir conquistas aos usuários
node scripts/verificar_conquistas.js

# Recalcular estatísticas dos usuários
node scripts/recalcular_estatisticas.js

# Atualizar status dos usuários
node scripts/update_users_status.js
```

---

## Funcionalidades do Aplicativo

### Perfis de Usuário

#### Aluno
- Criar conta e fazer login
- Visualizar saldo de IFC Coins
- Participar de metas e ganhar conquistas
- Transferir coins para outros usuários
- Visualizar histórico de transações
- Personalizar perfil com foto

#### Professor
- Todas as funcionalidades do aluno
- Criar metas para os alunos
- Aprovar conclusões de metas
- Gerenciar suas turmas
- Necessita aprovação do administrador

#### Administrador
- Todas as funcionalidades do professor
- Aprovar solicitações de professores
- Gerenciar conquistas do sistema
- Aprovar transferências (se configurado)
- Visualizar estatísticas gerais

### Sistema de Metas

1. **Criação de Metas**: Professores podem criar metas com:
   - Título e descrição
   - Recompensa em IFC Coins
   - Data de expiração
   - Requisito de evidência (foto/documento/texto)
   - Categoria e dificuldade

2. **Participação**: Alunos podem:
   - Visualizar metas disponíveis
   - Filtrar por categoria/status
   - Solicitar participação
   - Enviar evidências de conclusão

3. **Aprovação**: Professores aprovam ou rejeitam conclusões

### Sistema de Conquistas

- **Conquistas Automáticas**: Atribuídas automaticamente ao atingir marcos
- **Categorias**: Transferências, Metas, Saldo, Especiais
- **Notificações**: Alertas quando conquistas são desbloqueadas
- **Visualização**: Galeria de conquistas no perfil

### Sistema de Transferências

- **QR Code**: Geração e leitura de códigos QR
- **Transferência Direta**: Por matrícula ou email
- **Histórico**: Registro completo de todas as transações
- **Notificações**: Alertas de transferências recebidas

---

## Configurações Avançadas

### Configuração de Notificações

O aplicativo suporta notificações locais para:
- Conquistas desbloqueadas
- Metas aprovadas/rejeitadas
- Transferências recebidas
- Aprovação de conta de professor

### Configuração de Upload de Imagens

- **Backend**: Configurado com Multer e Sharp para processamento
- **Frontend**: Image Picker para seleção de fotos
- **Armazenamento**: Local no servidor (pasta `uploads/`)

### Configuração de Segurança

- **JWT**: Tokens com expiração configurável
- **Rate Limiting**: Proteção contra spam
- **CORS**: Configuração de origens permitidas
- **Helmet**: Headers de segurança

---

## Solução de Problemas

### Problemas Comuns

#### Backend não inicia
```bash
# Verifique se o MongoDB está rodando
# Verifique se o arquivo .env está configurado
# Verifique se as dependências foram instaladas
npm install
```

#### Aplicativo não conecta com o backend
```bash
# Verifique a URL no config.dart
# Verifique se o backend está rodando
# Verifique as configurações CORS
```

#### Erro de permissões (Android)
```bash
# Adicione permissões no AndroidManifest.xml
# Para câmera, armazenamento e internet
```

### Logs e Debug

```bash
# Backend logs
cd backend
npm run dev

# Flutter logs
flutter run --verbose
```

---

## Documentação da API

A documentação completa da API está disponível em:
- **Swagger/OpenAPI**: `http://localhost:3000/api-docs` (se configurado)
- **Endpoints principais**:
  - `/api/auth` - Autenticação
  - `/api/users` - Gestão de usuários
  - `/api/goals` - Gestão de metas
  - `/api/achievements` - Gestão de conquistas
  - `/api/transactions` - Gestão de transações
  - `/api/admin` - Funcionalidades administrativas

---

## Estrutura do Projeto

```plaintext
backend/
├── server.js
├── env.example
├── package.json
├── package-lock.json
├── scripts/
│   ├── create_admin.js
│   ├── criar_conquistas_padrao.js
│   ├── verificar_conquistas.js
│   ├── recalcular_estatisticas.js
│   ├── update_users_status.js
│   └── add_solicitacao_professores.js
├── routes/
│   ├── user.js
│   ├── admin.js
│   ├── auth.js
│   ├── goal.js
│   ├── achievement.js
│   └── transaction.js
├── models/
│   ├── userModel.js
│   ├── goalModel.js
│   ├── achievementModel.js
│   ├── goalRequestModel.js
│   └── transactionModel.js
├── middleware/
│   └── auth.js

lib/
├── main.dart
├── config.dart
├── config.example
├── particle_background.dart
├── widgets/
│   └── user_avatar.dart
├── services/
│   ├── user_service.dart
│   ├── notification_service.dart
│   ├── auth_service.dart
│   ├── goal_service.dart
│   ├── achievement_service.dart
│   ├── admin_service.dart
│   └── transaction_service.dart
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
│   ├── admin_aprovar_solicitacoes_metas_screen.dart
│   ├── admin_aprovar_transferencias_screen.dart
│   ├── tela_professor_criar_conta.dart
│   ├── tela_login.dart
│   ├── tela_aluno_criar_conta.dart
│   ├── primeira_tela.dart
│   ├── qr_code_ler_screen.dart
│   ├── qr_code_receber_screen.dart
│   ├── transferencia_screen.dart
│   └── historico_transacoes_screen.dart
├── models/
│   ├── user_model.dart
│   ├── goal_model.dart
│   ├── achievement_model.dart
│   └── transaction_model.dart
└── providers/
    └── auth_provider.dart
```

---

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## Equipe

- **Desenvolvedores**: Equipe IFC
- **Instituição**: Instituto Federal Catarinense
- **Disciplina**: Projeto Integrador

---

## Suporte

Para dúvidas ou problemas:
- Abra uma issue no GitHub
- Consulte a documentação da API
- Verifique os logs de erro

---

**IFC Coin** - Sistema de gamificação para instituições de ensino
