// Gerenciamento de Professores
class Professors {
    constructor() {
        this.currentPage = 1;
        this.currentStatus = '';
        this.init();
    }

    init() {
        // Event listeners
        document.getElementById('professorStatusFilter').addEventListener('change', (e) => {
            this.currentStatus = e.target.value;
            this.currentPage = 1;
            this.loadProfessors();
        });

        this.loadProfessors();
    }

    async loadProfessors() {
        try {
            const params = new URLSearchParams({
                page: this.currentPage,
                limit: CONFIG.ITEMS_PER_PAGE
            });

            if (this.currentStatus) {
                params.append('status', this.currentStatus);
            }

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/admin/solicitacoes-professores?${params}`);
            
            if (response.ok) {
                const data = await response.json();
                this.renderProfessors(data.solicitacoes);
                this.renderPagination(data.paginacao);
                document.getElementById('professorCount').textContent = data.paginacao.total;
            }
        } catch (error) {
            console.error('Erro ao carregar professores:', error);
            Utils.showNotification('Erro ao carregar solicitações de professores', 'error');
        }
    }

    renderProfessors(professors) {
        const container = document.getElementById('professorsList');
        
        if (professors.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhuma solicitação encontrada</p>';
            return;
        }

        container.innerHTML = professors.map(professor => `
            <div class="bg-white border border-gray-200 rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center space-x-4">
                        <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                            <i class="fas fa-chalkboard-teacher text-blue-600 text-xl"></i>
                        </div>
                        <div>
                            <h3 class="text-lg font-semibold text-gray-900">${professor.nome}</h3>
                            <p class="text-gray-600">${professor.email}</p>
                            <p class="text-sm text-gray-500">Matrícula: ${professor.matricula}</p>
                        </div>
                    </div>
                    <div class="text-right">
                        <span class="inline-block px-3 py-1 text-sm rounded-full ${
                            professor.statusAprovacao === 'pendente' ? 'bg-yellow-100 text-yellow-800' :
                            professor.statusAprovacao === 'aprovado' ? 'bg-green-100 text-green-800' :
                            'bg-red-100 text-red-800'
                        }">${professor.statusAprovacao}</span>
                        <p class="text-xs text-gray-500 mt-1">${Utils.formatDate(professor.createdAt)}</p>
                    </div>
                </div>
                
                ${professor.statusAprovacao === 'pendente' ? `
                    <div class="flex space-x-2">
                        <button onclick="professors.approveProfessor('${professor._id}')" 
                                class="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition duration-200">
                            <i class="fas fa-check mr-2"></i>Aprovar
                        </button>
                        <button onclick="professors.rejectProfessor('${professor._id}')" 
                                class="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition duration-200">
                            <i class="fas fa-times mr-2"></i>Recusar
                        </button>
                    </div>
                ` : ''}
            </div>
        `).join('');
    }

    renderPagination(pagination) {
        const container = document.getElementById('professorsPagination');
        
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
                <button onclick="professors.goToPage(${currentPage - 1})" 
                        class="px-3 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">
                    <i class="fas fa-chevron-left"></i>
                </button>
            `);
        }

        // Páginas numeradas
        for (let i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) {
            pages.push(`
                <button onclick="professors.goToPage(${i})" 
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
                <button onclick="professors.goToPage(${currentPage + 1})" 
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
        this.loadProfessors();
    }

    async approveProfessor(professorId) {
        try {
            const confirmed = await Utils.confirmAction('Tem certeza que deseja aprovar este professor?');
            if (!confirmed) return;

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/admin/aprovar-professor/${professorId}`, {
                method: 'POST',
                body: JSON.stringify({ motivo: 'Aprovado pelo administrador' })
            });

            if (response.ok) {
                Utils.showNotification('Professor aprovado com sucesso!', 'success');
                this.loadProfessors();
                dashboard.refresh();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao aprovar professor');
            }
        } catch (error) {
            console.error('Erro ao aprovar professor:', error);
            Utils.showNotification(error.message, 'error');
        }
    }

    async rejectProfessor(professorId) {
        try {
            const confirmed = await Utils.confirmAction('Tem certeza que deseja recusar este professor?');
            if (!confirmed) return;

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/admin/recusar-professor/${professorId}`, {
                method: 'POST',
                body: JSON.stringify({ motivo: 'Recusado pelo administrador' })
            });

            if (response.ok) {
                Utils.showNotification('Professor recusado com sucesso!', 'success');
                this.loadProfessors();
                dashboard.refresh();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao recusar professor');
            }
        } catch (error) {
            console.error('Erro ao recusar professor:', error);
            Utils.showNotification(error.message, 'error');
        }
    }
}

// Instanciar professores
const professors = new Professors();
