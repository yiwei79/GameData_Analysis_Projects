-- =====================================================
-- Delivery 1 KPIs - Database Schema
-- Game Analytics Pipeline
-- =====================================================
-- This schema is designed to be:
-- - Normalized (no data redundancy)
-- - Scalable (indexes on query-heavy columns)
-- - Efficient (proper foreign keys and constraints)
-- =====================================================

-- Table 1: Users
-- Stores player demographic information
-- Primary source for retention and demographic analysis
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender FLOAT NOT NULL COMMENT 'Stored as float (0-1) for flexibility',
    registration_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes for KPI queries
    INDEX idx_registration_date (registration_date),
    INDEX idx_country (country)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 2: Sessions
-- Tracks gameplay sessions for DAU/MAU and engagement metrics
CREATE TABLE sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME DEFAULT NULL,
    duration_seconds INT DEFAULT NULL COMMENT 'Calculated on session end',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes for efficient queries
    INDEX idx_user_id (user_id),
    INDEX idx_start_time (start_time),
    INDEX idx_user_start (user_id, start_time) COMMENT 'Composite index for retention queries'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 3: Items
-- Catalog of purchasable items (static reference data)
-- Matches Simulator's GetItem() method probabilities
CREATE TABLE items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 4: Purchases
-- Tracks in-game purchases for monetization KPIs (ARPU, ARPPU)
CREATE TABLE purchases (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    item_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL COMMENT 'Denormalized from items.price for historical accuracy',
    purchase_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes for monetization queries
    INDEX idx_user_id (user_id),
    INDEX idx_purchase_date (purchase_date),
    INDEX idx_session_id (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Populate Items Table
-- =====================================================
-- These items match the Simulator's GetItem() probabilities:
-- Item 1: 50% chance ($0.99)
-- Item 2: 25% chance ($4.99)
-- Item 3: 15% chance ($9.99)
-- Item 4: 1% chance ($19.99)
-- Item 5: 9% chance ($49.99)

INSERT INTO items (item_id, item_name, price, category) VALUES
(1, 'Bronze Pack', 0.99, 'starter'),
(2, 'Silver Pack', 4.99, 'standard'),
(3, 'Gold Pack', 9.99, 'premium'),
(4, 'Platinum Pack', 19.99, 'premium'),
(5, 'Diamond Pack', 49.99, 'exclusive');

-- =====================================================
-- Verification Queries
-- =====================================================
-- Run these after executing the schema to verify setup:

-- Check all tables exist
-- SHOW TABLES;

-- Verify items are populated
-- SELECT * FROM items;

-- Check table structure
-- DESCRIBE users;
-- DESCRIBE sessions;
-- DESCRIBE items;
-- DESCRIBE purchases;

-- Verify indexes exist
-- SHOW INDEX FROM users;
-- SHOW INDEX FROM sessions;
-- SHOW INDEX FROM purchases;
