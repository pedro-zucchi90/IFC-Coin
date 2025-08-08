// Gerenciamento de Usuários
class Users {
    constructor() {
        this.currentPage = 1;
        this.currentRole = '';
        this.currentStatus = '';
        this.init();
    }

    init() {
        // Event listeners
        document.getElementById('userRoleFilter').addEventListener('change', (e) => {
            this.currentRole = e.target.value;
            this.currentPage = 1;
            this.loadUsers();
        });

        document.getElementById('userStatusFilter').addEventListener('change', (e) => {
            this.currentStatus = e.target.value;
            this.currentPage = 1;
            this.loadUsers();
        });

        this.loadUsers();
    }

    async loadUsers() {
        try {
            const params = new URLSearchParams({
                page: this.currentPage,
                limit: CONFIG.ITEMS_PER_PAGE
            });

            if (this.currentRole) {
                params.append('role', this.currentRole);
            }

            if (this.currentStatus) {
                params.append('ativo', this.currentStatus);
            }

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/user/listar?${params}`);
            
            if (response.ok) {
                const data = await response.json();
                this.renderUsers(data.usuarios);
                this.renderPagination(data.paginacao);
                document.getElementById('userCount').textContent = data.paginacao.total;
            }
        } catch (error) {
            console.error('Erro ao carregar usuários:', error);
        }
    }

    renderUsers(users) {
        const container = document.getElementById('usersList');
        
        if (users.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhum usuário encontrado</p>';
            return;
        }

        container.innerHTML = users.map(user => `
            <div class="bg-white border border-gray-200 rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center space-x-4">
                        <div class="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
                            ${user.fotoPerfil ? `
                                <img src="${CONFIG.API_BASE_URL}${user.fotoPerfil}" alt="Foto de perfil" 
                                     class="w-12 h-12 rounded-full object-cover">
                            ` : `
                                <i class="fas fa-user text-gray-600 text-xl"></i>
                            `}
                        </div>
                        <div>
                            <h3 class="text-lg font-semibold text-gray-900">${user.nome}</h3>
                            <p class="text-gray-600">${user.email}</p>
                            <p class="text-sm text-gray-500">Matrícula: ${user.matricula}</p>
                            ${user.curso ? `<p class="text-sm text-gray-500">Curso: ${user.curso}</p>` : ''}
                        </div>
                    </div>
                    <div class="text-right">
                        <div class="flex items-center space-x-2 mb-2">
                            <span class="inline-block px-2 py-1 text-xs rounded-full ${
                                user.role === 'admin' ? 'bg-red-100 text-red-800' :
                                user.role === 'professor' ? 'bg-blue-100 text-blue-800' :
                                'bg-green-100 text-green-800'
                            }">${user.role}</span>
                            <span class="inline-block px-2 py-1 text-xs rounded-full ${
                                user.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                            }">${user.ativo ? 'Ativo' : 'Inativo'}</span>
                        </div>
                        <p class="text-lg font-bold text-gray-900">${Utils.formatCurrency(user.saldo)}</p>
                        <p class="text-xs text-gray-500">Saldo atual</p>
                    </div>
                </div>
                
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm mb-4">
                    <div>
                        <p class="text-gray-500">Conquistas</p>
                        <p class="font-semibold">${user.conquistas?.length || 0}</p>
                    </div>
                    <div>
                        <p class="text-gray-500">Metas concluídas</p>
                        <p class="font-semibold">${user.estatisticas?.metas_concluidas || 0}</p>
                    </div>
                    <div>
                        <p class="text-gray-500">Transferências</p>
                        <p class="font-semibold">${user.estatisticas?.transferencias_realizadas || 0}</p>
                    </div>
                    <div>
                        <p class="text-gray-500">Cadastrado em</p>
                        <p class="font-semibold">${Utils.formatDate(user.createdAt)}</p>
                    </div>
                </div>
                
                <div class="flex space-x-2">
                    <button onclick="users.editUser('${user._id}')" 
                            class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition duration-200">
                        <i class="fas fa-edit mr-2"></i>Editar
                    </button>
                    <button onclick="users.addCoins('${user._id}')" 
                            class="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition duration-200">
                        <i class="fas fa-plus mr-2"></i>Adicionar Coins
                    </button>
                    <button onclick="users.removeCoins('${user._id}')" 
                            class="bg-yellow-600 text-white px-4 py-2 rounded-md hover:bg-yellow-700 transition duration-200">
                        <i class="fas fa-minus mr-2"></i>Remover Coins
                    </button>
                    ${user.ativo ? `
                        <button onclick="users.deactivateUser('${user._id}')" 
                                class="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition duration-200">
                            <i class="fas fa-ban mr-2"></i>Desativar
                        </button>
                    ` : `
                        <button onclick="users.activateUser('${user._id}')" 
                                class="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition duration-200">
                            <i class="fas fa-check mr-2"></i>Ativar
                        </button>
                    `}
                </div>
            </div>
        `).join('');
    }

    renderPagination(pagination) {
        const container = document.getElementById('usersPagination');
        
        if (pagination.paginas <= 1) {
            container.innerHTML = '';
            return;
        }

        const pages = [];
        const currentPage = pagination.pagina;
        const totalPages = pagination.paginas;

        // Página anterior
        if (currentPage > 1) {
            pages.push(`
                <button onclick="users.goToPage(${currentPage - 1})" 
                        class="px-3 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">
                    <i class="fas fa-chevron-left"></i>
                </button>
            `);
        }

        // Páginas numeradas
        for (let i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) {
            pages.push(`
                <button onclick="users.goToPage(${i})" 
                        class="px-3 py-2 border border-gray-300 rounded-md ${
                            i === currentPage ? 'bg-blue-600 text-white' : 'text-gray-700 hover:bg-gray-50'
                        }">
                    ${i}
                </button>
            `);
        }

        // Próxima página
        if (currentPage < totalPages) {
            pages.push(`
                <button onclick="users.goToPage(${currentPage + 1})" 
                        class="px-3 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">
                    <i class="fas fa-chevron-right"></i>
                </button>
            `);
        }

        container.innerHTML = `
            <div class="flex space-x-1">
                ${pages.join('')}
            </div>
        `;
    }

    goToPage(page) {
        this.currentPage = page;
        this.loadUsers();
    }

    async editUser(userId) {
        // Implementar edição de usuário
        Utils.showNotification('Funcionalidade de edição em desenvolvimento', 'info');
    }

    async addCoins(userId) {
        const quantidade = prompt('Quantidade de coins a adicionar:');
        if (!quantidade || isNaN(quantidade) || quantidade <= 0) {
            Utils.showNotification('Quantidade inválida', 'error');
            return;
        }

        try {
            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/user/adicionar-coins`, {
                method: 'POST',
                body: JSON.stringify({
                    userId,
                    quantidade: parseInt(quantidade),
                    motivo: 'Adicionado pelo administrador'
                })
            });

            if (response.ok) {
                Utils.showNotification('Coins adicionados com sucesso!', 'success');
                this.loadUsers();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao adicionar coins');
            }
        } catch (error) {
            console.error('Erro ao adicionar coins:', error);
            Utils.showNotification(error.message, 'error');
        }
    }

    async removeCoins(userId) {
        const quantidade = prompt('Quantidade de coins a remover:');
        if (!quantidade || isNaN(quantidade) || quantidade <= 0) {
            Utils.showNotification('Quantidade inválida', 'error');
            return;
        }

        try {
            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/user/remover-coins`, {
                method: 'POST',
                body: JSON.stringify({
                    userId,
                    quantidade: parseInt(quantidade),
                    motivo: 'Removido pelo administrador'
                })
            });

            if (response.ok) {
                Utils.showNotification('Coins removidos com sucesso!', 'success');
                this.loadUsers();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao remover coins');
            }
        } catch (error) {
            console.error('Erro ao remover coins:', error);
            Utils.showNotification(error.message, 'error');
        }
    }

    async deactivateUser(userId) {
        try {
            const confirmed = await Utils.confirmAction('Tem certeza que deseja desativar este usuário?');
            if (!confirmed) return;

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/user/${userId}`, {
                method: 'DELETE'
            });

            if (response.ok) {
                Utils.showNotification('Usuário desativado com sucesso!', 'success');
                this.loadUsers();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao desativar usuário');
            }
        } catch (error) {
            console.error('Erro ao desativar usuário:', error);
            Utils.showNotification(error.message, 'error');
        }
    }

    async activateUser(userId) {
        try {
            const confirmed = await Utils.confirmAction('Tem certeza que deseja ativar este usuário?');
            if (!confirmed) return;

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/user/${userId}`, {
                method: 'PUT',
                body: JSON.stringify({ ativo: true })
            });

            if (response.ok) {
                Utils.showNotification('Usuário ativado com sucesso!', 'success');
                this.loadUsers();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao ativar usuário');
            }
        } catch (error) {
            console.error('Erro ao ativar usuário:', error);
            Utils.showNotification(error.message, 'error');
        }
    }
}

// Instanciar usuários
const users = new Users();
