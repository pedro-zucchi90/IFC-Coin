const mongoose = require('mongoose');
const User = require('../models/userModel');
require('dotenv').config();

// Dados de professores pendentes
const professoresPendentes = [
    {
        nome: 'João Silva',
        email: 'joao.silva@ifc.edu.br',
        senha: '123456',
        matricula: '001',
        role: 'professor',
        turmas: ['INFO-2021-1', 'INFO-2021-2'],
        saldo: 0,
        statusAprovacao: 'pendente'
    },
    {
        nome: 'Maria Santos',
        email: 'maria.santos@ifc.edu.br',
        senha: '123456',
        matricula: '002',
        role: 'professor',
        turmas: ['ENGA-2021-1'],
        saldo: 0,
        statusAprovacao: 'pendente'
    },
    {
        nome: 'Pedro Oliveira',
        email: 'pedro.oliveira@ifc.edu.br',
        senha: '123456',
        matricula: '003',
        role: 'professor',
        turmas: ['AGRO-2021-1'],
        saldo: 0,
        statusAprovacao: 'pendente'
    }
];

async function adicionarProfessoresPendentes() {
    try {
        // Conectar ao MongoDB
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ifc_coin');
        console.log('Conectado ao MongoDB');

        // Verificar se já existem professores com essas matrículas
        for (const profData of professoresPendentes) {
            const existente = await User.findOne({ matricula: profData.matricula });
            if (existente) {
                console.log(`Professor com matrícula ${profData.matricula} já existe, pulando...`);
                continue;
            }

            const professor = new User(profData);
            await professor.save();
            console.log(`Professor ${profData.nome} criado com sucesso (matrícula: ${profData.matricula})`);
        }

        // Mostrar estatísticas
        const pendentes = await User.countDocuments({ role: 'professor', statusAprovacao: 'pendente' });
        const aprovados = await User.countDocuments({ role: 'professor', statusAprovacao: 'aprovado' });
        const recusados = await User.countDocuments({ role: 'professor', statusAprovacao: 'recusado' });

        console.log('\nEstatísticas dos professores:');
        console.log(`- Pendentes: ${pendentes}`);
        console.log(`- Aprovados: ${aprovados}`);
        console.log(`- Recusados: ${recusados}`);

        console.log('\nScript concluído com sucesso!');

    } catch (error) {
        console.error('Erro durante a execução:', error);
    } finally {
        // Fechar conexão
        await mongoose.connection.close();
        console.log('Conexão com MongoDB fechada');
        process.exit(0);
    }
}

// Executar o script
adicionarProfessoresPendentes(); 