# Painel Administrativo Integrado

O painel administrativo do IFC Coin agora está integrado diretamente ao backend. Quando você iniciar o servidor, o painel estará disponível através de URLs específicas.

## Como Acessar

### 1. Iniciar o Servidor
```bash
cd backend
npm start
# ou
node server.js
```

### 2. URLs de Acesso

Após iniciar o servidor, você verá no console:
```
Servidor rodando na porta 3000
API disponível em: http://100.101.37.62:3000/api
Painel Administrativo disponível em: http://100.101.37.62:3000/admin
URL raiz redireciona para: http://100.101.37.62:3000/
```

### 3. Acessos Disponíveis

- **URL Raiz**: `http://100.101.37.62:3000/` - Redireciona automaticamente para o painel admin
- **Painel Admin**: `http://100.101.37.62:3000/admin` - Acesso direto ao painel
- **API**: `http://100.101.37.62:3000/api` - Endpoints da API

## Funcionalidades do Painel

### Login Administrativo
- Apenas usuários com role "admin" podem fazer login
- Autenticação via matrícula e senha
- Autenticação via JWT
- Sessão persistente no navegador

### Dashboard
- Estatísticas gerais do sistema
- Transações recentes
- Solicitações de professores pendentes
- Visão geral rápida

### Gerenciamento de Professores
- Listar todas as solicitações de professores
- Aprovar/recusar solicitações
- Filtrar por status (pendente, aprovado, recusado)
- Paginação de resultados

### Gerenciamento de Transações
- Visualizar todas as transações
- Aprovar/recusar transações pendentes
- Filtrar por tipo e status
- Histórico completo

### Gerenciamento de Metas
- Criar novas metas
- Editar metas existentes
- Aprovar/recusar conclusões de metas
- Configurar parâmetros (evidência obrigatória, aprovação necessária)

### Gerenciamento de Conquistas
- Visualizar todas as conquistas
- Filtrar por categoria
- Estatísticas de conquistas

### Gerenciamento de Usuários
- Listar todos os usuários
- Adicionar/remover moedas
- Ativar/desativar usuários
- Editar informações de usuários

## Estrutura de Arquivos

```
backend/
├── server.js                    # Servidor principal (agora serve o painel)
├── routes/                      # Rotas da API
├── models/                      # Modelos do banco de dados
└── README_ADMIN_PANEL.md       # Este arquivo

admin-web/
├── index.html                   # Página principal do painel
├── js/
│   ├── config.js               # Configurações
│   ├── auth.js                 # Autenticação
│   ├── dashboard.js            # Dashboard
│   ├── professors.js           # Gerenciamento de professores
│   ├── transactions.js         # Gerenciamento de transações
│   ├── goals.js                # Gerenciamento de metas
│   ├── achievements.js         # Gerenciamento de conquistas
│   ├── users.js                # Gerenciamento de usuários
│   └── app.js                  # Aplicação principal
└── README.md                   # Documentação completa
```

## Segurança

- Apenas administradores podem acessar o painel
- Autenticação JWT obrigatória
- Todas as requisições são autenticadas
- CORS configurado para desenvolvimento

## Troubleshooting

### Se o painel não carregar:
1. Verifique se o servidor está rodando
2. Confirme se a porta 3000 está disponível
3. Verifique se todos os arquivos do `admin-web` estão presentes
4. Abra o console do navegador para verificar erros

### Se o login não funcionar:
1. Confirme se o usuário tem role "admin"
2. Verifique se o token JWT está sendo gerado corretamente
3. Confirme se a API está respondendo em `/api/auth/login`

### Se as requisições falharem:
1. Verifique se a URL da API está correta em `admin-web/js/config.js`
2. Confirme se o CORS está configurado corretamente
3. Verifique se o token está sendo enviado nas requisições

## Desenvolvimento

Para modificar o painel:
1. Edite os arquivos em `admin-web/`
2. O servidor serve automaticamente os arquivos estáticos
3. Recarregue a página para ver as mudanças

Para adicionar novas funcionalidades:
1. Crie novos módulos JavaScript em `admin-web/js/`
2. Adicione as rotas necessárias em `backend/routes/`
3. Atualize o HTML e a navegação conforme necessário
