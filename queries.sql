/* IMPORTANT!:

For searching for available/unavailable superentities in "superentity_readable"
table, this conditions must be added to the WHERE statment respectively:
"status" = 'in'
"status" = 'out'

For searching for actual/former members in "entity_team_readable"
table, this conditions must be added to the WHERE statment respectively:
"member" = 'in'
"member" = 'out'

*/

-- Searching client (or potencial client)
SELECT * FROM "client"
WHERE
    "first_name" LIKE '%Harry%'
    OR "last_name" LIKE '%Kane%'
    OR "phone" = '+64-21-123-4568';


-- Client insertion
INSERT INTO "client" ("first_name", "last_name", "phone", "note")
VALUES ('Harry','Kane','+64-21-123-4568', NULL);


-- Order insertion
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


-- Adding a note to the new client
UPDATE "client"
SET "note" = 'Has mind blowing ideas'
WHERE "id" = 16;


-- Searching superentities by ID
SELECT * FROM "superentity_readable"
WHERE "id" = 661;


-- Searching for entity-team membership
SELECT *
FROM "entity_team_readable"
WHERE
    "known_as" LIKE '%Storm%'
    AND "team_name" = 'X-Men';


-- Linking requested superentities with their orders
INSERT INTO "order_entity" ("order_id","entity_id","requested")
VALUES
    (16,661,1);


-- Querying the superentities linked to specific orders
SELECT *
FROM "order_entity"
WHERE "order_id" = 16;


-- Analyze order to interpret its requirements
SELECT * FROM "order_readable"
WHERE "order_id" = 16;


-- Complex multiple order_entity linking
INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id", "assigned")
SELECT DISTINCT 16 AS "order_id","entity_id", 0 AS "assigned" -- From here to see values to be inserted
FROM (
-- From here to see entities values ↓
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


-- Linkig and assigning entities to orders
INSERT INTO "order_entity" ("order_id", "entity_id", "assigned")
VALUES
    (16, 918, 1);


-- Linking entities to orders as candidates
INSERT INTO "order_entity" ("order_id", "entity_id", "assigned")
VALUES
    (16, 918, 0),
    (16, 905, 0),
    (16, 916, 0);


-- Retrieving order-entities by specific orders
SELECT * FROM "order_entity_readable"
WHERE "order_id" = 16;


-- Retrieving powers of candidates of an order
SELECT * FROM "entity_power_readable"
WHERE "entity_id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 16
);


-- Retrieving aattributes of candidates of an order
SELECT * FROM "entity_attribute_readable"
WHERE "entity_id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 16
);


-- Querying superentities linked to an order
SELECT * FROM "superentity_readable"
WHERE "id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 16
);


-- Assign entities from candidates to order
UPDATE "order_entity"
SET "assigned" = 1
WHERE
    "order_id" = 16
    AND "entity_id" IN (905);


-- Setting or updating a fixed price of the order
UPDATE "order"
SET "fixed_price" = 10000
WHERE "id" = 16;


-- Inserting new status for an order
INSERT INTO "order_status_applied" ("order_id","status_id")
VALUES (16,3);


-- Recording payment
INSERT INTO "payment" ("client_id", "amount")
VALUES (16,10000);


-- Assignin team entities to orders
INSERT OR IGNORE INTO "order_entity" ("order_id","entity_id","requested","assigned")
SELECT 16 AS "order_id","entity_id",1 AS "requested",0 AS "assigned" -- From here to see values to be inserted
FROM "entity_team_readable"
WHERE "team_name" = 'Avengers'
ORDER BY "entity_id";


-- Querying superentities by partial matches on names
SELECT * FROM "superentity_readable"
WHERE
    "known_as" LIKE '%Jayna%'
    OR "full_name" LIKE '%Jayna%'
    OR "known_as" LIKE '%Zan%'
    OR "full_name" LIKE '%Zan%';


-- Superentity insertions via trigger
/*It handles leading and trailing whitespaces,
case inconsistencies, datatype inconsistencies,
and repeated records. */
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


-- ▼ SUPERENTITIES STEPPED AND REVIEWED INSERTIONS (WITH INBOX TABLES)

---------- ↓ █ SUPERENTITY █ ↓ ---------- (from here)
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


--Trimming "temp_superentity" strings
UPDATE "temp_superentity"
SET
    "known_as" = TRIM("known_as"),
    "full_name" = TRIM("full_name"),
    "gender" = TRIM("gender"),
    "race" = TRIM("race"),
    "publisher" = TRIM("publisher"),
    "status" = TRIM("status");


-- Deleting duplicates (trimmed nocase) in "temp_superentity" or in "superentity"
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



-- Checking for possible superentity partial matches by "known_as" or "full_name"
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


------ ↓ █ GENDER REVIEW █ ↓ ------ (query secuence from here)
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


-- Inserting into "gender" table the new gender from "temp_superentity"
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


-- Updating "temp_superentity"("gender") - Setting ID
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


------ ↓ █ RACE REVIEW █ ↓ ------ (query secuence from here)
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


-- Inserting into "race" table the new races from "temp_superentity"
INSERT OR IGNORE INTO "race" ("name") -- Ignore this line to just query.
SELECT DISTINCT "race" AS "new_races"
FROM "temp_superentity"
WHERE "race" IS NOT NULL
  AND "race" <> ''
  AND CAST("race" AS INTEGER) = 0
  AND "race" NOT IN (
    SELECT "name" COLLATE NOCASE FROM "race"
  );


-- Assigning id to "temp_superentity"."race" if match with existing "race"."name"
UPDATE "temp_superentity"
SET "race" = (
    SELECT "id" FROM "race"
    WHERE "race"."name" = "temp_superentity"."race" COLLATE NOCASE
)
WHERE EXISTS (
    SELECT 1 FROM "race"
    WHERE "race"."name" = "temp_superentity"."race" COLLATE NOCASE
);


------ ↓ █ PUBLISHER REVIEW █ ↓ ------ (query secuence from here)
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


-- Inserting into "publisher" table the new publishers from "temp_superentity"
INSERT OR IGNORE INTO "publisher" ("name") -- Ignore this line to just query.
SELECT "publisher"
FROM "temp_superentity"
WHERE "publisher" IS NOT NULL
    AND "publisher" <> ''
    AND CAST("publisher" AS INTEGER) = 0
    AND "publisher" NOT IN (
    SELECT "name" COLLATE NOCASE FROM "publisher"
  );


-- Assigning id to "temp_superentity"."publisher" if match with existing "publisher"."name"
UPDATE "temp_superentity"
SET "publisher" = (
    SELECT "id" FROM "publisher"
    WHERE "publisher"."name" = "temp_superentity"."publisher" COLLATE NOCASE
)
WHERE EXISTS (
    SELECT 1 FROM "publisher"
    WHERE "publisher"."name" = "temp_superentity"."publisher" COLLATE NOCASE
);


------ ↓ █ NEW SUPERENTITIES DUMPING █ ↓ ------
-- dumping via trigger of "superentity_readable" view ('in' as default avalilability status)
INSERT OR IGNORE INTO "superentity_readable"
SELECT *
FROM "temp_superentity";


-- Retrieving the new superentity records
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


------ ↓ █ ENTITY_POWER █ ↓ ------

-- Inserting into entity_power via VIEW and TRIGGER
INSERT OR IGNORE INTO "entity_power_readable" (
    "entity_id", "power_id", "power_name"
) VALUES
    (923, NULL, 'Animal morphing'),
    (924, NULL, 'Liquid water mimicry'),
    (924, NULL, 'Ice mimicry'),
    (924, NULL, 'Water vapor mimicry');


-- Retrieving new entities powers
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


-- ▼ ENTITY_POWER STEPPED AND REVIEWED INSERTIONS (WITH INBOX TABLES)

DROP TABLE IF EXISTS "temp_entity_power";

CREATE TABLE IF NOT EXISTS "temp_entity_power" (
    "entity_id" INTEGER DEFAULT NULL,
    "power_id" INTEGER DEFAULT NULL,
    "power_name" TEXT COLLATE NOCASE DEFAULT NULL,
    CHECK ("power_id" IS NOT NULL OR "power_name" IS NOT NULL)
);


-- Inserting powers to review into "temp_entity_power" table
INSERT OR IGNORE INTO "temp_entity_power" (
    "entity_id", "power_id", "power_name"
) VALUES
    (923, NULL, 'Animal morphing'),
    (924, NULL, 'Liquid water mimicry'),
    (924, NULL, 'Ice mimicry'),
    (924, NULL, 'Water vapor mimicry');

-- Trimming power name from inbox
UPDATE "temp_entity_power"
SET "power_name" = TRIM("power_name");


/* Checking whether the superpowers of the new entity are already identically
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


-- Dumping new "entity_power" relations from "temp_entity_power"
INSERT OR IGNORE INTO "entity_power" ("entity_id", "power_id")
SELECT "entity_id", "power_id"
FROM "temp_entity_power";


-- Retrieving new entity_power_readable ("entity_id" from "temp_superentity")
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


------ ↓ █ TEAM INSERTIONS █ ↓ ------

-- Insert into entity_team via VIEW and TRIGGER
INSERT INTO "entity_team_readable" ("entity_id", "team_name")
VALUES
    (923, 'Wonder Twins'),
    (924, 'Wonder Twins');

-- Retrieving new entity_team_readable ("entity_id" from "temp_superentity")
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


------ ↓ █ ATTRIBUTES INSERTION █ ↓ ------
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


-- Retrieving new entity_attribute_readable ("entity_id" from "temp_superentity")
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


-- █ SUPERENTITIES

-- superenty (by partial match of names).
SELECT * FROM "superentity_readable"
WHERE
    "known_as" LIKE '%Batman%'
    OR "known_as" LIKE '%Spiderman%'
    OR "known_as" LIKE '%Superman%'
    OR "known_as" LIKE '%Thor%'
ORDER BY
    "known_as" ASC,
    "full_name" ASC;


-- superenty (by id)
SELECT "known_as" FROM "superentity_readable"
WHERE "id" IN (
    SELECT "entity_id" FROM "order_entity"
    WHERE "order_id" IN (15,16)
);


-- superenty * (by MAX(id))
SELECT * FROM "superentity_readable" WHERE "id" = (
    SELECT MAX("id") FROM "superentity"
);


-- superentity_readable * (by superpower value)
SELECT * FROM "superentity_readable"
WHERE "id" IN (
    SELECT DISTINCT "entity_id"
    FROM "entity_power_readable"
    WHERE "entity_id" IN (
        SELECT "entity_id"
        FROM "entity_power_readable"
        WHERE "power_name" LIKE '%reality%'
            AND "status" = 'in' -- status
    )
);


-- Inserting entity_availability status
INSERT OR IGNORE INTO "entity_availability" ("entity_id", "status") VALUES
(1, 'in');


-- █ ENTITY_POWER

-- entity_power_readable * (by entity_id)
SELECT * FROM "entity_power_readable"
WHERE "power_name" LIKE "%reality%" -- by "name" LIKE
-- WHERE "entity_id" IN (428) -- by set of IDs
    AND "status" = 'in' -- status
ORDER BY "known_as" ASC;


-- powers of entities linked to specific orders
SELECT * FROM "entity_power_readable"
WHERE "entity_id" IN (
    SELECT "entity_id" FROM "order_entity"
    WHERE "order_id" IN (15,16)
);


-- entity_power_readable * (by order_id)
SELECT * FROM "entity_power_readable"
WHERE "entity_id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 10
);


-- entity_power_readable * (by entity_id with power_name partial match)
SELECT * FROM "entity_power_readable"
WHERE "entity_id" IN (
    SELECT "entity_id"
    FROM "entity_power_readable"
    WHERE "power_name" LIKE '%Time%'
);


-- █ SUPERPOWER

-- superpowers (by id of one superentity).
WITH "the_entity_id" AS (
    SELECT 351 -- insert id here
)
SELECT
    p."name" AS "super_power"
FROM "superpower" p
JOIN "entity_power" ep
    ON ep."power_id" = p."id"
JOIN "superentity_readable" er
    ON ep."entity_id" = er."id"
WHERE er."id" = (SELECT * FROM "the_entity_id");


-- superpowers (by id from knon_as LIKE)
SELECT
    p."name" AS "super_power"
FROM "superpower" p
JOIN "entity_power" ep
    ON ep."power_id" = p."id"
JOIN "superentity_readable" er
    ON ep."entity_id" = er."id"
WHERE
    er."id" IN (
        SELECT "id" FROM "superentity_readable"
        WHERE
            "known_as" LIKE '%Loki%'
            --OR "known_as" LIKE '%Eternity %'
            --OR "known_as" LIKE '%Mxyzptlk %'
);


-- █ TEAM

-- team (by superentity)
SELECT t."name" AS "team_name"
FROM "team" t
JOIN "entity_team" et
    ON t."id" = et."team_id"
WHERE "entity_id" = 579;


-- █ ENTITY_TEAM

-- For and by entity/team values
SELECT -- from the next columns comment out those that are wanted to be ignored ↓
    er."id" AS "entity_id",
    er."known_as" AS "entity_known_as",
    er."full_name" AS "entity_full_name",
    etr."team_id",
    etr."team_name",
    -- etr."member",
    -- er."gender" AS "entity_gender",
    -- er."race" AS "entity_race",
    -- er."publisher" AS "entity_publisher",
    er."morality_rating" AS "entity_morality_rating",
    er."status" AS "entity_status"
FROM "superentity_readable" er
JOIN "entity_team_readable" etr
    ON er."id" = etr."entity_id"
WHERE
    etr."member" = 'in'
    -- AND etr."team_name" LIKE "%X-men%" -- search by team name.
    AND etr."entity_id" IN (3, 18, 9, 31, 54, 808, 806) -- search by team id.
ORDER BY etr."team_name" ASC;
