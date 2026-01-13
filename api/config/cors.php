<?php

// Autoriser les requêtes depuis n'importe quelle origine. 
// Pour plus de sécurité en production, vous pourriez vouloir restreindre cela à des domaines spécifiques.
header("Access-Control-Allow-Origin: *");

// Autoriser les méthodes HTTP spécifiques qui peuvent être utilisées.
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

// Autoriser les en-têtes HTTP spécifiques qui peuvent être envoyés dans la requête.
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Gérer les requêtes "preflight" envoyées par le navigateur pour vérifier les permissions CORS.
// Si la méthode de la requête est OPTIONS, le script s'arrête ici après avoir envoyé les en-têtes.
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
