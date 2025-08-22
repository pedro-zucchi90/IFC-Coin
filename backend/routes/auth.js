const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const { verificarToken } = require('../middleware/auth');
const nodemailer = require('nodemailer');
const crypto = require('crypto'); 

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



// POST /api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ message: 'E-mail é obrigatório.' });
        }
        const user = await User.findOne({ email: email.toLowerCase().trim() });
        if (!user) {
            return res.status(404).json({ message: 'Usuário não encontrado.' });
        }

        // Gere um token seguro para reset
        const token = crypto.randomBytes(32).toString('hex');
        user.resetPasswordToken = token;
        user.resetPasswordExpires = Date.now() + 3600000; // 1 hora
        await user.save();

        // Configuração do Nodemailer
        const transporter = nodemailer.createTransport({
            service: 'gmail', // ou outro serviço, ex: 'hotmail'
            auth: {
                user: process.env.EMAIL, // seu email
                pass: process.env.SENHA_EMAIL // senha do app ou senha normal
            }
        });

        // Monta o link de redefinição
        const frontendURL = process.env.FRONTEND_URL || 'http://localhost:3000';
        const resetLink = `${frontendURL}/auth/reset-password?token=${token}`;

        // Conteúdo do e-mail
        const mailOptions = {
            from: `"IFC Coin" <${process.env.EMAIL}>`,
            to: user.email,
            subject: 'Recuperação de senha - IFC Coin',
            html: `
                <p>Olá, ${user.nome || ''}!</p>
                <p>Você solicitou a redefinição de senha do IFC Coin.</p>
                <p>Clique no link abaixo para definir uma nova senha:</p>
                <p><a href="${resetLink}" style="font-weight:bold;">Redefinir senha</a></p>
                <p>Se você não solicitou isso, ignore este e-mail.</p>
                <small>O link expira em 1 hora.</small>
            `
        };

        // Envia o e-mail
        await transporter.sendMail(mailOptions);

        return res.status(200).json({ message: 'E-mail de recuperação enviado!' });
    } catch (error) {
        console.error('Erro no forgot-password:', error);
        res.status(500).json({
            message: 'Erro interno do servidor'
        });
    }
});

// GET /api/auth/reset-password - Exibe formulário de redefinição de senha via token
router.get('/reset-password', async (req, res) => {
  const { token } = req.query;
  if (!token) {
    return res.status(400).send(`
      <html>
        <body>
          <h2>Token não informado</h2>
          <p>O link de redefinição de senha está inválido ou incompleto.</p>
        </body>
      </html>
    `);
  }
  try {
    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() }
    });
    if (!user) {
      return res.status(400).send(`
        <html>
          <body>
            <h2>Token inválido ou expirado</h2>
            <p>Solicite uma nova redefinição de senha.</p>
          </body>
        </html>
      `);
    }
    // Página estilizada inspirada na logo IFC Coin:
    res.send(`
      <html lang="pt-BR">
        <head>
          <meta charset="UTF-8">
          <title>Redefinir Senha | IFC Coin</title>
          <link href="https://fonts.googleapis.com/css?family=Montserrat:700,400&display=swap" rel="stylesheet">
          <style>
            :root {
              --ifc-blue: #49b6e8;
              --ifc-gray: #e3e7ed;
              --ifc-dark: #51535a;
              --ifc-white: #fff;
            }
            body {
              background: linear-gradient(135deg, var(--ifc-gray) 0%, var(--ifc-blue) 100%);
              font-family: 'Montserrat', Arial, sans-serif;
              margin: 0;
              min-height: 100vh;
              display: flex;
              align-items: center;
              justify-content: center;
            }
            .container {
              background: var(--ifc-white);
              max-width: 390px;
              width: 100%;
              margin: 40px auto;
              padding: 32px 28px 24px 28px;
              border-radius: 14px;
              box-shadow: 0 4px 32px rgba(49,182,232,0.09), 0 1.5px 4px rgba(49,83,90,0.06);
              display: flex;
              flex-direction: column;
              align-items: center;
              position: relative;
            }
            .logo {
              margin-bottom: 30px;
              width: 150px;
              height: 55px;
              display: flex;
              align-items: center;
              justify-content: center;
            }
            .logo-text {
              font-family: 'Montserrat', Arial, sans-serif;
              font-weight: 700;
              font-size: 2.2rem;
              letter-spacing: 2px;
              color: var(--ifc-dark);
            }
            .logo-text .coin {
              color: var(--ifc-blue);
              margin-left: 4px;
            }
            h2 {
              font-weight: 700;
              text-align: center;
              color: var(--ifc-blue);
              margin-bottom: 10px;
              letter-spacing: 1px;
            }
            .error-message {
              color: #d32f2f;
              text-align: center;
              margin-bottom: 10px;
              font-size: 1rem;
              height: 22px;
            }
            form {
              width: 100%;
              display: flex;
              flex-direction: column;
              gap: 12px;
              margin-top: 8px;
            }
            input[type="password"] {
              padding: 12px;
              border: 1.5px solid var(--ifc-blue);
              border-radius: 6px;
              font-size: 1rem;
              font-family: 'Montserrat', Arial, sans-serif;
              background: var(--ifc-gray);
              margin-bottom: 0;
              transition: border-color 0.2s;
            }
            input[type="password"]:focus {
              border-color: var(--ifc-dark);
              outline: none;
            }
            button {
              padding: 13px 0;
              background: var(--ifc-blue);
              color: var(--ifc-white);
              border: none;
              border-radius: 6px;
              font-size: 1.07rem;
              font-family: 'Montserrat', Arial, sans-serif;
              font-weight: bold;
              cursor: pointer;
              margin-top: 10px;
              box-shadow: 0 2px 8px rgba(49,182,232,0.07);
              transition: background 0.2s;
              letter-spacing: 1px;
            }
            button:hover {
              background: #319bd1;
            }
            .back-link {
              text-align: center;
              margin-top: 18px;
              font-size: 0.95rem;
            }
            .back-link a {
              color: var(--ifc-blue);
              text-decoration: none;
              font-weight: 700;
              transition: color 0.2s;
            }
            .back-link a:hover {
              color: var(--ifc-dark);
              text-decoration: underline;
            }
          </style>
          <script>
            function validarFormulario(event) {
              event.preventDefault();
              var senha1 = document.getElementsByName('novaSenha')[0].value;
              var senha2 = document.getElementsByName('confirmarSenha')[0].value;
              var errorDiv = document.getElementById('error-message');
              if (senha1.length < 6) {
                errorDiv.textContent = 'A senha deve ter pelo menos 6 caracteres.';
                return false;
              }
              if (senha1 !== senha2) {
                errorDiv.textContent = 'As senhas não conferem.';
                return false;
              }
              errorDiv.textContent = '';
              event.target.submit();
            }
          </script>
        </head>
        <body>
          <div class="container">
            <h2>Redefinir Senha</h2>
            <div id="error-message" class="error-message"></div>
            <form method="POST" action="/api/auth/reset-password" onsubmit="validarFormulario(event)">
              <input type="hidden" name="token" value="${token}" />
              <input type="password" name="novaSenha" placeholder="Nova senha" required minlength="6" />
              <input type="password" name="confirmarSenha" placeholder="Confirme a nova senha" required minlength="6" />
              <button type="submit">Redefinir senha</button>
            </form>
            <div class="back-link">
              <a href="/">Voltar ao login</a>
            </div>
          </div>
        </body>
      </html>
    `);
  } catch (error) {
    console.error('[reset-password][GET] Erro ao buscar usuário por token:', error);
    res.status(500).send(`
      <html>
        <body>
          <h2>Erro interno do servidor</h2>
          <p>Tente novamente mais tarde.</p>
        </body>
      </html>
    `);
  }
});

// POST /api/auth/reset-password - Redefine a senha do usuário via token
router.post('/reset-password', async (req, res) => {
    const { token, novaSenha, confirmarSenha } = req.body;
    if (!token || !novaSenha || !confirmarSenha) {
        return res.status(400).json({ message: 'Token e ambos os campos de senha são obrigatórios.' });
    }
    if (novaSenha !== confirmarSenha) {
        return res.status(400).json({ message: 'As senhas não conferem.' });
    }
    try {
        const user = await User.findOne({
            resetPasswordToken: token,
            resetPasswordExpires: { $gt: Date.now() }
        });
        if (!user) {
            return res.status(400).json({ message: 'Token inválido ou expirado. Solicite nova redefinição.' });
        }
        user.senha = novaSenha;
        user.resetPasswordToken = undefined;
        user.resetPasswordExpires = undefined;
        await user.save();

        // Tela de sucesso após redefinir a senha
        return res.send(`
          <html lang="pt-BR">
            <head>
              <meta charset="UTF-8">
              <title>Senha redefinida com sucesso | IFC Coin</title>
              <link href="https://fonts.googleapis.com/css?family=Montserrat:700,400&display=swap" rel="stylesheet">
              <style>
                :root {
                  --ifc-blue: #49b6e8;
                  --ifc-gray: #e3e7ed;
                  --ifc-dark: #51535a;
                  --ifc-white: #fff;
                  --ifc-success: #2e7d32;
                }
                body {
                  background: linear-gradient(135deg, var(--ifc-gray) 0%, var(--ifc-blue) 100%);
                  font-family: 'Montserrat', Arial, sans-serif;
                  margin: 0;
                  min-height: 100vh;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                }
                .container {
                  background: var(--ifc-white);
                  max-width: 390px;
                  width: 100%;
                  margin: 40px auto;
                  padding: 32px 28px 24px 28px;
                  border-radius: 14px;
                  box-shadow: 0 4px 32px rgba(49,182,232,0.09), 0 1.5px 4px rgba(49,83,90,0.06);
                  display: flex;
                  flex-direction: column;
                  align-items: center;
                  position: relative;
                }
                .logo {
                  margin-bottom: 30px;
                  width: 150px;
                  height: 55px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                }
                .logo-text {
                  font-family: 'Montserrat', Arial, sans-serif;
                  font-weight: 700;
                  font-size: 2.2rem;
                  letter-spacing: 2px;
                  color: var(--ifc-dark);
                }
                .logo-text .coin {
                  color: var(--ifc-blue);
                  margin-left: 4px;
                }
                h2 {
                  font-weight: 700;
                  text-align: center;
                  color: var(--ifc-success);
                  margin-bottom: 10px;
                  letter-spacing: 1px;
                }
                p {
                  text-align: center;
                  color: var(--ifc-dark);
                  font-size: 1.05rem;
                  margin-bottom: 10px;
                }
                .back-link {
                  text-align: center;
                  margin-top: 18px;
                  font-size: 0.95rem;
                }
                .back-link a {
                  color: var(--ifc-blue);
                  text-decoration: none;
                  font-weight: 700;
                  transition: color 0.2s;
                }
                .back-link a:hover {
                  color: var(--ifc-dark);
                  text-decoration: underline;
                }
              </style>
            </head>
            <body>
              <div class="container">
                <h2>Senha redefinida com sucesso!</h2>
                <p>Sua senha foi alterada. Agora você pode fazer login normalmente.</p>
              </div>
            </body>
          </html>
        `);
    } catch (error) {
        console.error('[reset-password][POST] Erro ao redefinir senha:', error);
        return res.status(500).json({ message: 'Erro interno do servidor.' });
    }
});

module.exports = router; 