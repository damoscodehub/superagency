
# Application level ideas

Here are some additional ideas that might be useful to implement at application level.

> Some of them I've been able to achieve in SQLite, others I haven't been able to achieve in what I was willing to try. (I wonder what of all this can be achieved -or achieved more efficiently- with other SQL systems).

## Dynamic aliases

For example when searching for superpowers by values of one superentity. I unsuccesfully tried this kind of query.

```sql
WITH "specific_entity" AS (
    SELECT "id","known_as"
    FROM "superentity"
    WHERE
        "id" = 351 -- by "id"
        --"known_as" = '' -- by "known_as"
)

SELECT
    p."name" AS (SELECT "known_as" FROM "specific_entity")||"_super_power"
FROM "superpower" p
JOIN "entity_power" ep
    ON ep."power_id" = p."id"
JOIN "superentity" e
    ON ep."entity_id" = e."id"
-- WHERE e."known_as" = (SELECT "known_as" FROM "specific_entity") -- by "known_as"
WHERE e."id" = (SELECT "id" FROM "specific_entity") -- by "id"
;
```

## Update NEW values BEFORE being inserted or updated.

I couldn't get any variation of TRIGGERS I tried to work, to modify the `"NEW value"` before some action is executed.

For example to TRIM NEW values before insert:

```sql
CREATE TRIGGER "attribute_trim_before_insert"
BEFORE INSERT ON "attribute"
FOR EACH ROW
BEGIN
    SET NEW."name" = TRIM(NEW."name");
END;
```

Or to TRIM NEW values before upload:

```sql
CREATE TRIGGER "attribute_trim_before_insert"
BEFORE INSERT ON "attribute"
FOR EACH ROW
BEGIN
    SELECT TRIM(NEW."name") INTO NEW."name";
END;
```
> This would be good for all "entity" tables. I got the same final results with AFTER-action TRIGGER versions, but I think it's better to correct the data before inserting it.

I also unsuccessfully tried some variations of triggers with the intention of dynamically changing the values of some NEW.data before inserting. For example:

```sql
CREATE TRIGGER IF NOT EXISTS "before_superentity_ins"
BEFORE INSERT ON "superentity"
FOR EACH ROW
BEGIN
    -- Handle Gender ID lookup
    SET NEW."gender_id" = (
        CASE
            WHEN typeof(NEW."gender_id") = 'text' THEN
                (SELECT "id" FROM "gender" WHERE TRIM("name") = TRIM(NEW."gender_id") COLLATE NOCASE)
            ELSE NEW."gender_id"
        END
    );

    -- Handle Race ID lookup
    SET NEW."race_id" = (
        CASE
            WHEN typeof(NEW."race_id") = 'text' THEN
                (SELECT "id" FROM "race" WHERE TRIM("name") = TRIM(NEW."race_id") COLLATE NOCASE)
            ELSE NEW."race_id"
        END
    );

    -- Handle Publisher ID lookup
    SET NEW."publisher_id" = (
        CASE
            WHEN typeof(NEW."publisher_id") = 'text' THEN
                (SELECT "id" FROM "publisher" WHERE TRIM("name") = TRIM(NEW."publisher_id") COLLATE NOCASE)
            ELSE NEW."publisher_id"
        END
    );
END;
```
> I ended up writing some insert statements that achieved the same result.

## More versatil insert method

When inserting or upload some foreign keys I like the idea of the system to:

- Check if the value is text: If the value is a string, checks if it already exists in a related table.
- Insert if not exists: If the value does not exist, insert it into the appropriate related table.
- Retrieve Identifiers: After ensuring the necessary values are present, retrieve identifiers (IDs) corresponding to the newly inserted values from the related tables.

Is there any application level method to achive that better than this TRIGGER I implemented?:

```sql
CREATE TRIGGER IF NOT EXISTS "superentity_r_instead_insert_insert_superentity"
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
        NEW."known_as",
        NEW."full_name",
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

    -- Use the inserted ID from the superentity table
    INSERT INTO "entity_availability" ("entity_id", "status", "datetime")
    SELECT
        (CASE
            WHEN NEW."id" IS NULL THEN last_insert_rowid()
            ELSE NEW."id"
        END),
        CASE
            WHEN TRIM(NEW."status") COLLATE NOCASE = 'out' THEN 'out'
            ELSE 'in'
        END,
        CURRENT_TIMESTAMP;
END;
```
- I would like to apply this functionality also for the rest of the tables, but in SQLite, this kind of TRIGGERS (the INSTEAD OF INSERTING kind) is only aplicable to views.
- With a BEFORE kind TRIGGER the NEW values can't be changed
- The AFTER TRIGGER type is not an option here because a non-existent id (foreign_key) could not be inserted in the first instance.


##

```sql
CREATE TRIGGER IF NOT EXISTS "superentity_before_insert_check"
BEFORE INSERT ON "superentity"
FOR EACH ROW
WHEN EXISTS (
    SELECT 1 FROM "superentity"
    WHERE TRIM(NEW."known_as") = TRIM("known_as") COLLATE NOCASE
    AND TRIM(NEW."full_name") = TRIM("full_name") COLLATE NOCASE
    AND NEW."publisher_id" = "publisher_id"
)
BEGIN
    SELECT RAISE(ABORT, 'Duplicate superentity detected ignoring case and extra spaces.');
END;
```




## Multiple trigger action time alternative

As far as I tried and researched, SQLite does not support triggers with more than one _trigger action time_.

For example:

```sql
BEFORE INSERT OR UPDATE ON "table_name"
```

So I decided to create an _"update trigger action time"_ version of many of my _"insert trigger action time"_ triggers, resulting in a lot of repeated code and many more triggers than I intuitively think the database should have.

## Triggers with inherited behavior
The trigger to inherit the behavior (INSERT or INSERT OR IGNORE) of the command that caused it to execute.

-------
- It may be better to adapt and integrate the database to a plataform that allows clients to connect directly with the superentities or place their orders into some kind of order's pool, so that the superentities
- Every `superentity` must have a value for each 6 fixed `attributes`. It would be better to implement a `superentity` insertion mechanism that requires that.
