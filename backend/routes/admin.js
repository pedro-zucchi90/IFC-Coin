const express = require('express');
const User = require('../models/userModel');
const { verificarToken, verificarAdmin } = require('../middleware/auth');

const router = express.Router();

// GET /api/admin/solicitacoes-professores - Listar solicitações de professores pendentes
router.get('/solicitacoes-professores', verificarToken, async (req, res) => {
    try {
        // Verificar se o usuário é admin
        if (req.user.role !== 'admin') {
            return res.status(403).json({
                message: 'Acesso negado. Apenas administradores podem acessar esta funcionalidade.'
            });
        }

        const { page = 1, limit = 10, status } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        // Construir filtros
        const filtros = { role: 'professor' };
        if (status) {
            filtros.statusAprovacao = status;
        }

        const solicitacoes = await User.find(filtros)
            .select('-senha')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await User.countDocuments(filtros);

        res.json({
            solicitacoes,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar solicitações:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/admin/aprovar-professor/:id - Aprovar solicitação de professor
router.post('/aprovar-professor/:id', verificarToken, async (req, res) => {
    try {
        // Verificar se o usuário é admin
        if (req.user.role !== 'admin') {
            return res.status(403).json({
                message: 'Acesso negado. Apenas administradores podem acessar esta funcionalidade.'
            });
        }

        const { id } = req.params;
        const { motivo } = req.body;

        const professor = await User.findById(id);
        
        if (!professor) {
            return res.status(404).json({
                message: 'Professor não encontrado'
            });
        }

        if (professor.role !== 'professor') {
            return res.status(400).json({
                message: 'Usuário não é um professor'
            });
        }

        if (professor.statusAprovacao !== 'pendente') {
            return res.status(400).json({
                message: 'Solicitação já foi processada'
            });
        }

        // Aprovar professor
        professor.statusAprovacao = 'aprovado';
        professor.ativo = true;
        await professor.save();

        res.json({
            message: 'Professor aprovado com sucesso',
            professor: professor.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro ao aprovar professor:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/admin/recusar-professor/:id - Recusar solicitação de professor
router.post('/recusar-professor/:id', verificarToken, async (req, res) => {
    try {
        // Verificar se o usuário é admin
        if (req.user.role !== 'admin') {
            return res.status(403).json({
                message: 'Acesso negado. Apenas administradores podem acessar esta funcionalidade.'
            });
        }

        const { id } = req.params;
        const { motivo } = req.body;

        const professor = await User.findById(id);
        
        if (!professor) {
            return res.status(404).json({
                message: 'Professor não encontrado'
            });
        }

        if (professor.role !== 'professor') {
            return res.status(400).json({
                message: 'Usuário não é um professor'
            });
        }

        if (professor.statusAprovacao !== 'pendente') {
            return res.status(400).json({
                message: 'Solicitação já foi processada'
            });
        }

        // Recusar professor
        professor.statusAprovacao = 'recusado';
        professor.ativo = false; // Desativar conta recusada
        await professor.save();

        res.json({
            message: 'Solicitação de professor recusada',
            professor: professor.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro ao recusar professor:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/admin/estatisticas-solicitacoes - Estatísticas das solicitações
router.get('/estatisticas-solicitacoes', verificarToken, async (req, res) => {
    try {
        // Verificar se o usuário é admin
        if (req.user.role !== 'admin') {
            return res.status(403).json({
                message: 'Acesso negado. Apenas administradores podem acessar esta funcionalidade.'
            });
        }

        const pendentes = await User.countDocuments({ 
            role: 'professor', 
            statusAprovacao: 'pendente' 
        });
        
        const aprovados = await User.countDocuments({ 
            role: 'professor', 
            statusAprovacao: 'aprovado' 
        });
        
        const recusados = await User.countDocuments({ 
            role: 'professor', 
            statusAprovacao: 'recusado' 
        });

        res.json({
            pendentes,
            aprovados,
            recusados,
            total: pendentes + aprovados + recusados
        });

    } catch (error) {
        console.error('Erro ao obter estatísticas:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

module.exports = router; 