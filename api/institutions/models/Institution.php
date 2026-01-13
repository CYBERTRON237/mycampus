<?php
class Institution {
    private $conn;
    private $table_name = "institutions";

    public function __construct($db) {
        $this->conn = $db;
        error_log("Institution model initialisé");
    }

    public function getAll($includeInactive = false) {
        try {
            error_log("getAll() appelé avec includeInactive=" . ($includeInactive ? 'true' : 'false'));
            
            $query = "SELECT * FROM " . $this->table_name . " WHERE 1=1";
            
            if (!$includeInactive) {
                $query .= " AND is_active = 1";
            }
            
            $query .= " ORDER BY name ASC";
            
            error_log("Requête SQL: $query");
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            
            $institutions_arr = array();
            
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $institution_item = $this->formatInstitution($row);
                array_push($institutions_arr, $institution_item);
            }
            
            error_log("getAll() a retourné " . count($institutions_arr) . " institutions");
            
            return array(
                "success" => true,
                "data" => $institutions_arr,
                "count" => count($institutions_arr)
            );
            
        } catch (PDOException $e) {
            error_log("Erreur PDO dans getAll(): " . $e->getMessage());
            error_log("Code d'erreur: " . $e->getCode());
            return array(
                "success" => false,
                "message" => "Erreur lors de la récupération des institutions",
                "error" => $e->getMessage()
            );
        } catch (Exception $e) {
            error_log("Erreur dans getAll(): " . $e->getMessage());
            return array(
                "success" => false,
                "message" => "Une erreur inattendue est survenue",
                "error" => $e->getMessage()
            );
        }
    }

    public function getById($id) {
        try {
            $query = "SELECT * FROM " . $this->table_name . " WHERE id = :id LIMIT 1";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(":id", $id, PDO::PARAM_INT);
            $stmt->execute();
            
            if ($stmt->rowCount() > 0) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                
                return array(
                    "success" => true,
                    "data" => $this->formatInstitution($row)
                );
            }
            
            return array(
                "success" => false,
                "message" => "Institution non trouvée"
            );
        } catch (PDOException $e) {
            error_log("Erreur PDO dans getById(): " . $e->getMessage());
            return array(
                "success" => false,
                "message" => "Erreur lors de la récupération de l'institution",
                "error" => $e->getMessage()
            );
        }
    }

    public function getByCode($code) {
        try {
            $query = "SELECT * FROM " . $this->table_name . " WHERE code = :code LIMIT 1";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(":code", $code);
            $stmt->execute();
            
            if ($stmt->rowCount() > 0) {
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                
                return array(
                    "success" => true,
                    "data" => $this->formatInstitution($row)
                );
            }
            
            return array(
                "success" => false,
                "message" => "Institution non trouvée"
            );
        } catch (PDOException $e) {
            error_log("Erreur PDO dans getByCode(): " . $e->getMessage());
            return array(
                "success" => false,
                "message" => "Erreur lors de la récupération de l'institution",
                "error" => $e->getMessage()
            );
        }
    }

    public function search($criteria) {
        $requestId = uniqid('search_', true);
        
        try {
            error_log("[$requestId] ===== DÉBUT search() =====");
            error_log("[$requestId] Critères: " . json_encode($criteria));
            
            // Types autorisés selon la structure de la table
            $allowedTypes = ['university', 'school', 'training_center', 'other'];
            
            // Champs de tri autorisés
            $allowedOrderBy = ['name', 'city', 'country', 'type', 'created_at'];
            
            $query = "SELECT * FROM " . $this->table_name . " WHERE 1=1";
            $params = array();
            
            // Recherche par texte
            if (!empty($criteria['search'])) {
                $query .= " AND (name LIKE :search OR city LIKE :search OR country LIKE :search OR description LIKE :search)";
                $params[':search'] = '%' . htmlspecialchars(strip_tags($criteria['search'])) . '%';
            }
            
            // Filtre par type
            if (!empty($criteria['type'])) {
                $type = strtolower(trim($criteria['type']));
                if (in_array($type, $allowedTypes)) {
                    $query .= " AND type = :type";
                    $params[':type'] = $type;
                }
            }
            
            // Filtre par ville
            if (!empty($criteria['city'])) {
                $query .= " AND city = :city";
                $params[':city'] = htmlspecialchars(strip_tags($criteria['city']));
            }
            
            // Filtre par pays
            if (!empty($criteria['country'])) {
                $query .= " AND country = :country";
                $params[':country'] = htmlspecialchars(strip_tags($criteria['country']));
            }
            
            // Filtre par statut actif/inactif
            if (isset($criteria['is_active'])) {
                $query .= " AND is_active = :is_active";
                $params[':is_active'] = $criteria['is_active'] ? 1 : 0;
            } else {
                $query .= " AND is_active = 1";
            }
            
            // Gestion du tri
            $order_by = 'name';
            $order_dir = 'ASC';
            
            if (!empty($criteria['order_by']) && in_array($criteria['order_by'], $allowedOrderBy)) {
                $order_by = $criteria['order_by'];
            }
            
            if (!empty($criteria['order_dir']) && in_array(strtoupper($criteria['order_dir']), ['ASC', 'DESC'])) {
                $order_dir = strtoupper($criteria['order_dir']);
            }
            
            // Utilisation de backticks pour échapper les noms de colonnes
            $query .= " ORDER BY `" . $order_by . "` " . $order_dir;
            
            // Pagination
            $page = isset($criteria['page']) ? max(1, (int)$criteria['page']) : 1;
            $per_page = isset($criteria['per_page']) ? min(max(1, (int)$criteria['per_page']), 100) : 20;
            $offset = ($page - 1) * $per_page;
            
            $query .= " LIMIT :offset, :per_page";
            
            error_log("[$requestId] Requête SQL: $query");
            error_log("[$requestId] Paramètres: " . json_encode($params));
            error_log("[$requestId] Offset: $offset, Per page: $per_page");
            
            $stmt = $this->conn->prepare($query);
            
            foreach ($params as $param => $value) {
                $stmt->bindValue($param, $value);
            }
            
            $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
            $stmt->bindValue(':per_page', (int)$per_page, PDO::PARAM_INT);
            
            error_log("[$requestId] Exécution de la requête...");
            $stmt->execute();
            
            $institutions = array();
            
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $institutions[] = $this->formatInstitution($row);
            }
            
            error_log("[$requestId] Résultats: " . count($institutions) . " institutions");
            
            // Requête de comptage avec les mêmes conditions que la requête principale
            $count_query = "SELECT COUNT(*) as total FROM " . $this->table_name . " WHERE 1=1";
            
            // Réutiliser les mêmes paramètres que la requête principale
            $count_params = $params;
            
            // Ajouter les mêmes conditions que la requête principale
            if (!empty($criteria['search'])) {
                $count_query .= " AND (name LIKE :search OR city LIKE :search OR country LIKE :search OR description LIKE :search)";
            }
            
            if (!empty($criteria['type'])) {
                $type = strtolower(trim($criteria['type']));
                if (in_array($type, $allowedTypes)) {
                    $count_query .= " AND type = :type";
                }
            }
            
            if (!empty($criteria['city'])) {
                $count_query .= " AND city = :city";
            }
            
            if (!empty($criteria['country'])) {
                $count_query .= " AND country = :country";
            }
            
            if (isset($criteria['is_active'])) {
                $count_query .= " AND is_active = :is_active";
            } else {
                $count_query .= " AND is_active = 1";
            }
            
            error_log("[$requestId] Requête de comptage: $count_query");
            
            $count_stmt = $this->conn->prepare($count_query);
            
            foreach ($count_params as $param => $value) {
                $count_stmt->bindValue($param, $value);
            }
            
            $count_stmt->execute();
            $total = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];
            
            error_log("[$requestId] Total: $total institutions");
            
            $result = array(
                "success" => true,
                "data" => $institutions,
                "pagination" => array(
                    "total" => (int)$total,
                    "page" => $page,
                    "per_page" => $per_page,
                    "total_pages" => ceil($total / $per_page)
                )
            );
            
            error_log("[$requestId] ===== FIN search() - SUCCÈS =====");
            
            return $result;
            
        } catch (PDOException $e) {
            error_log("[$requestId] ❌ Erreur PDO: " . $e->getMessage());
            error_log("[$requestId] Code: " . $e->getCode());
            error_log("[$requestId] Stack trace: " . $e->getTraceAsString());
            
            return array(
                "success" => false,
                "error" => "Erreur de base de données",
                "message" => $e->getMessage(),
                "code" => $e->getCode()
            );
            
        } catch (Exception $e) {
            error_log("[$requestId] ❌ Erreur générale: " . $e->getMessage());
            error_log("[$requestId] Stack trace: " . $e->getTraceAsString());
            
            return array(
                "success" => false,
                "error" => "Erreur lors de la recherche",
                "message" => $e->getMessage()
            );
        }
    }

    public function create($data) {
        try {
            $code = $this->generateInstitutionCode($data->name);
            $uuid = $this->generateUUID();
            
            $query = "INSERT INTO " . $this->table_name . " 
                     (uuid, code, name, short_name, type, status, country, region, city, 
                     address, postal_code, phone_primary, phone_secondary, email_official, 
                     email_admin, website, logo_url, banner_url, description, founded_year, 
                     rector_name, total_students, total_staff, is_national_hub, is_active, 
                     sync_enabled, metadata) 
                     VALUES 
                     (:uuid, :code, :name, :short_name, :type, :status, :country, :region, :city, 
                     :address, :postal_code, :phone_primary, :phone_secondary, :email_official, 
                     :email_admin, :website, :logo_url, :banner_url, :description, :founded_year, 
                     :rector_name, :total_students, :total_staff, :is_national_hub, :is_active, 
                     :sync_enabled, :metadata)";
            
            $stmt = $this->conn->prepare($query);
            
            $name = htmlspecialchars(strip_tags($data->name));
            $short_name = isset($data->short_name) ? htmlspecialchars(strip_tags($data->short_name)) : $this->generateShortName($data->name);
            $type = isset($data->type) && in_array($data->type, ['public', 'private', 'professional', 'research']) 
                  ? $data->type : 'public';
            $status = isset($data->status) && in_array($data->status, ['active', 'inactive', 'suspended']) 
                    ? $data->status : 'active';
            $country = isset($data->country) ? htmlspecialchars(strip_tags($data->country)) : 'Cameroun';
            $region = isset($data->region) ? htmlspecialchars(strip_tags($data->region)) : '';
            $city = isset($data->city) ? htmlspecialchars(strip_tags($data->city)) : '';
            $address = isset($data->address) ? htmlspecialchars(strip_tags($data->address)) : null;
            $postal_code = isset($data->postal_code) ? htmlspecialchars(strip_tags($data->postal_code)) : null;
            $phone_primary = isset($data->phone_primary) ? htmlspecialchars(strip_tags($data->phone_primary)) : null;
            $phone_secondary = isset($data->phone_secondary) ? htmlspecialchars(strip_tags($data->phone_secondary)) : null;
            $email_official = isset($data->email_official) ? filter_var($data->email_official, FILTER_SANITIZE_EMAIL) : null;
            $email_admin = isset($data->email_admin) ? filter_var($data->email_admin, FILTER_SANITIZE_EMAIL) : null;
            $website = isset($data->website) ? filter_var($data->website, FILTER_SANITIZE_URL) : null;
            $logo_url = isset($data->logo_url) ? filter_var($data->logo_url, FILTER_SANITIZE_URL) : null;
            $banner_url = isset($data->banner_url) ? filter_var($data->banner_url, FILTER_SANITIZE_URL) : null;
            $description = isset($data->description) ? htmlspecialchars(strip_tags($data->description)) : null;
            $founded_year = isset($data->founded_year) ? (int)$data->founded_year : null;
            $rector_name = isset($data->rector_name) ? htmlspecialchars(strip_tags($data->rector_name)) : null;
            $total_students = isset($data->total_students) ? (int)$data->total_students : 0;
            $total_staff = isset($data->total_staff) ? (int)$data->total_staff : 0;
            $is_national_hub = isset($data->is_national_hub) ? (int)(bool)$data->is_national_hub : 0;
            $is_active = isset($data->is_active) ? (int)(bool)$data->is_active : 1;
            $sync_enabled = isset($data->sync_enabled) ? (int)(bool)$data->sync_enabled : 1;
            $metadata = isset($data->metadata) ? json_encode($data->metadata) : null;
            
            $stmt->bindParam(":uuid", $uuid);
            $stmt->bindParam(":code", $code);
            $stmt->bindParam(":name", $name);
            $stmt->bindParam(":short_name", $short_name);
            $stmt->bindParam(":type", $type);
            $stmt->bindParam(":status", $status);
            $stmt->bindParam(":country", $country);
            $stmt->bindParam(":region", $region);
            $stmt->bindParam(":city", $city);
            $stmt->bindParam(":address", $address);
            $stmt->bindParam(":postal_code", $postal_code);
            $stmt->bindParam(":phone_primary", $phone_primary);
            $stmt->bindParam(":phone_secondary", $phone_secondary);
            $stmt->bindParam(":email_official", $email_official);
            $stmt->bindParam(":email_admin", $email_admin);
            $stmt->bindParam(":website", $website);
            $stmt->bindParam(":logo_url", $logo_url);
            $stmt->bindParam(":banner_url", $banner_url);
            $stmt->bindParam(":description", $description);
            $stmt->bindParam(":founded_year", $founded_year, PDO::PARAM_INT);
            $stmt->bindParam(":rector_name", $rector_name);
            $stmt->bindParam(":total_students", $total_students, PDO::PARAM_INT);
            $stmt->bindParam(":total_staff", $total_staff, PDO::PARAM_INT);
            $stmt->bindParam(":is_national_hub", $is_national_hub, PDO::PARAM_INT);
            $stmt->bindParam(":is_active", $is_active, PDO::PARAM_INT);
            $stmt->bindParam(":sync_enabled", $sync_enabled, PDO::PARAM_INT);
            $stmt->bindParam(":metadata", $metadata);
            
            if ($stmt->execute()) {
                $id = $this->conn->lastInsertId();
                return array(
                    "success" => true,
                    "message" => "Institution créée avec succès",
                    "id" => $id,
                    "code" => $code,
                    "uuid" => $uuid
                );
            }
            
            return array(
                "success" => false,
                "message" => "Erreur lors de la création de l'institution"
            );
            
        } catch (PDOException $e) {
            error_log("Erreur PDO dans create(): " . $e->getMessage());
            
            if ($e->getCode() == '23000') {
                if (strpos($e->getMessage(), 'code') !== false) {
                    return array(
                        "success" => false,
                        "message" => "Le code de l'institution existe déjà"
                    );
                }
            }
            
            return array(
                "success" => false,
                "message" => "Erreur de base de données: " . $e->getMessage()
            );
        }
    }

    public function update($id, $data) {
        try {
            $check_query = "SELECT id FROM " . $this->table_name . " WHERE id = :id LIMIT 1";
            $check_stmt = $this->conn->prepare($check_query);
            $check_stmt->bindParam(":id", $id, PDO::PARAM_INT);
            $check_stmt->execute();
            
            if ($check_stmt->rowCount() == 0) {
                return array(
                    "success" => false,
                    "message" => "Institution non trouvée"
                );
            }
            
            $update_fields = array();
            $params = array(":id" => $id);
            
            $allowed_fields = [
                'code', 'name', 'short_name', 'type', 'status', 'country', 'region', 'city',
                'address', 'postal_code', 'phone_primary', 'phone_secondary', 'email_official',
                'email_admin', 'website', 'logo_url', 'banner_url', 'description', 'founded_year',
                'rector_name', 'total_students', 'total_staff', 'is_national_hub', 'is_active',
                'sync_enabled', 'metadata'
            ];
            
            foreach ($data as $key => $value) {
                if (in_array($key, $allowed_fields)) {
                    $param = ":" . $key;
                    $update_fields[] = "`$key` = $param";
                    
                    switch ($key) {
                        case 'name':
                        case 'short_name':
                        case 'address':
                        case 'city':
                        case 'region':
                        case 'country':
                        case 'postal_code':
                        case 'rector_name':
                        case 'phone_primary':
                        case 'phone_secondary':
                            $params[$param] = htmlspecialchars(strip_tags($value));
                            break;
                            
                        case 'email_official':
                        case 'email_admin':
                            $params[$param] = filter_var($value, FILTER_SANITIZE_EMAIL);
                            break;
                            
                        case 'website':
                        case 'logo_url':
                        case 'banner_url':
                            $params[$param] = filter_var($value, FILTER_SANITIZE_URL);
                            break;
                            
                        case 'type':
                            $params[$param] = in_array($value, ['public', 'private', 'professional', 'research']) 
                                            ? $value : 'public';
                            break;
                            
                        case 'status':
                            $params[$param] = in_array($value, ['active', 'inactive', 'suspended']) 
                                            ? $value : 'active';
                            break;
                            
                        case 'founded_year':
                        case 'total_students':
                        case 'total_staff':
                            $params[$param] = (int)$value;
                            break;
                            
                        case 'is_national_hub':
                        case 'is_active':
                        case 'sync_enabled':
                            $params[$param] = (int)(bool)$value;
                            break;
                            
                        case 'metadata':
                            $params[$param] = is_string($value) ? $value : json_encode($value);
                            break;
                            
                        default:
                            $params[$param] = $value;
                    }
                }
            }
            
            if (empty($update_fields)) {
                return array(
                    "success" => false,
                    "message" => "Aucun champ valide à mettre à jour"
                );
            }
            
            $update_fields[] = "`updated_at` = CURRENT_TIMESTAMP";
            
            $query = "UPDATE " . $this->table_name . " SET " . implode(", ", $update_fields) . " WHERE id = :id";
            $stmt = $this->conn->prepare($query);
            
            foreach ($params as $param => $value) {
                $param_type = PDO::PARAM_STR;
                if (is_int($value)) {
                    $param_type = PDO::PARAM_INT;
                } elseif (is_bool($value)) {
                    $param_type = PDO::PARAM_INT;
                } elseif (is_null($value)) {
                    $param_type = PDO::PARAM_NULL;
                }
                
                $stmt->bindValue($param, $value, $param_type);
            }
            
            if ($stmt->execute()) {
                return array(
                    "success" => true,
                    "message" => $stmt->rowCount() > 0 ? "Institution mise à jour avec succès" : "Aucune modification effectuée"
                );
            }
            
            return array(
                "success" => false,
                "message" => "Erreur lors de la mise à jour de l'institution"
            );
            
        } catch (PDOException $e) {
            error_log("Erreur PDO dans update(): " . $e->getMessage());
            
            if ($e->getCode() == '23000') {
                if (strpos($e->getMessage(), 'code') !== false) {
                    return array(
                        "success" => false,
                        "message" => "Le code de l'institution existe déjà"
                    );
                }
            }
            
            return array(
                "success" => false,
                "message" => "Erreur de base de données: " . $e->getMessage()
            );
        }
    }

    public function delete($id) {
        try {
            $check_query = "SELECT id, is_national_hub FROM " . $this->table_name . " WHERE id = :id";
            $check_stmt = $this->conn->prepare($check_query);
            $check_stmt->bindParam(":id", $id, PDO::PARAM_INT);
            $check_stmt->execute();
            
            if ($check_stmt->rowCount() == 0) {
                return array(
                    "success" => false,
                    "message" => "Institution non trouvée"
                );
            }
            
            $institution = $check_stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($institution['is_national_hub']) {
                return array(
                    "success" => false,
                    "message" => "Impossible de supprimer un hub national"
                );
            }
            
            $query = "UPDATE " . $this->table_name . " SET 
                     is_active = 0, 
                     status = 'inactive',
                     updated_at = CURRENT_TIMESTAMP 
                     WHERE id = :id";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(":id", $id, PDO::PARAM_INT);
            
            if ($stmt->execute()) {
                return array(
                    "success" => true,
                    "message" => "Institution désactivée avec succès"
                );
            }
            
            return array(
                "success" => false,
                "message" => "Erreur lors de la désactivation de l'institution"
            );
            
        } catch (PDOException $e) {
            error_log("Erreur PDO dans delete(): " . $e->getMessage());
            
            if ($e->getCode() == '23000') {
                return array(
                    "success" => false,
                    "message" => "Impossible de désactiver cette institution car elle est liée à d'autres enregistrements"
                );
            }
            
            return array(
                "success" => false,
                "message" => "Erreur de base de données: " . $e->getMessage()
            );
        }
    }

    private function formatInstitution($row) {
        return array(
            "id" => (int)$row['id'],
            "name" => $row['name'],
            "description" => $row['description'] ?? null,
            "logo_url" => $row['logo_url'] ?? null,
            "address" => $row['address'] ?? null,
            "city" => $row['city'] ?? null,
            "country" => $row['country'] ?? 'Cameroun',
            "postal_code" => $row['postal_code'] ?? null,
            "phone" => $row['phone'] ?? null,
            "email" => $row['email'] ?? null,
            "website" => $row['website'] ?? null,
            "type" => $row['type'] ?? 'university',
            "is_active" => (bool)($row['is_active'] ?? true),
            "student_count" => (int)($row['student_count'] ?? 0),
            "teacher_count" => (int)($row['teacher_count'] ?? 0),
            "programs" => !empty($row['programs']) ? json_decode($row['programs'], true) : [],
            "facilities" => !empty($row['facilities']) ? json_decode($row['facilities'], true) : [],
            "metadata" => !empty($row['metadata']) ? json_decode($row['metadata'], true) : null,
            "created_at" => $row['created_at'] ?? null,
            "updated_at" => $row['updated_at'] ?? null
        );
    }

    private function generateInstitutionCode($name) {
        if (empty($name)) {
            return 'INST' . strtoupper(substr(md5(uniqid(rand(), true)), 0, 6));
        }
        
        $code = '';
        $words = preg_split('/\s+/', $name);
        
        foreach ($words as $word) {
            if (!empty($word)) {
                $code .= strtoupper(substr($word, 0, 1));
            }
        }
        
        if (strlen($code) < 3) {
            $code .= strtoupper(substr(md5(uniqid(rand(), true)), 0, 6 - strlen($code)));
        }
        
        $check_query = "SELECT COUNT(*) as count FROM " . $this->table_name . " WHERE code = :code";
        $check_stmt = $this->conn->prepare($check_query);
        $check_stmt->bindParam(":code", $code);
        $check_stmt->execute();
        
        if ($check_stmt->fetch(PDO::FETCH_ASSOC)['count'] > 0) {
            $suffix = 1;
            $original_code = $code;
            
            do {
                $code = $original_code . $suffix;
                $check_stmt->bindParam(":code", $code);
                $check_stmt->execute();
                $suffix++;
            } while ($check_stmt->fetch(PDO::FETCH_ASSOC)['count'] > 0 && $suffix < 100);
            
            if ($suffix >= 100) {
                $code = 'INST' . strtoupper(substr(md5(uniqid(rand(), true)), 0, 6));
            }
        }
        
        return $code;
    }
    
    private function generateShortName($name) {
        $words = preg_split('/\s+/', $name, 4);
        $short_name = '';
        
        for ($i = 0; $i < min(3, count($words)); $i++) {
            if (!empty($words[$i])) {
                $short_name .= ' ' . $words[$i];
            }
        }
        
        return trim($short_name);
    }
    
    private function generateUUID() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }
}
?>
