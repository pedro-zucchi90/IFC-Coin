const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const { verificarToken } = require('../middleware/auth');

const router = express.Router();

// Função para gerar token JWT
const gerarToken = (userId) => {
    return jwt.sign(
        { userId },
        process.env.JWT_SECRET,
        { expiresIn: '7d' } // Token expira em 7 dias
    );
};

// POST /api/auth/login
router.post('/login', async (req, res) => {
    try {
        const { matricula, senha } = req.body;

        // Validação dos campos
        if (!matricula || !senha) {
            return res.status(400).json({
                message: 'Matrícula e senha são obrigatórias'
            });
        }

        // Buscar usuário pela matrícula
        const user = await User.findOne({ matricula: matricula.trim() });

        if (!user) {
            return res.status(401).json({
                message: 'Matrícula ou senha incorretos'
            });
        }

        // Verificar se o usuário está ativo
        if (!user.ativo) {
            return res.status(401).json({
                message: 'Conta desativada. Entre em contato com o administrador.'
            });
        }

        // Verificar senha
        const senhaValida = await user.compararSenha(senha);
        if (!senhaValida) {
            return res.status(401).json({
                message: 'Matrícula ou senha incorretos'
            });
        }

        // Atualizar último login
        await user.atualizarUltimoLogin();

        // Gerar token JWT
        const token = gerarToken(user._id);

        // Retornar resposta
        res.json({
            message: 'Login realizado com sucesso',
            token,
            user: user.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro no login:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/auth/registro
router.post('/registro', async (req, res) => {
    try {
        const {
            nome,
            email,
            senha,
            matricula,
            role = 'aluno',
            curso,
            turmas = []
        } = req.body;

        // Validação dos campos obrigatórios
        if (!nome || !email || !senha || !matricula) {
            return res.status(400).json({
                message: 'Nome, email, senha e matrícula são obrigatórios'
            });
        }

        // Validação da senha
        if (senha.length < 6) {
            return res.status(400).json({
                message: 'Senha deve ter pelo menos 6 caracteres'
            });
        }

        // Verificar se matrícula já existe
        const matriculaExistente = await User.findOne({ matricula: matricula.trim() });
        if (matriculaExistente) {
            return res.status(400).json({
                message: 'Matrícula já cadastrada'
            });
        }

        // Verificar se email já existe
        const emailExistente = await User.findOne({ email: email.toLowerCase().trim() });
        if (emailExistente) {
            return res.status(400).json({
                message: 'Email já cadastrado'
            });
        }

        // Validação do curso para alunos
        if (role === 'aluno' && !curso) {
            return res.status(400).json({
                message: 'Curso é obrigatório para alunos'
            });
        }

        // Criar novo usuário
        const novoUser = new User({
            nome: nome.trim(),
            email: email.toLowerCase().trim(),
            senha,
            matricula: matricula.trim(),
            role,
            curso: role === 'aluno' ? curso : undefined,
            turmas: Array.isArray(turmas) ? turmas : []
        });

        await novoUser.save();

        // Gerar token JWT
        const token = gerarToken(novoUser._id);

        // Retornar resposta
        res.status(201).json({
            message: 'Usuário registrado com sucesso',
            token,
            user: novoUser.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro no registro:', error);
        
        if (error.code === 11000) {
            const campo = Object.keys(error.keyPattern)[0];
            return res.status(400).json({
                message: `${campo} já está em uso`
            });
        }

        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/auth/logout
router.post('/logout', verificarToken, async (req, res) => {
    try {
        // Em uma implementação mais robusta, você poderia:
        // 1. Adicionar o token a uma blacklist
        // 2. Atualizar o último logout do usuário
        // 3. Invalidar refresh tokens

        res.json({
            message: 'Logout realizado com sucesso'
        });
    } catch (error) {
        console.error('Erro no logout:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/auth/me - Obter dados do usuário logado
router.get('/me', verificarToken, async (req, res) => {
    try {
        res.json(req.user);
    } catch (error) {
        console.error('Erro ao obter dados do usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/auth/refresh - Renovar token (opcional)
router.post('/refresh', verificarToken, async (req, res) => {
    try {
        // Gerar novo token
        const novoToken = gerarToken(req.user._id);

        res.json({
            message: 'Token renovado com sucesso',
            token: novoToken
        });
    } catch (error) {
        console.error('Erro ao renovar token:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/auth/alterar-senha
router.post('/alterar-senha', verificarToken, async (req, res) => {
    try {
        const { senhaAtual, novaSenha } = req.body;

        if (!senhaAtual || !novaSenha) {
            return res.status(400).json({
                message: 'Senha atual e nova senha são obrigatórias'
            });
        }

        if (novaSenha.length < 6) {
            return res.status(400).json({
                message: 'Nova senha deve ter pelo menos 6 caracteres'
            });
        }

        // Buscar usuário com senha para verificação
        const user = await User.findById(req.user._id);

        // Verificar senha atual
        const senhaValida = await user.compararSenha(senhaAtual);
        if (!senhaValida) {
            return res.status(400).json({
                message: 'Senha atual incorreta'
            });
        }

        // Atualizar senha
        user.senha = novaSenha;
        await user.save();

        res.json({
            message: 'Senha alterada com sucesso'
        });

    } catch (error) {
        console.error('Erro ao alterar senha:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

module.exports = router; 