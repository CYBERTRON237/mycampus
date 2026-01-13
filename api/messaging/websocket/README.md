# Serveur WebSocket MyCampus

## Installation

1. Installer les dépendances :
```bash
composer install
```

2. Démarrer le serveur :
```bash
php server.php
```

Ou utiliser le script Windows :
```bash
start_server.bat
```

## Fonctionnalités

- **Messages temps réel** : Envoi/réception instantanée
- **Indicateurs de frappe** : "écrit en ce moment..."
- **Statuts utilisateur** : en ligne/hors ligne
- **Messages lus** : Confirmation de lecture
- **Reconnexion automatique** : Gestion des pannes

## Architecture

- **Port** : 8080
- **Adresse** : ws://127.0.0.1:8080
- **Authentification** : Token JWT
- **Rooms** : Par conversation (userId)

## Messages supportés

### Client → Serveur
- `authenticate` : Authentification utilisateur
- `join_room` : Rejoindre une conversation
- `message` : Envoyer un message
- `typing` : Indicateur de frappe
- `read` : Marquer comme lu

### Serveur → Client
- `authenticated` : Authentification réussie
- `message` : Nouveau message reçu
- `typing` : Statut de frappe
- `user_joined/user_left` : Connexion/déconnexion
- `message_read` : Message lu

## Intégration Flutter

Le service WebSocket est intégré dans :
- `WebSocketService` : Service principal
- `MessagingRepositoryImpl` : Repository avec WebSocket
- `ConversationPage` : UI avec temps réel

## Sécurité

- Validation des tokens JWT
- Isolation par rooms
- Filtrage des messages
- Gestion des erreurs
