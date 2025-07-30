const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

// Middleware para verificar token JWT
const verificarToken = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization; //pegar o token do header Authorization
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                message: 'Token de acesso não fornecido'
            });
        }

        const token = authHeader.substring(7); // Remove 'Bearer ' do início

        //verificar e decodificar o token
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (err) {
            if (err.name === 'JsonWebTokenError') {
                return res.status(401).json({
                    message: 'Token inválido'
                });
            }
            if (err.name === 'TokenExpiredError') {
                return res.status(401).json({
                    message: 'Token expirado'
                });
            }
            return res.status(401).json({
                message: 'Token inválido ou expirado'
            });
        }
        
        // Buscar o usuário no banco
        const user = await User.findById(decoded.userId).select('-senha');
        if (!user) {
            return res.status(401).json({
                message: 'Usuário não encontrado'
            });
        }

        if (!user.ativo) {
            return res.status(401).json({
                message: 'Usuário inativo'
            });
        }

        //adicionar o usuário ao request
        req.user = {
            _id: user._id,
            nome: user.nome,
            email: user.email,
            matricula: user.matricula,
            role: user.role,
            saldo: user.saldo,
            curso: user.curso,
            turmas: user.turmas,
            fotoPerfil: user.fotoPerfil,
            statusAprovacao: user.statusAprovacao,
            ativo: user.ativo,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        };
        
        next();
    } catch (error) {
        return res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
};

// Middleware para verificar roles específicas
const verificarRole = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                message: 'Usuário não autenticado'
            });
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                message: 'Acesso negado. Permissão insuficiente.'
            });
        }

        next();
    };
};

// Middleware para verificar se é admin
const verificarAdmin = verificarRole('admin');

// Middleware para verificar se é professor ou admin
const verificarProfessor = verificarRole('professor', 'admin');

// Middleware para verificar se é aluno
const verificarAluno = verificarRole('aluno');

// Middleware opcional para verificar token (não falha se não houver token)
const verificarTokenOpcional = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return next();
        }

        const token = authHeader.substring(7);
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        const user = await User.findById(decoded.userId).select('-senha');
        
        if (user && user.ativo) {
            req.user = user;
        }
        
        next();
    } catch (error) {
        next();
    }
};

module.exports = {
    verificarToken,
    verificarRole,
    verificarAdmin,
    verificarProfessor,
    verificarAluno,
    verificarTokenOpcional
}; 