const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const User = require('../models/userModel');
const { verificarToken, verificarAdmin, verificarProfessor } = require('../middleware/auth');

const router = express.Router();

// Configuração do multer para upload de arquivos
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/fotos-perfil';
    // Criar diretório se não existir
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // Gerar nome único para o arquivo
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'foto-' + req.user._id + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
  fileFilter: function (req, file, cb) {
    // Verificar se é uma imagem
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Apenas imagens são permitidas'), false);
    }
  }
});

// GET /api/user/perfil - Obter perfil do usuário logado
router.get('/perfil', verificarToken, async (req, res) => {
    try {
        res.json(req.user);
    } catch (error) {
        console.error('Erro ao obter perfil:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// PUT /api/user/perfil - Atualizar dados do perfil
router.put('/perfil', verificarToken, async (req, res) => {
  try {
    const { nome, email, curso } = req.body;
    const userId = req.user._id;

    // Buscar usuário
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        message: 'Usuário não encontrado'
      });
    }

    // Verificar se email já existe (se foi alterado)
    if (email && email !== user.email) {
      const emailExistente = await User.findOne({ 
        email: email.toLowerCase().trim(),
        _id: { $ne: userId }
      });
      
      if (emailExistente) {
        return res.status(400).json({
          message: 'Email já está em uso'
        });
      }
    }

    // Atualizar campos
    if (nome) user.nome = nome.trim();
    if (email) user.email = email.toLowerCase().trim();
    if (curso !== undefined) user.curso = curso;

    await user.save();

    res.json({
      message: 'Perfil atualizado com sucesso',
      user: user.toPublicJSON()
    });

  } catch (error) {
    console.error('Erro ao atualizar perfil:', error);
    res.status(500).json({
      message: 'Erro interno do servidor'
    });
  }
});

// POST /api/user/foto-perfil - Upload de foto de perfil
router.post('/foto-perfil', verificarToken, upload.single('foto'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        message: 'Nenhuma foto foi enviada'
      });
    }

    const userId = req.user._id;
    const user = await User.findById(userId);
    
    if (!user) {
      return res.status(404).json({
        message: 'Usuário não encontrado'
      });
    }

    // Se já existe uma foto, deletar a antiga
    if (user.fotoPerfil && user.fotoPerfil.startsWith('/uploads/')) {
      const oldPhotoPath = path.join(__dirname, '..', user.fotoPerfil);
      if (fs.existsSync(oldPhotoPath)) {
        fs.unlinkSync(oldPhotoPath);
      }
    }

    // Salvar caminho da nova foto
    const fotoPath = '/uploads/fotos-perfil/' + req.file.filename;
    user.fotoPerfil = fotoPath;
    await user.save();

    res.json({
      message: 'Foto de perfil atualizada com sucesso',
      fotoPerfil: fotoPath
    });

  } catch (error) {
    console.error('Erro ao fazer upload da foto:', error);
    res.status(500).json({
      message: 'Erro interno do servidor'
    });
  }
});

// GET /api/user/saldo - Obter saldo do usuário
router.get('/saldo', verificarToken, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('saldo');
    
    if (!user) {
      return res.status(404).json({
        message: 'Usuário não encontrado'
      });
    }

    res.json({
      saldo: user.saldo
    });

  } catch (error) {
    console.error('Erro ao obter saldo:', error);
    res.status(500).json({
      message: 'Erro interno do servidor'
    });
  }
});

// POST /api/user/adicionar-coins - Adicionar coins (apenas admin/professor)
router.post('/adicionar-coins', verificarProfessor, async (req, res) => {
    try {
        const { userId, quantidade, motivo } = req.body;

        if (!userId || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'ID do usuário e quantidade válida são obrigatórios'
            });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        await user.adicionarCoins(quantidade);

        res.json({
            message: 'Coins adicionados com sucesso',
            novoSaldo: user.saldo
        });

    } catch (error) {
        console.error('Erro ao adicionar coins:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// POST /api/user/remover-coins - Remover coins (apenas admin)
router.post('/remover-coins', verificarAdmin, async (req, res) => {
    try {
        const { userId, quantidade, motivo } = req.body;

        if (!userId || !quantidade || quantidade <= 0) {
            return res.status(400).json({
                message: 'ID do usuário e quantidade válida são obrigatórios'
            });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        await user.removerCoins(quantidade);

        res.json({
            message: 'Coins removidos com sucesso',
            novoSaldo: user.saldo
        });

    } catch (error) {
        console.error('Erro ao remover coins:', error);
        if (error.message === 'Saldo insuficiente ou quantidade inválida') {
            return res.status(400).json({
                message: error.message
            });
        }
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/user/listar - Listar usuários (apenas admin)
router.get('/listar', verificarAdmin, async (req, res) => {
    try {
        const { role, curso, ativo, page = 1, limit = 10 } = req.query;

        // Construir filtros
        const filtros = {};
        if (role) filtros.role = role;
        if (curso) filtros.curso = curso;
        if (ativo !== undefined) filtros.ativo = ativo === 'true';

        // Paginação
        const skip = (parseInt(page) - 1) * parseInt(limit);

        const usuarios = await User.find(filtros)
            .select('-senha')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await User.countDocuments(filtros);

        res.json({
            usuarios,
            paginacao: {
                pagina: parseInt(page),
                limite: parseInt(limit),
                total,
                paginas: Math.ceil(total / parseInt(limit))
            }
        });

    } catch (error) {
        console.error('Erro ao listar usuários:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/user/:id - Obter usuário específico (apenas admin)
router.get('/:id', verificarAdmin, async (req, res) => {
    try {
        const user = await User.findById(req.params.id).select('-senha');
        
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        res.json(user);

    } catch (error) {
        console.error('Erro ao obter usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// PUT /api/user/:id - Atualizar usuário (apenas admin)
router.put('/:id', verificarAdmin, async (req, res) => {
    try {
        const { nome, email, role, curso, turmas, ativo } = req.body;
        const userId = req.params.id;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        // Atualizar campos
        if (nome) user.nome = nome.trim();
        if (email) {
            const emailExistente = await User.findOne({ 
                email: email.toLowerCase().trim(),
                _id: { $ne: userId }
            });
            if (emailExistente) {
                return res.status(400).json({
                    message: 'Email já está em uso'
                });
            }
            user.email = email.toLowerCase().trim();
        }
        if (role) user.role = role;
        if (curso !== undefined) user.curso = curso;
        if (turmas && Array.isArray(turmas)) user.turmas = turmas;
        if (ativo !== undefined) user.ativo = ativo;

        await user.save();

        res.json({
            message: 'Usuário atualizado com sucesso',
            user: user.toPublicJSON()
        });

    } catch (error) {
        console.error('Erro ao atualizar usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// DELETE /api/user/:id - Desativar usuário (apenas admin)
router.delete('/:id', verificarAdmin, async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        
        if (!user) {
            return res.status(404).json({
                message: 'Usuário não encontrado'
            });
        }

        // Desativar usuário (soft delete)
        user.ativo = false;
        await user.save();

        res.json({
            message: 'Usuário desativado com sucesso'
        });

    } catch (error) {
        console.error('Erro ao desativar usuário:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// Servir arquivos estáticos (fotos de perfil)
router.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

module.exports = router; 