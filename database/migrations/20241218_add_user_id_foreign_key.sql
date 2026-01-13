-- Ajouter la contrainte de clé étrangère pour lier user_id à la table users
-- Cette requête crée une liaison entre les préinscriptions et les utilisateurs

-- D'abord, ajouter un index sur user_id pour optimiser les performances
ALTER TABLE `preinscriptions` 
ADD INDEX `idx_user_id_fk` (`user_id`);

-- Ensuite, ajouter la contrainte de clé étrangère
ALTER TABLE `preinscriptions` 
ADD CONSTRAINT `fk_preinscriptions_user_id` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;

-- Alternative pour vérifier (plus simple et sans information_schema)
SHOW CREATE TABLE `preinscriptions`;
