const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
    tipo: { type: String, enum: ['recebido', 'enviado'], required: true },
    origem: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    destino: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    quantidade: Number,
    descricao: String,
    hash: String,
    status: { type: String, enum: ['pendente', 'aprovada', 'recusada'], default: 'aprovada' }, // Para transferências professor-aluno
}, 
{ timestamps: true });

module.exports = mongoose.model('Transaction', transactionSchema);