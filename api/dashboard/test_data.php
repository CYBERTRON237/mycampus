<?php
header('Content-Type: application/json');

// Données de test pour le dashboard admin
echo json_encode([
    'success' => true,
    'data' => [
        'total_users' => 1250,
        'students' => 1000,
        'teachers' => 200,
        'admins' => 50,
        'active_students' => 850,
        'active_teachers' => 180,
        'new_this_month' => 45,
        'growth_rate' => 12.5,
        
        'total' => 15,
        'new_this_month' => 2,
        'growth_rate' => 8.3,
        'top_institutions' => [
            ['id' => '1', 'name' => 'Université de Yaoundé I', 'count' => 5],
            ['id' => '2', 'name' => 'Université de Douala', 'count' => 4],
            ['id' => '3', 'name' => 'Université de Dschang', 'count' => 3],
            ['id' => '4', 'name' => 'Université de Buéa', 'count' => 2],
            ['id' => '5', 'name' => 'Université de Maroua', 'count' => 1]
        ],
        
        'total' => 50,
        'top_faculties' => [
            ['id' => '1', 'name' => 'Faculté des Sciences', 'count' => 15],
            ['id' => '2', 'name' => 'Faculté de Droit', 'count' => 12],
            ['id' => '3', 'name' => 'Faculté de Médecine', 'count' => 10],
            ['id' => '4', 'name' => 'Faculté des Lettres', 'count' => 8],
            ['id' => '5', 'name' => 'Faculté d\'Économie', 'count' => 5]
        ],
        
        'total' => 120,
        
        'total' => 80,
        
        'total' => 150,
        'active_courses' => 120,
        'new_this_month' => 8,
        'growth_rate' => 5.2,
        'top_programs' => [
            ['id' => '1', 'name' => 'Informatique', 'count' => 300],
            ['id' => '2', 'name' => 'Gestion', 'count' => 250],
            ['id' => '3', 'name' => 'Droit', 'count' => 200],
            ['id' => '4', 'name' => 'Médecine', 'count' => 150],
            ['id' => '5', 'name' => 'Sciences', 'count' => 100]
        ],
        
        'total' => 25,
        'active_opportunities' => 20,
        
        'recent_activities' => [
            [
                'id' => '1',
                'description' => 'Nouvel utilisateur: Jean Dupont',
                'created_at' => '2025-12-11 10:30:00'
            ],
            [
                'id' => '2',
                'description' => 'Nouvel utilisateur: Marie Curie',
                'created_at' => '2025-12-11 09:15:00'
            ],
            [
                'id' => '3',
                'description' => 'Nouvel utilisateur: Paul Martin',
                'created_at' => '2025-12-10 16:45:00'
            ],
            [
                'id' => '4',
                'description' => 'Nouvel utilisateur: Sophie Laurent',
                'created_at' => '2025-12-10 14:20:00'
            ],
            [
                'id' => '5',
                'description' => 'Nouvel utilisateur: Michel Bernard',
                'created_at' => '2025-12-09 11:30:00'
            ]
        ]
    ]
]);
?>
