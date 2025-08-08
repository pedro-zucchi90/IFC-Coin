// Gerenciamento do Dashboard
class Dashboard {
    constructor() {
        this.setupDebugButton();
        // Não carregar dados automaticamente - será chamado pelo auth após login
    }

    init() {
        this.loadRecentTransactions();
        this.loadRecentProfessorRequests();
        this.loadRecentUsers();
    }

    async loadRecentTransactions() {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/transaction/todas?limit=5`, {
                headers: {
                    'Authorization': `Bearer ${auth.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                this.renderRecentTransactions(data.transacoes);
            } else {
                console.error('Erro ao carregar transações recentes:', response.status);
            }
        } catch (error) {
            console.error('Erro ao carregar transações recentes:', error);
        }
    }

    async loadRecentProfessorRequests() {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/admin/solicitacoes-professores?limit=5`, {
                headers: {
                    'Authorization': `Bearer ${auth.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                this.renderRecentProfessorRequests(data.solicitacoes);
            } else {
                console.error('Erro ao carregar solicitações de professores:', response.status);
            }
        } catch (error) {
            console.error('Erro ao carregar solicitações de professores:', error);
        }
    }

    renderRecentTransactions(transactions) {
        const container = document.getElementById('recentTransactions');
        
        if (transactions.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center">Nenhuma transação recente</p>';
            return;
        }

        container.innerHTML = transactions.map(transaction => `
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                        <i class="fas fa-exchange-alt text-blue-600"></i>
                    </div>
                    <div>
                        <p class="font-medium text-gray-900">
                            ${transaction.origem?.nome || 'Sistema'} → ${transaction.destino?.nome || 'Sistema'}
                        </p>
                        <p class="text-sm text-gray-600">${transaction.descricao}</p>
                        <p class="text-xs text-gray-500">${Utils.formatDate(transaction.createdAt)}</p>
                    </div>
                </div>
                <div class="text-right">
                    <p class="font-semibold text-gray-900">${Utils.formatCurrency(transaction.quantidade)}</p>
                    <span class="inline-block px-2 py-1 text-xs rounded-full ${
                        transaction.status === 'aprovada' ? 'bg-green-100 text-green-800' :
                        transaction.status === 'pendente' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                    }">${transaction.status}</span>
                </div>
            </div>
        `).join('');
    }

    renderRecentProfessorRequests(requests) {
        const container = document.getElementById('recentProfessorRequests');
        
        if (requests.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center">Nenhuma solicitação recente</p>';
            return;
        }

        container.innerHTML = requests.map(request => `
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 bg-yellow-100 rounded-full flex items-center justify-center">
                        <i class="fas fa-chalkboard-teacher text-yellow-600"></i>
                    </div>
                    <div>
                        <p class="font-medium text-gray-900">${request.nome}</p>
                        <p class="text-sm text-gray-600">${request.email}</p>
                        <p class="text-xs text-gray-500">Matrícula: ${request.matricula}</p>
                        <p class="text-xs text-gray-500">${Utils.formatDate(request.createdAt)}</p>
                    </div>
                </div>
                <div class="text-right">
                    <span class="inline-block px-2 py-1 text-xs rounded-full ${
                        request.statusAprovacao === 'pendente' ? 'bg-yellow-100 text-yellow-800' :
                        request.statusAprovacao === 'aprovado' ? 'bg-green-100 text-green-800' :
                        'bg-red-100 text-red-800'
                    }">${request.statusAprovacao}</span>
                </div>
            </div>
        `).join('');
    }

    async loadRecentUsers() {
        try {
            console.log('=== DEBUG loadRecentUsers ===');
            console.log('Auth token exists:', !!auth.token);
            console.log('Auth token:', auth.token ? auth.token.substring(0, 20) + '...' : 'null');
            console.log('Auth user:', auth.user);
            
            // Verificar se o token está disponível
            if (!auth.token) {
                console.error('Token não disponível para carregar usuários');
                const container = document.getElementById('recentUsers');
                container.innerHTML = '<p class="text-red-500 text-center">Token não disponível</p>';
                return;
            }
            
            const url = `${CONFIG.API_BASE_URL}/user/listar?limit=5`;
            console.log('Requesting URL:', url);
            
            const response = await fetch(url, {
                headers: {
                    'Authorization': `Bearer ${auth.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            console.log('Response status:', response.status);
            
            if (response.ok) {
                const data = await response.json();
                console.log('Response data:', data);
                this.renderRecentUsers(data.usuarios);
            } else {
                const errorData = await response.json();
                console.error('Error response:', errorData);
                
                // Mostrar mensagem de erro no container
                const container = document.getElementById('recentUsers');
                container.innerHTML = `<p class="text-red-500 text-center">Erro ao carregar usuários (Status: ${response.status})</p>`;
            }
        } catch (error) {
            console.error('Erro ao carregar usuários recentes:', error);
            
            // Mostrar mensagem de erro no container
            const container = document.getElementById('recentUsers');
            container.innerHTML = `<p class="text-red-500 text-center">Erro ao carregar usuários: ${error.message}</p>`;
        }
    }

    renderRecentUsers(users) {
        const container = document.getElementById('recentUsers');
        
        if (users.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center">Nenhum usuário encontrado</p>';
            return;
        }

        container.innerHTML = users.map(user => {
            const roleColors = {
                'admin': 'bg-red-100 text-red-600',
                'professor': 'bg-blue-100 text-blue-600',
                'aluno': 'bg-green-100 text-green-600'
            };

            const roleIcons = {
                'admin': 'fas fa-user-shield',
                'professor': 'fas fa-chalkboard-teacher',
                'aluno': 'fas fa-user-graduate'
            };

            return `
                <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-full overflow-hidden bg-gray-200 flex items-center justify-center">
                            ${user.fotoPerfil ? 
                                `<img src="${CONFIG.API_BASE_URL}${user.fotoPerfil}" alt="${user.nome}" class="w-full h-full object-cover" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';" onload="this.nextElementSibling.style.display='none';">` :
                                `<i class="fas fa-user text-gray-500"></i>`
                            }
                            <i class="fas fa-user text-gray-500" style="display: none;"></i>
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="font-medium text-gray-900 truncate">${user.nome}</p>
                            <p class="text-sm text-gray-600">Matrícula: ${user.matricula}</p>
                            ${user.curso ? `<p class="text-xs text-gray-500">${user.curso}</p>` : ''}
                            <p class="text-xs text-gray-500">${Utils.formatDate(user.createdAt)}</p>
                        </div>
                    </div>
                    <div class="text-right">
                        <span class="inline-block px-2 py-1 text-xs rounded-full ${roleColors[user.role] || 'bg-gray-100 text-gray-800'}">
                            <i class="${roleIcons[user.role] || 'fas fa-user'} mr-1"></i>
                            ${user.role}
                        </span>
                        <p class="text-xs text-gray-500 mt-1">${Utils.formatCurrency(user.saldo || 0)}</p>
                    </div>
                </div>
            `;
        }).join('');
    }

    setupDebugButton() {
        const debugBtn = document.getElementById('debugUsersBtn');
        if (debugBtn) {
            debugBtn.addEventListener('click', () => {
                console.log('=== DEBUG INFO ===');
                console.log('Auth token:', !!auth.token);
                console.log('Auth user:', auth.user);
                console.log('API URL:', CONFIG.API_BASE_URL);
                
                // Testar a API diretamente
                this.testAPI();
            });
        }
    }

    async testAPI() {
        try {
            console.log('Testando API de usuários...');
            
            const response = await fetch(`${CONFIG.API_BASE_URL}/user/listar?limit=1`, {
                headers: {
                    'Authorization': `Bearer ${auth.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            console.log('Response status:', response.status);
            const data = await response.json();
            console.log('Response data:', data);
            
            if (response.ok) {
                alert(`API funcionando! Total de usuários: ${data.paginacao.total}`);
            } else {
                alert(`Erro na API: ${data.message} (Status: ${response.status})`);
            }
        } catch (error) {
            console.error('Erro no teste:', error);
            alert(`Erro de conexão: ${error.message}`);
        }
    }

    // Atualizar dashboard
    async refresh() {
        console.log('Atualizando dashboard...');
        try {
            await Promise.all([
                this.loadRecentTransactions(),
                this.loadRecentProfessorRequests(),
                this.loadRecentUsers()
            ]);
            console.log('Dashboard atualizado com sucesso');
        } catch (error) {
            console.error('Erro ao atualizar dashboard:', error);
        }
    }
}

// Instanciar dashboard
const dashboard = new Dashboard();
