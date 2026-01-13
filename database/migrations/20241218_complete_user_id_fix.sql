-- Version complète qui gère les index et contraintes existants

-- 1. Supprimer l'index s'il existe déjà
DROP INDEX IF EXISTS `idx_user_id_fk` ON `preinscriptions`;

-- 2. Supprimer la contrainte de clé étrangère si elle existe déjà
ALTER TABLE `preinscriptions` 
DROP FOREIGN KEY IF EXISTS `fk_preinscriptions_user_id`;

-- 3. Modifier le type du champ user_id pour correspondre à users.id
ALTER TABLE `preinscriptions` 
MODIFY COLUMN `user_id` bigint UNSIGNED DEFAULT NULL COMMENT 'ID étudiant final - lié à la table users';

-- 4. Ajouter l'index optimisé
ALTER TABLE `preinscriptions` 
ADD INDEX `idx_user_id_fk` (`user_id`);

-- 5. Ajouter la contrainte de clé étrangère
ALTER TABLE `preinscriptions` 
ADD CONSTRAINT `fk_preinscriptions_user_id` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;

-- 6. Vérifier la structure
SHOW CREATE TABLE `preinscriptions`;
