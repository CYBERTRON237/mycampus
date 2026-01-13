# Dockerfile pour Render - MyCampus
FROM php:8.2-cli

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier tous les fichiers du projet dans le conteneur
COPY . /app

# Exposer le port pour Render
EXPOSE 10000

# Lancer le serveur PHP en utilisant la racine du projet
CMD ["php", "-S", "0.0.0.0:10000", "-t", "./"]
