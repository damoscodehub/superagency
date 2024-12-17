PRAGMA foreign_keys = OFF;
BEGIN;

-- Stores publishers (companies or firms that published the comics or productions where superentities are from)
CREATE TABLE IF NOT EXISTS "publisher" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" TEXT NOT NULL COLLATE NOCASE UNIQUE
);

-- Stores superentities' races
CREATE TABLE IF NOT EXISTS "race" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" TEXT NOT NULL COLLATE NOCASE UNIQUE
);

-- Stores the superentities' genders
CREATE TABLE IF NOT EXISTS "gender" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" TEXT COLLATE NOCASE NOT NULL UNIQUE
);

-- Stores the superentities along with some of their main additional data
CREATE TABLE IF NOT EXISTS "superentity" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "known_as" TEXT COLLATE NOCASE NOT NULL,
    "full_name" TEXT COLLATE NOCASE NOT NULL DEFAULT '-',
    "gender_id" INTEGER DEFAULT NULL,
    "race_id" INTEGER DEFAULT NULL,
    "publisher_id" INTEGER NOT NULL DEFAULT 1,
    "morality_rating" INTEGER CHECK ("morality_rating" BETWEEN 1 AND 10) DEFAULT NULL,
    UNIQUE ("known_as", "full_name", "publisher_id"),
    CONSTRAINT fk_sup_gen FOREIGN KEY ("gender_id") REFERENCES "gender"("id"),
    CONSTRAINT fk_sup_pub FOREIGN KEY ("publisher_id") REFERENCES "publisher"("id"),
    CONSTRAINT fk_sup_race FOREIGN KEY ("race_id") REFERENCES "race"("id")
);

-- Tracks the availability status of entities over time
CREATE TABLE IF NOT EXISTS "entity_availability" (
    "entity_id" INTEGER NOT NULL,
    "status" TEXT COLLATE NOCASE NOT NULL DEFAULT 'in' CHECK ("status" IN ('in','out')),
    "datetime" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("entity_id", "datetime"),
    CONSTRAINT fk_enav_ent FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
);

-- Stores fixed attributes. Every superentity has a value of each attribute (stablished in "entity_attribute")
CREATE TABLE IF NOT EXISTS "attribute" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" TEXT NOT NULL COLLATE NOCASE UNIQUE
);

-- Stores fixed attribute values for superentities, with a range of 1 to 100.
CREATE TABLE IF NOT EXISTS "entity_attribute" (
    "entity_id" INTEGER NOT NULL,
    "attribute_id" INTEGER NOT NULL,
    "attribute_value" INTEGER NOT NULL CHECK ("attribute_value" BETWEEN 1 AND 100),
    PRIMARY KEY ("entity_id", "attribute_id"),
    CONSTRAINT fk_eat_at FOREIGN KEY (attribute_id) REFERENCES "attribute" (id) ON DELETE CASCADE,
    CONSTRAINT fk_eat_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id) ON DELETE CASCADE
);

-- Stores superpowers. They are linked to superentities in "entity_power" table
CREATE TABLE IF NOT EXISTS "superpower" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" TEXT COLLATE NOCASE NOT NULL UNIQUE
);

-- Links superentities to their powers
CREATE TABLE IF NOT EXISTS "entity_power" (
    "entity_id" INTEGER NOT NULL,
    "power_id" INTEGER NOT NULL,
    PRIMARY KEY ("entity_id", "power_id"),
    CONSTRAINT fk_epo_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id) ON DELETE CASCADE,
    CONSTRAINT fk_epo_po FOREIGN KEY (power_id) REFERENCES "superpower" (id) ON DELETE CASCADE
);

-- Store teams. The superentities' teams memberships are stablished in "entity_team" table
CREATE TABLE IF NOT EXISTS "team" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "name" TEXT COLLATE NOCASE NOT NULL UNIQUE
);

-- Stores the relationship between entities and teams, tracking membership status ('in' or 'out') over time.
CREATE TABLE IF NOT EXISTS "entity_team" (
    "entity_id" INTEGER NOT NULL,
    "team_id" INTEGER NOT NULL,
    "member" TEXT COLLATE NOCASE NOT NULL DEFAULT 'in' CHECK ("member" IN ('in','out')),
    "datetime" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("entity_id", "team_id", "datetime"),
    CONSTRAINT fk_et_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE,
    CONSTRAINT fk_et_team FOREIGN KEY ("team_id") REFERENCES "team"("id") ON DELETE CASCADE
);

-- Store clients main data
CREATE TABLE IF NOT EXISTS "client" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "first_name" TEXT COLLATE NOCASE NOT NULL,
    "last_name" TEXT COLLATE NOCASE NOT NULL,
    "phone" TEXT COLLATE NOCASE NOT NULL UNIQUE,
    "note" TEXT COLLATE NOCASE DEFAULT NULL
);

-- Table for storing orders, including details about the client, schedule, and pricing.
CREATE TABLE IF NOT EXISTS "order" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "client_id" INTEGER NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "title" TEXT COLLATE NOCASE NOT NULL,
    "location" TEXT COLLATE NOCASE NOT NULL,
    "description" TEXT COLLATE NOCASE NOT NULL,
    "scheduled_start" DATETIME NOT NULL,
    "scheduled_end" DATETIME DEFAULT NULL,
    "fixed_price" INTEGER DEFAULT NULL,
    CHECK ("scheduled_end" IS NULL OR "scheduled_end" >= "scheduled_start"),
    CONSTRAINT fk_order_client FOREIGN KEY ("client_id") REFERENCES "client"("id") ON DELETE CASCADE
);

-- Stores possible order statuses. They are linked to orders in "order_status_applied"
CREATE TABLE IF NOT EXISTS "order_status" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "label" TEXT COLLATE NOCASE NOT NULL UNIQUE
);

-- Tracks the order's status over time
CREATE TABLE IF NOT EXISTS "order_status_applied" (
    "order_id" INTEGER NOT NULL,
    "status_id" INTEGER NOT NULL,
    "datetime" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("order_id", "datetime"),
    CONSTRAINT fk_order_status_applied_order FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT fk_order_status_applied_order_status FOREIGN KEY ("status_id") REFERENCES "order_status"("id") ON DELETE CASCADE
);

-- Stores the relationship between orders and superentities, tracking the request and assignment status for each entity in an order.
CREATE TABLE IF NOT EXISTS "order_entity" (
    "order_id" INTEGER NOT NULL,
    "entity_id" INTEGER NOT NULL,
    "requested" INTEGER NOT NULL DEFAULT 0 CHECK ("requested" BETWEEN 0 AND 1),
    "assigned" INTEGER NOT NULL DEFAULT 0 CHECK ("assigned" BETWEEN 0 AND 1),
    PRIMARY KEY ("order_id", "entity_id"),
    CONSTRAINT fk_so_order FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT fk_so_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
);

-- Stores payments made by clients
CREATE TABLE IF NOT EXISTS "payment" (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "datetime" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "client_id" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    CONSTRAINT fk_pay_client FOREIGN KEY ("client_id") REFERENCES "client"("id") ON DELETE CASCADE
);

-- Temporary table as an inbox for stepped and reviewed superentities insertions
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

-- Temporary table as an inbox for stepped and reviewed entity_power insertions
CREATE TABLE IF NOT EXISTS "temp_entity_power" (
    "entity_id" INTEGER DEFAULT NULL,
    "power_id" INTEGER DEFAULT NULL,
    "power_name" TEXT COLLATE NOCASE DEFAULT NULL,
    CHECK ("power_id" IS NOT NULL OR "power_name" IS NOT NULL)
);

-- Retrieves entity-team associations with the latest team membership status and availability status.
CREATE VIEW "entity_team_readable" AS
WITH latest_entity_team AS (
    SELECT
        "entity_id",
        "team_id",
        "member",
        MAX("datetime") AS latest_datetime
    FROM
        "entity_team"
    GROUP BY
        "entity_id",
        "team_id",
        "member"
),

latest_entity_availability AS (
    SELECT
        "entity_id",
        "status",
        MAX("datetime") AS latest_datetime
    FROM
        "entity_availability"
    GROUP BY
        "entity_id"
)

SELECT
    t."id" AS "team_id",
    ROW_NUMBER() OVER (
        PARTITION BY t."name"
        ORDER BY
            e."known_as" ASC,
            e."full_name" ASC
    ) AS "in-team_counter",
    t."name" AS "team_name",
    e."id" AS "entity_id",
    e."known_as",
    e."full_name",
    lea."status",
    let."member"
FROM
    latest_entity_team let
JOIN
    "superentity" e ON let."entity_id" = e."id"
LEFT JOIN
    latest_entity_availability lea ON lea."entity_id" = e."id"
JOIN
    "team" t ON let."team_id" = t."id"
ORDER BY
    t."name" ASC,
    e."known_as" ASC,
    e."full_name" ASC
/* entity_team_readable(team_id,"in-team_counter",team_name,entity_id,known_as,full_name,status,member) */;

-- Provides a readable summary of entity attributes and their availability status
CREATE VIEW "entity_attribute_readable" AS
SELECT
    eat."entity_id",
    se."known_as" AS "entity_known_as",
    se."full_name" AS "entity_full_name",
    eav."status",
    eat."attribute_id",
    a."name" AS "attribute_name",
    eat."attribute_value"
FROM "superentity" se
LEFT JOIN
    (SELECT "entity_id", "status", MAX("datetime")
     FROM "entity_availability"
     GROUP BY "entity_id") eav
    ON eav."entity_id" = se."id"
JOIN "entity_attribute" eat
    ON se."id" = eat."entity_id"
JOIN "attribute" a
    ON eat."attribute_id" = a."id"
ORDER BY eat."entity_id", eat."attribute_id"
/* entity_attribute_readable(entity_id,entity_known_as,entity_full_name,status,attribute_id,attribute_name,attribute_value) */;

-- Provides a readable summary of entities and their powers with availability status
CREATE VIEW "entity_power_readable" AS
SELECT
    e."id" AS "entity_id",
    e."known_as" AS "entity_known_as",
    e."full_name" AS "entity_full_name",
    ea."status",
    p."id" AS "power_id",
    p."name" AS "power_name"
FROM
    "superentity" e
LEFT JOIN
    (SELECT "entity_id", "status", MAX("datetime")
     FROM "entity_availability"
     GROUP BY "entity_id") ea ON ea."entity_id" = e."id"
JOIN
    "entity_power" ep ON e."id" = ep."entity_id"
JOIN
    "superpower" p ON ep."power_id" = p."id"
ORDER BY
    e."id"
/* entity_power_readable(entity_id,entity_known_as,entity_full_name,status,power_id,power_name) */;

-- Provides a readable view of superentity data with additional current availability status
CREATE VIEW "superentity_readable" AS
SELECT
    e."id",
    e."known_as",
    e."full_name",
    g."name" AS "gender",
    r."name" AS "race",
    p."name" AS "publisher",
    e."morality_rating",
    ea."status"
FROM
    "superentity" e
LEFT JOIN
    (SELECT "entity_id", "status", MAX("datetime")
     FROM "entity_availability"
     GROUP BY "entity_id") ea
    ON ea."entity_id" = e."id"
LEFT JOIN
    "gender" g ON g."id" = e."gender_id"
LEFT JOIN
    "race" r ON r."id" = e."race_id"
LEFT JOIN
    "publisher" p ON p."id" = e."publisher_id"
/* superentity_readable(id,known_as,full_name,gender,race,publisher,morality_rating,status) */;

-- Provides a readable view of order details including current status
CREATE VIEW "order_readable" AS
SELECT
    o."id" AS "order_id",
    o."client_id",
    o."created_at",
    o."title",
    o."location",
    o."description",
    o."scheduled_start",
    o."scheduled_end",
    o."fixed_price",
    os."label" AS "status",
    "latest_status"."max_datetime" AS "current_status_since"
FROM "order" o
INNER JOIN (
    SELECT
        "order_id",
        "status_id",
        MAX(datetime) AS "max_datetime"
    FROM
        "order_status_applied" osa
    GROUP BY
        "order_id"
) AS "latest_status"
    ON
        o."id" = latest_status."order_id"
INNER JOIN "order_status" os
    ON "latest_status"."status_id" = os."id"
ORDER BY o."id" ASC
/* order_readable(order_id,client_id,created_at,title,location,description,scheduled_start,scheduled_end,fixed_price,status,current_status_since) */;

-- Summarizes client information, including total orders, charges, payments, balance, and last order date.
CREATE VIEW "client_full" AS
SELECT
    c."id",
    c."first_name",
    c."last_name",
    c."phone",
    COUNT(o."id") AS "total_orders",
    COALESCE(fixed."total_fixed_fee", 0) AS "total_charged",
    COALESCE(paid."total_paid", 0) AS "total_paid",
    CAST(
        ROUND(
            COALESCE(paid."total_paid", 0) - COALESCE(fixed."total_fixed_fee", 0)
        ) AS INTEGER
    ) AS "balance",
    COALESCE(MAX(o."created_at"), 'didn''t order') AS "last_order_at"
FROM
    "client" c
    LEFT JOIN "order" o ON c."id" = o."client_id"
    LEFT JOIN (
        SELECT
            o."client_id",
            SUM(o."fixed_price") AS "total_fixed_fee"
        FROM
            "order" o
            LEFT JOIN (
                SELECT
                    "order_id",
                    MAX("datetime") AS "last_status_time"
                FROM
                    "order_status_applied"
                GROUP BY
                    "order_id"
            ) last_status ON o."id" = last_status."order_id"
            LEFT JOIN "order_status_applied" osa ON
                osa."order_id" = last_status."order_id" AND
                osa."datetime" = last_status."last_status_time"
        WHERE
            o."fixed_price" IS NOT NULL
            AND COALESCE(osa."status_id", 0) != 1
        GROUP BY
            o."client_id"
    ) fixed ON c."id" = fixed."client_id"
    LEFT JOIN (
        SELECT
            "client_id",
            SUM("amount") AS "total_paid"
        FROM
            "payment"
        GROUP BY
            "client_id"
    ) paid ON c."id" = paid."client_id"
GROUP BY
    c."id"
ORDER BY
    c."id"
/* client_full(id,first_name,last_name,phone,total_orders,total_charged,total_paid,balance,last_order_at) */;

-- Evaluates the punctuality of orders by comparing actual and scheduled start/end times
CREATE VIEW "punctuality" AS
WITH latest_status AS (
    SELECT
        osa."order_id",
        os."label" AS "current_status",
        (SELECT MAX(datetime) FROM "order_status_applied" WHERE order_id = osa.order_id) AS latest_status_datetime,
        osa."datetime" AS status_datetime,
        osa."status_id"
    FROM "order_status_applied" osa
    JOIN "order_status" os ON osa.status_id = os.id
    WHERE osa."datetime" = (
        SELECT MAX(datetime)
        FROM "order_status_applied"
        WHERE order_id = osa.order_id
    )
),
start_status AS (
    SELECT
        order_id,
        datetime AS started_datetime
    FROM "order_status_applied" osa
    JOIN "order_status" os ON osa.status_id = os.id
    WHERE os."label" = 'ongoing'
),
end_status AS (
    SELECT
        order_id,
        datetime AS ended_datetime
    FROM "order_status_applied" osa
    JOIN "order_status" os ON osa.status_id = os.id
    WHERE os."label" IN ('succeded', 'failed')
)
SELECT
    o."id" AS "order_id",
    CASE
        WHEN ls."current_status" = 'cancelled' THEN 'cancelled'
        WHEN o."scheduled_start" IS NULL THEN 'start not scheduled'
        WHEN julianday(o."scheduled_start") > julianday(CURRENT_TIMESTAMP) AND ss.started_datetime IS NULL THEN 'start scheduled for later'
        WHEN ss.started_datetime IS NOT NULL AND o."scheduled_start" IS NOT NULL THEN
            CASE
                WHEN julianday(ss.started_datetime) - julianday(o."scheduled_start") < 0 THEN
                    '-' || printf('%02d:%02d:%02d',
                        CAST(ABS((julianday(ss.started_datetime) - julianday(o."scheduled_start")) * 24) AS INTEGER),
                        CAST(ABS(((julianday(ss.started_datetime) - julianday(o."scheduled_start")) * 1440) % 60) AS INTEGER),
                        CAST(ABS(((julianday(ss.started_datetime) - julianday(o."scheduled_start")) * 86400) % 60) AS INTEGER))
                ELSE
                    printf('%02d:%02d:%02d',
                        CAST(((julianday(ss.started_datetime) - julianday(o."scheduled_start")) * 24) AS INTEGER),
                        CAST((((julianday(ss.started_datetime) - julianday(o."scheduled_start")) * 1440) % 60) AS INTEGER),
                        CAST((((julianday(ss.started_datetime) - julianday(o."scheduled_start")) * 86400) % 60) AS INTEGER))
            END
        ELSE NULL
    END AS "punctuality_of_start",
    CASE
        WHEN ls."current_status" = 'cancelled' THEN 'cancelled'
        WHEN ls."current_status" = 'failed' THEN NULL
        WHEN o."scheduled_end" IS NULL THEN 'end not scheduled'
        WHEN julianday(o."scheduled_end") > julianday(CURRENT_TIMESTAMP) AND es.ended_datetime IS NULL THEN 'end scheduled for later'
        WHEN es.ended_datetime IS NOT NULL AND o."scheduled_end" IS NOT NULL THEN
            CASE
                WHEN julianday(es.ended_datetime) - julianday(o."scheduled_end") < 0 THEN
                    '-' || printf('%02d:%02d:%02d',
                        CAST(ABS((julianday(es.ended_datetime) - julianday(o."scheduled_end")) * 24) AS INTEGER),
                        CAST(ABS(((julianday(es.ended_datetime) - julianday(o."scheduled_end")) * 1440) % 60) AS INTEGER),
                        CAST(ABS(((julianday(es.ended_datetime) - julianday(o."scheduled_end")) * 86400) % 60) AS INTEGER))
                ELSE
                    printf('%02d:%02d:%02d',
                        CAST(((julianday(es.ended_datetime) - julianday(o."scheduled_end")) * 24) AS INTEGER),
                        CAST((((julianday(es.ended_datetime) - julianday(o."scheduled_end")) * 1440) % 60) AS INTEGER),
                        CAST((((julianday(es.ended_datetime) - julianday(o."scheduled_end")) * 86400) % 60) AS INTEGER))
            END
        ELSE NULL
    END AS "punctuality_of_end",
    ls."current_status" AS "status"
FROM "order" o
JOIN latest_status ls ON ls."order_id" = o."id"
LEFT JOIN start_status ss ON ss."order_id" = o."id"
LEFT JOIN end_status es ON es."order_id" = o."id"
WHERE ls."current_status" NOT IN ('cancelled')
ORDER BY "order_id"
/* punctuality(order_id,punctuality_of_start,punctuality_of_end,status) */;

-- Retrieves order-entity associations, displaying order titles and entity details along with requested and assigned status
CREATE VIEW "order_entity_readable" AS
SELECT
    oe."order_id",
    o."title",
    oe."entity_id",
    e."known_as" AS "entity_known_as",
    e."full_name" AS "entity_full_name",
    oe."requested",
    oe."assigned"
FROM "superentity" e
JOIN "order_entity" oe
    ON e."id" = oe."entity_id"
JOIN "order" o
    ON oe."order_id" = o."id"
ORDER BY oe."order_id"
/* order_entity_readable(order_id,title,entity_id,entity_known_as,entity_full_name,requested,assigned) */;

-- Handles inserts into entity_power_readable by validating data and ensuring superpowers exist
CREATE TRIGGER "ent_pow_r_instead_insert_insert_ent_pow"
INSTEAD OF INSERT ON "entity_power_readable"
FOR EACH ROW
BEGIN
    -- Validate entity and power data
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM "superentity" WHERE "id" = NEW."entity_id"
        )
        THEN RAISE(ABORT, 'Error: entity_id does not exist in superentity')
    END;

    SELECT CASE
        WHEN NEW."power_id" IS NULL AND COALESCE(NEW."power_name", '') = ''
        THEN RAISE(ABORT, 'Error: Either power_id or power_name must be provided')
    END;

    -- Insert superpower if it doesn't exist
    INSERT INTO "superpower" ("name")
    SELECT TRIM(NEW."power_name")
    WHERE NEW."power_name" IS NOT NULL
      AND TRIM(NEW."power_name") != ''
      AND NOT EXISTS (
          SELECT 1 FROM "superpower"
          WHERE "name" = TRIM(NEW."power_name") COLLATE NOCASE
      );

    -- Insert into entity_power with the correct power_id
    INSERT INTO "entity_power" ("entity_id", "power_id")
    VALUES
        (NEW."entity_id", (
            CASE
                WHEN NEW."power_id" IS NULL THEN (
                    SELECT "id" FROM "superpower"
                    WHERE "name" = TRIM(NEW."power_name") COLLATE NOCASE
                )
                ELSE NEW."power_id"
            END
        ));
END;


-- Inserts gender, race, and publisher if they don't exist, then inserts into superentity and updates entity_availability accordingly
CREATE TRIGGER "superentity_r_instead_insert_insert_superentity"
INSTEAD OF INSERT ON "superentity_readable"
FOR EACH ROW
BEGIN
    -- Insert gender if it doesn't exist
    INSERT INTO "gender" ("name")
    SELECT TRIM(NEW."gender")
    WHERE TRIM(NEW."gender") <> ''
      AND CAST(TRIM(NEW."gender") AS INTEGER) = 0
      AND NOT EXISTS (
        SELECT 1 FROM "gender" WHERE TRIM("name") = TRIM(NEW."gender") COLLATE NOCASE
    );

    -- Insert race if it doesn't exist
    INSERT INTO "race" ("name")
    SELECT TRIM(NEW."race")
    WHERE TRIM(NEW."race") <> ''
      AND CAST(TRIM(NEW."race") AS INTEGER) = 0
      AND NOT EXISTS (
        SELECT 1 FROM "race" WHERE TRIM("name") = TRIM(NEW."race") COLLATE NOCASE
    );

    -- Insert publisher if it doesn't exist
    INSERT INTO "publisher" ("name")
    SELECT TRIM(NEW."publisher")
    WHERE TRIM(NEW."publisher") <> ''
      AND CAST(TRIM(NEW."publisher") AS INTEGER) = 0
      AND NOT EXISTS (
        SELECT 1 FROM "publisher" WHERE TRIM("name") = TRIM(NEW."publisher") COLLATE NOCASE
    );

    -- Insert into the superentity table
    INSERT INTO "superentity" ("id", "known_as", "full_name", "gender_id", "race_id", "publisher_id", "morality_rating")
    VALUES
        (CASE
            WHEN NEW."id" IS NULL THEN NULL
            ELSE NEW."id"
        END,
        TRIM(NEW."known_as"),
        TRIM(NEW."full_name"),
        -- Gender ID handling
        CASE
            WHEN CAST(NEW."gender" AS INTEGER) = 0 THEN (
                SELECT "id"
                FROM "gender"
                WHERE TRIM("name") = TRIM(NEW."gender") COLLATE NOCASE
            )
            ELSE CAST(NEW."gender" AS INTEGER)
        END,
        -- Race ID handling
        CASE
            WHEN CAST(NEW."race" AS INTEGER) = 0 THEN (
                SELECT "id"
                FROM "race"
                WHERE TRIM("name") = TRIM(NEW."race") COLLATE NOCASE
            )
            ELSE CAST(NEW."race" AS INTEGER)
        END,
        -- Publisher ID handling
        CASE
            WHEN CAST(NEW."publisher" AS INTEGER) = 0 THEN (
                SELECT "id"
                FROM "publisher"
                WHERE TRIM("name") = TRIM(NEW."publisher") COLLATE NOCASE
            )
            ELSE CAST(NEW."publisher" AS INTEGER)
        END,
        NEW."morality_rating");

    -- Use the inserted ID from the superentity table, but only if it exists
    INSERT INTO "entity_availability" ("entity_id", "status", "datetime")
    SELECT
        (CASE
            WHEN NEW."id" IS NULL THEN (
                SELECT "id"
                FROM "superentity"
                WHERE TRIM("known_as") = TRIM(NEW."known_as")
                  AND TRIM("full_name") = TRIM(NEW."full_name")
            )
            ELSE NEW."id"
        END),
        CASE
            WHEN TRIM(NEW."status") COLLATE NOCASE = 'out' THEN 'out'
            ELSE 'in'
        END,
        CURRENT_TIMESTAMP
    WHERE EXISTS (
        SELECT 1
        FROM "superentity"
        WHERE "id" = (CASE
            WHEN NEW."id" IS NULL THEN (
                SELECT "id"
                FROM "superentity"
                WHERE TRIM("known_as") = TRIM(NEW."known_as")
                  AND TRIM("full_name") = TRIM(NEW."full_name")
            )
            ELSE NEW."id"
        END)
    );
END;

-- Inserts the entity-team relationship, creating the team if necessary.
CREATE TRIGGER "ent_team_r_instead_insert_insert_ent_team"
INSTEAD OF INSERT ON "entity_team_readable"
FOR EACH ROW
BEGIN
    -- Validate entity and power data
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM "superentity" WHERE "id" = NEW."entity_id"
        )
        THEN RAISE(ABORT, 'Error: entity_id does not exist in superentity')
    END;

    -- Insert team if it doesn't exist
    INSERT INTO "team" ("name")
    SELECT TRIM(NEW."team_name")
    WHERE NEW."team_name" IS NOT NULL
      AND TRIM(NEW."team_name") != ''
      AND NOT EXISTS (
          SELECT 1 FROM "team"
          WHERE "name" = TRIM(NEW."team_name") COLLATE NOCASE
      );

    -- Insert into entity_team with the correct team_id
    INSERT INTO "entity_team" ("entity_id", "team_id", "member", "datetime")
    VALUES (
        NEW."entity_id", (
            CASE
                WHEN NEW."team_id" IS NULL THEN (
                    SELECT "id" FROM "team"
                    WHERE "name" = TRIM(NEW."team_name") COLLATE NOCASE
                )
                ELSE NEW."team_id"
            END
        ),
        CASE
            WHEN TRIM(NEW."member") COLLATE NOCASE = 'out' THEN 'out'
            ELSE 'in'
        END,
        CURRENT_TIMESTAMP
    );
END;

-- Automatically assigns a order_status of '2' (representing "SuperAgency! to confirm") to a new order after insertion if it doesn't already have this status.
CREATE TRIGGER "order_after_insert_insert_order_status"
AFTER INSERT ON "order"
FOR EACH ROW
WHEN NOT EXISTS (
    SELECT 1
    FROM "order_status_applied"
    WHERE
        "order_id" = NEW."id"
        AND "status_id" = 2
)
BEGIN
    INSERT INTO "order_status_applied" ("order_id", "status_id")
    VALUES (NEW."id", 2);
END;

-- Indexes for frequently searched columns in lookup tables
CREATE INDEX "idx_attribute_name" ON "attribute"("name");
CREATE INDEX "idx_gender_name" ON "gender"("name");
CREATE INDEX "idx_publisher_name" ON "publisher"("name");
CREATE INDEX "idx_race_name" ON "race"("name");
CREATE INDEX "idx_superpower_name" ON "superpower"("name");
CREATE INDEX "idx_team_name" ON "team"("name");

-- Indexes for frequently searched columns in "superentity" table
CREATE INDEX "idx_superentity_known_as" ON "superentity"("known_as");
CREATE INDEX "idx_superentity_full_name" ON "superentity"("full_name");

-- Index for (potentially) most searched columns in the "order" table
CREATE INDEX "idx_order_client_id" ON "order"("client_id");

-- Indexes for IDs pairs in junction tables
CREATE INDEX "idx_order_entity_order_id" ON "order_entity"("order_id");
CREATE INDEX "idx_order_entity_entity_id" ON "order_entity"("entity_id");
CREATE INDEX "idx_entity_team_entity_id" ON "entity_team"("entity_id");
CREATE INDEX "idx_entity_team_team_id" ON "entity_team"("team_id");
CREATE INDEX "idx_entity_attribute_entity_id" ON "entity_attribute"("entity_id");
CREATE INDEX "idx_entity_attribute_attribute_id" ON "entity_attribute"("attribute_id");
CREATE INDEX "idx_entity_power_entity_id" ON "entity_power"("entity_id");
CREATE INDEX "idx_entity_power_power_id" ON "entity_power"("power_id");

COMMIT;
PRAGMA foreign_keys = ON;
