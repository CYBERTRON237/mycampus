<?php
// Script de test pour le formulaire complet d'étudiant
// Ce script teste si le backend enregistre correctement tous les champs

header('Content-Type: application/json');

// Données de test complètes pour le formulaire
$testData = [
    'id' => 1,
    // Informations personnelles
    'first_name' => 'Jean',
    'middle_name' => 'Pierre',
    'last_name' => 'Dupont',
    'email' => 'jean.dupont.test@email.com',
    'phone' => '+237 699 123 456',
    'address' => '123 Rue de la République',
    'city' => 'Yaoundé',
    'region' => 'Centre',
    'country' => 'Cameroun',
    'postal_code' => 'BP 12345',
    'place_of_birth' => 'Douala',
    'nationality' => 'Camerounaise',
    'bio' => 'Étudiant motivé en informatique',
    'matricule' => 'STU2024001',
    'gender' => 'male',
    'date_of_birth' => '2000-01-15',
    
    // Contact d'urgence
    'emergency_contact_name' => 'Marie Dupont',
    'emergency_contact_phone' => '+237 699 789 012',
    'emergency_contact_relationship' => 'Mère',
    
    // Statut du compte
    'account_status' => 'active',
    
    // Informations académiques
    'current_level' => 'licence2',
    'admission_type' => 'regular',
    'enrollment_date' => '2023-10-01',
    'expected_graduation_date' => '2026-07-31',
    'actual_graduation_date' => null,
    
    // Performance académique
    'gpa' => 3.75,
    'total_credits_required' => 180,
    'class_rank' => 15,
    'honors' => 'Mention Bien',
    'disciplinary_records' => null,
    
    // Bourse
    'scholarship_status' => 'partial',
    'scholarship_details' => 'Bourse d\'excellence académique 50%',
    
    // Thèse
    'graduation_thesis_title' => 'Système de gestion intelligent pour MyCampus',
    'thesis_supervisor' => 'Prof. Martin',
    'thesis_defense_date' => null,
];

echo json_encode([
    'success' => true,
    'message' => 'Données de test pour le formulaire complet',
    'data' => $testData
]);
?>
