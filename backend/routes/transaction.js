const express = require('express');
const Transaction = require('../models/transactionModel');
const User = require('../models/userModel');
const { verificarToken, verificarAdmin, verificarProfessor } = require('../middleware/auth');

const router = express.Router();

// GET /api/transaction/historico - Histórico de transações do usuário
router.get('/historico', verificarToken, async (req, res) => {
    try {
        const { page = 1, limit = 10 } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        const transacoes = await Transaction.find({
            $or: [
                { origem: req.user._id },
                { destino: req.user._id }
            ]
        })
        .populate('origem', 'nome matricula')
        .populate('destino', 'nome matricula')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));

        const total = await Transaction.countDocuments({
            $or: [
                { origem: req.user._id },
                { destino: req.user._id }
            ]
        });

        res.json({
            transacoes,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao buscar histórico:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/transaction/transferir - Transferir coins entre usuários
router.post('/transferir', verificarToken, async (req, res) => {
    try {
        const { destinoMatricula, quantidade, descricao } = req.body;

        if (!destinoMatricula || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'Matrícula de destino e quantidade válida são obrigatórias'
            });
        }

        // Buscar usuário de destino
        const usuarioDestino = await User.findOne({ matricula: destinoMatricula });
        if (!usuarioDestino) {
            return res.status(404).json({
                message: 'Usuário de destino não encontrado'
            });
        }

        if (usuarioDestino._id.toString() === req.user._id.toString()) {
            return res.status(400).json({
                message: 'Não é possível transferir para si mesmo'
            });
        }

        // Admin/professor têm saldo ilimitado
        const isAdminOrProfessor = req.user.role === 'admin' || req.user.role === 'professor';
        if (!isAdminOrProfessor && req.user.saldo < quantidade) {
            return res.status(400).json({
                message: 'Saldo insuficiente para transferência'
            });
        }

        // Se professor transferindo para aluno, criar transação pendente
        let status = 'aprovada';
        const roleOrigem = req.user.role;
        const roleDestino = usuarioDestino.role;
        
        // Verificar se é professor transferindo para aluno
        if (roleOrigem === 'professor' && roleDestino === 'aluno') {
            status = 'pendente';
        }

        // Criar hash seguro
        const crypto = require('crypto');
        const hash = crypto.createHash('sha256')
            .update(`${Date.now()}_${req.user._id}_${usuarioDestino._id}_${Math.random()}`)
            .digest('hex');

        // Criar transação
        const transacao = new Transaction({
            tipo: 'enviado',
            origem: req.user._id,
            destino: usuarioDestino._id,
            quantidade,
            descricao: descricao || 'Transferência entre usuários',
            hash,
            status
        });

        await transacao.save();

        // Buscar instâncias reais do Mongoose
        const origem = await User.findById(req.user._id);
        const destino = await User.findById(usuarioDestino._id);

        if (status === 'aprovada') {
            // Atualizar saldos imediatamente
            await origem.removerCoins(quantidade);
            await destino.adicionarCoins(quantidade);
            
            // Atualizar estatísticas para conquistas
            await origem.atualizarEstatisticas('transferencia');
            await destino.atualizarEstatisticas('transferencia_recebida');
            await destino.atualizarEstatisticas('coins_ganhos', quantidade);
            
            // Verificar conquistas automaticamente
            await origem.verificarConquistas();
            await destino.verificarConquistas();
        }
        // Buscar transação com dados populados
        const transacaoCompleta = await Transaction.findById(transacao._id)
            .populate('origem', 'nome matricula role')
            .populate('destino', 'nome matricula role');

        res.status(201).json({
            message: status === 'pendente' ? 'Transferência pendente de aprovação do admin' : 'Transferência realizada com sucesso',
            transacao: transacaoCompleta
        });

    } catch (error) {
        console.error('Erro na transferência:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/transaction/recompensa - Dar recompensa (professor/admin)
router.post('/recompensa', verificarProfessor, async (req, res) => {
    try {
        const { destinoMatricula, quantidade, descricao } = req.body;

        if (!destinoMatricula || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'Matrícula de destino e quantidade válida são obrigatórias'
            });
        }

        // Buscar usuário de destino
        const usuarioDestino = await User.findOne({ matricula: destinoMatricula });
        if (!usuarioDestino) {
            return res.status(404).json({
                message: 'Usuário de destino não encontrado'
            });
        }

        // Criar transação
        const transacao = new Transaction({
            tipo: 'recebido',
            origem: req.user._id,
            destino: usuarioDestino._id,
            quantidade,
            descricao: descricao || 'Recompensa concedida',
            hash: `reward_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
        });

        await transacao.save();

        // Adicionar coins ao usuário de destino
        await usuarioDestino.adicionarCoins(quantidade);
        
        // Atualizar estatísticas para conquistas
        await usuarioDestino.atualizarEstatisticas('transferencia_recebida');
        await usuarioDestino.atualizarEstatisticas('coins_ganhos', quantidade);
        
        // Verificar conquistas automaticamente
        await usuarioDestino.verificarConquistas();

        // Buscar transação com dados populados
        const transacaoCompleta = await Transaction.findById(transacao._id)
            .populate('origem', 'nome matricula')
            .populate('destino', 'nome matricula');

        res.status(201).json({
            message: 'Recompensa concedida com sucesso',
            transacao: transacaoCompleta
        });

    } catch (error) {
        console.error('Erro ao conceder recompensa:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/transaction/todas - Listar todas as transações (admin)
router.get('/todas', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const { page = 1, limit = 20, tipo, origem, destino } = req.query;
        const skip = (parseInt(page) - 1) * parseInt(limit);

        // Construir filtros
        const filtros = {};
        if (tipo) filtros.tipo = tipo;
        if (origem) filtros.origem = origem;
        if (destino) filtros.destino = destino;

        const transacoes = await Transaction.find(filtros)
            .populate('origem', 'nome matricula')
            .populate('destino', 'nome matricula')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Transaction.countDocuments(filtros);

        res.json({
            transacoes,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar transações:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/transaction/:id/aprovar - Aprovar transferência pendente (admin)
router.post('/:id/aprovar', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const transacao = await Transaction.findById(req.params.id);
        if (!transacao) {
            return res.status(404).json({ message: 'Transação não encontrada' });
        }
        if (transacao.status !== 'pendente') {
            return res.status(400).json({ message: 'Transação já foi processada' });
        }
        // Atualizar status
        transacao.status = 'aprovada';
        await transacao.save();
        // Transferir saldo
        const User = require('../models/userModel');
        const origem = await User.findById(transacao.origem);
        const destino = await User.findById(transacao.destino);
        await origem.removerCoins(transacao.quantidade);
        await destino.adicionarCoins(transacao.quantidade);
        
        // Atualizar estatísticas para conquistas
        await origem.atualizarEstatisticas('transferencia');
        await destino.atualizarEstatisticas('transferencia_recebida');
        await destino.atualizarEstatisticas('coins_ganhos', transacao.quantidade);
        
        // Verificar conquistas automaticamente
        await origem.verificarConquistas();
        await destino.verificarConquistas();
        
        res.json({ message: 'Transferência aprovada e saldo transferido!' });
    } catch (error) {
        console.error('Erro ao aprovar transferência:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});

// POST /api/transaction/:id/recusar - Recusar transferência pendente (admin)
router.post('/:id/recusar', verificarToken, verificarAdmin, async (req, res) => {
    try {
        const transacao = await Transaction.findById(req.params.id);
        if (!transacao) {
            return res.status(404).json({ message: 'Transação não encontrada' });
        }
        if (transacao.status !== 'pendente') {
            return res.status(400).json({ message: 'Transação já foi processada' });
        }
        transacao.status = 'recusada';
        await transacao.save();
        res.json({ message: 'Transferência recusada.' });
    } catch (error) {
        console.error('Erro ao recusar transferência:', error);
        res.status(500).json({ message: 'Erro interno do servidor' });
    }
});

// GET /api/transaction/:id - Obter transação específica
router.get('/:id', verificarToken, async (req, res) => {
    try {
        const transacao = await Transaction.findById(req.params.id)
            .populate('origem', 'nome matricula')
            .populate('destino', 'nome matricula');

        if (!transacao) {
            return res.status(404).json({
                message: 'Transação não encontrada'
            });
        }

        // Verificar se o usuário tem acesso à transação
        if (!req.user.isAdmin && 
            transacao.origem._id.toString() !== req.user._id.toString() &&
            transacao.destino._id.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                message: 'Acesso negado'
            });
        }

        res.json(transacao);

    } catch (error) {
        console.error('Erro ao obter transação:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

module.exports = router; 