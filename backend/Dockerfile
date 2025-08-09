# Usa imagem oficial Node.js como base
FROM node:18-alpine

# Define diretório de trabalho dentro do container
WORKDIR /app

# Copia package.json e package-lock.json (se houver) para instalar dependências
COPY package*.json ./

# Instala as dependências
RUN npm install

# Copia todo o código da aplicação para dentro do container
COPY . .

# Expõe a porta que seu app vai usar
EXPOSE 3000

# Comando para iniciar sua aplicação
CMD ["npm", "start"]
