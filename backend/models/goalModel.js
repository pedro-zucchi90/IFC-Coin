const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema({
    titulo: String,
    descricao: String,
    tipo: { type: String, enum: ['evento', 'indicacao', 'desempenho', 'custom'] },
    recompensa: Number, // coins
    usuariosConcluidos: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    // Controles de segurança
    ativo: { type: Boolean, default: true },
    requerAprovacao: { type: Boolean, default: false }, // Se precisa de aprovação de professor/admin
    maxConclusoes: { type: Number, default: null }, // Limite máximo de conclusões (null = ilimitado)
    periodoValidade: { type: Number, default: null }, // Dias de validade (null = sempre válida)
    dataInicio: { type: Date, default: Date.now },
    dataFim: { type: Date, default: null },
    // Evidências necessárias
    evidenciaObrigatoria: { type: Boolean, default: false },
    tipoEvidencia: { type: String, enum: ['foto', 'documento', 'comprovante', 'texto'], default: 'texto' },
    descricaoEvidencia: String,
}, { timestamps: true });

module.exports = mongoose.model('Goal', goalSchema);