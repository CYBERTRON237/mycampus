-- Fix encoding issues in preinscriptions table
UPDATE preinscriptions SET faculty = 'Faculté des Arts, Lettres et Sciences Humaines' WHERE faculty LIKE 'Facult?%';

-- Fix other potential encoding issues
UPDATE preinscriptions SET faculty = 'Faculté des Sciences' WHERE faculty LIKE 'Facult%Sciences%' AND faculty != 'Faculté des Sciences';

-- Verify the fix
SELECT DISTINCT faculty FROM preinscriptions ORDER BY faculty;
