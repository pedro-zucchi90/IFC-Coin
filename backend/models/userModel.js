const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

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
        match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Email inválido']
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
        default: 'aluno' 
    },
    curso: { 
        type: String, 
        enum: ['Engenharia de Alimentos', 'Agropecuária', 'Informática para Internet'],
        required: function() {
            return this.role === 'aluno';
        }
    },
    turmas: [String],
    saldo: { 
        type: Number, 
        default: 0,
        min: [0, 'Saldo não pode ser negativo']
    },
    fotoPerfil: { 
        type: String, 
        default: '' 
    },
    ultimoLogin: {
        type: Date,
        default: Date.now
    },
    ativo: {
        type: Boolean,
        default: true
    }
}, 
{ timestamps: true });

// Middleware para hash da senha antes de salvar
userSchema.pre('save', async function(next) {
    // Só hash a senha se ela foi modificada (ou é nova)
    if (!this.isModified('senha')) return next();
    
    try {
        // Hash da senha com salt de 12 rounds
        const salt = await bcrypt.genSalt(12);
        this.senha = await bcrypt.hash(this.senha, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Método para comparar senhas
userSchema.methods.compararSenha = async function(senhaCandidata) {
    return await bcrypt.compare(senhaCandidata, this.senha);
};

// Método para adicionar coins
userSchema.methods.adicionarCoins = function(quantidade) {
    if (quantidade > 0) {
        this.saldo += quantidade;
        return this.save();
    }
    throw new Error('Quantidade deve ser positiva');
};

// Método para remover coins
userSchema.methods.removerCoins = function(quantidade) {
    if (quantidade > 0 && this.saldo >= quantidade) {
        this.saldo -= quantidade;
        return this.save();
    }
    throw new Error('Saldo insuficiente ou quantidade inválida');
};

// Método para atualizar último login
userSchema.methods.atualizarUltimoLogin = function() {
    this.ultimoLogin = new Date();
    return this.save();
};

// Método para retornar dados públicos (sem senha)
userSchema.methods.toPublicJSON = function() {
    const userObject = this.toObject();
    delete userObject.senha;
    return userObject;
};

// Índices para melhor performance
userSchema.index({ email: 1 });
userSchema.index({ matricula: 1 });
userSchema.index({ role: 1 });
userSchema.index({ ativo: 1 });

module.exports = mongoose.model('User', userSchema);
