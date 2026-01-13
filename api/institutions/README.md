# API des Institutions

Ce module fournit des endpoints pour gérer les institutions dans l'application MyCampus.

## Installation

1. Exécutez le script SQL de migration pour créer la table des institutions :
   ```
   mysql -u username -p mycampus < database/migrations/20241202_create_institutions_table.sql
   ```

2. Assurez-vous que les permissions des dossiers sont correctement configurées pour permettre l'écriture des logs et des fichiers téléchargés.

## Endpoints

### Récupérer toutes les institutions

```
GET /api/institutions
```

**Réponse réussie (200 OK)**
```json
[
  {
    "id": 1,
    "name": "Université de Yaoundé I",
    "description": "Première université du Cameroun",
    "city": "Yaoundé",
    "country": "Cameroun",
    "type": "university",
    "is_active": true,
    "created_at": "2024-01-01 00:00:00"
  },
  ...
]
```

### Récupérer une institution par ID

```
GET /api/institutions/{id}
```

**Réponse réussie (200 OK)**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Université de Yaoundé I",
    "description": "Première université du Cameroun",
    "logo_url": "https://example.com/logo.jpg",
    "address": "B.P. 812, Yaoundé",
    "city": "Yaoundé",
    "country": "Cameroun",
    "postal_code": "00237",
    "phone": "+237 222 22 30 11",
    "email": "contact@uy1.uninet.cm",
    "website": "https://www.uy1.uninet.cm",
    "type": "university",
    "is_active": true,
    "student_count": 40000,
    "teacher_count": 1500,
    "programs": ["Informatique", "Droit", "Médecine"],
    "facilities": ["Bibliothèque", "Laboratoires", "Stade"],
    "created_at": "2024-01-01 00:00:00",
    "updated_at": "2024-01-01 00:00:00"
  }
}
```

### Créer une nouvelle institution

```
POST /api/institutions
```

**Corps de la requête**
```json
{
  "name": "Nouvelle Institution",
  "description": "Description de la nouvelle institution",
  "city": "Ville",
  "country": "Pays",
  "type": "university"
}
```

**Réponse réussie (201 Created)**
```json
{
  "success": true,
  "message": "Institution créée avec succès",
  "id": 4
}
```

### Mettre à jour une institution

```
PUT /api/institutions/{id}
```

**Corps de la requête**
```json
{
  "name": "Nouveau nom",
  "description": "Nouvelle description",
  "is_active": true
}
```

**Réponse réussie (200 OK)**
```json
{
  "success": true,
  "message": "Institution mise à jour avec succès"
}
```

### Supprimer une institution

```
DELETE /api/institutions/{id}
```

**Réponse réussie (200 OK)**
```json
{
  "success": true,
  "message": "Institution supprimée avec succès"
}
```

## Gestion des erreurs

### Réponse d'erreur (400 Bad Request)
```json
{
  "success": false,
  "message": "Message d'erreur détaillé"
}
```

### Erreur d'authentification (401 Unauthorized)
```json
{
  "success": false,
  "message": "Non autorisé"
}
```

### Ressource non trouvée (404 Not Found)
```json
{
  "success": false,
  "message": "Institution non trouvée"
}
```

## Sécurité

Tous les endpoints (sauf éventuellement la lecture publique des institutions) nécessitent un token JWT valide dans l'en-tête d'autorisation :

```
Authorization: Bearer votre_token_jwt_ici
```

## Tests

Pour tester l'API, vous pouvez utiliser un client HTTP comme Postman ou cURL :

```bash
# Récupérer toutes les institutions
curl -X GET http://localhost/api/institutions \
  -H "Authorization: Bearer votre_token_jwt_ici"

# Créer une nouvelle institution
curl -X POST http://localhost/api/institutions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer votre_token_jwt_ici" \
  -d '{"name":"Nouvelle Institution","city":"Ville","country":"Pays"}'
```

## Notes supplémentaires

- Les champs `created_at` et `updated_at` sont gérés automatiquement par la base de données
- Les champs `programs` et `facilities` sont stockés sous forme de tableaux JSON
- Le champ `is_active` est un booléen qui détermine si l'institution est active ou non
- Le champ `type` peut être l'une des valeurs suivantes : 'university', 'school', 'training_center', 'other'
