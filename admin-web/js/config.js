// Configuração da API
const API_BASE_URL = `${window.location.protocol}//${window.location.hostname}:3000/api`;

// Configurações globais
const CONFIG = {
    API_BASE_URL,
    ITEMS_PER_PAGE: 10,
    DATE_FORMAT: 'DD/MM/YYYY HH:mm',
    CURRENCY_SYMBOL: 'IFC'
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

        // Criar ou obter container de notificações
        let notificationContainer = document.getElementById('notificationContainer');
        if (!notificationContainer) {
            notificationContainer = document.createElement('div');
            notificationContainer.id = 'notificationContainer';
            notificationContainer.className = 'fixed top-4 right-4 z-50 space-y-2 max-w-sm';
            document.body.appendChild(notificationContainer);
        }

        const notification = document.createElement('div');
        notification.className = `${colors[type]} text-white px-6 py-3 rounded-md shadow-lg transform transition-all duration-300 translate-x-full`;
        notification.textContent = message;

        notificationContainer.appendChild(notification);

        // Animar entrada
        setTimeout(() => {
            notification.classList.remove('translate-x-full');
        }, 100);

        // Remover após 5 segundos
        setTimeout(() => {
            notification.classList.add('translate-x-full');
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 5000);
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
    }
};