-- Requête pour corriger l'ID de Marie Dupont de 2 à 3
UPDATE users SET id = 3 WHERE email = 'marie.dupont@email.com';

-- Ou si vous voulez que Marie Dupont ait l'ID 2 :
UPDATE users SET id = 2 WHERE email = 'marie.dupont@email.com';
