<?php

// Fichier de configuration pour le module de gestion des utilisateurs

return [
    // Configuration des rôles et permissions
    'roles' => [
        'hierarchy' => [
            'superadmin' => 100,
            'admin_national' => 90,
            'admin_local' => 80,
            'leader' => 60,
            'teacher' => 40,
            'staff' => 30,
            'moderator' => 25,
            'alumni' => 20,
            'student' => 10,
            'guest' => 5
        ],
        'permissions' => [
            'superadmin' => ['*'], // Tous les droits
            'admin_national' => [
                'users.create', 'users.read', 'users.update', 'users.delete', 'users.manage_roles',
                'institutions.manage', 'system.all'
            ],
            'admin_local' => [
                'users.create', 'users.read', 'users.update',
                'institutions.read', 'institutions.manage'
            ],
            'leader' => [
                'users.read_students', 'users.update_limited', 'reports.read'
            ],
            'teacher' => [
                'users.read_students', 'content.create', 'content.read'
            ],
            'staff' => [
                'users.read_basic', 'reports.limited'
            ],
            'moderator' => [
                'users.read_basic', 'content.moderate', 'content.read'
            ],
            'alumni' => [
                'users.read_basic', 'content.create', 'content.read'
            ],
            'student' => [
                'users.read_self', 'content.read'
            ],
            'guest' => [
                'users.read_self'
            ]
        ]
    ],
    
    // Configuration de la pagination
    'pagination' => [
        'default_limit' => 20,
        'max_limit' => 100
    ],
    
    // Configuration des champs modifiables par rôle
    'editable_fields' => [
        'student' => ['first_name', 'last_name', 'phone', 'address', 'bio'],
        'teacher' => ['first_name', 'last_name', 'phone', 'address', 'bio', 'profile_photo_url'],
        'admin_local' => ['first_name', 'last_name', 'phone', 'email', 'address', 'account_status', 'is_active'],
        'admin_national' => ['*'], // Tous les champs
        'superadmin' => ['*'] // Tous les champs
    ],
    
    // Configuration des validations
    'validation' => [
        'password_min_length' => 8,
        'email_regex' => '/^[^\s@]+@[^\s@]+\.[^\s@]+$/',
        'phone_regex' => '/^[0-9\-\+\(\)\s]+$/',
        'name_min_length' => 2,
        'name_max_length' => 100
    ],
    
    // Configuration des notifications
    'notifications' => [
        'user_created' => true,
        'user_updated' => true,
        'user_deleted' => true,
        'role_assigned' => true
    ],
    
    // Configuration des logs d'audit
    'audit' => [
        'log_user_actions' => true,
        'log_role_changes' => true,
        'log_permission_changes' => true
    ]
];
?>
