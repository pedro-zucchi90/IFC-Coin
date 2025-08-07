const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const { verificarToken } = require('../middleware/auth');

const router = express.Router();

// Função para gerar token JWT
const gerarToken = (userId, role) => {
    return jwt.sign(
        { userId, role },
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

        // Verificar status de aprovação para professores
        if (user.role === 'professor') {
            if (user.statusAprovacao === 'pendente') {
                return res.status(401).json({
                    message: 'Sua conta está aguardando aprovação de um administrador.'
                });
            } else if (user.statusAprovacao === 'recusado') {
                return res.status(401).json({
                    message: 'Sua solicitação de cadastro foi recusada. Entre em contato com o administrador.'
                });
            } else if (user.statusAprovacao === 'aprovado') {
                const showApprovalNotification = !user.ultimoLogin || 
                    (user.ultimoLogin < user.updatedAt && user.updatedAt > user.createdAt);
                
                // Atualizar último login
                await user.atualizarUltimoLogin();
                
                // Gerar token JWT
                const token = gerarToken(user._id, user.role);
                
                // Adicionar flag para mostrar notificação de aprovação apenas na primeira vez
                return res.json({
                    message: 'Login realizado com sucesso',
                    token,
                    user: user.toPublicJSON(),
                    showApprovalNotification: showApprovalNotification
                });
            }
        }

        // Verificar senha
        const senhaValida = await user.compararSenha(senha);
        if (!senhaValida) {
            return res.status(401).json({
                message: 'Senha incorreta'
            });
        }

        // Atualizar último login
        await user.atualizarUltimoLogin();
        
        // Atualizar estatísticas de login consecutivo
        const hoje = new Date();
        const ultimoLogin = user.estatisticas.ultimoLoginConsecutivo;
        let diasConsecutivos = user.estatisticas.diasConsecutivos || 0;
        
        if (ultimoLogin) {
            const diffTime = hoje.getTime() - ultimoLogin.getTime();
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            if (diffDays === 1) {
                // Login consecutivo
                diasConsecutivos++;
            } else if (diffDays > 1) {
                // Quebrou a sequência
                diasConsecutivos = 1;
            }
            // Se diffDays === 0, é o mesmo dia, não altera
        } else {
            // Primeiro login
            diasConsecutivos = 1;
        }
        
        await user.atualizarEstatisticas('login_consecutivo', diasConsecutivos);
        
        // Verificar conquistas automaticamente
        await user.verificarConquistas();

        // Gerar token JWT
        const token = gerarToken(user._id, user.role);

        // Retornar resposta
        res.json({
            message: 'Login realizado com sucesso',
            token,
            user: user.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro no login:', error);
        res.status(500).json({
            message: process.env.NODE_ENV === 'development' ? (error.message + (error.stack ? '\n' + error.stack : '')) : 'Erro interno do servidor',
            dbError: process.env.NODE_ENV === 'development' ? error : undefined
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
            console.log('Campos obrigatórios faltando');
            return res.status(400).json({
                message: 'Nome, email, senha e matrícula são obrigatórios'
            });
        }

        // Validação da senha
        if (senha.length < 6) {
            console.log('Senha muito curta');
            return res.status(400).json({
                message: 'Senha deve ter pelo menos 6 caracteres'
            });
        }

        // Buscar por e-mail e matrícula
        let matriculaExistente = await User.findOne({ matricula: matricula.trim() });
        let emailExistente = await User.findOne({ email: email.toLowerCase().trim() });
        // Se ambos existem e são usuários diferentes, erro
        if (matriculaExistente && emailExistente && String(matriculaExistente._id) !== String(emailExistente._id)) {
            return res.status(400).json({ message: 'Já existe um usuário com este e-mail e outro com esta matrícula. Use dados diferentes.' });
        }
        // Se matrícula existe e é professor
        if (matriculaExistente && matriculaExistente.role === 'professor') {
            // Verificar se o novo email está em uso por outro usuário
            const outroEmail = await User.findOne({ email: email.toLowerCase().trim(), _id: { $ne: matriculaExistente._id } });
            if (outroEmail) {
                return res.status(400).json({ message: 'Email já cadastrado' });
            }
            matriculaExistente.nome = nome.trim();
            matriculaExistente.email = email.toLowerCase().trim();
            matriculaExistente.senha = senha;
            matriculaExistente.statusAprovacao = 'pendente';
            matriculaExistente.curso = undefined;
            matriculaExistente.turmas = Array.isArray(turmas) ? turmas : [];
            matriculaExistente.matricula = matricula.trim();
            await matriculaExistente.save();
            return res.status(201).json({
                message: 'Cadastro realizado com sucesso! Aguarde a aprovação de um administrador para fazer login.',
                user: matriculaExistente.toPublicJSON()
            });
        }
        // Se email existe e é professor recusado
        if (emailExistente && emailExistente.role === 'professor' && emailExistente.statusAprovacao === 'recusado') {
            // Verificar se a nova matrícula está em uso por outro usuário
            const outraMatricula = await User.findOne({ matricula: matricula.trim(), _id: { $ne: emailExistente._id } });
            if (outraMatricula) {
                return res.status(400).json({ message: 'Matrícula já cadastrada' });
            }
            emailExistente.nome = nome.trim();
            emailExistente.matricula = matricula.trim();
            emailExistente.senha = senha;
            emailExistente.statusAprovacao = 'pendente';
            emailExistente.curso = undefined;
            emailExistente.turmas = Array.isArray(turmas) ? turmas : [];
            emailExistente.email = email.toLowerCase().trim();
            await emailExistente.save();
            return res.status(201).json({
                message: 'Cadastro realizado com sucesso! Aguarde a aprovação de um administrador para fazer login.',
                user: emailExistente.toPublicJSON()
            });
        }
        
        // Bloquear se matrícula já existe
        if (matriculaExistente) {
            return res.status(400).json({
                message: 'Matrícula já cadastrada'
            });
        }

        // Bloquear se email já existe
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

        // Se for professor, não gerar token (aguarda aprovação)
        if (role === 'professor') {
            return res.status(201).json({
                message: 'Cadastro realizado com sucesso! Aguarde a aprovação de um administrador para fazer login.',
                user: novoUser.toPublicJSON()
            });
        }

        // Gerar token JWT apenas para alunos e admins
        const token = gerarToken(novoUser._id, novoUser.role);

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
            console.log('Erro de duplicação no campo:', campo);
            return res.status(400).json({
                message: `${campo} já está em uso`
            });
        }

        res.status(500).json({
            message: process.env.NODE_ENV === 'development' ? (error.message + (error.stack ? '\n' + error.stack : '')) : 'Erro interno do servidor',
            dbError: process.env.NODE_ENV === 'development' ? error : undefined
        });
    }
});

// POST /api/auth/logout
router.post('/logout', verificarToken, async (req, res) => {
    try {
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
        res.json(req.user); // req.user já é toPublicJSON pelo middleware
    } catch (error) {
        console.error('Erro ao obter dados do usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/auth/verify - Verificar se o token é válido
router.get('/verify', verificarToken, async (req, res) => {
    try {
        res.json({
            message: 'Token válido',
            user: req.user
        });
    } catch (error) {
        console.error('Erro ao verificar token:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/auth/refresh - Renovar token (opcional)
router.post('/refresh', verificarToken, async (req, res) => {
    try {
        // Gerar novo token
        const novoToken = gerarToken(req.user._id, req.user.role);
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

module.exports = router; 