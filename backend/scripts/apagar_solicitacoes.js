const mongoose = require('mongoose');
const GoalRequest = require('../models/goalRequestModel');
const Goal = require('../models/goalModel');
require('dotenv').config();

async function cleanGoalRequests() {
  try {
    // Conectar ao MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Conectado ao MongoDB');

    // Apagar todas as solicitações de conclusão
    const resultadoDeleteRequests = await GoalRequest.deleteMany({});
    console.log(`Solicitações apagadas: ${resultadoDeleteRequests.deletedCount}`);

    // Limpar usuários concluintes de todas as metas (opcional, mas recomendado se quiser reset completo)
    const metas = await Goal.find({});
    for (const meta of metas) {
      meta.usuariosConcluidos = [];
      await meta.save();
    }
    console.log(`Todos os usuários concluintes removidos de ${metas.length} metas`);

    console.log('✅ Seed finalizada com sucesso!');
  } catch (error) {
    console.error('Erro na seed:', error);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

cleanGoalRequests();
