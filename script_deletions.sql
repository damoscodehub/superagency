-- 1. Client
DELETE FROM "client" WHERE "id" > 15;


-- 2. Order
DELETE FROM "order" WHERE "id" > 15;


-- 4. order_entity
DELETE FROM "order_entity" WHERE "order_id" > 15;


-- order_status_applied
DELETE FROM "order_status_applied" WHERE "order_id" > 15;


-- 8.1 Payment record
DELETE FROM "payment"
WHERE "client_id" > 15;


-- Superentities Wonder Twins
DELETE FROM "superentity"
WHERE "id" IN (923,924);


-- Team Wonder Twins
DELETE FROM "team"
WHERE "name" = 'Wonder Twins';


-- Race "Exxorian"
DELETE FROM "race"
WHERE "name" = 'Exxorian';


-- Superpowers
DELETE FROM "superpower"
WHERE
    "id" > 232;

-- Entity-superpower (they have ON DELETE CASCADE)
DELETE FROM "entity_power"
WHERE "entity_id" IN (923,924);
