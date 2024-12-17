CREATE VIEW "sh_align" AS
SELECT superhero_name, full_name, alignment_id
FROM superhero;


.mode insert <superpeople>
.out superpeople.sql
select * from "sh_align";


SELECT "superhero_name", "full_name", COUNT("id") AS "count"
FROM "superhero"
GROUP BY "superhero_name"
HAVING COUNT("id") > 1
ORDER BY "count" DESC;

SELECT "alias", "full_name", COUNT("alias") AS "count"
FROM "temp1"
GROUP BY "alias"
HAVING COUNT("id") > 1
ORDER BY "count" DESC;

-- Select repeated "superhero_name"

SELECT * FROM "superhero"
WHERE "superhero_name" IN (
    SELECT "superhero_name" FROM (
        SELECT "superhero_name", "full_name", COUNT("id") AS "count"
        FROM "superhero"
        GROUP BY "superhero_name"
        HAVING COUNT("id") > 1
        ORDER BY "count" DESC
    )
);

------
SELECT "superhero_name" FROM "superhero"
WHERE "morality_rate" IS NULL;

SELECT "alias" FROM "temp1"
WHERE "morality_rate" IS NULL;

SELECT
    s."superhero_name",
    p."publisher_name"
FROM "superhero" s
JOIN "publisher" p
    ON s."publisher_id" = p."id"
WHERE s."superhero_name" IN (
    SELECT "alias" FROM "temp1"
    WHERE "morality_rate" IS NULL
);


SELECT
    ROW_NUMBER() OVER (ORDER BY "superhero_name") AS "temp_id", -- adds a column "temp_id" to enumerate the output rows
    "superhero_name"
FROM
    "superhero"
WHERE
    "morality_rate" IS NULL;

SELECT "morality_rate" FROM "temp1"
WHERE "alias" IN (
    SELECT "superhero_name" FROM "superhero"
    WHERE "morality_rate" IS NULL
    );

-- Query with subquerie and with an added column to enumerate the output rows.
WITH superhero_with_id AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY "superhero_name") AS "temp_id",
        "superhero_name"
    FROM
        "superhero"
    WHERE
        "morality_rate" IS NULL
)
SELECT
    t.*,
    s."temp_id"
FROM
    "temp1" t
JOIN
    superhero_with_id s
ON
    t."alias" = s."superhero_name";




-- Query with subquery and with an added column to enumerate the output rows.
WITH superhero_with_id AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY "id") AS "temp_id",
        "id"
    FROM
        "superhero"
    WHERE
        "full_name" IS NULL
)
SELECT
    s."id",
    s."superhero_name",
    s."full_name",
    "temp_id"
FROM "superhero" s
JOIN "superhero_with_id" i
    ON s."id" = i."id"
WHERE s."full_name" IS NULL;


SELECT "id", "superhero_name". "full_name" FROM "superhero" WHERE "full_name" IS NULL;





SELECT * FROM "superhero" WHERE "superhero_name" = 'Absorbing Man';


UPDATE "superhero"
SET "morality_rate" = (
    SELECT "morality_rate"
    FROM "temp1"
    WHERE "temp1"."alias" = "superhero"."superhero_name"
)
WHERE "morality_rate" IS NULL
AND "alias" IN (
    SELECT "superhero_name"
    FROM "superhero"
    WHERE "morality_rate" IS NULL
);

UPDATE "superhero"
SET "morality_rate" = (
    SELECT "morality_rate"
    FROM "temp1"
    WHERE "temp1"."alias" = "superhero"."superhero_name"
)
WHERE "morality_rate" IS NULL;

UPDATE "superhero"
SET "morality_rate" = 8
WHERE "id" = 358;

UPDATE "superhero"
SET "morality_rate" = 6
WHERE "id" = 378;


----
UPDATE "superhero"
SET "full_name" = 'Carol Susan Jane Danvers'
WHERE "id" = 161;

UPDATE "superhero"
SET "full_name" = "William Joseph 'Billy' Batson"
WHERE "id" = 160;
----

CREATE VIEW "has_null" AS
SELECT * FROM "superhero"
WHERE id IS NULL
  OR superhero_name IS NULL
  OR full_name IS NULL
  OR gender_id IS NULL
  OR eye_colour_id IS NULL
  OR hair_colour_id IS NULL
  OR skin_colour_id IS NULL
  OR race_id IS NULL
  OR publisher_id IS NULL
  OR alignment_id IS NULL
  OR height_cm IS NULL
  OR weight_kg IS NULL
  OR morality_rate IS NULL;

SELECT "id","superhero_name","full_name" FROM "superhero"
WHERE
    "superhero_name" IS NULL
    OR "superhero_name" = ''
    OR "superhero_name" = '-'
    OR "full_name" IS NULL
    OR "full_name" = ''
    OR "full_name" = '-';

SELECT
    "superhero_name",
    "full_name"
FROM
    "superhero"
WHERE
    "superhero_name" LIKE '%"%'
    OR "full_name" LIKE '%"%'



-- Update "superhero" from "superhero_updates"

UPDATE "superhero"
SET "full_name" = (
    SELECT "full_name"
    FROM "superhero_updates"
    WHERE "superhero_updates"."id" = "superhero"."id"
);

WHERE "id" IN (
    SELECT "id" FROM "superhero_updates"
);


CREATE VIEW "sh_names" AS
SELECT "id", "superhero_name", "full_name"
FROM "superhero";

sqlite3 c:/sqlite/chinook.db <<EOF
.headers on
.mode csv
.output sh_names.csv
SELECT * FROM sh_names;
.quit
EOF

SELECT MAX("id") as "max_id"
FROM "superhero";

-- To look for "missing" ids (< than the greatest id but absent)

WITH RECURSIVE all_ids AS (
    SELECT MIN("id") AS id
    FROM "superhero"
    UNION ALL
    SELECT id + 1
    FROM all_ids
    WHERE id + 1 <= (SELECT MAX("id") FROM "superhero")
)
SELECT id
FROM all_ids
WHERE id NOT IN (SELECT "id" FROM "superhero");





ALTER TABLE "superhero"
ADD COLUMN "fee" INTEGER;

-- Update preventing changein unmatch to NULL:
---- Whithout CASE keyword:

UPDATE "superhero"
SET "fee" = (
    SELECT "fee" FROM "fee_updates"
    WHERE "fee_updates"."id" = "superhero"."id"
)
WHERE "id" IN (
    SELECT "id" FROM "fee_updates"
)-- This last WHERE statment is not extrictly necesary here but is a good practice to prevent unwanted changes in other cases.
;

-- Update preventing changein unmatch to NULL:
---- Whith CASE keyword:

UPDATE "table_name"
SET "columnx_name" = CASE
    WHEN "columny_name" = value THEN value
    WHEN "columny_name" = value THEN value
    WHEN "columny_name" = value THEN value
    WHEN "columny_name" = value THEN value
    ELSE "columnx_name"  -- To leave unchanged if no match
END;

-- Check

SELECT "id", "superhero_name", "full_name", "morality_rating", "fee"
FROM "superhero";


SELECT "id", "superhero_name", "full_name"
FROM "superhero"
ORDER BY "full_name" ASC
LIMIT 5;

UPDATE "superhero"
SET "full_name" = 'William Joseph "Billy" Batson'
WHERE "id" = 160;

CREATE TABLE "names_complete" (
    "id" INTEGER PRIMARY KEY,
    "superhero_name" TEXT,
    "full_name" TEXT
);

.import --csv --skip 1 names_complete.csv names_complete


UPDATE "superhero"
SET "full_name" = (
    SELECT "full_name"
    FROM "names_complete"
    WHERE "names_complete"."id" = "superhero"."id"
)

WHERE "id" IN (
    SELECT "id" FROM "names_complete"
);

UPDATE "superhero"
SET "fee" = 1000
WHERE "id" IN (293, 342, 402);


CREATE TABLE superentity (
    "id" INTEGER PRIMARY KEY,
    "superhero_name" TEXT NOT NULL,
    "full_name" TEXT,
    "gender_id" INTEGER,
    "race_id" INTEGER,
    "publisher_id" INTEGER,
    "morality_rating" INTEGER CHECK ("morality_rating" BETWEEN 1 AND 10),
    "fee" INTEGER,
    FOREIGN KEY ("gender_id") REFERENCES "gender"("id"),
    FOREIGN KEY ("publisher_id") REFERENCES "publisher"("id"),
    FOREIGN KEY ("race_id") REFERENCES "race"("id")
);

INSERT INTO "superentity"
SELECT
    "id",
    "superhero_name",
    "full_name",
    "gender_id",
    "race_id",
    "publisher_id",
    "morality_rating",
    "fee"
FROM "superhero";

ALTER TABLE "superentity"


CREATE TABLE entity_attribute (
  entity_id INTEGER DEFAULT NULL,
  attribute_id INTEGER DEFAULT NULL,
  attribute_value INTEGER DEFAULT NULL,
  CONSTRAINT fk_hat_at FOREIGN KEY (attribute_id) REFERENCES attribute (id),
  CONSTRAINT fk_hat_hero FOREIGN KEY (hero_id) REFERENCES superhero (id)



DROP TABLE "fee_updates";

DROP TABLE "temp1";
DROP TABLE "superhero_updates";

DROP VIEW "sh_names";

ALTER TABLE "attribute_1"
RENAME TO "attribute";

ALTER TABLE "gender_1"
RENAME TO "gender";

ALTER TABLE "publisher_1"
RENAME TO "publisher";

ALTER TABLE "race_1"
RENAME TO "race";

ALTER TABLE "superentity_1"
RENAME TO "superentity";

ALTER TABLE "superpower_1"
RENAME TO "superpower";

CREATE VIEW "entity_names" AS
SELECT "id", "known_as"
FROM "superentity";


SELECT "id","superhero_name","full_name" FROM "superhero"
WHERE
    "superhero_name" IS NULL
    OR "superhero_name" = ''
    OR "superhero_name" = '-'
    OR "full_name" IS NULL
    OR "full_name" = ''
    OR "full_name" = '-';

SELECT COUNT(*) AS "NULL, '', '-'"
FROM "superhero"
WHERE
    "superhero_name" IS NULL
    OR "superhero_name" = ''
    OR "superhero_name" = '-'
    OR "full_name" IS NULL
    OR "full_name" = ''
    OR "full_name" = '-';


sqlite3 superagency.db <<EOF
.output /workspaces/119766791/cs50_sql/project/superagency/actual/backup.sql
.dump
.exit
EOF


WITH RECURSIVE all_ids AS (
    SELECT MIN("id") AS id
    FROM "superentity"
    UNION ALL
    SELECT id + 1
    FROM all_ids
    WHERE id + 1 <= (SELECT MAX("id") FROM "superentity")
)
SELECT id AS "missing_ids"
FROM all_ids
WHERE id NOT IN (SELECT "id" FROM "superentity");



SELECT * FROM "attribute";
SELECT * FROM "gender";
SELECT * FROM "publisher";
SELECT * FROM "race";
SELECT * FROM "superpower";
SELECT * FROM "entity_attribute";
SELECT * FROM "entity_power";
SELECT * FROM "superentity";
SELECT * FROM "team";
SELECT * FROM "client";
SELECT * FROM "entity_team";
SELECT * FROM "order";
SELECT * FROM "entity_order";

.dump "attribute"
.dump "gender"
.dump "publisher"
.dump "race"
.dump "superpower"
.dump "entity_attribute"
.dump "entity_power"
.dump "superentity"


SELECT "id","known_as", "full_name" FROM "superentity";

.import --csv --skip 1 entity_team.csv entity_team

SELECT
    s."id",
    s."known_as",
    t."name"
FROM
    "superentity" s
JOIN
    "entity_team" et
    ON et."entity_id" = s."id"
JOIN
    "team" t
    ON t."id" = et."team_id";


--  Assign unique id values based on the rowid
UPDATE "team"
SET "id" = rowid;


/* Create a new table with the same schema as other table (but empty).
1=0 is always false, so the SELECT statement will return no rows.
As a result, the new table (temp_team) will be created with the same schema, but it will be empty.*/
CREATE TABLE IF NOT EXISTS "superentity_temp" AS
SELECT * FROM "superentity" WHERE 1=0;


-- Insert but fully reject failed inserts
INSERT OR IGNORE INTO team ("name")
SELECT columns FROM "entity_temp_team";


-- Compare against multiple columns.
SELECT *
FROM "entity_team_temp" et
WHERE NOT EXISTS ( --or WHERE EXISTS
    SELECT 1
    FROM "superentity" se
    WHERE (se."known_as" = et."entity_name" OR se."full_name" = et."entity_name")
);

--
BEGIN TRANSACTION;


-- To decide if keep (commit) or undo (rollback) the impact of a SQL code execution
-- Step 1: Start a transaction
BEGIN TRANSACTION;

-- Step 2: Run one or more query/ies (e.g., update the hourly_price)
UPDATE superentities SET hourly_price = hourly_price * 1.1 WHERE id = 1;

-- Step 3: Check the impact by reading the output log or/and executing other testing queries, e.g:
SELECT * FROM superentities WHERE id = 1;

-- Step 4:
ROLLBACK; -- to undo changes
COMMIT; -- to aply changes.




CREATE VIEW team_match_temp AS
SELECT
    et.*,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM "superentity" se
            WHERE se."known_as" = et."entity_name" OR se."full_name" = et."entity_name"
        ) THEN 1
        ELSE 0
    END AS "match"
FROM "entity_team_temp" et;



SELECT "entity_name", "team_name"
FROM "team_match_temp"
WHERE
    "match" = 0
    /*AND "team_name" IN (
        'Avengers',
        'Guardians of the Galaxy',
        'Inhumans',

        ...
        'team_name_n",
        )*/
;

SELECT "entity_name", "team_name"
FROM "team_match_temp"
WHERE
    "entity_name" IN(
        SELECT "known_as"
        FROM "superentity"
        WHERE "id" > 756
    )
;

SELECT
    MAX("morality_rating") AS "max_morality_rating",
    MIN("morality_rating") AS "min_morality_rating",
    MAX("fee"),
    MIN("fee")
FROM "superentity";

SELECT *
FROM "entity_team_temp" et
WHERE EXISTS (
    SELECT 1
    FROM "superentity" se
    WHERE (se."known_as" = et."entity_name" OR se."full_name" = et."entity_name")
);

-- Insert missing characters into the "superentity" table starting from ID 757
INSERT INTO "superentity" ("id", "known_as", "full_name", "gender_id", "race_id", "publisher_id", "morality_rating", "fee")
VALUES
(757, "Captain Boomerang", "Digger Harkness", 1, 24, 4, 3, 600),
(758, "Puck", "Eugene Judd", 1, 3, 13, 7, 800),
(759, "Nocturne", "Talia Josephine Wagner", 2, 42, 13, 8, 750),
(760, "Misty Knight", "Mercedes Kelly Knight", 2, 24, 13, 8, 725),
(761, "Colleen Wing", "Colleen Wing", 2, 24, 13, 8, 725),
(762, "Cosmic Boy", "Rokk Krinn", 1, 2, 4, 9, 850),
(763, "Kitty Pryde", "Katherine Pryde", 2, 42, 13, 9, 850),
(764, "Night Thrasher", "Dwayne Taylor", 1, 24, 13, 7, 750),
(765, "Abigail Brand", "Abigail Brand", 2, 12, 13, 8, 700),
(766, "Manifold", "Eden Fesi", 1, 42, 13, 7, 750),
(767, "Steve Rogers", "Steven Grant Rogers", 1, 24, 13, 10, 1000),
(768, "Katana", "Tatsu Yamashiro", 2, 24, 4, 8, 750),
(769, "Baron Zemo", "Helmut Zemo", 1, 24, 13, 3, 850);

INSERT INTO "superentity" ("id", "known_as", "full_name", "gender_id", "race_id", "publisher_id", "morality_rating", "fee")
VALUES
(770, "Sunfire", "Shiro Yoshida", 1, 24, 13, 7, 750),
(771, "Fantomex", "Charlie Cluster-7", 1, 24, 13, 6, 800),
(772, "Rachel Summers", "Rachel Anne Summers", 2, 42, 13, 9, 850),
(773, "Marrow", "Sarah", 2, 42, 13, 6, 750),
(774, "Stepford Cuckoos", "Phoebe, Celeste, Esme, Sophie, Irma", 2, 42, 13, 7, 900),
(775, "Pixie", "Megan Gwynn", 2, 42, 13, 7, 700),
(776, "Magik", "Illyana Nikolievna Rasputina", 2, 42, 13, 9, 850),
(777, "Omega Sentinel", "Karima Shapandar", 2, 24, 13, 8, 800),
(778, "Avalanche", "Dominikos Petrakis", 1, 42, 13, 5, 700),
(779, "Destiny", "Irene Adler", 2, 42, 13, 6, 750);


BEGIN TRANSACTION;
INSERT INTO "team" ("name")
    SELECT "team_name"
    FROM "team_match_temp"
    /* WHERE "team_name" NOT IN (
        SELECT "team_name"
        FROM "team_match_temp"
        WHERE "match" = 0
        GROUP BY "team_name"
    )*/
    GROUP BY "team_name";

SELECT "team_name" FROM (
    SELECT st."id", st."known_as", st."full_name", ett."team_name"
    FROM "superentity_temp" st
    JOIN "entity_team_temp" ett ON st."known_as" = ett."entity_name"
)
GROUP BY "team_name";


SELECT
    st."id" AS "entity_id",
    st."known_as",
    st."full_name",
    ett."team_name",
    tpt."publisher_name",
    p."id" AS "publisher_id"
FROM "superentity_temp" st
JOIN "entity_team_temp" ett ON st."known_as" = ett."entity_name"
JOIN "team_publisher_temp" tpt ON ett."team_name" = tpt."team_name"
JOIN "publisher" p ON tpt."publisher_name" = p."name";


▼▼▼▼
CREATE VIEW "superentity_team_temp" AS
SELECT
    s."id" AS "entity_id",
    s."known_as",
    s."full_name",
    -- ett."entity_name",
    ett."team_name",
    t."id" AS "team_id"
FROM "superentity" s
JOIN "entity_team_temp" ett ON s."known_as" = ett."entity_name"
JOIN "team" t ON ett."team_name" = t."name"
;
SELECT "entity_id", "team_id"
FROM "superentity_team_temp";

.import --csv --skip 1 superentity_team.csv entity_team

SELECT * FROM "superentity_team"
WHERE "known_as" LIKE 'Spider%';

DELETE FROM "team"
WHERE
    "entity_id" = 889
    AND "team_id" = 3;

DELETE FROM "team"
WHERE
    "entity_id" = 644
    AND "team_id" = 39;

-- Delete with 2 or more columns as conditional
-- Using "IN"
DELETE FROM "team"
WHERE
    ("entity_id", "team_id") IN (
        (889, 3),
        (644, 39)
    );

-- Using "OR"
DELETE FROM "team"
WHERE
    ("entity_id" = 889 AND "team_id" = 3)
    OR ("entity_id" = 644 AND "team_id" = 39);

▲▲▲▲

SELECT
    st."id" AS "entity_id",
    --st."known_as",
    --st."full_name",
    --ett."team_name",
    --tpt."publisher_name",
    p."id" AS "publisher_id"
FROM "superentity_temp" st
JOIN "entity_team_temp" ett ON st."known_as" = ett."entity_name"
JOIN "team_publisher_temp" tpt ON ett."team_name" = tpt."team_name"
JOIN "publisher" p ON tpt."publisher_name" = p."name";

SELECT "id", "publisher_id"
FROM "superentity_temp";

-- update specific column based on values on other column
UPDATE "superentity_temp"
SET "publisher_id" = CASE "id"
WHEN 757 THEN 13
WHEN 758 THEN 13
WHEN 759 THEN 13
WHEN 760 THEN 13
WHEN 760 THEN 13
WHEN 761 THEN 13
WHEN 762 THEN 13
WHEN 763 THEN 13
WHEN 763 THEN 13
WHEN 764 THEN 13
WHEN 765 THEN 13
WHEN 766 THEN 13
WHEN 767 THEN 13
WHEN 768 THEN 13
WHEN 769 THEN 13
WHEN 770 THEN 13
WHEN 771 THEN 13
WHEN 772 THEN 13
WHEN 773 THEN 13
WHEN 774 THEN 13
WHEN 775 THEN 13
WHEN 776 THEN 13
WHEN 777 THEN 13
WHEN 778 THEN 13
WHEN 779 THEN 13
WHEN 780 THEN 13
WHEN 781 THEN 13
WHEN 782 THEN 13
WHEN 783 THEN 13
WHEN 784 THEN 13
WHEN 785 THEN 13
WHEN 786 THEN 13
WHEN 786 THEN 13
WHEN 787 THEN 4
WHEN 788 THEN 13
WHEN 789 THEN 13
WHEN 790 THEN 13
WHEN 791 THEN 13
WHEN 792 THEN 13
WHEN 793 THEN 13
WHEN 794 THEN 13
WHEN 795 THEN 13
WHEN 796 THEN 4
WHEN 797 THEN 4
WHEN 798 THEN 4
WHEN 799 THEN 4
WHEN 800 THEN 4
WHEN 801 THEN 4
WHEN 802 THEN 4
WHEN 803 THEN 3
WHEN 804 THEN 3
WHEN 805 THEN 3
WHEN 806 THEN 3
WHEN 807 THEN 3
WHEN 808 THEN 13
WHEN 808 THEN 13
WHEN 809 THEN 13
WHEN 810 THEN 13
WHEN 811 THEN 13
WHEN 812 THEN 13
WHEN 813 THEN 13
WHEN 814 THEN 13
WHEN 815 THEN 13
WHEN 816 THEN 13
WHEN 817 THEN 13
WHEN 818 THEN 13
WHEN 819 THEN 13
WHEN 820 THEN 13
WHEN 821 THEN 13
WHEN 822 THEN 15
WHEN 823 THEN 15
WHEN 824 THEN 15
WHEN 825 THEN 4
WHEN 826 THEN 10
WHEN 827 THEN 10
WHEN 828 THEN 10
WHEN 829 THEN 13
WHEN 830 THEN 13
WHEN 831 THEN 13
WHEN 832 THEN 13
WHEN 833 THEN 13
WHEN 834 THEN 13
WHEN 835 THEN 13
WHEN 835 THEN 13
WHEN 836 THEN 13
WHEN 837 THEN 13
WHEN 838 THEN 13
WHEN 839 THEN 13
WHEN 840 THEN 13
WHEN 841 THEN 13
WHEN 842 THEN 13
WHEN 843 THEN 10
WHEN 843 THEN 10
WHEN 844 THEN 10
WHEN 844 THEN 10
WHEN 845 THEN 10
WHEN 846 THEN 10
WHEN 847 THEN 10
WHEN 848 THEN 13
WHEN 849 THEN 10
WHEN 849 THEN 10
WHEN 850 THEN 10
WHEN 850 THEN 10
WHEN 851 THEN 10
WHEN 852 THEN 10
WHEN 853 THEN 10
WHEN 854 THEN 10
WHEN 855 THEN 10
WHEN 856 THEN 10
WHEN 857 THEN 10
WHEN 858 THEN 10
WHEN 864 THEN 4
WHEN 865 THEN 4
WHEN 866 THEN 13
WHEN 867 THEN 13
WHEN 868 THEN 13
WHEN 869 THEN 13
WHEN 870 THEN 13
WHEN 871 THEN 26
WHEN 872 THEN 26
WHEN 873 THEN 26
WHEN 874 THEN 26
WHEN 875 THEN 26
WHEN 876 THEN 24
WHEN 877 THEN 24
WHEN 878 THEN 24
WHEN 879 THEN 24
WHEN 880 THEN 24
WHEN 881 THEN 13
WHEN 882 THEN 13
WHEN 883 THEN 13
WHEN 884 THEN 13
WHEN 885 THEN 13
WHEN 886 THEN 13
WHEN 887 THEN 13
WHEN 888 THEN 13
WHEN 889 THEN 13
WHEN 889 THEN 13
WHEN 890 THEN 13
WHEN 891 THEN 13
WHEN 892 THEN 13
WHEN 893 THEN 13
WHEN 894 THEN 13
WHEN 895 THEN 13
WHEN 896 THEN 13
WHEN 897 THEN 13
WHEN 897 THEN 13
END;

SELECT
    st."id",
    st."known_as",
    st."full_name",
    st."publisher_id",
    p."name" AS "publisher_name"
FROM "superentity_temp" st
JOIN "publisher" p ON st."publisher_id" = p."id";


.mode csv
.headers on

SELECT * FROM "attribute";

SELECT
    s."id",
    s."known_as",
    s."full_name",
    p."name" AS "publisher_name"
FROM "superentity" s
JOIN "publisher" p
    ON s."publisher_id" = p."id"
WHERE s."id" > 756;


SELECT "id", "known_as", "full_name"
FROM "superentity"
WHERE
    "known_as" LIKE 'Iron man'
    --OR "full_name" LIKE ''
    ;

644,Spider-Man
73,Batman
667,Superman
342,Hulk
356,"Iron Man"


SELECT
    s."id" AS "entity_id",
    s."known_as",
    a."id" AS "attribute_id",
    a."name" AS "attribute_name",
    ea."attribute_value"
FROM "superentity" s
JOIN "entity_attribute" ea
    ON s."id" = ea."entity_id"
JOIN "attribute" a
    ON ea."attribute_id" = a."id"
WHERE s."known_as" IN (
    "Spider-Man",
    "Batman",
    "Superman",
    "Hulk",
    "Iron Man",
    "Thor",
    "Joker",
    "Magneto",
    "Thanos"
)
ORDER BY s."id" ASC;



SELECT "id", "known_as"
FROM "superentity"
WHERE "id" > 756;


.import --csv --skip 1 ent_att.csv "entity_attribute"


CREATE TABLE IF NOT EXISTS "entity_attribute_1" (
    "entity_id" INTEGER,
    "attribute_id" INTEGER,
    "attribute_value" INTEGER NOT NULL,
    PRIMARY KEY ("entity_id", "attribute_id"),
    CONSTRAINT fk_eat_at1 FOREIGN KEY (attribute_id) REFERENCES "attribute" (id),
    CONSTRAINT fk_eat_ent1 FOREIGN KEY ("entity_id") REFERENCES "superentity" (id)
);

INSERT INTO "entity_attribute_1"
SELECT * FROM "entity_attribute";

DROP TABLE "entity_attribute";

CREATE TABLE IF NOT EXISTS "entity_attribute" (
    "entity_id" INTEGER,
    "attribute_id" INTEGER,
    "attribute_value" INTEGER NOT NULL,
    PRIMARY KEY ("entity_id", "attribute_id"),
    CONSTRAINT fk_eat_at FOREIGN KEY (attribute_id) REFERENCES "attribute" (id),
    CONSTRAINT fk_eat_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id)
);

INSERT INTO "entity_attribute"
SELECT * FROM "entity_attribute_1";

.mode csv
.headers on

SELECT * FROM "superpower";


CREATE TABLE IF NOT EXISTS "entity_attribute" (
    "entity_id" INTEGER,
    "attribute_id" INTEGER,
    "attribute_value" INTEGER NOT NULL,
    PRIMARY KEY ("entity_id", "attribute_id"),
    CONSTRAINT fk_eat_at FOREIGN KEY (attribute_id) REFERENCES "attribute" (id),
    CONSTRAINT fk_eat_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id)
);

SELECT
    e."id",
    e."known_as",
    COUNT(ep."entity_id") AS "number_of_powers"
FROM "superentity" e
JOIN "entity_power" ep
    ON ep."entity_id" = e."id"
GROUP BY ep."entity_id"
LIMIT 50;


SELECT MAX("number_of_powers"), MIN("number_of_powers")
FROM (
    SELECT
        e."id",
        e."known_as",
        COUNT(ep."entity_id") AS "number_of_powers"
    FROM "superentity" e
    JOIN "entity_power" ep
        ON ep."entity_id" = e."id"
    GROUP BY ep."entity_id"
);


SELECT "known_as", "full_name", COUNT(*)
FROM "superentity"
GROUP BY "known_as", "full_name"
HAVING COUNT(*) > 1;

SELECT *
FROM "superentity"
WHERE ("known_as", "full_name") IN (
    SELECT "known_as", "full_name"
    FROM "superentity"
    GROUP BY "known_as", "full_name"
    HAVING COUNT(*) > 1
)
ORDER BY "known_as";


SELECT *
FROM "superentity"
WHERE ("known_as", "full_name") IN (
    SELECT "known_as", "full_name"
    FROM "superentity"
    GROUP BY "known_as", "full_name"
    HAVING COUNT(*) > 1
)
ORDER BY "known_as";

CREATE VIEW "superentity_readable" AS
SELECT
    e."id",
    e."known_as",
    e."full_name",
    g."name" AS "gender",
    r."name" AS "race",
    p."name" AS "publisher",
    e."morality_rating",
    e."fee"
FROM "superentity" e
JOIN "gender" g
    ON g."id" = e."gender_id"
JOIN "race" r
    ON r."id" = e."race_id"
JOIN "publisher" p
    ON p."id" = e."publisher_id";

-- Search for duplicated superentities.
SELECT * FROM "superentity_readable"
WHERE ("known_as", "full_name") IN (
    SELECT "known_as", "full_name"
FROM "superentity"
GROUP BY "known_as", "full_name"
HAVING COUNT(*) > 1
);

SELECT "rowid","entity_id", "power_id"
FROM "entity_power_temp"
WHERE ("entity_id", "power_id") IN (
    SELECT "entity_id", "power_id"
FROM "entity_power_temp"
GROUP BY "entity_id", "power_id"
HAVING COUNT(*) > 1
);

-- Search in "superentity" table by alias or name
SELECT "id", "known_as", "full_name"
FROM "superentity"
WHERE
    "known_as" LIKE '%Angel%'
    --OR "full_name" LIKE '%Spider%'
;

BEGIN TRANSACTION;

DELETE FROM "superentity"
WHERE "id" = 25;

ALTER TABLE "superentity"
ADD COLUMN "available" INTEGER CHECK ("available" BETWEEN 0 AND 1) DEFAULT 1 NOT NULL;

-- Add ON DELETE CASCADE to child tables

-- "entity_attribute" table
CREATE TABLE "temp" AS
SELECT * FROM "entity_attribute";

DROP TABLE "entity_attribute";

CREATE TABLE IF NOT EXISTS "entity_attribute" (
    "entity_id" INTEGER,
    "attribute_id" INTEGER,
    "attribute_value" INTEGER NOT NULL,
    PRIMARY KEY ("entity_id", "attribute_id"),
    CONSTRAINT fk_eat_at FOREIGN KEY (attribute_id) REFERENCES "attribute" (id) ON DELETE CASCADE,
    CONSTRAINT fk_eat_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id) ON DELETE CASCADE
);

INSERT INTO "entity_attribute"
SELECT * FROM "temp";

DROP TABLE "temp";


-- "entity_order" table:
CREATE TABLE "temp" AS
SELECT * FROM "entity_order";

DROP TABLE "entity_order";

CREATE TABLE IF NOT EXISTS "entity_order" (
    "order_id" INTEGER,
    "entity_id" INTEGER,
    PRIMARY KEY ("order_id", "entity_id"),
    CONSTRAINT fk_so_order FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT fk_so_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
);

INSERT INTO "entity_order"
SELECT * FROM "temp";

DROP TABLE "temp";


-- "entity_power" table
CREATE TABLE "temp" AS
SELECT * FROM "entity_power";

DROP TABLE "entity_power";

CREATE TABLE IF NOT EXISTS "entity_power" (
    "entity_id" INTEGER,
    "power_id" INTEGER,
    PRIMARY KEY ("entity_id", "power_id"),
    CONSTRAINT fk_epo_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id) ON DELETE CASCADE,
    CONSTRAINT fk_epo_po FOREIGN KEY (power_id) REFERENCES "superpower" (id) ON DELETE CASCADE
);

INSERT INTO "entity_power"
SELECT * FROM "temp";

DROP TABLE "temp";


-- "entity_team" table
CREATE TABLE "temp" AS
SELECT * FROM "entity_team";

DROP TABLE "entity_team";

CREATE TABLE IF NOT EXISTS "entity_team" (
    "entity_id" INTEGER,
    "team_id" INTEGER,
    PRIMARY KEY ("entity_id", "team_id"),
    CONSTRAINT fk_et_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE,
    CONSTRAINT fk_et_team FOREIGN KEY ("team_id") REFERENCES "team"("id") ON DELETE CASCADE
);

INSERT INTO "entity_team"
SELECT * FROM "temp";

DROP TABLE "temp";

-------



-- Listing the foreign keys that the specified table has.
PRAGMA foreign_key_list("superentity");

-- Listing tables that reference a specific table:
SELECT name
FROM sqlite_master
WHERE type = 'table'
AND sql LIKE '%REFERENCES "client"%';


----------

DELETE FROM "superentity"
WHERE "id" = 25;

UPDATE "superentity"
SET "full_name" = "Ares De'Congol"
WHERE "id" = 45;

DELETE FROM "superentity"
WHERE "id" = 52;

DELETE FROM "superentity"
WHERE "id" = 51;

DELETE FROM "entity_power"
WHERE "entity_id" = 50;

UPDATE "superentity"
SET "known_as" = "Atlas, Power Man, Smuggler"
WHERE "id" = 53;

UPDATE "superentity"
SET "full_name" = "Atlas"
WHERE "id" = 50;

INSERT OR IGNORE INTO "entity_power" VALUES
(50,18),
(50,61);

INSERT OR IGNORE INTO "entity_power" VALUES
(53,46),
(53,126),
(53,32),
(53,9),
(53,103);

INSERT INTO "race" ("name") VALUES
("Durlan");

UPDATE "superentity"
SET ("known_as","full_name","race_id","morality_rating","fee")
    = ("Chameleon Boy","Reep Daggle",62,8,1200)
WHERE "id" = 174;

UPDATE "superentity"
SET ("morality_rating","fee")
    = (3,900)
WHERE "id" = 175;


INSERT OR IGNORE INTO "entity_power" VALUES
(174,70),
(174,39);

INSERT OR IGNORE INTO "entity_power" VALUES
(175,7);

DELETE FROM "superentity"
WHERE "id" = 897;

UPDATE "superentity"
SET "fee" = 1350
WHERE "id" = 760;

DELETE FROM "entity_power_temp"
WHERE "rowid" = 21;

UPDATE "superentity"
SET "full_name" = 'Adam Bernard Brashear'
WHERE "id" = 760;

INSERT OR IGNORE INTO "entity_power_temp" VALUES
(760,31),
(760,26),
(760,103),
(760,98),
(760,16),
(760,17),
(760,168),
(760,169);

INSERT OR IGNORE INTO "superpower" ("name") VALUES
("Mental perception"),
("Anti-matter manipulation"),

DELETE FROM "entity_power_temp"
WHERE "entity_id" IN (763,835);

DELETE FROM "superentity"
WHERE "id" = 835;

INSERT OR IGNORE INTO "entity_power_temp" VALUES
(763,87),
(763,17);

UPDATE "superentity"
SET ("race_id", "publisher_id", "morality_rating") = (41, 4, 5)
WHERE "id" = 843;

DELETE FROM "entity_power_temp"
WHERE "entity_id" IN (843,849);

DELETE FROM "superentity"
WHERE "id" = 849;

INSERT OR IGNORE INTO "superpower" ("name") VALUES
("Temporary pain suppression"),
("Neurotactical wetware"),
("Multilingualism"),
("Combat master");

INSERT OR IGNORE INTO "entity_power_temp" VALUES
(843,7),
(843,13),
(843,171),
(843,172),
(843,173);

DELETE FROM "superentity"
WHERE "id" = 850;

DELETE FROM "entity_power_temp"
WHERE "entity_id" IN (844,850);

INSERT OR IGNORE INTO "superpower" ("name") VALUES
("Light Projection");

INSERT OR IGNORE INTO "entity_power_temp" VALUES
(844,8),
(844,22),
(844,9),
(844,2),
(844,151),
(844,61),
(844,174),
(844,26),
(844,31),
(844,18),
(844,173);

UPDATE "superentity"
SET "race_id" = 41
WHERE "id" = 844;

DELETE FROM "entity_power_temp"
WHERE "entity_id" NOT IN (
    SELECT "id"
    FROM "superentity"
);

INSERT OR IGNORE INTO "entity_power"
SELECT * FROM "entity_power_temp";

DELETE FROM "entity_power"
WHERE "entity_id" = (895);

INSERT OR IGNORE INTO "superpower" ("name") VALUES
("Fear instilling");

INSERT OR IGNORE INTO "entity_power" VALUES
(895, 13),
(895, 18),
(895, 26),
(895, 77),
(895, 175);

INSERT OR IGNORE INTO "race" ("name") VALUES
("Olympian");

UPDATE "superentity"
SET "race_id" = 63
WHERE "id" = 895;

-- ▲▲▲ DONE ▲▲▲

CREATE TABLE IF NOT EXISTS "order" (
    "id" INTEGER PRIMARY KEY,
    "client_id" INTEGER NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "title" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "scheduled_start" DATETIME NOT NULL,
    "started" DATETIME,
    "scheduled_end" DATETIME,
    "ended" DATETIME,
    "fixed_price" INTEGER,
    "hourly_price" INTEGER,
    "paid" INTEGER,
    CHECK ("scheduled_end" IS NULL OR "scheduled_end" >= "scheduled_start"),
    CHECK ("ended" IS NULL OR "ended" >= "started"),
    CHECK ("fixed_price" IS NOT NULL OR "hourly_price" IS NOT NULL),
    CONSTRAINT fk_order_client FOREIGN KEY ("client_id") REFERENCES "client"("id")
);

UPDATE "order"
SET "fixed_price" = 1000000
WHERE "id" = 16;

UPDATE "order"
SET "started" = NULL
WHERE "id" = 16;

UPDATE "order"
SET "hourly_price" = "hourly_price" * 10
WHERE
    "id" NOT IN (16)
    AND "hourly_price" IS NOT NULL;

UPDATE "order"
SET "hourly_price" = NULL
WHERE "hourly_price" = 0;

UPDATE "order"
SET ("started","ended") = ("scheduled_start","scheduled_end")
WHERE "id" IN (1,6,8,14);

UPDATE "order"
SET "started" = NULL
WHERE "id" = 16;

UPDATE "order"
SET ("started","ended") = ("scheduled_start","scheduled_end")
WHERE
    "started" IS NULL
    --AND "id" NOT IN (16)
    ;

SELECT "id", "started"
FROM "order";

"id",
"client_id",
"created_at",
"title",
"location",
"description",
"scheduled_start",
"started",
"scheduled_end",
"ended",
"fixed_price",
"hourly_price",
"paid"

UPDATE "order"
SET
    "started" = NULL,
    "scheduled_end" = NULL,
    "ended" = NULL
WHERE
    "started" = 'NULL'
    OR "scheduled_end" = 'NULL'
    OR "ended" = 'NULL';

UPDATE "order"
SET "paid" = 0
WHERE
    "started" IS NULL
    AND "ended" IS NULL;

UPDATE "order"
SET "paid" = "paid" + 3000
WHERE "paid" BETWEEN 3000 AND 9000;

UPDATE "superentity"
SET "fee" = "fee" + 1000
WHERE "id" > 896;


SELECT
    "team_id",
    GROUP_CONCAT("entity_id", ',') AS "entities_id"
FROM
    entity_team
GROUP BY
    team_id;

CREATE VIEW IF NOT EXISTS "team_full" AS
SELECT
    t."id" AS "team_id",
    t."name" AS "team_name",
    e."id" AS "entity_id",
    e."known_as",
    e."full_name"
FROM "superentity" e
JOIN "entity_team" et
    ON e."id" = et."entity_id"
JOIN "team" t
    ON et."team_id" = t."id"
ORDER BY
    "team_name" ASC,
    "known_as" ASC,
    "full_name" ASC;

CREATE TABLE IF NOT EXISTS "entity_order_temp" (
    "order_id" INT,
    "known_as" TEXT
);

SELECT * FROM "entity_order"
WHERE 1=0;

SELECT "known_as"
FROM "entity_order_temp"
WHERE "known_as" NOT IN (
    SELECT "known_as" FROM "superentity"
);

"Shroud"
"Zephyr"
"Shade"
"Doctor Light"
"Graviton"
"Terrax"

INSERT INTO superentity (id, known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)

INSERT INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES
('Shroud', 'Maximillian Coleridge', 1, 24, 13, 6, 1200, 1),
('Zephyr', 'Roxanne Spaulding', 2, 25, 25, 7, 900, 1),
('Shade', 'Richard Swift', 1, 24, 4, 4, 1500, 1),
('Doctor Light', 'Arthur Light', 1, 24, 4, 3, 1100, 1),
('Graviton', 'Franklin Hall', 1, 24, 13, 3, 1600, 1),
('Terrax', 'Tyros', 1, 2, 13, 3, 1800, 1);

SELECT "known_as"
FROM "superentity_readable"
WHERE "known_as" IN (
    SELECT DISTINCT "known_as"
    FROM "entity_order_temp"
);


DROP TABLE IF EXISTS "entity_order";

CREATE TABLE IF NOT EXISTS "order_entity" (
    "order_id" INTEGER,
    "entity_id" INTEGER,
    "selected" INTEGER NOT NULL DEFAULT 0 CHECK ("selected" BETWEEN 0 AND 1),
    PRIMARY KEY ("order_id", "entity_id"),
    CONSTRAINT fk_so_order FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT fk_so_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
);

INSERT INTO "entity_order" ("order_id","entity_id")
SELECT * FROM "entity_order_temp";

SELECT "order_id", "known_as", COUNT(*)
FROM "entity_order_temp"
GROUP BY "order_id", "known_as"
HAVING COUNT(*) > 1;


INSERT INTO "order_entity" ("order_id","entity_id")
SELECT
    oet."order_id",
    e."id" AS "entity_id"
FROM "order_entity_temp" oet
JOIN "superentity" e
    ON oet."known_as" = e."known_as"
WHERE oet."order_id" NOT IN (1,2);


DELETE FROM "order_entity"
WHERE "order_id" IN (1,2);

INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id")
VALUES
(1, 210),
(1, 544),
(1, 776),
(2, 210),
(2, 544),
(2, 776);


CREATE VIEW IF NOT EXISTS "order_entity_readable" AS
SELECT
    oe."order_id",
    o."title",
    oe."entity_id",
    e."known_as" AS "entity_known_as",
    e."full_name" AS "entity_full_name",
    oe."selected"
FROM "superentity" e
JOIN "order_entity" oe
    ON e."id" = oe."entity_id"
JOIN "order" o
    ON oe."order_id" = o."id"
ORDER BY oe."order_id";

INSERT OR IGNORE INTO "status" ("label")
VALUES
("cancelled"),
("sa_to_confirm"),
("client_to_confirm"),
("confirmed"),
("in_progress"),
("failed"),
("succeded");



CREATE TABLE IF NOT EXISTS "status" (
    "id" INTEGER PRIMARY KEY,
    "label" TEXT NOT NULL UNIQUE
);

.output temp_dump.sql

.dump entity_team_temp
.dump superentity_temp
.dump team_publisher_temp
.dump entity_power_temp
.dump order_entity_temp

.output

DROP TABLE entity_team_temp;
DROP TABLE superentity_temp;
DROP TABLE team_publisher_temp;
DROP TABLE entity_power_temp;
DROP TABLE order_entity_temp;

INSERT INTO "superentity" ("known_as", "full_name", "gender_id", "race_id", "publisher_id", "morality_rating", "fee")
VALUES ('Dionysus', 'Dionysus', 1, 63, 4, 4, 8000);

INSERT OR IGNORE INTO "superpower" ("name") VALUES
("Absolute control of wine"),
("Power bestowal");

INSERT OR IGNORE INTO "entity_power" VALUES
(903,16), -- longevity
(903,20), -- Telepathy
(903,42), -- Magic
(903,46), -- Dimensional travel
(903,48), -- shapeshifting
(903,177), -- Absolute control of wine
(903,178); -- Power bestowal


.mode list
.headers on
SELECT "superentity" FROM (
    SELECT
        e."id",
        e."known_as" AS "superentity",
        p."name" AS "superpower",
        ROW_NUMBER() OVER (ORDER BY "superhero_name") AS "enum"
    FROM "superentity" e
    JOIN "entity_power" ep
        ON ep."entity_id" = e."id"
    JOIN "superpower" p
        ON ep."power_id" = p."id"
    -- WHERE p."name" LIKE "%Power Augmentation%" -- by "name" LIKE
    WHERE p."id" IN (117) -- by set of IDs
    ORDER BY e."known_as" ASC
);


UPDATE "order_entity"
SET "entity_id" = 903
WHERE ("order_id","entity_id") = (3,39);

DELETE FROM "order_entity"
WHERE ("order_id","entity_id")
    IN ((3,347),(3,661));


UPDATE "order_entity"
SET "entity_id" = 210
WHERE ("order_id","entity_id") = (3,39);

INSERT OR IGNORE INTO "order_entity" ("order_id","entity_id") VALUES
(4,210),
(4,679);

DELETE FROM "order_entity"
WHERE ("order_id","entity_id")
    IN ((5,544));


INSERT INTO "order_entity" ("order_id","entity_id") VALUES
(14,577);

UPDATE "superentity"
SET "race_id" = 24
WHERE "id" = 577;

UPDATE "superentity"
SET "fee" = "fee" - 400
WHERE "id" IN (
    SELECT "entity_id"
    FROM "team_full"
    WHERE "team_name" = 'G.I. Joe'
);

SELECT * FROM "superentity_readable"
WHERE "id" IN (
    SELECT "entity_id"
    FROM "team_full"
    WHERE "team_name" = 'G.I. Joe'
);

| 579 | Ripcord      | Walter A. Lane                 | Female | -                 | Marvel Comics | 8               | 12500 |

UPDATE "superentity"
SET
    "gender_id" = 1,
    "race_id" = 24,
    "fee" = 1400,
    "publisher_id" = 26
WHERE "id" = 579;

INSERT INTO "entity_team" VALUES
(579,12);

INSERT INTO "order_entity" ("order_id","entity_id") VALUES
(14,471);

INSERT INTO "superpower" ("name") VALUES
("Manipulation of matter");

INSERT INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES ('The High Evolutionary', 'Herbert Wyndham', 1, 13, 13, 6, 18000, 1);

INSERT INTO "entity_power" ("entity_id","power_id") VALUES
(904,17),
(904,69),
(904,18),
(904,6),
(904,9),
(904,97),
(904,103),
(904,24),
(904,179);


INSERT OR IGNORE INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES ('Apocalypse', 'En Sabah Nur', 1, 42, 13, 3, 13000, 1);

INSERT OR IGNORE INTO superpower (id, name)
VALUES
(180, 'Biomorphing');

DELETE FROM "superentity"
WHERE "id" = 905;

INSERT OR IGNORE INTO "entity_power" ("entity_id", power_id)
VALUES
(36, 1),    -- Agility
(36, 18),   -- Super Strength
(36, 31),   -- Super Speed
(36, 26),   -- Stamina
(36, 6),    -- Durability
(36, 60),   -- Reflexes
(36, 29),   -- Dexterity
(36, 39),   -- Enhanced Senses
(36, 9),    -- Flight
(36, 50),   -- Immortality
(36, 61),   -- Invulnerability
(36, 40),   -- Telekinesis
(36, 38),   -- Teleportation
(36, 20),   -- Telepathy
(36, 73),   -- Technopath/Cyberpath
(36, 103),  -- Energy Manipulation
(36, 147),  -- Matter Absorption
(36, 63),   -- Force Fields
(36, 180),  -- Biomorphing
(36, 80),
(36, 178),
(36, 14);

-- ORDER: Teach him a superpower

INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id") VALUES
(5, 230), -- Doctor Fate
(5, 637), -- Franklin Richards
(5, 275), -- Hope Summers
(5, 340), -- Spectre
(5, 904),
(5, 36),
(5, 84);

ALTER TABLE "order_entity"
RENAME COLUMN "selected" TO "assigned";


SELECT * FROM "superentity"
WHERE "id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 4
);

SELECT "id" FROM "superentity"
WHERE "id" IN (
    SELECT
        e."id"
    FROM "superentity" e
    JOIN "entity_power" ep
        ON ep."entity_id" = e."id"
    JOIN "superpower" p
        ON ep."power_id" = p."id"
    -- WHERE p."name" LIKE "%Power Augmentation%" -- by "name" LIKE
    WHERE p."id" IN (129) -- by set of IDs
)
ORDER BY "id" ASC;

INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id") VALUES
(6,164),
(6,312),
(6,358),
(6,446),
(6,535),
(6,539),
(6,669);

SELECT
    e."id",
    e."known_as" AS "superentity",
    p."name" AS "superpower"
FROM "superentity" e
JOIN "entity_power" ep
    ON ep."entity_id" = e."id"
JOIN "superpower" p
    ON ep."power_id" = p."id"
WHERE
    p."name" = 'Water Control'
-- WHERE e -- by set of IDs
ORDER BY e."known_as" ASC;

SELECT * FROM "superentity_readable" WHERE "id" = 21;

BEGIN TRANSACTION;
DELETE FROM "order_entity"
WHERE "order_id" = 7;

SELECT * FROM "order_entity_readable";

INSERT INTO "order_entity" ("order_id","entity_id") VALUES
(7,(SELECT "id" FROM "superentity" WHERE "known_as" = 'Joker')),
(7,(SELECT "id" FROM "superentity" WHERE "known_as" = 'Amazo'));


SELECT * FROM "superentity_readable" WHERE "id" IN (
    SELECT "entity_id"
    FROM "order_entity"
    WHERE "order_id" = 8
);

DROP VIEW IF EXISTS "entity_power_readable";

CREATE VIEW IF NOT EXISTS "entity_power_readable" AS
SELECT
    e."id" AS "entity_id",
    e."known_as" AS "entity_known_as",
    e."full_name" AS "entity_full_name",
    p."id" AS "power_id",
    p."name" AS "power_name"
FROM "superentity" e
JOIN "entity_power" ep
    ON e."id" = ep."entity_id"
JOIN "superpower" p
    ON ep."power_id" = p."id"
ORDER BY e."id";

SELECT * FROM "superentity_readable"
WHERE "id" IN (
    SELECT DISTINCT "entity_id"
    FROM "entity_power_readable"
    WHERE "entity_id" IN (
        SELECT "entity_id"
        FROM "entity_power_readable"
        WHERE "power_name" LIKE '%wind%'
    )
);



-- Assign entities to orders

UPDATE "order_entity"
SET "assigned" = 1
WHERE ("order_id", "entity_id") IN (
    (1, 210),
    (2, 544),
    (3, 903),
    (4, 561),
    (5, 232),
    (6, 669),
    (7, 21),


INSERT INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES ('Weather Wizard', 'Mark Mardon', 1, 41, 4, 4, 16500, 1);

SELECT * FROM "superentity_readable" WHERE "id" = (
    SELECT MAX("id") FROM "superentity"
);

INSERT OR IGNORE INTO "entity_power" VALUES
(905,155),
(905,141),
(905,14);

INSERT OR IGNORE INTO "order_entity" ("order_id","entity_id") VALUES
(8,905);

BEGIN TRANSACTION;
UPDATE "client"
SET
    "first_name" = 'Santa',
    "last_name" = 'Claus',
    "note" = 'Ho ho ho'
WHERE "id" = 9;

SELECT * FROM "client";

UPDATE "order"
SET
    "title" = 'Gift delivey',
    "description" = 'Help Santa deliver all the presents at midnight in each location.',
    "location" = 'Lapland, Finland',
    "scheduled_start" = '2024-01-01 00:00:00',
    "started" = '2024-01-01 00:00:00',
    "scheduled_end" = '2024-01-02 00:00:00',
    "ended" = '2024-01-02 00:00:00'
WHERE "id" = 9;


INSERT INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES ('Black Racer', 'William "Willie" Walker', 1, 44, 4, 5, 18000, 1);

INSERT OR IGNORE INTO "superpower" ("name")
VALUES ('Cosmic Perceptions and Senses');

INSERT INTO "entity_power" ("entity_id", "power_id")
VALUES
(906, 50),   -- Immortality
(906, 31),   -- Super Speed
(906, 182),  -- Super-charged Brain Activity
(906, 25),   -- Density Control
(906, 106),  -- Time Travel
(906, 18),   -- Super Strength
(906, 6),    -- Durability
(906, 60),   -- Reflexes
(906, 1),    -- Agility
(906, 26),   -- Stamina
(906, 126),  -- Portal Creation
(906, 35),   -- Electrokinesis
(906, 46),   -- Dimensional Travel
(906, 132),  -- Time Manipulation
(906, 9),    -- Flight
(906, 87),   -- Intangibility
(906, 37),   -- Death Touch
(906, 174),  -- Energy Projection
(906, 8),    -- Energy Absorption
(906, 89),   -- Matter Manipulation
(906, 61),   -- Invulnerability
(906, 108),  -- Illusions
(906, 181);  -- Cosmic Perceptions and Senses


UPDATE "superentity"
SET "race_id" = 41
WHERE "id" = 756;

UPDATE "superentity"
SET "known_as" = 'Wonder Woman'
WHERE "id" = 745;

UPDATE "superentity"
SET "known_as" = 'Reverse Flash (Professor Zoom)'
WHERE "id" = 545;

DELETE FROM "order_entity"
WHERE "order_id" = 9;

BEGIN TRANSACTION;
DELETE FROM "superpower"
WHERE "id" = 182;

INSERT INTO superpower ("name")
VALUES ('Cosmic Awareness');

DELETE FROM "entity_power"
WHERE "entity_id" = 761;

INSERT INTO entity_power (entity_id, power_id)
VALUES
(761,16),
(761,41),
(761,45),
(761,62),
(761,66);

INSERT INTO "superentity" ("known_as", "full_name", "gender_id", "race_id", "publisher_id", "morality_rating", "fee", "available")
VALUES ('Phoenix Force', '-', 3, 12, 13, 9, 20000, 1);

INSERT INTO entity_power (entity_id, power_id)
VALUES
(907, 163),  -- Phoenix Force
(907, 50),   -- Immortality
(907, 20),   -- Telepathy
(907, 40),   -- Telekinesis
(907, 9),    -- Flight
(907, 149),  -- Resurrection
(907, 89),   -- Matter Manipulation
(907, 103),  -- Energy Manipulation
(907, 174),  -- Energy Projection
(907, 182),  -- Cosmic Awareness
(907, 159);  -- Reality Warping

INSERT INTO "order_entity" ("order_id", "entity_id") VALUES
(9,271),
(9,272),
(9,545),
(9,105),
(9,906),
(9,555);


INSERT INTO "order_entity" ("order_id", "entity_id") VALUES
(11,(SELECT MAX("id") FROM "superentity"));

SELECT "known_as" FROM "superentity_readable"
WHERE "id" IN (
    SELECT DISTINCT "entity_id"
    FROM "entity_power_readable"
    WHERE "entity_id" IN (
        SELECT "entity_id"
        FROM "entity_power_readable"
        WHERE "power_name" LIKE '%Time Manipulation%'
    )
);


SELECT "id" FROM "superentity_readable"
WHERE "known_as" IN (
    'Rip Hunter',
    'Cable',
    'Doctor Strange',
    'Doctor Fate',
    'Zoom'
);

INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id") VALUES
(12,149),
(12,230),
(12,232),
(12,578),
(12,756);

INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id") VALUES
(13,755),
(13,228),
(13,232),
(13,721),
(13,600);


INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id") VALUES
(14,904);



SELECT "id" FROM "superentity_readable"
WHERE "known_as" IN (
    'Storm',
    'Weather Wizard',
    'Red Tornado',
    'Doctor Fate',
    'Zoom'
);

INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id") VALUES
(15,905),
(15,197),
(15,570);


SELECT "entity_known_as" FROM "order_entity_readable"
WHERE "order_id" IN (
    16
);

UPDATE "superentity"

SET

DROP TABLE IF EXISTS "temp_top";

CREATE TABLE IF NOT EXISTS "temp_top" (
    "top" INT NOT NULL,
    "known_as" TEXT NOT NULL,
    "publisher_name" TEXT NOT NULL
);


SELECT * FROM "temp_top"
WHERE "known_as" NOT IN (
    SELECT "known_as" FROM "superentity"
);


/*
Search for LIKE but ignoring 'The '
*/
SELECT tt.*
FROM "temp_top" tt
LEFT JOIN "superentity" se
ON REPLACE(tt."known_as", 'The ', '') LIKE '%' || REPLACE(se."known_as", 'The ', '') || '%'
WHERE se."known_as" IS NULL;


INSERT INTO superpower (id, name)
VALUES (183, 'Omnipotence');

INSERT INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES ('The Source', '-', 3, 21, 4, 10, NULL, 0);


INSERT INTO entity_power (entity_id, power_id)
VALUES
(, 183),  -- Omnipotence
(, 167),  -- Omniscience
(, 166);  -- Omnipresence

BEGIN TRANSACTION;
UPDATE "superpower"
SET "name" = 'Matter manipulation'
WHERE "id" = 179;

SELECT * FROM "entity_power_readable"
WHERE "power_name" = 'Omnipotence';

BEGIN TRANSACTION;
UPDATE "entity_power"
SET "power_id" = 112
WHERE "power_id" = 183;

DELETE FROM "superpower"
WHERE "id" = 183;

UPDATE "superpower"
SET "name" = 'Omnipotence'
WHERE "id" = 112;

UPDATE "superpower"
SET "name" = CASE "id"
    WHEN 166 THEN 'Omnipresence'
    WHEN 167 THEN 'Omniscience'
    WHEN 115 THEN 'Cosmic Power'
    ELSE "name"  -- Keeps the current value for unmatched rows
END;


UPDATE "superentity"
SET
    "race_id" = (SELECT "id" FROM "race" WHERE "name" = 'Fallen Demiurgic Archangel'),
    "morality_rating" = 3,
    "fee" = NULL,
    "available" = 0
WHERE "id" = 430;

DELETE FROM "superentity"
WHERE "id" = 909;


INSERT OR IGNORE INTO "race" ("name") VALUES
('Fallen Demiurgic Archangel');


INSERT INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES (
    'Lucifer Morningstar',
    'Lucifer Morningstar',
	1,
	(SELECT "id" FROM "race" WHERE "name" = 'Fallen Demiurgic Archangel'),
	(SELECT "id" FROM "publisher" WHERE "name" = 'DC Comics'),
	3,
	NULL,
	0);


DROP TABLE IF EXISTS "power_temp";

CREATE TABLE IF NOT EXISTS "power_temp" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL UNIQUE
);

INSERT OR IGNORE INTO "power_temp" ("name") VALUES
    ('Nigh-Omnipotence'),
    ('Nigh-Omnipresence'),
    ('Omniscience'),
    ('Reality Warping'),
    ('Matter manipulation'),
    ('Energy Manipulation'),
    ('Space Manipulation'),
    ('Time Manipulation'),
    ('Omnikinesis'),
    ('Soulekinesis'),
    ('Umbrakinesis'),
    ('Destinokinesis'),
    ('Pyrokinesis'),
    ('Telekinesis'),
    ('God Strength'),
    ('Invulnerability'),
    ('Immortality'),
    ('Intelligence'),
    ('Regeneration'),
    ('Flight'),
    ('Telepathy'),
    ('Mind Control'),
    ('Shapeshifting');

UPDATE "power_temp"
SET "name" = UPPER(SUBSTR("name", 1, 1)) || LOWER(SUBSTR("name", 2));


INSERT OR IGNORE INTO "superpower" ("name")
SELECT DISTINCT "name"
FROM "power_temp"
WHERE "name" NOT IN (
    SELECT "name" FROM "superpower"
);

INSERT INTO "entity_power"
SELECT (
    SELECT "id"
    FROM "superentity"
    WHERE
        "known_as" = 'Lucifer Morningstar'
    ) AS "entity_id",
    p."id" AS "power_id"
FROM "superpower" p
WHERE p."name" IN (
    SELECT "name" FROM "power_temp"
);

INSERT OR IGNORE INTO "race" ("name") VALUES
('Demiurgic Archangel');

INSERT OR IGNORE INTO "race" ("name") VALUES
('Demiurgic Archangel');


INSERT INTO superentity (known_as, full_name, gender_id, race_id, publisher_id, morality_rating, fee, available)
VALUES (
    'Michael Demiurgos',
    'Michael Demiurgos',
	1,
	(SELECT "id" FROM "race" WHERE "name" = 'Demiurgic Archangel'),
	(SELECT "id" FROM "publisher" WHERE "name" = 'DC Comics'),
	8,
	NULL,
	0);

DROP TABLE IF EXISTS "power_temp";

CREATE TABLE IF NOT EXISTS "power_temp" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL UNIQUE
);

INSERT OR IGNORE INTO "power_temp" ("name") VALUES
    ('Nigh-Omnipotence'),
    ('Omniscience'),
    ('Omnipresence'),
    ('Cosmic Awareness'),
    ('Dimensional Travel'),
    ('Molecular dissipation'),
    ('Ectokinesis'),
    ('Eldritch Blast'),
    ('Flight'),
    ('Immortality'),
    ('Invulnerability'),
    ('Metamorphosis'),
    ('Power grant'),
    ('Reality warping'),
    ('Resurrection'),
    ('Size changing'),
    ('Agility'),
    ('Super speed'),
    ('Stamina'),
    ('Super strength'),
    ('Flight');

UPDATE "power_temp"
SET "name" = UPPER(SUBSTR("name", 1, 1)) || LOWER(SUBSTR("name", 2));

/*
SELECT "name"
FROM "power_temp"
WHERE "name" NOT IN (
    SELECT "name" FROM "superpower"
);
*/

INSERT OR IGNORE INTO "superpower" ("name")
SELECT DISTINCT "name"
FROM "power_temp"
WHERE "name" NOT IN (
    SELECT "name" FROM "superpower"
);

INSERT OR IGNORE INTO "entity_power"
SELECT (
    SELECT "id"
    FROM "superentity"
    WHERE
        "known_as" = 'Michael Demiurgos'
    ) AS "entity_id",
    p."id" AS "power_id"
FROM "superpower" p
WHERE p."name" IN (
    SELECT "name" FROM "power_temp"
);


UPDATE "superentity"
SET
    "known_as" = 'Man of miracles / Mother of Existence',
    "full_name" = 'Man of miracles / Mother of Existence',
    "gender_id" = 3,
    "race_id" = (SELECT "id" FROM "race" WHERE "name" = 'Fallen Demiurgic Archangel'),
    "morality_rating" = 9,
    "fee" = NULL,
    "available" = 0
WHERE "id" = 441;

DELETE FROM "entity_power"
WHERE "entity_id" = 441;

DROP TABLE IF EXISTS "power_temp";

CREATE TABLE IF NOT EXISTS "power_temp" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL UNIQUE
);

INSERT OR IGNORE INTO "power_temp" ("name") VALUES
    ('Omnipotence'),
    ('Omniscience'),
    ('Omnipresence'),
    ('Immortality');

UPDATE "power_temp"
SET "name" = UPPER(SUBSTR("name", 1, 1)) || LOWER(SUBSTR("name", 2));

INSERT OR IGNORE INTO "superpower" ("name")
SELECT DISTINCT "name"
FROM "power_temp"
WHERE "name" NOT IN (
    SELECT "name" FROM "superpower"
);

INSERT OR IGNORE INTO "entity_power"
SELECT (
    SELECT "id"
    FROM "superentity"
    WHERE
        "known_as" = 'Man of miracles / Mother of Existence'
    ) AS "entity_id",
    p."id" AS "power_id"
FROM "superpower" p
WHERE p."name" IN (
    SELECT "name" FROM "power_temp"
);


SELECT * FROM "superentity"
WHERE "id" IN (
    518,
    424,
    84,
    481,
    683,
    908,
    430,
    909,
    441
);

UPDATE "superentity"
SET
    "fee" = NULL,
    "available" = 0
WHERE "id" IN (
    518,
    424,
    84,
    481,
    683,
    908,
    430,
    909,
    441,
    239,
    683,
    637
);


UPDATE "superentity"
SET "full_name" = 'Spectre'
WHERE "id" = 637;



SELECT
    e."id",
    e."known_as" AS "superentity",
    p."name" AS "superpower"
FROM "superentity" e
JOIN "entity_power" ep
    ON ep."entity_id" = e."id"
JOIN "superpower" p
    ON ep."power_id" = p."id"
-- WHERE p."name" LIKE "%Power Augmentation%" -- by "name" LIKE
WHERE e."id" IN(
    518,
    424,
    84,
    481,
    683,
    908,
    430,
    909,
    441,
    239,
    683,
    637
) -- by set of IDs
ORDER BY e."known_as" ASC;


SELECT * FROM "superentity_readable" WHERE "id" = 637;

WITH "temp"("id") AS (
    VALUES
    (518),
    (424),
    (84),
    (481),
    (683),
    (908),
    (430),
    (909),
    (441),
    (239),
    (637)
)

SELECT "id" FROM "temp"
WHERE "id" NOT IN (
    SELECT DISTINCT "entity_id"
    FROM "entity_power"
    WHERE "entity_id" IS NOT NULL
);

WITH "temp"("id") AS (
    VALUES
    (518),
    (424),
    (84),
    (481),
    (683),
    (908),
    (430),
    (909),
    (441),
    (239),
    (637)
)
/*
DELETE FROM "order_entity"
WHERE ("order_id", "entity_id") IN (
    SELECT "order_id", "entity_id" FROM "order_entity_readable"
    WHERE "entity_id" IN (
        SELECT * FROM "temp"
    )
);
*/
SELECT "id" FROM "temp"
WHERE "id" IN (
    SELECT DISTINCT "entity_id"
    FROM "order_entity"
    WHERE "entity_id" IS NOT NULL
)
ORDER BY "order_id";


-- Remove unnecessary elements
DROP TABLE IF EXISTS "duplicated"
DROP TABLE IF EXISTS "order_entity_temp"
DROP TABLE IF EXISTS "temp_top"


-- Further database edition.
DROP VIEW IF EXISTS "team_full";

CREATE VIEW IF NOT EXISTS "entity_team_readable" AS
SELECT
    t."id" AS "team_id",
    t."name" AS "team_name",
    e."id" AS "entity_id",
    e."known_as",
    e."full_name"
FROM "superentity" e
JOIN "entity_team" et
    ON e."id" = et."entity_id"
JOIN "team" t
    ON et."team_id" = t."id"
ORDER BY
    "team_name" ASC,
    "known_as" ASC,
    "full_name" ASC;


-- Find duplicates

SELECT * FROM "superentity"
WHERE "known_as" IN (
    SELECT "known_as"
    FROM "superentity"
    GROUP BY "known_as"
    HAVING COUNT("known_as") > 1
)
ORDER BY "known_as";

DELETE FROM "superentity"
WHERE "id" = 808;

SELECT * FROM "entity_team"
WHERE "entity_id" = 808;

SELECT * FROM "entity_team"
WHERE "entity_id" = 786;

SELECT * FROM "entity_attribute"
WHERE "entity_id" = 786;

CREATE VIEW IF NOT EXISTS "entity_attribute_readable" AS
SELECT
    ea."entity_id",
    e."known_as" AS "entity_known_as",
    e."full_name" AS "entity_full_name",
    ea."attribute_id",
    a."name" AS "attribute_name",
    ea."attribute_value"
FROM "superentity" e
JOIN "entity_attribute" ea
    ON e."id" = ea."entity_id"
JOIN "attribute" a
    ON ea."attribute_id" = a."id"
ORDER BY "entity_id", "attribute_id";


.mode csv
.headers on
.output output.txt

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 1
    AND "attribute_value" = (
        SELECT MAX("attribute_value") AS "max_intelligence"
        FROM "entity_attribute"
        WHERE "attribute_id" = 1
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 1
    AND "attribute_value" = (
        SELECT MIN("attribute_value") AS "min_intelligence"
        FROM "entity_attribute"
        WHERE "attribute_id" = 1
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 2
    AND "attribute_value" = (
        SELECT MAX("attribute_value") AS "max_strength"
        FROM "entity_attribute"
        WHERE "attribute_id" = 2
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 2
    AND "attribute_value" = (
        SELECT MIN("attribute_value") AS "min_strength"
        FROM "entity_attribute"
        WHERE "attribute_id" = 2
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 3
    AND "attribute_value" = (
        SELECT MAX("attribute_value") AS "max_speed"
        FROM "entity_attribute"
        WHERE "attribute_id" = 3
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 3
    AND "attribute_value" = (
        SELECT MIN("attribute_value") AS "min_speed"
        FROM "entity_attribute"
        WHERE "attribute_id" = 3
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 4
    AND "attribute_value" = (
        SELECT MAX("attribute_value") AS "max_durability"
        FROM "entity_attribute"
        WHERE "attribute_id" = 4
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 4
    AND "attribute_value" = (
        SELECT MIN("attribute_value") AS "max_durability"
        FROM "entity_attribute"
        WHERE "attribute_id" = 4
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 5
    AND "attribute_value" = (
        SELECT MAX("attribute_value") AS "max_power"
        FROM "entity_attribute"
        WHERE "attribute_id" = 5
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 5
    AND "attribute_value" = (
        SELECT MIN("attribute_value") AS "max_power"
        FROM "entity_attribute"
        WHERE "attribute_id" = 5
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

SELECT "entity_known_as", "attribute_name", "attribute_value" FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 6
    AND "attribute_value" = (
        SELECT MAX("attribute_value") AS "max_combat"
        FROM "entity_attribute"
        WHERE "attribute_id" = 6
    )
GROUP BY ("attribute_id","attribue_value")
LIMIT 1;

----
-- max Speed
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 3
    AND "attribute_value" = (
        SELECT MAX("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 3
    )
LIMIT 1;

-- min Speed
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 3
    AND "attribute_value" = (
        SELECT MIN("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 3
    )
LIMIT 1;

-- max Durability
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 4
    AND "attribute_value" = (
        SELECT MAX("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 4
    )
LIMIT 1;

-- min Durability
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 4
    AND "attribute_value" = (
        SELECT MIN("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 4
    )
LIMIT 1;

-- max Power
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 5
    AND "attribute_value" = (
        SELECT MAX("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 5
    )
LIMIT 1;

-- min Power
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 5
    AND "attribute_value" = (
        SELECT MIN("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 5
    )
LIMIT 1;

-- max combat
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 6
    AND "attribute_value" = (
        SELECT MAX("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 6
    )
LIMIT 1;

-- min combat
SELECT
    "entity_known_as",
    "attribute_name",
    "attribute_value"
FROM "entity_attribute_readable"
WHERE
    "attribute_id" = 6
    AND "attribute_value" = (
        SELECT MIN("attribute_value")
        FROM "entity_attribute"
        WHERE "attribute_id" = 6
    )
LIMIT 1;


SELECT
    "id",
    "known_as" AS "entity_known_as"
FROM "superentity"
WHERE "id" NOT IN (
    SELECT DISTINCT("entity_id")
    FROM "entity_attribute"
);


SELECT * FROM "entity_attribute" WHERE "entity_id" = 7;


SELECT * FROM "superentity_readable"
WHERE
    LOWER("known_as") LIKE LOWER('%' || (
        SELECT "known_as"
        FROM "new_entity_inbox"
    ) || '%')
    OR LOWER("full_name") LIKE LOWER('%' || (
        SELECT "full_name"
        FROM "new_entity_inbox"
    ) || '%');

SELECT * FROM "superentity_readable"
WHERE
    "known_as" LIKE '%' || (
        SELECT "known_as"
        FROM "new_entity_inbox"
    ) || '%'
    OR "full_name" LIKE '%' || (
        SELECT "full_name"
        FROM "new_entity_inbox"
    ) || '%';


SELECT
    tbl_name AS 'table_name',
    sql AS 'foreign_key'
FROM
    sqlite_master
WHERE
    type = 'table'
    AND sql LIKE '%REFERENCES "superentity"%'
ORDER BY
    tbl_name;

ALTER TABLE "superentity"
ADD COLUMN "available_since" DATETIME DEFAULT NULL;

ALTER TABLE "superentity"
ADD COLUMN "unavailable_since" DATETIME DEFAULT NULL;

UPDATE "superentity"
SET "unavailable_since" = (CURRENT_TIMESTAMP)
WHERE "available" = 0;

SELECT * FROM "superentity"
WHERE "unavailable_since" IS NOT NULL
LIMIT 10;

ALTER TABLE "superentity"
DROP COLUMN "available";

ALTER TABLE "superentity"
RENAME COLUMN
    "unavailable_since"
    TO "available_since";

UPDATE "superentity"
SET "unavailable_since" = "available_since";


UPDATE "superentity"
SET "available_since" = '2024-09-25 00:56:41';


CREATE TABLE IF NOT EXISTS "entity_availability" (
    "entity_id" INTEGER NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'in' CHECK ("type" IN ('in','out')),
    "datetime" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("entity_id", "datetime")
    CONSTRAINT fk_enav_ent FOREIGN KEY ("entity_id") REFERENCES "superentity"("id")
);

INSERT OR IGNORE INTO "entity_availability"("entity_id", "type", "datetime")
SELECT "id", 'out', CURRENT_TIMESTAMP
FROM "superentity"
WHERE "unavailable_since" IS NOT NULL;

-- Search for all records of entities that has been out.
SELECT * FROM "entity_availability"
WHERE "entity_id" IN (
    SELECT "entity_id"
    FROM "entity_availability"
    WHERE "type" = 'out'
);

ALTER TABLE "superentity" DROP COLUMN "available_since";
ALTER TABLE "superentity" DROP COLUMN "unavailable_since";


WITH "availability_check" AS (
    SELECT "entity_id", "type", MAX("datetime")
    FROM "entity_availability"
    GROUP BY "entity_id"
)

DROP VIEW IF EXISTS "superentity_readable";

CREATE VIEW IF NOT EXISTS "superentity_readable" AS
SELECT
    e."id",
    e."known_as",
    e."full_name",
    g."name" AS "gender",
    r."name" AS "race",
    p."name" AS "publisher",
    e."morality_rating",
    e."fee",
    CASE
        WHEN ea."type" = 'out' THEN 0
        ELSE 1
    END AS "av"
FROM
    (SELECT "entity_id", "type", MAX("datetime")
    FROM "entity_availability"
    GROUP BY "entity_id") ea
JOIN "superentity" e
    ON ea."entity_id" = e."id"
JOIN "gender" g
    ON g."id" = e."gender_id"
JOIN "race" r
    ON r."id" = e."race_id"
JOIN "publisher" p
    ON p."id" = e."publisher_id";

-- Testing check_entity_availability trigger
INSERT OR IGNORE INTO "entity_availability" ("entity_id", "type") VALUES
(5,'out'),
(6,'out'),
(7,'out');

ALTER TABLE "entity_team"
DROP COLUMN "start";

ALTER TABLE "entity_team"
DROP COLUMN "end";

DELETE FROM "entity_availability"
WHERE "entity_id" BETWEEN 1 AND 5
AND "type" = 'out';


DROP VIEW IF EXISTS "entity_team_readable";

CREATE VIEW IF NOT EXISTS "entity_team_readable" AS
SELECT
    t."id" AS "team_id",
    t."name" AS "team_name",
    er."id" AS "entity_id",
    er."known_as",
    er."full_name",
    er."av",
    let."type" AS "member"
FROM (
    SELECT
    "entity_id",
    "team_id",
    "type",
    MAX("datetime")
    FROM "entity_team"
    GROUP BY "entity_id", "team_id"
) let
JOIN "superentity_readable" er
    ON let."entity_id" = er."id"
JOIN "entity_team" et
    ON er."id" = et."entity_id"
JOIN "team" t
    ON et."team_id" = t."id"
WHERE
    er."av" = 1
ORDER BY
    "team_name" ASC,
    "known_as" ASC,
    "full_name" ASC;


.mode csv
.headers on

SELECT name
FROM pragma_table_info("entity_team");


SELECT
    "entity_id",
    "team_id",
    "type",
    MAX("datetime")
FROM "entity_team"
GROUP BY "entity_id", "team_id";


SELECT
    "entity_id",
    "team_id",
    MAX("datetime") AS max_datetime
FROM "entity_team"
GROUP BY ("entity_id", "team_id");


ALTER TABLE "new_entity_inbox"
DELETE ROW "available";

ALTER TABLE "entity_team"
RENAME COLUMN "type" TO "status"

SELECT name AS "view_name"
FROM sqlite_master
WHERE type = 'view';

/*

+---------------------------+
|         view_name         |
+---------------------------+
| client_full               |
| duplicated                |
| order_entity_readable     |
| superentity_readable      |
| entity_team_readable      |
| entity_power_readable     |
| entity_attribute_readable |
+---------------------------+

*/

.schema order_entity_readable

ALTER TABLE "entity_team"
RENAME COLUMN "status" TO "member";

.mode csv
.headers on
SELECT name
FROM pragma_table_info("superentity");

DROP TABLE IF EXISTS "new_entity_inbox";



WITH new_entity AS (
    SELECT
        'Chapulín Colorado' AS known_as,
        'Chapulín Colorado' AS full_name,
        'Male' AS gender,
        'Human' AS race,
        3 AS publisher,
        10 AS morality_rating,
        100 AS fee
)
INSERT INTO "superentity_readable" (known_as, full_name, gender, race, publisher, morality_rating, fee)
SELECT known_as, full_name, gender, race, publisher, morality_rating, fee FROM "new_entity";


WITH new_entity AS (
    SELECT -- insert/edit values before "AS" ↓
        'Elsexto' AS known_as,
        'Elsexto' AS full_name,
        'Male' AS gender, -- gender name or id
        'Human' AS race, -- race name or id
        'DC Comics' AS publisher, -- publisher name or id
        10 AS morality_rating,
        100 AS fee
)
INSERT INTO "superentity"
    ("known_as", "full_name", "gender_id", "race_id",
    "publisher_id", "morality_rating", "fee")
SELECT
    "known_as", "full_name",
    -- Handle Gender ID lookup
    CASE
        WHEN typeof("new_entity"."gender") = 'text' THEN (
            SELECT "id" FROM "gender"
            WHERE LOWER("name") = LOWER("new_entity"."gender")
        ) ELSE "new_entity"."gender"
        END,
    -- Handle Race ID lookup
    CASE
        WHEN typeof("new_entity"."race") = 'text' THEN (
            SELECT "id" FROM "race"
            WHERE LOWER("name") = LOWER("new_entity"."race")
        ) ELSE "new_entity"."race"
        END,
    -- Handle Publisher ID lookup
    CASE
        WHEN typeof("new_entity"."publisher") = 'text' THEN (
            SELECT "id" FROM "publisher"
            WHERE LOWER("name") = LOWER("new_entity"."publisher")
        ) ELSE "new_entity"."publisher"
        END,
    "morality_rating", "fee" FROM "new_entity";




INSERT INTO "superentity_readable" (known_as) VALUES ('Listorti');

SELECT * FROM superentity ORDER BY "id" DESC LIMIT 4;

SELECT * FROM "entity_availability" WHERE "entity_id" >= 910 ORDER BY "entity_id" DESC;

SELECT * FROM superentity_readable WHERE "id" >= 910 ORDER BY "id" DESC;

PRAGMA foreign_keys=OFF;
DELETE FROM "superentity"
WHERE "id" >= 910;


-- Searching for all the tables with foreign keys referencing "superentity"
WITH all_tables AS (
  SELECT name
  FROM sqlite_master
  WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%'
)
SELECT
  all_tables.name AS table_name,
  fk.*
FROM
  all_tables,
  pragma_foreign_key_list(all_tables.name) AS fk
WHERE fk."table" = 'superentity' -- set table_name here
ORDER BY
  all_tables.name,
  fk.id,
  fk.seq;



CREATE TRIGGER "att_superentity_r_ins"
INSTEAD OF INSERT ON "superentity_readable"
FOR EACH ROW
BEGIN
    INSERT INTO "superentity" ("id", "known_as", "full_name", "gender_id", "race_id", "publisher_id", "morality_rating", "fee")
    VALUES
        (NEW."id", NEW."known_as", NEW."full_name",
        -- Gender ID handling
        (CASE
            WHEN typeof(NEW."gender") = 'text' THEN (
                SELECT "id"
                FROM "gender"
                WHERE LOWER(TRIM("name")) = LOWER(TRIM(NEW."gender"))
            )
            ELSE TRIM(NEW."gender")
        END),
        -- Race ID handling
        (CASE
            WHEN typeof(NEW."race") = 'text' THEN (
                SELECT "id"
                FROM "race"
                WHERE LOWER(TRIM("name")) = LOWER(TRIM(NEW."race"))
            )
            ELSE (TRIM(NEW."race")
        END),
        -- Publisher ID handling
        (CASE
            WHEN typeof(NEW."publisher") = 'text' THEN (
                SELECT "id"
                FROM "publisher"
                WHERE LOWER(TRIM("name")) = LOWER(TRIM(NEW."publisher"))
            )
            ELSE (TRIM(NEW."publisher")
        END),
        NEW."morality_rating", NEW."fee");
END;


.mode csv
.headers on

SELECT name
FROM sqlite_master
WHERE name NOT LIKE '%autoindex%'
AND name != 'sqlite_sequence'
AND type = 'trigger'
ORDER BY type ASC, name ASC;



DROP TRIGGER "after_superentity_ins";
DROP TRIGGER "att_superentity_r_ins";
DROP TRIGGER "check_entity_availability";
DROP TRIGGER "check_team_membership";


SELECT DISTINCT sr.*
FROM "superentity_readable" sr
JOIN "temp_superentity" ts
  ON LOWER(TRIM(sr."known_as")) LIKE '%' || LOWER(TRIM(ts."known_as")) || '%'

UNION

SELECT DISTINCT sr.*
FROM "superentity_readable" sr
JOIN "temp_superentity" ts
  ON LOWER(TRIM(sr."full_name")) LIKE '%' || LOWER(TRIM(ts."full_name")) || '%'

ORDER BY sr."known_as" ASC;



DROP TABLE IF EXISTS "test";

CREATE TABLE IF NOT EXISTS "test" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT COLLATE NOCASE DEFAULT NULL UNIQUE
);

INSERT INTO "test" VALUES
(1, 'Hola'),
(2, 'hola ');

SELECT * FROM "test" WHERE "name" = 'hola';


attribute
gender
publisher
race
superpower
superentity
team
client
order_status
entity_availability

SELECT * FROM "attribute" ORDER BY "id" DESC LIMIT 1;


.schema attribute
INSERT INTO "attribute" ("name") VALUES
('intelligence ');

SELECT * FROM "attribute";


DELETE FROM "entity_power"
WHERE "entity_id" = (
    SELECT "id" FROM "superentity"
    WHERE "known_as" = "Loki" COLLATE NOCASE
) AND "power_id" = (
    SELECT "id" FROM "superpower"
    WHERE "name" = "flight" COLLATE NOCASE
);


DROP TABLE "test";

CREATE TABLE "test" (
    "name" TEXT COLLATE NOCASE
);

INSERT INTO "test" VALUES
    ('Hola');

SELECT * FROM "test"
WHERE "name" = 'hola';


-- Create a table for colors with case-insensitive comparison
CREATE TABLE IF NOT EXISTS "colors" (
    "color_name" TEXT COLLATE NOCASE NOT NULL UNIQUE
);

-- Insert some color names into the colors table
INSERT INTO "colors" ("color_name") VALUES
    ('Red'),
    ('Blue'),
    ('Green');

-- Create a table for items with a color column (case-insensitive)
CREATE TABLE IF NOT EXISTS "items" (
    "item_color" TEXT COLLATE NOCASE NOT NULL
);

-- Insert some colors into the items table
-- Notice 'red' and 'blue' are lowercase but should match 'Red' and 'Blue'
INSERT INTO "items" ("item_color") VALUES
    ('red'),
    ('blue'),
    ('yellow');  -- This one doesn't exist in the colors table

-- Find colors in the items table that are not in the colors table
-- This is case-insensitive
SELECT DISTINCT "item_color"
FROM "items"
WHERE TRIM("item_color") NOT IN (
    SELECT TRIM("color_name") COLLATE NOCASE FROM "colors"
);


/*
Chapulín Colorado
Boogerman
Zan
Jayna

Arm-Fall-Off-Boy
Dogwelder
The Hypno-Hustler
The Walrus, Marvel
Frog-Man, Eugene Patilio, Marvel

Thundercats:
    Lion-O (Thundercats)
    Panthro (Thundercats)
    Cheetara (Thundercats)
    Tygra (Thundercats)
    Snarf (Thundercats)
    Jackalman (Thundercats)

*/


.schema "temp_superentity"

-- Testing some TRIGGERS
INSERT INTO "superentity" ("known_as") VALUES (TRIM('   Test   '));
INSERT INTO "attribute" ("name") VALUES (TRIM('   Test2   '));
INSERT INTO "gender" ("name") VALUES (TRIM('   Test   '));
INSERT INTO "publisher" ("name") VALUES (TRIM('   Test   '));
INSERT INTO "race" ("name") VALUES (TRIM('   Test   '));
INSERT INTO "superpower" ("name") VALUES (TRIM('   Test   '));
INSERT INTO "team" ("name") VALUES (TRIM('   Test   '));
INSERT INTO "client" ("first_name", "last_name", "phone") VALUES (TRIM('   Test   '), TRIM('   Test   '),TRIM('   Test   '));
SELECT * FROM "superentity" ORDER BY "id" DESC LIMIT 1;
SELECT * FROM "attribute" ORDER BY "id" DESC LIMIT 1;
SELECT * FROM "gender" ORDER BY "id" DESC LIMIT 1;
SELECT * FROM "publisher" ORDER BY "id" DESC LIMIT 1;
SELECT * FROM "race" ORDER BY "id" DESC LIMIT 1;
SELECT * FROM "superpower" ORDER BY "id" DESC LIMIT 1;
SELECT * FROM "team" ORDER BY "id" DESC LIMIT 1;
SELECT * FROM "client" ORDER BY "id" DESC LIMIT 1;


INSERT INTO "superentity_readable" VALUES
(NULL, '  Test  ', '  Test  ', '  MALE  ', '  human  ', '  dc COMICS  ', 7, 12000, 'out');


SELECT sql
FROM SQLITE_master
WHERE
    "name" = 'attribute_unique_trim_insert'
    OR "name" = 'attribute_unique_trim_nocase_insert';

SELECT name
FROM sqlite_master
WHERE
    name NOT LIKE '%autoindex%'
    AND name != 'sqlite_sequence'
    AND type = 'trigger'
ORDER BY name ASC;


DROP TRIGGER IF EXISTS "attribute_trim_after_insert";
DROP TRIGGER IF EXISTS "attribute_trim_after_update";
DROP TRIGGER IF EXISTS "attribute_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "attribute_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "check_entity_availability";
DROP TRIGGER IF EXISTS "check_team_membership";
DROP TRIGGER IF EXISTS "client_trim_after_insert";
DROP TRIGGER IF EXISTS "client_trim_after_update";
DROP TRIGGER IF EXISTS "client_unique_phone_trim_nocase_insert";
DROP TRIGGER IF EXISTS "client_unique_phone_trim_nocase_update";
DROP TRIGGER IF EXISTS "entity_availability_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "entity_availability_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "gender_trim_after_insert";
DROP TRIGGER IF EXISTS "gender_trim_after_update";
DROP TRIGGER IF EXISTS "gender_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "gender_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "new_superentity_availability";
DROP TRIGGER IF EXISTS "order_status_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "order_status_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "publisher_trim_after_insert";
DROP TRIGGER IF EXISTS "publisher_trim_after_update";
DROP TRIGGER IF EXISTS "publisher_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "publisher_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "race_trim_after_insert";
DROP TRIGGER IF EXISTS "race_trim_after_update";
DROP TRIGGER IF EXISTS "race_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "race_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "superentity_trim_after_insert";
DROP TRIGGER IF EXISTS "superentity_trim_after_update";
DROP TRIGGER IF EXISTS "superentity_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "superentity_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "superpower_trim_after_insert";
DROP TRIGGER IF EXISTS "superpower_trim_after_update";
DROP TRIGGER IF EXISTS "superpower_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "superpower_unique_trim_nocase_update";
DROP TRIGGER IF EXISTS "team_trim_after_insert";
DROP TRIGGER IF EXISTS "team_trim_after_update";
DROP TRIGGER IF EXISTS "team_unique_trim_nocase_insert";
DROP TRIGGER IF EXISTS "team_unique_trim_nocase_update";

DROP TRIGGER IF EXISTS "attribute_unique_trim_insert";
DROP TRIGGER IF EXISTS "attribute_unique_trim_update";
DROP TRIGGER IF EXISTS "gender_unique_trim_insert";
DROP TRIGGER IF EXISTS "gender_unique_trim_update";
DROP TRIGGER IF EXISTS "publisher_unique_trim_insert";
DROP TRIGGER IF EXISTS "publisher_unique_trim_update";


SELECT name, sql
FROM SQLITE_master
WHERE
    "name" = 'check_entity_availability'
    OR "name" = 'new_superentity_availability';

.mode list
.separator "\n\n"


SELECT sql
FROM (
    SELECT sql, name
    FROM SQLITE_master
    WHERE type = 'trigger'
    UNION ALL
    SELECT '', name  -- This adds an empty line after each row
    FROM SQLITE_master
    WHERE type = 'trigger'
    ORDER BY name ASC
);


SELECT sql
FROM SQLITE_master
WHERE type = 'trigger'
ORDER BY name ASC;


-- > Legacy direct insertions of only ONE record at a time.

-- Method "value AS field"
WITH "new_entity" AS (
    SELECT -- Insert/edit values before "AS" ↓
        (SELECT MAX("id") + 1 FROM "superentity") AS "id",
        'Some name' AS "known_as",
        'full_name NULL' AS "full_name",
        'gender' NULL AS "gender", -- gender name or id
        'race' NULL AS "race", -- race name or id
        'publisher' NULL AS "publisher", -- publisher name or id
        morality_rating NULL AS "morality_rating",
        fee NULL AS "fee"
)
    -- └> Do not change this statment from here ↓.
INSERT INTO "superentity" (
    "known_as", "full_name", "gender_id", "race_id", "publisher_id", "morality_rating", "fee"
) SELECT
    "known_as", "full_name",
    -- Handle Gender ID lookup
    CASE
        WHEN typeof("new_entity"."gender") = 'text' THEN (
            SELECT "id" FROM "gender"
            WHERE "name" = "new_entity"."gender" COLLATE NOCASE
        ) ELSE "new_entity"."gender"
        END,
    -- Handle Race ID lookup
    CASE
        WHEN typeof("new_entity"."race") = 'text' THEN (
            SELECT "id" FROM "race"
            WHERE "name" = "new_entity"."race" COLLATE NOCASE
        ) ELSE "new_entity"."race"
        END,
    -- Handle Publisher ID lookup
    CASE
        WHEN typeof("new_entity"."publisher") = 'text' THEN (
            SELECT "id" FROM "publisher"
            WHERE "name" = "new_entity"."publisher" COLLATE NOCASE
        ) ELSE "new_entity"."publisher"
        END,
    "morality_rating", "fee" FROM "new_entity";


-- PAYMENT
CREATE TABLE IF NOT EXISTS "payment" (
    "id" INTEGER PRIMARY KEY,
    "datetime" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "client_id" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL
)


INSERT INTO "payment" ("datetime", "client_id", "amount")
SELECT "created_at", "client_id", "paid"
FROM "order"
WHERE "paid" != 0;

SELECT * FROM "payment";


ALTER TABLE "order"
DROP COLUMN "paid";


-- Fixing: Runtime error: error in view entity_attribute_readable: no such column: er.av
DROP VIEW IF EXISTS "entity_attribute_readable";

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
ORDER BY eat."entity_id", eat."attribute_id";


-- ORDER_READABLE

-- Total paid by client
SELECT "client_id", SUM("amount") AS "total_paid"
FROM "payment"
GROUP BY "client_id"
ORDER BY "client_id";

-- Total debt by client
-- └> fixed
SELECT "client_id", SUM("fixed_price")
FROM "order"
WHERE "fixed_price" IS NOT NULL
GROUP BY "client_id"
ORDER BY "client_id";

-- └> hourly
SELECT
    "client_id",
    "hourly_price" * (
        ROUND((SUM(JULIANDAY("ended") - JULIANDAY("started")) * 24), 2)
    ) AS "hourly_debt"
FROM "order"
WHERE
    "ended" IS NOT NULL
    AND "hourly_price" IS NOT NULL
GROUP BY "client_id"
ORDER BY "client_id";


-- Combined table with total_fixed_debt, total_hourly_debt, total_paid and total_debt
SELECT
    "client_id",
    "total_fixed_debt",
    "total_hourly_debt",
    "subtotal_debt",
    "total_paid",
    CAST(ROUND(subtotal_debt - total_paid) AS INTEGER) AS "total_debt"
FROM (
    SELECT
        COALESCE(fixed."client_id", hourly."client_id", paid."client_id") AS "client_id",
        COALESCE(fixed."total_fixed_debt", 0) AS "total_fixed_debt",
        CAST(ROUND(COALESCE(hourly."total_hourly_debt", 0)) AS INTEGER) AS "total_hourly_debt",
        CAST(ROUND(COALESCE(fixed."total_fixed_debt", 0)
            + COALESCE(hourly."total_hourly_debt", 0)) AS INTEGER) AS "subtotal_debt",
        COALESCE(paid."total_paid", 0) AS "total_paid"
    FROM
        -- Subquery for total fixed debt
        (
            SELECT "client_id", SUM("fixed_price") AS "total_fixed_debt"
            FROM "order"
            WHERE "fixed_price" IS NOT NULL
            GROUP BY "client_id"
        ) AS fixed
    FULL OUTER JOIN
        -- Subquery for total hourly debt
        (
            SELECT
                "client_id",
                SUM("hourly_price" * ROUND((JULIANDAY("ended") - JULIANDAY("started")) * 24, 2)) AS "total_hourly_debt"
            FROM "order"
            WHERE "ended" IS NOT NULL AND "hourly_price" IS NOT NULL
            GROUP BY "client_id"
        ) AS hourly
    ON fixed."client_id" = hourly."client_id"
    FULL OUTER JOIN
        -- Subquery for total payment
        (
            SELECT "client_id", SUM("amount") AS "total_paid"
            FROM "payment"
            GROUP BY "client_id"
        ) AS paid
    ON COALESCE(fixed."client_id", hourly."client_id") = paid."client_id"
) AS debts
ORDER BY client_id;


client."id" AS ""
-- Combined table with total_fixed_fee, total_hourly_fee, total_paid and balance
CREATE VIEW IF NOT EXISTS "client_payment_balance" AS
SELECT
    "client_id",
    "total_fixed_fee",
    "total_hourly_fee",
    "total_fee",
    "total_paid",
    CAST(ROUND(total_paid - total_fee) AS INTEGER) AS "balance"
FROM (
    SELECT
        "client"."id" AS "client_id",
        COALESCE(fixed."total_fixed_fee", 0) AS "total_fixed_fee",
        CAST(ROUND(COALESCE(hourly."total_hourly_fee", 0)) AS INTEGER) AS "total_hourly_fee",
        CAST(ROUND(COALESCE(fixed."total_fixed_fee", 0)
            + COALESCE(hourly."total_hourly_fee", 0)) AS INTEGER) AS "total_fee",
        COALESCE(paid."total_paid", 0) AS "total_paid"
    FROM "client"
    LEFT JOIN
        -- Subquery for total fixed fee
        (
            SELECT "client_id", SUM("fixed_price") AS "total_fixed_fee"
            FROM "order"
            WHERE "fixed_price" IS NOT NULL
            GROUP BY "client_id"
        ) AS fixed
        ON "client"."id" = fixed."client_id"
    LEFT JOIN
        -- Subquery for total hourly fee
        (
            SELECT
                "client_id",
                SUM("hourly_price" * ROUND((JULIANDAY("ended") - JULIANDAY("started")) * 24, 2)) AS "total_hourly_fee"
            FROM "order"
            WHERE "ended" IS NOT NULL AND "hourly_price" IS NOT NULL
            GROUP BY "client_id"
        ) AS hourly
        ON "client"."id" = hourly."client_id"
    LEFT JOIN
        -- Subquery for total payment
        (
            SELECT "client_id", SUM("amount") AS "total_paid"
            FROM "payment"
            GROUP BY "client_id"
        ) AS paid
        ON "client"."id" = paid."client_id"
    ) AS fees
ORDER BY client_id;


/*

"scheduled_end", "scheduled_start"

*/

INSERT INTO "payment" ("client_id", "amount") VALUES
(14, 4000);

.mode csv
.headers on

SELECT name
FROM pragma_table_info('order');

CREATE VIEW IF NOT EXISTS "order_readable" AS
SELECT
    o."id" AS "order_id",
    o."client_id",
    c."first_name"
    c."last_name"
    o."created_at",
    o."title",
    o."location",
    o."description",
    o."scheduled_start",
    o."started",
    o."scheduled_end",
    o."ended",
    o."fixed_price",
    o."hourly_price",
    o."paid",
    o."status_id",

ALTER TABLE "order"
DROP COLUMN "paid";

DROP TRIGGER "entity_team_before_insert_check";

CREATE TRIGGER "entity_team_before_insert_check"
BEFORE INSERT ON "entity_team"
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (
            (SELECT "member"
             FROM "entity_team"
             WHERE
                "entity_id" = NEW."entity_id"
                AND "team_id" = NEW."team_id"
             ORDER BY "datetime" DESC
             LIMIT 1) = 'in'
        )
        AND NEW."member" = 'in'
        THEN
            RAISE(FAIL, 'One or more of those entities are already in the team.')
        WHEN (
            (SELECT "member"
             FROM "entity_team"
             WHERE
                "entity_id" = NEW."entity_id"
                AND "team_id" = NEW."team_id"
             ORDER BY "datetime" DESC
             LIMIT 1) = 'out'
        ) AND NEW."member" = 'out'
        THEN
            RAISE(FAIL, 'One or more of those entities are already out of the team.')
    END;
END;


CREATE VIEW "client_full" AS
    WITH "client_last_order" AS (
        SELECT "client_id", MAX("created_at") AS "last_order"
        FROM "order"
        GROUP BY "client_id"
    )

    SELECT
        c."id",
        c."first_name",
        c."last_name",
        c."phone",
        COUNT(o."id") AS "total_orders",
        SUM(o."paid") AS "total_paid",
        l."last_order"
    FROM "client" c
    JOIN "order" o
        ON c."id" = o."client_id"
    JOIN "client_last_order" l
        ON o."client_id" = l."client_id"
    GROUP BY c."id"
    ORDER BY c."id"


DROP VIEW "client_full";

CREATE VIEW "client_full" AS
    WITH "client_last_order" AS (
        SELECT "client_id", MAX("created_at") AS "last_order_at"
        FROM "order"
        GROUP BY "client_id"
    )

    SELECT
        c."id",
        c."first_name",
        c."last_name",
        c."phone",
        COUNT(o."id") AS "total_orders",
        cpb."total_paid",
        l."last_order_at"
    FROM "client" c
    JOIN "order" o
        ON c."id" = o."client_id"
    JOIN "client_payment_balance" cpb
        ON c."id" = cpb."client_id"
    JOIN "client_last_order" l
        ON c."id" = l."client_id"
    GROUP BY c."id"
    ORDER BY c."id"
;


WITH all_elements AS (
  SELECT name
  FROM sqlite_master
  WHERE name NOT LIKE 'sqlite_%'
)
SELECT
  all_elements.name AS element_name,
  fk.*
FROM
  all_elements,
  pragma_foreign_key_list(all_elements.name) AS fk
WHERE fk."table" = 'order' -- set element_name here
ORDER BY
  all_elements.name,
  fk.id,
  fk.seq;

-------------------

DROP VIEW IF EXISTS "order_entity_readable";
DROP VIEW IF EXISTS "client_payment_balance";
DROP VIEW IF EXISTS "client_full";

CREATE VIEW "order_entity_readable" AS
SELECT
    oe."order_id",
    o."title",
    oe."entity_id",
    e."known_as" AS "entity_known_as",
    e."full_name" AS "entity_full_name",
    oe."assigned"
FROM "superentity" e
JOIN "order_entity" oe
    ON e."id" = oe."entity_id"
JOIN "order" o
    ON oe."order_id" = o."id"
ORDER BY oe."order_id";


CREATE VIEW "client_payment_balance" AS
SELECT
    "client_id",
    "total_fixed_fee",
    "total_hourly_fee",
    "total_fee",
    "total_paid",
    CAST(ROUND(total_paid - total_fee) AS INTEGER) AS "balance"
FROM (
    SELECT
        "client"."id" AS "client_id",
        COALESCE(fixed."total_fixed_fee", 0) AS "total_fixed_fee",
        CAST(ROUND(COALESCE(hourly."total_hourly_fee", 0)) AS INTEGER) AS "total_hourly_fee",
        CAST(ROUND(COALESCE(fixed."total_fixed_fee", 0)
            + COALESCE(hourly."total_hourly_fee", 0)) AS INTEGER) AS "total_fee",
        COALESCE(paid."total_paid", 0) AS "total_paid"
    FROM "client"
    LEFT JOIN
        -- Subquery for total fixed fee
        (
            SELECT "client_id", SUM("fixed_price") AS "total_fixed_fee"
            FROM "order"
            WHERE "fixed_price" IS NOT NULL
            GROUP BY "client_id"
        ) AS fixed
        ON "client"."id" = fixed."client_id"
    LEFT JOIN
        -- Subquery for total hourly fee
        (
            SELECT
                "client_id",
                SUM("hourly_price" * ROUND((JULIANDAY("ended") - JULIANDAY("started")) * 24, 2)) AS "total_hourly_fee"
            FROM "order"
            WHERE "ended" IS NOT NULL AND "hourly_price" IS NOT NULL
            GROUP BY "client_id"
        ) AS hourly
        ON "client"."id" = hourly."client_id"
    LEFT JOIN
        -- Subquery for total payment
        (
            SELECT "client_id", SUM("amount") AS "total_paid"
            FROM "payment"
            GROUP BY "client_id"
        ) AS paid
        ON "client"."id" = paid."client_id"
    ) AS fees
ORDER BY client_id;

CREATE VIEW "client_full" AS
    WITH "client_last_order" AS (
        SELECT "client_id", MAX("created_at") AS "last_order_at"
        FROM "order"
        GROUP BY "client_id"
    )

    SELECT
        c."id",
        c."first_name",
        c."last_name",
        c."phone",
        COUNT(o."id") AS "total_orders",
        cpb."total_paid",
        l."last_order_at"
    FROM "client" c
    JOIN "order" o
        ON c."id" = o."client_id"
    JOIN "client_payment_balance" cpb
        ON c."id" = cpb."client_id"
    JOIN "client_last_order" l
        ON c."id" = l."client_id"
    GROUP BY c."id"
    ORDER BY c."id";


.mode csv
.headers on


SELECT
    ROW_NUMBER()
        OVER (ORDER BY type ASC, name ASC)
        AS "total_count", -- Total count over all rows
    ROW_NUMBER()
        OVER (PARTITION BY type ORDER BY name ASC)
        AS "type_count", -- Type-specific count
    name,
    type
FROM
    sqlite_master
WHERE
    name NOT LIKE 'sqlite_%'
ORDER BY
    type ASC,
    name ASC;



UPDATE "superentity"
SET ("morality_rating","fee") = (5, 21000)
WHERE "id" = 600;


SELECT * FROM "superentity"
WHERE "full_name" IN ('-', '');


UPDATE "superentity"
SET "full_name" = "known_as"
WHERE "full_name" IN ('-', '');

SELECT * FROM "superentity"
WHERE "id" IN (907, 908);


-- Output all view's sqls (schemas) separated by 2 empty lines
.mode list
.separator "\n\n"

SELECT
    CASE
        WHEN sql != '' THEN sql || ';'
        ELSE ''
    END AS sql
FROM (
    SELECT sql, name
    FROM SQLITE_master
    WHERE type = 'view'
    UNION ALL
    SELECT '', name -- First empty line
    FROM SQLITE_master
    WHERE type = 'view'
    UNION ALL
    SELECT '', name -- Second empty line
    FROM SQLITE_master
    WHERE type = 'view'
    ORDER BY name ASC
);

-- Output all triggers's sqls (schemas) separated by 2 empty lines
.mode list
.separator "\n\n"
.once triggers_ok.sql

SELECT
    CASE
        WHEN sql != '' THEN sql || ';'
        ELSE ''
    END AS sql
FROM (
    SELECT sql, name
    FROM SQLITE_master
    WHERE type = 'trigger'
    UNION ALL
    SELECT '', name -- First empty line
    FROM SQLITE_master
    WHERE type = 'trigger'
    UNION ALL
    SELECT '', name -- Second empty line
    FROM SQLITE_master
    WHERE type = 'trigger'
    ORDER BY name ASC
);


CREATE TABLE "db" (
    "id" INTEGER,
    "name" TEXT,
    "type" TEXT
);

CREATE TABLE "db_bu" (
    "id" INTEGER,
    "name" TEXT,
    "type" TEXT
);

.import --csv --skip 1 output.csv db
.import --csv --skip 1 output_bu.csv db_bu

ALTER TABLE "db"
DROP COLUMN "id";

ALTER TABLE "db_bu"
DROP COLUMN "id";

SELECT * FROM "db"

UNION

SELECT * FROM "db_bu"
GROUP BY ("name", "type")
HAVING COUNT("name", "type") = 1
ORDER BY "name";


SELECT *
FROM (
    SELECT * FROM "db"
    UNION ALL
    SELECT * FROM "db_bu"
) AS combined
GROUP BY "name", "type"
HAVING COUNT(*) = 1
ORDER BY "name";

SELECT *, 'absent in db_bu' AS status FROM "db"
EXCEPT
SELECT *, 'absent in db_bu' AS status FROM "db_bu"

UNION

SELECT *, 'absent in db' AS status FROM "db_bu"
EXCEPT
SELECT *, 'absent in db' AS status FROM "db"
ORDER BY "name";


.mode csv
.headers on
SELECT * FROM "db" ORDER BY "name";


CREATE TABLE "db_bu" (
    "name" TEXT,
    "type" TEXT
);


CREATE TABLE "triggers_from_drop" (
    "name" TEXT,
    "type" TEXT
);

CREATE TABLE "triggers_from_create" (
    "name" TEXT,
    "type" TEXT
);

.import --csv --skip 1 triggers_from_drop.csv triggers_from_drop
.import --csv --skip 1 triggers_from_create.csv triggers_from_create


SELECT *, 'absent in create' AS status FROM "triggers_from_drop"
EXCEPT
SELECT *, 'absent in create' AS status FROM "triggers_from_create"

UNION

SELECT *, 'absent in drop' AS status FROM "triggers_from_create"
EXCEPT
SELECT *, 'absent in drop' AS status FROM "triggers_from_drop"
ORDER BY "name";


SELECT DISTINCT t1.*
FROM "triggers_from_create" t1
JOIN "triggers_from_create" t2
ON t1."name" = t2."name"
WHERE t1."rowid" <> t2."rowid"
ORDER BY t1."name";

BEGIN;
UPDATE "client"
SET "id" = CASE "id"
    WHEN 8 THEN 16
    WHEN 16 THEN 8
    ELSE "id"  -- Keeps the current value for unmatched rows
END;

.mode csv
SELECT name
FROM pragma_table_info ('order');

.mode table


INSERT INTO "order" (
    client_id,
    created_at,
    title,
    location,
    description,
    scheduled_start,
    started,
    scheduled_end,
    ended,
    fixed_price,
    hourly_price,
    status_id
)
SELECT
    client_id,
    created_at,
    title,
    location,
    description,
    scheduled_start,
    started,
    scheduled_end,
    ended,
    fixed_price,
    hourly_price,
    status_id
FROM "order"
WHERE "id" = 8;


UPDATE "order"
SET "id" = CASE "id"
    WHEN 17 THEN 8
    WHEN 18 THEN 16
    ELSE "id"
END;


.mode csv
SELECT name
FROM pragma_table_info ('client');

.mode table

INSERT INTO "client" (
    first_name,
    last_name,
    phone,
    note
)
SELECT
    first_name,
    last_name,
    '+64-21-123-4568',
    note
FROM "client"
WHERE "id" = 8;

SELECT * FROM "client"
ORDER BY "id" DESC;

PRAGMA foreign_keys = OFF;
BEGIN;

DELETE FROM "client" WHERE "id" = 16;
DELETE FROM "client" WHERE "id" = 8;

UPDATE "client"
SET "id" = CASE "id"
    WHEN 18 THEN 16
    WHEN 17 THEN 8
    ELSE "id"
END;


UPDATE "order_entity"
SET "id" = CASE "id"
    WHEN 18 THEN 16
    WHEN 17 THEN 8
    ELSE "id"
END;


INSERT INTO order_entity VALUES(8,902,1);
INSERT INTO order_entity VALUES(8,901,0);

INSERT INTO order_entity VALUES(16,661,0);
INSERT INTO order_entity VALUES(16,570,0);
INSERT INTO order_entity VALUES(16,898,0);
INSERT INTO order_entity VALUES(16,905,1);

UPDATE "entity_power"
SET "power_id" = 18
WHERE "power_id" = 184;

SELECT * FROM "entity_power_readable"
WHERE "power_id" = 155;

SELECT * FROM "entity_power_readable"
WHERE "entity_id" = 197;

.mode csv
.headers on

SELECT "known_as" FROM "superentity"
WHERE "id" IN (
    SELECT "entity_id" FROM "order_entity"
    WHERE "order_id" = 7
);

SELECT * FROM "attribute";

SELECT * FROM "entity_attribute"
WHERE "entity_id" = 667;

SELECT "id" FROM "superentity"
WHERE "known_as" LIKE 'Green Lantern%';

/*
307,
911,
308,
309,
311,
*/

INSERT INTO "superpower" ("name") VALUES
('Imaginpotence');

INSERT INTO "entity_power" VALUES
    (307,62),
    (911,62),
    (308,62),
    (309,62),
    (311,62),
    (307,9),
    (911,9),
    (308,9),
    (309,9),
    (311,9),
    (307,63),
    (911,63),
    (308,63),
    (309,63),
    (311,63),
    (307,18),
    (911,18),
    (308,18),
    (309,18),
    (311,18),
    (307,6),
    (911,6),
    (308,6),
    (309,6),
    (311,6),
    (307,22),
    (911,22),
    (308,22),
    (309,22),
    (311,22),
    (307,31),
    (911,31),
    (308,31),
    (309,31),
    (311,31),
    (307,125),
    (911,125),
    (308,125),
    (309,125),
    (311,125),
    (307,2),
    (911,2),
    (308,2),
    (309,2),
    (311,2),
    (307,97),
    (911,97),
    (308,97),
    (309,97),
    (311,97),
    (307,214),
    (911,214),
    (308,214),
    (309,214),
    (311,214);


139, Brainiac
356, Iron man
520, Oracle
200, Cyborg
705, Ultron
231, Doctor Octopus
128, Blue Bettle (Theodore Kord)
274, Forge
228, Docter Doom
70, Batgirl IV Cassandra Cain
437, Machine Man
419, Lex Luthor

DELETE FROM "order_entity"
WHERE "order_id" = 14;

INSERT INTO "entity_power" VALUES
    (661,)

.mode csv

SELECT * FROM "superpower";


INSERT INTO entity_power (entity_id, power_id) VALUES (661, 141);
INSERT INTO entity_power (entity_id, power_id) VALUES (661, 155);
INSERT INTO entity_power (entity_id, power_id) VALUES (661, 35);
INSERT INTO entity_power (entity_id, power_id) VALUES (661, 207);
INSERT INTO entity_power (entity_id, power_id) VALUES (661, 9);


SELECT
    tbl_name AS 'table_name', -- do not change this
    sql
FROM
    sqlite_master
WHERE
    type = 'table'
    AND sql LIKE '%REFERENCES "order"%' -- set table_name here
ORDER BY
    tbl_name;


PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = ON;
BEGIN;
CREATE TABLE "order_tmp" (
    "id" INTEGER PRIMARY KEY,
    "client_id" INTEGER NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "title" TEXT COLLATE NOCASE NOT NULL,
    "location" TEXT COLLATE NOCASE NOT NULL,
    "description" TEXT COLLATE NOCASE NOT NULL,
    "scheduled_start" DATETIME DEFAULT NULL,
    "scheduled_end" DATETIME,
    "started" DATETIME,
    "ended" DATETIME,
    "fixed_price" INTEGER,
    "hourly_price" INTEGER,
    "status_id" INTEGER NOT NULL DEFAULT 2,
    CHECK ("scheduled_end" IS NULL OR "scheduled_end" >= "scheduled_start"),
    CHECK ("ended" IS NULL OR "ended" >= "started"),
    CONSTRAINT fk_order_client FOREIGN KEY ("client_id") REFERENCES "client"("id"),
    CONSTRAINT fk_order_status FOREIGN KEY ("status_id") REFERENCES "order_status"("id")
);
INSERT INTO "order_tmp" ("id", "client_id", "created_at", "title", "location", "description", "scheduled_start", "scheduled_end", "started", "ended", "fixed_price", "hourly_price", "status_id") SELECT "id", "client_id", "created_at", "title", "location", "description", "scheduled_start", "scheduled_end", "started", "ended", "fixed_price", "hourly_price", "status_id" FROM "order";
DROP TABLE "order";
ALTER TABLE "order_tmp" RENAME TO "order";
COMMIT;
PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = OFF;


.once order.txt
.dump order


.mode csv
SELECT name
FROM pragma_table_info ("superentity");


WITH all_tables AS (
  SELECT name
  FROM sqlite_master
  WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%'
)
SELECT
  all_tables.name AS table_name,
  fk.*
FROM
  all_tables,
  pragma_foreign_key_list(all_tables.name) AS fk
WHERE fk."table" = 'order' -- set table_name here
ORDER BY
  all_tables.name,
  fk.id,
  fk.seq;


BEGIN;
UPDATE "superentity"
SET "race_id" = CASE "id"
    WHEN 334 THEN 67
    WHEN 276 THEN 24
    ELSE "race_id"
END;

UPDATE "superentity"
SET "gender_id" = 1
WHERE "id" = 276;


SELECT *
FROM sqlite_master
WHERE
    sql LIKE '%MAX("datetime")%'
    || '% FROM "entity_availability"%';


.once output.txt
SELECT *
FROM sqlite_master
WHERE
    type = 'view'
    AND sql LIKE '%superentity_readable%';


CREATE VIEW "temp_entity_power_readable" AS
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
    e."id";



CREATE VIEW "temp_entity_team_readable" AS
SELECT
    t."id" AS "team_id",
    t."name" AS "team_name",
    e."id" AS "entity_id",
    e."known_as",
    e."full_name",
    ea."status",
    let."member"
FROM
    (SELECT "entity_id", "team_id", "member", MAX("datetime")
     FROM "entity_team"
     GROUP BY "entity_id", "team_id") let
JOIN
    "superentity" e ON let."entity_id" = e."id"
LEFT JOIN
    (SELECT "entity_id", "status", MAX("datetime")
     FROM "entity_availability"
     GROUP BY "entity_id") ea ON ea."entity_id" = e."id"
JOIN
    "entity_team" et ON e."id" = et."entity_id"
JOIN
    "team" t ON et."team_id" = t."id"
ORDER BY
    t."name" ASC,
    e."known_as" ASC,
    e."full_name" ASC;



.once output.txt
SELECT *
FROM sqlite_master
WHERE
    type = 'view'
    AND sql LIKE '%superentity_readable%';

-- Searching for Multiple Keyword Occurrences
SELECT *
FROM sqlite_master
WHERE
    type = 'view'
    AND INSTR(SUBSTR(sql, INSTR(sql, 'readable') + LENGTH('readable')), 'readable') > 0;

DROP VIEW "temp_entity_power_readable";
DROP VIEW "temp_entity_team_readable";

.mode csv
.headers on
.once superentity_with_fees.csv
SELECT * FROM "superentity";

BEGIN;
ALTER TABLE "superentity"
DROP COLUMN "fee";

SELECT name
FROM pragma_table_info ("superentity");


-- Testing view without hourly fee
CREATE VIEW IF NOT EXISTS "temp_client_payment_balance" AS
SELECT
    "client"."id" AS "client_id",
    COALESCE(fixed."total_fixed_fee", 0) AS "total_charged",
    COALESCE(paid."total_paid", 0) AS "total_paid",
    CAST(ROUND(COALESCE(paid."total_paid", 0) - COALESCE(fixed."total_fixed_fee", 0)) AS INTEGER) AS "balance"
FROM "client"
LEFT JOIN (
        SELECT "client_id", SUM("fixed_price") AS "total_fixed_fee"
        FROM "order"
        WHERE "fixed_price" IS NOT NULL
        GROUP BY "client_id"
    ) AS fixed
    ON "client"."id" = fixed."client_id"
LEFT JOIN (
        SELECT "client_id", SUM("amount") AS "total_paid"
        FROM "payment"
        GROUP BY "client_id"
    ) AS paid
    ON "client"."id" = paid."client_id"
ORDER BY "client"."id";


DROP VIEW IF EXISTS "temp_client_payment_balance";


.mode list

SELECT ('DROP ' || UPPER(type) || ' IF EXISTS "' || (name) ||'";') AS "command"
FROM sqlite_master
WHERE name NOT LIKE 'sqlite_%';

.mode table

WITH "entity_power_filtered" AS (
    SELECT
        p."name" AS "superpower",
        er."id" AS "entity_id",
        er."known_as" AS "superentity",
        er."morality_rating"
    FROM "superentity_readable" er
    JOIN "entity_power" ep
        ON ep."entity_id" = er."id"
    JOIN "superpower" p
        ON ep."power_id" = p."id"
    WHERE (
        p."name" LIKE "%wind%"
        OR p."name" LIKE "%weather%"
    )
        AND er."status" = 'in'
        AND er."morality_rating" <= 7
    ORDER BY er."known_as" ASC
)
SELECT DISTINCT 16, "entity_id", 0
FROM "entity_power_filtered";


WITH "entity_power_filtered" AS (
    SELECT
        p."name" AS "superpower",
        er."id" AS "entity_id",
        er."known_as" AS "superentity",
        er."morality_rating"
    FROM "superentity_readable" er
    JOIN "entity_power" ep
        ON ep."entity_id" = er."id"
    JOIN "superpower" p
        ON ep."power_id" = p."id"
    WHERE (
        p."name" LIKE "%wind%"
        OR p."name" LIKE "%weather%"
    )
        AND er."status" = 'in'
        AND er."morality_rating" <= 7
    ORDER BY er."known_as" ASC
)
INSERT OR IGNORE INTO "order_entity" ("order_id", "entity_id", "assigned")
SELECT DISTINCT 16, "entity_id", 0
FROM "entity_power_filtered";


.mode list

WITH "entity_power_filtered" AS (
-- from here (for full result) ↓
    SELECT
        p."name" AS "superpower",
        er."id" AS "entity_id",
        er."known_as" AS "superentity",
        er."morality_rating"
    FROM "superentity_readable" er
    JOIN "entity_power" ep
        ON ep."entity_id" = er."id"
    JOIN "superpower" p
        ON ep."power_id" = p."id"
    WHERE (
        p."name" LIKE "%wind%" -- by "name" LIKE
        -- OR p."name" LIKE "%weather%"
    )
    -- WHERE er."id" IN (428) -- by set of IDs
        AND er."status" = 'in' -- status
        AND er."morality_rating"
    ORDER BY er."known_as" ASC
-- up to here (for full result) ↑ add ;
)
SELECT DISTINCT "superentity"
FROM "entity_power_filtered";


.mode csv
.headers on
SELECT * FROM "attribute";

.schema "attribute"

SELECT * FROM "entity_attribute"
WHERE "entity_id" IN (
    73, -- Batman
    667, -- Superman
    685, -- Thor
    577 -- Riddler
);

SELECT "id", "known_as", "full_name", "publisher"
FROM "superentity_readable"
WHERE "id" > 911;


WITH "superentity_selection" AS (
    SELECT * FROM "superentity"
    WHERE "id" > 911
)

INSERT INTO "temp_superentity"
SELECT *, 'in' AS "status"
FROM "superentity"
WHERE "id" > 911;

CREATE TABLE "temp_superentity_bu" AS
SELECT * FROM "temp_superentity";

BEGIN;
DELETE FROM "superentity"
WHERE "id" > 911;

SELECT * FROM "superentity" ORDER BY "id" DESC LIMIT 5;


SELECT * FROM "superentity_readable" ORDER BY "id" DESC LIMIT 11;

SELECT * FROM "gender"
ORDER BY "id" DESC LIMIT 5;

.once output.txt
SELECT rowid, * FROM "temp_superentity";



-- Testing type-affinity
DROP TABLE example;

-- With type-affinity
CREATE TABLE example (
    mixed_column TEXT
);

-- Without type-affinity
CREATE TABLE example (
    mixed_column
);


INSERT INTO example (mixed_column) VALUES ('string'), (42);

SELECT *,
    CASE typeof(mixed_column)
        WHEN 'integer' THEN 'This is an integer'
        WHEN 'text' THEN 'This is text'
        ELSE 'Other type'
    END AS type_info
FROM example;

SELECT CAST(mixed_column AS INTEGER) AS integer_value
FROM example
WHERE typeof(mixed_column) = 'integer';

-- New entities's attributes insertion.
-- Aero
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(912, 1, 80),  -- Intelligence
(912, 2, 60),  -- Strength
(912, 3, 90),  -- Speed
(912, 4, 70),  -- Durability
(912, 5, 85),  -- Power
(912, 6, 65);  -- Combat

-- Cyclone
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(913, 1, 75),  -- Intelligence
(913, 2, 50),  -- Strength
(913, 3, 80),  -- Speed
(913, 4, 60),  -- Durability
(913, 5, 90),  -- Power
(913, 6, 55);  -- Combat

-- Wind Dancer
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(914, 1, 70),  -- Intelligence
(914, 2, 45),  -- Strength
(914, 3, 85),  -- Speed
(914, 4, 65),  -- Durability
(914, 5, 88),  -- Power
(914, 6, 60);  -- Combat

-- Whirlwind
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(915, 1, 65),  -- Intelligence
(915, 2, 70),  -- Strength
(915, 3, 85),  -- Speed
(915, 4, 75),  -- Durability
(915, 5, 80),  -- Power
(915, 6, 70);  -- Combat

-- Typhoon
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(916, 1, 60),  -- Intelligence
(916, 2, 80),  -- Strength
(916, 3, 75),  -- Speed
(916, 4, 85),  -- Durability
(916, 5, 85),  -- Power
(916, 6, 65);  -- Combat

-- Avatar Aang
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(917, 1, 95),  -- Intelligence
(917, 2, 50),  -- Strength
(917, 3, 95),  -- Speed
(917, 4, 70),  -- Durability
(917, 5, 100), -- Power
(917, 6, 90);  -- Combat

-- Windstorm (Marvel Comics)
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(918, 1, 65),  -- Intelligence
(918, 2, 55),  -- Strength
(918, 3, 85),  -- Speed
(918, 4, 60),  -- Durability
(918, 5, 75),  -- Power
(918, 6, 50);  -- Combat

-- Windstorm (DC Comics)
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(919, 1, 60),  -- Intelligence
(919, 2, 60),  -- Strength
(919, 3, 80),  -- Speed
(919, 4, 65),  -- Durability
(919, 5, 70),  -- Power
(919, 6, 55);  -- Combat

-- Silver Sorceress
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(920, 1, 85),  -- Intelligence
(920, 2, 45),  -- Strength
(920, 3, 65),  -- Speed
(920, 4, 55),  -- Durability
(920, 5, 95),  -- Power
(920, 6, 70);  -- Combat

-- Monsoon
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(921, 1, 65),  -- Intelligence
(921, 2, 70),  -- Strength
(921, 3, 75),  -- Speed
(921, 4, 70),  -- Durability
(921, 5, 80),  -- Power
(921, 6, 60);  -- Combat

-- Hurricane
INSERT INTO "entity_attribute" ("entity_id", "attribute_id", "attribute_value") VALUES
(922, 1, 60),  -- Intelligence
(922, 2, 65),  -- Strength
(922, 3, 75),  -- Speed
(922, 4, 65),  -- Durability
(922, 5, 75),  -- Power
(922, 6, 60);  -- Combat


INSERT INTO "team" ("name")
VALUES ('Star Trek');

INSERT INTO "entity_team" ("entity_id", "team_id")
SELECT
    "id",
    (SELECT "id" FROM "team" WHERE "name" = 'Star Trek') AS "team_name"
FROM "superentity_readable"
WHERE "publisher" = 'Star Trek';

SELECT * FROM "entity_team_readable"
WHERE "team_name" = 'Star Trek';

INSERT INTO "team" ("name")
VALUES ('South Park');

INSERT INTO "entity_team" ("entity_id", "team_id")
SELECT
    "id",
    (SELECT "id" FROM "team" WHERE "name" = 'South Park') AS "team_name"
FROM "superentity_readable"
WHERE "publisher" = 'South Park';

----- PUBLISHER REVIEW -----

SELECT * FROM "publisher";

id,name
1,-
2,"ABC Studios"
3,"Dark Horse Comics"
4,"DC Comics"
5,"George Lucas"
6,Hanna-Barbera
7,HarperCollins
8,"Icon Comics"
9,"IDW Publishing"
10,"Image Comics"
11,"J. K. Rowling"
12,"J. R. R. Tolkien"
13,"Marvel Comics"
14,Microsoft
15,"NBC - Heroes"
16,Rebellion
17,Shueisha
18,"Sony Pictures"
19,"South Park"
20,"Star Trek"
21,SyFy
22,"Team Epic TV"
23,"Titan Books"
24,"Universal Studios"
25,Wildstorm
26,Hasbro
27,"DC Thomson"
28,Nickelodeon


SELECT "id", "known_as", "full_name"
FROM "superentity"
WHERE "publisher_id" IS NULL;

id,known_as,full_name
859,Bloodshot,"Ray Garrison"
862,Harbinger,"Peter Stanchek"
329,He-Man,"Prince Adam of Eternia"
363,"James Bond (Craig)","James Bond"
861,Ninjak,"Colin King"
863,Shadowman,"Jack Boniface"
613,She-Ra,Adora
860,"X-O Manowar","Aric of Dacia"


SELECT "id", "known_as", "full_name"
FROM "superentity"
WHERE "publisher_id" = '1';


UPDATE "superentity"
SET "publisher_id" = 1
WHERE "publisher_id" IN (
    2,  -- ABC Studios
    5,  -- George Lucas
    6,  -- Hanna-Barbera
    11, -- J. K. Rowling
    12, -- J. R. R. Tolkien
    14, -- Microsoft
    15, -- NBC - Heroes
    18, -- Sony Pictures
    19, -- South Park
    20, -- Star Trek
    21, -- SyFy
    22, -- Team Epic TV
    24, -- Universal Studios
    26  -- Hasbro
);

SELECT * FROM "superentity_readable" LIMIT 20;


DELETE FROM "publisher"
WHERE "id" NOT IN (
    SELECT DISTINCT "publisher_id"
    FROM "superentity"
    ORDER BY "publisher_id" ASC
);

SELECT * FROM "publisher";

SELECT * FROM "superentity"
WHERE "publisher_id" = 29;

UPDATE "superentity"
SET "publisher_id" = 1
WHERE "id" = 917;

DELETE FROM "publisher"
WHERE "id" = 29;
-----------------


INSERT INTO "superentity_readable"
VALUES (NULL,'Jayna', 'Jayna', 'Alala', 'Exxorian', 'DC Comics ', 9, 'in');

SELECT * FROM "gender";
DELETE FROM "gender"
WHERE "id" = "4";

SELECT * FROM "superentity_readable" ORDER BY "id" DESC LIMIT 5;

SELECT * FROM "entity_availability" ORDER BY "entity_id" DESC LIMIT 5;


DELETE FROM "superentity"
WHERE "id" = 923;

INSERT INTO "superentity_readable" ("known_as")
VALUES ('Test5');


--------------

CREATE TABLE IF NOT EXISTS "config_insert_trigger" (
    "mode" TEXT NOCASE,
    CHECK ("mode" IN ('strict','ignore'))
);


SELECT * FROM "config_insert_trigger";

DELETE FROM "config_insert_trigger";

INSERT OR REPLACE INTO "config_insert_trigger" ("mode") VALUES ('strict');
INSERT OR REPLACE INTO "config_insert_trigger" ("mode") VALUES ('ignore');


SELECT * FROM "superentity_readable" ORDER BY "id" DESC LIMIT 4;

SELECT * FROM "superentity_readable"
WHERE "id" > 922;

SELECT * FROM "entity_availability" ORDER BY "entity_id" DESC LIMIT 1;


DELETE FROM "superentity"
WHERE "id" > 922;

SELECT * FROM "entity_availability"
WHERE "entity_id" > 922;

SELECT * FROM "race"
WHERE "name" = 'Exxorian';

SELECT * FROM "race"
ORDER BY "id" DESC LIMIT 5;

DELETE FROM "race"
WHERE "name" = 'Exxorian';

INSERT INTO superentity VALUES(923,'Jayna','Jayna',2,69,4,9);
INSERT OR IGNORE INTO superentity VALUES(923,'TEST','TEST',2,68,4,9);
INSERT INTO superentity VALUES(1000,'TEST2','TEST',2,68,4,9);
INSERT INTO superentity VALUES(1001,' TEST2','TEST',2,68,4,9);

DELETE FROM "superentity"
WHERE "id" = 925;

SELECT * FROM "superentity"
WHERE
    "known_as" LIKE '%Jayna%'
    OR "full_name" LIKE '%Jayna%';


INSERT INTO "superentity_readable" (
    /*"id", */"known_as", "full_name", "gender", "race", "publisher", "morality_rating", "status"
) VALUES
    ('  Alala', '  Jayna', 'Female', 'Exxorian', 'DC Comics ', 9, 'out');


INSERT OR IGNORE INTO "superentity_readable" (
    "id", "known_as", "full_name", "gender", "race", "publisher", "morality_rating"
) VALUES
    (923, 'Jayna', 'Jayna', 2,69,4,9);


INSERT OR IGNORE INTO "superentity_readable" (
    "id", "known_as", "full_name", "gender", "race", "publisher", "morality_rating"
) VALUES
    (923, 'Jayna', 'Jayna', 'Female', 'Exxorian', 'DC Comics ', 9);



INSERT OR IGNORE INTO "superentity_readable" (
    "id", "known_as", "full_name", "gender", "race", "publisher", "morality_rating"
) VALUES
    (NULL, 'Jayna', 'Jayna', 'Female', 'Exxorian', 'DC Comics ', 9);


INSERT OR IGNORE INTO "superentity_readable" (
    /*"id", */"known_as", "full_name", "gender", "race", "publisher", "morality_rating"
) VALUES
    ('Jayna', 'Jayna', 'Female', 'Exxorian', 'DC Comics ', 9),
    ('Test6', 'asd', 'Female', 'Exxorian', 'DC Comics ', 9),
    --(' Testosterona', 'asd', 'Female', 'Exxorian', 'DC Comics ', 9),
    ('Zan', 'Zan', 'Male', 'Exxorian', 'DC Comics', 9);

-- Output all the triggers
SELECT name
FROM sqlite_master
WHERE type = 'trigger';


SELECT changes()
FROM "superentity";


.mode list
.once output.txt
SELECT ('DROP ' || UPPER(type) || ' IF EXISTS "' || (name) ||'";') AS "command"
FROM sqlite_master
WHERE
    name NOT LIKE 'sqlite_%'
    AND name LIKE '%before%'
    AND type = 'trigger';



.mode list
.separator "\n\n"
.once output.txt
SELECT
    CASE
        WHEN sql != '' THEN sql || ';'
        ELSE ''
    END AS sql
FROM (
    SELECT sql, name
    FROM SQLITE_master
    WHERE
        type = 'trigger'
        AND name LIKE '%before%'
    UNION ALL
    SELECT '', name -- First empty line
    FROM SQLITE_master
    WHERE type = 'trigger'
    UNION ALL
    SELECT '', name -- Second empty line
    FROM SQLITE_master
    WHERE type = 'trigger'
    ORDER BY name ASC
);


.mode list
.separator "\n"
.headers off
.once output.txt
WITH RECURSIVE
numbers(n) AS (
    SELECT 0 UNION ALL SELECT n + 1 FROM numbers WHERE n < 2
),
trigger_rows AS (
    SELECT sql || ';' as sql, name, 0 as row_type
    FROM sqlite_master
    WHERE type = 'trigger'
),
expanded_rows AS (
    SELECT
        CASE
            WHEN n = 0 THEN sql
            ELSE ''
        END as sql,
        name,
        ROW_NUMBER() OVER (ORDER BY name, n) as rn
    FROM trigger_rows
    CROSS JOIN numbers
)
SELECT sql
FROM expanded_rows
ORDER BY rn;


.mode list
.headers off
.once output.txt
SELECT ('DROP ' || UPPER(type) || ' IF EXISTS "' || (name) ||'";') AS "command"
FROM sqlite_master
WHERE
    name NOT LIKE 'sqlite_%'
    AND type = 'trigger'
ORDER BY name;


.mode list
.separator "\n"
.once output.txt
WITH RECURSIVE
numbers(n) AS (
    SELECT 0 UNION ALL SELECT n + 1 FROM numbers WHERE n < 2
),
trigger_rows AS (
    SELECT sql || ';' as sql, name, 0 as row_type
    FROM sqlite_master
    WHERE type = 'trigger' AND name NOT LIKE '%before%'
),
expanded_rows AS (
    SELECT
        CASE
            WHEN n = 0 THEN sql
            ELSE ''
        END as sql,
        name,
        ROW_NUMBER() OVER (ORDER BY name, n) as rn
    FROM trigger_rows
    CROSS JOIN numbers
)
SELECT sql
FROM expanded_rows
ORDER BY rn;


.mode table
SELECT * FROM "entity_power_readable"
WHERE "entity_id" = (
    SELECT "entity_id"
    FROM (
        SELECT "entity_id", MAX("power_count") AS "max_power_count"
        FROM (
            SELECT "entity_id", COUNT("power_id") AS "power_count"
            FROM "entity_power"
            GROUP BY "entity_id"
        )
    )
);


.once output.txt
.schema

.once dump.sql
.dump


CREATE TABLE IF NOT EXISTS "order_status_applied" (
    "order_id" INTEGER NOT NULL,
    "status_id" INTEGER NOT NULL,
    "datetime" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("order_id", "datetime"),
    CONSTRAINT fk_order_status_applied_order FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT fk_order_status_applied_order_status FOREIGN KEY ("status_id") REFERENCES "order_status"("id") ON DELETE CASCADE
);


.mode csv
.output output.txt
SELECT "id", 7 AS "status_label", "ended"
FROM "order"
WHERE "ended" IS NOT NULL;


INSERT INTO "order_status_applied" ("order_id","status_id","datetime")
VALUES
-- 2 → sa to confirm
(1,2,"2023-01-02 14:30:00"),
(2,2,"2023-02-15 09:45:00"),
(3,2,"2023-03-01 11:10:00"),
(4,2,"2023-04-12 17:25:00"),
(5,2,"2023-05-04 12:50:00"),
(6,2,"2023-06-06 13:15:00"),
(7,2,"2023-07-09 15:20:00"),
(8,2,"2023-10-05 10:00:00"),
(9,2,"2023-12-20 18:30:00"),
(10,2,"2024-08-10 07:40:00"),
(11,2,"2024-09-14 14:55:00"),
(12,2,"2024-09-22 09:45:00"),
(13,2,"2024-10-03 11:15:00"),
(14,2,"2024-10-28 14:20:00"),
(15,2,"2024-11-01 13:40:00"),
(16,2,"2024-11-17 16:05:00"),
-- 3 → client to confirm
(1,3,"2023-01-02 14:40:00"),
(2,3,"2023-02-15 09:55:00"),
(3,3,"2023-03-01 11:20:00"),
(4,3,"2023-04-12 17:35:00"),
(5,3,"2023-05-04 13:00:00"),
(6,3,"2023-06-06 13:25:00"),
(7,3,"2023-07-09 15:30:00"),
(8,3,"2023-10-05 10:10:00"),
(9,3,"2023-12-20 18:40:00"),
(10,3,"2024-08-10 07:50:00"),
(11,3,"2024-09-14 15:05:00"),
(12,3,"2024-09-22 09:55:00"),
(13,3,"2024-10-03 11:25:00"),
(14,3,"2024-10-28 14:30:00"),
(15,3,"2024-11-01 13:50:00"),
(16,3,"2024-11-17 16:15:00"),
-- 1 → Cancelled
(8,1,"2023-10-06 10:00:00"),
-- 4 → Confirmed
(1,4,"2023-01-02 15:40:00"),
(2,4,"2023-02-15 10:55:00"),
(3,4,"2023-03-01 12:20:00"),
(4,4,"2023-04-12 18:35:00"),
(5,4,"2023-05-04 14:00:00"),
(6,4,"2023-06-06 14:25:00"),
(7,4,"2023-07-09 16:30:00"),
(9,4,"2023-12-20 19:40:00"),
(10,4,"2024-08-10 08:50:00"),
(11,4,"2024-09-14 16:05:00"),
(12,4,"2024-09-22 10:55:00"),
(13,4,"2024-10-03 12:25:00"),
(14,4,"2024-10-28 15:30:00"),
(15,4,"2024-11-01 14:50:00"),
(16,4,"2024-11-17 17:15:00"),
-- 5 → Ongoing
(1,5,"2023-01-10 08:00:00"),
(2,5,"2023-02-20 07:00:00"),
(3,5,"2023-03-05 18:00:00"),
(4,5,"2023-04-21 10:00:00"),
(5,5,"2023-05-10 09:00:00"),
(6,5,"2023-06-10 07:00:00"),
(7,5,"2023-07-15 12:00:00"),
(9,5,"2023-11-25 00:00:00"),
(10,5,"2024-08-28 08:30:00"),
(11,5,"2024-09-15 09:05:00"),
(12,5,"2024-10-20 07:00:00"),
(13,5,"2024-11-07 08:00:00"),
(16,5,"2024-11-16 02:21:01"),
-- 6 → Failed
(4,6,"2023-04-21 10:10:00"),
-- 7 → Succeded
(1,7,"2023-01-17 17:00:00"),
(2,7,"2023-02-21 07:00:00"),
(3,7,"2023-03-05 20:00:00"),
(5,7,"2023-05-13 18:00:00"),
(7,7,"2023-07-16 20:30:00"),
(9,7,"2023-11-26 00:00:00"),
(10,7,"2024-08-28 23:00:00"),
(11,7,"2024-09-15 09:07:00"),
(12,7,"2024-10-20 07:30:00"),
(16,7,"2024-11-16 02:24:24");


-- Outputs the names of the columns of "order" table.
SELECT name
FROM pragma_table_info ("order");


-- Outputs the inserts command for the order table v.2
.output output.txt
.mode insert "order"
SELECT
    "id",
    "client_id",
    "created_at",
    "title",
    "location",
    "description",
    "scheduled_start",
    "scheduled_end"
FROM
    "order";


CREATE TABLE IF NOT EXISTS "order_entity_requested" (
    "order_id" INTEGER NOT NULL,
    "requested_entity_id" INTEGER NOT NULL,
    CONSTRAINT "fk_ord_ent_req_order" FOREIGN KEY("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT "fk_ord_ent_req_ent" FOREIGN KEY("requested_entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
);



WITH all_tables AS (
  SELECT name
  FROM sqlite_master
  WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%'
)
SELECT
  all_tables.name AS table_name,
  fk.*
FROM
  all_tables,
  pragma_foreign_key_list(all_tables.name) AS fk
WHERE fk."table" = 'order' -- set table_name here
ORDER BY
  all_tables.name,
  fk.id,
  fk.seq;


.once output.txt
SELECT name, sql
FROM sqlite_master
WHERE sql LIKE '%"order"%';



.mode list
.separator "\n"
.once output.txt
WITH RECURSIVE
numbers(n) AS (
    SELECT 0 UNION ALL SELECT n + 1 FROM numbers WHERE n < 2
),
"rows" AS (
    SELECT sql || ';' as sql, name, 0 as row_type
    FROM sqlite_master
    WHERE -- set the conditions
	    name NOT LIKE 'sqlite_%' -- to ignore elements generated automatically
        AND sql LIKE '%"order"%'
),
expanded_rows AS (
    SELECT
        CASE
            WHEN n = 0 THEN sql
            ELSE ''
        END as sql,
        name,
        ROW_NUMBER() OVER (ORDER BY name, n) as rn
    FROM "rows"
    CROSS JOIN numbers
)
SELECT sql
FROM expanded_rows
ORDER BY rn;




-- "order_readable" VIEW creation

CREATE VIEW IF NOT EXISTS "order_readable" AS
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
ORDER BY o."id" ASC;


.output output.txt
.schema order
.schema order_status
.schema order_status_applied


.mode insert "order"
SELECT
    "id",
    "client_id",
    "created_at",
    "title",
    "location",
    "description",
    "scheduled_start",
    "scheduled_end",
    "fixed_price"
FROM "order";


CREATE TRIGGER IF NOT EXISTS "order_after_insert_insert_order_status"
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



INSERT INTO "order" (/*"id",*/ "client_id", "created_at", "title", "location", "description", "scheduled_start", "scheduled_end", "fixed_price")
VALUES (
    /*16, -- id*/
    16, -- client_id
    CURRENT_TIMESTAMP, -- created_at
    'TEST', -- title
    'TEST', -- location
    'TEST', -- description
    '2024-11-18 00:00:00', -- scheduled_start
    '2024-11-18 16:00:00', -- scheduled_end
    NULL -- fixed_price
);

.once output.txt
SELECT * FROM "order_readable";
SELECT * FROM "client_full";


DROP TABLE IF EXISTS "order_entity_requested";
CREATE TABLE "order_entity_requested" (
    "order_id" INTEGER NOT NULL,
    "entity_id" INTEGER NOT NULL,
    CONSTRAINT "fk_ord_ent_req_order" FOREIGN KEY("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT "fk_ord_ent_req_ent" FOREIGN KEY("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
);

DROP VIEW IF EXISTS "order_entity_requested_readable";
CREATE VIEW IF NOT EXISTS "order_entity_requested_readable" AS
SELECT
    oer."order_id",
    oer."entity_id",
    sr."known_as",
    sr."full_name",
    sr."publisher",
    sr."morality_rating",
    sr."status"
FROM "order_entity_requested" oer
INNER JOIN "superentity_readable" sr ON oer."entity_id" = sr."id"
ORDER BY oer."order_id", "entity_id";

SELECT * FROM "order_entity_requested_readable";

BEGIN;
PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = ON;

CREATE TABLE "order_entity_tmp" (
    "order_id" INTEGER,
    "entity_id" INTEGER,
    "requested" INTEGER NOT NULL DEFAULT 0 CHECK ("requested" BETWEEN 0 AND 1),
    "assigned" INTEGER NOT NULL DEFAULT 0 CHECK ("assigned" BETWEEN 0 AND 1),
    PRIMARY KEY ("order_id", "entity_id"),
    CONSTRAINT fk_so_order FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT fk_so_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
);


INSERT INTO "order_entity_tmp" (
    "order_id",
    "entity_id",
    "requested",
    "assigned"
)
SELECT
    "order_id",
    "entity_id",
    0 AS "requested",
    "assigned"
FROM "order_entity";

DROP TABLE "order_entity";

ALTER TABLE "order_entity_tmp"
RENAME TO "order_entity";


COMMIT;
PRAGMA legacy_alter_table = OFF;
PRAGMA foreign_keys = ON;

DROP VIEW "order_entity_requested_readable";
DROP TABLE "order_entity_requested";

-- Fixing "entity_team_readable" view
DROP VIEW IF EXISTS "entity_team_readable";
CREATE VIEW IF NOT EXISTS "entity_team_readable" AS
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
    e."full_name" ASC;



SELECT name
FROM sqlite_master
WHERE type = 'trigger';

.mode list
SELECT name
FROM sqlite_master
WHERE type = 'view';


SELECT * FROM "entity_team"
WHERE "entity_id" IN (923,924);

600 Wanda
454 Maxima
544 Professor X


SELECT
    name/*,
    sql*/
FROM
    sqlite_master
WHERE
    type IN ('table','view','trigger')
    AND sql LIKE '%REFERENCES "client_full"%' -- set table_name here
ORDER BY
    name;



CREATE VIEW "client_full" AS
    WITH "client_last_order" AS (
        SELECT "client_id", MAX("created_at") AS "last_order_at"
        FROM "order"
        GROUP BY "client_id"
    )

    SELECT
        c."id",
        c."first_name",
        c."last_name",
        c."phone",
        COUNT(o."id") AS "total_orders",
        cpb."total_paid",
        l."last_order_at"
    FROM "client" c
    JOIN "order" o
        ON c."id" = o."client_id"
    JOIN "client_payment_balance" cpb
        ON c."id" = cpb."client_id"
    JOIN "client_last_order" l
        ON c."id" = l."client_id"
    GROUP BY c."id"
    ORDER BY c."id"


CREATE VIEW "client_payment_balance" AS
SELECT
    "client"."id" AS "client_id",
    COALESCE(fixed."total_fixed_fee", 0) AS "total_charged",
    COALESCE(paid."total_paid", 0) AS "total_paid",
    CAST(ROUND(COALESCE(paid."total_paid", 0) - COALESCE(fixed."total_fixed_fee", 0)) AS INTEGER) AS "balance"
FROM "client"
JOIN (
        SELECT "client_id", SUM("fixed_price") AS "total_fixed_fee"
        FROM "order"
        WHERE
            "fixed_price" IS NOT NULL
            AND "status_id" NOT IN (1)
        GROUP BY "client_id"
    ) AS fixed
    ON "client"."id" = fixed."client_id"
LEFT JOIN (
        SELECT "client_id", SUM("amount") AS "total_paid"
        FROM "payment"
        GROUP BY "client_id"
    ) AS paid
    ON "client"."id" = paid."client_id"
ORDER BY "client"."id"


CREATE VIEW "client_full_2" AS
WITH "client_payment_balance" AS (
    SELECT
        "client"."id" AS "client_id",
        COALESCE(SUM(CASE WHEN "order"."fixed_price" IS NOT NULL AND "order"."status_id" NOT IN (1) THEN "order"."fixed_price" ELSE 0 END), 0) AS "total_charged",
        COALESCE(SUM("payment"."amount"), 0) AS "total_paid",
        CAST(ROUND(COALESCE(SUM("payment"."amount"), 0) - COALESCE(SUM(CASE WHEN "order"."fixed_price" IS NOT NULL AND "order"."status_id" NOT IN (1) THEN "order"."fixed_price" ELSE 0 END), 0)) AS INTEGER) AS "balance"
    FROM "client"
    LEFT JOIN "order"
        ON "client"."id" = "order"."client_id"
    LEFT JOIN "payment"
        ON "client"."id" = "payment"."client_id"
    GROUP BY "client"."id"
),
"client_last_order" AS (
    SELECT "client_id", MAX("created_at") AS "last_order_at"
    FROM "order"
    GROUP BY "client_id"
)
SELECT
    c."id",
    c."first_name",
    c."last_name",
    c."phone",
    COUNT(o."id") AS "total_orders",
    cpb."total_charged",
    cpb."total_paid",
    cpb."balance",
    l."last_order_at"
FROM "client" c
JOIN "order" o
    ON c."id" = o."client_id"
JOIN "client_payment_balance" cpb
    ON c."id" = cpb."client_id"
JOIN "client_last_order" l
    ON c."id" = l."client_id"
GROUP BY c."id"
ORDER BY c."id";


CREATE VIEW "client_full_3" AS
SELECT
    c."id",
    c."first_name",
    c."last_name",
    c."phone",
    COUNT(o."id") AS "total_orders",
    COALESCE(fixed."total_fixed_fee", 0) AS "total_charged",
    COALESCE(paid."total_paid", 0) AS "total_paid",
    CAST(ROUND(COALESCE(paid."total_paid", 0) - COALESCE(fixed."total_fixed_fee", 0)) AS INTEGER) AS "balance",
    MAX(o."created_at") AS "last_order_at"
FROM "client" c
JOIN "order" o ON c."id" = o."client_id"
LEFT JOIN (
    SELECT "client_id", SUM("fixed_price") AS "total_fixed_fee"
    FROM "order"
    WHERE "fixed_price" IS NOT NULL AND "status_id" NOT IN (1)
    GROUP BY "client_id"
) fixed ON c."id" = fixed."client_id"
LEFT JOIN (
    SELECT "client_id", SUM("amount") AS "total_paid"
    FROM "payment"
    GROUP BY "client_id"
) paid ON c."id" = paid."client_id"
GROUP BY c."id"
ORDER BY c."id";


CREATE VIEW "client_full" AS
SELECT
    c."id",
    c."first_name",
    c."last_name",
    c."phone",
    COUNT(o."id") AS "total_orders",
    COALESCE(fixed."total_fixed_fee", 0) AS "total_charged",
    COALESCE(paid."total_paid", 0) AS "total_paid",
    CAST(ROUND(COALESCE(paid."total_paid", 0) - COALESCE(fixed."total_fixed_fee", 0)) AS INTEGER) AS "balance",
    COALESCE(MAX(o."created_at"), "didn't order") AS "last_order_at"  -- Default date for clients with no orders
FROM "client" c
LEFT JOIN "order" o ON c."id" = o."client_id"
LEFT JOIN (
    SELECT "client_id", SUM("fixed_price") AS "total_fixed_fee"
    FROM "order"
    WHERE "fixed_price" IS NOT NULL AND "status_id" NOT IN (1)
    GROUP BY "client_id"
) fixed ON c."id" = fixed."client_id"
LEFT JOIN (
    SELECT "client_id", SUM("amount") AS "total_paid"
    FROM "payment"
    GROUP BY "client_id"
) paid ON c."id" = paid."client_id"
GROUP BY c."id"
ORDER BY c."id";

DROP VIEW IF EXISTS "client_full_4";
DROP VIEW IF EXISTS "client_full_2";
DROP VIEW IF EXISTS "client_full_3";
DROP VIEW IF EXISTS "client_full";
DROP VIEW IF EXISTS "client_payment_balance";


.mode list
SELECT name
FROM sqlite_master
WHERE
    type = 'table'
    AND name NOT LIKE '%temp%'
ORDER BY name;


.mode list
SELECT name
FROM sqlite_master
WHERE
    type = 'table'
ORDER BY name;

.mode list
SELECT name
FROM sqlite_master
WHERE
    type = 'trigger'
ORDER BY name;


.mode list
SELECT name
FROM pragma_table_info('client');


.once output.txt
.schema order


PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = ON;
BEGIN;
CREATE TABLE "order_tmp" (
    "id" INTEGER PRIMARY KEY,
    "client_id" INTEGER NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "title" TEXT COLLATE NOCASE NOT NULL,
    "location" TEXT COLLATE NOCASE NOT NULL,
    "description" TEXT COLLATE NOCASE NOT NULL,
    "scheduled_start" DATETIME NOT NULL,
    "scheduled_end" DATETIME DEFAULT NULL,
    "fixed_price" INTEGER DEFAULT NULL,
    CHECK ("scheduled_end" IS NULL OR "scheduled_end" >= "scheduled_start"),
    CONSTRAINT fk_order_client FOREIGN KEY ("client_id") REFERENCES "client"("id")
);
INSERT INTO "order_tmp" ("id", "client_id", "created_at", "title", "location", "description", "scheduled_start", "scheduled_end", "fixed_price") SELECT "id", "client_id", "created_at", "title", "location", "description", "scheduled_start", "scheduled_end", "fixed_price" FROM "order";
DROP TABLE "order";
ALTER TABLE "order_tmp" RENAME TO "order";
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
/*COMMIT;
PRAGMA legacy_alter_table = OFF;
PRAGMA foreign_keys = ON;
*/

.output schema_tables_fix.sql
.schema "attribute"
.schema "client"
.schema "entity_attribute"
.schema "entity_availability"
.schema "entity_power"
.schema "entity_team"
.schema "gender"
.schema "order"
.schema "order_entity"
.schema "order_status"
.schema "order_status_applied"
.schema "payment"
.schema "publisher"
.schema "race"
.schema "superentity"
.schema "superpower"
.schema "team"
.schema "temp_entity_power"
.schema "temp_superentity"



-- Fixing missing data in "superentity"

.mode csv
.headers on
.output output.txt

.output
SELECT * FROM "gender";

SELECT id,known_as,full_name,gender,race,publisher
FROM "superentity_readable"
WHERE "id" IN (
    SELECT "id" FROM "superentity"
    WHERE "gender_id" = 3
)
ORDER BY "id" ASC;


SELECT * FROM "race";

SELECT id,known_as,full_name,publisher
FROM "superentity_readable"
WHERE "id" IN (
    SELECT "id" FROM "superentity"
    WHERE "race_id" IS NULL
    OR "race_id" = 1
)
ORDER BY "id" ASC;



DROP VIEW IF EXISTS "client_full";
CREATE VIEW IF NOT EXISTS "client_full" AS
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
    c."id";
