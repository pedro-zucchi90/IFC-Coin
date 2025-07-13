require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/userModel');

async function updateUsersStatus() {
  try {
    console.log('Conectando ao MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ifc_coin');
    console.log('Conectado ao MongoDB');

    // Atualizar professores existentes para status 'aprovado' (já estão ativos)
    const professoresResult = await User.updateMany(
      { 
        role: 'professor',
        statusAprovacao: { $exists: false }
      },
      { 
        $set: { statusAprovacao: 'aprovado' }
      }
    );

    // Atualizar alunos existentes para status 'aprovado'
    const alunosResult = await User.updateMany(
      { 
        role: 'aluno',
        statusAprovacao: { $exists: false }
      },
      { 
        $set: { statusAprovacao: 'aprovado' }
      }
    );

    // Atualizar admins existentes para status 'aprovado'
    const adminsResult = await User.updateMany(
      { 
        role: 'admin',
        statusAprovacao: { $exists: false }
      },
      { 
        $set: { statusAprovacao: 'aprovado' }
      }
    );

    console.log('Atualização concluída:');
    console.log(`- Professores atualizados: ${professoresResult.modifiedCount}`);
    console.log(`- Alunos atualizados: ${alunosResult.modifiedCount}`);
    console.log(`- Admins atualizados: ${adminsResult.modifiedCount}`);

    // Verificar usuários sem statusAprovacao
    const usuariosSemStatus = await User.countDocuments({
      statusAprovacao: { $exists: false }
    });

    if (usuariosSemStatus > 0) {
      console.log(`Ainda existem ${usuariosSemStatus} usuários sem statusAprovacao`);
    } else {
      console.log('Todos os usuários foram atualizados com sucesso!');
    }

  } catch (error) {
    console.error('Erro durante a atualização:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Desconectado do MongoDB');
  }
}

// Executar o script
updateUsersStatus(); 