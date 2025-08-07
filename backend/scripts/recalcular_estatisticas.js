const mongoose = require('mongoose');
const User = require('../models/userModel');
const Transaction = require('../models/transactionModel');
const Goal = require('../models/goalModel');
require('dotenv').config();

async function recalcularEstatisticas() {
    try {
        console.log('Conectando ao MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Conectado ao MongoDB');

        console.log('Iniciando recálculo de estatísticas...');
        
        // Buscar todos os usuários
        const usuarios = await User.find({});
        console.log(`Encontrados ${usuarios.length} usuários`);

        for (const usuario of usuarios) {
            console.log(`\nProcessando usuário: ${usuario.nome} (${usuario.matricula})`);
            
            // Resetar estatísticas
            usuario.estatisticas = {
                totalTransferencias: 0,
                totalTransferenciasRecebidas: 0,
                totalMetasConcluidas: 0,
                totalCoinsGanhos: 0,
                diasConsecutivos: usuario.estatisticas.diasConsecutivos || 0,
                ultimoLoginConsecutivo: usuario.estatisticas.ultimoLoginConsecutivo || new Date(),
                temFotoPerfil: !!usuario.fotoPerfilBin
            };

            // Calcular transferências enviadas
            const transferenciasEnviadas = await Transaction.find({
                origem: usuario._id,
                status: 'aprovada'
            });
            usuario.estatisticas.totalTransferencias = transferenciasEnviadas.length;
            console.log(`  - Transferências enviadas: ${transferenciasEnviadas.length}`);

            // Calcular transferências recebidas
            const transferenciasRecebidas = await Transaction.find({
                destino: usuario._id,
                status: 'aprovada'
            });
            usuario.estatisticas.totalTransferenciasRecebidas = transferenciasRecebidas.length;
            console.log(`  - Transferências recebidas: ${transferenciasRecebidas.length}`);

            // Calcular total de coins ganhos (transferências recebidas + recompensas de metas)
            let totalCoinsGanhos = 0;
            
            // Coins de transferências recebidas
            for (const transacao of transferenciasRecebidas) {
                totalCoinsGanhos += transacao.quantidade;
            }
            
            // Coins de metas concluídas
            const metasConcluidas = await Goal.find({
                usuariosConcluidos: usuario._id
            });
            usuario.estatisticas.totalMetasConcluidas = metasConcluidas.length;
            
            for (const meta of metasConcluidas) {
                totalCoinsGanhos += meta.recompensa;
            }
            
            usuario.estatisticas.totalCoinsGanhos = totalCoinsGanhos;
            console.log(`  - Metas concluídas: ${metasConcluidas.length}`);
            console.log(`  - Total coins ganhos: ${totalCoinsGanhos}`);

            // Salvar usuário atualizado
            await usuario.save();
            
            // Verificar conquistas automaticamente
            const conquistasAdicionadas = await usuario.verificarConquistas();
            if (conquistasAdicionadas.length > 0) {
                console.log(`  - ✅ ${conquistasAdicionadas.length} conquista(s) adicionada(s):`);
                conquistasAdicionadas.forEach(conquista => {
                    console.log(`    • ${conquista.nome}`);
                });
            }
        }

        console.log('\n🎉 Recálculo de estatísticas concluído com sucesso!');
        console.log(`Processados ${usuarios.length} usuários`);

    } catch (error) {
        console.error('Erro ao recalcular estatísticas:', error);
    } finally {
        await mongoose.disconnect();
        console.log('Desconectado do MongoDB');
    }
}

// Executar o script
recalcularEstatisticas(); 