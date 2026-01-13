-- Corriger le type de données du champ user_id pour le rendre compatible
-- Le champ id dans la table users est probablement bigint UNSIGNED

-- 1. D'abord, modifier le type du champ user_id pour correspondre à users.id
ALTER TABLE `preinscriptions` 
MODIFY COLUMN `user_id` bigint UNSIGNED DEFAULT NULL COMMENT 'ID étudiant final - lié à la table users';

-- 2. Ensuite, ajouter l'index optimisé
ALTER TABLE `preinscriptions` 
ADD INDEX `idx_user_id_fk` (`user_id`);

-- 3. Enfin, ajouter la contrainte de clé étrangère
ALTER TABLE `preinscriptions` 
ADD CONSTRAINT `fk_preinscriptions_user_id` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;

-- 4. Vérifier la structure
SHOW CREATE TABLE `preinscriptions`;
