const express = require('express');
const Achievement = require('../models/achievementModel');
const { verificarToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/achievement - Listar todas as conquistas disponíveis (somente leitura)
router.get('/', verificarToken, async (req, res) => {
    try {
        const { tipo, categoria, page = 1, limit = 10 } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        // Construir filtros
        const filtros = {};
        if (tipo) filtros.tipo = tipo;
        if (categoria) filtros.categoria = categoria;

        const conquistas = await Achievement.find(filtros)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Achievement.countDocuments(filtros);

        res.json({
            conquistas,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar conquistas:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/achievement/listar - Listar conquistas disponíveis (mantido para compatibilidade)
router.get('/listar', verificarToken, async (req, res) => {
    try {
        const { tipo, categoria, page = 1, limit = 10 } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        // Construir filtros
        const filtros = {};
        if (tipo) filtros.tipo = tipo;
        if (categoria) filtros.categoria = categoria;

        const conquistas = await Achievement.find(filtros)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Achievement.countDocuments(filtros);

        res.json({
            conquistas,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar conquistas:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/achievement/categorias - Listar categorias disponíveis
router.get('/categorias', verificarToken, async (req, res) => {
    try {
        const categorias = await Achievement.distinct('categoria');
        res.json(categorias.filter(cat => cat)); // Remove valores null/undefined

    } catch (error) {
        console.error('Erro ao buscar categorias:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/achievement/:id - Obter conquista específica
router.get('/:id', verificarToken, async (req, res) => {
    try {
        const achievement = await Achievement.findById(req.params.id);
        
        if (!achievement) {
            return res.status(404).json({ message: 'Conquista não encontrada' });
        }
        
        res.json(achievement);
    } catch (error) {
        console.error('Erro ao buscar conquista:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});

// GET /api/achievement/usuario/conquistas - Obter conquistas do usuário logado
router.get('/usuario/conquistas', verificarToken, async (req, res) => {
    try {
        const User = require('../models/userModel');
        const user = await User.findById(req.user._id).populate('conquistas.achievement');
        
        if (!user) {
            return res.status(404).json({ message: 'Usuário não encontrado' });
        }

        res.json({
            conquistas: user.conquistas,
            estatisticas: user.estatisticas
        });
    } catch (error) {
        console.error('Erro ao buscar conquistas do usuário:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});

// POST /api/achievement/usuario/verificar - Verificar e adicionar conquistas automaticamente
router.post('/usuario/verificar', verificarToken, async (req, res) => {
    try {
        const User = require('../models/userModel');
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({ message: 'Usuário não encontrado' });
        }

        // Verificar conquistas automaticamente
        const conquistasAdicionadas = await user.verificarConquistas();
        
        // Buscar usuário atualizado com conquistas populadas
        const userAtualizado = await User.findById(req.user._id).populate('conquistas.achievement');

        res.json({
            message: `${conquistasAdicionadas.length} conquista(s) adicionada(s)`,
            conquistasAdicionadas,
            conquistas: userAtualizado.conquistas,
            estatisticas: userAtualizado.estatisticas
        });
    } catch (error) {
        console.error('Erro ao verificar conquistas:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});

module.exports = router; 