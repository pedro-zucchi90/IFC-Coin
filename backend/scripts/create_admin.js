const mongoose = require('mongoose');
const User = require('../models/userModel');
require('dotenv').config();

async function createAdmin() {
    try {
        // Conectar ao MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Conectado ao MongoDB');

        // Verificar se já existe um admin
        const existingAdmin = await User.findOne({ role: 'admin' });
        if (existingAdmin) {
            console.log('Já existe um administrador no sistema:', existingAdmin.nome);
            process.exit(0);
        }

        // Criar administrador padrão
        const admin = new User({
            nome: 'Administrador IFC Coin',
            email: 'admin@ifc.edu.br',
            matricula: '1234002',
            senha: 'admin12',
            role: 'admin',
            ativo: true,
            statusAprovacao: 'aprovado',
            saldo: 0,
            turmas: []
        });

        await admin.save();
        console.log('✅ Administrador criado com sucesso!');
        console.log('\nCredenciais do administrador:');
        console.log('Matrícula: 1234002');
        console.log('Senha: admin12');
        console.log('\nEste usuário pode ser usado para gerenciar o sistema via API.');

    } catch (error) {
        console.error('Erro ao criar administrador:', error);
    } finally {
        await mongoose.disconnect();
        process.exit(0);
    }
}

createAdmin(); 