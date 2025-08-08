// Gerenciamento de autenticação
class Auth {
    constructor() {
        this.token = localStorage.getItem('adminToken');
        this.user = JSON.parse(localStorage.getItem('adminUser') || 'null');
        this.init();
    }

    init() {
        // Verificar se já está logado
        if (this.token && this.user) {
            this.showDashboard();
        } else {
            this.showLogin();
        }

        // Event listeners
        document.getElementById('loginForm').addEventListener('submit', (e) => this.handleLogin(e));
        document.getElementById('logoutBtn').addEventListener('click', () => this.handleLogout());
    }

    async handleLogin(e) {
        e.preventDefault();
        
        const matricula = document.getElementById('matricula').value;
        const password = document.getElementById('password').value;
        const errorDiv = document.getElementById('loginError');

        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/auth/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ matricula, senha: password })
            });

            const data = await response.json();

            if (response.ok) {
                // Verificar se é admin
                if (data.user.role !== 'admin') {
                    throw new Error('Acesso negado. Apenas administradores podem acessar este painel.');
                }

                this.token = data.token;
                this.user = data.user;

                // Salvar no localStorage
                localStorage.setItem('adminToken', this.token);
                localStorage.setItem('adminUser', JSON.stringify(this.user));

                await this.showDashboard();
                Utils.showNotification('Login realizado com sucesso!', 'success');
            } else {
                throw new Error(data.message || 'Erro no login');
            }
        } catch (error) {
            errorDiv.textContent = error.message;
            errorDiv.classList.remove('hidden');
            Utils.showNotification(error.message, 'error');
        }
    }

    handleLogout() {
        this.token = null;
        this.user = null;
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        this.showLogin();
        Utils.showNotification('Logout realizado com sucesso!', 'info');
    }

    showLogin() {
        document.getElementById('loginScreen').classList.remove('hidden');
        document.getElementById('dashboard').classList.add('hidden');
        document.getElementById('loginError').classList.add('hidden');
    }

    async showDashboard() {
        document.getElementById('loginScreen').classList.add('hidden');
        document.getElementById('dashboard').classList.remove('hidden');
        document.getElementById('adminName').textContent = this.user.nome;
        
        // Carregar dados do dashboard após login bem-sucedido
        await this.loadDashboardData();
        
        // Inicializar dashboard após garantir que tudo está carregado
        await this.initializeDashboard();
    }

    async initializeDashboard() {
        // Aguardar um pouco para garantir que todos os componentes estão prontos
        await new Promise(resolve => setTimeout(resolve, 300));
        
        // Verificar se o dashboard existe e inicializar
        if (window.dashboard) {
            console.log('Inicializando dashboard...');
            try {
                window.dashboard.init();
                console.log('Dashboard inicializado com sucesso');
            } catch (error) {
                console.error('Erro ao inicializar dashboard:', error);
            }
        } else {
            console.error('Dashboard não encontrado, tentando novamente...');
            // Tentar novamente após mais tempo
            await new Promise(resolve => setTimeout(resolve, 500));
            if (window.dashboard) {
                console.log('Inicializando dashboard (segunda tentativa)...');
                try {
                    window.dashboard.init();
                    console.log('Dashboard inicializado com sucesso (segunda tentativa)');
                } catch (error) {
                    console.error('Erro ao inicializar dashboard (segunda tentativa):', error);
                }
            } else {
                console.error('Dashboard ainda não encontrado');
            }
        }
    }

    async loadDashboardData() {
        try {
            // Carregar estatísticas
            const statsResponse = await fetch(`${CONFIG.API_BASE_URL}/admin/estatisticas-solicitacoes`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`
                }
            });
            
            if (statsResponse.ok) {
                const stats = await statsResponse.json();
                document.getElementById('pendingRequests').textContent = stats.pendentes;
            } else {
                console.error('Erro ao carregar estatísticas:', statsResponse.status);
            }

            // Carregar outras estatísticas básicas
            await this.loadBasicStats();
            
        } catch (error) {
            console.error('Erro ao carregar dados do dashboard:', error);
        }
    }

    async loadBasicStats() {
        try {
            // Total de usuários
            const usersResponse = await fetch(`${CONFIG.API_BASE_URL}/user/listar?limit=1`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`
                }
            });
            
            if (usersResponse.ok) {
                const usersData = await usersResponse.json();
                document.getElementById('totalUsers').textContent = usersData.paginacao.total;
            } else {
                console.error('Erro ao carregar usuários:', usersResponse.status);
            }

            // Transações hoje
            const today = new Date().toISOString().split('T')[0];
            const transactionsResponse = await fetch(`${CONFIG.API_BASE_URL}/transaction/todas?limit=1`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`
                }
            });
            
            if (transactionsResponse.ok) {
                const transactionsData = await transactionsResponse.json();
                // Contar transações de hoje
                const todayTransactions = transactionsData.transacoes.filter(t => 
                    t.createdAt.startsWith(today)
                ).length;
                document.getElementById('todayTransactions').textContent = todayTransactions;
            } else {
                console.error('Erro ao carregar transações:', transactionsResponse.status);
            }

            // Metas ativas
            const goalsResponse = await fetch(`${CONFIG.API_BASE_URL}/goal?limit=100`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`
                }
            });
            
            if (goalsResponse.ok) {
                const goalsData = await goalsResponse.json();
                const activeGoals = goalsData.metas.filter(g => g.ativo === true).length;
                document.getElementById('activeGoals').textContent = activeGoals;
            } else {
                console.error('Erro ao carregar metas:', goalsResponse.status);
            }

        } catch (error) {
            console.error('Erro ao carregar estatísticas básicas:', error);
        }
    }

    // Método para fazer requisições autenticadas
    async authenticatedRequest(url, options = {}) {
        const defaultOptions = {
            headers: {
                'Authorization': `Bearer ${this.token}`,
                'Content-Type': 'application/json'
            }
        };

        const finalOptions = {
            ...defaultOptions,
            ...options,
            headers: {
                ...defaultOptions.headers,
                ...options.headers
            }
        };

        const response = await fetch(url, finalOptions);
        
        // Só fazer logout se for erro 401 E se o token existir E se estivermos no dashboard
        if (response.status === 401 && this.token && document.getElementById('dashboard').classList.contains('hidden') === false) {
            // Só fazer logout se estivermos no dashboard (não na tela de login)
            console.warn('Erro 401 detectado no dashboard - fazer logout');
            this.handleLogout();
        }

        return response;
    }
}

// Instanciar autenticação
const auth = new Auth();
