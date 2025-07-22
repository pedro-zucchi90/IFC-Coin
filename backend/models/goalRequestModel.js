const mongoose = require('mongoose');

const goalRequestSchema = new mongoose.Schema({
  goal: { type: mongoose.Schema.Types.ObjectId, ref: 'Goal', required: true },
  aluno: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  status: { type: String, enum: ['pendente', 'aprovada', 'recusada'], default: 'pendente' },
  comentario: { type: String },
  evidenciaTexto: { type: String },
  evidenciaArquivo: { type: String }, // caminho do arquivo, se houver
  resposta: { type: String }, // comentário do admin/professor
  analisadoPor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  dataAnalise: { type: Date },
}, { timestamps: true });

module.exports = mongoose.model('GoalRequest', goalRequestSchema); 