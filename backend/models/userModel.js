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
        enum: ['Técnico em Alimentos', 'Agropecuária', 'Informática para Internet'],
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
    },
    conquistas: [{
        achievement: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Achievement'
        },
        dataConquista: {
            type: Date,
            default: Date.now
        }
    }],
    estatisticas: {
        totalTransferencias: { type: Number, default: 0 },
        totalTransferenciasRecebidas: { type: Number, default: 0 },
        totalMetasConcluidas: { type: Number, default: 0 },
        totalCoinsGanhos: { type: Number, default: 0 },
        diasConsecutivos: { type: Number, default: 0 },
        ultimoLoginConsecutivo: { type: Date, default: Date.now },
        temFotoPerfil: { type: Boolean, default: false }
    },
    resetPasswordToken: String,
    resetPasswordExpires: Date
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
        // Admin/professor: saldo ilimitado (não precisa checar limite)
        this.saldo += quantidade;
        return this.save();
    }
    throw new Error('Quantidade deve ser positiva');
};

// Método para remover coins do saldo do usuário
userSchema.methods.removerCoins = function(quantidade) {
    if (quantidade > 0) {
        // Admin/professor: saldo ilimitado (nunca ficam negativos)
        if (this.role === 'admin' || this.role === 'professor') {
            this.saldo = Math.max(0, this.saldo - quantidade); // só para manter coerência visual
            return this.save();
        }
        if (this.saldo >= quantidade) {
            this.saldo -= quantidade;
            return this.save();
        }
    }
    throw new Error('Saldo insuficiente ou quantidade inválida');
};

// Método para atualizar a data do último login
userSchema.methods.atualizarUltimoLogin = function() {
    this.ultimoLogin = new Date();
    return this.save();
};

// Método para adicionar conquista ao usuário
userSchema.methods.adicionarConquista = async function(achievementId) {
    // Verificar se já tem essa conquista
    const jaTemConquista = this.conquistas.some(c => c.achievement.toString() === achievementId.toString());
    if (!jaTemConquista) {
        this.conquistas.push({
            achievement: achievementId,
            dataConquista: new Date()
        });
        await this.save();
        return true; // Nova conquista adicionada
    }
    return false; // Já tinha a conquista
};

// Método para verificar e adicionar conquistas automaticamente
userSchema.methods.verificarConquistas = async function() {
    const Achievement = require('./achievementModel');
    const conquistasAdicionadas = [];

    // Buscar todas as conquistas disponíveis
    const todasConquistas = await Achievement.find({});

    for (const conquista of todasConquistas) {
        // Verificar se já tem essa conquista
        const jaTem = this.conquistas.some(c => c.achievement.toString() === conquista._id.toString());
        if (jaTem) continue;

        // Verificar requisitos baseados no tipo de conquista
        let deveAdicionar = false;

        switch (conquista.tipo) {
            // Transferências enviadas
            case 'primeira_transferencia':
                if (this.estatisticas.totalTransferencias >= 1) {
                    deveAdicionar = true;
                }
                break;
            case 'transferencias_10':
                if (this.estatisticas.totalTransferencias >= 10) {
                    deveAdicionar = true;
                }
                break;
            case 'transferencias_50':
                if (this.estatisticas.totalTransferencias >= 50) {
                    deveAdicionar = true;
                }
                break;
            case 'transferencias_100':
                if (this.estatisticas.totalTransferencias >= 100) {
                    deveAdicionar = true;
                }
                break;

            // Transferências recebidas
            case 'primeira_recebida':
                if (this.estatisticas.totalTransferenciasRecebidas >= 1) {
                    deveAdicionar = true;
                }
                break;
            case 'recebidas_10':
                if (this.estatisticas.totalTransferenciasRecebidas >= 10) {
                    deveAdicionar = true;
                }
                break;
            case 'recebidas_50':
                if (this.estatisticas.totalTransferenciasRecebidas >= 50) {
                    deveAdicionar = true;
                }
                break;
            case 'recebidas_100':
                if (this.estatisticas.totalTransferenciasRecebidas >= 100) {
                    deveAdicionar = true;
                }
                break;

            // Metas
            case 'primeira_meta':
                if (this.estatisticas.totalMetasConcluidas >= 1) {
                    deveAdicionar = true;
                }
                break;
            case 'metas_10':
                if (this.estatisticas.totalMetasConcluidas >= 10) {
                    deveAdicionar = true;
                }
                break;
            case 'metas_50':
                if (this.estatisticas.totalMetasConcluidas >= 50) {
                    deveAdicionar = true;
                }
                break;
            case 'metas_100':
                if (this.estatisticas.totalMetasConcluidas >= 100) {
                    deveAdicionar = true;
                }
                break;

            // Coins acumulados
            case 'coins_100':
                if (this.estatisticas.totalCoinsGanhos >= 100) {
                    deveAdicionar = true;
                }
                break;
            case 'coins_500':
                if (this.estatisticas.totalCoinsGanhos >= 500) {
                    deveAdicionar = true;
                }
                break;
            case 'coins_1000':
                if (this.estatisticas.totalCoinsGanhos >= 1000) {
                    deveAdicionar = true;
                }
                break;
            case 'coins_5000':
                if (this.estatisticas.totalCoinsGanhos >= 5000) {
                    deveAdicionar = true;
                }
                break;

            // Frequência
            case 'login_consecutivo_7':
                if (this.estatisticas.diasConsecutivos >= 7) {
                    deveAdicionar = true;
                }
                break;
            case 'login_consecutivo_30':
                if (this.estatisticas.diasConsecutivos >= 30) {
                    deveAdicionar = true;
                }
                break;
            case 'login_consecutivo_100':
                if (this.estatisticas.diasConsecutivos >= 100) {
                    deveAdicionar = true;
                }
                break;

            // Foto de perfil
            case 'foto_perfil':
                if (this.estatisticas.temFotoPerfil) {
                    deveAdicionar = true;
                }
                break;

            // Balanço geral
            case 'equilibrado':
                if (this.estatisticas.totalTransferencias >= 10 && 
                    this.estatisticas.totalTransferenciasRecebidas >= 10) {
                    deveAdicionar = true;
                }
                break;
            case 'social':
                if (this.estatisticas.totalTransferencias >= 5 && 
                    this.estatisticas.totalTransferenciasRecebidas >= 5) {
                    deveAdicionar = true;
                }
                break;
        }

        if (deveAdicionar) {
            await this.adicionarConquista(conquista._id);
            conquistasAdicionadas.push(conquista);
        }
    }

    return conquistasAdicionadas;
};

// Método para atualizar estatísticas
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
