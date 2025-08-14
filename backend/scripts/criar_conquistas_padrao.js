const mongoose = require('mongoose');
const Achievement = require('../models/achievementModel');
require('dotenv').config();

// Conquistas padrão que serão criadas automaticamente
const conquistasPadrao = [
    // === TRANSFERÊNCIAS ENVIADAS ===
    {
        nome: 'Primeiro Passo',
        descricao: 'Realizou sua primeira transferência de IFC Coins',
        tipo: 'primeira_transferencia',
        categoria: 'Transferências',
        icone: '🚀',
        requisitos: 'Realizar 1 transferência'
    },
    {
        nome: 'Distribuidor Generoso',
        descricao: 'Realizou 10 transferências de IFC Coins',
        tipo: 'transferencias_10',
        categoria: 'Transferências',
        icone: '💸',
        requisitos: 'Realizar 10 transferências'
    },
    {
        nome: 'Mestre das Transferências',
        descricao: 'Realizou 50 transferências de IFC Coins',
        tipo: 'transferencias_50',
        categoria: 'Transferências',
        icone: '🏆',
        requisitos: 'Realizar 50 transferências'
    },
    {
        nome: 'Lenda das Transferências',
        descricao: 'Realizou 100 transferências de IFC Coins',
        tipo: 'transferencias_100',
        categoria: 'Transferências',
        icone: '👑',
        requisitos: 'Realizar 100 transferências'
    },

    // === TRANSFERÊNCIAS RECEBIDAS ===
    {
        nome: 'Primeira Recepção',
        descricao: 'Recebeu sua primeira transferência de IFC Coins',
        tipo: 'primeira_recebida',
        categoria: 'Recebimentos',
        icone: '📥',
        requisitos: 'Receber 1 transferência'
    },
    {
        nome: 'Receptor Popular',
        descricao: 'Recebeu 10 transferências de IFC Coins',
        tipo: 'recebidas_10',
        categoria: 'Recebimentos',
        icone: '🎁',
        requisitos: 'Receber 10 transferências'
    },
    {
        nome: 'Ímã de Coins',
        descricao: 'Recebeu 50 transferências de IFC Coins',
        tipo: 'recebidas_50',
        categoria: 'Recebimentos',
        icone: '🧲',
        requisitos: 'Receber 50 transferências'
    },
    {
        nome: 'Celebridade do IFC',
        descricao: 'Recebeu 100 transferências de IFC Coins',
        tipo: 'recebidas_100',
        categoria: 'Recebimentos',
        icone: '⭐',
        requisitos: 'Receber 100 transferências'
    },

    // === METAS ===
    {
        nome: 'Primeira Conquista',
        descricao: 'Concluiu sua primeira meta',
        tipo: 'primeira_meta',
        categoria: 'Metas',
        icone: '✅',
        requisitos: 'Concluir 1 meta'
    },
    {
        nome: 'Persistente',
        descricao: 'Concluiu 10 metas',
        tipo: 'metas_10',
        categoria: 'Metas',
        icone: '🎯',
        requisitos: 'Concluir 10 metas'
    },
    {
        nome: 'Mestre das Metas',
        descricao: 'Concluiu 50 metas',
        tipo: 'metas_50',
        categoria: 'Metas',
        icone: '🎖️',
        requisitos: 'Concluir 50 metas'
    },
    {
        nome: 'Lenda das Metas',
        descricao: 'Concluiu 100 metas',
        tipo: 'metas_100',
        categoria: 'Metas',
        icone: '🏅',
        requisitos: 'Concluir 100 metas'
    },

    // === COINS ACUMULADOS ===
    {
        nome: 'Poupador Iniciante',
        descricao: 'Acumulou 100 IFC Coins',
        tipo: 'coins_100',
        categoria: 'Coins',
        icone: '🪙',
        requisitos: 'Acumular 100 IFC Coins'
    },
    {
        nome: 'Investidor',
        descricao: 'Acumulou 500 IFC Coins',
        tipo: 'coins_500',
        categoria: 'Coins',
        icone: '💎',
        requisitos: 'Acumular 500 IFC Coins'
    },
    {
        nome: 'Milionário',
        descricao: 'Acumulou 1000 IFC Coins',
        tipo: 'coins_1000',
        categoria: 'Coins',
        icone: '💰',
        requisitos: 'Acumular 1000 IFC Coins'
    },
    {
        nome: 'Bilionário',
        descricao: 'Acumulou 5000 IFC Coins',
        tipo: 'coins_5000',
        categoria: 'Coins',
        icone: '💎',
        requisitos: 'Acumular 5000 IFC Coins'
    },

    // === FREQUÊNCIA ===
    {
        nome: 'Frequente',
        descricao: 'Acessou o app por 7 dias consecutivos',
        tipo: 'login_consecutivo_7',
        categoria: 'Frequência',
        icone: '📅',
        requisitos: 'Acessar por 7 dias consecutivos'
    },
    {
        nome: 'Viciado',
        descricao: 'Acessou o app por 30 dias consecutivos',
        tipo: 'login_consecutivo_30',
        categoria: 'Frequência',
        icone: '🔥',
        requisitos: 'Acessar por 30 dias consecutivos'
    },
    {
        nome: 'Lenda da Frequência',
        descricao: 'Acessou o app por 100 dias consecutivos',
        tipo: 'login_consecutivo_100',
        categoria: 'Frequência',
        icone: '⚡',
        requisitos: 'Acessar por 100 dias consecutivos'
    },

    // === FOTO DE PERFIL ===
    {
        nome: 'Fotogênico',
        descricao: 'Atualizou sua foto de perfil',
        tipo: 'foto_perfil',
        categoria: 'Perfil',
        icone: '📸',
        requisitos: 'Atualizar foto de perfil'
    },

    // === BALANÇO GERAL ===
    {
        nome: 'Equilibrado',
        descricao: 'Enviou e recebeu pelo menos 10 transferências cada',
        tipo: 'equilibrado',
        categoria: 'Balanço',
        icone: '⚖️',
        requisitos: 'Enviar e receber 10+ transferências cada'
    },
    {
        nome: 'Social',
        descricao: 'Realizou pelo menos 5 transferências e recebeu pelo menos 5',
        tipo: 'social',
        categoria: 'Balanço',
        icone: '🤝',
        requisitos: 'Realizar e receber 5+ transferências cada'
    }
];

async function criarConquistasPadrao() {
    try {
        console.log('Conectando ao MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Conectado ao MongoDB');

        console.log('Verificando conquistas existentes...');
        const conquistasExistentes = await Achievement.find({});
        
        if (conquistasExistentes.length > 0) {
            console.log(`Já existem ${conquistasExistentes.length} conquistas no banco.`);
            console.log('Para recriar todas as conquistas, delete-as primeiro.');
            return;
        }

        console.log('Criando conquistas padrão...');
        const conquistasCriadas = [];

        for (const conquista of conquistasPadrao) {
            const novaConquista = new Achievement(conquista);
            await novaConquista.save();
            conquistasCriadas.push(novaConquista);
            console.log(`✅ Conquista criada: ${conquista.nome}`);
        }

        console.log(`\n🎉 ${conquistasCriadas.length} conquistas criadas com sucesso!`);
        console.log('\nConquistas criadas:');
        conquistasCriadas.forEach((c, index) => {
            console.log(`${index + 1}. ${c.nome} (${c.tipo})`);
        });

    } catch (error) {
        console.error('Erro ao criar conquistas:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Desconectado do MongoDB');
    }
}

// Executar o script
criarConquistasPadrao(); 