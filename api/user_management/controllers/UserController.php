<?php

namespace App\Controllers;

use App\Models\User;
use PDO;

class UserController {
    private PDO $db;
    private ?User $currentUser = null;

    public function __construct(PDO $db) {
        $this->db = $db;
    }

    /**
     * Initialise l'utilisateur courant à partir du token JWT
     */
    private function authenticate(): bool {
        // Essayer d'abord le header direct (plus fiable)
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? null;
        
        // Si pas trouvé, essayer getallheaders()
        if (!$authHeader && function_exists('getallheaders')) {
            $headers = getallheaders();
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        }
        
        // Si toujours pas trouvé, essayer les alternatives
        if (!$authHeader) {
            foreach ($_SERVER as $name => $value) {
                if (substr($name, 0, 5) == 'HTTP_') {
                    $headerName = str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))));
                    if (strtolower($headerName) === 'authorization') {
                        $authHeader = $value;
                        break;
                    }
                }
            }
        }
        
        if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
            return false;
        }

        $token = substr($authHeader, 7);
        
        try {
            $payload = $this->decodeJWT($token);
            
            if (empty($payload['user_id'])) {
                return false;
            }

            $this->currentUser = new User($this->db);
            $this->currentUser->findById($payload['user_id']);
            
            return $this->currentUser->isLoggedIn();
            
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Décodage JWT simplifié
     */
    private function decodeJWT(string $token): array {
        // Implémentation JWT simplifiée
        // Pour les tests, accepter un token base64 simple
        $parts = explode('.', $token);
        
        if (count($parts) >= 1) {
            // Essayer de décoder la première partie comme base64
            $payload = json_decode(base64_decode($parts[0]), true);
            if ($payload && isset($payload['user_id'])) {
                return $payload;
            }
        }
        
        // Fallback: essayer le format JWT standard
        if (count($parts) === 3) {
            $payload = json_decode(base64_decode($parts[1]), true);
            if ($payload && isset($payload['user_id'])) {
                return $payload;
            }
        }
        
        throw new \InvalidArgumentException('Token JWT invalide');
    }

    /**
     * Vérifie si l'utilisateur courant a une permission spécifique
     */
    private function requirePermission(string $permission): void {
        if (!$this->currentUser || !$this->currentUser->hasPermission($permission)) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Permission refusée',
                'error' => 'permission_denied'
            ], 403);
            exit;
        }
    }

    /**
     * Envoie une réponse JSON
     */
    private function sendJsonResponse(array $data, int $statusCode = 200): void {
        header('Content-Type: application/json');
        http_response_code($statusCode);
        echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Obtient les données de la requête JSON
     */
    private function getJsonInput(): array {
        $input = file_get_contents('php://input');
        return json_decode($input, true) ?: [];
    }

    /**
     * Valide les données d'entrée
     */
    private function validateInput(array $data, array $required): array {
        $errors = [];
        
        foreach ($required as $field) {
            if (empty($data[$field])) {
                $errors[] = "Le champ '$field' est requis";
            }
        }
        
        if (!empty($errors)) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $errors
            ], 400);
        }
        
        return $data;
    }

    /**
     * GET /api/users - Liste des utilisateurs visibles
     */
    public function index(): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        try {
            $filters = [
                'page' => $_GET['page'] ?? 1,
                'limit' => min($_GET['limit'] ?? 20, 100), // Limite max de 100
                'search' => $_GET['search'] ?? null,
                'role' => $_GET['role'] ?? null,
                'status' => $_GET['status'] ?? null
            ];

            $users = $this->currentUser->getVisibleUsers($filters);
            
            // Ajouter les permissions pour chaque utilisateur
            foreach ($users as &$user) {
                $user['permissions'] = [
                    'can_view' => true, // Déjà filtré par la requête
                    'can_edit' => $this->currentUser->canEditUser($user['id']),
                    'can_delete' => $this->currentUser->canDeleteUser($user['id'])
                ];
            }

            $this->sendJsonResponse([
                'success' => true,
                'data' => $users,
                'pagination' => [
                    'page' => (int) $filters['page'],
                    'limit' => (int) $filters['limit'],
                    'total' => count($users) // Simplifié - en pratique, faire une requête COUNT
                ]
            ]);

        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la récupération des utilisateurs',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * GET /api/users/{id} - Détails d'un utilisateur
     */
    public function show(int $id): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        try {
            // Vérifier si l'utilisateur courant peut voir cet utilisateur
            if (!$this->currentUser->canViewUser($id)) {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Utilisateur non trouvé ou accès refusé',
                    'error' => 'access_denied'
                ], 404);
            }

            $user = new User($this->db);
            $userData = $user->findById($id);

            if (!$userData) {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Utilisateur non trouvé',
                    'error' => 'user_not_found'
                ], 404);
            }

            // Ajouter les permissions
            $userData['permissions'] = [
                'can_view' => true,
                'can_edit' => $this->currentUser->canEditUser($id),
                'can_delete' => $this->currentUser->canDeleteUser($id)
            ];

            $this->sendJsonResponse([
                'success' => true,
                'data' => $userData
            ]);

        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la récupération de l\'utilisateur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * POST /api/users - Créer un nouvel utilisateur
     */
    public function create(): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        $this->requirePermission('users.create');

        try {
            $input = $this->getJsonInput();
            
            $required = ['email', 'first_name', 'last_name', 'password', 'institution_id'];
            $userData = $this->validateInput($input, $required);

            // Validation supplémentaire
            if (!filter_var($userData['email'], FILTER_VALIDATE_EMAIL)) {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Email invalide',
                    'error' => 'invalid_email'
                ], 400);
            }

            if (strlen($userData['password']) < 8) {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Le mot de passe doit contenir au moins 8 caractères',
                    'error' => 'password_too_short'
                ], 400);
            }

            // Définir le rôle par défaut si non spécifié
            $userData['primary_role'] = $userData['primary_role'] ?? 'student';
            $userData['account_status'] = $userData['account_status'] ?? 'pending_verification';

            $result = $this->currentUser->create($userData);

            $this->sendJsonResponse($result, $result['success'] ? 201 : 400);

        } catch (\InvalidArgumentException $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => $e->getMessage(),
                'error' => 'validation_error'
            ], 400);
        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la création de l\'utilisateur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * PUT /api/users/{id} - Mettre à jour un utilisateur
     */
    public function update(int $id): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        try {
            $input = $this->getJsonInput();
            
            if (empty($input)) {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Aucune donnée fournie',
                    'error' => 'no_data'
                ], 400);
            }

            $result = $this->currentUser->update($id, $input);

            $this->sendJsonResponse($result, $result['success'] ? 200 : 400);

        } catch (\InvalidArgumentException $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => $e->getMessage(),
                'error' => 'validation_error'
            ], 400);
        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour de l\'utilisateur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * DELETE /api/users/{id} - Supprimer un utilisateur
     */
    public function delete(int $id): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        try {
            $result = $this->currentUser->delete($id);

            $this->sendJsonResponse($result, $result['success'] ? 200 : 400);

        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la suppression de l\'utilisateur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * GET /api/users/stats - Statistiques des utilisateurs
     */
    public function stats(): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        $this->requirePermission('users.read');

        try {
            $stats = $this->currentUser->getUserRoleStats();

            $this->sendJsonResponse([
                'success' => true,
                'data' => $stats
            ]);

        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la récupération des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * POST /api/users/{id}/roles - Assigner un rôle à un utilisateur
     */
    public function assignRole(int $id): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        $this->requirePermission('users.manage_roles');

        try {
            $input = $this->getJsonInput();
            $required = ['role'];
            $this->validateInput($input, $required);

            $targetUser = new User($this->db);
            $targetUser->findById($id);

            if (!$targetUser) {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Utilisateur non trouvé',
                    'error' => 'user_not_found'
                ], 404);
            }

            // Vérifier que l'utilisateur courant peut gérer les rôles de cet utilisateur
            if (!$this->currentUser->canEditUser($id)) {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Permission refusée',
                    'error' => 'permission_denied'
                ], 403);
            }

            $success = $this->currentUser->assignRole($id, $input['role'], $this->currentUser->getData()['id']);

            if ($success) {
                $this->sendJsonResponse([
                    'success' => true,
                    'message' => 'Rôle assigné avec succès'
                ]);
            } else {
                $this->sendJsonResponse([
                    'success' => false,
                    'message' => 'Erreur lors de l\'assignation du rôle',
                    'error' => 'assignment_failed'
                ], 400);
            }

        } catch (\InvalidArgumentException $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => $e->getMessage(),
                'error' => 'validation_error'
            ], 400);
        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de l\'assignation du rôle',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * GET /api/users/current - Informations de l'utilisateur courant
     */
    public function current(): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        try {
            $userData = $this->currentUser->getData();
            $roles = $this->currentUser->getRoles();
            $permissions = $this->currentUser->getPermissions();

            $this->sendJsonResponse([
                'success' => true,
                'data' => [
                    'user' => $userData,
                    'roles' => $roles,
                    'permissions' => $permissions,
                    'highest_level' => $this->currentUser->getHighestLevel(),
                    'primary_role' => $this->currentUser->getPrimaryRole()
                ]
            ]);

        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la récupération des informations',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * POST /api/users/search - Recherche avancée d'utilisateurs
     */
    public function search(): void {
        if (!$this->authenticate()) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Authentification requise',
                'error' => 'authentication_required'
            ], 401);
        }

        $this->requirePermission('users.read');

        try {
            $input = $this->getJsonInput();
            
            $filters = [
                'page' => $input['page'] ?? 1,
                'limit' => min($input['limit'] ?? 20, 100),
                'search' => $input['search'] ?? null,
                'role' => $input['role'] ?? null,
                'status' => $input['status'] ?? null,
                'institution_id' => $input['institution_id'] ?? null
            ];

            $users = $this->currentUser->getVisibleUsers($filters);

            $this->sendJsonResponse([
                'success' => true,
                'data' => $users,
                'pagination' => [
                    'page' => (int) $filters['page'],
                    'limit' => (int) $filters['limit'],
                    'total' => count($users)
                ]
            ]);

        } catch (\Exception $e) {
            $this->sendJsonResponse([
                'success' => false,
                'message' => 'Erreur lors de la recherche',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
