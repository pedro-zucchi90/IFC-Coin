# 🚀 Documentação Detalhada - Servidor Principal (server.js)

## 📋 Visão Geral

O arquivo `server.js` é o **ponto de entrada principal** da aplicação backend do IFC Coin. Ele configura o servidor Express, estabelece conexão com o MongoDB e registra todas as rotas da API.

---

## 🔧 Análise Linha por Linha

### **Linha 1-2: Configuração de Variáveis de Ambiente**
```javascript
// Carrega variáveis de ambiente do arquivo .env (deve ser o primeiro)
require('dotenv').config(); // <--- DEVE vir antes de tudo
```

**Explicação Detalhada:**
- `require('dotenv').config()`: Carrega as variáveis de ambiente do arquivo `.env`
- **Por que primeiro?** As outras bibliotecas podem precisar dessas variáveis
- **Variáveis carregadas:**
  - `MONGODB_URI`: URL de conexão com MongoDB
  - `JWT_SECRET`: Chave secreta para tokens JWT
  - `PORT`: Porta do servidor (padrão: 3000)

### **Linha 4-7: Importação de Bibliotecas Principais**
```javascript
const express = require('express'); // Framework web para Node.js
const mongoose = require('mongoose'); // ODM para MongoDB
const cors = require('cors'); // Middleware para habilitar CORS
const path = require('path'); // Utilitário para manipulação de caminhos
```

**Explicação Detalhada:**
- **Express**: Framework web minimalista e flexível para Node.js
  - Fornece sistema de roteamento
  - Middleware para processar requisições
  - Gerenciamento de respostas HTTP
- **Mongoose**: Object Document Mapper (ODM) para MongoDB
  - Define schemas para validação de dados
  - Fornece métodos para CRUD
  - Gerencia relacionamentos entre documentos
- **CORS**: Cross-Origin Resource Sharing
  - Permite requisições de diferentes origens
  - Necessário para frontend acessar a API
- **Path**: Utilitário nativo do Node.js
  - Manipula caminhos de arquivos de forma segura
  - Funciona em diferentes sistemas operacionais

### **Linha 9-10: Importação de Rotas**
```javascript
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
```

**Explicação Detalhada:**
- **authRoutes**: Rotas de autenticação (login, registro)
- **userRoutes**: Rotas de usuários (perfil, busca, atualização)
- **Por que separar?** Organização modular do código
- **Benefícios:**
  - Código mais limpo e organizado
  - Facilita manutenção
  - Permite reutilização

### **Linha 12-15: Importação de Modelos**
```javascript
const User = require('./models/userModel');
const Transaction = require('./models/transactionModel');
const Goal = require('./models/goalModel');
const Achievement = require('./models/achievementModel');
```

**Explicação Detalhada:**
- **User**: Modelo de usuários (alunos, professores, admins)
- **Transaction**: Modelo de transações de coins
- **Goal**: Modelo de metas dos usuários
- **Achievement**: Modelo de conquistas do sistema
- **Por que importar aqui?** Alguns middlewares podem precisar dos modelos

### **Linha 17-18: Inicialização do Express**
```javascript
const app = express();
const PORT = process.env.PORT || 3000;
```

**Explicação Detalhada:**
- **app**: Instância principal do Express
- **PORT**: Porta do servidor (do .env ou padrão 3000)
- **Express()**: Cria uma nova aplicação Express
- **process.env.PORT**: Lê a porta do arquivo .env
- **|| 3000**: Fallback se não estiver definida

### **Linha 20-26: Configuração CORS**
```javascript
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: true
}));
```

**Explicação Detalhada:**
- **origin: '*'**: Permite requisições de qualquer origem
- **methods**: Métodos HTTP permitidos
- **allowedHeaders**: Headers permitidos nas requisições
- **credentials: true**: Permite cookies e autenticação
- **Por que essa configuração?** Desenvolvimento mais flexível

### **Linha 28-29: Middleware de Parsing**
```javascript
app.use(express.json());
app.use(express.static('public'));
```

**Explicação Detalhada:**
- **express.json()**: Parse automaticamente JSON no body das requisições
- **express.static('public')**: Serve arquivos estáticos da pasta 'public'
- **Benefícios:**
  - Não precisa fazer parse manual do JSON
  - Arquivos estáticos servidos automaticamente

### **Linha 31-32: Servir Arquivos de Upload**
```javascript
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
```

**Explicação Detalhada:**
- **'/uploads'**: Rota para acessar arquivos
- **express.static()**: Middleware para servir arquivos estáticos
- **path.join(__dirname, 'uploads')**: Caminho absoluto para pasta uploads
- **__dirname**: Diretório atual do arquivo
- **Exemplo de uso:** `http://localhost:3000/uploads/foto.jpg`

### **Linha 34-42: Conexão com MongoDB**
```javascript
console.log('Tentando conectar ao MongoDB...');
mongoose.connect(process.env.MONGODB_URI)
.then(() => {
  console.log('Conectado ao MongoDB');
})
.catch((err) => {
  console.error('Erro ao conectar ao MongoDB:', err);
  process.exit(1);
});
```

**Explicação Detalhada:**
- **mongoose.connect()**: Estabelece conexão com MongoDB
- **process.env.MONGODB_URI**: URL de conexão do arquivo .env
- **.then()**: Executa quando conexão é bem-sucedida
- **.catch()**: Executa se houver erro na conexão
- **process.exit(1)**: Encerra o processo com erro
- **Por que encerrar?** Sem banco de dados, a aplicação não funciona

### **Linha 44-50: Registro de Rotas**
```javascript
app.use('/api/auth', authRoutes); // Autenticação e registro
app.use('/api/user', userRoutes); // Usuários
app.use('/api/transaction', require('./routes/transaction')); // Transações
app.use('/api/goal', require('./routes/goal')); // Metas
app.use('/api/achievement', require('./routes/achievement')); // Conquistas
app.use('/api/admin', require('./routes/admin')); // Administração
```

**Explicação Detalhada:**
- **app.use()**: Registra middleware/rotas no Express
- **'/api/auth'**: Prefixo para todas as rotas de autenticação
- **authRoutes**: Objeto com as rotas de autenticação
- **Estrutura final:**
  - `/api/auth/login` → Rota de login
  - `/api/user/profile` → Rota de perfil
  - `/api/transaction/transfer` → Rota de transferência
  - etc.

### **Linha 52-58: Rota de Health Check**
```javascript
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'API está funcionando',
    timestamp: new Date().toISOString()
  });
});
```

**Explicação Detalhada:**
- **app.get()**: Define rota GET
- **'/api/health'**: Endpoint para verificar se API está online
- **(req, res)**: Função que processa a requisição
- **req**: Objeto com dados da requisição
- **res**: Objeto para enviar resposta
- **res.json()**: Envia resposta em formato JSON
- **new Date().toISOString()**: Data atual em formato ISO

### **Linha 60-67: Middleware de Tratamento de Erros**
```javascript
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    message: 'Erro interno do servidor',
    error: process.env.NODE_ENV === 'development' ? err.message : {}
  });
});
```

**Explicação Detalhada:**
- **4 parâmetros**: Indica middleware de erro no Express
- **err**: Objeto com informações do erro
- **req, res**: Objetos de requisição e resposta
- **next**: Função para passar para próximo middleware
- **console.error(err.stack)**: Log do erro no console
- **res.status(500)**: Código de erro HTTP 500
- **process.env.NODE_ENV**: Ambiente (development/production)
- **Erro só em desenvolvimento**: Segurança em produção

### **Linha 69-72: Middleware 404 (Rota Não Encontrada)**
```javascript
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Rota não encontrada' });
});
```

**Explicação Detalhada:**
- **'*'**: Corresponde a qualquer rota não definida
- **Deve vir por último**: Captura rotas não encontradas
- **res.status(404)**: Código HTTP "Not Found"
- **Mensagem clara**: Informa que a rota não existe

### **Linha 74-77: Inicialização do Servidor**
```javascript
app.listen(3000, '0.0.0.0', () => {
  console.log('Servidor rodando na porta 3000');
  console.log('API disponível em: http://100.101.37.62:3000/api');
});
```

**Explicação Detalhada:**
- **app.listen()**: Inicia o servidor HTTP
- **3000**: Porta do servidor
- **'0.0.0.0'**: Escuta em todas as interfaces de rede
- **() => {}**: Callback executado quando servidor inicia
- **console.log()**: Mensagens informativas no console
- **Por que '0.0.0.0'?** Permite acesso externo ao servidor

---

## 🔄 Fluxo de Execução

1. **Carregamento de Variáveis** → `.env` é lido
2. **Importação de Bibliotecas** → Express, Mongoose, etc.
3. **Configuração de Middleware** → CORS, JSON parsing
4. **Conexão com Banco** → MongoDB é conectado
5. **Registro de Rotas** → Todas as rotas são registradas
6. **Inicialização** → Servidor começa a escutar

---

## 🛡️ Segurança

- **CORS configurado**: Permite requisições cross-origin
- **Erros não expostos**: Em produção, detalhes de erro são ocultados
- **Validação de entrada**: Middleware valida dados de entrada
- **Autenticação JWT**: Tokens para proteger rotas

---

## 📊 Monitoramento

- **Logs de conexão**: MongoDB e servidor
- **Health check**: Endpoint para verificar status
- **Tratamento de erros**: Logs detalhados em desenvolvimento
- **Status codes**: Respostas HTTP apropriadas

---

## 🔧 Configuração

**Arquivo .env necessário:**
```env
MONGODB_URI=mongodb://localhost:27017/ifc_coin
JWT_SECRET=sua_chave_secreta_aqui
PORT=3000
NODE_ENV=development
```

**Dependências no package.json:**
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  }
}
```

---

Esta documentação fornece uma análise completa e detalhada do servidor principal, explicando cada linha de código, sua função e como ela contribui para o funcionamento geral da aplicação.
# 👤 Documentação Detalhada - Modelo de Usuário (userModel.js)

## 📋 Visão Geral

O arquivo `userModel.js` define o **esquema do usuário** no MongoDB usando Mongoose. Este é o modelo mais complexo do sistema, pois gerencia todos os tipos de usuários (alunos, professores, admins) e suas funcionalidades relacionadas.

---

## 🔧 Análise Detalhada do Schema

### **Linha 1-2: Importações**
```javascript
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
```

**Explicação Detalhada:**
- **mongoose**: ODM para MongoDB, fornece funcionalidades de schema
- **bcryptjs**: Biblioteca para criptografia de senhas
  - **Por que bcrypt?** Algoritmo seguro e lento para hash de senhas
  - **Salt**: Valor aleatório adicionado ao hash para maior segurança

### **Linha 4-5: Definição do Schema**
```javascript
const userSchema = new mongoose.Schema({
    // ... campos do schema
}, { timestamps: true });
```

**Explicação Detalhada:**
- **mongoose.Schema()**: Cria um novo schema do Mongoose
- **timestamps: true**: Adiciona automaticamente `createdAt` e `updatedAt`
- **Benefícios dos timestamps:**
  - Rastreamento de quando o usuário foi criado
  - Controle de quando foi atualizado pela última vez

---

## 📊 Campos do Schema - Análise Detalhada

### **Campo: nome**
```javascript
nome: {
    type: String,
    required: [true, 'Nome é obrigatório'],
    trim: true
}
```

**Explicação Detalhada:**
- **type: String**: Define o tipo do campo como string
- **required: [true, 'Nome é obrigatório']**: 
  - `true`: Campo obrigatório
  - `'Nome é obrigatório'`: Mensagem de erro personalizada
- **trim: true**: Remove espaços em branco no início e fim
- **Validação**: Mongoose valida automaticamente antes de salvar

### **Campo: email**
```javascript
email: { 
    type: String, 
    unique: true,
    required: [true, 'Email é obrigatório'],
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Email inválido']
}
```

**Explicação Detalhada:**
- **unique: true**: Garante que não existam emails duplicados
- **lowercase: true**: Converte email para minúsculas automaticamente
- **trim: true**: Remove espaços em branco
- **match**: Regex para validar formato de email
  - `^\w+`: Começa com letras/números
  - `([.-]?\w+)*`: Pode ter pontos ou hífens
  - `@\w+`: Deve ter @ seguido de letras/números
  - `(\.\w{2,3})+$`: Deve terminar com domínio válido

### **Campo: senha**
```javascript
senha: {
    type: String,
    required: [true, 'Senha é obrigatória'],
    minlength: [6, 'Senha deve ter pelo menos 6 caracteres']
}
```

**Explicação Detalhada:**
- **required**: Campo obrigatório
- **minlength: [6, 'Senha deve ter pelo menos 6 caracteres']**:
  - `6`: Mínimo de 6 caracteres
  - `'Senha deve ter pelo menos 6 caracteres'`: Mensagem de erro
- **Segurança**: Senha será hasheada antes de salvar (ver middleware)

### **Campo: matricula**
```javascript
matricula: { 
    type: String, 
    unique: true,
    required: [true, 'Matrícula é obrigatória'],
    trim: true
}
```

**Explicação Detalhada:**
- **unique: true**: Cada matrícula deve ser única no sistema
- **trim: true**: Remove espaços em branco
- **Identificação**: Usada como identificador único do usuário

### **Campo: role**
```javascript
role: { 
    type: String, 
    enum: ['aluno', 'professor', 'admin'], 
    default: 'aluno'
}
```

**Explicação Detalhada:**
- **enum**: Lista de valores permitidos
- **['aluno', 'professor', 'admin']**: Tipos de usuário no sistema
- **default: 'aluno'**: Valor padrão se não especificado
- **Controle de acesso**: Define permissões do usuário

### **Campo: statusAprovacao**
```javascript
statusAprovacao: {
    type: String,
    enum: ['pendente', 'aprovado', 'recusado'],
    default: function() {
        return this.role === 'professor' ? 'pendente' : 'aprovado';
    }
}
```

**Explicação Detalhada:**
- **enum**: Estados possíveis de aprovação
- **default: function()**: Função que retorna valor padrão
- **Lógica**: Professores começam como 'pendente', outros como 'aprovado'
- **this.role**: Acessa o campo 'role' do documento atual

### **Campo: curso**
```javascript
curso: { 
    type: String, 
    enum: ['Engenharia de Alimentos', 'Agropecuária', 'Informática para Internet'],
    required: function() {
        return this.role === 'aluno';
    }
}
```

**Explicação Detalhada:**
- **enum**: Lista de cursos disponíveis
- **required: function()**: Função que determina se é obrigatório
- **Lógica**: Curso é obrigatório apenas para alunos
- **Validação condicional**: Baseada no campo 'role'

### **Campo: saldo**
```javascript
saldo: { 
    type: Number, 
    default: 0,
    min: [0, 'Saldo não pode ser negativo']
}
```

**Explicação Detalhada:**
- **type: Number**: Campo numérico
- **default: 0**: Saldo inicial zero
- **min: [0, 'Saldo não pode ser negativo']**: Valor mínimo permitido
- **Coins**: Representa a moeda virtual do sistema

### **Campo: fotoPerfil**
```javascript
fotoPerfil: { 
    type: String, 
    default: '' 
}
```

**Explicação Detalhada:**
- **type: String**: URL ou caminho da foto
- **default: ''**: String vazia se não houver foto
- **Armazenamento**: Pode ser URL ou caminho local

### **Campo: fotoPerfilBin**
```javascript
fotoPerfilBin: {
    type: Buffer,
    select: false
}
```

**Explicação Detalhada:**
- **type: Buffer**: Armazena dados binários da imagem
- **select: false**: Não retorna por padrão nas consultas
- **Performance**: Evita carregar dados binários desnecessariamente
- **Segurança**: Dados sensíveis não são expostos automaticamente

### **Campo: ultimoLogin**
```javascript
ultimoLogin: {
    type: Date,
    default: Date.now
}
```

**Explicação Detalhada:**
- **type: Date**: Campo de data/hora
- **default: Date.now**: Data atual como padrão
- **Rastreamento**: Monitora atividade do usuário

### **Campo: ativo**
```javascript
ativo: {
    type: Boolean,
    default: true
}
```

**Explicação Detalhada:**
- **type: Boolean**: Campo verdadeiro/falso
- **default: true**: Usuário ativo por padrão
- **Soft delete**: Permite desativar sem deletar

---

## 🏆 Campo: conquistas (Array Complexo)

```javascript
conquistas: [{
    achievement: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Achievement'
    },
    dataConquista: {
        type: Date,
        default: Date.now
    }
}]
```

**Explicação Detalhada:**
- **conquistas: []**: Array de conquistas do usuário
- **achievement**: Referência para documento Achievement
  - **mongoose.Schema.Types.ObjectId**: ID único do MongoDB
  - **ref: 'Achievement'**: Referência para modelo Achievement
- **dataConquista**: Data quando a conquista foi obtida
- **Populate**: Permite carregar dados completos da conquista

---

## 📊 Campo: estatisticas (Objeto Complexo)

```javascript
estatisticas: {
    totalTransferencias: { type: Number, default: 0 },
    totalTransferenciasRecebidas: { type: Number, default: 0 },
    totalMetasConcluidas: { type: Number, default: 0 },
    totalCoinsGanhos: { type: Number, default: 0 },
    diasConsecutivos: { type: Number, default: 0 },
    ultimoLoginConsecutivo: { type: Date, default: Date.now },
    temFotoPerfil: { type: Boolean, default: false }
}
```

**Explicação Detalhada:**
- **totalTransferencias**: Contador de transferências enviadas
- **totalTransferenciasRecebidas**: Contador de transferências recebidas
- **totalMetasConcluidas**: Contador de metas completadas
- **totalCoinsGanhos**: Total de coins ganhos (não saldo atual)
- **diasConsecutivos**: Sequência de logins consecutivos
- **ultimoLoginConsecutivo**: Data do último login para calcular sequência
- **temFotoPerfil**: Flag se usuário tem foto de perfil

---

## 🔧 Middleware de Hash de Senha

```javascript
userSchema.pre('save', async function(next) {
    if (!this.isModified('senha')) return next();
    
    try {
        const salt = await bcrypt.genSalt(12);
        this.senha = await bcrypt.hash(this.senha, salt);
        next();
    } catch (error) {
        next(error);
    }
});
```

**Explicação Detalhada:**
- **pre('save')**: Middleware executado ANTES de salvar
- **this.isModified('senha')**: Verifica se senha foi alterada
- **bcrypt.genSalt(12)**: Gera salt com 12 rounds (segurança)
- **bcrypt.hash()**: Cria hash da senha com salt
- **next()**: Passa para próximo middleware
- **next(error)**: Passa erro para tratamento

---

## 🔐 Métodos de Instância

### **Método: compararSenha**
```javascript
userSchema.methods.compararSenha = async function(senhaCandidata) {
    return await bcrypt.compare(senhaCandidata, this.senha);
};
```

**Explicação Detalhada:**
- **methods**: Define método de instância
- **compararSenha**: Nome do método
- **senhaCandidata**: Senha fornecida pelo usuário
- **bcrypt.compare()**: Compara senha com hash armazenado
- **Retorna**: true se senha correta, false caso contrário

### **Método: adicionarCoins**
```javascript
userSchema.methods.adicionarCoins = function(quantidade) {
    if (quantidade > 0) {
        this.saldo += quantidade;
        return this.save();
    }
    throw new Error('Quantidade deve ser positiva');
};
```

**Explicação Detalhada:**
- **Validação**: Verifica se quantidade é positiva
- **this.saldo += quantidade**: Adiciona ao saldo atual
- **this.save()**: Salva alterações no banco
- **throw new Error()**: Lança erro se quantidade inválida

### **Método: removerCoins**
```javascript
userSchema.methods.removerCoins = function(quantidade) {
    if (quantidade > 0) {
        if (this.role === 'admin' || this.role === 'professor') {
            this.saldo = Math.max(0, this.saldo - quantidade);
            return this.save();
        }
        if (this.saldo >= quantidade) {
            this.saldo -= quantidade;
            return this.save();
        }
    }
    throw new Error('Saldo insuficiente ou quantidade inválida');
};
```

**Explicação Detalhada:**
- **Validação**: Verifica se quantidade é positiva
- **Lógica especial**: Admin/professor nunca ficam negativos
- **Math.max(0, ...)**: Garante saldo mínimo zero
- **Verificação de saldo**: Alunos precisam ter saldo suficiente
- **Erro**: Lança erro se saldo insuficiente

### **Método: atualizarUltimoLogin**
```javascript
userSchema.methods.atualizarUltimoLogin = function() {
    this.ultimoLogin = new Date();
    return this.save();
};
```

**Explicação Detalhada:**
- **new Date()**: Data/hora atual
- **this.ultimoLogin**: Atualiza campo de último login
- **this.save()**: Persiste alteração no banco

### **Método: adicionarConquista**
```javascript
userSchema.methods.adicionarConquista = async function(achievementId) {
    const jaTemConquista = this.conquistas.some(c => 
        c.achievement.toString() === achievementId.toString()
    );
    if (!jaTemConquista) {
        this.conquistas.push({
            achievement: achievementId,
            dataConquista: new Date()
        });
        await this.save();
        return true;
    }
    return false;
};
```

**Explicação Detalhada:**
- **achievementId**: ID da conquista a ser adicionada
- **some()**: Verifica se já existe a conquista
- **toString()**: Converte ObjectId para string para comparação
- **push()**: Adiciona nova conquista ao array
- **new Date()**: Data atual da conquista
- **Retorna**: true se adicionada, false se já existia

---

## 🏆 Método: verificarConquistas (Método Principal)

Este é o método mais complexo do modelo, responsável por verificar e adicionar conquistas automaticamente.

### **Estrutura Geral**
```javascript
userSchema.methods.verificarConquistas = async function() {
    const Achievement = require('./achievementModel');
    const conquistasAdicionadas = [];
    const todasConquistas = await Achievement.find({});
    
    for (const conquista of todasConquistas) {
        // Lógica de verificação
    }
    
    return conquistasAdicionadas;
};
```

### **Verificação de Conquistas por Tipo**

#### **Transferências Enviadas**
```javascript
case 'primeira_transferencia':
    if (this.estatisticas.totalTransferencias >= 1) {
        deveAdicionar = true;
    }
    break;
```

**Explicação Detalhada:**
- **Verifica**: Se usuário fez pelo menos 1 transferência
- **totalTransferencias**: Contador de transferências enviadas
- **>= 1**: Condição para primeira transferência

#### **Transferências Recebidas**
```javascript
case 'recebidas_10':
    if (this.estatisticas.totalTransferenciasRecebidas >= 10) {
        deveAdicionar = true;
    }
    break;
```

**Explicação Detalhada:**
- **Verifica**: Se usuário recebeu pelo menos 10 transferências
- **totalTransferenciasRecebidas**: Contador específico de recebimentos

#### **Metas Concluídas**
```javascript
case 'metas_50':
    if (this.estatisticas.totalMetasConcluidas >= 50) {
        deveAdicionar = true;
    }
    break;
```

**Explicação Detalhada:**
- **Verifica**: Se usuário concluiu pelo menos 50 metas
- **totalMetasConcluidas**: Contador de metas completadas

#### **Coins Acumulados**
```javascript
case 'coins_1000':
    if (this.estatisticas.totalCoinsGanhos >= 1000) {
        deveAdicionar = true;
    }
    break;
```

**Explicação Detalhada:**
- **Verifica**: Se usuário ganhou pelo menos 1000 coins
- **totalCoinsGanhos**: Total histórico de coins ganhos (não saldo atual)

#### **Frequência de Login**
```javascript
case 'login_consecutivo_30':
    if (this.estatisticas.diasConsecutivos >= 30) {
        deveAdicionar = true;
    }
    break;
```

**Explicação Detalhada:**
- **Verifica**: Se usuário fez login por 30 dias consecutivos
- **diasConsecutivos**: Contador de dias seguidos de login

#### **Foto de Perfil**
```javascript
case 'foto_perfil':
    if (this.estatisticas.temFotoPerfil) {
        deveAdicionar = true;
    }
    break;
```

**Explicação Detalhada:**
- **Verifica**: Se usuário adicionou foto de perfil
- **temFotoPerfil**: Flag booleana

#### **Conquistas Sociais**
```javascript
case 'equilibrado':
    if (this.estatisticas.totalTransferencias >= 10 && 
        this.estatisticas.totalTransferenciasRecebidas >= 10) {
        deveAdicionar = true;
    }
    break;
```

**Explicação Detalhada:**
- **Verifica**: Se usuário enviou E recebeu pelo menos 10 transferências
- **Condição dupla**: Precisa atender ambos os critérios

---

## 📊 Método: atualizarEstatisticas

```javascript
userSchema.methods.atualizarEstatisticas = function(tipo, valor = 1) {
    switch (tipo) {
        case 'transferencia':
            this.estatisticas.totalTransferencias += valor;
            break;
        case 'transferencia_recebida':
            this.estatisticas.totalTransferenciasRecebidas += valor;
            break;
        case 'meta_concluida':
            this.estatisticas.totalMetasConcluidas += valor;
            break;
        case 'coins_ganhos':
            this.estatisticas.totalCoinsGanhos += valor;
            break;
        case 'login_consecutivo':
            this.estatisticas.diasConsecutivos = valor;
            this.estatisticas.ultimoLoginConsecutivo = new Date();
            break;
        case 'foto_perfil':
            this.estatisticas.temFotoPerfil = true;
            break;
    }
    return this.save();
};
```

**Explicação Detalhada:**
- **tipo**: Identifica qual estatística atualizar
- **valor**: Quantidade a adicionar (padrão: 1)
- **switch**: Seleciona estatística baseada no tipo
- **+= valor**: Adiciona valor à estatística atual
- **this.save()**: Persiste alterações no banco

---

## 🔒 Método: toPublicJSON

```javascript
userSchema.methods.toPublicJSON = function() {
    const userObject = this.toObject();
    delete userObject.senha;
    delete userObject.fotoPerfilBin;
    return userObject;
};
```

**Explicação Detalhada:**
- **this.toObject()**: Converte documento Mongoose para objeto JavaScript
- **delete userObject.senha**: Remove senha do objeto
- **delete userObject.fotoPerfilBin**: Remove dados binários da foto
- **Segurança**: Evita expor dados sensíveis na API

---

## ⚡ Índices para Performance

```javascript
userSchema.index({ role: 1 });
userSchema.index({ ativo: 1 });
```

**Explicação Detalhada:**
- **role: 1**: Índice crescente no campo role
- **ativo: 1**: Índice crescente no campo ativo
- **Performance**: Acelera consultas por role e status
- **1**: Ordem crescente (ascending)

---

## 📤 Exportação do Modelo

```javascript
module.exports = mongoose.model('User', userSchema);
```

**Explicação Detalhada:**
- **mongoose.model()**: Cria modelo a partir do schema
- **'User'**: Nome do modelo (usado em referências)
- **userSchema**: Schema definido anteriormente
- **module.exports**: Disponibiliza modelo para importação

---

## 🔄 Fluxo de Uso do Modelo

1. **Criação**: `new User({...})` → Middleware hash → Salva
2. **Login**: `findOne()` → `compararSenha()` → `atualizarUltimoLogin()`
3. **Transação**: `removerCoins()` → `adicionarCoins()` → `atualizarEstatisticas()`
4. **Conquistas**: `verificarConquistas()` → `adicionarConquista()`
5. **API**: `toPublicJSON()` → Remove dados sensíveis

---

## 🛡️ Segurança Implementada

- **Hash de senha**: bcrypt com salt de 12 rounds
- **Validação de entrada**: Regex para email, tamanho mínimo para senha
- **Dados sensíveis**: Senha e foto binária não expostas
- **Validação condicional**: Campos obrigatórios baseados no role
- **Índices**: Performance otimizada para consultas frequentes

---

Esta documentação fornece uma análise completa e detalhada do modelo de usuário, explicando cada campo, método e funcionalidade de segurança implementada.
# 🔐 Documentação Detalhada - Rotas de Autenticação (auth.js)

## 📋 Visão Geral

O arquivo `auth.js` gerencia todas as operações de **autenticação e autorização** do sistema IFC Coin. Ele controla login, registro, validação de tokens e controle de acesso baseado em roles.

---

## 🔧 Análise Detalhada das Importações

### **Linha 1-5: Importações Principais**
```javascript
const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const { verificarToken } = require('../middleware/auth');

const router = express.Router();
```

**Explicação Detalhada:**
- **express**: Framework web para criar rotas
- **jsonwebtoken**: Biblioteca para criar e verificar tokens JWT
- **User**: Modelo de usuário importado
- **verificarToken**: Middleware de autenticação
- **express.Router()**: Cria um router para agrupar rotas relacionadas

---

## 🔑 Função: gerarToken

### **Linha 7-13: Geração de Token JWT**
```javascript
const gerarToken = (userId, role) => {
    return jwt.sign(
        { userId, role },
        process.env.JWT_SECRET,
        { expiresIn: '7d' } // Token expira em 7 dias
    );
};
```

**Explicação Detalhada:**
- **jwt.sign()**: Cria um token JWT
- **{ userId, role }**: Payload do token (dados do usuário)
- **process.env.JWT_SECRET**: Chave secreta para assinar o token
- **expiresIn: '7d'**: Token expira em 7 dias
- **Por que 7 dias?** Equilibra segurança com conveniência do usuário

---

## 🔐 Rota: POST /api/auth/login

### **Linha 15-25: Validação de Entrada**
```javascript
router.post('/login', async (req, res) => {
    try {
        const { matricula, senha } = req.body;

        // Validação dos campos
        if (!matricula || !senha) {
            return res.status(400).json({
                message: 'Matrícula e senha são obrigatórias'
            });
        }
```

**Explicação Detalhada:**
- **router.post()**: Define rota POST
- **'/login'**: Endpoint para autenticação
- **async (req, res)**: Função assíncrona que processa requisição
- **req.body**: Dados enviados no corpo da requisição
- **Destructuring**: Extrai matricula e senha do body
- **Validação**: Verifica se campos obrigatórios foram fornecidos
- **res.status(400)**: Código HTTP "Bad Request"
- **return**: Para execução se validação falhar

### **Linha 27-35: Busca do Usuário**
```javascript
// Buscar usuário pela matrícula
const user = await User.findOne({ matricula: matricula.trim() });

if (!user) {
    return res.status(401).json({
        message: 'Matrícula ou senha incorretos'
    });
}
```

**Explicação Detalhada:**
- **User.findOne()**: Busca usuário no banco de dados
- **{ matricula: matricula.trim() }**: Filtro por matrícula
- **trim()**: Remove espaços em branco da matrícula
- **await**: Aguarda resultado da consulta assíncrona
- **if (!user)**: Verifica se usuário foi encontrado
- **Mensagem genérica**: "Matrícula ou senha incorretos" por segurança
- **401**: Código HTTP "Unauthorized"

### **Linha 37-43: Verificação de Status Ativo**
```javascript
// Verificar se o usuário está ativo
if (!user.ativo) {
    return res.status(401).json({
        message: 'Conta desativada. Entre em contato com o administrador.'
    });
}
```

**Explicação Detalhada:**
- **user.ativo**: Campo booleano que indica se conta está ativa
- **Soft delete**: Usuário não é deletado, apenas desativado
- **Mensagem clara**: Orienta usuário sobre como proceder
- **401**: Código HTTP "Unauthorized"

### **Linha 45-75: Controle de Aprovação para Professores**
```javascript
// Verificar status de aprovação para professores
if (user.role === 'professor') {
    if (user.statusAprovacao === 'pendente') {
        return res.status(401).json({
            message: 'Sua conta está aguardando aprovação de um administrador.'
        });
    } else if (user.statusAprovacao === 'recusado') {
        return res.status(401).json({
            message: 'Sua solicitação de cadastro foi recusada. Entre em contato com o administrador.'
        });
    } else if (user.statusAprovacao === 'aprovado') {
        const showApprovalNotification = !user.ultimoLogin || 
            (user.ultimoLogin < user.updatedAt && user.updatedAt > user.createdAt);
        
        // Atualizar último login
        await user.atualizarUltimoLogin();
        
        // Gerar token JWT
        const token = gerarToken(user._id, user.role);
        
        // Adicionar flag para mostrar notificação de aprovação apenas na primeira vez
        return res.json({
            message: 'Login realizado com sucesso',
            token,
            user: user.toPublicJSON(),
            showApprovalNotification: showApprovalNotification
        });
    }
}
```

**Explicação Detalhada:**
- **user.role === 'professor'**: Verifica se é professor
- **statusAprovacao**: Campo que controla aprovação de professores
- **'pendente'**: Aguardando aprovação do admin
- **'recusado'**: Solicitação foi negada
- **'aprovado'**: Professor pode fazer login
- **showApprovalNotification**: Flag para mostrar notificação de aprovação
- **Lógica da notificação**: 
  - `!user.ultimoLogin`: Primeiro login
  - `user.ultimoLogin < user.updatedAt`: Login após atualização
  - `user.updatedAt > user.createdAt`: Houve atualização após criação
- **user.atualizarUltimoLogin()**: Método do modelo para atualizar último login
- **gerarToken()**: Função para criar token JWT
- **user.toPublicJSON()**: Remove dados sensíveis do usuário

### **Linha 77-85: Verificação de Senha**
```javascript
// Verificar senha
const senhaValida = await user.compararSenha(senha);
if (!senhaValida) {
    return res.status(401).json({
        message: 'Senha incorreta'
    });
}
```

**Explicação Detalhada:**
- **user.compararSenha()**: Método do modelo que compara senha com hash
- **await**: Aguarda resultado da comparação assíncrona
- **senhaValida**: Boolean que indica se senha está correta
- **Mensagem genérica**: Por segurança, não diferencia entre usuário inexistente e senha incorreta

### **Linha 87-105: Atualização de Estatísticas e Login**
```javascript
// Atualizar último login
await user.atualizarUltimoLogin();

// Atualizar estatísticas de login consecutivo
const hoje = new Date();
const ultimoLogin = user.estatisticas.ultimoLoginConsecutivo;
let diasConsecutivos = user.estatisticas.diasConsecutivos || 0;

if (ultimoLogin) {
    const diffTime = hoje.getTime() - ultimoLogin.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 1) {
        // Login consecutivo
        diasConsecutivos++;
    } else if (diffDays > 1) {
        // Quebrou a sequência
        diasConsecutivos = 1;
    }
} else {
    // Primeiro login
    diasConsecutivos = 1;
}
```

**Explicação Detalhada:**
- **user.atualizarUltimoLogin()**: Atualiza campo de último login
- **new Date()**: Data/hora atual
- **user.estatisticas.ultimoLoginConsecutivo**: Data do último login para calcular sequência
- **user.estatisticas.diasConsecutivos**: Contador de dias consecutivos
- **getTime()**: Converte data para milissegundos
- **diffTime**: Diferença em milissegundos entre hoje e último login
- **Math.ceil()**: Arredonda para cima (considera login no mesmo dia como 1 dia)
- **1000 * 60 * 60 * 24**: Converte milissegundos para dias
- **diffDays === 1**: Login no dia seguinte (consecutivo)
- **diffDays > 1**: Quebrou a sequência
- **diasConsecutivos = 1**: Primeiro login ou sequência quebrada

### **Linha 107-115: Atualização de Estatísticas e Geração de Token**
```javascript
// Atualizar estatísticas
await user.atualizarEstatisticas('login_consecutivo', diasConsecutivos);

// Gerar token JWT
const token = gerarToken(user._id, user.role);

// Retornar resposta de sucesso
res.json({
    message: 'Login realizado com sucesso',
    token,
    user: user.toPublicJSON()
});
```

**Explicação Detalhada:**
- **user.atualizarEstatisticas()**: Método do modelo para atualizar estatísticas
- **'login_consecutivo'**: Tipo de estatística a atualizar
- **diasConsecutivos**: Valor a ser definido
- **gerarToken()**: Cria token JWT com ID e role do usuário
- **user.toPublicJSON()**: Remove dados sensíveis (senha, foto binária)
- **res.json()**: Envia resposta em formato JSON

### **Linha 117-122: Tratamento de Erros**
```javascript
} catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({
        message: 'Erro interno do servidor'
    });
}
```

**Explicação Detalhada:**
- **catch (error)**: Captura qualquer erro que ocorra no try
- **console.error()**: Log do erro para debugging
- **res.status(500)**: Código HTTP "Internal Server Error"
- **Mensagem genérica**: Não expõe detalhes do erro por segurança

---

## 📝 Rota: POST /api/auth/register

### **Linha 124-140: Validação de Entrada**
```javascript
router.post('/register', async (req, res) => {
    try {
        const { nome, email, senha, matricula, role, curso } = req.body;

        // Validação dos campos obrigatórios
        if (!nome || !email || !senha || !matricula || !role) {
            return res.status(400).json({
                message: 'Todos os campos obrigatórios devem ser preenchidos'
            });
        }

        // Validação específica para alunos
        if (role === 'aluno' && !curso) {
            return res.status(400).json({
                message: 'Curso é obrigatório para alunos'
            });
        }
```

**Explicação Detalhada:**
- **Destructuring**: Extrai todos os campos do body
- **Validação geral**: Verifica campos obrigatórios para todos
- **Validação específica**: Curso é obrigatório apenas para alunos
- **role === 'aluno'**: Verifica se é aluno
- **400**: Código HTTP "Bad Request" para dados inválidos

### **Linha 142-150: Verificação de Duplicatas**
```javascript
// Verificar se já existe usuário com mesmo email ou matrícula
const userExists = await User.findOne({
    $or: [
        { email: email.toLowerCase().trim() },
        { matricula: matricula.trim() }
    ]
});

if (userExists) {
    return res.status(400).json({
        message: 'Usuário já existe com este email ou matrícula'
    });
}
```

**Explicação Detalhada:**
- **User.findOne()**: Busca usuário no banco
- **$or**: Operador MongoDB para "OU"
- **email.toLowerCase().trim()**: Normaliza email (minúsculas, sem espaços)
- **matricula.trim()**: Remove espaços da matrícula
- **userExists**: Verifica se encontrou usuário duplicado
- **400**: Código HTTP "Bad Request" para dados duplicados

### **Linha 152-165: Criação do Usuário**
```javascript
// Criar novo usuário
const newUser = new User({
    nome: nome.trim(),
    email: email.toLowerCase().trim(),
    senha: senha,
    matricula: matricula.trim(),
    role: role,
    curso: role === 'aluno' ? curso : undefined
});

await newUser.save();
```

**Explicação Detalhada:**
- **new User()**: Cria nova instância do modelo
- **trim()**: Remove espaços em branco dos campos
- **toLowerCase()**: Converte email para minúsculas
- **role === 'aluno' ? curso : undefined**: Curso apenas para alunos
- **await newUser.save()**: Salva usuário no banco
- **Middleware**: Hash da senha é executado automaticamente

### **Linha 167-175: Geração de Token e Resposta**
```javascript
// Gerar token JWT
const token = gerarToken(newUser._id, newUser.role);

// Retornar resposta de sucesso
res.status(201).json({
    message: 'Usuário criado com sucesso',
    token,
    user: newUser.toPublicJSON()
});
```

**Explicação Detalhada:**
- **gerarToken()**: Cria token JWT para o novo usuário
- **newUser._id**: ID único do usuário criado
- **newUser.role**: Role do usuário
- **res.status(201)**: Código HTTP "Created"
- **newUser.toPublicJSON()**: Remove dados sensíveis da resposta

### **Linha 177-182: Tratamento de Erros**
```javascript
} catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({
        message: 'Erro interno do servidor'
    });
}
```

**Explicação Detalhada:**
- **catch (error)**: Captura erros do try
- **console.error()**: Log para debugging
- **500**: Código HTTP "Internal Server Error"

---

## 🔍 Rota: GET /api/auth/me

### **Linha 184-200: Verificação de Token e Retorno de Dados**
```javascript
router.get('/me', verificarToken, async (req, res) => {
    try {
        // Buscar usuário pelo ID do token
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        // Verificar se usuário está ativo
        if (!user.ativo) {
            return res.status(401).json({
                message: 'Conta desativada'
            });
        }

        res.json({
            user: user.toPublicJSON()
        });
    } catch (error) {
        console.error('Erro ao buscar usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação Detalhada:**
- **verificarToken**: Middleware que valida o token JWT
- **req.user._id**: ID do usuário extraído do token
- **User.findById()**: Busca usuário pelo ID
- **404**: Código HTTP "Not Found" se usuário não existe
- **user.ativo**: Verifica se conta está ativa
- **401**: Código HTTP "Unauthorized" se conta desativada
- **user.toPublicJSON()**: Remove dados sensíveis

---

## 🔄 Rota: POST /api/auth/refresh

### **Linha 202-220: Renovação de Token**
```javascript
router.post('/refresh', verificarToken, async (req, res) => {
    try {
        // Buscar usuário atual
        const user = await User.findById(req.user._id);
        
        if (!user || !user.ativo) {
            return res.status(401).json({
                message: 'Usuário não encontrado ou inativo'
            });
        }

        // Gerar novo token
        const newToken = gerarToken(user._id, user.role);

        res.json({
            message: 'Token renovado com sucesso',
            token: newToken,
            user: user.toPublicJSON()
        });
    } catch (error) {
        console.error('Erro ao renovar token:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação Detalhada:**
- **verificarToken**: Middleware que valida token atual
- **User.findById()**: Busca usuário pelo ID do token
- **user.ativo**: Verifica se conta está ativa
- **gerarToken()**: Cria novo token com mesma duração
- **newToken**: Token renovado com nova data de expiração

---

## 🚪 Rota: POST /api/auth/logout

### **Linha 222-230: Logout (Simulado)**
```javascript
router.post('/logout', verificarToken, async (req, res) => {
    try {
        // Em um sistema real, você poderia invalidar o token
        // Por enquanto, apenas retorna sucesso
        res.json({
            message: 'Logout realizado com sucesso'
        });
    } catch (error) {
        console.error('Erro no logout:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação Detalhada:**
- **verificarToken**: Valida token antes do logout
- **Logout simulado**: JWT é stateless, então invalidação seria no frontend
- **Sistema real**: Poderia usar blacklist de tokens ou Redis
- **200**: Código HTTP "OK" para logout bem-sucedido

---

## 📤 Exportação do Router

### **Linha 232: Exportação**
```javascript
module.exports = router;
```

**Explicação Detalhada:**
- **module.exports**: Disponibiliza router para importação
- **router**: Objeto com todas as rotas de autenticação
- **Uso**: Importado no server.js como authRoutes

---

## 🔄 Fluxo de Autenticação

### **1. Registro de Usuário**
```
POST /api/auth/register
↓
Validação de campos
↓
Verificação de duplicatas
↓
Criação do usuário (hash automático da senha)
↓
Geração de token JWT
↓
Resposta com dados do usuário
```

### **2. Login de Usuário**
```
POST /api/auth/login
↓
Validação de campos
↓
Busca do usuário por matrícula
↓
Verificação de status ativo
↓
Verificação de aprovação (professores)
↓
Comparação de senha
↓
Atualização de estatísticas
↓
Geração de token JWT
↓
Resposta com dados do usuário
```

### **3. Verificação de Token**
```
GET /api/auth/me
↓
Middleware verificarToken
↓
Extração de dados do token
↓
Busca do usuário no banco
↓
Verificação de status ativo
↓
Retorno dos dados do usuário
```

---

## 🛡️ Segurança Implementada

### **1. Hash de Senhas**
- **bcrypt**: Algoritmo seguro e lento
- **Salt**: Valor aleatório para maior segurança
- **12 rounds**: Configuração de segurança alta

### **2. Tokens JWT**
- **Payload**: userId e role do usuário
- **Expiração**: 7 dias
- **Assinatura**: Chave secreta do servidor

### **3. Validação de Entrada**
- **Campos obrigatórios**: Validação antes do processamento
- **Normalização**: Email em minúsculas, trim de espaços
- **Verificação de duplicatas**: Email e matrícula únicos

### **4. Controle de Acesso**
- **Status ativo**: Usuários podem ser desativados
- **Aprovação de professores**: Sistema de aprovação manual
- **Roles**: Diferentes níveis de acesso

### **5. Mensagens de Erro**
- **Genéricas**: Não revelam informações sensíveis
- **Específicas**: Quando apropriado (campos obrigatórios)
- **Logs**: Erros registrados para debugging

---

## 📊 Códigos de Status HTTP

- **200**: Sucesso (login, logout, me)
- **201**: Criado (registro)
- **400**: Dados inválidos (validação, duplicatas)
- **401**: Não autorizado (credenciais inválidas, conta inativa)
- **404**: Não encontrado (usuário inexistente)
- **500**: Erro interno do servidor

---

Esta documentação fornece uma análise completa e detalhada das rotas de autenticação, explicando cada linha de código, fluxo de execução e medidas de segurança implementadas.
# DOCUMENTAÇÃO DETALHADA - MODELO DE CONQUISTAS (achievementModel.js)

## VISÃO GERAL
Este arquivo define o modelo de dados para as conquistas (achievements) do sistema IFC Coin. As conquistas são recompensas que os usuários podem desbloquear ao realizar determinadas ações no sistema, como transferências, metas, acúmulo de coins, etc.

## ESTRUTURA DO ARQUIVO

### 1. IMPORTAÇÃO DO MONGOOSE
```javascript
const mongoose = require('mongoose');
```
**Explicação:** Importa a biblioteca Mongoose, que é o ODM (Object Document Mapper) para MongoDB. O Mongoose permite definir esquemas, modelos e trabalhar com documentos MongoDB de forma orientada a objetos.

### 2. DEFINIÇÃO DO ESQUEMA
```javascript
const achievementSchema = new mongoose.Schema({
```
**Explicação:** Cria um novo esquema Mongoose chamado `achievementSchema`. Um esquema define a estrutura, tipos de dados, validações e comportamentos dos documentos que serão armazenados na coleção MongoDB.

### 3. CAMPO: NOME
```javascript
nome: { type: String, required: true },
```
**Explicação:** 
- **`nome`**: Nome do campo no documento
- **`type: String`**: Define que o valor deve ser uma string
- **`required: true`**: Torna o campo obrigatório. Se não for fornecido, o Mongoose lançará um erro de validação

**Exemplo de uso:** "Primeira Transferência", "Coletor de Coins", etc.

### 4. CAMPO: DESCRIÇÃO
```javascript
descricao: { type: String, required: true },
```
**Explicação:**
- **`descricao`**: Campo para armazenar a descrição detalhada da conquista
- **`type: String`**: Valor deve ser uma string
- **`required: true`**: Campo obrigatório

**Exemplo de uso:** "Complete sua primeira transferência de coins", "Acumule 1000 coins", etc.

### 5. CAMPO: TIPO (ENUM)
```javascript
tipo: { 
    type: String, 
    enum: [
        // Transferências enviadas
        'primeira_transferencia',
        'transferencias_10',
        'transferencias_50',
        'transferencias_100',
        
        // Transferências recebidas
        'primeira_recebida',
        'recebidas_10',
        'recebidas_50',
        'recebidas_100',
        
        // Metas
        'primeira_meta',
        'metas_10',
        'metas_50',
        'metas_100',
        
        // Coins acumulados
        'coins_100',
        'coins_500',
        'coins_1000',
        'coins_5000',
        
        // Frequência
        'login_consecutivo_7',
        'login_consecutivo_30',
        'login_consecutivo_100',
        
        // Foto de perfil
        'foto_perfil',
        
        // Balanço geral
        'equilibrado',
        'social'
    ], 
    required: true 
},
```

**Explicação detalhada:**

#### **`type: String`**
Define que o valor deve ser uma string.

#### **`enum: [...]`**
Restringe os valores possíveis apenas aos listados no array. Se um valor diferente for fornecido, o Mongoose lançará um erro de validação.

#### **Categorias de Conquistas:**

##### **TRANSFERÊNCIAS ENVIADAS**
- **`'primeira_transferencia'`**: Conquista para a primeira transferência realizada
- **`'transferencias_10'`**: Conquista após 10 transferências enviadas
- **`'transferencias_50'`**: Conquista após 50 transferências enviadas
- **`'transferencias_100'`**: Conquista após 100 transferências enviadas

##### **TRANSFERÊNCIAS RECEBIDAS**
- **`'primeira_recebida'`**: Conquista para a primeira transferência recebida
- **`'recebidas_10'`**: Conquista após receber 10 transferências
- **`'recebidas_50'`**: Conquista após receber 50 transferências
- **`'recebidas_100'`**: Conquista após receber 100 transferências

##### **METAS**
- **`'primeira_meta'`**: Conquista para criar a primeira meta
- **`'metas_10'`**: Conquista após criar 10 metas
- **`'metas_50'`**: Conquista após criar 50 metas
- **`'metas_100'`**: Conquista após criar 100 metas

##### **COINS ACUMULADOS**
- **`'coins_100'`**: Conquista ao acumular 100 coins
- **`'coins_500'`**: Conquista ao acumular 500 coins
- **`'coins_1000'`**: Conquista ao acumular 1000 coins
- **`'coins_5000'`**: Conquista ao acumular 5000 coins

##### **FREQUÊNCIA**
- **`'login_consecutivo_7'`**: Conquista por fazer login 7 dias consecutivos
- **`'login_consecutivo_30'`**: Conquista por fazer login 30 dias consecutivos
- **`'login_consecutivo_100'`**: Conquista por fazer login 100 dias consecutivos

##### **FOTO DE PERFIL**
- **`'foto_perfil'`**: Conquista por adicionar uma foto de perfil

##### **BALANÇO GERAL**
- **`'equilibrado'`**: Conquista para usuários que mantêm um balanço equilibrado
- **`'social'`**: Conquista para usuários que são muito ativos socialmente

#### **`required: true`**
Torna o campo obrigatório. Sem este campo, a conquista não pode ser criada.

### 6. CAMPO: CATEGORIA
```javascript
categoria: { type: String },
```
**Explicação:**
- **`categoria`**: Campo opcional para categorizar as conquistas
- **`type: String`**: Valor deve ser uma string
- **Sem `required`**: Campo opcional

**Exemplo de uso:** "Transferências", "Metas", "Coins", "Frequência", etc.

### 7. CAMPO: ÍCONE
```javascript
icone: { type: String },
```
**Explicação:**
- **`icone`**: Campo opcional para armazenar o nome ou caminho do ícone da conquista
- **`type: String`**: Valor deve ser uma string
- **Sem `required`**: Campo opcional

**Exemplo de uso:** "trophy", "star", "medal", ou caminho para imagem

### 8. CAMPO: REQUISITOS
```javascript
requisitos: { type: String },
```
**Explicação:**
- **`requisitos`**: Campo opcional para descrever os requisitos específicos da conquista
- **`type: String`**: Valor deve ser uma string
- **Sem `required`**: Campo opcional

**Exemplo de uso:** "Faça 10 transferências", "Acumule 1000 coins", etc.

### 9. OPÇÕES DO ESQUEMA
```javascript
{ timestamps: true }
```
**Explicação:**
- **`timestamps: true`**: Adiciona automaticamente dois campos ao documento:
  - **`createdAt`**: Data/hora de criação do documento
  - **`updatedAt`**: Data/hora da última atualização do documento
- Estes campos são gerenciados automaticamente pelo Mongoose

### 10. EXPORTAÇÃO DO MODELO
```javascript
module.exports = mongoose.model('Achievement', achievementSchema);
```
**Explicação:**
- **`mongoose.model('Achievement', achievementSchema)`**: Cria um modelo Mongoose chamado 'Achievement' baseado no esquema definido
- **`module.exports`**: Exporta o modelo para ser usado em outros arquivos
- O primeiro parâmetro ('Achievement') define o nome da coleção no MongoDB (será 'achievements' no plural)

## EXEMPLO DE DOCUMENTO NO MONGODB
```json
{
  "_id": ObjectId("..."),
  "nome": "Primeira Transferência",
  "descricao": "Complete sua primeira transferência de coins",
  "tipo": "primeira_transferencia",
  "categoria": "Transferências",
  "icone": "trophy",
  "requisitos": "Faça pelo menos uma transferência",
  "createdAt": ISODate("2024-01-01T10:00:00Z"),
  "updatedAt": ISODate("2024-01-01T10:00:00Z")
}
```

## FUNCIONALIDADES DO MODELO

### 1. **VALIDAÇÃO AUTOMÁTICA**
- O Mongoose valida automaticamente os tipos de dados
- Campos obrigatórios são verificados
- Valores do enum são validados

### 2. **TIMESTAMPS AUTOMÁTICOS**
- `createdAt` e `updatedAt` são gerenciados automaticamente
- Útil para auditoria e rastreamento

### 3. **FLEXIBILIDADE**
- Campos opcionais permitem conquistas simples ou complexas
- Categorização permite organização visual
- Ícones permitem personalização visual

### 4. **ENUM ESTRUTURADO**
- 22 tipos diferentes de conquistas
- Cobertura completa das funcionalidades do sistema
- Fácil expansão para novos tipos

## RELACIONAMENTOS
Este modelo é referenciado no `userModel.js` através do campo `conquistas.achievement`, criando um relacionamento entre usuários e suas conquistas desbloqueadas.

## USO NO SISTEMA
1. **Criação**: Scripts de seed criam conquistas padrão
2. **Verificação**: Sistema verifica automaticamente se usuários desbloquearam conquistas
3. **Exibição**: Frontend exibe conquistas disponíveis e desbloqueadas
4. **Gamificação**: Motiva usuários a usar mais funcionalidades do sistema
# DOCUMENTAÇÃO DETALHADA - MODELO DE TRANSAÇÕES (transactionModel.js)

## VISÃO GERAL
Este arquivo define o modelo de dados para as transações do sistema IFC Coin. As transações registram todas as transferências de coins entre usuários, incluindo transferências normais entre alunos e transferências especiais entre professores e alunos que podem requerer aprovação.

## ESTRUTURA DO ARQUIVO

### 1. IMPORTAÇÃO DO MONGOOSE
```javascript
const mongoose = require('mongoose');
```
**Explicação:** Importa a biblioteca Mongoose, que é o ODM (Object Document Mapper) para MongoDB. O Mongoose permite definir esquemas, modelos e trabalhar com documentos MongoDB de forma orientada a objetos.

### 2. DEFINIÇÃO DO ESQUEMA
```javascript
const transactionSchema = new mongoose.Schema({
```
**Explicação:** Cria um novo esquema Mongoose chamado `transactionSchema`. Um esquema define a estrutura, tipos de dados, validações e comportamentos dos documentos que serão armazenados na coleção MongoDB.

### 3. CAMPO: TIPO
```javascript
tipo: { type: String, enum: ['recebido', 'enviado'], required: true },
```
**Explicação detalhada:**

#### **`tipo`**
Nome do campo que define o tipo da transação.

#### **`type: String`**
Define que o valor deve ser uma string.

#### **`enum: ['recebido', 'enviado']`**
Restringe os valores possíveis apenas a 'recebido' ou 'enviado':
- **`'recebido'`**: Indica que o usuário recebeu coins (transação de entrada)
- **`'enviado'`**: Indica que o usuário enviou coins (transação de saída)

#### **`required: true`**
Torna o campo obrigatório. Sem este campo, a transação não pode ser criada.

**Exemplo de uso:** 
- Para um usuário que enviou coins: `tipo: 'enviado'`
- Para um usuário que recebeu coins: `tipo: 'recebido'`

### 4. CAMPO: ORIGEM
```javascript
origem: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
```
**Explicação detalhada:**

#### **`origem`**
Nome do campo que identifica quem enviou os coins.

#### **`type: mongoose.Schema.Types.ObjectId`**
Define que o valor deve ser um ObjectId do MongoDB. ObjectId é um identificador único de 12 bytes usado pelo MongoDB.

#### **`ref: 'User'`**
Estabelece uma referência ao modelo 'User'. Isso permite:
- **Populate**: Carregar dados completos do usuário de origem
- **Validação**: Verificar se o ObjectId existe na coleção de usuários
- **Relacionamento**: Criar relacionamento entre transações e usuários

**Exemplo de uso:** `origem: ObjectId("507f1f77bcf86cd799439011")`

### 5. CAMPO: DESTINO
```javascript
destino: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
```
**Explicação detalhada:**

#### **`destino`**
Nome do campo que identifica quem recebeu os coins.

#### **`type: mongoose.Schema.Types.ObjectId`**
Define que o valor deve ser um ObjectId do MongoDB.

#### **`ref: 'User'`**
Estabelece uma referência ao modelo 'User', permitindo populate e validação.

**Exemplo de uso:** `destino: ObjectId("507f1f77bcf86cd799439012")`

### 6. CAMPO: QUANTIDADE
```javascript
quantidade: Number,
```
**Explicação detalhada:**

#### **`quantidade`**
Nome do campo que armazena a quantidade de coins transferidos.

#### **`Number`**
Define que o valor deve ser um número. No JavaScript/MongoDB, isso pode ser:
- **Inteiro**: `100`, `500`, `1000`
- **Decimal**: `100.5`, `500.75` (se necessário)

**Exemplo de uso:** `quantidade: 100`

### 7. CAMPO: DESCRIÇÃO
```javascript
descricao: String,
```
**Explicação detalhada:**

#### **`descricao`**
Nome do campo para armazenar uma descrição opcional da transação.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional (sem `required`).

**Exemplo de uso:** 
- `descricao: "Pagamento por trabalho em grupo"`
- `descricao: "Recompensa por participação em evento"`
- `descricao: "Transferência de emergência"`

### 8. CAMPO: HASH
```javascript
hash: String,
```
**Explicação detalhada:**

#### **`hash`**
Nome do campo para armazenar um hash único da transação.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional.

**Exemplo de uso:** 
- `hash: "abc123def456ghi789"`
- `hash: "tx_2024_001_001"`

**Propósito:** 
- **Rastreabilidade**: Identificar transações únicas
- **Segurança**: Verificar integridade da transação
- **Auditoria**: Facilitar auditoria de transações

### 9. CAMPO: STATUS
```javascript
status: { type: String, enum: ['pendente', 'aprovada', 'recusada'], default: 'aprovada' },
```
**Explicação detalhada:**

#### **`status`**
Nome do campo que define o status atual da transação.

#### **`type: String`**
Define que o valor deve ser uma string.

#### **`enum: ['pendente', 'aprovada', 'recusada']`**
Restringe os valores possíveis:
- **`'pendente'`**: Transação aguardando aprovação (ex: professor → aluno)
- **`'aprovada'`**: Transação foi aprovada e executada
- **`'recusada'`**: Transação foi recusada e não executada

#### **`default: 'aprovada'`**
Define o valor padrão como 'aprovada'. Isso significa que:
- Transações normais entre alunos são automaticamente aprovadas
- Transações que requerem aprovação começam como 'pendente'
- O sistema pode mudar para 'aprovada' ou 'recusada' conforme necessário

### 10. OPÇÕES DO ESQUEMA
```javascript
{ timestamps: true }
```
**Explicação:**
- **`timestamps: true`**: Adiciona automaticamente dois campos ao documento:
  - **`createdAt`**: Data/hora de criação da transação
  - **`updatedAt`**: Data/hora da última atualização da transação
- Estes campos são gerenciados automaticamente pelo Mongoose

### 11. EXPORTAÇÃO DO MODELO
```javascript
module.exports = mongoose.model('Transaction', transactionSchema);
```
**Explicação:**
- **`mongoose.model('Transaction', transactionSchema)`**: Cria um modelo Mongoose chamado 'Transaction' baseado no esquema definido
- **`module.exports`**: Exporta o modelo para ser usado em outros arquivos
- O primeiro parâmetro ('Transaction') define o nome da coleção no MongoDB (será 'transactions' no plural)

## EXEMPLO DE DOCUMENTO NO MONGODB

### Transação Normal (Aluno → Aluno)
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439013"),
  "tipo": "enviado",
  "origem": ObjectId("507f1f77bcf86cd799439011"),
  "destino": ObjectId("507f1f77bcf86cd799439012"),
  "quantidade": 100,
  "descricao": "Pagamento por trabalho em grupo",
  "hash": "tx_2024_001_001",
  "status": "aprovada",
  "createdAt": ISODate("2024-01-01T10:00:00Z"),
  "updatedAt": ISODate("2024-01-01T10:00:00Z")
}
```

### Transação Pendente (Professor → Aluno)
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439014"),
  "tipo": "recebido",
  "origem": ObjectId("507f1f77bcf86cd799439015"),
  "destino": ObjectId("507f1f77bcf86cd799439016"),
  "quantidade": 500,
  "descricao": "Recompensa por excelente participação",
  "hash": "tx_2024_001_002",
  "status": "pendente",
  "createdAt": ISODate("2024-01-01T11:00:00Z"),
  "updatedAt": ISODate("2024-01-01T11:00:00Z")
}
```

## FUNCIONALIDADES DO MODELO

### 1. **SISTEMA DE REFERÊNCIAS**
- **`origem`** e **`destino`** referenciam usuários
- Permite carregar dados completos dos usuários com `populate()`
- Facilita consultas e relatórios

### 2. **CONTROLE DE STATUS**
- **Transações automáticas**: Status 'aprovada' por padrão
- **Transações com aprovação**: Podem ser 'pendente', 'aprovada' ou 'recusada'
- Permite implementar fluxos de aprovação para professor-aluno

### 3. **RASTREABILIDADE**
- **`hash`**: Identificador único para auditoria
- **`timestamps`**: Rastreamento temporal completo
- **`descricao`**: Contexto da transação

### 4. **FLEXIBILIDADE**
- Campos opcionais permitem transações simples ou complexas
- Suporte a diferentes tipos de transferência
- Extensível para novos requisitos

## RELACIONAMENTOS

### 1. **COM USUÁRIOS**
- **`origem`** → `User` (quem enviou)
- **`destino`** → `User` (quem recebeu)
- Permite consultas como "todas as transações de um usuário"

### 2. **NO SISTEMA**
- Usado em rotas de transação (`/api/transactions`)
- Referenciado no histórico de usuários
- Base para relatórios e estatísticas

## USO NO SISTEMA

### 1. **CRIAÇÃO DE TRANSAÇÕES**
```javascript
// Transação normal
const transaction = new Transaction({
  tipo: 'enviado',
  origem: userId,
  destino: recipientId,
  quantidade: 100,
  descricao: 'Pagamento',
  hash: generateHash(),
  status: 'aprovada'
});
```

### 2. **CONSULTAS COMUM**
```javascript
// Todas as transações de um usuário
const userTransactions = await Transaction.find({
  $or: [{ origem: userId }, { destino: userId }]
}).populate('origem destino');

// Transações pendentes
const pendingTransactions = await Transaction.find({ status: 'pendente' });
```

### 3. **POPULATE DE DADOS**
```javascript
// Carregar dados completos dos usuários
const transaction = await Transaction.findById(id)
  .populate('origem', 'nome email')
  .populate('destino', 'nome email');
```

## SEGURANÇA E VALIDAÇÃO

### 1. **VALIDAÇÃO AUTOMÁTICA**
- Mongoose valida tipos de dados
- Enum restringe valores válidos
- Referências verificam existência de usuários

### 2. **INTEGRIDADE**
- `hash` garante unicidade
- `timestamps` permitem auditoria
- Status controla fluxo de aprovação

### 3. **FLEXIBILIDADE**
- Suporte a diferentes cenários de uso
- Extensível para novos requisitos
- Mantém compatibilidade com sistema existente
# DOCUMENTAÇÃO DETALHADA - MODELO DE METAS (goalModel.js)

## VISÃO GERAL
Este arquivo define o modelo de dados para as metas (goals) do sistema IFC Coin. As metas são objetivos que os usuários podem cumprir para ganhar coins, incluindo diferentes tipos como eventos, indicações, desempenho acadêmico e metas customizadas. O modelo inclui controles de segurança, validação de evidências e limites de participação.

## ESTRUTURA DO ARQUIVO

### 1. IMPORTAÇÃO DO MONGOOSE
```javascript
const mongoose = require('mongoose');
```
**Explicação:** Importa a biblioteca Mongoose, que é o ODM (Object Document Mapper) para MongoDB. O Mongoose permite definir esquemas, modelos e trabalhar com documentos MongoDB de forma orientada a objetos.

### 2. DEFINIÇÃO DO ESQUEMA
```javascript
const goalSchema = new mongoose.Schema({
```
**Explicação:** Cria um novo esquema Mongoose chamado `goalSchema`. Um esquema define a estrutura, tipos de dados, validações e comportamentos dos documentos que serão armazenados na coleção MongoDB.

### 3. CAMPO: TÍTULO
```javascript
titulo: String,
```
**Explicação detalhada:**

#### **`titulo`**
Nome do campo que armazena o título da meta.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional (sem `required`).

**Exemplo de uso:** 
- `titulo: "Participar do Evento de Tecnologia"`
- `titulo: "Indicar 5 novos usuários"`
- `titulo: "Manter média 8.0 por 3 meses"`

### 4. CAMPO: DESCRIÇÃO
```javascript
descricao: String,
```
**Explicação detalhada:**

#### **`descricao`**
Nome do campo que armazena a descrição detalhada da meta.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional.

**Exemplo de uso:** 
- `descricao: "Participe do evento de tecnologia e ganhe 100 coins"`
- `descricao: "Indique novos usuários para a plataforma e receba recompensas"`
- `descricao: "Mantenha uma média acadêmica de 8.0 por 3 meses consecutivos"`

### 5. CAMPO: TIPO
```javascript
tipo: { type: String, enum: ['evento', 'indicacao', 'desempenho', 'custom'] },
```
**Explicação detalhada:**

#### **`tipo`**
Nome do campo que define a categoria da meta.

#### **`type: String`**
Define que o valor deve ser uma string.

#### **`enum: ['evento', 'indicacao', 'desempenho', 'custom']`**
Restringe os valores possíveis:
- **`'evento'`**: Metas relacionadas a participação em eventos, workshops, palestras
- **`'indicacao'`**: Metas para indicar novos usuários para a plataforma
- **`'desempenho'`**: Metas baseadas em desempenho acadêmico (médias, frequência)
- **`'custom'`**: Metas personalizadas criadas por professores ou administradores

**Exemplo de uso:** `tipo: 'evento'`

### 6. CAMPO: REQUISITO
```javascript
requisito: Number, // Ex: 10 horas, 2 convites, 1 ação
```
**Explicação detalhada:**

#### **`requisito`**
Nome do campo que define a quantidade necessária para completar a meta.

#### **`Number`**
Define que o valor deve ser um número.

#### **Comentário explicativo**
O comentário explica que o número pode representar diferentes unidades:
- **Horas**: Para eventos (ex: 10 horas de participação)
- **Convites**: Para indicações (ex: 2 convites enviados)
- **Ações**: Para metas customizadas (ex: 1 ação específica)

**Exemplo de uso:** 
- `requisito: 10` (10 horas de evento)
- `requisito: 5` (5 indicações)
- `requisito: 1` (1 ação específica)

### 7. CAMPO: RECOMPENSA
```javascript
recompensa: Number, // coins
```
**Explicação detalhada:**

#### **`recompensa`**
Nome do campo que define a quantidade de coins que o usuário receberá ao completar a meta.

#### **`Number`**
Define que o valor deve ser um número.

#### **Comentário explicativo**
O comentário especifica que a recompensa é em coins.

**Exemplo de uso:** 
- `recompensa: 100` (100 coins)
- `recompensa: 500` (500 coins)
- `recompensa: 1000` (1000 coins)

### 8. CAMPO: USUÁRIOS CONCLUÍDOS
```javascript
usuariosConcluidos: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
```
**Explicação detalhada:**

#### **`usuariosConcluidos`**
Nome do campo que armazena a lista de usuários que já completaram esta meta.

#### **`[{ ... }]`**
Define que o valor deve ser um array (lista).

#### **`type: mongoose.Schema.Types.ObjectId`**
Define que cada elemento do array deve ser um ObjectId do MongoDB.

#### **`ref: 'User'`**
Estabelece uma referência ao modelo 'User', permitindo:
- **Populate**: Carregar dados completos dos usuários
- **Validação**: Verificar se os ObjectIds existem na coleção de usuários
- **Relacionamento**: Criar relacionamento entre metas e usuários

**Exemplo de uso:** 
```javascript
usuariosConcluidos: [
  ObjectId("507f1f77bcf86cd799439011"),
  ObjectId("507f1f77bcf86cd799439012"),
  ObjectId("507f1f77bcf86cd799439013")
]
```

### 9. CAMPO: ATIVO
```javascript
ativo: { type: Boolean, default: true },
```
**Explicação detalhada:**

#### **`ativo`**
Nome do campo que define se a meta está ativa e disponível para os usuários.

#### **`type: Boolean`**
Define que o valor deve ser um booleano (true/false).

#### **`default: true`**
Define o valor padrão como `true`, significando que:
- Novas metas são criadas como ativas por padrão
- Metas podem ser desativadas sem serem deletadas
- Permite controle de disponibilidade sem perder dados

**Exemplo de uso:** 
- `ativo: true` (meta disponível)
- `ativo: false` (meta desativada)

### 10. CAMPO: REQUER APROVAÇÃO
```javascript
requerAprovacao: { type: Boolean, default: false }, // Se precisa de aprovação de professor/admin
```
**Explicação detalhada:**

#### **`requerAprovacao`**
Nome do campo que define se a conclusão da meta requer aprovação manual.

#### **`type: Boolean`**
Define que o valor deve ser um booleano.

#### **`default: false`**
Define o valor padrão como `false`, significando que:
- A maioria das metas é aprovada automaticamente
- Apenas metas específicas requerem aprovação manual
- Professores/admins podem aprovar ou recusar conclusões

#### **Comentário explicativo**
O comentário esclarece que a aprovação é feita por professores ou administradores.

**Exemplo de uso:** 
- `requerAprovacao: false` (aprovação automática)
- `requerAprovacao: true` (requer aprovação manual)

### 11. CAMPO: MÁXIMO DE CONCLUSÕES
```javascript
maxConclusoes: { type: Number, default: null }, // Limite máximo de conclusões (null = ilimitado)
```
**Explicação detalhada:**

#### **`maxConclusoes`**
Nome do campo que define o número máximo de usuários que podem completar esta meta.

#### **`type: Number`**
Define que o valor deve ser um número.

#### **`default: null`**
Define o valor padrão como `null`, significando que:
- `null` = ilimitado (qualquer número de usuários pode completar)
- Número específico = limite máximo de conclusões

#### **Comentário explicativo**
O comentário esclarece que `null` significa ilimitado.

**Exemplo de uso:** 
- `maxConclusoes: null` (ilimitado)
- `maxConclusoes: 50` (máximo 50 usuários)
- `maxConclusoes: 1` (apenas 1 usuário)

### 12. CAMPO: PERÍODO DE VALIDADE
```javascript
periodoValidade: { type: Number, default: null }, // Dias de validade (null = sempre válida)
```
**Explicação detalhada:**

#### **`periodoValidade`**
Nome do campo que define por quantos dias a meta é válida após ser criada.

#### **`type: Number`**
Define que o valor deve ser um número (dias).

#### **`default: null`**
Define o valor padrão como `null`, significando que:
- `null` = sempre válida (não expira)
- Número específico = dias de validade

#### **Comentário explicativo**
O comentário esclarece que `null` significa sempre válida.

**Exemplo de uso:** 
- `periodoValidade: null` (sempre válida)
- `periodoValidade: 30` (válida por 30 dias)
- `periodoValidade: 7` (válida por 7 dias)

### 13. CAMPO: DATA DE INÍCIO
```javascript
dataInicio: { type: Date, default: Date.now },
```
**Explicação detalhada:**

#### **`dataInicio`**
Nome do campo que define quando a meta começou a ser válida.

#### **`type: Date`**
Define que o valor deve ser uma data.

#### **`default: Date.now`**
Define o valor padrão como a data/hora atual, significando que:
- Novas metas começam a valer imediatamente
- Pode ser alterado para datas futuras
- Usado em conjunto com `periodoValidade` para calcular expiração

**Exemplo de uso:** 
- `dataInicio: new Date("2024-01-01")`
- `dataInicio: new Date()` (data atual)

### 14. CAMPO: DATA DE FIM
```javascript
dataFim: { type: Date, default: null },
```
**Explicação detalhada:**

#### **`dataFim`**
Nome do campo que define quando a meta expira (data específica).

#### **`type: Date`**
Define que o valor deve ser uma data.

#### **`default: null`**
Define o valor padrão como `null`, significando que:
- `null` = sem data de fim específica
- Data específica = meta expira nesta data

**Exemplo de uso:** 
- `dataFim: null` (sem data de fim)
- `dataFim: new Date("2024-12-31")` (expira em 31/12/2024)

### 15. CAMPO: EVIDÊNCIA OBRIGATÓRIA
```javascript
evidenciaObrigatoria: { type: Boolean, default: false },
```
**Explicação detalhada:**

#### **`evidenciaObrigatoria`**
Nome do campo que define se o usuário deve fornecer evidência para completar a meta.

#### **`type: Boolean`**
Define que o valor deve ser um booleano.

#### **`default: false`**
Define o valor padrão como `false`, significando que:
- A maioria das metas não requer evidência
- Apenas metas específicas requerem comprovação
- Usuários devem anexar arquivos ou texto como prova

**Exemplo de uso:** 
- `evidenciaObrigatoria: false` (sem evidência necessária)
- `evidenciaObrigatoria: true` (evidência obrigatória)

### 16. CAMPO: TIPO DE EVIDÊNCIA
```javascript
tipoEvidencia: { type: String, enum: ['foto', 'documento', 'comprovante', 'texto'], default: 'texto' },
```
**Explicação detalhada:**

#### **`tipoEvidencia`**
Nome do campo que define que tipo de evidência o usuário deve fornecer.

#### **`type: String`**
Define que o valor deve ser uma string.

#### **`enum: ['foto', 'documento', 'comprovante', 'texto']`**
Restringe os valores possíveis:
- **`'foto'`**: Usuário deve enviar uma foto como evidência
- **`'documento'`**: Usuário deve enviar um documento (PDF, etc.)
- **`'comprovante'`**: Usuário deve enviar um comprovante específico
- **`'texto'`**: Usuário deve escrever uma descrição textual

#### **`default: 'texto'`**
Define o valor padrão como 'texto', sendo o tipo mais simples.

**Exemplo de uso:** 
- `tipoEvidencia: 'foto'` (evidência fotográfica)
- `tipoEvidencia: 'documento'` (evidência documental)
- `tipoEvidencia: 'texto'` (evidência textual)

### 17. CAMPO: DESCRIÇÃO DA EVIDÊNCIA
```javascript
descricaoEvidencia: String,
```
**Explicação detalhada:**

#### **`descricaoEvidencia`**
Nome do campo que armazena instruções sobre que tipo de evidência o usuário deve fornecer.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional.

**Exemplo de uso:** 
- `descricaoEvidencia: "Envie uma foto do seu certificado de participação"`
- `descricaoEvidencia: "Descreva como você participou do evento"`
- `descricaoEvidencia: "Anexe o comprovante de presença"`

### 18. OPÇÕES DO ESQUEMA
```javascript
{ timestamps: true }
```
**Explicação:**
- **`timestamps: true`**: Adiciona automaticamente dois campos ao documento:
  - **`createdAt`**: Data/hora de criação da meta
  - **`updatedAt`**: Data/hora da última atualização da meta
- Estes campos são gerenciados automaticamente pelo Mongoose

### 19. EXPORTAÇÃO DO MODELO
```javascript
module.exports = mongoose.model('Goal', goalSchema);
```
**Explicação:**
- **`mongoose.model('Goal', goalSchema)`**: Cria um modelo Mongoose chamado 'Goal' baseado no esquema definido
- **`module.exports`**: Exporta o modelo para ser usado em outros arquivos
- O primeiro parâmetro ('Goal') define o nome da coleção no MongoDB (será 'goals' no plural)

## EXEMPLO DE DOCUMENTO NO MONGODB

### Meta de Evento
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439020"),
  "titulo": "Participar do Evento de Tecnologia",
  "descricao": "Participe do evento de tecnologia e ganhe 100 coins",
  "tipo": "evento",
  "requisito": 10,
  "recompensa": 100,
  "usuariosConcluidos": [
    ObjectId("507f1f77bcf86cd799439011"),
    ObjectId("507f1f77bcf86cd799439012")
  ],
  "ativo": true,
  "requerAprovacao": false,
  "maxConclusoes": null,
  "periodoValidade": 30,
  "dataInicio": ISODate("2024-01-01T00:00:00Z"),
  "dataFim": null,
  "evidenciaObrigatoria": true,
  "tipoEvidencia": "foto",
  "descricaoEvidencia": "Envie uma foto do seu certificado de participação",
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-01T00:00:00Z")
}
```

### Meta de Indicação
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439021"),
  "titulo": "Indicar Novos Usuários",
  "descricao": "Indique novos usuários para a plataforma e receba recompensas",
  "tipo": "indicacao",
  "requisito": 5,
  "recompensa": 50,
  "usuariosConcluidos": [],
  "ativo": true,
  "requerAprovacao": false,
  "maxConclusoes": 100,
  "periodoValidade": null,
  "dataInicio": ISODate("2024-01-01T00:00:00Z"),
  "dataFim": null,
  "evidenciaObrigatoria": false,
  "tipoEvidencia": "texto",
  "descricaoEvidencia": "Descreva como você indicou os novos usuários",
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-01T00:00:00Z")
}
```

## FUNCIONALIDADES DO MODELO

### 1. **SISTEMA DE TIPOS FLEXÍVEL**
- **4 tipos principais**: evento, indicação, desempenho, custom
- **Extensível**: Fácil adição de novos tipos
- **Categorização**: Organização clara das metas

### 2. **CONTROLES DE SEGURANÇA**
- **`ativo`**: Controle de disponibilidade
- **`requerAprovacao`**: Controle de aprovação manual
- **`maxConclusoes`**: Limite de participantes
- **`periodoValidade`**: Controle temporal

### 3. **SISTEMA DE EVIDÊNCIAS**
- **4 tipos de evidência**: foto, documento, comprovante, texto
- **Obrigatoriedade configurável**: Algumas metas requerem prova
- **Instruções personalizadas**: Descrição específica do que enviar

### 4. **CONTROLE TEMPORAL**
- **`dataInicio`**: Quando a meta começa a valer
- **`dataFim`**: Data específica de expiração
- **`periodoValidade`**: Dias de validade após criação

### 5. **RASTREABILIDADE**
- **`usuariosConcluidos`**: Lista de quem completou
- **`timestamps`**: Rastreamento temporal completo
- **Relacionamentos**: Referência aos usuários

## RELACIONAMENTOS

### 1. **COM USUÁRIOS**
- **`usuariosConcluidos`** → `User[]` (quem completou a meta)
- Permite consultas como "metas completadas por um usuário"

### 2. **NO SISTEMA**
- Usado em rotas de metas (`/api/goals`)
- Referenciado no sistema de recompensas
- Base para gamificação e engajamento

## USO NO SISTEMA

### 1. **CRIAÇÃO DE METAS**
```javascript
// Meta de evento
const goal = new Goal({
  titulo: "Participar do Evento",
  descricao: "Participe e ganhe coins",
  tipo: "evento",
  requisito: 10,
  recompensa: 100,
  evidenciaObrigatoria: true,
  tipoEvidencia: "foto"
});
```

### 2. **CONSULTAS COMUM**
```javascript
// Metas ativas
const activeGoals = await Goal.find({ ativo: true });

// Metas por tipo
const eventGoals = await Goal.find({ tipo: 'evento', ativo: true });

// Metas que um usuário completou
const userGoals = await Goal.find({
  usuariosConcluidos: userId
});
```

### 3. **VERIFICAÇÃO DE VALIDADE**
```javascript
// Metas válidas (não expiradas)
const validGoals = await Goal.find({
  ativo: true,
  $or: [
    { dataFim: null },
    { dataFim: { $gt: new Date() } }
  ]
});
```

## SEGURANÇA E VALIDAÇÃO

### 1. **VALIDAÇÃO AUTOMÁTICA**
- Mongoose valida tipos de dados
- Enum restringe valores válidos
- Referências verificam existência de usuários

### 2. **CONTROLES DE ACESSO**
- Metas podem ser ativadas/desativadas
- Aprovação manual para metas sensíveis
- Limites de participação

### 3. **FLEXIBILIDADE**
- Suporte a diferentes tipos de meta
- Sistema de evidências configurável
- Controles temporais flexíveis
# DOCUMENTAÇÃO DETALHADA - MODELO DE SOLICITAÇÕES DE METAS (goalRequestModel.js)

## VISÃO GERAL
Este arquivo define o modelo de dados para as solicitações de conclusão de metas (goal requests) do sistema IFC Coin. Quando um usuário tenta completar uma meta que requer aprovação ou evidência, uma solicitação é criada para que professores ou administradores possam analisar e aprovar/recusar a conclusão da meta.

## ESTRUTURA DO ARQUIVO

### 1. IMPORTAÇÃO DO MONGOOSE
```javascript
const mongoose = require('mongoose');
```
**Explicação:** Importa a biblioteca Mongoose, que é o ODM (Object Document Mapper) para MongoDB. O Mongoose permite definir esquemas, modelos e trabalhar com documentos MongoDB de forma orientada a objetos.

### 2. DEFINIÇÃO DO ESQUEMA
```javascript
const goalRequestSchema = new mongoose.Schema({
```
**Explicação:** Cria um novo esquema Mongoose chamado `goalRequestSchema`. Um esquema define a estrutura, tipos de dados, validações e comportamentos dos documentos que serão armazenados na coleção MongoDB.

### 3. CAMPO: META
```javascript
goal: { type: mongoose.Schema.Types.ObjectId, ref: 'Goal', required: true },
```
**Explicação detalhada:**

#### **`goal`**
Nome do campo que identifica qual meta o usuário está tentando completar.

#### **`type: mongoose.Schema.Types.ObjectId`**
Define que o valor deve ser um ObjectId do MongoDB. ObjectId é um identificador único de 12 bytes usado pelo MongoDB.

#### **`ref: 'Goal'`**
Estabelece uma referência ao modelo 'Goal', permitindo:
- **Populate**: Carregar dados completos da meta
- **Validação**: Verificar se o ObjectId existe na coleção de metas
- **Relacionamento**: Criar relacionamento entre solicitações e metas

#### **`required: true`**
Torna o campo obrigatório. Sem este campo, a solicitação não pode ser criada.

**Exemplo de uso:** `goal: ObjectId("507f1f77bcf86cd799439020")`

### 4. CAMPO: ALUNO
```javascript
aluno: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
```
**Explicação detalhada:**

#### **`aluno`**
Nome do campo que identifica qual usuário está fazendo a solicitação.

#### **`type: mongoose.Schema.Types.ObjectId`**
Define que o valor deve ser um ObjectId do MongoDB.

#### **`ref: 'User'`**
Estabelece uma referência ao modelo 'User', permitindo:
- **Populate**: Carregar dados completos do usuário
- **Validação**: Verificar se o ObjectId existe na coleção de usuários
- **Relacionamento**: Criar relacionamento entre solicitações e usuários

#### **`required: true`**
Torna o campo obrigatório. Sem este campo, a solicitação não pode ser criada.

**Exemplo de uso:** `aluno: ObjectId("507f1f77bcf86cd799439011")`

### 5. CAMPO: STATUS
```javascript
status: { type: String, enum: ['pendente', 'aprovada', 'recusada'], default: 'pendente' },
```
**Explicação detalhada:**

#### **`status`**
Nome do campo que define o status atual da solicitação.

#### **`type: String`**
Define que o valor deve ser uma string.

#### **`enum: ['pendente', 'aprovada', 'recusada']`**
Restringe os valores possíveis:
- **`'pendente'`**: Solicitação aguardando análise de professor/admin
- **`'aprovada'`**: Solicitação foi aprovada, meta considerada completada
- **`'recusada'`**: Solicitação foi recusada, meta não completada

#### **`default: 'pendente'`**
Define o valor padrão como 'pendente', significando que:
- Novas solicitações começam como pendentes
- Professores/admins devem analisar e aprovar/recusar
- Sistema pode processar automaticamente após análise

**Exemplo de uso:** 
- `status: 'pendente'` (aguardando análise)
- `status: 'aprovada'` (aprovada)
- `status: 'recusada'` (recusada)

### 6. CAMPO: COMENTÁRIO
```javascript
comentario: { type: String },
```
**Explicação detalhada:**

#### **`comentario`**
Nome do campo para armazenar um comentário opcional do usuário sobre a solicitação.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional (sem `required`).

**Exemplo de uso:** 
- `comentario: "Participei do evento e gostaria de solicitar a conclusão da meta"`
- `comentario: "Indiquei 5 novos usuários conforme solicitado"`
- `comentario: "Mantive média 8.5 por 3 meses consecutivos"`

### 7. CAMPO: EVIDÊNCIA TEXTO
```javascript
evidenciaTexto: { type: String },
```
**Explicação detalhada:**

#### **`evidenciaTexto`**
Nome do campo para armazenar evidência textual fornecida pelo usuário.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional.

**Exemplo de uso:** 
- `evidenciaTexto: "Participei do evento de tecnologia no dia 15/01/2024"`
- `evidenciaTexto: "Indiquei os seguintes usuários: joao@email.com, maria@email.com"`
- `evidenciaTexto: "Minha média nos últimos 3 meses foi 8.7"`

### 8. CAMPO: EVIDÊNCIA ARQUIVO
```javascript
evidenciaArquivo: { type: String }, // caminho do arquivo, se houver
```
**Explicação detalhada:**

#### **`evidenciaArquivo`**
Nome do campo para armazenar o caminho do arquivo de evidência enviado pelo usuário.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional.

#### **Comentário explicativo**
O comentário esclarece que o campo armazena o caminho do arquivo, não o arquivo em si.

**Exemplo de uso:** 
- `evidenciaArquivo: "/uploads/certificado_evento.pdf"`
- `evidenciaArquivo: "/uploads/comprovante_presenca.jpg"`
- `evidenciaArquivo: "/uploads/relatorio_desempenho.docx"`

### 9. CAMPO: RESPOSTA
```javascript
resposta: { type: String }, // comentário do admin/professor
```
**Explicação detalhada:**

#### **`resposta`**
Nome do campo para armazenar o comentário do administrador ou professor sobre a solicitação.

#### **`String`**
Define que o valor deve ser uma string. Campo opcional.

#### **Comentário explicativo**
O comentário esclarece que a resposta é feita por admin ou professor.

**Exemplo de uso:** 
- `resposta: "Aprovado! Evidência suficiente fornecida."`
- `resposta: "Recusado. Evidência insuficiente ou não atende aos requisitos."`
- `resposta: "Aprovado com observações. Boa participação no evento."`

### 10. CAMPO: ANALISADO POR
```javascript
analisadoPor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
```
**Explicação detalhada:**

#### **`analisadoPor`**
Nome do campo que identifica qual usuário (professor/admin) analisou a solicitação.

#### **`type: mongoose.Schema.Types.ObjectId`**
Define que o valor deve ser um ObjectId do MongoDB.

#### **`ref: 'User'`**
Estabelece uma referência ao modelo 'User', permitindo:
- **Populate**: Carregar dados completos do analisador
- **Validação**: Verificar se o ObjectId existe na coleção de usuários
- **Relacionamento**: Criar relacionamento entre solicitações e analisadores

**Exemplo de uso:** `analisadoPor: ObjectId("507f1f77bcf86cd799439015")`

### 11. CAMPO: DATA DE ANÁLISE
```javascript
dataAnalise: { type: Date },
```
**Explicação detalhada:**

#### **`dataAnalise`**
Nome do campo que armazena quando a solicitação foi analisada.

#### **`Date`**
Define que o valor deve ser uma data. Campo opcional.

**Exemplo de uso:** 
- `dataAnalise: new Date("2024-01-15T10:30:00Z")`
- `dataAnalise: new Date()` (data atual)

### 12. OPÇÕES DO ESQUEMA
```javascript
{ timestamps: true }
```
**Explicação:**
- **`timestamps: true`**: Adiciona automaticamente dois campos ao documento:
  - **`createdAt`**: Data/hora de criação da solicitação
  - **`updatedAt`**: Data/hora da última atualização da solicitação
- Estes campos são gerenciados automaticamente pelo Mongoose

### 13. EXPORTAÇÃO DO MODELO
```javascript
module.exports = mongoose.model('GoalRequest', goalRequestSchema);
```
**Explicação:**
- **`mongoose.model('GoalRequest', goalRequestSchema)`**: Cria um modelo Mongoose chamado 'GoalRequest' baseado no esquema definido
- **`module.exports`**: Exporta o modelo para ser usado em outros arquivos
- O primeiro parâmetro ('GoalRequest') define o nome da coleção no MongoDB (será 'goalrequests' no plural)

## EXEMPLO DE DOCUMENTO NO MONGODB

### Solicitação Pendente
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439030"),
  "goal": ObjectId("507f1f77bcf86cd799439020"),
  "aluno": ObjectId("507f1f77bcf86cd799439011"),
  "status": "pendente",
  "comentario": "Participei do evento de tecnologia e gostaria de solicitar a conclusão da meta",
  "evidenciaTexto": "Participei do evento de tecnologia no dia 15/01/2024 das 14h às 18h",
  "evidenciaArquivo": "/uploads/certificado_evento.pdf",
  "resposta": null,
  "analisadoPor": null,
  "dataAnalise": null,
  "createdAt": ISODate("2024-01-15T14:00:00Z"),
  "updatedAt": ISODate("2024-01-15T14:00:00Z")
}
```

### Solicitação Aprovada
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439031"),
  "goal": ObjectId("507f1f77bcf86cd799439021"),
  "aluno": ObjectId("507f1f77bcf86cd799439012"),
  "status": "aprovada",
  "comentario": "Indiquei 5 novos usuários conforme solicitado",
  "evidenciaTexto": "Indiquei os seguintes usuários: joao@email.com, maria@email.com, pedro@email.com, ana@email.com, lucas@email.com",
  "evidenciaArquivo": null,
  "resposta": "Aprovado! Evidência suficiente fornecida.",
  "analisadoPor": ObjectId("507f1f77bcf86cd799439015"),
  "dataAnalise": ISODate("2024-01-16T09:30:00Z"),
  "createdAt": ISODate("2024-01-15T16:00:00Z"),
  "updatedAt": ISODate("2024-01-16T09:30:00Z")
}
```

### Solicitação Recusada
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439032"),
  "goal": ObjectId("507f1f77bcf86cd799439022"),
  "aluno": ObjectId("507f1f77bcf86cd799439013"),
  "status": "recusada",
  "comentario": "Mantive média 7.5 por 3 meses",
  "evidenciaTexto": "Minha média nos últimos 3 meses foi 7.5",
  "evidenciaArquivo": "/uploads/boletim.pdf",
  "resposta": "Recusado. A meta requer média mínima de 8.0.",
  "analisadoPor": ObjectId("507f1f77bcf86cd799439015"),
  "dataAnalise": ISODate("2024-01-17T11:15:00Z"),
  "createdAt": ISODate("2024-01-15T18:00:00Z"),
  "updatedAt": ISODate("2024-01-17T11:15:00Z")
}
```

## FUNCIONALIDADES DO MODELO

### 1. **SISTEMA DE APROVAÇÃO**
- **Status controlado**: pendente → aprovada/recusada
- **Rastreabilidade**: Quem analisou e quando
- **Comentários**: Comunicação entre usuário e analisador

### 2. **SISTEMA DE EVIDÊNCIAS**
- **Evidência textual**: Descrição detalhada do usuário
- **Evidência arquivo**: Upload de documentos/fotos
- **Flexibilidade**: Suporte a diferentes tipos de prova

### 3. **RELACIONAMENTOS**
- **`goal`** → `Goal` (qual meta está sendo solicitada)
- **`aluno`** → `User` (quem fez a solicitação)
- **`analisadoPor`** → `User` (quem analisou)

### 4. **RASTREABILIDADE**
- **`timestamps`**: Rastreamento temporal completo
- **`dataAnalise`**: Quando foi analisada
- **`resposta`**: Justificativa da decisão

## RELACIONAMENTOS

### 1. **COM METAS**
- **`goal`** → `Goal` (meta sendo solicitada)
- Permite consultas como "todas as solicitações de uma meta"

### 2. **COM USUÁRIOS**
- **`aluno`** → `User` (solicitante)
- **`analisadoPor`** → `User` (analisador)
- Permite consultas como "todas as solicitações de um aluno"

### 3. **NO SISTEMA**
- Usado em rotas de solicitações (`/api/goal-requests`)
- Referenciado no sistema de aprovação
- Base para relatórios de atividades

## USO NO SISTEMA

### 1. **CRIAÇÃO DE SOLICITAÇÕES**
```javascript
// Nova solicitação
const request = new GoalRequest({
  goal: goalId,
  aluno: userId,
  comentario: "Participei do evento",
  evidenciaTexto: "Descrição detalhada",
  evidenciaArquivo: "/uploads/arquivo.pdf"
});
```

### 2. **CONSULTAS COMUM**
```javascript
// Solicitações pendentes
const pendingRequests = await GoalRequest.find({ status: 'pendente' })
  .populate('goal aluno');

// Solicitações de um usuário
const userRequests = await GoalRequest.find({ aluno: userId })
  .populate('goal analisadoPor');

// Solicitações de uma meta
const goalRequests = await GoalRequest.find({ goal: goalId })
  .populate('aluno analisadoPor');
```

### 3. **ANÁLISE DE SOLICITAÇÕES**
```javascript
// Aprovar solicitação
await GoalRequest.findByIdAndUpdate(requestId, {
  status: 'aprovada',
  resposta: 'Aprovado!',
  analisadoPor: adminId,
  dataAnalise: new Date()
});
```

## FLUXO DE TRABALHO

### 1. **CRIAÇÃO**
1. Usuário tenta completar meta que requer aprovação
2. Sistema cria solicitação com status 'pendente'
3. Usuário fornece evidências (texto/arquivo)

### 2. **ANÁLISE**
1. Professor/admin visualiza solicitações pendentes
2. Analisa evidências fornecidas
3. Aprova ou recusa com comentário

### 3. **PROCESSAMENTO**
1. Se aprovada: meta é marcada como completada
2. Se recusada: usuário pode tentar novamente
3. Sistema atualiza estatísticas do usuário

## SEGURANÇA E VALIDAÇÃO

### 1. **VALIDAÇÃO AUTOMÁTICA**
- Mongoose valida tipos de dados
- Enum restringe valores válidos
- Referências verificam existência de entidades

### 2. **CONTROLES DE ACESSO**
- Apenas professores/admins podem analisar
- Usuários só podem ver suas próprias solicitações
- Sistema registra quem analisou

### 3. **FLEXIBILIDADE**
- Suporte a diferentes tipos de evidência
- Comentários para comunicação
- Rastreabilidade completa
# DOCUMENTAÇÃO DETALHADA - ROTAS DE USUÁRIOS (user.js)

## VISÃO GERAL
Este arquivo define todas as rotas relacionadas ao gerenciamento de usuários no sistema IFC Coin. Inclui operações de perfil, upload de fotos, gerenciamento de saldo, listagem de usuários e operações administrativas. O arquivo implementa controle de acesso baseado em roles e utiliza middleware de autenticação.

## ESTRUTURA DO ARQUIVO

### 1. IMPORTAÇÕES NECESSÁRIAS
```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const User = require('../models/userModel');
const { verificarToken, verificarAdmin, verificarProfessor } = require('../middleware/auth');
```
**Explicação detalhada:**

#### **`express`**
Framework web para Node.js, usado para criar o router.

#### **`multer`**
Middleware para lidar com upload de arquivos multipart/form-data.

#### **`path`**
Módulo nativo do Node.js para manipulação de caminhos de arquivo.

#### **`fs`**
Módulo nativo do Node.js para operações de sistema de arquivos.

#### **`User`**
Modelo de usuário importado do arquivo `userModel.js`.

#### **`verificarToken, verificarAdmin, verificarProfessor`**
Middleware de autenticação importado do arquivo `auth.js`:
- **`verificarToken`**: Verifica se o usuário está autenticado
- **`verificarAdmin`**: Verifica se o usuário é administrador
- **`verificarProfessor`**: Verifica se o usuário é professor ou admin

### 2. CRIAÇÃO DO ROUTER
```javascript
const router = express.Router();
```
**Explicação:** Cria um novo router do Express que será usado para agrupar todas as rotas de usuário.

### 3. CONFIGURAÇÃO DO MULTER
```javascript
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
  fileFilter: function (req, file, cb) {
    // Verificar se é uma imagem
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Apenas imagens são permitidas'), false);
    }
  }
});
```
**Explicação detalhada:**

#### **`multer.memoryStorage()`**
Configura o multer para armazenar arquivos em memória ao invés de disco.

#### **`limits.fileSize: 5 * 1024 * 1024`**
Define limite de 5MB para upload de arquivos.

#### **`fileFilter`**
Função que filtra tipos de arquivo:
- **`file.mimetype.startsWith('image/')`**: Aceita apenas imagens
- **`cb(null, true)`**: Aceita o arquivo
- **`cb(new Error(...), false)`**: Rejeita o arquivo

## ROTAS IMPLEMENTADAS

### 1. **GET /api/user/perfil** - Obter Perfil do Usuário
```javascript
router.get('/perfil', verificarToken, async (req, res) => {
    try {
        res.json(req.user); // req.user já é toPublicJSON pelo middleware
    } catch (error) {
        console.error('Erro ao obter perfil:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Método e Caminho**
- **`GET`**: Método HTTP para obter dados
- **`/perfil`**: Endpoint para perfil do usuário logado

#### **Middleware**
- **`verificarToken`**: Garante que o usuário está autenticado

#### **Funcionalidade**
- **`req.user`**: Usuário já processado pelo middleware de autenticação
- **`toPublicJSON()`**: Método que remove dados sensíveis (senha)
- **Tratamento de erro**: Captura e loga erros, retorna 500

### 2. **PUT /api/user/perfil** - Atualizar Dados do Perfil
```javascript
router.put('/perfil', verificarToken, upload.single('fotoPerfil'), async (req, res) => {
  try {
    const { nome, email, curso } = req.body;
    const userId = req.user._id;

    // Buscar usuário
    const user = await User.findById(userId).select('+fotoPerfilBin');
    if (!user) {
      return res.status(404).json({
        message: 'Usuário não encontrado'
      });
    }

    // Verificar se email já existe (se foi alterado)
    if (email && email !== user.email) {
      const emailExistente = await User.findOne({ 
        email: email.toLowerCase().trim(),
        _id: { $ne: userId }
      });
      if (emailExistente) {
        return res.status(400).json({
          message: 'Email já está em uso'
        });
      }
    }

    // Atualizar campos
    if (nome) user.nome = nome.trim();
    if (email) user.email = email.toLowerCase().trim();
    if (curso !== undefined) user.curso = curso;

    // Se veio arquivo, atualizar foto de perfil
    if (req.file) {
      // Redimensionar e comprimir imagem com sharp
      const sharp = require('sharp');
      const resizedBuffer = await sharp(req.file.buffer)
        .resize(256, 256, { fit: 'cover' })
        .jpeg({ quality: 80 })
        .toBuffer();
      // Salvar binário no MongoDB
      user.fotoPerfilBin = resizedBuffer;
      // Atualizar campo fotoPerfil para endpoint
      user.fotoPerfil = `/api/user/foto/${user._id}`;
      
      // Atualizar estatísticas para conquistas
      await user.atualizarEstatisticas('foto_perfil');
      
      // Verificar conquistas automaticamente
      await user.verificarConquistas();
    }

    await user.save();

    res.json({
      message: 'Perfil atualizado com sucesso',
      user: user.toPublicJSON()
    });

  } catch (error) {
    console.error('Erro ao atualizar perfil:', error);
    res.status(500).json({
      message: 'Erro interno do servidor'
    });
  }
});
```

**Explicação detalhada:**

#### **Método e Caminho**
- **`PUT`**: Método HTTP para atualizar dados
- **`/perfil`**: Endpoint para atualizar perfil

#### **Middleware**
- **`verificarToken`**: Autenticação obrigatória
- **`upload.single('fotoPerfil')`**: Processa upload de uma imagem

#### **Validações**
- **Busca usuário**: `User.findById(userId).select('+fotoPerfilBin')`
- **Verificação de email**: Evita duplicatas
- **`$ne: userId`**: Exclui o próprio usuário da verificação

#### **Processamento de Imagem**
- **`sharp`**: Biblioteca para processamento de imagem
- **`resize(256, 256)`**: Redimensiona para 256x256 pixels
- **`jpeg({ quality: 80 })`**: Comprime com qualidade 80%
- **`fit: 'cover'`**: Mantém proporção, corta se necessário

#### **Atualizações Automáticas**
- **`atualizarEstatisticas('foto_perfil')`**: Atualiza estatísticas
- **`verificarConquistas()`**: Verifica se desbloqueou conquistas

### 3. **POST /api/user/foto-perfil** - Upload de Foto de Perfil
```javascript
router.post('/foto-perfil', verificarToken, upload.single('foto'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        message: 'Nenhuma foto foi enviada'
      });
    }

    const userId = req.user._id;
    const user = await User.findById(userId).select('+fotoPerfilBin');
    if (!user) {
      return res.status(404).json({
        message: 'Usuário não encontrado'
      });
    }

    // Salvar binário no MongoDB
    user.fotoPerfilBin = req.file.buffer;
    user.fotoPerfil = `/api/user/foto/${user._id}`;
    await user.save();

    res.json({
      message: 'Foto de perfil atualizada com sucesso',
      fotoPerfil: user.fotoPerfil
    });

  } catch (error) {
    console.error('Erro ao fazer upload da foto:', error);
    res.status(500).json({
      message: 'Erro interno do servidor'
    });
  }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Endpoint dedicado**: Para upload apenas de foto
- **Validação de arquivo**: Verifica se arquivo foi enviado
- **Armazenamento binário**: Salva imagem diretamente no MongoDB
- **URL de acesso**: Gera URL para acessar a foto

### 4. **GET /api/user/foto/:id** - Servir Foto de Perfil
```javascript
router.get('/foto/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('+fotoPerfilBin');
    if (!user || !user.fotoPerfilBin) {
      return res.status(404).send('Foto não encontrada');
    }
    // Detectar tipo da imagem (simples, assume jpeg)
    res.set('Content-Type', 'image/jpeg');
    res.send(user.fotoPerfilBin);
  } catch (error) {
    res.status(500).send('Erro ao buscar foto');
  }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Endpoint público**: Não requer autenticação
- **Busca por ID**: Usa parâmetro da URL
- **Content-Type**: Define como imagem JPEG
- **Envio direto**: Envia buffer binário da imagem

### 5. **GET /api/user/saldo** - Obter Saldo do Usuário
```javascript
router.get('/saldo', verificarToken, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('saldo');
    
    if (!user) {
      return res.status(404).json({
        message: 'Usuário não encontrado'
      });
    }

    res.json({
      saldo: user.saldo
    });

  } catch (error) {
    console.error('Erro ao obter saldo:', error);
    res.status(500).json({
      message: 'Erro interno do servidor'
    });
  }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Consulta otimizada**: Seleciona apenas o campo `saldo`
- **Resposta simples**: Retorna apenas o saldo atual
- **Autenticação**: Apenas usuário logado pode ver seu saldo

### 6. **POST /api/user/adicionar-coins** - Adicionar Coins (Professor/Admin)
```javascript
router.post('/adicionar-coins', verificarProfessor, async (req, res) => {
    try {
        const { userId, quantidade, motivo } = req.body;

        if (!userId || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'ID do usuário e quantidade válida são obrigatórios'
            });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        await user.adicionarCoins(quantidade);

        res.json({
            message: 'Coins adicionados com sucesso',
            novoSaldo: user.saldo
        });

    } catch (error) {
        console.error('Erro ao adicionar coins:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **`verificarProfessor`**: Apenas professores e admins podem adicionar coins

#### **Validações**
- **`userId`**: ID do usuário que receberá os coins
- **`quantidade`**: Deve ser maior que zero
- **`motivo`**: Opcional, para auditoria

#### **Funcionalidade**
- **`adicionarCoins()`**: Método do modelo que adiciona coins
- **Retorna novo saldo**: Para confirmação da operação

### 7. **POST /api/user/remover-coins** - Remover Coins (Apenas Admin)
```javascript
router.post('/remover-coins', verificarAdmin, async (req, res) => {
    try {
        const { userId, quantidade, motivo } = req.body;

        if (!userId || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'ID do usuário e quantidade válida são obrigatórios'
            });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        await user.removerCoins(quantidade);

        res.json({
            message: 'Coins removidos com sucesso',
            novoSaldo: user.saldo
        });

    } catch (error) {
        console.error('Erro ao remover coins:', error);
        if (error.message === 'Saldo insuficiente ou quantidade inválida') {
            return res.status(400).json({
                message: error.message
            });
        }
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **`verificarAdmin`**: Apenas administradores podem remover coins

#### **Tratamento de Erro Específico**
- **Verifica erro específico**: Saldo insuficiente
- **Retorna 400**: Para erros de validação
- **Retorna 500**: Para erros internos

### 8. **GET /api/user/listar** - Listar Usuários (Apenas Admin)
```javascript
router.get('/listar', verificarAdmin, async (req, res) => {
    try {
        const { role, curso, ativo, page = 1, limit = 10 } = req.query;

        // Construir filtros
        const filtros = {};
        if (role) filtros.role = role;
        if (curso) filtros.curso = curso;
        if (ativo !== undefined) filtros.ativo = ativo === 'true';

        // Paginação
        const skip = (parseInt(page) - 1) * parseInt(limit);

        const usuarios = await User.find(filtros)
            .select('-senha')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await User.countDocuments(filtros);

        res.json({
            usuarios,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar usuários:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Filtros Disponíveis**
- **`role`**: Filtrar por tipo de usuário (aluno, professor, admin)
- **`curso`**: Filtrar por curso específico
- **`ativo`**: Filtrar por status ativo/inativo

#### **Paginação**
- **`page`**: Página atual (padrão: 1)
- **`limit`**: Itens por página (padrão: 10)
- **`skip`**: Calcula quantos itens pular
- **`total`**: Total de registros encontrados

#### **Ordenação e Seleção**
- **`.sort({ createdAt: -1 })`**: Ordena por data de criação (mais recente primeiro)
- **`.select('-senha')`**: Exclui senha dos resultados

### 9. **GET /api/user/:id** - Obter Usuário Específico (Apenas Admin)
```javascript
router.get('/:id', verificarAdmin, async (req, res) => {
    try {
        const user = await User.findById(req.params.id).select('-senha');
        
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        res.json(user);

    } catch (error) {
        console.error('Erro ao obter usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Busca por ID**: Usa parâmetro da URL
- **Exclui senha**: Por segurança
- **Apenas admin**: Controle de acesso restrito

### 10. **PUT /api/user/:id** - Atualizar Usuário (Apenas Admin)
```javascript
router.put('/:id', verificarAdmin, async (req, res) => {
    try {
        const { nome, email, role, curso, turmas, ativo } = req.body;
        const userId = req.params.id;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        // Atualizar campos
        if (nome) user.nome = nome.trim();
        if (email) {
            const emailExistente = await User.findOne({ 
                email: email.toLowerCase().trim(),
                _id: { $ne: userId }
            });
            if (emailExistente) {
                return res.status(400).json({
                    message: 'Email já está em uso'
                });
            }
            user.email = email.toLowerCase().trim();
        }
        if (role) user.role = role;
        if (curso !== undefined) user.curso = curso;
        if (turmas && Array.isArray(turmas)) user.turmas = turmas;
        if (ativo !== undefined) user.ativo = ativo;

        await user.save();

        res.json({
            message: 'Usuário atualizado com sucesso',
            user: user.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro ao atualizar usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Campos Atualizáveis**
- **`nome`**: Nome do usuário
- **`email`**: Email (com verificação de duplicata)
- **`role`**: Tipo de usuário
- **`curso`**: Curso do usuário
- **`turmas`**: Array de turmas
- **`ativo`**: Status ativo/inativo

#### **Validações**
- **Verificação de email**: Evita duplicatas
- **Validação de turmas**: Verifica se é array
- **Tratamento de undefined**: Para campos opcionais

### 11. **DELETE /api/user/:id** - Desativar Usuário (Apenas Admin)
```javascript
router.delete('/:id', verificarAdmin, async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        // Desativar usuário (soft delete)
        user.ativo = false;
        await user.save();

        res.json({
            message: 'Usuário desativado com sucesso'
        });

    } catch (error) {
        console.error('Erro ao desativar usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Soft Delete**
- **Não deleta**: Apenas marca como inativo
- **Preserva dados**: Mantém histórico e relacionamentos
- **Reversível**: Pode ser reativado posteriormente

### 12. **SERVIÇO DE ARQUIVOS ESTÁTICOS**
```javascript
router.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Servir arquivos**: Para fotos de perfil antigas
- **Caminho relativo**: `../uploads` a partir do diretório atual
- **Middleware estático**: Express serve arquivos automaticamente

## EXPORTAÇÃO DO ROUTER
```javascript
module.exports = router;
```

**Explicação:** Exporta o router para ser usado no servidor principal.

## SEGURANÇA IMPLEMENTADA

### 1. **CONTROLE DE ACESSO**
- **`verificarToken`**: Autenticação obrigatória
- **`verificarAdmin`**: Apenas administradores
- **`verificarProfessor`**: Professores e administradores

### 2. **VALIDAÇÃO DE DADOS**
- **Verificação de email**: Evita duplicatas
- **Validação de arquivo**: Apenas imagens
- **Limite de tamanho**: 5MB máximo

### 3. **PROCESSAMENTO DE IMAGEM**
- **Redimensionamento**: 256x256 pixels
- **Compressão**: Qualidade 80%
- **Armazenamento binário**: Direto no MongoDB

### 4. **TRATAMENTO DE ERROS**
- **Try-catch**: Captura todos os erros
- **Logs**: Registra erros para debug
- **Respostas apropriadas**: Status codes corretos

## FUNCIONALIDADES ESPECIAIS

### 1. **SISTEMA DE CONQUISTAS**
- **Atualização automática**: Ao adicionar foto
- **Verificação de conquistas**: Processo automático

### 2. **PAGINAÇÃO**
- **Filtros múltiplos**: Role, curso, status
- **Ordenação**: Por data de criação
- **Informações de paginação**: Total, páginas, etc.

### 3. **SOFT DELETE**
- **Preserva dados**: Não deleta permanentemente
- **Reversível**: Pode reativar usuários

### 4. **UPLOAD DE ARQUIVOS**
- **Validação de tipo**: Apenas imagens
- **Processamento**: Redimensionamento e compressão
- **Armazenamento**: Binário no MongoDB
# DOCUMENTAÇÃO DETALHADA - ROTAS DE TRANSAÇÕES (transaction.js)

## VISÃO GERAL
Este arquivo define todas as rotas relacionadas ao sistema de transações do IFC Coin. Inclui transferências entre usuários, recompensas de professores, histórico de transações, aprovação de transferências pendentes e gerenciamento administrativo. O sistema implementa controle de acesso baseado em roles e utiliza middleware de autenticação.

## ESTRUTURA DO ARQUIVO

### 1. IMPORTAÇÕES NECESSÁRIAS
```javascript
const express = require('express');
const Transaction = require('../models/transactionModel');
const User = require('../models/userModel');
const { verificarToken, verificarAdmin, verificarProfessor } = require('../middleware/auth');
```
**Explicação detalhada:**

#### **`express`**
Framework web para Node.js, usado para criar o router.

#### **`Transaction`**
Modelo de transações importado do arquivo `transactionModel.js`.

#### **`User`**
Modelo de usuários importado do arquivo `userModel.js`.

#### **`verificarToken, verificarAdmin, verificarProfessor`**
Middleware de autenticação importado do arquivo `auth.js`:
- **`verificarToken`**: Verifica se o usuário está autenticado
- **`verificarAdmin`**: Verifica se o usuário é administrador
- **`verificarProfessor`**: Verifica se o usuário é professor ou admin

### 2. CRIAÇÃO DO ROUTER
```javascript
const router = express.Router();
```
**Explicação:** Cria um novo router do Express que será usado para agrupar todas as rotas de transações.

## ROTAS IMPLEMENTADAS

### 1. **GET /api/transaction/historico** - Histórico de Transações do Usuário
```javascript
router.get('/historico', verificarToken, async (req, res) => {
    try {
        const { page = 1, limit = 10 } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        const transacoes = await Transaction.find({
            $or: [
                { origem: req.user._id },
                { destino: req.user._id }
            ]
        })
        .populate('origem', 'nome matricula')
        .populate('destino', 'nome matricula')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));

        const total = await Transaction.countDocuments({
            $or: [
                { origem: req.user._id },
                { destino: req.user._id }
            ]
        });

        res.json({
            transacoes,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao buscar histórico:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Método e Caminho**
- **`GET`**: Método HTTP para obter dados
- **`/historico`**: Endpoint para histórico pessoal

#### **Middleware**
- **`verificarToken`**: Garante que o usuário está autenticado

#### **Parâmetros de Query**
- **`page`**: Página atual (padrão: 1)
- **`limit`**: Itens por página (padrão: 10)

#### **Consulta de Transações**
- **`$or`**: Busca transações onde o usuário é origem OU destino
- **`populate`**: Carrega dados dos usuários (nome e matrícula)
- **`sort({ createdAt: -1 })`**: Ordena por data de criação (mais recente primeiro)
- **`skip` e `limit`**: Implementa paginação

#### **Contagem Total**
- **`countDocuments`**: Conta total de transações para paginação
- **Mesma condição `$or`**: Garante consistência

#### **Resposta**
- **`transacoes`**: Lista de transações com dados populados
- **`paginacao`**: Informações de paginação (página, limite, total, páginas)

### 2. **POST /api/transaction/transferir** - Transferir Coins Entre Usuários
```javascript
router.post('/transferir', verificarToken, async (req, res) => {
    try {
        const { destinoMatricula, quantidade, descricao } = req.body;

        if (!destinoMatricula || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'Matrícula de destino e quantidade válida são obrigatórias'
            });
        }

        // Buscar usuário de destino
        const usuarioDestino = await User.findOne({ matricula: destinoMatricula });
        if (!usuarioDestino) {
            return res.status(404).json({
                message: 'Usuário de destino não encontrado'
            });
        }

        if (usuarioDestino._id.toString() === req.user._id.toString()) {
            return res.status(400).json({
                message: 'Não é possível transferir para si mesmo'
            });
        }

        // Admin/professor têm saldo ilimitado
        const isAdminOrProfessor = req.user.role === 'admin' || req.user.role === 'professor';
        if (!isAdminOrProfessor && req.user.saldo < quantidade) {
            return res.status(400).json({
                message: 'Saldo insuficiente para transferência'
            });
        }

        // Se professor transferindo para aluno, criar transação pendente
        let status = 'aprovada';
        const roleOrigem = req.user.role;
        const roleDestino = usuarioDestino.role;
        
        // Verificar se é professor transferindo para aluno
        if (roleOrigem === 'professor' && roleDestino === 'aluno') {
            status = 'pendente';
        }

        // Criar hash seguro
        const crypto = require('crypto');
        const hash = crypto.createHash('sha256')
            .update(`${Date.now()}_${req.user._id}_${usuarioDestino._id}_${Math.random()}`)
            .digest('hex');

        // Criar transação
        const transacao = new Transaction({
            tipo: 'enviado',
            origem: req.user._id,
            destino: usuarioDestino._id,
            quantidade,
            descricao: descricao || 'Transferência entre usuários',
            hash,
            status
        });

        await transacao.save();

        // Buscar instâncias reais do Mongoose
        const origem = await User.findById(req.user._id);
        const destino = await User.findById(usuarioDestino._id);

        if (status === 'aprovada') {
            // Atualizar saldos imediatamente
            await origem.removerCoins(quantidade);
            await destino.adicionarCoins(quantidade);
            
            // Atualizar estatísticas para conquistas
            await origem.atualizarEstatisticas('transferencia');
            await destino.atualizarEstatisticas('transferencia_recebida');
            await destino.atualizarEstatisticas('coins_ganhos', quantidade);
            
            // Verificar conquistas automaticamente
            await origem.verificarConquistas();
            await destino.verificarConquistas();
        }
        // Buscar transação com dados populados
        const transacaoCompleta = await Transaction.findById(transacao._id)
            .populate('origem', 'nome matricula role')
            .populate('destino', 'nome matricula role');

        res.status(201).json({
            message: status === 'pendente' ? 'Transferência pendente de aprovação do admin' : 'Transferência realizada com sucesso',
            transacao: transacaoCompleta
        });

    } catch (error) {
        console.error('Erro na transferência:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Validações Iniciais**
- **`destinoMatricula`**: Matrícula do usuário que receberá os coins
- **`quantidade`**: Deve ser maior que zero
- **`descricao`**: Opcional, descrição da transferência

#### **Busca do Usuário de Destino**
- **`User.findOne({ matricula: destinoMatricula })`**: Busca por matrícula
- **Retorna 404**: Se usuário não encontrado

#### **Validações de Segurança**
- **Auto-transferência**: Impede transferência para si mesmo
- **Saldo insuficiente**: Verifica se tem coins suficientes
- **Saldo ilimitado**: Admins e professores não têm limite

#### **Sistema de Aprovação**
- **Status padrão**: 'aprovada' para transferências normais
- **Status pendente**: Professor → Aluno requer aprovação
- **Controle de roles**: Verifica tipos de usuário

#### **Geração de Hash**
- **`crypto.createHash('sha256')`**: Algoritmo SHA-256
- **Dados únicos**: Timestamp + IDs + random
- **Rastreabilidade**: Hash único para cada transação

#### **Criação da Transação**
- **`tipo: 'enviado'`**: Para o usuário que envia
- **`hash`**: Hash único gerado
- **`status`**: Aprovada ou pendente

#### **Processamento de Saldo**
- **Condicional**: Só processa se status = 'aprovada'
- **`removerCoins()`**: Remove coins do remetente
- **`adicionarCoins()`**: Adiciona coins ao destinatário

#### **Atualização de Estatísticas**
- **`atualizarEstatisticas('transferencia')`**: Para quem enviou
- **`atualizarEstatisticas('transferencia_recebida')`**: Para quem recebeu
- **`atualizarEstatisticas('coins_ganhos', quantidade)`**: Coins ganhos

#### **Verificação de Conquistas**
- **`verificarConquistas()`**: Verifica se desbloqueou conquistas
- **Automático**: Para ambos os usuários

### 3. **POST /api/transaction/recompensa** - Dar Recompensa (Professor/Admin)
```javascript
router.post('/recompensa', verificarProfessor, async (req, res) => {
    try {
        const { destinoMatricula, quantidade, descricao } = req.body;

        if (!destinoMatricula || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'Matrícula de destino e quantidade válida são obrigatórias'
            });
        }

        // Buscar usuário de destino
        const usuarioDestino = await User.findOne({ matricula: destinoMatricula });
        if (!usuarioDestino) {
            return res.status(404).json({
                message: 'Usuário de destino não encontrado'
            });
        }

        // Criar transação
        const transacao = new Transaction({
            tipo: 'recebido',
            origem: req.user._id,
            destino: usuarioDestino._id,
            quantidade,
            descricao: descricao || 'Recompensa concedida',
            hash: `reward_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
        });

        await transacao.save();

        // Adicionar coins ao usuário de destino
        await usuarioDestino.adicionarCoins(quantidade);
        
        // Atualizar estatísticas para conquistas
        await usuarioDestino.atualizarEstatisticas('transferencia_recebida');
        await usuarioDestino.atualizarEstatisticas('coins_ganhos', quantidade);
        
        // Verificar conquistas automaticamente
        await usuarioDestino.verificarConquistas();

        // Buscar transação com dados populados
        const transacaoCompleta = await Transaction.findById(transacao._id)
            .populate('origem', 'nome matricula')
            .populate('destino', 'nome matricula');

        res.status(201).json({
            message: 'Recompensa concedida com sucesso',
            transacao: transacaoCompleta
        });

    } catch (error) {
        console.error('Erro ao conceder recompensa:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **`verificarProfessor`**: Apenas professores e admins podem dar recompensas

#### **Diferenças da Transferência**
- **`tipo: 'recebido'`**: Para o destinatário (não 'enviado')
- **Hash especial**: Prefixo 'reward_' para identificar recompensas
- **Sem verificação de saldo**: Professores/admins têm saldo ilimitado
- **Sempre aprovada**: Recompensas não precisam de aprovação

#### **Processamento**
- **Adiciona coins diretamente**: Sem remover de ninguém
- **Atualiza estatísticas**: Para conquistas
- **Verifica conquistas**: Processo automático

### 4. **GET /api/transaction/todas** - Listar Todas as Transações (Admin)
```javascript
router.get('/todas', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const { page = 1, limit = 20, tipo, origem, destino } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        // Construir filtros
        const filtros = {};
        if (tipo) filtros.tipo = tipo;
        if (origem) filtros.origem = origem;
        if (destino) filtros.destino = destino;

        const transacoes = await Transaction.find(filtros)
            .populate('origem', 'nome matricula')
            .populate('destino', 'nome matricula')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Transaction.countDocuments(filtros);

        res.json({
            transacoes,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar transações:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **`verificarToken` + `verificarAdmin`**: Apenas admins podem ver todas as transações

#### **Filtros Disponíveis**
- **`tipo`**: Filtrar por 'enviado' ou 'recebido'
- **`origem`**: Filtrar por usuário de origem
- **`destino`**: Filtrar por usuário de destino

#### **Paginação**
- **`limit = 20`**: Padrão maior que histórico pessoal
- **Filtros dinâmicos**: Aplicados conforme parâmetros

### 5. **POST /api/transaction/:id/aprovar** - Aprovar Transferência Pendente (Admin)
```javascript
router.post('/:id/aprovar', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const transacao = await Transaction.findById(req.params.id);
        if (!transacao) {
            return res.status(404).json({ message: 'Transação não encontrada' });
        }
        if (transacao.status !== 'pendente') {
            return res.status(400).json({ message: 'Transação já foi processada' });
        }
        // Atualizar status
        transacao.status = 'aprovada';
        await transacao.save();
        // Transferir saldo
        const User = require('../models/userModel');
        const origem = await User.findById(transacao.origem);
        const destino = await User.findById(transacao.destino);
        await origem.removerCoins(transacao.quantidade);
        await destino.adicionarCoins(transacao.quantidade);
        
        // Atualizar estatísticas para conquistas
        await origem.atualizarEstatisticas('transferencia');
        await destino.atualizarEstatisticas('transferencia_recebida');
        await destino.atualizarEstatisticas('coins_ganhos', transacao.quantidade);
        
        // Verificar conquistas automaticamente
        await origem.verificarConquistas();
        await destino.verificarConquistas();
        
        res.json({ message: 'Transferência aprovada e saldo transferido!' });
    } catch (error) {
        console.error('Erro ao aprovar transferência:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

#### **Validações**
- **Transação existe**: Verifica se ID é válido
- **Status pendente**: Só aprova transações pendentes
- **Controle de acesso**: Apenas admins podem aprovar

#### **Processamento**
- **Atualiza status**: Para 'aprovada'
- **Transfere saldo**: Remove da origem, adiciona ao destino
- **Atualiza estatísticas**: Para conquistas
- **Verifica conquistas**: Processo automático

### 6. **POST /api/transaction/:id/recusar** - Recusar Transferência Pendente (Admin)
```javascript
router.post('/:id/recusar', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const transacao = await Transaction.findById(req.params.id);
        if (!transacao) {
            return res.status(404).json({ message: 'Transação não encontrada' });
        }
        if (transacao.status !== 'pendente') {
            return res.status(400).json({ message: 'Transação já foi processada' });
        }
        transacao.status = 'recusada';
        await transacao.save();
        res.json({ message: 'Transferência recusada.' });
    } catch (error) {
        console.error('Erro ao recusar transferência:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Apenas marca como recusada**: Não transfere saldo
- **Mesmas validações**: Transação existe e está pendente
- **Resposta simples**: Confirma recusa

### 7. **GET /api/transaction/:id** - Obter Transação Específica
```javascript
router.get('/:id', verificarToken, async (req, res) => {
    try {
        const transacao = await Transaction.findById(req.params.id)
            .populate('origem', 'nome matricula')
            .populate('destino', 'nome matricula');

        if (!transacao) {
            return res.status(404).json({
                message: 'Transação não encontrada'
            });
        }

        // Verificar se o usuário tem acesso à transação
        if (!req.user.isAdmin && 
            transacao.origem._id.toString() !== req.user._id.toString() &&
            transacao.destino._id.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                message: 'Acesso negado'
            });
        }

        res.json(transacao);

    } catch (error) {
        console.error('Erro ao obter transação:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **Admins**: Podem ver qualquer transação
- **Usuários normais**: Só veem transações onde são origem ou destino
- **403 Forbidden**: Se não tem permissão

#### **Populate**
- **Dados completos**: Nome e matrícula dos usuários
- **Fácil visualização**: Para frontend

## EXPORTAÇÃO DO ROUTER
```javascript
module.exports = router;
```

**Explicação:** Exporta o router para ser usado no servidor principal.

## SEGURANÇA IMPLEMENTADA

### 1. **CONTROLE DE ACESSO**
- **`verificarToken`**: Autenticação obrigatória
- **`verificarAdmin`**: Apenas administradores
- **`verificarProfessor`**: Professores e administradores

### 2. **VALIDAÇÕES DE NEGÓCIO**
- **Auto-transferência**: Impede transferência para si mesmo
- **Saldo insuficiente**: Verifica disponibilidade de coins
- **Saldo ilimitado**: Admins/professores não têm limite

### 3. **SISTEMA DE APROVAÇÃO**
- **Professor → Aluno**: Requer aprovação de admin
- **Aluno → Aluno**: Aprovação automática
- **Admin/Professor**: Sempre aprovado

### 4. **RASTREABILIDADE**
- **Hash único**: Para cada transação
- **Timestamps**: Rastreamento temporal
- **Logs de erro**: Para debug

## FUNCIONALIDADES ESPECIAIS

### 1. **SISTEMA DE CONQUISTAS**
- **Atualização automática**: Ao transferir/receber
- **Verificação de conquistas**: Processo automático
- **Estatísticas**: Rastreamento de atividades

### 2. **PAGINAÇÃO**
- **Filtros múltiplos**: Tipo, origem, destino
- **Ordenação**: Por data de criação
- **Informações completas**: Total, páginas, etc.

### 3. **DIFERENÇAS DE ROLE**
- **Alunos**: Saldo limitado, transferências normais
- **Professores**: Saldo ilimitado, podem dar recompensas
- **Admins**: Controle total, aprovação de transações

### 4. **TIPOS DE TRANSFERÊNCIA**
- **Transferência normal**: Entre usuários comuns
- **Recompensa**: Professor → Aluno (sem remoção de saldo)
- **Transferência pendente**: Professor → Aluno (requer aprovação)
# DOCUMENTAÇÃO DETALHADA - ROTAS DE METAS (goal.js)

## VISÃO GERAL
Este arquivo define todas as rotas relacionadas ao sistema de metas (goals) do IFC Coin. Inclui criação, listagem, conclusão de metas, sistema de aprovação de solicitações, upload de evidências e gerenciamento administrativo. O sistema implementa controle de acesso baseado em roles e utiliza middleware de autenticação.

## ESTRUTURA DO ARQUIVO

### 1. IMPORTAÇÕES NECESSÁRIAS
```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Goal = require('../models/goalModel');
const User = require('../models/userModel');
const GoalRequest = require('../models/goalRequestModel');
const { verificarToken, verificarAdmin, verificarProfessor } = require('../middleware/auth');
```
**Explicação detalhada:**

#### **`express`**
Framework web para Node.js, usado para criar o router.

#### **`multer`**
Middleware para lidar com upload de arquivos multipart/form-data.

#### **`path`**
Módulo nativo do Node.js para manipulação de caminhos de arquivo.

#### **`fs`**
Módulo nativo do Node.js para operações de sistema de arquivos.

#### **`Goal`**
Modelo de metas importado do arquivo `goalModel.js`.

#### **`User`**
Modelo de usuários importado do arquivo `userModel.js`.

#### **`GoalRequest`**
Modelo de solicitações de metas importado do arquivo `goalRequestModel.js`.

#### **`verificarToken, verificarAdmin, verificarProfessor`**
Middleware de autenticação importado do arquivo `auth.js`.

### 2. CRIAÇÃO DO ROUTER
```javascript
const router = express.Router();
```
**Explicação:** Cria um novo router do Express que será usado para agrupar todas as rotas de metas.

### 3. CONFIGURAÇÃO DO MULTER PARA EVIDÊNCIAS
```javascript
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/evidencias';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // Gera nome único para o arquivo
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'evidencia-' + req.user._id + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // Limite de 10MB
  },
  fileFilter: function (req, file, cb) {
    // Permite apenas tipos específicos de arquivos
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'text/plain'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Tipo de arquivo não permitido'), false);
    }
  }
});
```

**Explicação detalhada:**

#### **`multer.diskStorage`**
Configura o multer para armazenar arquivos em disco ao invés de memória.

#### **`destination`**
- **`uploads/evidencias`**: Diretório de destino
- **`fs.existsSync()`**: Verifica se diretório existe
- **`fs.mkdirSync()`**: Cria diretório se não existir
- **`{ recursive: true }`**: Cria diretórios pai se necessário

#### **`filename`**
- **Nome único**: Timestamp + random + extensão original
- **Prefixo**: 'evidencia-' + ID do usuário
- **Extensão**: Mantém extensão original do arquivo

#### **`limits.fileSize: 10 * 1024 * 1024`**
Define limite de 10MB para upload de arquivos.

#### **`fileFilter`**
- **Tipos permitidos**: JPEG, PNG, GIF, PDF, TXT
- **Validação**: Verifica MIME type do arquivo
- **Rejeição**: Para tipos não permitidos

## ROTAS IMPLEMENTADAS

### 1. **GET /api/goal** - Listar Metas
```javascript
router.get('/', verificarToken, async (req, res) => {
    try {
        const { tipo, page = 1, limit = 10 } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        // Se for admin, mostrar todas as metas
        if (req.user.role === 'admin') {
            const filtros = {};
            if (tipo) {filtros.tipo = tipo;}

            const metas = await Goal.find(filtros)
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit));

            const total = await Goal.countDocuments(filtros);

            res.json({
                metas: metas,
                paginacao: {
                    pagina: parseInt(page),
                    limite: parseInt(limit),
                    total,
                    paginas: Math.ceil(total / parseInt(limit))
                }
            });
        } else {
            // Para usuários normais, mostrar apenas metas ativas e válidas
            const filtros = { ativo: true };
            if (tipo) {filtros.tipo = tipo;}

            // Validade temporal: metas sem data de fim ou com data de fim futura
            const agora = new Date();
            filtros.$or = [
                { dataFim: null },
                { dataFim: { $gte: agora } }
            ];

            // Busca metas no banco
            const metas = await Goal.find(filtros)
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(parseInt(limit));

            // Marca se o usuário já concluiu cada meta
            const metasComStatus = await Promise.all(metas.map(async (meta) => {
                const usuarioConcluiu = meta.usuariosConcluidos.includes(req.user._id);
                let temSolicitacaoPendente = false;
                if (!usuarioConcluiu && meta.requerAprovacao) {
                    const pendente = await GoalRequest.findOne({ goal: meta._id, aluno: req.user._id, status: 'pendente' });
                    temSolicitacaoPendente = !!pendente;
                }
                return {
                    ...meta.toObject(),
                    usuarioConcluiu,
                    temSolicitacaoPendente
                };
            }));

            const total = await Goal.countDocuments(filtros);

            res.json({
                metas: metasComStatus,
                paginacao: {
                    pagina: parseInt(page),
                    limite: parseInt(limit),
                    total,
                    paginas: Math.ceil(total / parseInt(limit))
                }
            });
        }

    } catch (error) {
        console.error('Erro ao listar metas:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso Diferenciado**
- **Admins**: Veem todas as metas (ativas e inativas)
- **Usuários normais**: Veem apenas metas ativas e válidas

#### **Filtros para Usuários Normais**
- **`ativo: true`**: Apenas metas ativas
- **Validade temporal**: Metas sem data de fim OU com data futura
- **`$or`**: Operador lógico OR do MongoDB

#### **Status Personalizado**
- **`usuarioConcluiu`**: Se o usuário já completou a meta
- **`temSolicitacaoPendente`**: Se tem solicitação aguardando aprovação
- **`Promise.all()`**: Processa todas as metas em paralelo

### 2. **GET /api/goal/listar** - Listar Metas (Compatibilidade)
```javascript
router.get('/listar', verificarToken, async (req, res) => {
    // ... código similar ao anterior, mas apenas para usuários normais
});
```

**Explicação:** Endpoint mantido para compatibilidade com versões anteriores.

### 3. **GET /api/goal/minhas** - Metas Concluídas pelo Usuário
```javascript
router.get('/minhas', verificarToken, async (req, res) => {
    try {
        const metas = await Goal.find({
            usuariosConcluidos: req.user._id
        }).sort({ createdAt: -1 });

        res.json(metas);

    } catch (error) {
        console.error('Erro ao buscar metas do usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Busca específica**: Metas onde o usuário está em `usuariosConcluidos`
- **Ordenação**: Por data de criação (mais recente primeiro)
- **Resposta simples**: Lista de metas concluídas

### 4. **POST /api/goal** - Criar Nova Meta (Admin)
```javascript
router.post('/', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const { 
            titulo, 
            descricao, 
            tipo, 
            requisito, 
            recompensa, 
            requerAprovacao,
            maxConclusoes,
            periodoValidade,
            dataInicio,
            dataFim,
            evidenciaObrigatoria,
            tipoEvidencia,
            descricaoEvidencia
        } = req.body;

        // Validação dos campos obrigatórios
        if (!titulo || !descricao || !tipo || !requisito || !recompensa) {
            return res.status(400).json({
                message: 'Título, descrição, tipo, requisito e recompensa são obrigatórios'
            });
        }

        if (requisito <= 0 || recompensa <= 0) {
            return res.status(400).json({
                message: 'Requisito e recompensa devem ser valores positivos'
            });
        }

        // Cria nova meta
        const novaMeta = new Goal({
            titulo: titulo.trim(),
            descricao: descricao.trim(),
            tipo,
            requisito,
            recompensa,
            usuariosConcluidos: [],
            requerAprovacao: !!requerAprovacao,
            maxConclusoes: maxConclusoes || null,
            periodoValidade: periodoValidade || null,
            dataInicio: dataInicio ? new Date(dataInicio) : new Date(),
            dataFim: dataFim ? new Date(dataFim) : null,
            evidenciaObrigatoria: !!evidenciaObrigatoria,
            tipoEvidencia: tipoEvidencia || 'texto',
            descricaoEvidencia: descricaoEvidencia || null
        });

        await novaMeta.save();

        res.status(201).json({
            message: 'Meta criada com sucesso',
            meta: novaMeta
        });

    } catch (error) {
        console.error('Erro ao criar meta:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **`verificarAdmin`**: Apenas administradores podem criar metas

#### **Validações**
- **Campos obrigatórios**: título, descrição, tipo, requisito, recompensa
- **Valores positivos**: requisito e recompensa > 0

#### **Processamento de Dados**
- **`trim()`**: Remove espaços em branco
- **`!!requerAprovacao`**: Converte para boolean
- **`new Date()`**: Converte strings para datas
- **Valores padrão**: Para campos opcionais

### 5. **POST /api/goal/criar** - Criar Meta (Professor/Admin)
```javascript
router.post('/criar', verificarToken, verificarProfessor, async (req, res) => {
    // ... código similar, mas com menos campos
});
```

**Explicação:** Versão simplificada para professores, mantida para compatibilidade.

### 6. **POST /api/goal/concluir/:id** - Solicitar Conclusão de Meta
```javascript
router.post('/concluir/:id', verificarToken, upload.single('evidenciaArquivo'), async (req, res) => {
    try {
        const meta = await Goal.findById(req.params.id);

        if (!meta) {
            return res.status(404).json({
                message: 'Meta não encontrada'
            });
        }

        // Verifica se a meta está ativa
        if (!meta.ativo) {
            return res.status(400).json({
                message: 'Meta não está mais ativa'
            });
        }

        // Verifica se o usuário já concluiu
        if (meta.usuariosConcluidos.includes(req.user._id)) {
            return res.status(400).json({
                message: 'Meta já foi concluída'
            });
        }

        // Se requer aprovação, criar GoalRequest pendente
        if (meta.requerAprovacao) {
            // Verifica se já existe solicitação pendente para essa meta e usuário
            const jaSolicitada = await GoalRequest.findOne({ goal: meta._id, aluno: req.user._id, status: 'pendente' });
            if (jaSolicitada) {
                return res.status(400).json({ message: 'Já existe uma solicitação pendente para essa meta.' });
            }
            let evidenciaArquivoPath = undefined;
            if (req.file) {
                evidenciaArquivoPath = req.file.path;
            }
            const goalRequest = new GoalRequest({
                goal: meta._id,
                aluno: req.user._id,
                comentario: req.body.comentario,
                evidenciaTexto: req.body.evidenciaTexto,
                evidenciaArquivo: evidenciaArquivoPath,
                status: 'pendente',
            });
            await goalRequest.save();
            return res.status(200).json({ message: 'Solicitação enviada para análise!', goalRequest });
        }

        // Se não requer aprovação, concluir direto
        meta.usuariosConcluidos.push(req.user._id);
        await meta.save();
        await req.user.adicionarCoins(meta.recompensa);
        
        // Atualizar estatísticas para conquistas
        await req.user.atualizarEstatisticas('meta_concluida');
        await req.user.atualizarEstatisticas('coins_ganhos', meta.recompensa);
        
        // Verificar conquistas automaticamente
        await req.user.verificarConquistas();
        
        const Transaction = require('../models/transactionModel');
        const transacao = new Transaction({
            tipo: 'recebido',
            origem: null, // Sistema
            destino: req.user._id,
            quantidade: meta.recompensa,
            descricao: `Recompensa por concluir meta: ${meta.titulo}`,
            hash: `goal_${meta._id}_${req.user._id}_${Date.now()}`
        });
        await transacao.save();
        res.status(200).json({ message: 'Meta concluída com sucesso!', recompensaAdicionada: meta.recompensa });
    } catch (error) {
        console.error('Erro ao concluir meta:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

#### **Validações Iniciais**
- **Meta existe**: Verifica se ID é válido
- **Meta ativa**: Verifica se está disponível
- **Não concluída**: Verifica se usuário já completou

#### **Sistema de Aprovação**
- **`requerAprovacao`**: Se true, cria solicitação pendente
- **Verificação de duplicata**: Evita solicitações múltiplas
- **Upload de evidência**: Processa arquivo se enviado

#### **Conclusão Direta**
- **Adiciona usuário**: À lista de concluídos
- **Adiciona coins**: Recompensa imediata
- **Atualiza estatísticas**: Para conquistas
- **Cria transação**: Registra a recompensa

### 7. **GET /api/goal/solicitacoes** - Listar Solicitações
```javascript
router.get('/solicitacoes', verificarToken, async (req, res) => {
    try {
        // Apenas admin ou professor pode ver todas
        if (!["admin", "professor"].includes(req.user.role)) {
            return res.status(403).json({ message: 'Acesso negado' });
        }
        const status = req.query.status;
        const filtro = status ? { status } : {};
        const solicitacoes = await GoalRequest.find(filtro)
            .populate('goal')
            .populate('aluno', 'nome email matricula')
            .sort({ createdAt: -1 });
        res.json(solicitacoes);
    } catch (error) {
        console.error('Erro ao listar solicitações:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **Apenas admin/professor**: Podem ver solicitações
- **Filtro por status**: Opcional (pendente, aprovada, recusada)

#### **Populate**
- **`goal`**: Dados completos da meta
- **`aluno`**: Nome, email e matrícula do solicitante

### 8. **POST /api/goal/solicitacoes/:id/aprovar** - Aprovar Solicitação
```javascript
router.post('/solicitacoes/:id/aprovar', verificarToken, async (req, res) => {
    try {
        if (!["admin", "professor"].includes(req.user.role)) {
            return res.status(403).json({ message: 'Acesso negado' });
        }
        const solicitacao = await GoalRequest.findById(req.params.id).populate('goal').populate('aluno');
        if (!solicitacao) {
            return res.status(404).json({ message: 'Solicitação não encontrada' });
        }
        if (solicitacao.status !== 'pendente') {
            return res.status(400).json({ message: 'Solicitação já foi processada' });
        }
        // Marcar como aprovada
        solicitacao.status = 'aprovada';
        solicitacao.analisadoPor = req.user._id;
        solicitacao.dataAnalise = new Date();
        solicitacao.resposta = req.body.resposta;
        await solicitacao.save();
        // Marcar meta como concluída para o aluno
        const meta = await Goal.findById(solicitacao.goal._id);
        if (!meta.usuariosConcluidos.includes(solicitacao.aluno._id)) {
            meta.usuariosConcluidos.push(solicitacao.aluno._id);
            await meta.save();
            // Adicionar coins ao aluno
            const aluno = await User.findById(solicitacao.aluno._id);
            await aluno.adicionarCoins(meta.recompensa);
            
            // Atualizar estatísticas para conquistas
            await aluno.atualizarEstatisticas('meta_concluida');
            await aluno.atualizarEstatisticas('coins_ganhos', meta.recompensa);
            
            // Verificar conquistas automaticamente
            await aluno.verificarConquistas();
            
            // Criar transação
            const Transaction = require('../models/transactionModel');
            const transacao = new Transaction({
                tipo: 'recebido',
                origem: null,
                destino: aluno._id,
                quantidade: meta.recompensa,
                descricao: `Recompensa por concluir meta: ${meta.titulo}`,
                hash: `goal_${meta._id}_${aluno._id}_${Date.now()}`
            });
            await transacao.save();
        }
        res.json({ message: 'Solicitação aprovada e coins creditados!', solicitacao });
    } catch (error) {
        console.error('Erro ao aprovar solicitação:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

#### **Validações**
- **Controle de acesso**: Apenas admin/professor
- **Solicitação existe**: Verifica se ID é válido
- **Status pendente**: Só aprova solicitações pendentes

#### **Processamento**
- **Atualiza solicitação**: Status, analisador, data, resposta
- **Adiciona usuário**: À lista de concluídos da meta
- **Adiciona coins**: Recompensa ao aluno
- **Atualiza estatísticas**: Para conquistas
- **Cria transação**: Registra a recompensa

### 9. **POST /api/goal/solicitacoes/:id/recusar** - Recusar Solicitação
```javascript
router.post('/solicitacoes/:id/recusar', verificarToken, async (req, res) => {
    try {
        if (!["admin", "professor"].includes(req.user.role)) {
            return res.status(403).json({ message: 'Acesso negado' });
        }
        const solicitacao = await GoalRequest.findById(req.params.id).populate('goal').populate('aluno');
        if (!solicitacao) {
            return res.status(404).json({ message: 'Solicitação não encontrada' });
        }
        if (solicitacao.status !== 'pendente') {
            return res.status(400).json({ message: 'Solicitação já foi processada' });
        }
        solicitacao.status = 'recusada';
        solicitacao.analisadoPor = req.user._id;
        solicitacao.dataAnalise = new Date();
        solicitacao.resposta = req.body.resposta;
        await solicitacao.save();
        res.json({ message: 'Solicitação recusada.', solicitacao });
    } catch (error) {
        console.error('Erro ao recusar solicitação:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Apenas marca como recusada**: Não adiciona coins
- **Mesmas validações**: Controle de acesso e status
- **Registra análise**: Quem analisou, quando e resposta

### 10. **PUT /api/goal/:id** - Atualizar Meta (Admin)
```javascript
router.put('/:id', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const { 
            titulo, 
            descricao, 
            tipo, 
            requisito, 
            recompensa, 
            requerAprovacao,
            maxConclusoes,
            periodoValidade,
            dataInicio,
            dataFim,
            evidenciaObrigatoria,
            tipoEvidencia,
            descricaoEvidencia
        } = req.body;
        const metaId = req.params.id;

        const meta = await Goal.findById(metaId);
        if (!meta) {
            return res.status(404).json({
                message: 'Meta não encontrada'
            });
        }

        // Atualiza campos
        if (titulo !== undefined) { meta.titulo = titulo.trim(); }
        if (descricao !== undefined) { meta.descricao = descricao.trim(); }
        if (tipo !== undefined) { meta.tipo = tipo; }
        if (requisito !== undefined) { meta.requisito = requisito; }
        if (recompensa !== undefined) { meta.recompensa = recompensa; }
        if (requerAprovacao !== undefined) { meta.requerAprovacao = !!requerAprovacao; }
        if (maxConclusoes !== undefined) { meta.maxConclusoes = maxConclusoes; }
        if (periodoValidade !== undefined) { meta.periodoValidade = periodoValidade; }
        if (dataInicio !== undefined) { meta.dataInicio = dataInicio ? new Date(dataInicio) : new Date(); }
        if (dataFim !== undefined) { meta.dataFim = dataFim ? new Date(dataFim) : null; }
        if (evidenciaObrigatoria !== undefined) { meta.evidenciaObrigatoria = !!evidenciaObrigatoria; }
        if (tipoEvidencia !== undefined) { meta.tipoEvidencia = tipoEvidencia; }
        if (descricaoEvidencia !== undefined) { meta.descricaoEvidencia = descricaoEvidencia; }

        await meta.save();

        res.json({
            message: 'Meta atualizada com sucesso',
            meta
        });

    } catch (error) {
        console.error('Erro ao atualizar meta:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Controle de Acesso**
- **`verificarAdmin`**: Apenas administradores podem atualizar

#### **Atualização Condicional**
- **`!== undefined`**: Só atualiza se campo foi enviado
- **`trim()`**: Remove espaços em branco
- **Conversão de tipos**: Boolean, Date, etc.

### 11. **DELETE /api/goal/:id** - Deletar Meta (Admin)
```javascript
router.delete('/:id', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const meta = await Goal.findById(req.params.id);

        if (!meta) {
            return res.status(404).json({
                message: 'Meta não encontrada'
            });
        }

        await Goal.findByIdAndDelete(req.params.id);

        res.json({
            message: 'Meta deletada com sucesso'
        });

    } catch (error) {
        console.error('Erro ao deletar meta:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Hard delete**: Remove meta permanentemente
- **Validação**: Verifica se meta existe antes de deletar
- **Controle de acesso**: Apenas admins podem deletar

### 12. **GET /api/goal/:id** - Obter Meta Específica
```javascript
router.get('/:id', verificarToken, async (req, res) => {
    try {
        const meta = await Goal.findById(req.params.id);

        if (!meta) {
            return res.status(404).json({
                message: 'Meta não encontrada'
            });
        }

        // Verifica se o usuário já concluiu
        const usuarioConcluiu = meta.usuariosConcluidos.includes(req.user._id);
        
        res.json({
            ...meta.toObject(),
            usuarioConcluiu
        });

    } catch (error) {
        console.error('Erro ao obter meta:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Busca por ID**: Meta específica
- **Status personalizado**: Se usuário já concluiu
- **Dados completos**: Meta + status do usuário

### 13. **SERVIÇO DE ARQUIVOS ESTÁTICOS**
```javascript
router.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
```

**Explicação detalhada:**

#### **Funcionalidade**
- **Servir evidências**: Arquivos de evidências enviados
- **Caminho relativo**: `../uploads` a partir do diretório atual
- **Middleware estático**: Express serve arquivos automaticamente

## EXPORTAÇÃO DO ROUTER
```javascript
module.exports = router;
```

**Explicação:** Exporta o router para ser usado no servidor principal.

## SEGURANÇA IMPLEMENTADA

### 1. **CONTROLE DE ACESSO**
- **`verificarToken`**: Autenticação obrigatória
- **`verificarAdmin`**: Apenas administradores
- **`verificarProfessor`**: Professores e administradores

### 2. **VALIDAÇÃO DE ARQUIVOS**
- **Tipos permitidos**: JPEG, PNG, GIF, PDF, TXT
- **Limite de tamanho**: 10MB máximo
- **Nome único**: Evita conflitos de arquivo

### 3. **VALIDAÇÕES DE NEGÓCIO**
- **Meta ativa**: Verifica se está disponível
- **Não concluída**: Evita conclusões duplicadas
- **Solicitação única**: Evita solicitações múltiplas

### 4. **SISTEMA DE APROVAÇÃO**
- **Metas com aprovação**: Requer análise de admin/professor
- **Metas automáticas**: Conclusão imediata
- **Rastreabilidade**: Quem analisou e quando

## FUNCIONALIDADES ESPECIAIS

### 1. **SISTEMA DE CONQUISTAS**
- **Atualização automática**: Ao concluir metas
- **Verificação de conquistas**: Processo automático
- **Estatísticas**: Rastreamento de atividades

### 2. **UPLOAD DE EVIDÊNCIAS**
- **Múltiplos tipos**: Imagens, PDFs, textos
- **Armazenamento seguro**: Em disco com nomes únicos
- **Validação de tipo**: MIME type checking

### 3. **CONTROLE TEMPORAL**
- **Data de início**: Quando meta começa a valer
- **Data de fim**: Quando meta expira
- **Validação automática**: Metas expiradas não aparecem

### 4. **SISTEMA DE REQUEST**
- **Solicitações pendentes**: Para metas que requerem aprovação
- **Evidências**: Textuais e arquivos
- **Análise**: Aprovação/recusa com comentários
# DOCUMENTAÇÃO DETALHADA - ROTAS DE CONQUISTAS (achievement.js)

## Visão Geral
O arquivo `backend/routes/achievement.js` gerencia todas as operações relacionadas ao sistema de conquistas da aplicação IFC Coin. Este módulo fornece endpoints para listar conquistas disponíveis, obter conquistas de usuários específicos, verificar conquistas automaticamente e gerenciar categorias.

## Estrutura do Arquivo

### 1. IMPORTAÇÕES E CONFIGURAÇÃO INICIAL

```javascript
const express = require('express');
const Achievement = require('../models/achievementModel');
const { verificarToken } = require('../middleware/auth');

const router = express.Router();
```

**Explicação linha por linha:**

- **`const express = require('express');`**: Importa o framework Express.js, que é a base para criar a aplicação web e definir as rotas da API.

- **`const Achievement = require('../models/achievementModel');`**: Importa o modelo de dados `Achievement` que define a estrutura e comportamento dos documentos de conquistas no MongoDB. Este modelo contém os schemas e métodos para interagir com a coleção de conquistas.

- **`const { verificarToken } = require('../middleware/auth');`**: Importa especificamente a função `verificarToken` do middleware de autenticação. Esta função será usada para proteger as rotas, garantindo que apenas usuários autenticados possam acessar os endpoints de conquistas.

- **`const router = express.Router();`**: Cria uma nova instância do Router do Express. O Router permite organizar as rotas de forma modular, agrupando endpoints relacionados em um único arquivo. Isso facilita a manutenção e organização do código.

### 2. ROTA PRINCIPAL - LISTAR CONQUISTAS

```javascript
// GET /api/achievement - Listar todas as conquistas disponíveis (somente leitura)
router.get('/', verificarToken, async (req, res) => {
    try {
        const { tipo, categoria, page = 1, limit = 10 } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        // Construir filtros
        const filtros = {};
        if (tipo) filtros.tipo = tipo;
        if (categoria) filtros.categoria = categoria;

        const conquistas = await Achievement.find(filtros)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Achievement.countDocuments(filtros);

        res.json({
            conquistas,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar conquistas:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

**Cabeçalho da rota:**
- **`router.get('/', verificarToken, async (req, res) => {`**: Define uma rota GET para o caminho raiz `/api/achievement`. A função `verificarToken` é executada antes da função principal para verificar se o usuário está autenticado. A função principal é assíncrona para permitir operações de banco de dados.

**Extração de parâmetros:**
- **`const { tipo, categoria, page = 1, limit = 10 } = req.query;`**: Extrai parâmetros da query string da requisição HTTP. Usa desestruturação com valores padrão:
  - `tipo`: Filtro por tipo de conquista (opcional)
  - `categoria`: Filtro por categoria (opcional)
  - `page`: Número da página (padrão: 1)
  - `limit`: Limite de itens por página (padrão: 10)

**Cálculo de paginação:**
- **`const skip = (parseInt(page) - 1) * parseInt(limit);`**: Calcula quantos documentos "pular" para chegar à página desejada. Por exemplo, se estamos na página 2 com limite 10, pulamos 10 documentos.

**Construção de filtros:**
- **`const filtros = {};`**: Inicializa um objeto vazio para armazenar os filtros de consulta.
- **`if (tipo) filtros.tipo = tipo;`**: Se o parâmetro `tipo` foi fornecido, adiciona ao objeto de filtros.
- **`if (categoria) filtros.categoria = categoria;`**: Se o parâmetro `categoria` foi fornecido, adiciona ao objeto de filtros.

**Consulta ao banco de dados:**
- **`const conquistas = await Achievement.find(filtros)`**: Executa uma consulta no MongoDB usando o modelo Achievement. Aplica os filtros construídos anteriormente.
- **`.sort({ createdAt: -1 })`**: Ordena os resultados pela data de criação em ordem decrescente (mais recentes primeiro).
- **`.skip(skip)`**: Pula os documentos calculados para a paginação.
- **`.limit(parseInt(limit))`**: Limita o número de resultados retornados.

**Contagem total:**
- **`const total = await Achievement.countDocuments(filtros);`**: Conta o número total de documentos que correspondem aos filtros, sem aplicar paginação.

**Resposta estruturada:**
- **`res.json({...})`**: Retorna uma resposta JSON com:
  - `conquistas`: Array com as conquistas encontradas
  - `paginacao`: Objeto com informações de paginação:
    - `pagina`: Página atual
    - `limite`: Itens por página
    - `total`: Total de documentos
    - `paginas`: Total de páginas calculado

**Tratamento de erro:**
- **`catch (error) => {`**: Captura qualquer erro que ocorra durante a execução.
- **`console.error('Erro ao listar conquistas:', error);`**: Registra o erro no console para debugging.
- **`res.status(500).json({...})`**: Retorna erro 500 (Internal Server Error) com mensagem genérica.

### 3. ROTA DE COMPATIBILIDADE - LISTAR CONQUISTAS

```javascript
// GET /api/achievement/listar - Listar conquistas disponíveis (mantido para compatibilidade)
router.get('/listar', verificarToken, async (req, res) => {
    // ... código idêntico ao anterior
});
```

**Explicação:**
Esta rota é idêntica à rota principal (`/`), mas mantida para garantir compatibilidade com versões anteriores da API. Alguns clientes podem estar usando o endpoint `/listar` em vez do endpoint raiz.

### 4. ROTA PARA LISTAR CATEGORIAS

```javascript
// GET /api/achievement/categorias - Listar categorias disponíveis
router.get('/categorias', verificarToken, async (req, res) => {
    try {
        const categorias = await Achievement.distinct('categoria');
        res.json(categorias.filter(cat => cat)); // Remove valores null/undefined

    } catch (error) {
        console.error('Erro ao buscar categorias:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

**Consulta de categorias únicas:**
- **`const categorias = await Achievement.distinct('categoria');`**: Usa o método `distinct()` do Mongoose para obter todos os valores únicos do campo `categoria` em todos os documentos de conquistas. Isso retorna um array com todas as categorias existentes.

**Filtragem de valores nulos:**
- **`res.json(categorias.filter(cat => cat));`**: Filtra o array de categorias removendo valores `null`, `undefined` ou vazios. A função `filter(cat => cat)` mantém apenas valores "truthy".

### 5. ROTA PARA OBTER CONQUISTA ESPECÍFICA

```javascript
// GET /api/achievement/:id - Obter conquista específica
router.get('/:id', verificarToken, async (req, res) => {
    try {
        const achievement = await Achievement.findById(req.params.id);
        
        if (!achievement) {
            return res.status(404).json({ message: 'Conquista não encontrada' });
        }
        
        res.json(achievement);
    } catch (error) {
        console.error('Erro ao buscar conquista:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

**Parâmetro dinâmico:**
- **`router.get('/:id', ...)`**: Define uma rota com parâmetro dinâmico `:id`. O valor será acessível via `req.params.id`.

**Busca por ID:**
- **`const achievement = await Achievement.findById(req.params.id);`**: Busca uma conquista específica no banco de dados usando o ID fornecido na URL.

**Verificação de existência:**
- **`if (!achievement) {`**: Verifica se a conquista foi encontrada.
- **`return res.status(404).json({ message: 'Conquista não encontrada' });`**: Se não encontrada, retorna erro 404 (Not Found) com mensagem explicativa.

**Resposta de sucesso:**
- **`res.json(achievement);`**: Se encontrada, retorna a conquista completa em formato JSON.

### 6. ROTA PARA OBTER CONQUISTAS DO USUÁRIO

```javascript
// GET /api/achievement/usuario/conquistas - Obter conquistas do usuário logado
router.get('/usuario/conquistas', verificarToken, async (req, res) => {
    try {
        const User = require('../models/userModel');
        const user = await User.findById(req.user._id).populate('conquistas.achievement');
        
        if (!user) {
            return res.status(404).json({ message: 'Usuário não encontrado' });
        }

        res.json({
            conquistas: user.conquistas,
            estatisticas: user.estatisticas
        });
    } catch (error) {
        console.error('Erro ao buscar conquistas do usuário:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

**Importação dinâmica:**
- **`const User = require('../models/userModel');`**: Importa o modelo User dentro da função. Isso é feito aqui porque o modelo User não é usado em outras partes deste arquivo.

**Busca do usuário com população:**
- **`const user = await User.findById(req.user._id)`**: Busca o usuário pelo ID extraído do token JWT (armazenado em `req.user._id`).
- **`.populate('conquistas.achievement')`**: Popula (substitui) as referências de conquistas pelos documentos completos. Isso converte IDs em objetos completos de conquistas.

**Verificação de existência:**
- **`if (!user) {`**: Verifica se o usuário foi encontrado no banco de dados.

**Resposta estruturada:**
- **`res.json({ conquistas: user.conquistas, estatisticas: user.estatisticas })`**: Retorna tanto as conquistas quanto as estatísticas do usuário em uma única resposta.

### 7. ROTA PARA VERIFICAR CONQUISTAS AUTOMATICAMENTE

```javascript
// POST /api/achievement/usuario/verificar - Verificar e adicionar conquistas automaticamente
router.post('/usuario/verificar', verificarToken, async (req, res) => {
    try {
        const User = require('../models/userModel');
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({ message: 'Usuário não encontrado' });
        }

        // Verificar conquistas automaticamente
        const conquistasAdicionadas = await user.verificarConquistas();
        
        // Buscar usuário atualizado com conquistas populadas
        const userAtualizado = await User.findById(req.user._id).populate('conquistas.achievement');

        res.json({
            message: `${conquistasAdicionadas.length} conquista(s) adicionada(s)`,
            conquistasAdicionadas,
            conquistas: userAtualizado.conquistas,
            estatisticas: userAtualizado.estatisticas
        });
    } catch (error) {
        console.error('Erro ao verificar conquistas:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});
```

**Explicação detalhada:**

**Método POST:**
- **`router.post('/usuario/verificar', ...)`**: Define uma rota POST para acionar a verificação automática de conquistas.

**Busca inicial do usuário:**
- **`const user = await User.findById(req.user._id);`**: Busca o usuário sem população para executar a verificação.

**Verificação automática:**
- **`const conquistasAdicionadas = await user.verificarConquistas();`**: Chama o método `verificarConquistas()` definido no modelo User. Este método analisa as estatísticas do usuário e adiciona conquistas automaticamente quando os critérios são atendidos.

**Busca do usuário atualizado:**
- **`const userAtualizado = await User.findById(req.user._id).populate('conquistas.achievement');`**: Busca novamente o usuário, agora com as conquistas populadas para retornar dados completos.

**Resposta detalhada:**
- **`message`**: Mensagem informando quantas conquistas foram adicionadas.
- **`conquistasAdicionadas`**: Array com as conquistas que foram adicionadas nesta verificação.
- **`conquistas`**: Lista completa de conquistas do usuário (após a verificação).
- **`estatisticas`**: Estatísticas atualizadas do usuário.

### 8. EXPORTAÇÃO DO ROUTER

```javascript
module.exports = router;
```

**Explicação:**
Exporta o router configurado para ser usado no arquivo principal do servidor (`server.js`), onde será registrado como middleware para o caminho `/api/achievement`.

## Funcionalidades Principais

### 1. **Sistema de Paginação**
- Implementa paginação completa com parâmetros `page` e `limit`
- Calcula automaticamente o número total de páginas
- Permite navegação eficiente em grandes conjuntos de dados

### 2. **Sistema de Filtros**
- Filtros por `tipo` de conquista
- Filtros por `categoria` de conquista
- Filtros combináveis para consultas complexas

### 3. **Verificação Automática de Conquistas**
- Endpoint dedicado para verificar conquistas automaticamente
- Utiliza o método `verificarConquistas()` do modelo User
- Retorna conquistas recém-adicionadas e estatísticas atualizadas

### 4. **População de Referências**
- Usa `populate()` para converter IDs de conquistas em objetos completos
- Garante que o frontend receba dados completos sem necessidade de consultas adicionais

### 5. **Tratamento de Erros Robusto**
- Try-catch em todas as operações assíncronas
- Logs de erro detalhados para debugging
- Respostas de erro padronizadas

## Segurança

### 1. **Autenticação Obrigatória**
- Todas as rotas usam `verificarToken` como middleware
- Garante que apenas usuários autenticados acessem os dados

### 2. **Validação de Parâmetros**
- Conversão segura de strings para números (`parseInt()`)
- Valores padrão para evitar erros de paginação
- Filtros opcionais que não quebram a consulta

## Integração com o Sistema

### 1. **Modelo Achievement**
- Utiliza o modelo `Achievement` para operações de banco de dados
- Aproveita os schemas e validações definidos no modelo

### 2. **Modelo User**
- Importação dinâmica do modelo User quando necessário
- Utiliza métodos como `verificarConquistas()` e `populate()`

### 3. **Middleware de Autenticação**
- Integra com o sistema de autenticação JWT
- Acessa dados do usuário via `req.user._id`

## Padrões de Resposta

### 1. **Sucesso (200)**
```json
{
    "conquistas": [...],
    "paginacao": {
        "pagina": 1,
        "limite": 10,
        "total": 50,
        "paginas": 5
    }
}
```

### 2. **Erro 404**
```json
{
    "message": "Conquista não encontrada"
}
```

### 3. **Erro 500**
```json
{
    "message": "Erro interno do servidor"
}
```

## Considerações de Performance

### 1. **Índices de Banco de Dados**
- Recomenda-se criar índices nos campos `tipo`, `categoria` e `createdAt`
- Índices compostos podem melhorar consultas com múltiplos filtros

### 2. **Paginação Eficiente**
- Uso de `skip()` e `limit()` para paginação
- Contagem separada para evitar carregar todos os dados

### 3. **População Seletiva**
- População apenas quando necessário
- Evita carregar dados desnecessários

Este arquivo é fundamental para o sistema de gamificação, fornecendo todas as funcionalidades necessárias para gerenciar e consultar conquistas de forma eficiente e segura.
# DOCUMENTAÇÃO DETALHADA - ROTAS ADMINISTRATIVAS (admin.js)

## Visão Geral
O arquivo `backend/routes/admin.js` gerencia todas as funcionalidades administrativas da aplicação IFC Coin. Este módulo é responsável por gerenciar solicitações de professores, aprovar ou recusar candidatos, e fornecer estatísticas sobre o processo de aprovação. Todas as rotas neste arquivo requerem privilégios de administrador.

## Estrutura do Arquivo

### 1. IMPORTAÇÕES E CONFIGURAÇÃO INICIAL

```javascript
const express = require('express');
const User = require('../models/userModel');
const { verificarToken, verificarAdmin } = require('../middleware/auth');

const router = express.Router();
```

**Explicação linha por linha:**

- **`const express = require('express');`**: Importa o framework Express.js para criar as rotas da API.

- **`const User = require('../models/userModel');`**: Importa o modelo User que define a estrutura e comportamento dos documentos de usuários no MongoDB. Este modelo será usado para gerenciar professores e suas solicitações.

- **`const { verificarToken, verificarAdmin } = require('../middleware/auth');`**: Importa duas funções do middleware de autenticação:
  - `verificarToken`: Verifica se o usuário está autenticado
  - `verificarAdmin`: Verifica se o usuário tem privilégios de administrador
  - Ambas as funções são necessárias para proteger as rotas administrativas

- **`const router = express.Router();`**: Cria uma nova instância do Router do Express para organizar as rotas administrativas de forma modular.

### 2. ROTA PARA LISTAR SOLICITAÇÕES DE PROFESSORES

```javascript
// GET /api/admin/solicitacoes-professores - Listar solicitações de professores
router.get('/solicitacoes-professores', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const { page = 1, limit = 10, status } = req.query;
    const skip = (page - 1) * limit;

    let query = { role: 'professor' };
    if (status && status !== 'todas') {
      query.statusAprovacao = status;
    }

    const solicitacoes = await User.find(query)
      .select('nome email matricula statusAprovacao createdAt')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await User.countDocuments(query);
    const paginas = Math.ceil(total / limit);

    res.json({
      solicitacoes,
      paginacao: {
        pagina: parseInt(page),
        paginas,
        total,
        limite: parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Erro ao listar solicitações de professores:', error);
    res.status(500).json({ message: 'Erro interno do servidor' });
  }
});
```

**Explicação detalhada:**

**Cabeçalho da rota:**
- **`router.get('/solicitacoes-professores', verificarToken, verificarAdmin, async (req, res) => {`**: Define uma rota GET para listar solicitações de professores. Usa dois middlewares de segurança:
  - `verificarToken`: Garante que o usuário está logado
  - `verificarAdmin`: Garante que o usuário tem privilégios de administrador

**Extração de parâmetros:**
- **`const { page = 1, limit = 10, status } = req.query;`**: Extrai parâmetros da query string:
  - `page`: Número da página (padrão: 1)
  - `limit`: Limite de itens por página (padrão: 10)
  - `status`: Filtro por status de aprovação (opcional)

**Cálculo de paginação:**
- **`const skip = (page - 1) * limit;`**: Calcula quantos documentos "pular" para chegar à página desejada.

**Construção da query:**
- **`let query = { role: 'professor' };`**: Inicializa a query buscando apenas usuários com role 'professor'.
- **`if (status && status !== 'todas') { query.statusAprovacao = status; }`**: Se um status específico foi fornecido e não é 'todas', adiciona o filtro de status à query.

**Consulta ao banco de dados:**
- **`const solicitacoes = await User.find(query)`**: Busca professores no banco de dados usando os filtros construídos.
- **`.select('nome email matricula statusAprovacao createdAt')`**: Seleciona apenas os campos necessários, otimizando a consulta.
- **`.sort({ createdAt: -1 })`**: Ordena por data de criação (mais recentes primeiro).
- **`.skip(skip)`**: Pula documentos para paginação.
- **`.limit(parseInt(limit))`**: Limita o número de resultados.

**Contagem e cálculo de páginas:**
- **`const total = await User.countDocuments(query);`**: Conta o total de documentos que correspondem aos filtros.
- **`const paginas = Math.ceil(total / limit);`**: Calcula o número total de páginas.

**Resposta estruturada:**
- **`res.json({...})`**: Retorna JSON com:
  - `solicitacoes`: Array com as solicitações encontradas
  - `paginacao`: Objeto com informações de paginação

### 3. ROTA PARA OBTER ESTATÍSTICAS DAS SOLICITAÇÕES

```javascript
// GET /api/admin/estatisticas-solicitacoes - Obter estatísticas das solicitações
router.get('/estatisticas-solicitacoes', verificarToken, verificarAdmin, async (req, res) => {
  try {

    const pendentes = await User.countDocuments({ 
      role: 'professor', 
      statusAprovacao: 'pendente' 
    });
    
    const aprovados = await User.countDocuments({ 
      role: 'professor', 
      statusAprovacao: 'aprovado' 
    });
    
    const recusados = await User.countDocuments({ 
      role: 'professor', 
      statusAprovacao: 'recusado' 
    });
    
    const total = await User.countDocuments({ role: 'professor' });

    res.json({
      pendentes,
      aprovados,
      recusados,
      total
    });
  } catch (error) {
    console.error('Erro ao obter estatísticas de solicitações:', error);
    res.status(500).json({ message: 'Erro interno do servidor' });
  }
});
```

**Explicação detalhada:**

**Contagem de solicitações pendentes:**
- **`const pendentes = await User.countDocuments({ role: 'professor', statusAprovacao: 'pendente' });`**: Conta quantos professores têm status 'pendente' (aguardando aprovação).

**Contagem de solicitações aprovadas:**
- **`const aprovados = await User.countDocuments({ role: 'professor', statusAprovacao: 'aprovado' });`**: Conta quantos professores foram aprovados.

**Contagem de solicitações recusadas:**
- **`const recusados = await User.countDocuments({ role: 'professor', statusAprovacao: 'recusado' });`**: Conta quantos professores foram recusados.

**Contagem total:**
- **`const total = await User.countDocuments({ role: 'professor' });`**: Conta o total de professores (independente do status).

**Resposta com estatísticas:**
- **`res.json({ pendentes, aprovados, recusados, total })`**: Retorna um objeto com todas as contagens para criar dashboards e relatórios.

### 4. ROTA PARA APROVAR PROFESSOR

```javascript
// POST /api/admin/aprovar-professor/:id - Aprovar solicitação de professor
router.post('/aprovar-professor/:id', verificarToken, verificarAdmin, async (req, res) => {
    try {

        const { id } = req.params;
        const { motivo } = req.body;

        const professor = await User.findById(id);
        
        if (!professor) {
            return res.status(404).json({
                message: 'Professor não encontrado'
            });
        }

        if (professor.role !== 'professor') {
            return res.status(400).json({
                message: 'Usuário não é um professor'
            });
        }

        if (professor.statusAprovacao !== 'pendente') {
            return res.status(400).json({
                message: 'Solicitação já foi processada'
            });
        }

        // Aprovar professor
        professor.statusAprovacao = 'aprovado';
        professor.ativo = true;
        await professor.save();

        res.json({
            message: 'Professor aprovado com sucesso',
            professor: professor.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro ao aprovar professor:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

**Parâmetros da requisição:**
- **`const { id } = req.params;`**: Extrai o ID do professor da URL.
- **`const { motivo } = req.body;`**: Extrai o motivo da aprovação do corpo da requisição (opcional).

**Busca do professor:**
- **`const professor = await User.findById(id);`**: Busca o professor pelo ID fornecido.

**Validações de segurança:**
- **`if (!professor) { return res.status(404).json({ message: 'Professor não encontrado' }); }`**: Verifica se o professor existe.
- **`if (professor.role !== 'professor') { return res.status(400).json({ message: 'Usuário não é um professor' }); }`**: Verifica se o usuário realmente é um professor.
- **`if (professor.statusAprovacao !== 'pendente') { return res.status(400).json({ message: 'Solicitação já foi processada' }); }`**: Verifica se a solicitação ainda está pendente.

**Processo de aprovação:**
- **`professor.statusAprovacao = 'aprovado';`**: Altera o status para 'aprovado'.
- **`professor.ativo = true;`**: Ativa a conta do professor.
- **`await professor.save();`**: Salva as alterações no banco de dados.

**Resposta de sucesso:**
- **`res.json({ message: 'Professor aprovado com sucesso', professor: professor.toPublicJSON() })`**: Retorna mensagem de sucesso e dados do professor (usando método `toPublicJSON()` para remover informações sensíveis).

### 5. ROTA PARA RECUSAR PROFESSOR

```javascript
// POST /api/admin/recusar-professor/:id - Recusar solicitação de professor
router.post('/recusar-professor/:id', verificarToken, verificarAdmin, async (req, res) => {
    try {

        const { id } = req.params;
        const { motivo } = req.body;

        const professor = await User.findById(id);
        
        if (!professor) {
            return res.status(404).json({
                message: 'Professor não encontrado'
            });
        }

        if (professor.role !== 'professor') {
            return res.status(400).json({
                message: 'Usuário não é um professor'
            });
        }

        if (professor.statusAprovacao !== 'pendente') {
            return res.status(400).json({
                message: 'Solicitação já foi processada'
            });
        }

        // Recusar professor
        professor.statusAprovacao = 'recusado';
        professor.ativo = false; // Desativar conta recusada
        await professor.save();

        res.json({
            message: 'Solicitação de professor recusada',
            professor: professor.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro ao recusar professor:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});
```

**Explicação detalhada:**

**Estrutura similar à aprovação:**
Esta rota segue a mesma estrutura da rota de aprovação, mas com diferenças importantes no processo de recusa:

**Processo de recusa:**
- **`professor.statusAprovacao = 'recusado';`**: Altera o status para 'recusado'.
- **`professor.ativo = false;`**: **Desativa** a conta do professor (diferente da aprovação que ativa).

**Resposta de sucesso:**
- **`res.json({ message: 'Solicitação de professor recusada', professor: professor.toPublicJSON() })`**: Retorna mensagem específica para recusa.

### 6. EXPORTAÇÃO DO ROUTER

```javascript
module.exports = router;
```

**Explicação:**
Exporta o router configurado para ser usado no arquivo principal do servidor (`server.js`), onde será registrado como middleware para o caminho `/api/admin`.

## Funcionalidades Principais

### 1. **Sistema de Aprovação de Professores**
- Listagem de solicitações com paginação e filtros
- Estatísticas detalhadas do processo de aprovação
- Aprovação e recusa de candidatos com validações de segurança

### 2. **Controle de Acesso Rigoroso**
- Todas as rotas requerem autenticação (`verificarToken`)
- Todas as rotas requerem privilégios de administrador (`verificarAdmin`)
- Validações múltiplas antes de processar solicitações

### 3. **Sistema de Status de Aprovação**
- `pendente`: Aguardando análise do administrador
- `aprovado`: Professor aprovado e conta ativada
- `recusado`: Professor recusado e conta desativada

### 4. **Validações de Segurança**
- Verificação de existência do usuário
- Verificação do role (deve ser 'professor')
- Verificação do status atual (deve ser 'pendente')
- Prevenção de processamento duplo

## Segurança

### 1. **Autenticação Dupla**
- `verificarToken`: Garante que o usuário está logado
- `verificarAdmin`: Garante que o usuário tem privilégios de administrador

### 2. **Validações de Negócio**
- Verifica se o usuário existe antes de processar
- Verifica se o usuário é realmente um professor
- Verifica se a solicitação ainda está pendente
- Previne processamento de solicitações já processadas

### 3. **Controle de Ativação de Contas**
- Contas aprovadas são ativadas (`ativo = true`)
- Contas recusadas são desativadas (`ativo = false`)
- Garante que apenas professores aprovados possam usar o sistema

## Integração com o Sistema

### 1. **Modelo User**
- Utiliza o modelo User para todas as operações
- Usa o método `toPublicJSON()` para remover dados sensíveis
- Aproveita os campos `role`, `statusAprovacao` e `ativo`

### 2. **Middleware de Autenticação**
- Integra com o sistema de autenticação JWT
- Usa middleware específico para verificar privilégios de administrador

### 3. **Sistema de Status**
- Integra com o sistema de status de aprovação de professores
- Mantém consistência entre status e estado da conta

## Padrões de Resposta

### 1. **Listagem de Solicitações (200)**
```json
{
    "solicitacoes": [
        {
            "_id": "...",
            "nome": "João Silva",
            "email": "joao@email.com",
            "matricula": "2023001",
            "statusAprovacao": "pendente",
            "createdAt": "2023-01-01T00:00:00.000Z"
        }
    ],
    "paginacao": {
        "pagina": 1,
        "paginas": 5,
        "total": 50,
        "limite": 10
    }
}
```

### 2. **Estatísticas (200)**
```json
{
    "pendentes": 15,
    "aprovados": 25,
    "recusados": 5,
    "total": 45
}
```

### 3. **Aprovação/Recusa (200)**
```json
{
    "message": "Professor aprovado com sucesso",
    "professor": {
        "_id": "...",
        "nome": "João Silva",
        "email": "joao@email.com",
        "statusAprovacao": "aprovado",
        "ativo": true
    }
}
```

### 4. **Erro 400 - Validação**
```json
{
    "message": "Solicitação já foi processada"
}
```

### 5. **Erro 404 - Não Encontrado**
```json
{
    "message": "Professor não encontrado"
}
```

## Fluxo de Trabalho Administrativo

### 1. **Visualização de Solicitações**
1. Administrador acessa `/api/admin/solicitacoes-professores`
2. Sistema retorna lista paginada de professores pendentes
3. Administrador pode filtrar por status

### 2. **Análise de Estatísticas**
1. Administrador acessa `/api/admin/estatisticas-solicitacoes`
2. Sistema retorna contadores de cada status
3. Administrador pode tomar decisões baseadas nos números

### 3. **Processamento de Solicitações**
1. Administrador escolhe aprovar ou recusar um professor
2. Sistema valida se a solicitação ainda está pendente
3. Sistema atualiza status e estado da conta
4. Sistema retorna confirmação da ação

## Considerações de Performance

### 1. **Seleção de Campos**
- Usa `.select()` para buscar apenas campos necessários
- Reduz o tamanho dos dados transferidos
- Melhora a performance das consultas

### 2. **Paginação Eficiente**
- Implementa paginação com `skip()` e `limit()`
- Evita carregar grandes volumes de dados
- Calcula estatísticas separadamente

### 3. **Índices Recomendados**
- Índice em `role` para filtrar professores
- Índice em `statusAprovacao` para filtrar por status
- Índice em `createdAt` para ordenação

Este arquivo é fundamental para o controle administrativo da aplicação, garantindo que apenas professores aprovados tenham acesso ao sistema e fornecendo ferramentas completas para gerenciar o processo de aprovação.
# DOCUMENTAÇÃO DETALHADA - MIDDLEWARE DE AUTENTICAÇÃO (auth.js)

## Visão Geral
O arquivo `backend/middleware/auth.js` contém todos os middlewares relacionados à autenticação e autorização da aplicação IFC Coin. Este módulo é responsável por verificar tokens JWT, validar permissões de usuários, e garantir que apenas usuários autorizados acessem recursos específicos. É um componente crítico para a segurança da aplicação.

## Estrutura do Arquivo

### 1. IMPORTAÇÕES E DEPENDÊNCIAS

```javascript
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
```

**Explicação linha por linha:**

- **`const jwt = require('jsonwebtoken');`**: Importa a biblioteca `jsonwebtoken` que é usada para criar, verificar e decodificar tokens JWT (JSON Web Tokens). Esta biblioteca é fundamental para implementar autenticação baseada em tokens.

- **`const User = require('../models/userModel');`**: Importa o modelo User que será usado para buscar informações do usuário no banco de dados durante o processo de autenticação.

### 2. MIDDLEWARE PRINCIPAL - VERIFICAR TOKEN

```javascript
// Middleware para verificar token JWT
const verificarToken = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization; //pegar o token do header Authorization
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                message: 'Token de acesso não fornecido'
            });
        }

        const token = authHeader.substring(7); // Remove 'Bearer ' do início

        //verificar e decodificar o token
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (err) {
            if (err.name === 'JsonWebTokenError') {
                return res.status(401).json({
                    message: 'Token inválido'
                });
            }
            if (err.name === 'TokenExpiredError') {
                return res.status(401).json({
                    message: 'Token expirado'
                });
            }
            return res.status(401).json({
                message: 'Token inválido ou expirado'
            });
        }
        
        // Buscar o usuário no banco
        const user = await User.findById(decoded.userId).select('-senha');
        if (!user) {
            return res.status(401).json({
                message: 'Usuário não encontrado'
            });
        }

        if (!user.ativo) {
            return res.status(401).json({
                message: 'Usuário inativo'
            });
        }

        //adicionar o usuário ao request
        req.user = {
            _id: user._id,
            nome: user.nome,
            email: user.email,
            matricula: user.matricula,
            role: user.role,
            saldo: user.saldo,
            curso: user.curso,
            turmas: user.turmas,
            fotoPerfil: user.fotoPerfil,
            statusAprovacao: user.statusAprovacao,
            ativo: user.ativo,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        };
        
        next();
    } catch (error) {
        return res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
};
```

**Explicação detalhada:**

**Cabeçalho da função:**
- **`const verificarToken = async (req, res, next) => {`**: Define uma função middleware assíncrona que recebe os parâmetros padrão do Express:
  - `req`: Objeto de requisição
  - `res`: Objeto de resposta
  - `next`: Função para passar para o próximo middleware

**Extração do header de autorização:**
- **`const authHeader = req.headers.authorization;`**: Extrai o header `Authorization` da requisição HTTP. Este header deve conter o token JWT no formato `Bearer <token>`.

**Validação da presença do header:**
- **`if (!authHeader || !authHeader.startsWith('Bearer ')) {`**: Verifica se:
  - O header existe (`!authHeader`)
  - O header começa com 'Bearer ' (`!authHeader.startsWith('Bearer ')`)
- **`return res.status(401).json({ message: 'Token de acesso não fornecido' });`**: Se alguma condição for verdadeira, retorna erro 401 (Unauthorized) com mensagem explicativa.

**Extração do token:**
- **`const token = authHeader.substring(7);`**: Remove os primeiros 7 caracteres ('Bearer ') do header, deixando apenas o token JWT.

**Verificação e decodificação do token:**
- **`let decoded;`**: Declara variável para armazenar o token decodificado.
- **`try { decoded = jwt.verify(token, process.env.JWT_SECRET); }`**: Tenta verificar e decodificar o token usando a chave secreta definida na variável de ambiente `JWT_SECRET`.

**Tratamento de erros específicos do JWT:**
- **`catch (err) {`**: Captura erros durante a verificação do token.
- **`if (err.name === 'JsonWebTokenError') {`**: Verifica se o erro é de token inválido (assinatura incorreta, formato inválido, etc.).
- **`if (err.name === 'TokenExpiredError') {`**: Verifica se o erro é de token expirado.
- **`return res.status(401).json({ message: 'Token inválido ou expirado' });`**: Retorna erro genérico para outros tipos de erro.

**Busca do usuário no banco de dados:**
- **`const user = await User.findById(decoded.userId).select('-senha');`**: Busca o usuário pelo ID extraído do token, excluindo o campo senha por segurança.
- **`if (!user) { return res.status(401).json({ message: 'Usuário não encontrado' }); }`**: Se o usuário não existir, retorna erro 401.

**Verificação de status ativo:**
- **`if (!user.ativo) { return res.status(401).json({ message: 'Usuário inativo' }); }`**: Verifica se o usuário está ativo. Usuários inativos (recusados ou desativados) não podem acessar o sistema.

**Adição do usuário ao request:**
- **`req.user = { ... };`**: Cria um objeto com os dados do usuário e adiciona ao objeto `req` para que esteja disponível nos próximos middlewares e rotas. Inclui todos os campos relevantes exceto a senha.

**Finalização do middleware:**
- **`next();`**: Chama a função `next()` para passar o controle para o próximo middleware ou rota.

**Tratamento de erro geral:**
- **`catch (error) => { return res.status(500).json({ message: 'Erro interno do servidor' }); }`**: Captura qualquer erro não tratado e retorna erro 500.

### 3. MIDDLEWARE PARA VERIFICAR ROLES ESPECÍFICAS

```javascript
// Middleware para verificar roles específicas
const verificarRole = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                message: 'Usuário não autenticado'
            });
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                message: 'Acesso negado. Permissão insuficiente.'
            });
        }

        next();
    };
};
```

**Explicação detalhada:**

**Definição da função:**
- **`const verificarRole = (...roles) => {`**: Define uma função que aceita múltiplos parâmetros (roles) usando rest parameters (`...roles`). Isso permite passar quantos roles forem necessários.

**Retorno de função middleware:**
- **`return (req, res, next) => {`**: Retorna uma função middleware que será executada quando a rota for acessada.

**Verificação de autenticação:**
- **`if (!req.user) { return res.status(401).json({ message: 'Usuário não autenticado' }); }`**: Verifica se o usuário foi autenticado pelo middleware anterior (`verificarToken`).

**Verificação de permissões:**
- **`if (!roles.includes(req.user.role)) {`**: Verifica se o role do usuário está incluído na lista de roles permitidos.
- **`return res.status(403).json({ message: 'Acesso negado. Permissão insuficiente.' });`**: Se não estiver, retorna erro 403 (Forbidden).

**Finalização:**
- **`next();`**: Se todas as verificações passarem, chama `next()` para continuar.

### 4. MIDDLEWARES ESPECÍFICOS PARA ROLES

```javascript
// Middleware para verificar se é admin
const verificarAdmin = verificarRole('admin');

// Middleware para verificar se é professor ou admin
const verificarProfessor = verificarRole('professor', 'admin');

// Middleware para verificar se é aluno
const verificarAluno = verificarRole('aluno');
```

**Explicação detalhada:**

**Middleware para administradores:**
- **`const verificarAdmin = verificarRole('admin');`**: Cria um middleware específico que verifica se o usuário tem role 'admin'.

**Middleware para professores e administradores:**
- **`const verificarProfessor = verificarRole('professor', 'admin');`**: Cria um middleware que permite acesso tanto para professores quanto para administradores. Isso é útil para funcionalidades que professores podem usar, mas administradores também têm acesso.

**Middleware para alunos:**
- **`const verificarAluno = verificarRole('aluno');`**: Cria um middleware específico para alunos.

### 5. MIDDLEWARE OPCIONAL PARA TOKEN

```javascript
// Middleware opcional para verificar token (não falha se não houver token)
const verificarTokenOpcional = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return next();
        }

        const token = authHeader.substring(7);
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        const user = await User.findById(decoded.userId).select('-senha');
        
        if (user && user.ativo) {
            req.user = user;
        }
        
        next();
    } catch (error) {
        next();
    }
};
```

**Explicação detalhada:**

**Propósito:**
Este middleware é usado quando queremos que uma rota funcione tanto para usuários autenticados quanto para usuários não autenticados (como rotas públicas que podem mostrar informações extras para usuários logados).

**Verificação opcional do header:**
- **`if (!authHeader || !authHeader.startsWith('Bearer ')) { return next(); }`**: Se não houver header de autorização, simplesmente passa para o próximo middleware sem erro.

**Processamento do token:**
- **`const token = authHeader.substring(7);`**: Extrai o token do header.
- **`const decoded = jwt.verify(token, process.env.JWT_SECRET);`**: Verifica o token.
- **`const user = await User.findById(decoded.userId).select('-senha');`**: Busca o usuário.

**Adição condicional do usuário:**
- **`if (user && user.ativo) { req.user = user; }`**: Se o usuário existir e estiver ativo, adiciona ao request.

**Tratamento de erro:**
- **`catch (error) => { next(); }`**: Se houver qualquer erro, simplesmente passa para o próximo middleware sem falhar.

### 6. EXPORTAÇÃO DOS MIDDLEWARES

```javascript
module.exports = {
    verificarToken,
    verificarRole,
    verificarAdmin,
    verificarProfessor,
    verificarAluno,
    verificarTokenOpcional
};
```

**Explicação:**
Exporta todos os middlewares para serem usados nas rotas da aplicação. Cada middleware tem uma função específica no sistema de autenticação e autorização.

## Funcionalidades Principais

### 1. **Sistema de Autenticação JWT**
- Verificação de tokens JWT válidos
- Tratamento específico de diferentes tipos de erro de token
- Busca e validação de usuários no banco de dados
- Verificação de status ativo do usuário

### 2. **Sistema de Autorização por Roles**
- Middleware genérico para verificar roles específicas
- Middlewares específicos para cada tipo de usuário
- Controle granular de permissões
- Suporte a múltiplos roles por rota

### 3. **Middleware Opcional**
- Suporte a rotas que funcionam com ou sem autenticação
- Não falha quando não há token
- Permite funcionalidades extras para usuários logados

### 4. **Segurança Robusta**
- Validação completa de tokens
- Verificação de existência e status do usuário
- Remoção de dados sensíveis (senha)
- Tratamento de erros específicos

## Segurança

### 1. **Validação de Token**
- Verifica se o token está presente no formato correto
- Valida a assinatura do token usando a chave secreta
- Trata especificamente tokens expirados e inválidos
- Verifica se o usuário ainda existe no banco

### 2. **Controle de Acesso**
- Verifica se o usuário está ativo antes de permitir acesso
- Implementa controle de acesso baseado em roles
- Previne acesso não autorizado a recursos protegidos
- Suporta hierarquia de permissões (admin > professor > aluno)

### 3. **Proteção de Dados**
- Remove automaticamente a senha dos dados do usuário
- Inclui apenas dados necessários no objeto `req.user`
- Não expõe informações sensíveis nas respostas

## Integração com o Sistema

### 1. **Modelo User**
- Utiliza o modelo User para buscar informações do usuário
- Aproveita os campos `role`, `ativo`, `statusAprovacao`
- Usa `.select('-senha')` para excluir dados sensíveis

### 2. **Sistema JWT**
- Integra com a biblioteca `jsonwebtoken`
- Usa `process.env.JWT_SECRET` para verificação
- Suporta tokens com payload contendo `userId`

### 3. **Express.js**
- Segue o padrão de middlewares do Express
- Usa `next()` para passar controle entre middlewares
- Integra com o sistema de rotas

## Padrões de Uso

### 1. **Middleware Obrigatório**
```javascript
// Rota que requer autenticação
router.get('/perfil', verificarToken, (req, res) => {
    // req.user está disponível
});

// Rota que requer autenticação e role específico
router.post('/admin/action', verificarToken, verificarAdmin, (req, res) => {
    // req.user está disponível e é admin
});
```

### 2. **Middleware Opcional**
```javascript
// Rota que funciona com ou sem autenticação
router.get('/public', verificarTokenOpcional, (req, res) => {
    if (req.user) {
        // Usuário logado - mostrar dados extras
    } else {
        // Usuário não logado - mostrar dados básicos
    }
});
```

### 3. **Combinação de Middlewares**
```javascript
// Rota que requer autenticação e permite professor ou admin
router.post('/goal', verificarToken, verificarProfessor, (req, res) => {
    // req.user está disponível e é professor ou admin
});
```

## Tratamento de Erros

### 1. **Erro 401 - Não Autorizado**
- Token não fornecido
- Token inválido
- Token expirado
- Usuário não encontrado
- Usuário inativo

### 2. **Erro 403 - Acesso Negado**
- Role insuficiente para acessar o recurso
- Usuário não tem permissão necessária

### 3. **Erro 500 - Erro Interno**
- Erros não tratados durante a verificação
- Problemas de conexão com banco de dados

## Considerações de Performance

### 1. **Otimização de Consultas**
- Usa `.select('-senha')` para buscar apenas campos necessários
- Evita buscar dados desnecessários do banco

### 2. **Cache de Tokens**
- Considerar implementar cache para tokens válidos
- Reduzir consultas ao banco de dados

### 3. **Validação Eficiente**
- Verifica primeiro a presença do header antes de processar
- Usa early returns para evitar processamento desnecessário

Este arquivo é fundamental para a segurança da aplicação, garantindo que apenas usuários autorizados acessem recursos específicos e mantendo a integridade do sistema de autenticação.
# DOCUMENTAÇÃO DETALHADA - SCRIPT DE SEED (seed.js)

## Visão Geral
O arquivo `backend/scripts/seed.js` é um script de inicialização do banco de dados que popula o sistema IFC Coin com dados de exemplo. Este script é fundamental para configurar o ambiente de desenvolvimento, testes e demonstração, criando usuários, metas, conquistas e transações iniciais.

## Estrutura do Arquivo

### 1. IMPORTAÇÕES E DEPENDÊNCIAS

```javascript
const mongoose = require('mongoose');
const User = require('../models/userModel');
const Transaction = require('../models/transactionModel');
const Goal = require('../models/goalModel');
const Achievement = require('../models/achievementModel');
require('dotenv').config();
```

**Explicação linha por linha:**

- **`const mongoose = require('mongoose');`**: Importa a biblioteca Mongoose para conectar e interagir com o MongoDB. Mongoose fornece uma interface orientada a objetos para o MongoDB.

- **`const User = require('../models/userModel');`**: Importa o modelo User que define a estrutura e comportamento dos documentos de usuários no MongoDB.

- **`const Transaction = require('../models/transactionModel');`**: Importa o modelo Transaction para gerenciar transações de coins entre usuários.

- **`const Goal = require('../models/goalModel');`**: Importa o modelo Goal para gerenciar metas que os usuários podem completar.

- **`const Achievement = require('../models/achievementModel');`**: Importa o modelo Achievement para gerenciar conquistas do sistema de gamificação.

- **`require('dotenv').config();`**: Carrega as variáveis de ambiente do arquivo `.env`, incluindo a string de conexão do MongoDB (`MONGODB_URI`).

### 2. DADOS DE EXEMPLO - USUÁRIOS

```javascript
// Dados de exemplo
const usuariosExemplo = [
    {
        nome: 'Administrador Sistema Celular',
        email: 'admin44@gmail.com',
        senha: 'admin12',
        matricula: '1234002',
        role: 'admin',
        turmas: [],
        saldo: 0
    }
];
```

**Explicação detalhada:**

**Estrutura do array:**
- **`const usuariosExemplo = [...]`**: Define um array com dados de usuários que serão criados no banco de dados.

**Dados do administrador:**
- **`nome: 'Administrador Sistema Celular'`**: Nome completo do usuário administrador.
- **`email: 'admin44@gmail.com'`**: Email único do administrador para login.
- **`senha: 'admin12'`**: Senha em texto plano que será hasheada pelo middleware do modelo User.
- **`matricula: '1234002'`**: Número de matrícula único do administrador.
- **`role: 'admin'`**: Define o papel do usuário como administrador, com privilégios máximos.
- **`turmas: []`**: Array vazio de turmas (administradores não pertencem a turmas específicas).
- **`saldo: 0`**: Saldo inicial de coins (administradores começam com 0 coins).

### 3. FUNÇÃO PRINCIPAL - SEED DATABASE

```javascript
async function seedDatabase() {
    try {
        console.log(process.env.MONGODB_URI)
        // Conectar ao MongoDB
        await mongoose.connect(process.env.MONGODB_URI);

        console.log('Conectado ao MongoDB');
```

**Explicação detalhada:**

**Cabeçalho da função:**
- **`async function seedDatabase() {`**: Define uma função assíncrona que será responsável por todo o processo de seed.

**Log da string de conexão:**
- **`console.log(process.env.MONGODB_URI)`**: Exibe a string de conexão do MongoDB para debugging (pode ser removido em produção).

**Conexão com o banco:**
- **`await mongoose.connect(process.env.MONGODB_URI);`**: Estabelece conexão com o MongoDB usando a string de conexão definida nas variáveis de ambiente.

**Confirmação de conexão:**
- **`console.log('Conectado ao MongoDB');`**: Confirma que a conexão foi estabelecida com sucesso.

### 4. LIMPEZA E CRIAÇÃO DE USUÁRIOS

```javascript
        // Limpar coleção de usuários
        await User.deleteMany({});
        console.log('Coleção de usuários limpa');

        // Inserir usuários de exemplo (individualmente para garantir que o hash seja aplicado)
        const usuariosCriados = [];
        for (const usuarioData of usuariosExemplo) {
            const usuario = new User(usuarioData);
            await usuario.save(); // Isso vai executar o middleware de hash
            usuariosCriados.push(usuario);
        }
        console.log(`${usuariosCriados.length} usuários criados com sucesso`);
```

**Explicação detalhada:**

**Limpeza da coleção:**
- **`await User.deleteMany({});`**: Remove todos os documentos da coleção de usuários. O objeto vazio `{}` significa "todos os documentos".
- **`console.log('Coleção de usuários limpa');`**: Confirma que a limpeza foi executada.

**Processo de criação individual:**
- **`const usuariosCriados = [];`**: Inicializa um array para armazenar os usuários criados.
- **`for (const usuarioData of usuariosExemplo) {`**: Itera sobre cada objeto de dados de usuário.

**Criação e salvamento:**
- **`const usuario = new User(usuarioData);`**: Cria uma nova instância do modelo User com os dados fornecidos.
- **`await usuario.save();`**: Salva o usuário no banco de dados. Este comando executa o middleware de hash de senha definido no modelo User.
- **`usuariosCriados.push(usuario);`**: Adiciona o usuário criado ao array para referência posterior.

**Confirmação de criação:**
- **`console.log(\`${usuariosCriados.length} usuários criados com sucesso\`);`**: Exibe quantos usuários foram criados com sucesso.

### 5. CRIAÇÃO DE METAS DE EXEMPLO

```javascript
        // Criar metas de exemplo
        const metasExemplo = [
            {
                titulo: 'Primeira Aula',
                descricao: 'Participe da sua primeira aula do semestre',
                tipo: 'evento',
                requisito: 1,
                recompensa: 10,
                usuariosConcluidos: [],
                ativo: true,
                requerAprovacao: false, // Aprovação automática
                evidenciaObrigatoria: false
            },
            {
                titulo: 'Participação em Evento',
                descricao: 'Participe de um evento institucional',
                tipo: 'evento',
                requisito: 1,
                recompensa: 25,
                usuariosConcluidos: [],
                ativo: true,
                requerAprovacao: true, // Precisa de aprovação
                evidenciaObrigatoria: true,
                tipoEvidencia: 'foto',
                descricaoEvidencia: 'Envie uma foto do evento'
            },
            {
                titulo: 'Indicação de Amigo',
                descricao: 'Indique um amigo para participar do sistema',
                tipo: 'indicacao',
                requisito: 1,
                recompensa: 15,
                usuariosConcluidos: [],
                ativo: true,
                requerAprovacao: false,
                evidenciaObrigatoria: false
            },
            {
                titulo: 'Excelente Desempenho',
                descricao: 'Mantenha excelente desempenho acadêmico',
                tipo: 'desempenho',
                requisito: 1,
                recompensa: 50,
                usuariosConcluidos: [],
                ativo: true,
                requerAprovacao: true, // Precisa de aprovação
                evidenciaObrigatoria: true,
                tipoEvidencia: 'documento',
                descricaoEvidencia: 'Envie comprovante de boas notas'
            },
            {
                titulo: 'Meta Limitada',
                descricao: 'Meta com limite de conclusões',
                tipo: 'evento',
                requisito: 1,
                recompensa: 30,
                usuariosConcluidos: [],
                ativo: true,
                requerAprovacao: false,
                maxConclusoes: 5, // Máximo 5 pessoas podem concluir
                evidenciaObrigatoria: false
            }
        ];

        const metasCriadas = await Goal.insertMany(metasExemplo);
        console.log(`${metasCriadas.length} metas criadas com sucesso`);
```

**Explicação detalhada:**

**Meta 1 - Primeira Aula:**
- **`titulo: 'Primeira Aula'`**: Nome da meta.
- **`descricao: 'Participe da sua primeira aula do semestre'`**: Descrição clara do que o usuário deve fazer.
- **`tipo: 'evento'`**: Categoria da meta (evento, indicação, desempenho, custom).
- **`requisito: 1`**: Quantidade necessária para completar a meta.
- **`recompensa: 10`**: Coins que o usuário receberá ao completar.
- **`usuariosConcluidos: []`**: Array vazio de usuários que já completaram.
- **`ativo: true`**: Meta está disponível para os usuários.
- **`requerAprovacao: false`**: Aprovação automática (não precisa de revisão).
- **`evidenciaObrigatoria: false`**: Não precisa enviar evidência.

**Meta 2 - Participação em Evento:**
- **`requerAprovacao: true`**: Precisa de aprovação manual.
- **`evidenciaObrigatoria: true`**: Obrigatório enviar evidência.
- **`tipoEvidencia: 'foto'`**: Tipo de evidência aceita.
- **`descricaoEvidencia: 'Envie uma foto do evento'`**: Instruções para o usuário.

**Meta 3 - Indicação de Amigo:**
- **`tipo: 'indicacao'`**: Meta de indicação de outros usuários.
- **`recompensa: 15`**: Recompensa menor para indicações.

**Meta 4 - Excelente Desempenho:**
- **`tipo: 'desempenho'`**: Meta relacionada ao desempenho acadêmico.
- **`recompensa: 50`**: Recompensa maior para desempenho.
- **`tipoEvidencia: 'documento'`**: Aceita documentos como evidência.

**Meta 5 - Meta Limitada:**
- **`maxConclusoes: 5`**: Limite máximo de usuários que podem completar esta meta.

**Criação em lote:**
- **`const metasCriadas = await Goal.insertMany(metasExemplo);`**: Cria todas as metas de uma vez usando `insertMany()`.
- **`console.log(\`${metasCriadas.length} metas criadas com sucesso\`);`**: Confirma a criação.

### 6. CRIAÇÃO DE CONQUISTAS DE EXEMPLO

```javascript
        // Criar conquistas de exemplo
        const conquistasExemplo = [
            {
                nome: 'Iniciante',
                descricao: 'Primeira conquista no sistema IFC Coin',
                tipo: 'medalha',
                categoria: 'Geral',
                icone: '🥉',
                requisitos: 'Faça login pela primeira vez'
            },
            {
                nome: 'Participativo',
                descricao: 'Participou de 5 eventos',
                tipo: 'conquista',
                categoria: 'Eventos',
                icone: '🎯',
                requisitos: 'Participe de 5 eventos institucionais'
            },
            {
                nome: 'Mestre das Transferências',
                descricao: 'Realizou 10 transferências',
                tipo: 'titulo',
                categoria: 'Transações',
                icone: '💎',
                requisitos: 'Realize 10 transferências de coins'
            },
            {
                nome: 'Benfeitor',
                descricao: 'Concedeu 20 recompensas',
                tipo: 'medalha',
                categoria: 'Professor',
                icone: '🏆',
                requisitos: 'Conceda 20 recompensas como professor'
            }
        ];

        const conquistasCriadas = await Achievement.insertMany(conquistasExemplo);
        console.log(`${conquistasCriadas.length} conquistas criadas com sucesso`);
```

**Explicação detalhada:**

**Conquista 1 - Iniciante:**
- **`nome: 'Iniciante'`**: Nome da conquista.
- **`descricao: 'Primeira conquista no sistema IFC Coin'`**: Descrição da conquista.
- **`tipo: 'medalha'`**: Tipo de conquista (medalha, conquista, titulo).
- **`categoria: 'Geral'`**: Categoria para organização.
- **`icone: '🥉'`**: Emoji que representa a conquista.
- **`requisitos: 'Faça login pela primeira vez'`**: Descrição dos requisitos.

**Conquista 2 - Participativo:**
- **`tipo: 'conquista'`**: Tipo diferente de conquista.
- **`categoria: 'Eventos'`**: Categoria específica para eventos.
- **`icone: '🎯'`**: Ícone relacionado a participação.

**Conquista 3 - Mestre das Transferências:**
- **`tipo: 'titulo'`**: Conquista do tipo título.
- **`categoria: 'Transações'`**: Categoria para transações.
- **`icone: '💎'`**: Ícone de diamante para representar valor.

**Conquista 4 - Benfeitor:**
- **`categoria: 'Professor'`**: Categoria específica para professores.
- **`icone: '🏆'`**: Ícone de troféu para representar excelência.

### 7. CRIAÇÃO DE TRANSAÇÕES DE EXEMPLO

```javascript
        // Criar algumas transações de exemplo (apenas se houver usuários suficientes)
        if (usuariosCriados.length > 0) {
            const transacoesExemplo = [
                {
                    tipo: 'recebido',
                    origem: null, // Sistema
                    destino: usuariosCriados[0]._id,
                    quantidade: 10,
                    descricao: 'Recompensa por primeira aula',
                    hash: 'seed_tx_001'
                }
            ];

            const transacoesCriadas = await Transaction.insertMany(transacoesExemplo);
            console.log(`${transacoesCriadas.length} transações de exemplo criadas`);
        }
```

**Explicação detalhada:**

**Verificação de usuários:**
- **`if (usuariosCriados.length > 0) {`**: Só cria transações se houver usuários criados.

**Transação de exemplo:**
- **`tipo: 'recebido'`**: Tipo de transação (recebido/enviado).
- **`origem: null`**: Null indica que a transação veio do sistema (não de outro usuário).
- **`destino: usuariosCriados[0]._id`**: ID do primeiro usuário criado como destinatário.
- **`quantidade: 10`**: Quantidade de coins transferidos.
- **`descricao: 'Recompensa por primeira aula'`**: Descrição da transação.
- **`hash: 'seed_tx_001'`**: Hash único para identificar a transação.

### 8. EXIBIÇÃO DE RESUMO

```javascript
        // Mostrar informações dos usuários criados
        console.log('\nUsuários criados:');
        usuariosCriados.forEach(user => {
            console.log(`- ${user.nome} (${user.role}) - Matrícula: ${user.matricula} - Saldo: ${user.saldo} coins`);
        });

        console.log('\nMetas criadas:');
        metasCriadas.forEach(meta => {
            console.log(`- ${meta.titulo} (${meta.tipo}) - Recompensa: ${meta.recompensa} coins`);
        });

        console.log('\nConquistas criadas:');
        conquistasCriadas.forEach(conquista => {
            console.log(`- ${conquista.nome} (${conquista.tipo}) - ${conquista.categoria}`);
        });

        console.log('\nScript de seed concluído com sucesso!');
        console.log('\nCredenciais de teste:');
        console.log('Admin: matrícula 1234002, senha admin12');
```

**Explicação detalhada:**

**Resumo de usuários:**
- **`usuariosCriados.forEach(user => {`**: Itera sobre cada usuário criado.
- **`console.log(\`- ${user.nome} (${user.role}) - Matrícula: ${user.matricula} - Saldo: ${user.saldo} coins\`);`**: Exibe informações formatadas de cada usuário.

**Resumo de metas:**
- **`metasCriadas.forEach(meta => {`**: Itera sobre cada meta criada.
- **`console.log(\`- ${meta.titulo} (${meta.tipo}) - Recompensa: ${meta.recompensa} coins\`);`**: Exibe informações das metas.

**Resumo de conquistas:**
- **`conquistasCriadas.forEach(conquista => {`**: Itera sobre cada conquista criada.
- **`console.log(\`- ${conquista.nome} (${conquista.tipo}) - ${conquista.categoria}\`);`**: Exibe informações das conquistas.

**Credenciais de teste:**
- **`console.log('Admin: matrícula 1234002, senha admin12');`**: Fornece as credenciais para login de teste.

### 9. TRATAMENTO DE ERROS E FINALIZAÇÃO

```javascript
    } catch (error) {
        console.error('Erro durante o seed:', error);
    } finally {
        // Fechar conexão
        await mongoose.connection.close();
        console.log('Conexão com MongoDB fechada');
        process.exit(0);
    }
}

// Executar o script
seedDatabase();
```

**Explicação detalhada:**

**Tratamento de erro:**
- **`catch (error) => {`**: Captura qualquer erro que ocorra durante o processo.
- **`console.error('Erro durante o seed:', error);`**: Exibe o erro detalhado para debugging.

**Finalização:**
- **`finally {`**: Bloco que sempre é executado, independente de sucesso ou erro.
- **`await mongoose.connection.close();`**: Fecha a conexão com o MongoDB.
- **`console.log('Conexão com MongoDB fechada');`**: Confirma o fechamento da conexão.
- **`process.exit(0);`**: Encerra o processo Node.js com código de sucesso (0).

**Execução do script:**
- **`seedDatabase();`**: Chama a função principal para executar o script.

## Funcionalidades Principais

### 1. **Inicialização Completa do Sistema**
- Cria usuário administrador padrão
- Popula metas de diferentes tipos
- Cria conquistas para gamificação
- Estabelece transações iniciais

### 2. **Dados de Exemplo Diversificados**
- Metas com diferentes requisitos de aprovação
- Conquistas de diferentes categorias
- Transações para demonstrar funcionalidade
- Usuário administrador para testes

### 3. **Processo Seguro de Criação**
- Limpeza prévia das coleções
- Hash automático de senhas
- Validação através dos modelos
- Tratamento de erros robusto

### 4. **Feedback Detalhado**
- Logs de progresso em cada etapa
- Resumo final dos dados criados
- Credenciais de teste fornecidas
- Confirmação de sucesso

## Segurança

### 1. **Limpeza de Dados**
- Remove dados existentes antes de criar novos
- Evita conflitos e dados duplicados
- Garante estado limpo para testes

### 2. **Hash de Senhas**
- Senhas são hasheadas automaticamente
- Usa o middleware do modelo User
- Garante segurança mesmo em dados de teste

### 3. **Validação de Modelos**
- Usa os mesmos modelos da aplicação
- Aplica todas as validações definidas
- Garante consistência dos dados

## Casos de Uso

### 1. **Desenvolvimento**
- Configuração inicial do ambiente
- Dados de teste para desenvolvimento
- Demonstração de funcionalidades

### 2. **Testes**
- Dados consistentes para testes
- Usuário administrador para login
- Metas e conquistas para testar

### 3. **Demonstração**
- Sistema funcional para apresentações
- Dados realistas para mostrar
- Credenciais de acesso fornecidas

## Como Executar

### 1. **Preparação**
```bash
# Certifique-se de que o .env está configurado
MONGODB_URI=mongodb://localhost:27017/ifc_coin

# Instale as dependências
npm install
```

### 2. **Execução**
```bash
# Execute o script
node backend/scripts/seed.js
```

### 3. **Verificação**
- Verifique os logs de saída
- Confirme que todos os dados foram criados
- Use as credenciais fornecidas para login

## Considerações Importantes

### 1. **Ambiente de Produção**
- Não execute em produção sem modificação
- Remova ou modifique dados sensíveis
- Considere usar dados mais realistas

### 2. **Personalização**
- Modifique os dados de exemplo conforme necessário
- Adicione mais usuários, metas ou conquistas
- Ajuste recompensas e requisitos

### 3. **Manutenção**
- Atualize dados quando necessário
- Mantenha consistência com mudanças nos modelos
- Teste após modificações

Este script é fundamental para a configuração inicial do sistema, fornecendo dados de exemplo que permitem testar todas as funcionalidades da aplicação IFC Coin.
# DOCUMENTAÇÃO DETALHADA - SCRIPT DE CONQUISTAS PADRÃO (criar_conquistas_padrao.js)

## Visão Geral
O arquivo `backend/scripts/criar_conquistas_padrao.js` é um script especializado para criar o conjunto completo de conquistas padrão do sistema IFC Coin. Este script define 22 conquistas diferentes organizadas em 6 categorias, cobrindo todos os aspectos do sistema de gamificação: transferências, metas, coins, frequência, perfil e balanço.

## Estrutura do Arquivo

### 1. IMPORTAÇÕES E DEPENDÊNCIAS

```javascript
const mongoose = require('mongoose');
const Achievement = require('../models/achievementModel');
require('dotenv').config();
```

**Explicação linha por linha:**

- **`const mongoose = require('mongoose');`**: Importa a biblioteca Mongoose para conectar ao MongoDB e gerenciar os documentos de conquistas.

- **`const Achievement = require('../models/achievementModel');`**: Importa o modelo Achievement que define a estrutura e validações para as conquistas no banco de dados.

- **`require('dotenv').config();`**: Carrega as variáveis de ambiente do arquivo `.env`, incluindo a string de conexão do MongoDB.

### 2. ARRAY DE CONQUISTAS PADRÃO

```javascript
// Conquistas padrão que serão criadas automaticamente
const conquistasPadrao = [
    // === TRANSFERÊNCIAS ENVIADAS ===
    {
        nome: 'Primeiro Passo',
        descricao: 'Realizou sua primeira transferência de IFC Coins',
        tipo: 'primeira_transferencia',
        categoria: 'Transferências',
        icone: '🚀',
        requisitos: 'Realizar 1 transferência'
    },
    // ... mais conquistas
];
```

**Explicação detalhada:**

**Estrutura do array:**
- **`const conquistasPadrao = [...]`**: Define um array contendo todas as 22 conquistas padrão do sistema.

**Organização por categorias:**
O script organiza as conquistas em 6 categorias principais:

#### **1. Transferências Enviadas (4 conquistas)**
```javascript
{
    nome: 'Primeiro Passo',
    descricao: 'Realizou sua primeira transferência de IFC Coins',
    tipo: 'primeira_transferencia',
    categoria: 'Transferências',
    icone: '🚀',
    requisitos: 'Realizar 1 transferência'
}
```

**Explicação dos campos:**
- **`nome: 'Primeiro Passo'`**: Nome da conquista que aparece para o usuário.
- **`descricao: 'Realizou sua primeira transferência de IFC Coins'`**: Descrição detalhada do que o usuário fez para ganhar a conquista.
- **`tipo: 'primeira_transferencia'`**: Identificador único usado pelo sistema para verificar automaticamente se o usuário ganhou a conquista.
- **`categoria: 'Transferências'`**: Categoria para organização e filtros na interface.
- **`icone: '🚀'`**: Emoji que representa visualmente a conquista.
- **`requisitos: 'Realizar 1 transferência'`**: Descrição dos requisitos para o usuário.

**Progressão das conquistas de transferência:**
1. **Primeiro Passo** (1 transferência) - 🚀
2. **Distribuidor Generoso** (10 transferências) - 💸
3. **Mestre das Transferências** (50 transferências) - 🏆
4. **Lenda das Transferências** (100 transferências) - 👑

#### **2. Transferências Recebidas (4 conquistas)**
```javascript
{
    nome: 'Primeira Recepção',
    descricao: 'Recebeu sua primeira transferência de IFC Coins',
    tipo: 'primeira_recebida',
    categoria: 'Recebimentos',
    icone: '📥',
    requisitos: 'Receber 1 transferência'
}
```

**Progressão das conquistas de recebimento:**
1. **Primeira Recepção** (1 recebimento) - 📥
2. **Receptor Popular** (10 recebimentos) - 🎁
3. **Ímã de Coins** (50 recebimentos) - 🧲
4. **Celebridade do IFC** (100 recebimentos) - ⭐

#### **3. Metas (4 conquistas)**
```javascript
{
    nome: 'Primeira Conquista',
    descricao: 'Concluiu sua primeira meta',
    tipo: 'primeira_meta',
    categoria: 'Metas',
    icone: '✅',
    requisitos: 'Concluir 1 meta'
}
```

**Progressão das conquistas de metas:**
1. **Primeira Conquista** (1 meta) - ✅
2. **Persistente** (10 metas) - 🎯
3. **Mestre das Metas** (50 metas) - 🎖️
4. **Lenda das Metas** (100 metas) - 🏅

#### **4. Coins Acumulados (4 conquistas)**
```javascript
{
    nome: 'Poupador Iniciante',
    descricao: 'Acumulou 100 IFC Coins',
    tipo: 'coins_100',
    categoria: 'Coins',
    icone: '🪙',
    requisitos: 'Acumular 100 IFC Coins'
}
```

**Progressão das conquistas de coins:**
1. **Poupador Iniciante** (100 coins) - 🪙
2. **Investidor** (500 coins) - 💎
3. **Milionário** (1000 coins) - 💰
4. **Bilionário** (5000 coins) - 💎💎

#### **5. Frequência (3 conquistas)**
```javascript
{
    nome: 'Frequente',
    descricao: 'Acessou o app por 7 dias consecutivos',
    tipo: 'login_consecutivo_7',
    categoria: 'Frequência',
    icone: '📅',
    requisitos: 'Acessar por 7 dias consecutivos'
}
```

**Progressão das conquistas de frequência:**
1. **Frequente** (7 dias) - 📅
2. **Viciado** (30 dias) - 🔥
3. **Lenda da Frequência** (100 dias) - ⚡

#### **6. Perfil e Balanço (3 conquistas)**
```javascript
{
    nome: 'Fotogênico',
    descricao: 'Atualizou sua foto de perfil',
    tipo: 'foto_perfil',
    categoria: 'Perfil',
    icone: '📸',
    requisitos: 'Atualizar foto de perfil'
},
{
    nome: 'Equilibrado',
    descricao: 'Enviou e recebeu pelo menos 10 transferências cada',
    tipo: 'equilibrado',
    categoria: 'Balanço',
    icone: '⚖️',
    requisitos: 'Enviar e receber 10+ transferências cada'
},
{
    nome: 'Social',
    descricao: 'Realizou pelo menos 5 transferências e recebeu pelo menos 5',
    tipo: 'social',
    categoria: 'Balanço',
    icone: '🤝',
    requisitos: 'Realizar e receber 5+ transferências cada'
}
```

### 3. FUNÇÃO PRINCIPAL - CRIAR CONQUISTAS PADRÃO

```javascript
async function criarConquistasPadrao() {
    try {
        console.log('Conectando ao MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Conectado ao MongoDB');
```

**Explicação detalhada:**

**Cabeçalho da função:**
- **`async function criarConquistasPadrao() {`**: Define uma função assíncrona que será responsável por criar todas as conquistas padrão.

**Conexão com o banco:**
- **`console.log('Conectando ao MongoDB...');`**: Exibe mensagem de início da conexão.
- **`await mongoose.connect(process.env.MONGODB_URI);`**: Estabelece conexão com o MongoDB usando a string de conexão das variáveis de ambiente.
- **`console.log('Conectado ao MongoDB');`**: Confirma que a conexão foi estabelecida.

### 4. VERIFICAÇÃO DE CONQUISTAS EXISTENTES

```javascript
        console.log('Verificando conquistas existentes...');
        const conquistasExistentes = await Achievement.find({});
        
        if (conquistasExistentes.length > 0) {
            console.log(`Já existem ${conquistasExistentes.length} conquistas no banco.`);
            console.log('Para recriar todas as conquistas, delete-as primeiro.');
            return;
        }
```

**Explicação detalhada:**

**Verificação de dados existentes:**
- **`console.log('Verificando conquistas existentes...');`**: Exibe mensagem de verificação.
- **`const conquistasExistentes = await Achievement.find({});`**: Busca todas as conquistas existentes no banco de dados.

**Proteção contra duplicação:**
- **`if (conquistasExistentes.length > 0) {`**: Verifica se já existem conquistas no banco.
- **`console.log(\`Já existem ${conquistasExistentes.length} conquistas no banco.\`);`**: Informa quantas conquistas já existem.
- **`console.log('Para recriar todas as conquistas, delete-as primeiro.');`**: Fornece instruções para recriar as conquistas.
- **`return;`**: Encerra a função para evitar duplicação de dados.

### 5. CRIAÇÃO DAS CONQUISTAS

```javascript
        console.log('Criando conquistas padrão...');
        const conquistasCriadas = [];

        for (const conquista of conquistasPadrao) {
            const novaConquista = new Achievement(conquista);
            await novaConquista.save();
            conquistasCriadas.push(novaConquista);
            console.log(`✅ Conquista criada: ${conquista.nome}`);
        }
```

**Explicação detalhada:**

**Inicialização do processo:**
- **`console.log('Criando conquistas padrão...');`**: Exibe mensagem de início da criação.
- **`const conquistasCriadas = [];`**: Inicializa array para armazenar as conquistas criadas.

**Loop de criação:**
- **`for (const conquista of conquistasPadrao) {`**: Itera sobre cada conquista do array de conquistas padrão.

**Criação individual:**
- **`const novaConquista = new Achievement(conquista);`**: Cria uma nova instância do modelo Achievement com os dados da conquista.
- **`await novaConquista.save();`**: Salva a conquista no banco de dados.
- **`conquistasCriadas.push(novaConquista);`**: Adiciona a conquista criada ao array de referência.
- **`console.log(\`✅ Conquista criada: ${conquista.nome}\`);`**: Exibe confirmação de cada conquista criada.

### 6. EXIBIÇÃO DE RESUMO

```javascript
        console.log(`\n🎉 ${conquistasCriadas.length} conquistas criadas com sucesso!`);
        console.log('\nConquistas criadas:');
        conquistasCriadas.forEach((c, index) => {
            console.log(`${index + 1}. ${c.nome} (${c.tipo})`);
        });
```

**Explicação detalhada:**

**Resumo final:**
- **`console.log(\`\n🎉 ${conquistasCriadas.length} conquistas criadas com sucesso!\`);`**: Exibe o total de conquistas criadas com emoji de celebração.

**Lista detalhada:**
- **`console.log('\nConquistas criadas:');`**: Inicia a lista de conquistas criadas.
- **`conquistasCriadas.forEach((c, index) => {`**: Itera sobre cada conquista criada com índice.
- **`console.log(\`${index + 1}. ${c.nome} (${c.tipo})\`);`**: Exibe cada conquista numerada com nome e tipo.

### 7. TRATAMENTO DE ERROS E FINALIZAÇÃO

```javascript
    } catch (error) {
        console.error('Erro ao criar conquistas:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Desconectado do MongoDB');
    }
}

// Executar o script
criarConquistasPadrao();
```

**Explicação detalhada:**

**Tratamento de erro:**
- **`catch (error) => {`**: Captura qualquer erro que ocorra durante o processo.
- **`console.error('Erro ao criar conquistas:', error);`**: Exibe o erro detalhado para debugging.

**Finalização:**
- **`finally {`**: Bloco que sempre é executado, independente de sucesso ou erro.
- **`await mongoose.disconnect();`**: Fecha a conexão com o MongoDB.
- **`console.log('Desconectado do MongoDB');`**: Confirma o fechamento da conexão.

**Execução do script:**
- **`criarConquistasPadrao();`**: Chama a função principal para executar o script.

## Funcionalidades Principais

### 1. **Sistema Completo de Conquistas**
- 22 conquistas organizadas em 6 categorias
- Progressão lógica de dificuldade
- Cobertura de todos os aspectos do sistema

### 2. **Categorização Inteligente**
- **Transferências**: Foca na atividade de envio e recebimento
- **Metas**: Recompensa a conclusão de objetivos
- **Coins**: Incentiva o acúmulo de riqueza virtual
- **Frequência**: Promove o uso regular do sistema
- **Perfil**: Recompensa a personalização
- **Balanço**: Incentiva interação equilibrada

### 3. **Progressão Gamificada**
- Conquistas de diferentes níveis de dificuldade
- Recompensas visuais com emojis únicos
- Sistema de progressão que mantém usuários engajados

### 4. **Proteção de Dados**
- Verifica conquistas existentes antes de criar
- Evita duplicação de dados
- Fornece instruções claras para recriação

## Estratégia de Gamificação

### 1. **Transferências Enviadas**
- **Objetivo**: Incentivar a generosidade e compartilhamento
- **Progressão**: 1 → 10 → 50 → 100 transferências
- **Psicologia**: Sensação de poder e generosidade

### 2. **Transferências Recebidas**
- **Objetivo**: Recompensar popularidade e aceitação social
- **Progressão**: 1 → 10 → 50 → 100 recebimentos
- **Psicologia**: Validação social e aceitação

### 3. **Metas**
- **Objetivo**: Incentivar participação em atividades
- **Progressão**: 1 → 10 → 50 → 100 metas
- **Psicologia**: Sensação de realização e progresso

### 4. **Coins Acumulados**
- **Objetivo**: Incentivar economia e planejamento
- **Progressão**: 100 → 500 → 1000 → 5000 coins
- **Psicologia**: Sensação de riqueza e sucesso

### 5. **Frequência**
- **Objetivo**: Promover uso regular do sistema
- **Progressão**: 7 → 30 → 100 dias consecutivos
- **Psicologia**: Formação de hábitos e dependência

### 6. **Perfil e Balanço**
- **Objetivo**: Incentivar personalização e interação equilibrada
- **Tipos**: Foto de perfil, equilíbrio, socialização
- **Psicologia**: Expressão pessoal e interação social

## Integração com o Sistema

### 1. **Verificação Automática**
- Os tipos de conquista correspondem aos verificados no modelo User
- Sistema automático de verificação de conquistas
- Atualização em tempo real das estatísticas

### 2. **Interface do Usuário**
- Categorias organizam as conquistas na interface
- Ícones visuais melhoram a experiência
- Progressão clara motiva o usuário

### 3. **Sistema de Recompensas**
- Conquistas desbloqueiam funcionalidades
- Badges visuais no perfil
- Sistema de ranking baseado em conquistas

## Como Executar

### 1. **Preparação**
```bash
# Certifique-se de que o .env está configurado
MONGODB_URI=mongodb://localhost:27017/ifc_coin

# Instale as dependências
npm install
```

### 2. **Execução**
```bash
# Execute o script
node backend/scripts/criar_conquistas_padrao.js
```

### 3. **Verificação**
- Verifique os logs de saída
- Confirme que 22 conquistas foram criadas
- Teste a verificação automática no sistema

## Considerações Importantes

### 1. **Execução Única**
- O script verifica se já existem conquistas
- Evita duplicação de dados
- Fornece instruções para recriação

### 2. **Personalização**
- Modifique as conquistas conforme necessário
- Ajuste requisitos e recompensas
- Adicione novas categorias se necessário

### 3. **Manutenção**
- Atualize conquistas quando o sistema evolui
- Mantenha consistência com mudanças nos modelos
- Teste a verificação automática após modificações

Este script é fundamental para estabelecer o sistema de gamificação completo do IFC Coin, fornecendo uma base sólida de conquistas que incentivam o uso e engajamento dos usuários.
# DOCUMENTAÇÃO DETALHADA - SCRIPT DE VERIFICAÇÃO DE CONQUISTAS (verificar_conquistas.js)

## Visão Geral
O arquivo `backend/scripts/verificar_conquistas.js` é um script de diagnóstico e debugging para o sistema de conquistas do IFC Coin. Este script permite verificar o estado atual das conquistas de um usuário, suas estatísticas, e listar todas as conquistas disponíveis no sistema. É uma ferramenta essencial para desenvolvimento, testes e manutenção do sistema de gamificação.

## Estrutura do Arquivo

### 1. IMPORTAÇÕES E DEPENDÊNCIAS

```javascript
const mongoose = require('mongoose');
const User = require('../models/userModel');
const Achievement = require('../models/achievementModel');
require('dotenv').config();
```

**Explicação linha por linha:**

- **`const mongoose = require('mongoose');`**: Importa a biblioteca Mongoose para conectar ao MongoDB e gerenciar os documentos.

- **`const User = require('../models/userModel');`**: Importa o modelo User para buscar informações de usuários e suas conquistas.

- **`const Achievement = require('../models/achievementModel');`**: Importa o modelo Achievement para listar todas as conquistas disponíveis no sistema.

- **`require('dotenv').config();`**: Carrega as variáveis de ambiente do arquivo `.env`, incluindo a string de conexão do MongoDB.

### 2. FUNÇÃO PRINCIPAL - VERIFICAR CONQUISTAS

```javascript
async function verificarConquistas() {
    try {
        console.log('Conectando ao MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Conectado ao MongoDB');
```

**Explicação detalhada:**

**Cabeçalho da função:**
- **`async function verificarConquistas() {`**: Define uma função assíncrona que será responsável por toda a verificação de conquistas.

**Conexão com o banco:**
- **`console.log('Conectando ao MongoDB...');`**: Exibe mensagem de início da conexão.
- **`await mongoose.connect(process.env.MONGODB_URI);`**: Estabelece conexão com o MongoDB usando a string de conexão das variáveis de ambiente.
- **`console.log('Conectado ao MongoDB');`**: Confirma que a conexão foi estabelecida.

### 3. BUSCA DE USUÁRIO COM CONQUISTAS

```javascript
        // Buscar um usuário com conquistas
        const usuario = await User.findOne({}).populate('conquistas.achievement');
        
        if (!usuario) {
            console.log('Nenhum usuário encontrado');
            return;
        }
```

**Explicação detalhada:**

**Busca de usuário:**
- **`const usuario = await User.findOne({});`**: Busca o primeiro usuário encontrado no banco de dados. O objeto vazio `{}` significa "qualquer documento".

**População de conquistas:**
- **`.populate('conquistas.achievement')`**: Popula (substitui) as referências de conquistas pelos documentos completos. Isso converte IDs em objetos completos de conquistas.

**Verificação de existência:**
- **`if (!usuario) {`**: Verifica se um usuário foi encontrado.
- **`console.log('Nenhum usuário encontrado');`**: Se não encontrado, exibe mensagem informativa.
- **`return;`**: Encerra a função se não houver usuários.

### 4. EXIBIÇÃO DE INFORMAÇÕES DO USUÁRIO

```javascript
        console.log(`\nUsuário: ${usuario.nome} (${usuario.matricula})`);
        console.log(`Conquistas: ${usuario.conquistas.length}`);
        console.log('Estatísticas:', usuario.estatisticas);
```

**Explicação detalhada:**

**Informações básicas do usuário:**
- **`console.log(\`\nUsuário: ${usuario.nome} (${usuario.matricula})\`);`**: Exibe o nome e matrícula do usuário encontrado.

**Contagem de conquistas:**
- **`console.log(\`Conquistas: ${usuario.conquistas.length}\`);`**: Exibe quantas conquistas o usuário possui.

**Estatísticas do usuário:**
- **`console.log('Estatísticas:', usuario.estatisticas);`**: Exibe todas as estatísticas do usuário (transferências enviadas/recebidas, metas concluídas, etc.).

### 5. LISTAGEM DAS CONQUISTAS DO USUÁRIO

```javascript
        if (usuario.conquistas.length > 0) {
            console.log('\nConquistas do usuário:');
            usuario.conquistas.forEach((conquista, index) => {
                console.log(`${index + 1}. ${conquista.achievement?.nome || 'Conquista não encontrada'} (${conquista.achievement?.categoria || 'Sem categoria'})`);
            });
        } else {
            console.log('\nUsuário não possui conquistas');
        }
```

**Explicação detalhada:**

**Verificação de conquistas:**
- **`if (usuario.conquistas.length > 0) {`**: Verifica se o usuário possui conquistas.

**Listagem detalhada:**
- **`console.log('\nConquistas do usuário:');`**: Inicia a listagem das conquistas.
- **`usuario.conquistas.forEach((conquista, index) => {`**: Itera sobre cada conquista do usuário com índice.

**Exibição segura:**
- **`conquista.achievement?.nome || 'Conquista não encontrada'`**: Usa optional chaining (`?.`) para acessar o nome da conquista de forma segura. Se a conquista não existir, exibe "Conquista não encontrada".
- **`conquista.achievement?.categoria || 'Sem categoria'`**: Similar ao anterior, mas para a categoria.

**Caso sem conquistas:**
- **`else { console.log('\nUsuário não possui conquistas'); }`**: Se o usuário não tiver conquistas, exibe mensagem informativa.

### 6. LISTAGEM DE TODAS AS CONQUISTAS DISPONÍVEIS

```javascript
        // Verificar todas as conquistas disponíveis
        const todasConquistas = await Achievement.find({});
        console.log(`\nTotal de conquistas disponíveis: ${todasConquistas.length}`);
        
        if (todasConquistas.length > 0) {
            console.log('\nConquistas disponíveis:');
            todasConquistas.forEach((conquista, index) => {
                console.log(`${index + 1}. ${conquista.nome} (${conquista.categoria}) - ${conquista.tipo}`);
            });
        }
```

**Explicação detalhada:**

**Busca de todas as conquistas:**
- **`const todasConquistas = await Achievement.find({});`**: Busca todas as conquistas disponíveis no sistema.

**Contagem total:**
- **`console.log(\`\nTotal de conquistas disponíveis: ${todasConquistas.length}\`);`**: Exibe o número total de conquistas no sistema.

**Listagem detalhada:**
- **`if (todasConquistas.length > 0) {`**: Verifica se existem conquistas no sistema.
- **`console.log('\nConquistas disponíveis:');`**: Inicia a listagem de todas as conquistas.
- **`todasConquistas.forEach((conquista, index) => {`**: Itera sobre cada conquista disponível.
- **`console.log(\`${index + 1}. ${conquista.nome} (${conquista.categoria}) - ${conquista.tipo}\`);`**: Exibe cada conquista numerada com nome, categoria e tipo.

### 7. TRATAMENTO DE ERROS E FINALIZAÇÃO

```javascript
    } catch (error) {
        console.error('Erro:', error);
    } finally {
        await mongoose.disconnect();
        console.log('\nDesconectado do MongoDB');
    }
}

// Executar o script
verificarConquistas();
```

**Explicação detalhada:**

**Tratamento de erro:**
- **`catch (error) => {`**: Captura qualquer erro que ocorra durante o processo.
- **`console.error('Erro:', error);`**: Exibe o erro detalhado para debugging.

**Finalização:**
- **`finally {`**: Bloco que sempre é executado, independente de sucesso ou erro.
- **`await mongoose.disconnect();`**: Fecha a conexão com o MongoDB.
- **`console.log('\nDesconectado do MongoDB');`**: Confirma o fechamento da conexão.

**Execução do script:**
- **`verificarConquistas();`**: Chama a função principal para executar o script.

## Funcionalidades Principais

### 1. **Diagnóstico de Usuário**
- Busca um usuário qualquer no sistema
- Exibe informações básicas (nome, matrícula)
- Mostra estatísticas completas
- Lista conquistas adquiridas

### 2. **Verificação de Conquistas**
- Popula referências de conquistas
- Exibe conquistas de forma segura
- Trata casos de conquistas não encontradas
- Numera conquistas para fácil identificação

### 3. **Visão Geral do Sistema**
- Lista todas as conquistas disponíveis
- Mostra total de conquistas no sistema
- Exibe categorias e tipos de conquistas
- Fornece visão completa do sistema de gamificação

### 4. **Debugging e Manutenção**
- Identifica problemas no sistema de conquistas
- Verifica integridade dos dados
- Facilita troubleshooting
- Ajuda na manutenção do sistema

## Casos de Uso

### 1. **Desenvolvimento**
- Verificar se conquistas estão sendo criadas corretamente
- Testar sistema de verificação automática
- Debuggar problemas de gamificação

### 2. **Testes**
- Verificar estado de usuários de teste
- Confirmar funcionamento do sistema
- Validar dados de conquistas

### 3. **Manutenção**
- Diagnosticar problemas no sistema
- Verificar integridade dos dados
- Monitorar estado das conquistas

## Exemplo de Saída

```
Conectando ao MongoDB...
Conectado ao MongoDB

Usuário: João Silva (2023001)
Conquistas: 3
Estatísticas: {
  transferenciasEnviadas: 15,
  transferenciasRecebidas: 8,
  metasConcluidas: 5,
  coinsAcumulados: 250,
  diasConsecutivos: 12
}

Conquistas do usuário:
1. Primeiro Passo (Transferências)
2. Participativo (Eventos)
3. Poupador Iniciante (Coins)

Total de conquistas disponíveis: 22

Conquistas disponíveis:
1. Primeiro Passo (Transferências) - primeira_transferencia
2. Distribuidor Generoso (Transferências) - transferencias_10
3. Mestre das Transferências (Transferências) - transferencias_50
...
22. Social (Balanço) - social

Desconectado do MongoDB
```

## Como Executar

### 1. **Preparação**
```bash
# Certifique-se de que o .env está configurado
MONGODB_URI=mongodb://localhost:27017/ifc_coin

# Instale as dependências
npm install
```

### 2. **Execução**
```bash
# Execute o script
node backend/scripts/verificar_conquistas.js
```

### 3. **Interpretação dos Resultados**
- Verifique se o usuário encontrado tem conquistas
- Compare estatísticas com conquistas adquiridas
- Confirme se todas as conquistas estão listadas
- Identifique possíveis problemas no sistema

## Considerações Importantes

### 1. **Usuário de Teste**
- O script busca o primeiro usuário encontrado
- Ideal ter usuários com dados para teste
- Execute o script de seed primeiro se necessário

### 2. **População de Dados**
- Usa `.populate()` para dados completos
- Trata casos de referências quebradas
- Exibe informações de forma segura

### 3. **Debugging**
- Identifica conquistas não encontradas
- Mostra estatísticas vs conquistas
- Facilita identificação de problemas

Este script é uma ferramenta essencial para desenvolvimento e manutenção do sistema de gamificação, fornecendo visibilidade completa sobre o estado das conquistas e facilitando a identificação de problemas.
