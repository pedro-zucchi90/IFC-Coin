# Sistema de Aprovação de Professores - IFC Coin

## Como Funciona

### Para Professores:
1. **Cadastro**: Quando um professor se cadastra, ele fica com status "pendente"
2. **Aguarda Aprovação**: Não consegue fazer login até ser aprovado por um admin
3. **Notificação**: Recebe mensagem informando que aguarda aprovação
4. **Após Aprovação**: Pode fazer login normalmente

### Para Administradores:
1. **Acesso**: Menu "Solicitações de Professores" na tela inicial (apenas para admins)
2. **Visualização**: Lista de professores pendentes com estatísticas
3. **Ações**: Pode aprovar ou recusar solicitações
4. **Filtros**: Pode filtrar por status (pendente, aprovado, recusado)

## Endpoints da API

### Backend (Node.js)

#### Listar Solicitações
```
GET /api/admin/solicitacoes-professores
Headers: Authorization: Bearer <token>
Query: page, limit, status
```

#### Aprovar Professor
```
POST /api/admin/aprovar-professor/:id
Headers: Authorization: Bearer <token>
Body: { "motivo": "string" } (opcional)
```

#### Recusar Professor
```
POST /api/admin/recusar-professor/:id
Headers: Authorization: Bearer <token>
Body: { "motivo": "string" } (opcional)
```

#### Estatísticas
```
GET /api/admin/estatisticas-solicitacoes
Headers: Authorization: Bearer <token>
```

## Fluxo de Cadastro

### Antes (Todos autenticados automaticamente):
1. Professor se cadastra
2. Recebe token automaticamente
3. Vai direto para Home

### Agora (Professores aguardam aprovação):
1. Professor se cadastra
2. **NÃO** recebe token
3. Recebe mensagem: "Cadastro realizado! Aguarde aprovação"
4. Volta para tela de login
5. Admin aprova na tela de solicitações
6. Professor pode fazer login

## Status de Aprovação

- **pendente**: Professor cadastrado, aguardando aprovação
- **aprovado**: Professor aprovado, pode fazer login
- **recusado**: Professor recusado, conta desativada

## Migração de Dados

Para atualizar usuários existentes no banco:

```bash
cd backend
node scripts/update_users_status.js
```

Este script:
- Define status "aprovado" para todos os professores existentes
- Define status "aprovado" para todos os alunos existentes  
- Define status "aprovado" para todos os admins existentes

## Telas do App

### Para Admins:
- **Home**: Botão "Solicitações de Professores" (novo)
- **Solicitações**: Lista com estatísticas, filtros e ações

### Para Professores:
- **Cadastro**: Mesma tela, mas comportamento diferente
- **Login**: Bloqueado se status = "pendente" ou "recusado"

## Mensagens de Erro

### Login de Professor Pendente:
"Sua conta está aguardando aprovação de um administrador."

### Login de Professor Recusado:
"Sua solicitação de cadastro foi recusada. Entre em contato com o administrador."

### Cadastro de Professor:
"Cadastro realizado com sucesso! Aguarde a aprovação de um administrador para fazer login."

## Segurança

- Apenas admins podem acessar endpoints de aprovação
- Middleware `verificarAdmin` protege todas as rotas
- Professores pendentes não conseguem gerar tokens
- Status é verificado em cada login

## Testes

1. Cadastre um novo professor
2. Verifique que não consegue fazer login
3. Como admin, acesse "Solicitações de Professores"
4. Aprove o professor
5. Professor agora consegue fazer login 