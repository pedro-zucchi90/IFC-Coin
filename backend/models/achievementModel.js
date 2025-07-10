const mongoose = require('mongoose');

const achievementSchema = new mongoose.Schema({
    nome: { type: String, required: true }, 
    descricao: { type: String, required: true }, 
    tipo: { type: String, enum: ['medalha', 'conquista', 'titulo'], required: true },
    categoria: { type: String }, 
    icone: { type: String }, 
    requisitos: { type: String }, 
}, 
{ timestamps: true });

module.exports = mongoose.model('Achievement', achievementSchema);
