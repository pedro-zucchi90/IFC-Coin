# Usa imagem oficial Node.js como base
FROM node:18-alpine

# Define diretório de trabalho dentro do container
WORKDIR /app

# Copia package.json e package-lock.json (se houver) para instalar dependências
COPY package*.json ./

# Limpa o cache do npm e instala as dependências
RUN npm cache clean --force && \
    npm install

# Copia todo o código da aplicação para dentro do container
COPY . .

# Expõe a porta que seu app vai usar
EXPOSE 3000

# Copia e configura o script de entrada
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Define o script de entrada como comando principal
CMD ["docker-entrypoint.sh"]