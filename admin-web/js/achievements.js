// Gerenciamento de Conquistas
class Achievements {
    constructor() {
        this.currentPage = 1;
        this.currentCategory = '';
        this.init();
    }

    init() {
        // Event listeners
        document.getElementById('achievementCategoryFilter').addEventListener('change', (e) => {
            this.currentCategory = e.target.value;
            this.currentPage = 1;
            this.loadAchievements();
        });

        this.loadAchievements();
        this.loadCategories();
    }

    async loadCategories() {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/achievement/categorias`, {
                headers: {
                    'Authorization': `Bearer ${auth.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const categories = await response.json();
                const select = document.getElementById('achievementCategoryFilter');
                
                // Manter a opção "Todas as categorias"
                select.innerHTML = '<option value="">Todas as categorias</option>';
                
                categories.forEach(category => {
                    const option = document.createElement('option');
                    option.value = category;
                    option.textContent = category;
                    select.appendChild(option);
                });
            }
        } catch (error) {
            console.error('Erro ao carregar categorias:', error);
        }
    }

    async loadAchievements() {
        try {
            const params = new URLSearchParams({
                page: this.currentPage,
                limit: CONFIG.ITEMS_PER_PAGE
            });

            if (this.currentCategory) {
                params.append('categoria', this.currentCategory);
            }

            const response = await fetch(`${CONFIG.API_BASE_URL}/achievement?${params}`, {
                headers: {
                    'Authorization': `Bearer ${auth.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                this.renderAchievements(data.conquistas);
                this.renderPagination(data.paginacao);
                document.getElementById('achievementCount').textContent = data.paginacao.total;
            }
        } catch (error) {
            console.error('Erro ao carregar conquistas:', error);
        }
    }

    renderAchievements(achievements) {
        const container = document.getElementById('achievementsList');
        
        if (achievements.length === 0) {
            container.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhuma conquista encontrada</p>';
            return;
        }

        container.innerHTML = achievements.map(achievement => `
            <div class="bg-white border border-gray-200 rounded-lg p-6">
                <div class="flex items-start space-x-4">
                    <div class="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0">
                        <i class="fas fa-trophy text-yellow-600 text-2xl"></i>
                    </div>
                    <div class="flex-1">
                        <div class="flex items-start justify-between mb-2">
                            <h3 class="text-lg font-semibold text-gray-900">${achievement.nome}</h3>
                            <div class="flex items-center space-x-2">
                                <span class="inline-block px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800">
                                    ${achievement.categoria || 'Geral'}
                                </span>
                                ${achievement.tipo ? `
                                    <span class="inline-block px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">
                                        ${achievement.tipo}
                                    </span>
                                ` : ''}
                            </div>
                        </div>
                        <p class="text-gray-600 mb-3">${achievement.descricao}</p>
                        
                        <div class="grid grid-cols-2 gap-4 text-sm">
                            <div>
                                <p class="text-gray-500">Requisito</p>
                                <p class="font-semibold">${achievement.requisitos || 'Não especificado'}</p>
                            </div>
                            <div>
                                <p class="text-gray-500">Tipo</p>
                                <p class="font-semibold">${achievement.tipo || 'Não especificado'}</p>
                            </div>
                        </div>
                        
                        ${achievement.icone ? `
                            <div class="mt-3">
                                <p class="text-gray-500 text-sm">Ícone: ${achievement.icone}</p>
                            </div>
                        ` : ''}
                        
                        <div class="mt-3 text-xs text-gray-500">
                            <p>Criada em: ${Utils.formatDate(achievement.createdAt)}</p>
                        </div>
                    </div>
                </div>
            </div>
        `).join('');
    }

    renderPagination(pagination) {
        const container = document.getElementById('achievementsPagination');
        
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
                <button onclick="achievements.goToPage(${currentPage - 1})" 
                        class="px-3 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">
                    <i class="fas fa-chevron-left"></i>
                </button>
            `);
        }

        // Páginas numeradas
        for (let i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) {
            pages.push(`
                <button onclick="achievements.goToPage(${i})" 
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
                <button onclick="achievements.goToPage(${currentPage + 1})" 
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
        this.loadAchievements();
    }
}

// Instanciar conquistas
const achievements = new Achievements();
