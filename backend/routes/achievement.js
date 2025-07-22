const express = require('express');
const Achievement = require('../models/achievementModel');
const { verificarToken, verificarAdmin } = require('../middleware/auth');

const router = express.Router();

// GET /api/achievement/listar - Listar conquistas disponíveis
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

// POST /api/achievement/criar - Criar nova conquista (admin)
router.post('/criar', verificarAdmin, async (req, res) => {
    console.log('Tentativa de criar conquista:', req.user, req.headers.authorization);
    try {
        const { nome, descricao, tipo, categoria, icone, requisitos } = req.body;

        if (!nome || !descricao || !tipo) {
            return res.status(400).json({
                message: 'Nome, descrição e tipo são obrigatórios'
            });
        }

        const novaConquista = new Achievement({
            nome: nome.trim(),
            descricao: descricao.trim(),
            tipo,
            categoria: categoria || null,
            icone: icone || null,
            requisitos: requisitos || null
        });

        await novaConquista.save();

        res.status(201).json({
            message: 'Conquista criada com sucesso',
            conquista: novaConquista
        });

    } catch (error) {
        console.error('Erro ao criar conquista:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// PUT /api/achievement/:id - Atualizar conquista (admin)
router.put('/:id', verificarToken, verificarAdmin, async (req, res) => {
    console.log('Tentativa de editar conquista:', req.user, req.headers.authorization);
    try {
        const { nome, descricao, tipo, categoria, icone, requisitos } = req.body;
        const conquistaId = req.params.id;

        const conquista = await Achievement.findById(conquistaId);
        if (!conquista) {
            return res.status(404).json({
                message: 'Conquista não encontrada'
            });
        }

        // Atualizar campos
        if (nome) conquista.nome = nome.trim();
        if (descricao) conquista.descricao = descricao.trim();
        if (tipo) conquista.tipo = tipo;
        if (categoria !== undefined) conquista.categoria = categoria;
        if (icone !== undefined) conquista.icone = icone;
        if (requisitos !== undefined) conquista.requisitos = requisitos;

        await conquista.save();

        res.json({
            message: 'Conquista atualizada com sucesso',
            conquista
        });

    } catch (error) {
        console.error('Erro ao atualizar conquista:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// DELETE /api/achievement/:id - Deletar conquista (admin)
router.delete('/:id', verificarToken, verificarAdmin, async (req, res) => {
    console.log('Tentativa de deletar conquista:', req.user, req.headers.authorization);
    try {
        const conquista = await Achievement.findById(req.params.id);

        if (!conquista) {
            return res.status(404).json({
                message: 'Conquista não encontrada'
            });
        }

        await Achievement.findByIdAndDelete(req.params.id);

        res.json({
            message: 'Conquista deletada com sucesso'
        });

    } catch (error) {
        console.error('Erro ao deletar conquista:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/achievement/:id - Obter conquista específica
router.get('/:id', verificarToken, async (req, res) => {
    try {
        const conquista = await Achievement.findById(req.params.id);

        if (!conquista) {
            return res.status(404).json({
                message: 'Conquista não encontrada'
            });
        }

        res.json(conquista);

    } catch (error) {
        console.error('Erro ao obter conquista:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/achievement/estatisticas - Estatísticas das conquistas (admin)
router.get('/estatisticas/geral', verificarAdmin, async (req, res) => {
    try {
        const totalConquistas = await Achievement.countDocuments();
        
        const conquistasPorTipo = await Achievement.aggregate([
            {
                $group: {
                    _id: '$tipo',
                    count: { $sum: 1 }
                }
            }
        ]);

        const conquistasPorCategoria = await Achievement.aggregate([
            {
                $match: { categoria: { $exists: true, $ne: null } }
            },
            {
                $group: {
                    _id: '$categoria',
                    count: { $sum: 1 }
                }
            }
        ]);

        res.json({
            totalConquistas,
            conquistasPorTipo,
            conquistasPorCategoria
        });

    } catch (error) {
        console.error('Erro ao buscar estatísticas:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

module.exports = router; 