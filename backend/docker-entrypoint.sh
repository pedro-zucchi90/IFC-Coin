#!/bin/sh

# Aguarda 3 segundos para garantir que o MongoDB esteja pronto
sleep 3

# Executa o script de criação do admin
echo "Criando usuário administrador..."
node /app/scripts/create_admin.js

# Executa o script de criação das conquistas padrão
echo "Criando conquistas padrão..."
node /app/scripts/criar_conquistas_padrao.js

# Inicia o servidor
echo "Iniciando o servidor..."
npm start
