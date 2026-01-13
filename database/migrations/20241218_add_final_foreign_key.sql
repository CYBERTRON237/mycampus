-- Ajouter la contrainte de clé étrangère finale
-- Le champ user_id est maintenant bigint UNSIGNED et l'index existe déjà

-- Ajouter la contrainte de clé étrangère
ALTER TABLE `preinscriptions` 
ADD CONSTRAINT `fk_preinscriptions_user_id` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;

-- Vérifier que tout est correct
SHOW CREATE TABLE `preinscriptions`;
