# Module de Gestion des Utilisateurs - MyCampus

## Vue d'ensemble

Module complet de gestion des utilisateurs avec restrictions basées sur les rôles hiérarchiques. L'admin peut effectuer le CRUD complet sur les autres utilisateurs, tandis que les utilisateurs avec des rôles inférieurs ne peuvent voir, modifier ou supprimer que les utilisateurs de niveau inférieur.

## Architecture

### Backend (PHP/MySQL)

#### 1. Base de données
- **Migration**: `database/migrations/20241212_create_role_management_tables.sql`
- **Tables créées**:
  - `roles`: Rôles hiérarchiques avec niveaux
  - `permissions`: Permissions granulaires
  - `role_permissions`: Association rôles-permissions
  - `user_roles`: Gestion des rôles multiples par utilisateur

#### 2. Modèle PHP
- **Fichier**: `api/user_management/models/User.php`
- **Fonctionnalités**:
  - Gestion des rôles et permissions
  - Validation des accès (canViewUser, canEditUser, canDeleteUser)
  - Filtrage automatique selon la hiérarchie
  - CRUD complet avec validation

#### 3. Contrôleur PHP
- **Fichier**: `api/user_management/controllers/UserController.php`
- **Endpoints REST**:
  - `GET /api/user_management/users` - Liste des utilisateurs visibles
  - `GET /api/user_management/users/{id}` - Détails utilisateur
  - `POST /api/user_management/users` - Créer utilisateur
  - `PUT /api/user_management/users/{id}` - Modifier utilisateur
  - `DELETE /api/user_management/users/{id}` - Supprimer utilisateur
  - `GET /api/user_management/users/stats` - Statistiques
  - `POST /api/user_management/users/{id}/roles` - Assigner rôle
  - `GET /api/user_management/users/current` - Utilisateur courant

#### 4. Routes API
- **Fichier**: `api/user_management/routes/api.php`
- **Configuration**: Gestion CORS, authentification JWT, routing

### Frontend (Flutter)

#### 1. Modèles de données
- **Fichier**: `lib/features/user_management/data/models/user_model.dart`
- **Classes**: `UserModel`, `UserPermissions`, `UserRoleStats`, `UserFilters`, etc.

#### 2. Architecture Clean Architecture
- **Repository**: `lib/features/user_management/data/repositories/user_management_repository.dart`
- **DataSource**: `lib/features/user_management/data/datasources/user_management_remote_datasource.dart`
- **Provider**: `lib/features/user_management/providers/user_management_provider.dart`

#### 3. Interface utilisateur
- **Page principale**: `lib/features/user_management/presentation/pages/user_management_page.dart`
- **Widgets**:
  - `user_card_widget.dart` - Carte utilisateur avec actions
  - `user_stats_widget.dart` - Statistiques par rôle
  - `user_filters_widget.dart` - Filtres de recherche
  - `create_user_dialog.dart` - Dialogue de création

## Hiérarchie des Rôles

### Niveaux de permission (du plus au moins élevé)
1. **Superadmin** (100) - Accès complet à tout
2. **Admin National** (90) - Gestion nationale
3. **Admin Local** (80) - Gestion institutionnelle
4. **Leader** (60) - Chef de département/faculté
5. **Teacher** (40) - Enseignant
6. **Staff** (30) - Personnel administratif
7. **Moderator** (25) - Modérateur
8. **Alumni** (20) - Ancien étudiant
9. **Student** (10) - Étudiant
10. **Guest** (5) - Invité

### Règles de visibilité
- **Superadmin/Admin National**: Voient tous les utilisateurs
- **Admin Local**: Voit uniquement les utilisateurs de son institution
- **Autres rôles**: Voient uniquement les utilisateurs de niveau inférieur
- **Tous**: Voient leur propre profil

## Fonctionnalités Clés

### 1. Gestion des restrictions
- Filtrage automatique selon le rôle de l'utilisateur connecté
- Validation des permissions pour chaque action
- Interface adaptative selon les droits

### 2. Interface utilisateur
- Recherche et filtrage multi-critères
- Actions contextuelles selon les permissions
- Statistiques en temps réel
- Gestion en masse (si permissions)

### 3. Sécurité
- Validation des entrées
- Protection contre les escalades de privilèges
- Audit des actions
- Authentification JWT

## Installation

### 1. Base de données
```sql
-- Exécuter la migration
mysql -u root -p mycampus < database/migrations/20241212_create_role_management_tables.sql
```

### 2. Configuration API
- Configurer la connexion à la base de données dans `api/user_management/routes/api.php`
- Mettre en place l'authentification JWT

### 3. Intégration Flutter
- Ajouter les dépendances HTTP
- Configurer les endpoints dans le datasource
- Intégrer le provider dans l'application

## Utilisation

### 1. Accès au module
```dart
// Navigation vers le module de gestion
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChangeNotifierProvider(
      create: (context) => UserManagementProvider(
        repository: userManagementRepository,
      ),
      child: UserManagementPage(),
    ),
  ),
);
```

### 2. Permissions
Les permissions sont vérifiées automatiquement:
- `canCreateUsers` - Création d'utilisateurs
- `canManageRoles` - Gestion des rôles
- `canViewStats` - Accès aux statistiques

### 3. Exemples d'utilisation
```php
// PHP - Vérification des permissions
if ($user->canEditUser($targetUserId)) {
    // Permettre la modification
}

// PHP - Liste des utilisateurs visibles
$users = $user->getVisibleUsers(['page' => 1, 'limit' => 20]);
```

## Tests

### 1. Tests API
```bash
# Test de récupération des utilisateurs
curl -H "Authorization: Bearer TOKEN" \
     http://localhost/mycampus/api/user_management/users

# Test de création d'utilisateur
curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer TOKEN" \
     -d '{"email":"test@example.com","first_name":"Test","last_name":"User","password":"password123","institution_id":1}' \
     http://localhost/mycampus/api/user_management/users
```

### 2. Tests Flutter
Les tests unitaires sont à implémenter dans `test/features/user_management/`

## Sécurité

### 1. Validation des entrées
- Email format validation
- Password strength requirements
- SQL injection prevention

### 2. Contrôle d'accès
- Role-based access control (RBAC)
- Hierarchical permissions
- JWT token validation

### 3. Audit
- Activity logging
- Permission change tracking
- User action history

## Maintenance

### 1. Monitoring
- User activity statistics
- Permission usage metrics
- Error tracking

### 2. Updates
- Role hierarchy modifications
- Permission updates
- Security patches

## Notes importantes

1. **Performance**: Les requêtes utilisent des procédures stockées pour optimiser les performances
2. **Scalability**: Architecture modulaire permettant l'ajout de nouveaux rôles
3. **Security**: Double validation (côté API et côté client)
4. **User Experience**: Interface adaptative selon les permissions de l'utilisateur

Ce module garantit que chaque utilisateur ne peut voir et interagir qu'avec les utilisateurs de niveau inférieur, tout en permettant aux administrateurs de gérer l'ensemble du système selon leurs prérogatives.
