const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Schema do usuário, define a estrutura dos documentos na coleção 'users'
const userSchema = new mongoose.Schema({
    nome: {
        type: String,
        required: [true, 'Nome é obrigatório'],
        trim: true
    },
    email: { 
        type: String, 
        unique: true,
        required: [true, 'Email é obrigatório'],
        lowercase: true,
        trim: true,
        match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Email inválido'] // Regex para validar email
    },
    senha: {
        type: String,
        required: [true, 'Senha é obrigatória'],
        minlength: [6, 'Senha deve ter pelo menos 6 caracteres']
    },
    matricula: { 
        type: String, 
        unique: true,
        required: [true, 'Matrícula é obrigatória'],
        trim: true
    },
    role: { 
        type: String, 
        enum: ['aluno', 'professor', 'admin'], 
        default: 'aluno' // Define o tipo de usuário
    },
    statusAprovacao: {
        type: String,
        enum: ['pendente', 'aprovado', 'recusado'],
        default: function() {
            // Professores começam como pendentes, outros como aprovados
            return this.role === 'professor' ? 'pendente' : 'aprovado';
        }
    },
    curso: { 
        type: String, 
        enum: ['Engenharia de Alimentos', 'Agropecuária', 'Informática para Internet'],
        required: function() {
            // Curso é obrigatório apenas para alunos
            return this.role === 'aluno';
        }
    },
    turmas: [String], // Lista de turmas do usuário
    saldo: { 
        type: Number, 
        default: 0,
        min: [0, 'Saldo não pode ser negativo']
    },
    fotoPerfil: { 
        type: String, 
        default: '' // URL ou caminho da foto de perfil
    },
    fotoPerfilBin: {
        type: Buffer,
        select: false //não retorna por padrão
    },
    ultimoLogin: {
        type: Date,
        default: Date.now //daata do último login
    },
    ativo: {
        type: Boolean,
        default: true //usuário ativo ou não
    }
}, 
{ timestamps: true }); //adiciona createdAt e updatedAt automaticamente

// Middleware para hash da senha antes de salvar o usuário
userSchema.pre('save', async function(next) {
    // Só faz hash se a senha foi modificada ou é novo usuário
    if (!this.isModified('senha')) return next();
    
    try {
        // Gera salt e faz hash da senha
        const salt = await bcrypt.genSalt(12);
        this.senha = await bcrypt.hash(this.senha, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Método de instância para comparar senha informada com a salva (hash)
userSchema.methods.compararSenha = async function(senhaCandidata) {
    return await bcrypt.compare(senhaCandidata, this.senha);
};

// Método para adicionar coins ao saldo do usuário
userSchema.methods.adicionarCoins = function(quantidade) {
    if (quantidade > 0) {
        this.saldo += quantidade;
        return this.save();
    }
    throw new Error('Quantidade deve ser positiva');
};

// Método para remover coins do saldo do usuário
userSchema.methods.removerCoins = function(quantidade) {
    if (quantidade > 0 && this.saldo >= quantidade) {
        this.saldo -= quantidade;
        return this.save();
    }
    throw new Error('Saldo insuficiente ou quantidade inválida');
};

// Método para atualizar a data do último login
userSchema.methods.atualizarUltimoLogin = function() {
    this.ultimoLogin = new Date();
    return this.save();
};

// Método para retornar os dados públicos do usuário (sem senha e foto binária)
userSchema.methods.toPublicJSON = function() {
    const userObject = this.toObject();
    delete userObject.senha;
    delete userObject.fotoPerfilBin;
    return userObject;
};

// Índices para melhorar performance em buscas por role e ativo
userSchema.index({ role: 1 });
userSchema.index({ ativo: 1 });

// Exporta o modelo User para ser usado em outras partes do projeto
module.exports = mongoose.model('User', userSchema);
