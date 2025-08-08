# IFC Coin - Painel Administrativo Web

Interface web para administradores do sistema IFC Coin, desenvolvida com HTML, Tailwind CSS e JavaScript puro.

## Funcionalidades

### 🔐 Autenticação
- Login seguro apenas para administradores
- Autenticação via matrícula e senha
- Verificação de role de admin
- Sessão persistente com localStorage
- Logout automático em caso de token expirado

### 📊 Dashboard
- Visão geral do sistema
- Estatísticas em tempo real:
  - Total de usuários
  - Solicitações pendentes de professores
  - Transações do dia
  - Metas ativas
- Últimas transações
- Solicitações recentes de professores

### 👨‍🏫 Gerenciamento de Professores
- Listar todas as solicitações de professores
- Filtrar por status (pendente, aprovado, recusado)
- Aprovar/recusar solicitações
- Visualizar detalhes dos professores
- Paginação de resultados

### 💰 Gerenciamento de Transações
- Listar todas as transações do sistema
- Filtrar por tipo (enviado/recebido) e status
- Aprovar/recusar transações pendentes
- Visualizar detalhes completos das transações
- Paginação de resultados

### 🎯 Gerenciamento de Metas
- Listar todas as metas do sistema
- Filtrar por tipo (acadêmico, social, esportivo, cultural)
- Criar novas metas com formulário completo
- Editar e excluir metas existentes
- Visualizar estatísticas de conclusão
- Paginação de resultados

### 🏆 Gerenciamento de Conquistas
- Listar todas as conquistas do sistema
- Filtrar por categoria
- Visualizar detalhes das conquistas
- Paginação de resultados

### 👥 Gerenciamento de Usuários
- Listar todos os usuários do sistema
- Filtrar por role (aluno, professor, admin) e status
- Adicionar/remover coins dos usuários
- Ativar/desativar usuários
- Visualizar estatísticas dos usuários
- Paginação de resultados

## Estrutura de Arquivos

```
admin-web/
├── index.html              # Página principal
├── js/
│   ├── config.js           # Configurações e utilitários
│   ├── auth.js             # Gerenciamento de autenticação
│   ├── dashboard.js        # Dashboard principal
│   ├── professors.js       # Gerenciamento de professores
│   ├── transactions.js     # Gerenciamento de transações
│   ├── goals.js           # Gerenciamento de metas
│   ├── achievements.js    # Gerenciamento de conquistas
│   ├── users.js           # Gerenciamento de usuários
│   └── app.js             # Aplicação principal
└── README.md              # Esta documentação
```

## Como Usar

### 1. Configuração
Certifique-se de que o backend está rodando na porta 3000. Se estiver em uma porta diferente, edite o arquivo `js/config.js`:

```javascript
const API_BASE_URL = 'http://localhost:3000/api';
```

### 2. Acesso
1. Abra o arquivo `index.html` em um navegador web
2. Faça login com matrícula e senha de administrador
3. Navegue pelas diferentes seções usando o menu lateral

### 3. Funcionalidades Principais

#### Login
- Apenas usuários com role "admin" podem acessar
- Sessão é mantida mesmo após fechar o navegador
- Logout automático em caso de token expirado

#### Dashboard
- Carrega estatísticas em tempo real
- Mostra transações e solicitações recentes
- Atualiza automaticamente

#### Professores
- Visualize todas as solicitações de professores
- Use filtros para encontrar solicitações específicas
- Aprove ou recuse solicitações pendentes

#### Transações
- Monitore todas as transações do sistema
- Aprove ou recuse transações pendentes
- Use filtros para encontrar transações específicas

#### Metas
- Crie novas metas com formulário completo
- Visualize todas as metas existentes
- Edite ou exclua metas conforme necessário

#### Conquistas
- Visualize todas as conquistas do sistema
- Use filtros por categoria

#### Usuários
- Gerencie todos os usuários do sistema
- Adicione ou remova coins
- Ative ou desative usuários
- Visualize estatísticas detalhadas

## Tecnologias Utilizadas

- **HTML5**: Estrutura da página
- **Tailwind CSS**: Framework CSS para estilização
- **JavaScript ES6+**: Funcionalidades e interações
- **Font Awesome**: Ícones
- **Fetch API**: Comunicação com o backend

## Recursos de UX/UI

- **Design Responsivo**: Funciona em desktop, tablet e mobile
- **Interface Moderna**: Design limpo e profissional
- **Feedback Visual**: Notificações para todas as ações
- **Loading States**: Indicadores de carregamento
- **Paginação**: Navegação eficiente em grandes listas
- **Filtros**: Busca e filtragem avançada
- **Modais**: Formulários em janelas modais
- **Animações**: Transições suaves

## Segurança

- **Autenticação Obrigatória**: Apenas admins podem acessar
- **Token JWT**: Autenticação segura
- **Verificação de Role**: Dupla verificação de permissões
- **Sanitização de Dados**: Validação de entrada
- **HTTPS Recomendado**: Para produção

## Compatibilidade

- **Navegadores Modernos**: Chrome, Firefox, Safari, Edge
- **Mobile**: Responsivo para dispositivos móveis
- **Desktop**: Interface otimizada para desktop

## Desenvolvimento

Para modificar ou estender a interface:

1. **Adicionar Nova Seção**:
   - Crie um novo arquivo JS na pasta `js/`
   - Adicione a seção no HTML
   - Configure a navegação

2. **Modificar Estilos**:
   - Use classes Tailwind CSS
   - Adicione estilos customizados no `app.js`

3. **Adicionar Funcionalidades**:
   - Use a classe `auth.authenticatedRequest()` para chamadas à API
   - Use `Utils.showNotification()` para feedback

## Troubleshooting

### Problemas Comuns

1. **Erro de CORS**:
   - Verifique se o backend está configurado para aceitar requisições do frontend
   - Configure o CORS no backend se necessário

2. **Erro de Autenticação**:
   - Verifique se o token está sendo enviado corretamente
   - Verifique se o usuário tem role de admin

3. **Dados não carregam**:
   - Verifique se a API está rodando
   - Verifique o console do navegador para erros
   - Verifique se a URL da API está correta

### Logs e Debug

- Abra o console do navegador (F12) para ver logs detalhados
- Todas as requisições à API são logadas
- Erros são exibidos com detalhes completos

## Contribuição

Para contribuir com melhorias:

1. Mantenha o padrão de código existente
2. Use as classes e utilitários já definidos
3. Teste em diferentes navegadores
4. Mantenha a responsividade
5. Documente novas funcionalidades

## Licença

Este projeto faz parte do sistema IFC Coin e segue as mesmas diretrizes de licenciamento.
