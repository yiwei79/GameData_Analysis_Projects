-- Database Schema for Game Analytics Pipeline
-- Delivery 1 KPIs - Clean, Normalized, and Scalable Design

CREATE DATABASE IF NOT EXISTS game_analytics;
USE game_analytics;

-- Users Table: Stores player demographic information
CREATE TABLE IF NOT EXISTS users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    age INT UNSIGNED NOT NULL,
    gender FLOAT NOT NULL COMMENT 'Stored as float (0-1) for flexibility',
    registration_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_registration_date (registration_date),
    INDEX idx_country (country)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sessions Table: Tracks gameplay sessions
CREATE TABLE IF NOT EXISTS sessions (
    session_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME DEFAULT NULL,
    duration_seconds INT UNSIGNED DEFAULT NULL COMMENT 'Calculated on session end',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_start_time (start_time),
    INDEX idx_user_start (user_id, start_time) COMMENT 'Composite index for retention queries'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Items Table: Catalog of purchasable items
CREATE TABLE IF NOT EXISTS items (
    item_id INT UNSIGNED PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Purchases Table: Tracks in-game purchases
CREATE TABLE IF NOT EXISTS purchases (
    purchase_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    item_id INT UNSIGNED NOT NULL,
    purchase_date DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL COMMENT 'Denormalized from items for historical accuracy',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    INDEX idx_user_id (user_id),
    INDEX idx_purchase_date (purchase_date),
    INDEX idx_session_id (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample items with prices
INSERT INTO items (item_id, item_name, price, category) VALUES
(1, 'Bronze Pack', 0.99, 'starter'),
(2, 'Silver Pack', 4.99, 'standard'),
(3, 'Gold Pack', 9.99, 'premium'),
(4, 'Platinum Pack', 19.99, 'premium'),
(5, 'Diamond Pack', 49.99, 'exclusive')
ON DUPLICATE KEY UPDATE
    item_name = VALUES(item_name),
    price = VALUES(price),
    category = VALUES(category);
