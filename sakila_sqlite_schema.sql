
-- Partial SQLite Conversion of Sakila Schema (example: actor table only)
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS actor;
CREATE TABLE actor (
  actor_id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  last_update DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes manually as needed:
CREATE INDEX idx_actor_last_name ON actor (last_name);

PRAGMA foreign_keys = ON;
