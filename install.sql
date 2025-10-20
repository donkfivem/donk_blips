-- Donk Blips Database Installation
-- Run this SQL file in your database to create the required table

CREATE TABLE IF NOT EXISTS `donk_blips` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `x` FLOAT NOT NULL,
    `y` FLOAT NOT NULL,
    `z` FLOAT NOT NULL,
    `sprite` INT NOT NULL,
    `color` INT NOT NULL,
    `scale` FLOAT NOT NULL DEFAULT 0.8,
    `created_by` VARCHAR(50) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
