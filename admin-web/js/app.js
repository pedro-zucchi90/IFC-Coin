// Aplicação Principal
class App {
    constructor() {
        this.currentSection = 'dashboard';
        this.init();
    }

    init() {
        this.setupNavigation();
        this.setupGlobalEventListeners();
    }

    setupNavigation() {
        // Event listeners para navegação
        document.querySelectorAll('.nav-item').forEach(button => {
            button.addEventListener('click', (e) => {
                const section = e.target.closest('.nav-item').dataset.section;
                this.showSection(section);
            });
        });
    }

    setupGlobalEventListeners() {
        // Fechar modais ao clicar fora
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('fixed')) {
                e.target.classList.add('hidden');
            }
        });

        // Atalhos de teclado
        document.addEventListener('keydown', (e) => {
            // ESC para fechar modais
            if (e.key === 'Escape') {
                document.querySelectorAll('.fixed').forEach(modal => {
                    modal.classList.add('hidden');
                });
            }
        });
    }

    async showSection(sectionName) {
        // Esconder todas as seções
        document.querySelectorAll('.section').forEach(section => {
            section.classList.add('hidden');
        });

        // Remover classe active de todos os botões de navegação
        document.querySelectorAll('.nav-item').forEach(button => {
            button.classList.remove('active');
        });

        // Mostrar seção selecionada
        const targetSection = document.getElementById(`${sectionName}Section`);
        if (targetSection) {
            targetSection.classList.remove('hidden');
        }

        // Adicionar classe active ao botão selecionado
        const activeButton = document.querySelector(`[data-section="${sectionName}"]`);
        if (activeButton) {
            activeButton.classList.add('active');
        }

        this.currentSection = sectionName;

        // Atualizar dados da seção se necessário
        await this.refreshCurrentSection();
    }

    async refreshCurrentSection() {
        switch (this.currentSection) {
            case 'dashboard':
                await dashboard.refresh();
                break;
            case 'professors':
                await professors.loadProfessors();
                break;
            case 'transactions':
                await transactions.loadTransactions();
                break;
            case 'goals':
                await goals.loadGoals();
                break;
            case 'achievements':
                await achievements.loadAchievements();
                break;
            case 'users':
                await users.loadUsers();
                break;
        }
    }

    // Método para mostrar loading
    showLoading() {
        const loading = document.createElement('div');
        loading.id = 'loading';
        loading.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
        loading.innerHTML = `
            <div class="bg-white p-6 rounded-lg shadow-xl">
                <div class="flex items-center space-x-3">
                    <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                    <span class="text-gray-700">Carregando...</span>
                </div>
            </div>
        `;
        document.body.appendChild(loading);
    }

    // Método para esconder loading
    hideLoading() {
        const loading = document.getElementById('loading');
        if (loading) {
            loading.remove();
        }
    }

    // Método para atualizar estatísticas do dashboard
    async updateDashboardStats() {
        try {
            // Atualizar estatísticas básicas
            await auth.loadBasicStats();
            
            // Atualizar dados recentes
            dashboard.refresh();
            
        } catch (error) {
            console.error('Erro ao atualizar estatísticas do dashboard:', error);
        }
    }
}

// Estilos CSS adicionais
const additionalStyles = `
    .nav-item {
        @apply px-4 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition duration-200 cursor-pointer;
    }
    
    .nav-item.active {
        @apply bg-blue-600 text-white hover:bg-blue-700;
    }
    
    .section {
        @apply transition-all duration-300;
    }
    
    .section.hidden {
        @apply hidden;
    }
    
    .section.active {
        @apply block;
    }
    
    /* Animações para notificações */
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    .notification {
        animation: slideIn 0.3s ease-out;
    }
    
    /* Estilos para modais */
    .modal-backdrop {
        backdrop-filter: blur(4px);
    }
    
    /* Estilos para cards */
    .card-hover {
        transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
    }
    
    .card-hover:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    }
    
    /* Estilos para botões */
    .btn-primary {
        @apply bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition duration-200;
    }
    
    .btn-success {
        @apply bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition duration-200;
    }
    
    .btn-danger {
        @apply bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition duration-200;
    }
    
    .btn-warning {
        @apply bg-yellow-600 text-white px-4 py-2 rounded-md hover:bg-yellow-700 transition duration-200;
    }
    
    /* Estilos para status badges */
    .status-pending {
        @apply bg-yellow-100 text-yellow-800;
    }
    
    .status-approved {
        @apply bg-green-100 text-green-800;
    }
    
    .status-rejected {
        @apply bg-red-100 text-red-800;
    }
    
    .status-active {
        @apply bg-green-100 text-green-800;
    }
    
    .status-inactive {
        @apply bg-red-100 text-red-800;
    }
`;

// Adicionar estilos ao documento
const styleSheet = document.createElement('style');
styleSheet.textContent = additionalStyles;
document.head.appendChild(styleSheet);

// Instanciar aplicação
const app = new App();

// Exportar para uso global
window.app = app;
