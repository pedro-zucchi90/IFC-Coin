// Carrega variáveis de ambiente do arquivo .env (deve ser o primeiro)
require('dotenv').config(); // <--- DEVE vir antes de tudo

// Importa bibliotecas principais
const express = require('express'); // Framework web para Node.js
const mongoose = require('mongoose'); // ODM para MongoDB
const cors = require('cors'); // Middleware para habilitar CORS
const helmet = require('helmet'); // Middleware de segurança HTTP
const rateLimit = require('express-rate-limit'); // Middleware para limitar requisições
const path = require('path'); // Utilitário para manipulação de caminhos

// Importa rotas
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');

// Importa modelos do banco de dados
const User = require('./models/userModel');
const Transaction = require('./models/transactionModel');
const Goal = require('./models/goalModel');
const Achievement = require('./models/achievementModel');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de segurança HTTP (protege contra várias vulnerabilidades)
app.use(helmet());

// Configuração do CORS para permitir requisições de origens específicas
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:8000'],
  credentials: true
}));

// Limita o número de requisições por IP para evitar ataques de força bruta/DDOS
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // limite de 100 requests por IP
  message: 'Muitas requisições deste IP, tente novamente mais tarde.'
});
app.use('/api/', limiter);

// Middleware para interpretar JSON e dados de formulários
app.use(express.json({ limit: '10mb' })); // Aceita JSON até 10MB
app.use(express.urlencoded({ extended: true }));

// Servir arquivos estáticos da pasta uploads (ex: fotos de perfil, evidências)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

console.log('Tentando conectar ao MongoDB...');
// Conecta ao banco de dados MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ifc_coin')
.then(() => {
  console.log('Conectado ao MongoDB');
})
.catch((err) => {
  console.error('Erro ao conectar ao MongoDB:', err);
  process.exit(1);
});

// Rotas principais da API
app.use('/api/auth', authRoutes); // Autenticação e registro
app.use('/api/user', userRoutes); // Usuários
app.use('/api/transaction', require('./routes/transaction')); // Transações
app.use('/api/goal', require('./routes/goal')); // Metas
app.use('/api/achievement', require('./routes/achievement')); // Conquistas
app.use('/api/admin', require('./routes/admin')); // Administração

// Rota de teste para verificar se a API está online
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'API está funcionando',
    timestamp: new Date().toISOString()
  });
});

// Middleware de tratamento de erros gerais
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    message: 'Erro interno do servidor',
    error: process.env.NODE_ENV === 'development' ? err.message : {}
  });
});

// Middleware para rotas não encontradas (404)
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Rota não encontrada' });
});

// Inicia o servidor na porta 3000 (ou definida no .env)
app.listen(3000, '0.0.0.0', () => {
  console.log('Servidor rodando na porta 3000');
  console.log('API disponível em: http://192.168.0.107:3000/api');
}); 
