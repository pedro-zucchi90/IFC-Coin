// Gerenciamento de Metas
class Goals {
    constructor() {
        this.currentPage = 1;
        this.currentType = '';
        this.init();
    }

    init() {
        // Event listeners
        document.getElementById('goalTypeFilter').addEventListener('change', (e) => {
            this.currentType = e.target.value;
            this.currentPage = 1;
            this.loadGoals();
        });

        document.getElementById('createGoalBtn').addEventListener('click', () => {
            this.showCreateGoalModal();
        });

        document.getElementById('cancelCreateGoal').addEventListener('click', () => {
            this.hideCreateGoalModal();
        });

        document.getElementById('createGoalForm').addEventListener('submit', (e) => {
            this.handleCreateGoal(e);
        });

        // Inicializar com valor padrão
        this.currentType = '';
        this.loadGoals();
    }

    async loadGoals() {
        try {
            const params = new URLSearchParams({
                page: this.currentPage,
                limit: CONFIG.ITEMS_PER_PAGE
            });

            // Só adicionar o filtro de tipo se não for vazio
            if (this.currentType && this.currentType.trim() !== '') {
                params.append('tipo', this.currentType);
            }

            console.log('Carregando metas com parâmetros:', params.toString());
            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/goal?${params}`);
            
            if (response.ok) {
                const data = await response.json();
                console.log('Metas recebidas:', data.metas.length, 'Total:', data.paginacao.total);
                this.renderGoals(data.metas);
                this.renderPagination(data.paginacao);
                document.getElementById('goalCount').textContent = data.paginacao.total;
            } else {
                const errorData = await response.json();
                console.error('Erro na API de metas:', errorData);
                Utils.showNotification(`Erro ao carregar metas: ${errorData.message}`, 'error');
            }
        } catch (error) {
            console.error('Erro ao carregar metas:', error);
        }
    }

    renderGoals(goals) {
        const container = document.getElementById('goalsList');
        
        if (goals.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhuma meta encontrada</p>';
            return;
        }

        container.innerHTML = goals.map(goal => `
            <div class="bg-white border border-gray-200 rounded-lg p-6">
                <div class="flex items-start justify-between mb-4">
                    <div class="flex items-start space-x-4">
                        <div class="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center">
                            <i class="fas fa-bullseye text-purple-600 text-xl"></i>
                        </div>
                        <div class="flex-1">
                            <div class="flex items-center justify-between">
                                <h3 class="text-lg font-semibold text-gray-900">${goal.titulo}</h3>
                                <div class="flex items-center space-x-2">
                                    <span class="inline-block px-2 py-1 text-xs rounded-full ${
                                        goal.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                    }">${goal.ativo ? 'Ativa' : 'Inativa'}</span>
                                    <span class="inline-block px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800">
                                        ${goal.tipo}
                                    </span>
                                </div>
                            </div>
                            <p class="text-gray-600 mt-1">${goal.descricao}</p>
                            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4 text-sm">
                                <div>
                                    <p class="text-gray-500">Requisito</p>
                                    <p class="font-semibold">${goal.requisito}</p>
                                </div>
                                <div>
                                    <p class="text-gray-500">Recompensa</p>
                                    <p class="font-semibold">${Utils.formatCurrency(goal.recompensa)}</p>
                                </div>
                                <div>
                                    <p class="text-gray-500">Concluída por</p>
                                    <p class="font-semibold">${goal.usuariosConcluidos?.length || 0} usuários</p>
                                </div>
                                <div>
                                    <p class="text-gray-500">Criada em</p>
                                    <p class="font-semibold">${Utils.formatDate(goal.createdAt)}</p>
                                </div>
                            </div>
                            ${goal.requerAprovacao ? `
                                <div class="mt-2">
                                    <span class="inline-block px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                                        Requer aprovação
                                    </span>
                                </div>
                            ` : ''}
                            ${goal.evidenciaObrigatoria ? `
                                <div class="mt-2">
                                    <span class="inline-block px-2 py-1 text-xs rounded-full bg-orange-100 text-orange-800">
                                        Evidência obrigatória
                                    </span>
                                </div>
                            ` : ''}
                        </div>
                    </div>
                </div>
                
                <div class="flex space-x-2">
                    <button onclick="goals.editGoal('${goal._id}')" 
                            class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition duration-200">
                        <i class="fas fa-edit mr-2"></i>Editar
                    </button>
                    <button onclick="goals.deleteGoal('${goal._id}')" 
                            class="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition duration-200">
                        <i class="fas fa-trash mr-2"></i>Excluir
                    </button>
                </div>
            </div>
        `).join('');
    }

    renderPagination(pagination) {
        const container = document.getElementById('goalsPagination');
        
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
                <button onclick="goals.goToPage(${currentPage - 1})" 
                        class="px-3 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">
                    <i class="fas fa-chevron-left"></i>
                </button>
            `);
        }

        // Páginas numeradas
        for (let i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) {
            pages.push(`
                <button onclick="goals.goToPage(${i})" 
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
                <button onclick="goals.goToPage(${currentPage + 1})" 
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
        this.loadGoals();
    }

    showCreateGoalModal() {
        document.getElementById('createGoalModal').classList.remove('hidden');
    }

    hideCreateGoalModal() {
        document.getElementById('createGoalModal').classList.add('hidden');
        document.getElementById('createGoalForm').reset();
    }

    async handleCreateGoal(e) {
        e.preventDefault();
        
        const formData = new FormData(e.target);
        const goalData = {
            titulo: formData.get('titulo'),
            descricao: formData.get('descricao'),
            tipo: formData.get('tipo'),
            requisito: parseInt(formData.get('requisito')),
            recompensa: parseInt(formData.get('recompensa')),
            requerAprovacao: formData.get('requerAprovacao') === 'on',
            evidenciaObrigatoria: formData.get('evidenciaObrigatoria') === 'on',
            maxConclusoes: formData.get('maxConclusoes') ? parseInt(formData.get('maxConclusoes')) : null,
            dataInicio: formData.get('dataInicio') || new Date().toISOString(),
            dataFim: formData.get('dataFim') || null
        };

        try {
            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/goal`, {
                method: 'POST',
                body: JSON.stringify(goalData)
            });

            if (response.ok) {
                Utils.showNotification('Meta criada com sucesso!', 'success');
                this.hideCreateGoalModal();
                this.loadGoals();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao criar meta');
            }
        } catch (error) {
            console.error('Erro ao criar meta:', error);
            Utils.showNotification(error.message, 'error');
        }
    }

    async editGoal(goalId) {
        // Implementar edição de meta
        Utils.showNotification('Funcionalidade de edição em desenvolvimento', 'info');
    }

    async deleteGoal(goalId) {
        try {
            const confirmed = await Utils.confirmAction('Tem certeza que deseja excluir esta meta?');
            if (!confirmed) return;

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/goal/${goalId}`, {
                method: 'DELETE'
            });

            if (response.ok) {
                Utils.showNotification('Meta excluída com sucesso!', 'success');
                this.loadGoals();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao excluir meta');
            }
        } catch (error) {
            console.error('Erro ao excluir meta:', error);
            Utils.showNotification(error.message, 'error');
        }
    }
}

// Instanciar metas
const goals = new Goals();
