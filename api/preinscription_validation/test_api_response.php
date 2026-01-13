<?php
// Test pour voir la réponse exacte de l'API
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');

try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // Récupérer une préinscription pour tester
    $sql = "SELECT p.*, 
                   u.id as user_id, u.email as user_email, u.primary_role as user_role
            FROM preinscriptions p 
            LEFT JOIN users u ON p.email = u.email 
            WHERE p.status IN ('pending', 'under_review')
            ORDER BY p.created_at DESC
            LIMIT 1";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($preinscription) {
        // Ajouter les champs supplémentaires
        $preinscription['has_user_account'] = !empty($preinscription['user_id']);
        $preinscription['current_user_role'] = $preinscription['user_role'];
        $preinscription['can_be_validated'] = isset($preinscription['payment_status']) && 
            ($preinscription['payment_status'] === 'paid' || $preinscription['payment_status'] === 'confirmed');
        
        // Afficher les types de données problématiques
        $problematic_fields = [];
        foreach ($preinscription as $key => $value) {
            if (in_array($key, ['scholarship_requested', 'interview_required', 'registration_completed', 
                               'marketing_consent', 'data_processing_consent', 'newsletter_subscription',
                               'is_processed', 'has_user_account', 'can_be_validated'])) {
                $problematic_fields[$key] = [
                    'value' => $value,
                    'type' => gettype($value),
                    'is_bool' => is_bool($value)
                ];
            }
        }
        
        echo json_encode([
            'success' => true,
            'data' => [$preinscription],
            'debug' => [
                'problematic_fields' => $problematic_fields,
                'total_fields' => count($preinscription)
            ]
        ]);
    } else {
        echo json_encode([
            'success' => true,
            'data' => [],
            'message' => 'Aucune préinscription trouvée'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
