<?php
// Modifications à ajouter dans submit.php pour gérer les préinscriptions pour tiers

// 1. Ajouter cette fonction de validation après getCurrentUserId()

function validatePreinscriptionData($input, $currentUser, $debugFile) {
    $relationship = $input['relationship'] ?? 'self';
    $applicantEmail = $input['applicantEmail'] ?? null;
    $applicantPhone = $input['applicantPhone'] ?? null;
    
    file_put_contents($debugFile, "Validation - Relationship: $relationship\n", FILE_APPEND);
    file_put_contents($debugFile, "Validation - Applicant Email: $applicantEmail\n", FILE_APPEND);
    file_put_contents($debugFile, "Validation - Applicant Phone: $applicantPhone\n", FILE_APPEND);
    
    // Si relation = 'self', vérifier que l'email correspond à l'utilisateur connecté
    if ($relationship === 'self') {
        if (!empty($applicantEmail) && $applicantEmail !== $currentUser['email']) {
            file_put_contents($debugFile, "ERREUR: Email ne correspond pas à l'utilisateur pour self\n", FILE_APPEND);
            return [
                'success' => false,
                'message' => 'Pour une auto-préinscription, l\'email doit correspondre à votre compte'
            ];
        }
        // Auto-remplir l'email de l'utilisateur
        $input['applicantEmail'] = $currentUser['email'];
    }
    
    // Si relation != 'self', vérifier qu'au moins email ou téléphone est fourni
    if ($relationship !== 'self') {
        if (empty($applicantEmail) && empty($applicantPhone)) {
            file_put_contents($debugFile, "ERREUR: Email ou téléphone requis pour préinscription tiers\n", FILE_APPEND);
            return [
                'success' => false,
                'message' => 'Email ou téléphone de la personne concerné est requis'
            ];
        }
    }
    
    return ['success' => true, 'data' => $input];
}

// 2. Modifier la partie POST request handling dans submit.php

// Remplacer la section existante de validation par :

// Récupérer automatiquement l'ID de l'utilisateur connecté
$currentUserId = getCurrentUserId();

if (!$currentUserId) {
    file_put_contents($debugFile, "ERREUR: Utilisateur non authentifié\n", FILE_APPEND);
    echo json_encode([
        'success' => false, 
        'message' => 'Utilisateur non authentifié'
    ]);
    exit;
}

file_put_contents($debugFile, "ID utilisateur connecté: $currentUserId\n", FILE_APPEND);

// Récupérer les informations complètes de l'utilisateur connecté
try {
    $stmt = $pdo->prepare("SELECT id, email, role FROM users WHERE id = ? AND deleted_at IS NULL");
    $stmt->execute([$currentUserId]);
    $currentUser = $stmt->fetch();
    
    if (!$currentUser) {
        file_put_contents($debugFile, "ERREUR: Utilisateur non trouvé\n", FILE_APPEND);
        echo json_encode([
            'success' => false, 
            'message' => 'Utilisateur non trouvé'
        ]);
        exit;
    }
    
    file_put_contents($debugFile, "Utilisateur trouvé: " . json_encode($currentUser) . "\n", FILE_APPEND);
    
} catch (Exception $e) {
    file_put_contents($debugFile, "ERREUR: " . $e->getMessage() . "\n", FILE_APPEND);
    echo json_encode([
        'success' => false, 
        'message' => 'Erreur lors de la récupération des informations utilisateur'
    ]);
    exit;
}

// Valider les données de préinscription
$validationResult = validatePreinscriptionData($input, $currentUser, $debugFile);
if (!$validationResult['success']) {
    echo json_encode($validationResult);
    exit;
}

$input = $validationResult['data'];

// 3. Mettre à jour la requête SQL INSERT pour inclure les nouveaux champs

// Dans la requête SQL, ajouter après student_id :
applicant_email,
applicant_phone,
relationship,

// Et dans les VALUES, ajouter après $currentUserId :
$input['applicantEmail'] ?? null,
$input['applicantPhone'] ?? null,
$input['relationship'] ?? 'self',

// 4. Mettre à jour la réponse JSON pour inclure les nouveaux champs

// Dans la réponse succès, ajouter :
'relationship' => $input['relationship'] ?? 'self',
'applicant_email' => $input['applicantEmail'] ?? null,
'applicant_phone' => $input['applicantPhone'] ?? null,

// 5. Créer un endpoint séparé pour traiter manuellement une préinscription

// Créer un nouveau fichier : process_preinscription.php
?>
