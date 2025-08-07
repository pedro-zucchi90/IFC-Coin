const mongoose = require('mongoose');
const User = require('../models/userModel');
const Achievement = require('../models/achievementModel');
require('dotenv').config();

async function verificarConquistas() {
    try {
        console.log('Conectando ao MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Conectado ao MongoDB');

        // Buscar um usuário com conquistas
        const usuario = await User.findOne({}).populate('conquistas.achievement');
        
        if (!usuario) {
            console.log('Nenhum usuário encontrado');
            return;
        }

        console.log(`\nUsuário: ${usuario.nome} (${usuario.matricula})`);
        console.log(`Conquistas: ${usuario.conquistas.length}`);
        console.log('Estatísticas:', usuario.estatisticas);
        
        if (usuario.conquistas.length > 0) {
            console.log('\nConquistas do usuário:');
            usuario.conquistas.forEach((conquista, index) => {
                console.log(`${index + 1}. ${conquista.achievement?.nome || 'Conquista não encontrada'} (${conquista.achievement?.categoria || 'Sem categoria'})`);
            });
        } else {
            console.log('\nUsuário não possui conquistas');
        }

        // Verificar todas as conquistas disponíveis
        const todasConquistas = await Achievement.find({});
        console.log(`\nTotal de conquistas disponíveis: ${todasConquistas.length}`);
        
        if (todasConquistas.length > 0) {
            console.log('\nConquistas disponíveis:');
            todasConquistas.forEach((conquista, index) => {
                console.log(`${index + 1}. ${conquista.nome} (${conquista.categoria}) - ${conquista.tipo}`);
            });
        }

    } catch (error) {
        console.error('Erro:', error);
    } finally {
        await mongoose.disconnect();
        console.log('\nDesconectado do MongoDB');
    }
}

// Executar o script
verificarConquistas(); 