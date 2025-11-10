# Utilise une image officielle de Node.js comme base
FROM node:18-alpine

# Définit le dossier de travail à l’intérieur du conteneur
WORKDIR /app

# Copie uniquement les fichiers package.json et package-lock.json (pour installer les dépendances)
COPY package*.json ./

# Installe les dépendances Node.js
RUN npm install

# Copie le reste du code de l’application
COPY . .

# Informe Docker que le conteneur écoutera sur le port 3000
EXPOSE 3000

# Commande exécutée au démarrage du conteneur
CMD ["node", "index.js"]

