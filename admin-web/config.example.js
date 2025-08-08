// Exemplo de configuração para a interface web administrativa
// Copie este arquivo para config.js e ajuste conforme necessário

// Configuração da API
const API_BASE_URL = 'http://localhost:3000/api';

// Para produção, use a URL do seu servidor:
// const API_BASE_URL = 'https://seu-servidor.com/api';

// Configurações globais
const CONFIG = {
    API_BASE_URL,
    ITEMS_PER_PAGE: 10,
    DATE_FORMAT: 'DD/MM/YYYY HH:mm',
    CURRENCY_SYMBOL: 'IFC',
    
    // Configurações de desenvolvimento
    DEBUG: true, // Ative para ver logs detalhados
    
    // Configurações de timeout
    REQUEST_TIMEOUT: 10000, // 10 segundos
    
    // Configurações de notificação
    NOTIFICATION_DURATION: 3000, // 3 segundos
};

// Utilitários
const Utils = {
    // Formatar data
    formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    },

    // Formatar moeda
    formatCurrency(amount) {
        return `${CONFIG.CURRENCY_SYMBOL} ${amount}`;
    },

    // Mostrar notificação
    showNotification(message, type = 'info') {
        const colors = {
            success: 'bg-green-500',
            error: 'bg-red-500',
            warning: 'bg-yellow-500',
            info: 'bg-blue-500'
        };

        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 ${colors[type]} text-white px-6 py-3 rounded-md shadow-lg z-50 notification`;
        notification.textContent = message;

        document.body.appendChild(notification);

        setTimeout(() => {
            notification.remove();
        }, CONFIG.NOTIFICATION_DURATION);
    },

    // Confirmar ação
    async confirmAction(message) {
        return new Promise((resolve) => {
            const result = confirm(message);
            resolve(result);
        });
    },

    // Validar email
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },

    // Log de debug
    log(message, data = null) {
        if (CONFIG.DEBUG) {
            console.log(`[IFC Admin] ${message}`, data);
        }
    },

    // Tratar erro
    handleError(error, context = '') {
        console.error(`[IFC Admin] Erro em ${context}:`, error);
        this.showNotification(`Erro: ${error.message}`, 'error');
    }
};
