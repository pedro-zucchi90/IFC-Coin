const express = require('express');
const User = require('../models/userModel');
const { verificarToken, verificarAdmin } = require('../middleware/auth');

const router = express.Router();

// GET /api/admin/solicitacoes-professores - Listar solicitações de professores
router.get('/solicitacoes-professores', verificarToken, verificarAdmin, async (req, res) => {
  try {
    const { page = 1, limit = 10, status } = req.query;
    const skip = (page - 1) * limit;

    let query = { role: 'professor' };
    if (status && status !== 'todas') {
      query.statusAprovacao = status;
    }

    const solicitacoes = await User.find(query)
      .select('nome email matricula statusAprovacao createdAt')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await User.countDocuments(query);
    const paginas = Math.ceil(total / limit);

    res.json({
      solicitacoes,
      paginacao: {
        pagina: parseInt(page),
        paginas,
        total,
        limite: parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Erro ao listar solicitações de professores:', error);
    res.status(500).json({ message: 'Erro interno do servidor' });
  }
});

// GET /api/admin/estatisticas-solicitacoes - Obter estatísticas das solicitações
router.get('/estatisticas-solicitacoes', verificarToken, verificarAdmin, async (req, res) => {
  try {

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
    
    const total = await User.countDocuments({ role: 'professor' });

    res.json({
      pendentes,
      aprovados,
      recusados,
      total
    });
  } catch (error) {
    console.error('Erro ao obter estatísticas de solicitações:', error);
    res.status(500).json({ message: 'Erro interno do servidor' });
  }
});

// POST /api/admin/aprovar-professor/:id - Aprovar solicitação de professor
router.post('/aprovar-professor/:id', verificarToken, verificarAdmin, async (req, res) => {
    try {


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
router.post('/recusar-professor/:id', verificarToken, verificarAdmin, async (req, res) => {
    try {

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

module.exports = router; 