const mongoose = require('mongoose');

const achievementSchema = new mongoose.Schema({
    nome: { type: String, required: true }, 
    descricao: { type: String, required: true }, 
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
    categoria: { type: String }, 
    icone: { type: String }, 
    requisitos: { type: String }, 
}, 
{ timestamps: true });

module.exports = mongoose.model('Achievement', achievementSchema);
