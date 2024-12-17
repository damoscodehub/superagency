-- database: superagency.db
.mode table
.output

-- 0.0 All items (except the system-generated ones)
SELECT
    ROW_NUMBER()
        OVER (ORDER BY type ASC, name ASC)
        AS "total_count", -- Total count over all rows
    name,
    type,
    ROW_NUMBER()
        OVER (PARTITION BY type ORDER BY name ASC)
        AS "type_count" -- Type-specific count
FROM
    sqlite_master
WHERE
    name NOT LIKE 'sqlite_%'
ORDER BY
    type ASC,
    name ASC;

-- 1.1 Searching client (or potencial client)
.schema "client" -- ed

SELECT * FROM "client";


SELECT * FROM "client"
WHERE
    "first_name" LIKE '%Harry%'
    OR "last_name" LIKE '%Kane%'
    OR "phone" = '+64-21-123-4568';


-- 1.2 Client insertion

INSERT INTO "client" ("first_name", "last_name", "phone", "note")
VALUES ('Harry','Kane','+64-21-123-4568', NULL);


-- 2.1 "Order" table schema and records
.schema "order" -- ed

SELECT * FROM "order";


-- 2.2 Order insertion
INSERT INTO "order" (
    /*"id",*/
    "client_id",
    "created_at",
    "title",
    "location",
    "description",
    "scheduled_start",
    "scheduled_end",
    "fixed_price"
)
VALUES (
    /*,*/ -- id
    16, -- client_id
    CURRENT_TIMESTAMP, -- created_at
    'Windstorm in the school', -- title
    'Auckland, New Zealand', -- location
    'Create a windstorm in his school to save him from the exam', -- description
    '2024-11-18 00:00:00', -- scheduled_start
    '2024-11-18 16:00:00', -- scheduled_end
    NULL -- fixed_price
);


-- 2.3 "order_after_insert_insert_order_status" trigger
.mode list
.headers off
.once output.sql


SELECT sql
FROM sqlite_master
WHERE name = 'order_after_insert_insert_order_status';


.mode table


-- 2.4
.schema "order_status"

SELECT * FROM "order_status";


-- "order_status_applied" table schema and records
.schema "order_status_applied" -- ed
SELECT * FROM "order_status_applied";


-- 2.5 "order_status_applied" table schema and records
.once output.sql
.schema "order_readable"

SELECT * FROM "order_readable";


-- 2.6 Adding a note to the new client
UPDATE "client"
SET "note" = 'Has mind blowing ideas'
WHERE "id" = 16;


-- 3.1
.once output.sql
.schema "entity_team_readable"

-- 3.2
SELECT *
FROM "entity_team_readable"
WHERE
    "known_as" LIKE '%Storm%'
    AND "team_name" = 'X-Men';


-- 3.3
.schema "entity_availability" -- ed
SELECT * FROM "entity_availability";


-- 3.4 Searching current availability
SELECT
    "entity_id",
    "status",
    MAX("datetime") AS "last_record_at"
FROM "entity_availability"
GROUP BY "entity_id";


-- 3.5 Searching current availability in all elements
.once output.txt
SELECT type, name, sql
FROM sqlite_master
WHERE
    sql LIKE '%MAX("datetime")%'
    || '% FROM "entity_availability"%';


-- 3.6
.schema "entity_team" -- ed
SELECT * FROM "entity_team";

-- 3.7
.schema "order_entity" -- ed
SELECT * FROM "order_entity";


-- 3.8
INSERT INTO "order_entity" ("order_id","entity_id","requested")
VALUES
    (16,661,1);


-- 3.9
SELECT *
FROM "order_entity"
WHERE "order_id" = 16;


-- 3.10
.schema "superentity" -- ed
SELECT * FROM "superentity";


-- 3.11 Searching for Storm (see morality_rating)
.once output.sql
.schema "superentity_readable"

SELECT * FROM "superentity_readable"
WHERE "id" = 661;


-- 3.12 Analyze order to interpret its requirements
SELECT * FROM "order_readable"
WHERE "order_id" = 16;


-- 4.1 order_entity insertion all entities from query
INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id", "assigned")
SELECT DISTINCT 16 AS "order_id","entity_id", 0 AS "assigned" -- From here to see values to be inserted
FROM (
-- 4.2 .once output.txt - From here to see entities values ↓
    SELECT
        er."id" AS "entity_id",
        er."known_as" AS "superentity",
        er."morality_rating",
        p."name" AS "superpower"
    FROM "superentity_readable" er
    JOIN "entity_power" ep
        ON ep."entity_id" = er."id"
    JOIN "superpower" p
        ON ep."power_id" = p."id"
    WHERE (
        p."name" LIKE '%wind%' -- by "name" LIKE
        OR p."name" LIKE '%weather%'
    )
    -- WHERE er."id" IN (428) -- by set of IDs
        AND er."status" = 'in' -- status
        AND er."morality_rating" <= 7
    ORDER BY er."known_as" ASC -- Up to here to see entities values ↑
)
ORDER BY "entity_id";


-- 4.3 EXAMPLE, DO NOT RUN - order_entity insertion assigned 1
INSERT INTO "order_entity" ("order_id", "entity_id", "assigned")
VALUES
    (16, 918, 1);

-- 4.4 order_entity insertion assigned 0
INSERT INTO "order_entity" ("order_id", "entity_id", "assigned")
VALUES
    (16, 918, 0),
    (16, 905, 0),
    (16, 916, 0);


-- 4.5 output candidates for order 16
.once output.sql
.schema "order_entity_readable"

SELECT * FROM "order_entity_readable"
WHERE "order_id" = 16;


-- 5.1 Analize candidates powers
.once output.sql
.schema "entity_power_readable"

SELECT * FROM "entity_power_readable"
WHERE "entity_id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 16
);


-- 5.2 Analize candidates attributes
.once output.sql
.schema "entity_attribute_readable"

SELECT * FROM "entity_attribute_readable"
WHERE "entity_id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 16
);


-- 5.3 Analize other data from candidates, like gender or race
SELECT * FROM "superentity_readable"
WHERE "id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 16
);


-- 6.1 Assign entities from candidates to order
UPDATE "order_entity"
SET "assigned" = 1
WHERE
    "order_id" = 16
    AND "entity_id" IN (905);


-- 7.1 Set or update a fixed price of the order
UPDATE "order"
SET "fixed_price" = 10000
WHERE "id" = 16;


-- 7.2 Display "order_readable"
SELECT * FROM "order_readable"
WHERE "order_id" = 16;


-- 7.3 Insert status 3 "client_to_confirm"
INSERT INTO "order_status_applied" ("order_id","status_id")
VALUES (16,3);


-- 8.1 Payment record
INSERT INTO "payment" ("client_id", "amount")
VALUES (16,10000);


-- 8.2 Payment balance
.once output.sql
.schema "client_full"

SELECT * FROM "client_full";


-- 8.3
SELECT * FROM "client_full"
WHERE "id" = 16;


-- 8.4 Insert status 4 "confirmed"
INSERT INTO "order_status_applied" ("order_id","status_id")
VALUES (16,4);


-- 9.1 Insert status 5 "ongoing"
INSERT INTO "order_status_applied" ("order_id","status_id")
VALUES (16,5);


-- 9.2 If fails Insert status 6 "failed"
INSERT INTO "order_status_applied" ("order_id","status_id")
VALUES (16,6);


-- To cancel Insert status 1 "cancelled"
INSERT INTO "order_status_applied" ("order_id","status_id")
VALUES (16,1);


-- 9.3 If succesfully acomplished Insert status 2 "succeded"
INSERT INTO "order_status_applied" ("order_id","status_id")
VALUES (16,7);


-- 10 Punctuality
.once output.sql
.schema "punctuality"

SELECT * FROM "punctuality";


-- 11.0 teams (elements)
SELECT name, type
FROM sqlite_master
WHERE
    name LIKE '%team%'
    AND name NOT LIKE 'sqlite_%'
ORDER BY type, name;


-- 11.1 team table
.schema "team" -- ed

SELECT * FROM "team";


-- 11.2 entity_team table
.schema "entity_team" -- ed

SELECT * FROM "entity_team";


-- 11.3 entity_team_readable view
.output output.sql
.schema "entity_team_readable"

SELECT * FROM "entity_team_readable";


-- 11.4 Assign team entities to orders
INSERT OR IGNORE INTO "order_entity" ("order_id","entity_id","requested","assigned")
SELECT 16 AS "order_id","entity_id",1 AS "requested",0 AS "assigned" -- From here to see values to be inserted
FROM "entity_team_readable"
WHERE "team_name" = 'Avengers'
ORDER BY "entity_id";


-- 12.1 Searching for Wonder Twins
SELECT * FROM "superentity_readable"
WHERE
    "known_as" LIKE '%Jayna%'
    OR "full_name" LIKE '%Jayna%'
    OR "known_as" LIKE '%Zan%'
    OR "full_name" LIKE '%Zan%';


-- 12.2 EXAMPLE, DO NOT RUN - New entities basic insertions
INSERT INTO "superentity" (
    /*"id", */
    "known_as",
    "full_name",
    "gender_id",
    "race_id",
    "publisher_id",
    "morality_rating"
)
VALUES
    ('Jayna', 'Jayna', '...'),
    ('Zan', 'Zan', '...');


-- 13.1 Output sql of "superentity_r_instead_insert_insert_superentity" trigger
.mode list
.headers off
.once output.sql

SELECT sql
FROM sqlite_master
WHERE name = 'superentity_r_instead_insert_insert_superentity';

.mode table


-- 13.2 race table
.schema "race"

SELECT * FROM "race";


-- 13.3 Search for Exxorian and High Evolutionary
SELECT * FROM "race"
WHERE "name" LIKE '%Exxorian%';


SELECT * FROM "superentity_readable"
WHERE "known_as" LIKE '%Evolutionary%';


-- 13.4 Superentity insertions via trigger (avoid SQLite editor, use output on pannel 2)
BEGIN;
INSERT OR IGNORE INTO "superentity_readable" (
    /*"id",*/
    "known_as",
    "full_name",
    "gender",
    "race",
    "publisher",
    "morality_rating"
)
VALUES
    ('Jayna', 'Jayna', ' Female ', 'Exxorian', 4, 9),
    (' Zan ', ' Zan ', 1, ' Exxorian ', ' DC COMICS ', 9),
    (' The High EVOLUTIONARY','Herbert WYNDHAM',1,13,13,6);


-- 13.5 Check the inserted data
.mode list
.headers on
.once output.txt

SELECT * FROM (
    SELECT * FROM "superentity_readable"
    ORDER BY "id" DESC LIMIT 3
)
ORDER BY "id" ASC;


-- 14.1
ROLLBACK;


-- 15.1 SUPERENTITIES STEPPED AND REVIEWED INSERTIONS.

---------- █ SUPERENTITY █ ----------
BEGIN;

DROP TABLE IF EXISTS "temp_superentity";

CREATE TABLE IF NOT EXISTS "temp_superentity" (
    "id" INTEGER DEFAULT NULL UNIQUE,
    "known_as" TEXT COLLATE NOCASE NOT NULL,
    "full_name" TEXT COLLATE NOCASE DEFAULT NULL,
    "gender" TEXT COLLATE NOCASE DEFAULT NULL,
    "race" TEXT COLLATE NOCASE DEFAULT NULL,
    "publisher" TEXT COLLATE NOCASE DEFAULT NULL,
    "morality_rating" INTEGER CHECK ("morality_rating" BETWEEN 1 AND 10) DEFAULT NULL,
    "status" TEXT COLLATE NOCASE CHECK ("status" IN ('in','out')) DEFAULT 'in'
);

INSERT INTO "temp_superentity" (
    "known_as", "full_name", "gender", "race", "publisher", "morality_rating", "status"
) VALUES
    ('Jayna', 'Jayna', ' Female ', 'Exxorian', 4, 9, 'in'),
    (' Zan ', ' Zan ', 1, ' Exxorian ', ' DC COMICS ', 9, 'in'),
    (' The High EVOLUTIONARY','Herbert WYNDHAM',1,13,13,6, 'in');


--TRIM "temp_superentity"
UPDATE "temp_superentity"
SET
    "known_as" = TRIM("known_as"),
    "full_name" = TRIM("full_name"),
    "gender" = TRIM("gender"),
    "race" = TRIM("race"),
    "publisher" = TRIM("publisher"),
    "status" = TRIM("status");


-- Delete duplicated (trimmed nocase) in "temp_superentity" or in "superentity"
WITH CTE AS (
    SELECT
        ROWID AS rowid,
        ROW_NUMBER() OVER (
            PARTITION BY
                "known_as" COLLATE NOCASE,
                "full_name" COLLATE NOCASE,
                "publisher" COLLATE NOCASE
        ) AS rn
    FROM "temp_superentity"
)
DELETE FROM "temp_superentity"
WHERE
    ROWID IN (SELECT rowid FROM CTE WHERE rn > 1)
    OR EXISTS (
        SELECT 1
        FROM "superentity"
        WHERE
            "temp_superentity"."known_as" = "superentity"."known_as" COLLATE NOCASE
            AND "temp_superentity"."full_name" = "superentity"."full_name" COLLATE NOCASE
            AND "temp_superentity"."publisher" = "superentity"."publisher_id" COLLATE NOCASE
    );


-- Output "temp_superentity" with rowid
.mode list
.headers on
.output output.txt

SELECT rowid, * FROM "temp_superentity";


-- Check for possible superentity matches by "known_as" or "full_name"
.mode table

SELECT DISTINCT sr.*
FROM "superentity_readable" sr
JOIN "temp_superentity" ts
  ON sr."known_as" LIKE '%' || ts."known_as" || '%'

UNION

SELECT DISTINCT sr.*
FROM "superentity_readable" sr
JOIN "temp_superentity" ts
  ON sr."full_name" LIKE '%' || ts."full_name" || '%'

ORDER BY sr."known_as" ASC;


---------- █ GENDER REVIEW █ ----------
SELECT
    ts.rowid AS "temp_rowid",
    ts."id" AS "temp_id",
    ts."known_as" AS "temp_known_as",
    ts."gender" AS "temp_gender",
    COALESCE(g."id", '(no-match)') AS "gender_id",
    COALESCE(g."name", '(no-match)') AS "gender_name"
FROM
    "temp_superentity" ts
LEFT JOIN "gender" g
    ON (
        CASE
            WHEN CAST(ts."gender" AS INTEGER) != 0
                THEN g."id" = CAST(ts."gender" AS INTEGER)
            ELSE g."name" LIKE '%' || ts."gender" || '%'
        END
    )
WHERE ts."gender" IS NOT NULL
ORDER BY temp_rowid;


-- INSERT INTO "gender" table the new gender from "temp_superentity"
INSERT OR IGNORE INTO "gender" ("name") -- Ignore this line to just query.
SELECT DISTINCT "gender" AS "new_gender"
FROM "temp_superentity"
WHERE
    "gender" IS NOT NULL
    AND "gender" != ''
    AND CAST("gender" AS INTEGER) = 0
    AND "gender" NOT IN (
        SELECT "name" COLLATE NOCASE FROM "gender"
    );


-- UPDATE "temp_superentity"("gender") - SET ID
UPDATE "temp_superentity"
SET "gender" = (
    SELECT "id"
    FROM "gender"
    WHERE "gender"."name" = "temp_superentity"."gender" COLLATE NOCASE
)
WHERE EXISTS (
    SELECT 1 FROM "gender"
    WHERE "gender"."name" = "temp_superentity"."gender" COLLATE NOCASE
);


-- Output "temp_superentity"
SELECT rowid, * FROM "temp_superentity";


-------- █ RACE REVIEW █ --------
SELECT
    ts.rowid AS "temp_rowid",
    ts."id" AS "temp_id",
    ts."known_as" AS "temp_known_as",
    ts."race" AS "temp_race",
    COALESCE(r."id", '(no-match)') AS "race_id",
    COALESCE(r."name", '(no-match)') AS "race_name"
FROM "temp_superentity" ts
LEFT JOIN "race" r
    ON (
        CASE
            WHEN CAST(ts."race" AS INTEGER) != 0
                THEN r."id" = CAST(ts."race" AS INTEGER)
            ELSE r."name" LIKE '%' || ts."race" || '%'
        END
    )
WHERE ts."race" IS NOT NULL
ORDER BY ts.rowid ASC;


-- INSERT INTO "race" table the new races from "temp_superentity"
INSERT OR IGNORE INTO "race" ("name") -- Ignore this line to just query.
SELECT DISTINCT "race" AS "new_races"
FROM "temp_superentity"
WHERE "race" IS NOT NULL
  AND "race" <> ''
  AND CAST("race" AS INTEGER) = 0
  AND "race" NOT IN (
    SELECT "name" COLLATE NOCASE FROM "race"
  );


-- Assign id to "temp_superentity"."race" if match with existing "race"."name"
UPDATE "temp_superentity"
SET "race" = (
    SELECT "id" FROM "race"
    WHERE "race"."name" = "temp_superentity"."race" COLLATE NOCASE
)
WHERE EXISTS (
    SELECT 1 FROM "race"
    WHERE "race"."name" = "temp_superentity"."race" COLLATE NOCASE
);


-- Output "temp_superentity"
SELECT rowid, * FROM "temp_superentity";


-------- █ PUBLISHER REVIEW █ --------
SELECT
    ts.rowid AS "temp_rowid",
    ts."id" AS "temp_id",
    ts."known_as" AS "temp_known_as",
    ts."publisher" AS "temp_publisher",
    COALESCE(p."id", '(no-match)') AS "publisher_id",
    COALESCE(p."name", '(no-match)') AS "publisher_name"
FROM "temp_superentity" ts
LEFT JOIN "publisher" p
    ON (
        CASE
            WHEN CAST(ts."publisher" AS INTEGER) != 0
                THEN p."id" = CAST(ts."publisher" AS INTEGER)
            ELSE p."name" LIKE '%' || ts."publisher" || '%'
        END
    )
WHERE ts."publisher" IS NOT NULL
ORDER BY ts.rowid ASC;


-- INSERT INTO "publisher" table the new publishers from "temp_superentity"
INSERT OR IGNORE INTO "publisher" ("name") -- Ignore this line to just query.
SELECT "publisher"
FROM "temp_superentity"
WHERE "publisher" IS NOT NULL
    AND "publisher" <> ''
    AND CAST("publisher" AS INTEGER) = 0
    AND "publisher" NOT IN (
    SELECT "name" COLLATE NOCASE FROM "publisher"
  );


-- Assign id to "temp_superentity"."publisher" if match with existing "publisher"."name"
UPDATE "temp_superentity"
SET "publisher" = (
    SELECT "id" FROM "publisher"
    WHERE "publisher"."name" = "temp_superentity"."publisher" COLLATE NOCASE
)
WHERE EXISTS (
    SELECT 1 FROM "publisher"
    WHERE "publisher"."name" = "temp_superentity"."publisher" COLLATE NOCASE
);


-- Output "temp_superentity"
SELECT rowid, * FROM "temp_superentity";


-------- █ NEW SUPERENTITIES DUMPING █ --------

-- dump via trigger of "superentity_readable" view ('in' as default avalilability status)
INSERT OR IGNORE INTO "superentity_readable"
SELECT *
FROM "temp_superentity";


-- Output the new superentity records
SELECT s.*
FROM "superentity" s
JOIN "temp_superentity" ts
    ON (
        (s."known_as" = ts."known_as" COLLATE NOCASE
            OR (s."known_as" IS NULL AND ts."known_as" IS NULL))
        AND (s."full_name" = ts."full_name" COLLATE NOCASE
            OR (s."full_name" IS NULL AND ts."full_name" IS NULL))
        AND (
            s."publisher_id" = ts."publisher"
                OR (s."publisher_id" IS NULL AND ts."publisher" IS NULL)
                OR s."publisher_id" = (
                    SELECT "id" FROM "publisher"
                    WHERE "name" = ts."publisher" COLLATE NOCASE
            )
        )
    )
ORDER BY ts.rowid;


-------- █ ENTITY_POWER █ --------

-- 16.1 Insert into entity_power via VIEW and TRIGGER
.mode list
.headers off
.once output.sql

SELECT sql
FROM sqlite_master
WHERE name = "ent_pow_r_instead_insert_insert_ent_pow";

.mode table


INSERT OR IGNORE INTO "entity_power_readable" (
    "entity_id", "power_id", "power_name"
) VALUES
    (923, NULL, 'Animal morphing'),
    (924, NULL, 'Liquid water mimicry'),
    (924, NULL, 'Ice mimicry'),
    (924, NULL, 'Water vapor mimicry');


-- Output new entities powers
.once output.txt

SELECT * FROM "entity_power_readable"
WHERE "entity_id" IN (
    SELECT s."id"
    FROM "superentity" s
    JOIN "temp_superentity" ts
        ON (
            (s."known_as" = ts."known_as" COLLATE NOCASE
                OR (s."known_as" IS NULL AND ts."known_as" IS NULL))
            AND (s."full_name" = ts."full_name" COLLATE NOCASE
                OR (s."full_name" IS NULL AND ts."full_name" IS NULL))
            AND (
                s."publisher_id" = ts."publisher"
                    OR (s."publisher_id" IS NULL AND ts."publisher" IS NULL)
                    OR s."publisher_id" = (
                        SELECT "id" FROM "publisher"
                        WHERE "name" = ts."publisher" COLLATE NOCASE
                )
            )
        )
ORDER BY ts.rowid
);


-- 16.2 Insert into entity_power via inbox table.
DROP TABLE IF EXISTS "temp_entity_power";

CREATE TABLE IF NOT EXISTS "temp_entity_power" (
    "entity_id" INTEGER DEFAULT NULL,
    "power_id" INTEGER DEFAULT NULL,
    "power_name" TEXT COLLATE NOCASE DEFAULT NULL,
    CHECK ("power_id" IS NOT NULL OR "power_name" IS NOT NULL)
);


-- Insert powers to review into "temp_entity_power" table
INSERT OR IGNORE INTO "temp_entity_power" (
    "entity_id", "power_id", "power_name"
) VALUES
    (923, NULL, 'Animal morphing'),
    (924, NULL, 'Liquid water mimicry'),
    (924, NULL, 'Ice mimicry'),
    (924, NULL, 'Water vapor mimicry');

--
UPDATE "temp_entity_power"
SET "power_name" = TRIM("power_name");


.output output.txt

SELECT rowid, *
FROM "temp_entity_power";


/* Check whether the superpowers of the new entity are already identically
present in the "superpowers" table, under different names, or are new.*/
SELECT DISTINCT "power_name"
FROM "temp_entity_power"
WHERE
    "power_name" NOT NULL
    AND "power_name" != ''
    AND "power_name" NOT IN (
        SELECT "name" COLLATE NOCASE FROM "superpower"
    );


-- Dump the new superpowers into "superpower" table
INSERT OR IGNORE INTO "superpower" ("name") -- Ignore this line to just query.
SELECT DISTINCT "power_name"
FROM "temp_entity_power"
WHERE
    "power_name" NOT NULL
    AND "power_name" != ''
    AND "power_name" NOT IN (
        SELECT "name" COLLATE NOCASE FROM "superpower"
    );


-- Auto-complete "temp_entity_power"."power_id"
UPDATE "temp_entity_power"
SET "power_id" = (
    SELECT "id" FROM "superpower"
    WHERE "superpower"."name"
        = "temp_entity_power"."power_name" COLLATE NOCASE
    )
WHERE EXISTS (
    SELECT "id" FROM "superpower"
    WHERE "superpower"."name"
        = "temp_entity_power"."power_name" COLLATE NOCASE
);


-- Auto-complete "temp_entity_power"."power_name"
UPDATE "temp_entity_power"
SET "power_name" = (
    SELECT "name" FROM "superpower"
    WHERE "superpower"."id" = "temp_entity_power"."power_id"
)
WHERE EXISTS (
    SELECT "name" FROM "superpower"
    WHERE "superpower"."id" = "temp_entity_power"."power_id"
);


-- Output "temp_entity_power"
SELECT rowid,*
FROM "temp_entity_power";


-- Dump new "entity_power" relations from "temp_entity_power"
INSERT OR IGNORE INTO "entity_power" ("entity_id", "power_id")
SELECT "entity_id", "power_id"
FROM "temp_entity_power";


-- Output new entity_power_readable ("entity_id" from "temp_superentity")
SELECT * FROM "entity_power_readable"
WHERE "entity_id" IN (
    SELECT s."id"
    FROM "superentity" s
    JOIN "temp_superentity" ts
        ON (
            (s."known_as" = ts."known_as" COLLATE NOCASE
                OR (s."known_as" IS NULL AND ts."known_as" IS NULL))
            AND (s."full_name" = ts."full_name" COLLATE NOCASE
                OR (s."full_name" IS NULL AND ts."full_name" IS NULL))
            AND (
                s."publisher_id" = ts."publisher"
                    OR (s."publisher_id" IS NULL AND ts."publisher" IS NULL)
                    OR s."publisher_id" = (
                        SELECT "id" FROM "publisher"
                        WHERE "name" = ts."publisher" COLLATE NOCASE
                )
            )
        )
ORDER BY ts.rowid
);


-- 16.2
SELECT "entity_known_as", "power_id", "power_name"
FROM "entity_power_readable"
WHERE "entity_known_as" = 'Silver Surfer';



--------█ TEAM █-------

-- 17.1 Insert into entity_team via VIEW and TRIGGER
.mode list
.headers off
.once output.sql

SELECT sql
FROM sqlite_master
WHERE name = "ent_team_r_instead_insert_insert_ent_team";

.mode table


INSERT INTO "entity_team_readable" ("entity_id", "team_name")
VALUES
    (923, 'Wonder Twins'),
    (924, 'Wonder Twins');

-- Output new entity_team_readable ("entity_id" from "temp_superentity")
.output output.txt

SELECT * FROM "entity_team_readable"
WHERE "entity_id" IN (
    SELECT s."id"
    FROM "superentity" s
    JOIN "temp_superentity" ts
        ON (
            (s."known_as" = ts."known_as" COLLATE NOCASE
                OR (s."known_as" IS NULL AND ts."known_as" IS NULL))
            AND (s."full_name" = ts."full_name" COLLATE NOCASE
                OR (s."full_name" IS NULL AND ts."full_name" IS NULL))
            AND (
                s."publisher_id" = ts."publisher"
                    OR (s."publisher_id" IS NULL AND ts."publisher" IS NULL)
                    OR s."publisher_id" = (
                        SELECT "id" FROM "publisher"
                        WHERE "name" = ts."publisher" COLLATE NOCASE
                )
            )
        )
ORDER BY ts.rowid
);


-- 18.1
--------█ ATTRIBUTES █-------

INSERT OR IGNORE INTO "entity_attribute" (
    "entity_id", "attribute_id", "attribute_value"
)
VALUES
-- Jayna
(923, 1, 65),  -- Intelligence: Above average but not at Batman/Riddler level
(923, 2, 40),  -- Strength: Enhanced in animal forms but not Thor/Superman level
(923, 3, 45),  -- Speed: Good mobility especially in animal forms
(923, 4, 45),  -- Durability: Decent protection in transformed states
(923, 5, 50),  -- Power: Significant due to shapeshifting abilities
(923, 6, 40),  -- Combat: Trained but not extensively
-- Zan
(924, 1, 65),  -- Intelligence: Similar to his twin
(924, 2, 35),  -- Strength: Slightly lower than Jayna, varies with water forms
(924, 3, 50),  -- Speed: Good mobility in water/vapor forms
(924, 4, 40),  -- Durability: Can be vulnerable in water form
(924, 5, 50),  -- Power: Significant due to water transformation
(924, 6, 40);  -- Combat: Similar training to Jayna


-- Output new entity_attribute_readable ("entity_id" from "temp_superentity")
SELECT * FROM "entity_attribute_readable"
WHERE "entity_id" IN (
    SELECT s."id"
    FROM "superentity" s
    JOIN "temp_superentity" ts
        ON (
            (s."known_as" = ts."known_as" COLLATE NOCASE
                OR (s."known_as" IS NULL AND ts."known_as" IS NULL))
            AND (s."full_name" = ts."full_name" COLLATE NOCASE
                OR (s."full_name" IS NULL AND ts."full_name" IS NULL))
            AND (
                s."publisher_id" = ts."publisher"
                    OR (s."publisher_id" IS NULL AND ts."publisher" IS NULL)
                    OR s."publisher_id" = (
                        SELECT "id" FROM "publisher"
                        WHERE "name" = ts."publisher" COLLATE NOCASE
                )
            )
        )
ORDER BY ts.rowid
);


-- 19.1 Superentities with mind control power
.output output.txt

SELECT * FROM "superentity_readable"
WHERE
    "id" IN (
        SELECT "entity_id" FROM "entity_power_readable"
        WHERE "power_name" = 'Mind control'
    )
    AND "status" = 'in'
ORDER BY "id" ASC;
