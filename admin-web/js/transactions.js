// Gerenciamento de Transações
class Transactions {
    constructor() {
        this.currentPage = 1;
        this.currentType = '';
        this.currentStatus = '';
        this.init();
    }

    init() {
        // Event listeners
        document.getElementById('transactionTypeFilter').addEventListener('change', (e) => {
            this.currentType = e.target.value;
            this.currentPage = 1;
            this.loadTransactions();
        });

        document.getElementById('transactionStatusFilter').addEventListener('change', (e) => {
            this.currentStatus = e.target.value;
            this.currentPage = 1;
            this.loadTransactions();
        });

        this.loadTransactions();
    }

    async loadTransactions() {
        try {
            const params = new URLSearchParams({
                page: this.currentPage,
                limit: CONFIG.ITEMS_PER_PAGE
            });

            if (this.currentType) {
                params.append('tipo', this.currentType);
            }

            if (this.currentStatus) {
                params.append('status', this.currentStatus);
            }

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/transaction/todas?${params}`);
            
            if (response.ok) {
                const data = await response.json();
                this.renderTransactions(data.transacoes);
                this.renderPagination(data.paginacao);
                document.getElementById('transactionCount').textContent = data.paginacao.total;
            }
        } catch (error) {
            console.error('Erro ao carregar transações:', error);
        }
    }

    renderTransactions(transactions) {
        const container = document.getElementById('transactionsList');
        
        if (transactions.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhuma transação encontrada</p>';
            return;
        }

        container.innerHTML = transactions.map(transaction => `
            <div class="bg-white border border-gray-200 rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center space-x-4">
                        <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                            <i class="fas fa-exchange-alt text-blue-600 text-xl"></i>
                        </div>
                        <div class="flex-1">
                            <div class="flex items-center justify-between">
                                <h3 class="text-lg font-semibold text-gray-900">
                                    ${transaction.origem?.nome || 'Sistema'} → ${transaction.destino?.nome || 'Sistema'}
                                </h3>
                                <div class="text-right">
                                    <p class="text-lg font-bold text-gray-900">${Utils.formatCurrency(transaction.quantidade)}</p>
                                    <span class="inline-block px-2 py-1 text-xs rounded-full ${
                                        transaction.status === 'aprovada' ? 'bg-green-100 text-green-800' :
                                        transaction.status === 'pendente' ? 'bg-yellow-100 text-yellow-800' :
                                        'bg-red-100 text-red-800'
                                    }">${transaction.status}</span>
                                </div>
                            </div>
                            <p class="text-gray-600 mt-1">${transaction.descricao}</p>
                            <div class="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                                <span><i class="fas fa-calendar mr-1"></i>${Utils.formatDate(transaction.createdAt)}</span>
                                <span><i class="fas fa-tag mr-1"></i>${transaction.tipo}</span>
                                ${transaction.hash ? `<span><i class="fas fa-hashtag mr-1"></i>${transaction.hash.substring(0, 8)}...</span>` : ''}
                            </div>
                        </div>
                    </div>
                </div>
                
                ${transaction.status === 'pendente' ? `
                    <div class="flex space-x-2">
                        <button onclick="transactions.approveTransaction('${transaction._id}')" 
                                class="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition duration-200">
                            <i class="fas fa-check mr-2"></i>Aprovar
                        </button>
                        <button onclick="transactions.rejectTransaction('${transaction._id}')" 
                                class="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition duration-200">
                            <i class="fas fa-times mr-2"></i>Recusar
                        </button>
                    </div>
                ` : ''}
            </div>
        `).join('');
    }

    renderPagination(pagination) {
        const container = document.getElementById('transactionsPagination');
        
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
                <button onclick="transactions.goToPage(${currentPage - 1})" 
                        class="px-3 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">
                    <i class="fas fa-chevron-left"></i>
                </button>
            `);
        }

        // Páginas numeradas
        for (let i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) {
            pages.push(`
                <button onclick="transactions.goToPage(${i})" 
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
                <button onclick="transactions.goToPage(${currentPage + 1})" 
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
        this.loadTransactions();
    }

    async approveTransaction(transactionId) {
        try {
            const confirmed = await Utils.confirmAction('Tem certeza que deseja aprovar esta transação?');
            if (!confirmed) return;

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/transaction/${transactionId}/aprovar`, {
                method: 'POST'
            });

            if (response.ok) {
                Utils.showNotification('Transação aprovada com sucesso!', 'success');
                this.loadTransactions();
                dashboard.refresh();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao aprovar transação');
            }
        } catch (error) {
            console.error('Erro ao aprovar transação:', error);
            Utils.showNotification(error.message, 'error');
        }
    }

    async rejectTransaction(transactionId) {
        try {
            const confirmed = await Utils.confirmAction('Tem certeza que deseja recusar esta transação?');
            if (!confirmed) return;

            const response = await auth.authenticatedRequest(`${CONFIG.API_BASE_URL}/transaction/${transactionId}/recusar`, {
                method: 'POST'
            });

            if (response.ok) {
                Utils.showNotification('Transação recusada com sucesso!', 'success');
                this.loadTransactions();
                dashboard.refresh();
            } else {
                const data = await response.json();
                throw new Error(data.message || 'Erro ao recusar transação');
            }
        } catch (error) {
            console.error('Erro ao recusar transação:', error);
            Utils.showNotification(error.message, 'error');
        }
    }
}

// Instanciar transações
const transactions = new Transactions();
