const mongoose = require('mongoose');
const User = require('./models/userModel');
require('dotenv').config();

async function testLogin() {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ifc_coin');
        console.log('Conectado ao MongoDB');

        // Buscar usuário
        const user = await User.findOne({ matricula: '2021001' });
        if (!user) {
            console.log('Usuário não encontrado');
            return;
        }

        console.log('Usuário encontrado:', {
            nome: user.nome,
            matricula: user.matricula,
            role: user.role,
            senhaHash: user.senha.substring(0, 20) + '...' // Mostrar apenas o início do hash
        });

        // Testar comparação de senha
        const senhaCorreta = await user.compararSenha('123456');
        const senhaIncorreta = await user.compararSenha('senhaerradaaaa');

        console.log('Teste de senha "123456":', senhaCorreta);
        console.log('Teste de senha "senhaerrada":', senhaIncorreta);

        await mongoose.connection.close();
    } catch (error) {
        console.error('Erro:', error);
    }
}

testLogin(); 