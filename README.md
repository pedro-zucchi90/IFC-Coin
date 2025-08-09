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

## 2. Configuração do Backend (Banco de Dados Local)

### 2.1 Acessando o Diretório do Backend

Primeiro, você precisa acessar o diretório onde o backend está localizado. Execute o seguinte comando no terminal:

```bash
# Entre no diretório do backend
cd backend
```

### 2.2 Instalando Dependências

Após acessar o diretório do backend, instale as dependências necessárias para o funcionamento do projeto. Utilize o comando abaixo:

```bash
# Instale as dependências
npm install
```

### 2.3 Configurando Variáveis de Ambiente

Para que o backend funcione corretamente, você precisará configurar as variáveis de ambiente. Para isso, copie o arquivo de exemplo de variáveis de ambiente e renomeie-o para `.env`:

```bash
# Copie o arquivo de exemplo de variáveis de ambiente
cp env.example .env
```

Agora, edite o arquivo `backend/.env` com suas configurações específicas. Aqui está um exemplo de como deve ser a configuração:

```env
# Configurações do Servidor
PORT=3000
NODE_ENV=development

# Configurações do MongoDB (Local)
MONGODB_URI=mongodb://127.0.0.1:27017/ifc_coin_db

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

### 2.4 Iniciando o MongoDB Local

Para que o backend funcione, o MongoDB deve estar em execução. Você pode iniciar o MongoDB usando o comando `mongod`, que é o servidor do MongoDB. Dependendo do seu sistema operacional, use um dos seguintes métodos:

#### 2.4.1 Iniciando o Servidor MongoDB

```bash
# Inicie o servidor MongoDB
mongod --dbpath /caminho/para/seu/diretorio/de/dados
```

**Nota:** Substitua `/caminho/para/seu/diretorio/de/dados` pelo caminho onde você deseja armazenar os dados do MongoDB. Se você não especificar um `--dbpath`, o MongoDB usará o diretório padrão.

#### 2.4.2 Acessando o Shell do MongoDB

Após iniciar o servidor, você pode acessar o shell interativo do MongoDB usando o comando `mongosh`:

```bash
# Acesse o shell do MongoDB
mongosh
```

No shell, você pode executar comandos para interagir com o banco de dados. Por exemplo, para verificar se o banco de dados está funcionando corretamente, você pode usar:

```javascript
// Verifique se o MongoDB está rodando
db.stats()
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
const String baseUrl = 'http://IP_DA_MAQUINA:3000/api';
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

A API do IFC Coin é uma API RESTful que utiliza JSON para comunicação e JWT para autenticação. Todos os endpoints retornam respostas em formato JSON.

### Base URL
```
http://localhost:3000/api
```

### Autenticação
A API utiliza JWT (JSON Web Tokens) para autenticação. Para endpoints protegidos, inclua o token no header:
```
Authorization: Bearer <seu_token_jwt>
```

### Códigos de Status HTTP
- `200` - Sucesso
- `201` - Criado com sucesso
- `400` - Erro de validação
- `401` - Não autorizado
- `403` - Acesso negado
- `404` - Não encontrado
- `500` - Erro interno do servidor

---

## Endpoints da API

### Autenticação (`/api/auth`)

#### POST `/api/auth/login`
Realiza login do usuário.

**Body:**
```json
{
  "matricula": "2023001",
  "senha": "senha123"
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Login realizado com sucesso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "nome": "João Silva",
    "email": "joao@email.com",
    "matricula": "2023001",
    "role": "aluno",
    "saldo": 150,
    "curso": "Informática",
    "ativo": true
  }
}
```

#### POST `/api/auth/registro`
Registra um novo usuário.

**Body:**
```json
{
  "nome": "João Silva",
  "email": "joao@email.com",
  "senha": "senha123",
  "matricula": "2023001",
  "role": "aluno",
  "curso": "Informática"
}
```

**Resposta de Sucesso (201):**
```json
{
  "message": "Usuário registrado com sucesso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "nome": "João Silva",
    "email": "joao@email.com",
    "matricula": "2023001",
    "role": "aluno",
    "saldo": 0
  }
}
```

#### POST `/api/auth/logout`
Realiza logout do usuário (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "message": "Logout realizado com sucesso"
}
```

#### GET `/api/auth/me`
Obtém dados do usuário logado (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
  "nome": "João Silva",
  "email": "joao@email.com",
  "matricula": "2023001",
  "role": "aluno",
  "saldo": 150,
  "curso": "Informática",
  "ativo": true,
  "estatisticas": {
    "transferencias": 5,
    "transferenciasRecebidas": 3,
    "metasConcluidas": 2,
    "coinsGanhos": 300,
    "diasConsecutivos": 7
  }
}
```

#### GET `/api/auth/verify`
Verifica se o token é válido (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "message": "Token válido",
  "user": { ... }
}
```

#### POST `/api/auth/refresh`
Renova o token JWT (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "message": "Token renovado com sucesso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### Usuários (`/api/user`)

#### GET `/api/user/perfil`
Obtém perfil do usuário logado (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
  "nome": "João Silva",
  "email": "joao@email.com",
  "matricula": "2023001",
  "role": "aluno",
  "saldo": 150,
  "curso": "Informática",
  "fotoPerfil": "/api/user/foto/64f1a2b3c4d5e6f7g8h9i0j1"
}
```

#### PUT `/api/user/perfil`
Atualiza dados do perfil (requer autenticação).

**Body (multipart/form-data):**
```json
{
  "nome": "João Silva Atualizado",
  "email": "joao.novo@email.com",
  "curso": "Sistemas de Informação",
  "fotoPerfil": "[arquivo de imagem]"
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Perfil atualizado com sucesso",
  "user": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "nome": "João Silva Atualizado",
    "email": "joao.novo@email.com",
    "matricula": "2023001",
    "role": "aluno",
    "saldo": 150,
    "curso": "Sistemas de Informação",
    "fotoPerfil": "/api/user/foto/64f1a2b3c4d5e6f7g8h9i0j1"
  }
}
```

#### GET `/api/user/foto/:id`
Obtém foto de perfil de um usuário.

**Resposta:** Imagem JPEG/PNG

#### GET `/api/user/saldo`
Obtém saldo do usuário logado (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "saldo": 150
}
```

#### POST `/api/user/adicionar-coins`
Adiciona coins a um usuário (requer autenticação de professor/admin).

**Body:**
```json
{
  "userId": "64f1a2b3c4d5e6f7g8h9i0j1",
  "quantidade": 50,
  "motivo": "Participação em evento"
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Coins adicionados com sucesso",
  "novoSaldo": 200
}
```

#### POST `/api/user/remover-coins`
Remove coins de um usuário (requer autenticação de admin).

**Body:**
```json
{
  "userId": "64f1a2b3c4d5e6f7g8h9i0j1",
  "quantidade": 25,
  "motivo": "Correção de erro"
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Coins removidos com sucesso",
  "novoSaldo": 175
}
```

#### GET `/api/user/listar`
Lista usuários (requer autenticação de admin).

**Query Parameters:**
- `role` - Filtrar por papel (aluno, professor, admin)
- `curso` - Filtrar por curso
- `ativo` - Filtrar por status (true/false)
- `page` - Página (padrão: 1)
- `limit` - Limite por página (padrão: 10)

**Resposta de Sucesso (200):**
```json
{
  "usuarios": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "nome": "João Silva",
      "email": "joao@email.com",
      "matricula": "2023001",
      "role": "aluno",
      "saldo": 150,
      "curso": "Informática",
      "ativo": true
    }
  ],
  "paginacao": {
    "pagina": 1,
    "limite": 10,
    "total": 25,
    "paginas": 3
  }
}
```

#### GET `/api/user/:id`
Obtém usuário específico (requer autenticação de admin).

**Resposta de Sucesso (200):**
```json
{
  "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
  "nome": "João Silva",
  "email": "joao@email.com",
  "matricula": "2023001",
  "role": "aluno",
  "saldo": 150,
  "curso": "Informática",
  "ativo": true,
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

#### PUT `/api/user/:id`
Atualiza usuário (requer autenticação de admin).

**Body:**
```json
{
  "nome": "João Silva Atualizado",
  "email": "joao.novo@email.com",
  "role": "professor",
  "curso": null,
  "turmas": ["TURMA-A", "TURMA-B"],
  "ativo": true
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Usuário atualizado com sucesso",
  "user": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "nome": "João Silva Atualizado",
    "email": "joao.novo@email.com",
    "matricula": "2023001",
    "role": "professor",
    "saldo": 150,
    "ativo": true
  }
}
```

#### DELETE `/api/user/:id`
Desativa usuário (requer autenticação de admin).

**Resposta de Sucesso (200):**
```json
{
  "message": "Usuário desativado com sucesso"
}
```

---

### Metas (`/api/goal`)

#### GET `/api/goal`
Lista metas disponíveis (requer autenticação).

**Query Parameters:**
- `tipo` - Filtrar por tipo de meta
- `page` - Página (padrão: 1)
- `limit` - Limite por página (padrão: 10)

**Resposta de Sucesso (200):**
```json
{
  "metas": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "titulo": "Participar de Workshop",
      "descricao": "Participar de pelo menos um workshop técnico",
      "tipo": "evento",
      "requisito": 1,
      "recompensa": 50,
      "requerAprovacao": true,
      "ativo": true,
      "usuarioConcluiu": false,
      "temSolicitacaoPendente": false,
      "dataInicio": "2024-01-01T00:00:00.000Z",
      "dataFim": "2024-12-31T23:59:59.000Z"
    }
  ],
  "paginacao": {
    "pagina": 1,
    "limite": 10,
    "total": 15,
    "paginas": 2
  }
}
```

#### GET `/api/goal/minhas`
Lista metas concluídas pelo usuário (requer autenticação).

**Resposta de Sucesso (200):**
```json
[
  {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "titulo": "Participar de Workshop",
    "descricao": "Participar de pelo menos um workshop técnico",
    "tipo": "evento",
    "requisito": 1,
    "recompensa": 50,
    "concluidaEm": "2024-01-15T10:30:00.000Z"
  }
]
```

#### POST `/api/goal`
Cria nova meta (requer autenticação de admin).

**Body:**
```json
{
  "titulo": "Nova Meta",
  "descricao": "Descrição da meta",
  "tipo": "evento",
  "requisito": 1,
  "recompensa": 50,
  "requerAprovacao": true,
  "maxConclusoes": 100,
  "periodoValidade": 30,
  "dataInicio": "2024-01-01T00:00:00.000Z",
  "dataFim": "2024-12-31T23:59:59.000Z",
  "evidenciaObrigatoria": true,
  "tipoEvidencia": "foto",
  "descricaoEvidencia": "Envie uma foto do evento"
}
```

**Resposta de Sucesso (201):**
```json
{
  "message": "Meta criada com sucesso",
  "meta": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "titulo": "Nova Meta",
    "descricao": "Descrição da meta",
    "tipo": "evento",
    "requisito": 1,
    "recompensa": 50,
    "requerAprovacao": true,
    "ativo": true
  }
}
```

#### POST `/api/goal/concluir/:id`
Solicita conclusão de meta (requer autenticação).

**Body (multipart/form-data):**
```json
{
  "comentario": "Participei do workshop de Flutter",
  "evidenciaTexto": "Workshop realizado no dia 15/01/2024",
  "evidenciaArquivo": "[arquivo opcional]"
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Solicitação enviada para análise!",
  "goalRequest": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "goal": "64f1a2b3c4d5e6f7g8h9i0j1",
    "aluno": "64f1a2b3c4d5e6f7g8h9i0j1",
    "comentario": "Participei do workshop de Flutter",
    "status": "pendente",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

#### GET `/api/goal/solicitacoes`
Lista solicitações de conclusão (requer autenticação de professor/admin).

**Query Parameters:**
- `status` - Filtrar por status (pendente, aprovada, recusada)

**Resposta de Sucesso (200):**
```json
[
  {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "goal": {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "titulo": "Participar de Workshop",
      "recompensa": 50
    },
    "aluno": {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "nome": "João Silva",
      "email": "joao@email.com",
      "matricula": "2023001"
    },
    "comentario": "Participei do workshop de Flutter",
    "status": "pendente",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
]
```

#### POST `/api/goal/solicitacoes/:id/aprovar`
Aprova solicitação de conclusão (requer autenticação de professor/admin).

**Body:**
```json
{
  "resposta": "Aprovado! Parabéns pela participação."
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Solicitação aprovada e coins creditados!",
  "solicitacao": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "status": "aprovada",
    "analisadoPor": "64f1a2b3c4d5e6f7g8h9i0j1",
    "dataAnalise": "2024-01-15T11:00:00.000Z",
    "resposta": "Aprovado! Parabéns pela participação."
  }
}
```

#### POST `/api/goal/solicitacoes/:id/recusar`
Recusa solicitação de conclusão (requer autenticação de professor/admin).

**Body:**
```json
{
  "resposta": "Evidência insuficiente. Tente novamente."
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Solicitação recusada.",
  "solicitacao": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "status": "recusada",
    "analisadoPor": "64f1a2b3c4d5e6f7g8h9i0j1",
    "dataAnalise": "2024-01-15T11:00:00.000Z",
    "resposta": "Evidência insuficiente. Tente novamente."
  }
}
```

#### GET `/api/goal/:id`
Obtém meta específica (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
  "titulo": "Participar de Workshop",
  "descricao": "Participar de pelo menos um workshop técnico",
  "tipo": "evento",
  "requisito": 1,
  "recompensa": 50,
  "requerAprovacao": true,
  "ativo": true,
  "usuarioConcluiu": false,
  "dataInicio": "2024-01-01T00:00:00.000Z",
  "dataFim": "2024-12-31T23:59:59.000Z"
}
```

#### PUT `/api/goal/:id`
Atualiza meta (requer autenticação de admin).

**Body:**
```json
{
  "titulo": "Meta Atualizada",
  "descricao": "Nova descrição",
  "recompensa": 75,
  "ativo": false
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Meta atualizada com sucesso",
  "meta": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "titulo": "Meta Atualizada",
    "descricao": "Nova descrição",
    "recompensa": 75,
    "ativo": false
  }
}
```

#### DELETE `/api/goal/:id`
Deleta meta (requer autenticação de admin).

**Resposta de Sucesso (200):**
```json
{
  "message": "Meta deletada com sucesso"
}
```

---

### Conquistas (`/api/achievement`)

#### GET `/api/achievement`
Lista conquistas disponíveis (requer autenticação).

**Query Parameters:**
- `tipo` - Filtrar por tipo
- `categoria` - Filtrar por categoria
- `page` - Página (padrão: 1)
- `limit` - Limite por página (padrão: 10)

**Resposta de Sucesso (200):**
```json
{
  "conquistas": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "titulo": "Primeira Transferência",
      "descricao": "Realize sua primeira transferência",
      "tipo": "transferencia",
      "categoria": "social",
      "requisito": 1,
      "icone": "🎯",
      "ativo": true
    }
  ],
  "paginacao": {
    "pagina": 1,
    "limite": 10,
    "total": 25,
    "paginas": 3
  }
}
```

#### GET `/api/achievement/categorias`
Lista categorias disponíveis (requer autenticação).

**Resposta de Sucesso (200):**
```json
["social", "academico", "especial", "transferencia", "meta"]
```

#### GET `/api/achievement/:id`
Obtém conquista específica (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
  "titulo": "Primeira Transferência",
  "descricao": "Realize sua primeira transferência",
  "tipo": "transferencia",
  "categoria": "social",
  "requisito": 1,
  "icone": "🎯",
  "ativo": true,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

#### GET `/api/achievement/usuario/conquistas`
Obtém conquistas do usuário logado (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "conquistas": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "achievement": {
        "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
        "titulo": "Primeira Transferência",
        "descricao": "Realize sua primeira transferência",
        "icone": "🎯"
      },
      "conquistadaEm": "2024-01-15T10:30:00.000Z"
    }
  ],
  "estatisticas": {
    "transferencias": 5,
    "transferenciasRecebidas": 3,
    "metasConcluidas": 2,
    "coinsGanhos": 300,
    "diasConsecutivos": 7
  }
}
```

#### POST `/api/achievement/usuario/verificar`
Verifica e adiciona conquistas automaticamente (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "message": "2 conquista(s) adicionada(s)",
  "conquistasAdicionadas": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "titulo": "Primeira Transferência",
      "icone": "🎯"
    }
  ],
  "conquistas": [...],
  "estatisticas": {...}
}
```

---

### Transações (`/api/transaction`)

#### GET `/api/transaction/historico`
Obtém histórico de transações do usuário (requer autenticação).

**Query Parameters:**
- `page` - Página (padrão: 1)
- `limit` - Limite por página (padrão: 10)

**Resposta de Sucesso (200):**
```json
{
  "transacoes": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "tipo": "enviado",
      "origem": {
        "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
        "nome": "João Silva",
        "matricula": "2023001"
      },
      "destino": {
        "_id": "64f1a2b3c4d5e6f7g8h9i0j2",
        "nome": "Maria Santos",
        "matricula": "2023002"
      },
      "quantidade": 25,
      "descricao": "Transferência entre usuários",
      "status": "aprovada",
      "hash": "abc123...",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "paginacao": {
    "pagina": 1,
    "limite": 10,
    "total": 25,
    "paginas": 3
  }
}
```

#### POST `/api/transaction/transferir`
Transfere coins entre usuários (requer autenticação).

**Body:**
```json
{
  "destinoMatricula": "2023002",
  "quantidade": 25,
  "descricao": "Transferência para Maria"
}
```

**Resposta de Sucesso (201):**
```json
{
  "message": "Transferência realizada com sucesso",
  "transacao": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "tipo": "enviado",
    "origem": {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "nome": "João Silva",
      "matricula": "2023001",
      "role": "aluno"
    },
    "destino": {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j2",
      "nome": "Maria Santos",
      "matricula": "2023002",
      "role": "aluno"
    },
    "quantidade": 25,
    "descricao": "Transferência para Maria",
    "status": "aprovada",
    "hash": "abc123...",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

#### POST `/api/transaction/recompensa`
Concede recompensa a um usuário (requer autenticação de professor/admin).

**Body:**
```json
{
  "destinoMatricula": "2023002",
  "quantidade": 50,
  "descricao": "Recompensa por participação"
}
```

**Resposta de Sucesso (201):**
```json
{
  "message": "Recompensa concedida com sucesso",
  "transacao": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "tipo": "recebido",
    "origem": {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j3",
      "nome": "Prof. Carlos",
      "matricula": "PROF001"
    },
    "destino": {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j2",
      "nome": "Maria Santos",
      "matricula": "2023002"
    },
    "quantidade": 50,
    "descricao": "Recompensa por participação",
    "hash": "reward_abc123...",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

#### GET `/api/transaction/todas`
Lista todas as transações (requer autenticação de admin).

**Query Parameters:**
- `page` - Página (padrão: 1)
- `limit` - Limite por página (padrão: 20)
- `tipo` - Filtrar por tipo (enviado, recebido)
- `origem` - Filtrar por usuário de origem
- `destino` - Filtrar por usuário de destino

**Resposta de Sucesso (200):**
```json
{
  "transacoes": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "tipo": "enviado",
      "origem": {
        "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
        "nome": "João Silva",
        "matricula": "2023001"
      },
      "destino": {
        "_id": "64f1a2b3c4d5e6f7g8h9i0j2",
        "nome": "Maria Santos",
        "matricula": "2023002"
      },
      "quantidade": 25,
      "descricao": "Transferência entre usuários",
      "status": "aprovada",
      "hash": "abc123...",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "paginacao": {
    "pagina": 1,
    "limite": 20,
    "total": 100,
    "paginas": 5
  }
}
```

#### POST `/api/transaction/:id/aprovar`
Aprova transferência pendente (requer autenticação de admin).

**Resposta de Sucesso (200):**
```json
{
  "message": "Transferência aprovada e saldo transferido!"
}
```

#### POST `/api/transaction/:id/recusar`
Recusa transferência pendente (requer autenticação de admin).

**Resposta de Sucesso (200):**
```json
{
  "message": "Transferência recusada."
}
```

#### GET `/api/transaction/:id`
Obtém transação específica (requer autenticação).

**Resposta de Sucesso (200):**
```json
{
  "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
  "tipo": "enviado",
  "origem": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "nome": "João Silva",
    "matricula": "2023001"
  },
  "destino": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j2",
    "nome": "Maria Santos",
    "matricula": "2023002"
  },
  "quantidade": 25,
  "descricao": "Transferência entre usuários",
  "status": "aprovada",
  "hash": "abc123...",
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

---

### Administração (`/api/admin`)

#### GET `/api/admin/solicitacoes-professores`
Lista solicitações de professores (requer autenticação de admin).

**Query Parameters:**
- `page` - Página (padrão: 1)
- `limit` - Limite por página (padrão: 10)
- `status` - Filtrar por status (pendente, aprovado, recusado, todas)

**Resposta de Sucesso (200):**
```json
{
  "solicitacoes": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
      "nome": "Prof. Carlos Silva",
      "email": "carlos@email.com",
      "matricula": "PROF001",
      "statusAprovacao": "pendente",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "paginacao": {
    "pagina": 1,
    "paginas": 2,
    "total": 15,
    "limite": 10
  }
}
```

#### GET `/api/admin/estatisticas-solicitacoes`
Obtém estatísticas das solicitações (requer autenticação de admin).

**Resposta de Sucesso (200):**
```json
{
  "pendentes": 5,
  "aprovados": 8,
  "recusados": 2,
  "total": 15
}
```

#### POST `/api/admin/aprovar-professor/:id`
Aprova solicitação de professor (requer autenticação de admin).

**Body:**
```json
{
  "motivo": "Professor aprovado após análise do currículo"
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Professor aprovado com sucesso",
  "professor": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "nome": "Prof. Carlos Silva",
    "email": "carlos@email.com",
    "matricula": "PROF001",
    "role": "professor",
    "statusAprovacao": "aprovado",
    "ativo": true
  }
}
```

#### POST `/api/admin/recusar-professor/:id`
Recusa solicitação de professor (requer autenticação de admin).

**Body:**
```json
{
  "motivo": "Documentação insuficiente"
}
```

**Resposta de Sucesso (200):**
```json
{
  "message": "Solicitação de professor recusada",
  "professor": {
    "_id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "nome": "Prof. Carlos Silva",
    "email": "carlos@email.com",
    "matricula": "PROF001",
    "role": "professor",
    "statusAprovacao": "recusado",
    "ativo": false
  }
}
```

---

## Modelos de Dados

### Usuário (User)
```json
{
  "_id": "ObjectId",
  "nome": "String",
  "email": "String",
  "senha": "String (hasheada)",
  "matricula": "String",
  "role": "String (aluno|professor|admin)",
  "saldo": "Number",
  "curso": "String (apenas para alunos)",
  "turmas": ["String"],
  "fotoPerfil": "String (URL)",
  "fotoPerfilBin": "Buffer",
  "ativo": "Boolean",
  "statusAprovacao": "String (pendente|aprovado|recusado)",
  "ultimoLogin": "Date",
  "estatisticas": {
    "transferencias": "Number",
    "transferenciasRecebidas": "Number",
    "metasConcluidas": "Number",
    "coinsGanhos": "Number",
    "diasConsecutivos": "Number",
    "ultimoLoginConsecutivo": "Date"
  },
  "conquistas": [
    {
      "achievement": "ObjectId",
      "conquistadaEm": "Date"
    }
  ],
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Meta (Goal)
```json
{
  "_id": "ObjectId",
  "titulo": "String",
  "descricao": "String",
  "tipo": "String",
  "requisito": "Number",
  "recompensa": "Number",
  "usuariosConcluidos": ["ObjectId"],
  "requerAprovacao": "Boolean",
  "maxConclusoes": "Number",
  "periodoValidade": "Number",
  "dataInicio": "Date",
  "dataFim": "Date",
  "evidenciaObrigatoria": "Boolean",
  "tipoEvidencia": "String (texto|foto|documento)",
  "descricaoEvidencia": "String",
  "ativo": "Boolean",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Conquista (Achievement)
```json
{
  "_id": "ObjectId",
  "titulo": "String",
  "descricao": "String",
  "tipo": "String",
  "categoria": "String",
  "requisito": "Number",
  "icone": "String",
  "ativo": "Boolean",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Transação (Transaction)
```json
{
  "_id": "ObjectId",
  "tipo": "String (enviado|recebido)",
  "origem": "ObjectId (User)",
  "destino": "ObjectId (User)",
  "quantidade": "Number",
  "descricao": "String",
  "hash": "String",
  "status": "String (aprovada|pendente|recusada)",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Solicitação de Meta (GoalRequest)
```json
{
  "_id": "ObjectId",
  "goal": "ObjectId (Goal)",
  "aluno": "ObjectId (User)",
  "comentario": "String",
  "evidenciaTexto": "String",
  "evidenciaArquivo": "String (path)",
  "status": "String (pendente|aprovada|recusada)",
  "analisadoPor": "ObjectId (User)",
  "dataAnalise": "Date",
  "resposta": "String",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

---

## Códigos de Erro Comuns

### 400 - Bad Request
```json
{
  "message": "Matrícula e senha são obrigatórias"
}
```

### 401 - Unauthorized
```json
{
  "message": "Matrícula ou senha incorretos"
}
```

### 403 - Forbidden
```json
{
  "message": "Acesso negado"
}
```

### 404 - Not Found
```json
{
  "message": "Usuário não encontrado"
}
```

### 500 - Internal Server Error
```json
{
  "message": "Erro interno do servidor"
}
```

---

## Rate Limiting

A API implementa rate limiting para proteger contra spam e abuso:
- **Limite**: 100 requisições por janela
- **Janela**: 15 minutos (900.000 ms)
- **Headers de resposta**:
  - `X-RateLimit-Limit`: Limite de requisições
  - `X-RateLimit-Remaining`: Requisições restantes
  - `X-RateLimit-Reset`: Timestamp de reset

---

## Upload de Arquivos

### Foto de Perfil
- **Endpoint**: `PUT /api/user/perfil` ou `POST /api/user/foto-perfil`
- **Tipo**: `multipart/form-data`
- **Campo**: `fotoPerfil` ou `foto`
- **Formatos**: JPEG, PNG, GIF
- **Tamanho máximo**: 5MB
- **Processamento**: Redimensionamento automático para 256x256px

### Evidências de Metas
- **Endpoint**: `POST /api/goal/concluir/:id`
- **Tipo**: `multipart/form-data`
- **Campo**: `evidenciaArquivo`
- **Formatos**: JPEG, PNG, GIF, PDF, TXT
- **Tamanho máximo**: 10MB

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

## Suporte

Para dúvidas ou problemas:
- Abra uma issue no GitHub
- Consulte a documentação da API
- Verifique os logs de erro

---

**IFC Coin** - Sistema de gamificação para instituições de ensino
