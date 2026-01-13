<?php

class InstitutionController {
    private $institution;
    
    public function __construct($institution) {
        $this->institution = $institution;
    }
    
    // GET /api/institutions
    public function getInstitutions() {
        try {
            // Récupérer les paramètres de requête
            $search = isset($_GET['search']) ? $_GET['search'] : null;
            $type = isset($_GET['type']) ? $_GET['type'] : null;
            $status = isset($_GET['status']) ? $_GET['status'] : null;
            $region = isset($_GET['region']) ? $_GET['region'] : null;
            $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
            $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
            
            // Validation
            if ($page < 1) $page = 1;
            if ($limit < 1 || $limit > 100) $limit = 20;
            
            // Récupérer les institutions
            $institutions = $this->institution->read($search, $type, $status, $region, $page, $limit);
            
            // Récupérer le nombre total pour la pagination
            $total = $this->institution->count($search, $type, $status, $region);
            $totalPages = ceil($total / $limit);
            
            // Formatter la réponse
            $response = [
                'success' => true,
                'data' => $institutions,
                'pagination' => [
                    'current_page' => $page,
                    'total_pages' => $totalPages,
                    'total_items' => $total,
                    'items_per_page' => $limit
                ]
            ];
            
            http_response_code(200);
            echo json_encode($response);
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erreur lors de la récupération des institutions: ' . $e->getMessage()
            ]);
        }
    }
    
    // GET /api/institutions/{id}
    public function getInstitution($id) {
        try {
            $this->institution->id = $id;
            
            if($this->institution->readOne()) {
                $response = [
                    'success' => true,
                    'data' => [
                        'id' => $this->institution->id,
                        'uuid' => $this->institution->uuid,
                        'code' => $this->institution->code,
                        'name' => $this->institution->name,
                        'short_name' => $this->institution->short_name,
                        'type' => $this->institution->type,
                        'status' => $this->institution->status,
                        'country' => $this->institution->country,
                        'region' => $this->institution->region,
                        'city' => $this->institution->city,
                        'address' => $this->institution->address,
                        'postal_code' => $this->institution->postal_code,
                        'phone_primary' => $this->institution->phone_primary,
                        'phone_secondary' => $this->institution->phone_secondary,
                        'email_official' => $this->institution->email_official,
                        'email_admin' => $this->institution->email_admin,
                        'website' => $this->institution->website,
                        'logo_url' => $this->institution->logo_url,
                        'banner_url' => $this->institution->banner_url,
                        'description' => $this->institution->description,
                        'founded_year' => $this->institution->founded_year,
                        'rector_name' => $this->institution->rector_name,
                        'total_students' => $this->institution->total_students,
                        'total_staff' => $this->institution->total_staff,
                        'is_national_hub' => (bool)$this->institution->is_national_hub,
                        'is_active' => (bool)$this->institution->is_active,
                        'sync_enabled' => (bool)$this->institution->sync_enabled,
                        'last_sync_at' => $this->institution->last_sync_at,
                        'metadata' => $this->institution->metadata,
                        'created_at' => $this->institution->created_at,
                        'updated_at' => $this->institution->updated_at
                    ]
                ];
                
                http_response_code(200);
                echo json_encode($response);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Institution non trouvée'
                ]);
            }
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erreur lors de la récupération de l\'institution: ' . $e->getMessage()
            ]);
        }
    }
    
    // POST /api/institutions
    public function createInstitution() {
        try {
            // Récupérer les données JSON
            $data = json_decode(file_get_contents("php://input"));
            
            if(!$data) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Données invalides'
                ]);
                return;
            }
            
            // Validation des champs requis
            $required_fields = ['name', 'short_name', 'type', 'status', 'region'];
            foreach($required_fields as $field) {
                if(empty($data->$field)) {
                    http_response_code(400);
                    echo json_encode([
                        'success' => false,
                        'error' => "Le champ '$field' est requis"
                    ]);
                    return;
                }
            }
            
            // Assigner les valeurs
            $this->institution->uuid = $data->uuid ?? uniqid();
            $this->institution->code = $data->code ?? strtoupper(substr($data->short_name, 0, 3));
            $this->institution->name = $data->name;
            $this->institution->short_name = $data->short_name;
            $this->institution->type = $data->type;
            $this->institution->status = $data->status;
            $this->institution->country = $data->country ?? 'Cameroun';
            $this->institution->region = $data->region;
            $this->institution->city = $data->city ?? '';
            $this->institution->address = $data->address ?? '';
            $this->institution->postal_code = $data->postal_code ?? '';
            $this->institution->phone_primary = $data->phone_primary ?? '';
            $this->institution->phone_secondary = $data->phone_secondary ?? '';
            $this->institution->email_official = $data->email_official ?? '';
            $this->institution->email_admin = $data->email_admin ?? '';
            $this->institution->website = $data->website ?? '';
            $this->institution->logo_url = $data->logo_url ?? '';
            $this->institution->banner_url = $data->banner_url ?? '';
            $this->institution->description = $data->description ?? '';
            $this->institution->founded_year = $data->founded_year ?? null;
            $this->institution->rector_name = $data->rector_name ?? '';
            $this->institution->total_students = $data->total_students ?? 0;
            $this->institution->total_staff = $data->total_staff ?? 0;
            $this->institution->is_national_hub = $data->is_national_hub ?? false;
            $this->institution->is_active = $data->is_active ?? true;
            $this->institution->sync_enabled = $data->sync_enabled ?? true;
            $this->institution->metadata = $data->metadata ?? '';
            
            // Créer l'institution
            if($this->institution->create()) {
                $response = [
                    'success' => true,
                    'message' => 'Institution créée avec succès',
                    'data' => [
                        'id' => $this->institution->id,
                        'uuid' => $this->institution->uuid,
                        'code' => $this->institution->code,
                        'name' => $this->institution->name,
                        'short_name' => $this->institution->short_name,
                        'type' => $this->institution->type,
                        'status' => $this->institution->status,
                        'region' => $this->institution->region,
                        'is_active' => (bool)$this->institution->is_active,
                        'created_at' => date('Y-m-d H:i:s')
                    ]
                ];
                
                http_response_code(201);
                echo json_encode($response);
            } else {
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'error' => 'Erreur lors de la création de l\'institution'
                ]);
            }
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }
    
    // PUT /api/institutions/{id}
    public function updateInstitution($id) {
        try {
            // Récupérer les données JSON
            $data = json_decode(file_get_contents("php://input"));
            
            if(!$data) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Données invalides'
                ]);
                return;
            }
            
            // Vérifier si l'institution existe
            $this->institution->id = $id;
            if(!$this->institution->readOne()) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Institution non trouvée'
                ]);
                return;
            }
            
            // Mettre à jour les champs
            if(isset($data->name)) $this->institution->name = $data->name;
            if(isset($data->short_name)) $this->institution->short_name = $data->short_name;
            if(isset($data->type)) $this->institution->type = $data->type;
            if(isset($data->status)) $this->institution->status = $data->status;
            if(isset($data->region)) $this->institution->region = $data->region;
            if(isset($data->city)) $this->institution->city = $data->city;
            if(isset($data->country)) $this->institution->country = $data->country;
            if(isset($data->description)) $this->institution->description = $data->description;
            if(isset($data->website)) $this->institution->website = $data->website;
            if(isset($data->email_official)) $this->institution->email_official = $data->email_official;
            if(isset($data->phone_primary)) $this->institution->phone_primary = $data->phone_primary;
            if(isset($data->address)) $this->institution->address = $data->address;
            if(isset($data->logo_url)) $this->institution->logo_url = $data->logo_url;
            if(isset($data->total_students)) $this->institution->total_students = $data->total_students;
            if(isset($data->total_staff)) $this->institution->total_staff = $data->total_staff;
            
            // Mettre à jour l'institution
            if($this->institution->update()) {
                $response = [
                    'success' => true,
                    'message' => 'Institution mise à jour avec succès',
                    'data' => [
                        'id' => $this->institution->id,
                        'name' => $this->institution->name,
                        'short_name' => $this->institution->short_name,
                        'type' => $this->institution->type,
                        'status' => $this->institution->status,
                        'region' => $this->institution->region,
                        'updated_at' => date('Y-m-d H:i:s')
                    ]
                ];
                
                http_response_code(200);
                echo json_encode($response);
            } else {
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'error' => 'Erreur lors de la mise à jour de l\'université'
                ]);
            }
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }
    
    // DELETE /api/institutions/{id}
    public function deleteInstitution($id) {
        try {
            // Vérifier si l'institution existe
            $this->institution->id = $id;
            if(!$this->institution->readOne()) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Institution non trouvée'
                ]);
                return;
            }
            
            // Supprimer l'institution
            if($this->institution->delete()) {
                $response = [
                    'success' => true,
                    'message' => 'Institution supprimée avec succès'
                ];
                
                http_response_code(200);
                echo json_encode($response);
            } else {
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'error' => 'Erreur lors de la suppression de l\'institution'
                ]);
            }
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }
    
    // GET /api/institutions/regions
    public function getRegions() {
        try {
            $regions = $this->institution->getRegions();
            
            $response = [
                'success' => true,
                'data' => $regions
            ];
            
            http_response_code(200);
            echo json_encode($response);
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erreur lors de la récupération des régions: ' . $e->getMessage()
            ]);
        }
    }
}
?>
