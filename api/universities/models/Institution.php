<?php

class Institution {
    private $conn;
    private $table_name = "institutions";
    
    public $id;
    public $uuid;
    public $code;
    public $name;
    public $short_name;
    public $type;
    public $status;
    public $country;
    public $region;
    public $city;
    public $address;
    public $postal_code;
    public $phone_primary;
    public $phone_secondary;
    public $email_official;
    public $email_admin;
    public $website;
    public $logo_url;
    public $banner_url;
    public $description;
    public $founded_year;
    public $rector_name;
    public $total_students;
    public $total_staff;
    public $is_national_hub;
    public $is_active;
    public $sync_enabled;
    public $last_sync_at;
    public $metadata;
    public $created_at;
    public $updated_at;
    
    public function __construct($db) {
        $this->conn = $db;
    }
    
    // Créer une université
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                SET uuid=:uuid, code=:code, name=:name, short_name=:short_name, 
                    type=:type, status=:status, country=:country, region=:region,
                    city=:city, address=:address, postal_code=:postal_code,
                    phone_primary=:phone_primary, phone_secondary=:phone_secondary,
                    email_official=:email_official, email_admin=:email_admin,
                    website=:website, logo_url=:logo_url, banner_url=:banner_url,
                    description=:description, founded_year=:founded_year,
                    rector_name=:rector_name, total_students=:total_students,
                    total_staff=:total_staff, is_national_hub=:is_national_hub,
                    is_active=:is_active, sync_enabled=:sync_enabled,
                    metadata=:metadata, created_at=NOW()";
        
        $stmt = $this->conn->prepare($query);
        
        // Nettoyage et liaison
        $this->uuid = htmlspecialchars(strip_tags($this->uuid));
        $this->code = htmlspecialchars(strip_tags($this->code));
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->short_name = htmlspecialchars(strip_tags($this->short_name));
        $this->type = htmlspecialchars(strip_tags($this->type));
        $this->status = htmlspecialchars(strip_tags($this->status));
        $this->country = htmlspecialchars(strip_tags($this->country));
        $this->region = htmlspecialchars(strip_tags($this->region));
        $this->city = htmlspecialchars(strip_tags($this->city));
        $this->address = htmlspecialchars(strip_tags($this->address));
        $this->postal_code = htmlspecialchars(strip_tags($this->postal_code));
        $this->phone_primary = htmlspecialchars(strip_tags($this->phone_primary));
        $this->phone_secondary = htmlspecialchars(strip_tags($this->phone_secondary));
        $this->email_official = htmlspecialchars(strip_tags($this->email_official));
        $this->email_admin = htmlspecialchars(strip_tags($this->email_admin));
        $this->website = htmlspecialchars(strip_tags($this->website));
        $this->logo_url = htmlspecialchars(strip_tags($this->logo_url));
        $this->banner_url = htmlspecialchars(strip_tags($this->banner_url));
        $this->description = htmlspecialchars(strip_tags($this->description));
        $this->founded_year = htmlspecialchars(strip_tags($this->founded_year));
        $this->rector_name = htmlspecialchars(strip_tags($this->rector_name));
        $this->total_students = htmlspecialchars(strip_tags($this->total_students));
        $this->total_staff = htmlspecialchars(strip_tags($this->total_staff));
        $this->is_national_hub = (bool)$this->is_national_hub;
        $this->is_active = (bool)$this->is_active;
        $this->sync_enabled = (bool)$this->sync_enabled;
        $this->metadata = htmlspecialchars(strip_tags($this->metadata));
        
        $stmt->bindParam(":uuid", $this->uuid);
        $stmt->bindParam(":code", $this->code);
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":short_name", $this->short_name);
        $stmt->bindParam(":type", $this->type);
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":country", $this->country);
        $stmt->bindParam(":region", $this->region);
        $stmt->bindParam(":city", $this->city);
        $stmt->bindParam(":address", $this->address);
        $stmt->bindParam(":postal_code", $this->postal_code);
        $stmt->bindParam(":phone_primary", $this->phone_primary);
        $stmt->bindParam(":phone_secondary", $this->phone_secondary);
        $stmt->bindParam(":email_official", $this->email_official);
        $stmt->bindParam(":email_admin", $this->email_admin);
        $stmt->bindParam(":website", $this->website);
        $stmt->bindParam(":logo_url", $this->logo_url);
        $stmt->bindParam(":banner_url", $this->banner_url);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":founded_year", $this->founded_year);
        $stmt->bindParam(":rector_name", $this->rector_name);
        $stmt->bindParam(":total_students", $this->total_students);
        $stmt->bindParam(":total_staff", $this->total_staff);
        $stmt->bindParam(":is_national_hub", $this->is_national_hub, PDO::PARAM_BOOL);
        $stmt->bindParam(":is_active", $this->is_active, PDO::PARAM_BOOL);
        $stmt->bindParam(":sync_enabled", $this->sync_enabled, PDO::PARAM_BOOL);
        $stmt->bindParam(":metadata", $this->metadata);
        
        if($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            return true;
        }
        return false;
    }
    
    // Lire toutes les universités avec pagination et filtres
    public function read($search = null, $type = null, $status = null, $region = null, $page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        
        $query = "SELECT * FROM " . $this->table_name . " WHERE 1=1";
        $params = [];
        
        if($search) {
            $query .= " AND (name LIKE :search OR short_name LIKE :search OR code LIKE :search)";
            $params[':search'] = '%' . $search . '%';
        }
        
        if($type) {
            $query .= " AND type = :type";
            $params[':type'] = $type;
        }
        
        if($status) {
            $query .= " AND status = :status";
            $params[':status'] = $status;
        }
        
        if($region) {
            $query .= " AND region = :region";
            $params[':region'] = $region;
        }
        
        $query .= " ORDER BY created_at DESC LIMIT :limit OFFSET :offset";
        
        $stmt = $this->conn->prepare($query);
        
        foreach($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        
        $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
        
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    // Lire une université par ID
    public function readOne() {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = :id LIMIT 0,1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($row) {
            $this->id = $row['id'];
            $this->uuid = $row['uuid'];
            $this->code = $row['code'];
            $this->name = $row['name'];
            $this->short_name = $row['short_name'];
            $this->type = $row['type'];
            $this->status = $row['status'];
            $this->country = $row['country'];
            $this->region = $row['region'];
            $this->city = $row['city'];
            $this->address = $row['address'];
            $this->postal_code = $row['postal_code'];
            $this->phone_primary = $row['phone_primary'];
            $this->phone_secondary = $row['phone_secondary'];
            $this->email_official = $row['email_official'];
            $this->email_admin = $row['email_admin'];
            $this->website = $row['website'];
            $this->logo_url = $row['logo_url'];
            $this->banner_url = $row['banner_url'];
            $this->description = $row['description'];
            $this->founded_year = $row['founded_year'];
            $this->rector_name = $row['rector_name'];
            $this->total_students = $row['total_students'];
            $this->total_staff = $row['total_staff'];
            $this->is_national_hub = $row['is_national_hub'];
            $this->is_active = $row['is_active'];
            $this->sync_enabled = $row['sync_enabled'];
            $this->last_sync_at = $row['last_sync_at'];
            $this->metadata = $row['metadata'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            return true;
        }
        return false;
    }
    
    // Mettre à jour une université
    public function update() {
        $query = "UPDATE " . $this->table_name . "
                SET name=:name, short_name=:short_name, type=:type, status=:status, 
                    country=:country, region=:region, city=:city, description=:description, 
                    website=:website, email_official=:email_official, phone_primary=:phone_primary, 
                    address=:address, logo_url=:logo_url, total_students=:total_students,
                    total_staff=:total_staff, updated_at=NOW()
                WHERE id=:id";
        
        $stmt = $this->conn->prepare($query);
        
        // Nettoyage et liaison
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->short_name = htmlspecialchars(strip_tags($this->short_name));
        $this->type = htmlspecialchars(strip_tags($this->type));
        $this->status = htmlspecialchars(strip_tags($this->status));
        $this->country = htmlspecialchars(strip_tags($this->country));
        $this->region = htmlspecialchars(strip_tags($this->region));
        $this->city = htmlspecialchars(strip_tags($this->city));
        $this->description = htmlspecialchars(strip_tags($this->description));
        $this->website = htmlspecialchars(strip_tags($this->website));
        $this->email_official = htmlspecialchars(strip_tags($this->email_official));
        $this->phone_primary = htmlspecialchars(strip_tags($this->phone_primary));
        $this->address = htmlspecialchars(strip_tags($this->address));
        $this->logo_url = htmlspecialchars(strip_tags($this->logo_url));
        $this->total_students = htmlspecialchars(strip_tags($this->total_students));
        $this->total_staff = htmlspecialchars(strip_tags($this->total_staff));
        
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":short_name", $this->short_name);
        $stmt->bindParam(":type", $this->type);
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":country", $this->country);
        $stmt->bindParam(":region", $this->region);
        $stmt->bindParam(":city", $this->city);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":website", $this->website);
        $stmt->bindParam(":email_official", $this->email_official);
        $stmt->bindParam(":phone_primary", $this->phone_primary);
        $stmt->bindParam(":address", $this->address);
        $stmt->bindParam(":logo_url", $this->logo_url);
        $stmt->bindParam(":total_students", $this->total_students);
        $stmt->bindParam(":total_staff", $this->total_staff);
        
        return $stmt->execute();
    }
    
    // Supprimer une université
    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        
        return $stmt->execute();
    }
    
    // Compter le nombre total d'universités (pour la pagination)
    public function count($search = null, $type = null, $status = null, $region = null) {
        $query = "SELECT COUNT(*) as total FROM " . $this->table_name . " WHERE 1=1";
        $params = [];
        
        if($search) {
            $query .= " AND (name LIKE :search OR short_name LIKE :search OR code LIKE :search)";
            $params[':search'] = '%' . $search . '%';
        }
        
        if($type) {
            $query .= " AND type = :type";
            $params[':type'] = $type;
        }
        
        if($status) {
            $query .= " AND status = :status";
            $params[':status'] = $status;
        }
        
        if($region) {
            $query .= " AND region = :region";
            $params[':region'] = $region;
        }
        
        $stmt = $this->conn->prepare($query);
        
        foreach($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['total'];
    }
    
    // Obtenir toutes les régions uniques
    public function getRegions() {
        $query = "SELECT name FROM regions WHERE is_active = 1 ORDER BY name";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }
}
?>
