
So final project time arrived. I started 8 different ones and quit 7. So here is my last idea, the one that convinced me the most: **"The SuperAgency Database"**

The idea is to create a database for a company that manages the rental of published "super entities", that is, superheroes, supervillains (although I will briefly reflect on those terms later), characters with special abilities, etc., from actually published comics, movies, series, etc.

I think this database is going to have a profound impact on real life (?

# "The SuperAgency Database"

## The start

Initially I was making all my database from scratch.

```
sqlite3 superagency.db
```

For reasons that I will clarify later, I am not going to explain here the dynamics and logic of my initial schema, but I put it here just to leave a record. I really encourage you not to dwell on it.

```sql
CREATE TABLE "superentities" (
    "id" INTEGER PRIMARY KEY,
    "first_name" TEXT,
    "last_name" TEXT,
    "alias" TEXT NOT NULL,
    "universe_id" INTEGER,
    "moralty_rating" INTEGER CHECK("moralty_rating" BETWEEN 1 AND 10), -- established by popular judgment
    "superpowers" TEXT,
    "weaknesses" TEXT,
    "hour_fee" INTEGER,
    FOREIGN KEY ("universe_id") REFERENCES "universes"("id")

);

CREATE TABLE "universes" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL
);

CREATE TABLE "teams" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL
);

CREATE TABLE "superentities_teams" (
    "superentity_id" INTEGER,
    "team_id" INTEGER,
    PRIMARY KEY ("superentity_id", "team_id"),
    FOREIGN KEY ("superentity_id") REFERENCES "superentities"("id") ON DELETE CASCADE,
    FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE CASCADE
);

CREATE TABLE "orders" (
    "id" INTEGER PRIMARY KEY,
    "client_id" INTEGER NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "title" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "scheduled_start" DATETIME NOT NULL,
    "started" DATETIME, -- When the work began (if it did) regardless of the schedule.
    "scheduled_end" DATETIME,
    "ended" DATETIME, -- When the work ended (if it did) regardless of the schedule.
    "fixed_price" INTEGER, -- If it has been so agreed (in dollars)
    "hourly_price" INTEGER, -- If it has been so agreed (in dollars)
    "paid" INTEGER, -- Amunt paid (in dollars, not boolean)
    FOREIGN KEY ("client_id") REFERENCES "clients"("id")
);

CREATE TABLE "superentities_orders" (
    "order_id" INTEGER,
    "superentity_id" INTEGER,
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE,
    FOREIGN KEY ("superentity_id") REFERENCES "superentities"("id") ON DELETE CASCADE,
);

CREATE TABLE "clients" (
    "id" INTEGER PRIMARY KEY,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "phone" TEXT NOT NULL
);

CREATE VIEW "clients_full" AS
    WITH "client_last_order" AS (
        SELECT "client_id", MAX("created_at") AS "last_order"
        FROM "orders"
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
    FROM "clients" c
    JOIN "orders" o
        ON c."id" = o."client_id"
    JOIN "client_last_order" l
        ON o."client_id" = l."client_id"
    GROUP BY c."id"
    ORDER BY c."id";

CREATE INDEX idx_superentity_team ON "superentities_teams" ("superentity_id", "team_id");
CREATE INDEX idx_order_client ON "orders" ("client_id");

```

I gave ChatGPT the `INSERT INTO` tables and columns names, and I ask him to fill the original population statment data. After many iterations, this is what we achieved.

```sql
INSERT INTO "superpeople" ("first_name", "last_name", "alias", "moralty_rate", "superpowers", "weaknesses", "hour_fee", "universe_id")
VALUES
("Clark", "Kent", "Superman", 9, "Super strength, Flight, X-ray vision, Heat vision", "Kryptonite", 600, 1),
("Bruce", "Wayne", "Batman", 8, "Peak human physical and mental conditioning, Master detective", "Mortal, Emotional trauma", 540, 1),
("Diana", "Prince", "Wonder Woman", 9, "Super strength, Flight, Combat skills, Lasso of Truth", "Bound by her own lasso", 660, 1),
("Peter", "Parker", "Spider-Man", 7, "Wall-crawling, Super strength, Spider-sense, Agility", "Mortal, Responsibility", 450, 2),
("Tony", "Stark", "Iron Man", 6, "Powered armor suit, Genius intellect, Wealth", "Ego, Addiction", 750, 2),
("Steve", "Rogers", "Captain America", 9, "Super strength, Shield, Enhanced agility", "Mortal", 600, 2),
("Thor", "Odinson", "Thor", 8, "God of Thunder, Mjolnir, Immortality", "Hubris", 750, 2),
("Natasha", "Romanoff", "Black Widow", 7, "Espionage, Martial arts, Agility", "Mortal", 480, 2),
("Barry", "Allen", "The Flash", 8, "Super speed, Time travel", "Speed force dependency", 540, 1),
("Bruce", "Banner", "Hulk", 6, "Super strength, Regeneration", "Rage control", 510, 2),
("Arthur", "Curry", "Aquaman", 7, "Underwater breathing, Super strength, Communicate with sea creatures", "Dehydration", 480, 1),
("Hal", "Jordan", "Green Lantern", 7, "Power ring, Constructs", "Fear, Willpower", 510, 1),
("James 'Logan'", "Howlett", "Wolverine", 6, "Regeneration, Adamantium claws", "Berserker rage", 570, 2),
("Charles", "Xavier", "Professor X", 8, "Telepathy, Mind control", "Paralysis", 540, 2),
("Jean", "Grey", "Phoenix", 5, "Telekinesis, Telepathy, Phoenix Force", "Power control, Emotional instability", 600, 2),
("Matt", "Murdock", "Daredevil", 7, "Enhanced senses, Martial arts", "Blindness", 450, 2),
("Stephen", "Strange", "Doctor Strange", 7, "Magic, Sorcery, Time manipulation", "Overconfidence", 660, 2),
("Oliver", "Queen", "Green Arrow", 7, "Archery, Martial arts", "Mortal", 450, 1),
("Scott", "Lang", "Ant-Man", 6, "Size manipulation, Ant control", "Mortal", 420, 2),
("Wanda", "Maximoff", "Scarlet Witch", 4, "Reality manipulation, Magic", "Emotional instability", 600, 2),
("Vision", "", "Vision", 6, "Density manipulation, Intangibility, Super strength, Solar energy projection", "Emotional complexity, Dependency on the Mind Stone", 540, 2),
("Victor", "Stone", "Cyborg", 7, "Cybernetic enhancements, Technopathy", "Human emotions", 480, 1),
("T'Challa", "Udaku", "Black Panther", 8, "Enhanced strength, Vibranium suit, Wealth", "heart-shaped herb dependent", 600, 2),
("Kara", "Zor-El", "Supergirl", 8, "Super strength, Flight, Heat vision", "Kryptonite", 540, 1),
("Selina", "Kyle", "Catwoman", 5, "Martial arts, Stealth, Agility", "Moral ambiguity", 450, 1),
("Billy", "Batson", "Shazam", 8, "Super strength, Magic, Transformation", "Mortal in human form", 510, 1),
("Wade", "Wilson", "Deadpool", 6, "Regeneration, Martial arts", "Mental instability", 450, 2),
("Marc", "Spector", "Moon Knight", 5, "Multiple identities, Combat skills", "Mental instability", 450, 2),
("Jessica", "Jones", "Alias", 5, "Super strength, Investigation skills", "Alcoholism, PTSD", 450, 2),
("Frank", "Castle", "The Punisher", 4, "Expert marksman, Military tactics", "Obsessive revenge", 450, 2),
("Erik", "Lehnsherr", "Magneto", 3, "Magnetism manipulation, Genius intellect", "Hatred, Obsession", 450, 2),
("Harley", "Quinn", "Harley Quinn", 2, "Acrobatics, Psychology, Unpredictability", "Obsessive love", 450, 1),
("Victor", "Von Doom", "Doctor Doom", 2, "Genius intellect, Magic, Armor", "Ego, Pride", 480, 2),
("Lex", "Luthor", "Lex Luthor", 2, "Genius intellect, Wealth, Technology", "Obsession with Superman", 510, 1),
("Eddie", "Brock", "Venom", 4, "Super strength, Symbiote powers", "Weakness to sound, fire", 450, 2),
("Norman", "Osborn", "Green Goblin", 2, "Genius intellect, Enhanced strength, Goblin gear", "Insanity", 480, 2),
("Cletus", "Kasady", "Carnage", 1, "Symbiote powers, Super strength", "Uncontrollable rage", 450, 2),
("Slade", "Wilson", "Deathstroke", 3, "Enhanced strength, Tactics, Weaponry", "Obsession with Batman", 450, 1),
("Thanos", "", "Thanos", 1, "Super strength, Infinity Gauntlet", "Hubris", 750, 2),
("Erik", "Killmonger", "Killmonger", 3, "Enhanced strength, Combat skills", "Hatred, Revenge", 450, 2),
("Ra's", "al Ghul", "Ra's al Ghul", 2, "Immortality, Master strategist", "Obsession with justice", 450, 1),
("Selene", "Gallio", "Selene", 3, "Immortality, Magic, Psychic powers", "Power hunger", 450, 2),
("Wilson", "Fisk", "Kingpin", 2, "Criminal mastermind, Super strength", "Obsession with control", 450, 2),
("Unknown", "Unknown", "Bane", 2, "Super strength, Genius intellect", "Addiction to Venom", 450, 1),
("Helmut", "Zemo", "Baron Zemo", 3, "Master strategist, Combat skills", "Obsession with revenge", 450, 2),
("Ultron", "", "Ultron", 1, "Super intelligence, Self-repair, Technology control", "Overconfidence", 450, 2),
("Loki", "Laufeyson", "Loki", 4, "Magic, Trickery, Shapeshifting", "Ego, Mischief", 540, 2),
("Thaal", "Sinestro", "Sinestro", 3, "Power ring, Constructs", "Fear, Hatred", 480, 1),
("Sebastian", "Shaw", "Sebastian Shaw", 2, "Absorbs kinetic energy, Super strength", "Power hunger", 450, 2),
("Dormammu", "", "Dormammu", 1, "Mystical powers, Dimensional control", "Arrogance", 750, 2),
("Nathaniel", "Richards", "Kang the Conqueror", 2, "Time travel, Genius intellect", "Hubris, Overconfidence", 510, 2),
("Unknown", "Unknown", "Chapulín Colorado", 10, "None but has Chiquitolina Pills, Chilling Chipote and Paralyzing Cicada", "Clumsy, Stupid, Physically weak", 10, 6);


INSERT INTO "universes" ("name") VALUES
("DC Comics"),
("Marvel Comics"),
("Image Comics"),
("Dark Horse Comics"),
("Valiant Comics"),
("Chespirito");

```

But I think working with such powerful characters heightened my thirst for power, and I wanted this agency to monopolize the market. So I searched the internet to see if there wasn't already a more comprehensive database of "superheroes" and/or "supervillains". I found one that looked promising.

https://github.com/bbrumm/databasestar/tree/main/sample_databases/sample_db_superheroes/sqlite

> (Credits to ["bbrumm"](https://github.com/bbrumm) -the owner of the repository where I found this database- or/and ["miqueldespuig"](https://github.com/miqueldespuig) -who made the commits I can see there-)

That database was called `superhero.db` and this were its tables:

```sql
sqlite3 superhero.db

.mode list
.separator "\n"
.tables
```
```
alignment
gender
publisher
attribute
hero_attribute
race
superpower
colour
hero_power
superhero
```

```sql
.mode table
```

When I took a look to the `superhero` table, I was amazed to notice that there were hundreds of records, and I wanted to know how many exactly.

So I first ran this query:

```sql
SELECT MAX("id") as "max_id"
FROM "superhero";
```
```
+--------+
| max_id |
+--------+
| 756    |
+--------+
```

> Much later, after interacting a lot with that table, I suspected that the `IDs` were not consecutively from 1 to 756, but that some intermediate numbers were missing. If that was the case, the maximum `ID` did not represent the total number of records. So I ask ChatGPT for help to find it out. And indeed.

```sql
WITH RECURSIVE all_ids AS (
    SELECT MIN("id") AS id
    FROM "superhero"
    UNION ALL
    SELECT id + 1
    FROM all_ids
    WHERE id + 1 <= (SELECT MAX("id") FROM "superhero")
)
SELECT id AS "missing_ids"
FROM all_ids
WHERE id NOT IN (SELECT "id" FROM "superhero");
```
```
+-------------+
| missing_ids |
+-------------+
| 142         |
| 512         |
| 605         |
| 639         |
| 645         |
| 718         |
+-------------+
```
> What could have happened with those IDs? I don't know but thank to this I learned how to check missing numbers! =)

Believing then that there were 756 records, I was already extremely tempted to adapt it and incorporate that adaptation into my project.

> if I had known that there were really 750 I would not have done it, for God's sake!... (?.

But I asked myself if it wouldn't be cheating. ~~And this are the excuses I could found~~ And this is what I honestly reflexionated.

1. This would only facilitate the fact of populating the superentity table and some of their characteristics with a much larger number of records. Others aspects, as well as everything relevant for the correct development and implementation of my database for the purposes that I myself devised, would continue to depend entirely on me.
2. In fact, before even thinking about incorporating it, I already had my schema finished. The only things that were pending, from what was requested for the project, were items that would still be pending if I adapted and incorporated that external database (namely: completing the `DESIGN.md` and `queires.sql` files and making the `video`). So, ultimately, this would add much more work (including all this explanation) than it would take away.
3. This extra work would also involve the study and implementation of SQL knowledge and techniques, some of which I had already acquired and implemented in what I had already done, and others that were different, some that we had even seen in the course and I would not have to implement them in this project if it were not for the adaptation of the external database and the implementation of said adaptation.

So I set out on that mission...

> ... not knowing that it would be much more challenging for me than I thought with the SQL knowledge I had at the time and I would end up learning more insults in a thousand languages ​​than SQL techniques, although boy has this feat taught me about the latter!

## superhero.db adaptation

> At times, in order to simplify everything, I was tempted to delete as soon as possible the tables and columns that I thought would be superfluous in the agency's database, but I was afraid of changing my mind in the middle of the process and that this would end up being even more costly than what I finally decided to do: only do it at the final stage of the adaptation process.

### "superhero" table

The `superhero` table had this schema:

```sql
CREATE TABLE superhero (
  id INTEGER PRIMARY KEY,
  superhero_name TEXT DEFAULT NULL,
  full_name TEXT DEFAULT NULL,
  gender_id INTEGER DEFAULT NULL,
  eye_colour_id INTEGER DEFAULT NULL,
  hair_colour_id INTEGER DEFAULT NULL,
  skin_colour_id INTEGER DEFAULT NULL,
  race_id INTEGER DEFAULT NULL,
  publisher_id INTEGER DEFAULT NULL,
  alignment_id INTEGER DEFAULT NULL,
  height_cm INTEGER DEFAULT NULL,
  weight_kg INTEGER DEFAULT NULL,
  CONSTRAINT fk_sup_align FOREIGN KEY (alignment_id) REFERENCES alignment (id),
  CONSTRAINT fk_sup_eyecol FOREIGN KEY (eye_colour_id) REFERENCES colour (id),
  CONSTRAINT fk_sup_gen FOREIGN KEY (gender_id) REFERENCES gender (id),
  CONSTRAINT fk_sup_haircol FOREIGN KEY (hair_colour_id) REFERENCES colour (id),
  CONSTRAINT fk_sup_pub FOREIGN KEY (publisher_id) REFERENCES publisher (id),
  CONSTRAINT fk_sup_race FOREIGN KEY (race_id) REFERENCES race (id),
  CONSTRAINT fk_sup_skincol FOREIGN KEY (skin_colour_id) REFERENCES colour (id)
);
```

I found some blank names with this query:

```sql
SELECT COUNT(*) AS "NULL, '', '-'"
FROM "superhero"
WHERE
    "superhero_name" IS NULL
    OR "superhero_name" = ''
    OR "superhero_name" = '-'
    OR "full_name" IS NULL
    OR "full_name" = ''
    OR "full_name" = '-';
```
```
+---------------+
| NULL, '', '-' |
+---------------+
| 247           |
+---------------+
```

I created a csv with the relevant fields of records that has some name field NULL, '' or '-', in order to be able to copy and paste that clean text.

> Many times I prefered to use csv as I find it better when interacting with ChatGPT because it uses fewer characters than table mode (and ChatGPT has character limitation to send and recieve messages). I also though that I couldn't send monospaced font messages to ChatGPT so tables looked bad. But while writing this I thought I'd check and it does support markdown formatting. So I can enclose text with triple backticks (\`\`\`) for multi-line code or codeblocks, or backticks (\`) for inline code. so I might start using it =).

```sql
.headers on
.mode csv
.output data.csv

SELECT "id","superhero_name","full_name" FROM "superhero"
WHERE
    "superhero_name" IS NULL
    OR "superhero_name" = ''
    OR "superhero_name" = '-'
    OR "full_name" IS NULL
    OR "full_name" = ''
    OR "full_name" = '-';

.mode column
.headers off
```
I send that csv to ChatGPT and ask him to fill in the missing names and to give me a complete csv list.

> I had a really hard time getting satisfactory results every time I asked ChatGPT to apply certain criteria to long lists. I always had to do it in parts and even then I often couldn't get it to understand me properly, or when it did, it seemed to forget very easily and gwent off the rails. But finally I got it.

I saved that ChatGPT's entire list into a new `names_complete.csv` file in the same directory of my database.

I created a temporary table to dump that data into.

```sql
CREATE TABLE "names_complete" (
    "id" INTEGER PRIMARY KEY,
    "superhero_name" TEXT,
    "full_name" TEXT
);
```

I imported `names_complete.csv` into a new temp table.

```sql
.import --csv --skip 1 names_complete.csv names_complete
```

I updated `superhero` table with `names_complete` table:

```sql
UPDATE "superhero"
SET
    "full_name" = (
        SELECT "full_name"
        FROM "names_complete"
        WHERE "names_complete"."id" = "superhero"."id"
    ),
    "superhero_name" = (
        SELECT "superhero_name"
        FROM "names_complete"
        WHERE "names_complete"."id" = "superhero"."id"
    )
WHERE "id" IN (
    SELECT "id" FROM "names_complete"
);
```

I checked:

```sql
SELECT * FROM "superhero"
WHERE
    "superhero_name" IS NULL
    OR "superhero_name" = ''
    OR "superhero_name" = '-'
    OR "full_name" IS NULL
    OR "full_name" = ''
    OR "full_name" = '-';
```

```
sqlite>
```

No results! =) That's good!

#### "morality_rating" and "fee" columns

For the agency database project, I needed in that table 2 columns that were in my original table:

- `morality_rating`: an estimate of how popular and judged said character would be by the general population.
- `fee`: an estimate of the fees in dollars per hour that each character would charge if they were to be rented.

So I add them into this `superhero` table:

```sql
ALTER TABLE "superhero"
ADD COLUMN "morality_rating" INTEGER CHECK ("morality_rating" BETWEEN 1 AND 10);

ALTER TABLE "superhero"
ADD COLUMN "fee" INTEGER;
```

I gave ChatGPT a csv with `"superhero"("id")` and `"superhero"("superhero_name")` and ask him to add a plausible "morality_rating" and "fee" for each one.

> Again, as it was a very long list, ChatGPT was hard, but we got it.

I pasted that entire list into a new .csv file `morality_fees.csv` in the same directory of my database.

I imported that `morality_fees.csv` into a new temp table.

```sql

CREATE TABLE morality_fees (
    id INTEGER,
    morality_rating INTEGER,
    fee INTEGER
);

.import --csv --skip 1 morality_fees.csv morality_fees
```

I updated `superhero` table with `morality_fees` table.

```sql
UPDATE "superhero"
SET
    "morality_rating" = (
        SELECT "morality_rating"
        FROM "morality_fees"
        WHERE "morality_fees"."id" = "superhero"."id"
    ),
    "fee" = (
        SELECT "fee"
        FROM "morality_fees"
        WHERE "morality_fees"."id" = "superhero"."id"
    )
WHERE "id" IN (
    SELECT "id" FROM "morality_fees"
);
```

> If the last WHERE statment is not there, then all rows that don't match the subqueries criteria will have their chosen SET fields also modify, in this case with `NULL` value. So I think it's a good practice to add it. I understood this in the worst posible way =')

### The preference for a new .db file

I notice some things that I wanted to change.

1. Some table, column and constraint names referred to the concept of "hero", which I had previously deliberately avoided in my original schema because it depends on who judges it (including clients!)
2. Two `composite primary keys` were missing, one in `hero_attribute` table and the other in `hero_power` table. They are needed in order to prevent unwanted duplicated data.

While SQLite supports renaming table and column, it does not support adding, dropping or modifying constraints directly.

So I decided to back up the `.schema superhero` into a backup_sh_schema.sql

```sql
.output ./backup_sh_schema.sql
.schema
.output stdout
```

I made a copy if it with the name `schema_full.sql`, I changed all those things I wanted to change and I finally merged my original schema with this.

Then I needed also to "dumped" all data in a separete `populate.sql` file. So first I outputed as plain list all tables:

```sql
.mode list
.separator "\n"

SELECT name
FROM sqlite_master
WHERE type = 'table';
```
```
attribute
gender
publisher
race
superpower
entity_attribute
entity_power
superentity
team
client
entity_team
order
entity_order
```
I returned to the default mode:

```sql
.mode table;
```

Then I created the `populate.sql` file:

```sql
.mode insert
.output populate.sql
```

I dumped there the populated tables:

```sql
.dump "attribute"
.dump "gender"
.dump "publisher"
.dump "race"
.dump "superpower"
.dump "entity_attribute"
.dump "entity_power"
.dump "superentity"
```
And I return to the default output:

```sql
.mode table
.output stdout
```
I delete from `populate.sql` everything but the `INSERT` statments.
I deleted my original `superagency.db`and create a new one. I copied into its directory `schema_full.sql` and `populate.sql` files and `.read` them.

### "team%" tables

Since the number of registered superentities was huge and until then I had not managed to get ChatGPT to handle very long lists correctly, it was quite a challenge to populate the `team` and `entety_team` tables. I decided to asked him to make SQL statment to populate `entity_team_temp` table with `entity_name` and `team_name` columns, to make the most complete table he could with the most popular teams he knows and all thier members. The teams could be much more than those I chose, but to demonstrate the dynamics of this database this would be more than enough.

I paste a salection of them it into a new `entity_team_temp.sql` and improved it with many more interactions with ChatGPT. Then:

```sql
.read entity_team_temp.sql
```

Now I wanted to find out which of those characters where alredy recorded in my database and which ones were missing.

I thoght that I may need to consult that query several times and that it justified the creation of a VIEW, even if it was only temporal:

```sql
CREATE VIEW "team_match_temp" AS
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
```

> Note that I added a `match` column with value 1 or 0 if that character already was in my database or not, respectively.

I added those teams to the `team` table:

```sql
INSERT INTO "team"("name")
SELECT DISTINCT "team_name"
FROM "entity_team_temp";
```

I made a csv of the missing characters:

```sql
.mode csv
.headers on

SELECT "entity_name", "team_name"
FROM "team_match_temp"
WHERE "match" = 0;
```
I created `superentity_temp` table (with the same schema of `superentity` table to be able to insert data from the first to the second).

I asked ChatGPT to write the code to insert those new characters into `superentity_temp` table, and their respective missing publishers into the `publisher` table. The first task was difficult, but we finally got it done. The second one we didn't get, so I had to find another way to add the missing publishers and correct the `publisher_id` of the new characters.

To finish with the team topic created a new view

```sql
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
```

### "publisher%" tables

I created a new tamp table `team_publisher_temp`

```sql
CREATE TABLE IF NOT EXISTS "team_publisher_temp" (
    "team_name" TEXT NOT NULL,
    "publisher_name" TEXT NOT NULL,
    PRIMARY KEY ("team_name", "publisher_name")
);
```

I gave ChatGPT all the teams and ask him a code to insert their corresponding `publisher_name`.

Then I insert into `publisher` table only the those that were new.

```sql
INSERT OR IGNORE INTO "publisher"("name")
SELECT DISTINCT "publisher_name"
FROM "team_publisher_temp";
```
> As `publisher(name)` has the `UNIQUE` constraint and I run `INSERT OR IGNORE`, those publisher names that were already in the table didn't were duplicated nor produced a constraint error, they were simply ignored.

Now I could update the `superentity_temp(publisher_id)` joining 4 tables: `superentity_temp`, `entity_team_temp`, `team_publisher_temp` and `publisher`:

```sql
.mode list

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
```

> I first run the full code to better check, and then commented the extra code, to get only 2 columns:

```
entity_id|publisher_id
757|13
758|13
759|13
760|13
760|13
761|13
762|13
763|13
763|13
764|13
765|13
766|13
767|13
768|13
769|13
770|13
771|13
772|13
773|13
774|13
775|13
776|13
777|13
778|13
779|13
780|13
781|13
782|13
783|13
784|13
785|13
786|13
786|13
787|4
788|13
789|13
790|13
791|13
792|13
793|13
794|13
795|13
796|4
797|4
798|4
799|4
800|4
801|4
802|4
803|3
804|3
805|3
806|3
807|3
808|13
808|13
809|13
810|13
811|13
812|13
813|13
814|13
815|13
816|13
817|13
818|13
819|13
820|13
821|13
822|15
823|15
824|15
825|4
826|10
827|10
828|10
829|13
830|13
831|13
832|13
833|13
834|13
835|13
835|13
836|13
837|13
838|13
839|13
840|13
841|13
842|13
843|10
843|10
844|10
844|10
845|10
846|10
847|10
848|13
849|10
849|10
850|10
850|10
851|10
852|10
853|10
854|10
855|10
856|10
857|10
858|10
864|4
865|4
866|13
867|13
868|13
869|13
870|13
871|26
872|26
873|26
874|26
875|26
876|24
877|24
878|24
879|24
880|24
881|13
882|13
883|13
884|13
885|13
886|13
887|13
888|13
889|13
889|13
890|13
891|13
892|13
893|13
894|13
895|13
896|13
897|13
897|13
```
> I find this `list` mode easier to **multi-line editing**

Then with **multi-line editing** I used that list update `superentity_temp`:

```sql
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
```

Then I insert `superentity_temp` into `superentity`

```sql
INSERT INTO "superentity"
SELECT * FROM "superentity_temp";
```

To fill at least some examples for the "entity_team" I first created a view:

```sql
CREATE VIEW "superentity_team_temp" AS
SELECT
    s."id" AS "entity_id",
    s."known_as",
    s."full_name",
    ett."team_name",
    t."id" AS "team_id"
FROM "superentity" s
JOIN "entity_team_temp" ett ON s."known_as" = ett."entity_name"
JOIN "team" t ON ett."team_name" = t."name"
;

.output superentity_team.csv
.mode csv
.headers on

SELECT "entity_id", "team_id"
FROM "superentity_team_temp";

.import --csv --skip 1 superentity_team.csv entity_team

.output stdout
.mode table
```
> I could have use a subquery or a CTE (Common Table Expression) but I wanted a VIEW to access it easier for some revisions.

I made minor changes and it was ready.

### "attribute%" tables

I had to asign attributes ammount values to the new superentities. For that, I first created a csv with some references:

```sql
.mode csv
.headers on

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
```

I also created a csv with the new superentities, which need to be assigned attribute values.

```sql
SELECT "id", "known_as"
FROM "superentity"
WHERE "id" > 756;
```

I gave ChatGPT the two csv lists and asked it to generate another csv to assign attribute values ​​to the new superentities in the format `entity_id,attribute_id,attribute_value`.

> I found it incredibly difficult to get ChatGPT to do this relatively well, in fact I don't think I ever did. I just gave up at some point and left out certain values ​​that I'm not entirely convinced about, but which are absolutely irrelevant for the purposes of evaluating this final project.

I saved that as `ent_att.csv` and imported into `entity_attribute` table.

```sql
.import --csv --skip 1 ent_att.csv entity_attribute
```

Then I realize that all columns in that table had `DEFAULT NULL` constraint, and there wasn't any value CHECK for `attribute_value`:

```sql
CREATE TABLE IF NOT EXISTS "entity_attribute" (
    "entity_id" INTEGER DEFAULT NULL,
    "attribute_id" INTEGER DEFAULT NULL,
    "attribute_value" INTEGER DEFAULT NULL,
    PRIMARY KEY ("entity_id", "attribute_id"),
    CONSTRAINT fk_eat_at FOREIGN KEY (attribute_id) REFERENCES "attribute" (id),
    CONSTRAINT fk_eat_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id)
);
```

Then I made this other changes:

- Got rid of `DEFAULT NULL` action.
- Added `CHECk` constraint.
- Added `ON DELETE CASCADE`

While I understand that SQL forces primary keys to NOT NULL I did't like how that schema lookedm I wanted to get rid of `DEFAULT NULL` constraints. Besides, I want to add the `CHECk` constraint. And since SQL doesn't support adding constraints after a column is created. I decided to create a new table. But if I wanted to leave the `FOREIGN KEY` names as they were, since they cant be repeted, I had to delete that table completely and recreate it with the wanted changes. But to do that, I had to dump that data somewhere, and I decided to do it in a temporary table.

```sql
CREATE TABLE "temp" AS
SELECT * FROM "entity_attribute";
```

I deleted the original:

```sql
DROP TABLE "entity_attribute";
```

I recreated it with `NOT NULL` and `CHECK` constraints:

```sql
CREATE TABLE IF NOT EXISTS "entity_attribute" (
    "entity_id" INTEGER,
    "attribute_id" INTEGER,
    "attribute_value" INTEGER CHECK ("attribute_value" BETWEEN 1 AND 100)NOT NULL,
    PRIMARY KEY ("entity_id", "attribute_id"),
    CONSTRAINT fk_eat_at FOREIGN KEY (attribute_id) REFERENCES "attribute" (id) ON DELETE CASCADE,
    CONSTRAINT fk_eat_ent FOREIGN KEY ("entity_id") REFERENCES "superentity" (id) ON DELETE CASCADE
);
```
Then I dumped the data back into that table:

```sql
INSERT INTO "entity_attribute"
SELECT * FROM "temp";
```

I dropped the `temp` table:

```sql
DROP TABLE `temp`;
```
### "power%" tables

As I did to the last table, here I also:

- Got rid of `DEFAULT NULL` action.
- Added `ON DELETE CASCADE`

```sql
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
```

As usual with long lists, I struggled with ChatGPT to get a csv (entity_power.csv) to add the powers of the new entities. Then:

```sql
.import --csv --skip 1 entity_power.csv entity_power
```

I then did a lot of fine editing of that data, although there is probably still a lot left to correct.

### "client" % "order" tables

With the help of ChatGPT I added some fun clients. I made just a few changes there. We also created a fun order table, but I wasn't satisfied with the results. So I rethought most of them from scratch.

I implemented a system to be able to assign candidate entities for each order and then choose the ones finally in charge:

```sql
CREATE TABLE IF NOT EXISTS "order_entity" (
    "order_id" INTEGER,
    "entity_id" INTEGER,
    "assigned" INTEGER NOT NULL DEFAULT 0 CHECK ("assigned" BETWEEN 0 AND 1),
    PRIMARY KEY ("order_id", "entity_id"),
    CONSTRAINT fk_so_order FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE,
    CONSTRAINT fk_so_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE
```

And a more readable view:

```sql
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
ORDER BY oe."order_id"
/* order_entity_readable(order_id,title,entity_id,entity_known_as,entity_full_name,assigned) */;
```

-----

At some point I realized that there was an inconsistency between column names. While in other tables there was a `name` column, in `gender` table it was `gender` column. So I fixed it:

```sql
ALTER TABLE "gender"
RENAME COLUMN "gender" TO "name";
```
I decided to add a `available` column to the `superentity` table, as a _"soft delete"_ utility but inverted:

```sql
ALTER TABLE "superentity"
ADD COLUMN "available" INTEGER CHECK ("available" BETWEEN 0 AND 1) DEFAULT 1 NOT NULL;
```

I decided to add a "status" column to "order" table:

```sql
CREATE TABLE IF NOT EXISTS "status" (
    "id" INTEGER PRIMARY KEY,
    "label" TEXT NOT NULL UNIQUE
);
```

### Further changes

After making a lot of subtle changes and tests in my database I decided to do this further canges.

I replaced the `"available"`column in `"superentity"` table with 2 other columns: `"available_since"` and `"unavailable_since"`. Then I thought it would be even better to have a separate table to record when an entity becomes available or unavailable.

```sql
CREATE TABLE IF NOT EXISTS "entity_availability" (
    "entity_id" INTEGER NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'in' CHECK ("type" IN ('in','out')),
    "datetime" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("entity_id", "datetime")
    CONSTRAINT fk_enav_ent FOREIGN KEY ("entity_id") REFERENCES "superentity"("id")
);
```
And I populated it. First I insert every superentity (as `'in'`):

```sql
INSERT OR IGNORE INTO "entity_availability"("entity_id")
SELECT "id" FROM "superentity";
```
Then I recorded some of them `'out'` (some of whom are too powerful to make sense for them to work for the company -I already had them as some datatime in `"unavailable_since"`):

```sql
INSERT OR IGNORE INTO "entity_availability"("entity_id", "type", "datetime")
SELECT "id", 'out', CURRENT_TIMESTAMP
FROM "superentity"
WHERE "unavailable_since" IS NOT NULL;
```
I added an indicator of availability to the `"superentity_readable"` table, based on the last `"type"` of record in the `"entity_availability"` for each superentity:

```sql
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
```

I also edited `"entity_team"` table in order to implement a system to record memberships and disassociations of superentities with respect to teams:

```sql
CREATE TABLE IF NOT EXISTS "entity_team" (
    "entity_id" INTEGER,
    "team_id" INTEGER,
    "type" TEXT NOT NULL DEFAULT 'in' CHECK ("type" IN ('in','out')),
    "datetime" DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("entity_id", "team_id", "datetime"),
    CONSTRAINT fk_et_entity FOREIGN KEY ("entity_id") REFERENCES "superentity"("id") ON DELETE CASCADE,
    CONSTRAINT fk_et_team FOREIGN KEY ("team_id") REFERENCES "team"("id") ON DELETE CASCADE
```
I then edited the `"entity_team_readable"` view to reflect the availability of the super entities and the status of their memberships to the teams:

```sql
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
```

I thought it would be usefull to have this view, to help the task of deciding with superentites to assign to each order.

```sql

DROP VIEW IF EXISTS "entity_power_readable";

CREATE VIEW IF NOT EXISTS "entity_power_readable" AS
SELECT
    er."id" AS "entity_id",
    er."known_as" AS "entity_known_as",
    er."full_name" AS "entity_full_name",
    er."av",
    p."id" AS "power_id",
    p."name" AS "power_name"
FROM "superentity_readable" er
JOIN "entity_power" ep
    ON er."id" = ep."entity_id"
JOIN "superpower" p
    ON ep."power_id" = p."id"
ORDER BY er."id";
```

I did the same with the `entity_attribute` table:

```sql
DROP VIEW IF EXISTS "entity_attribute_readable";

CREATE VIEW IF NOT EXISTS "entity_attribute_readable" AS
SELECT
    ea."entity_id",
    er."known_as" AS "entity_known_as",
    er."full_name" AS "entity_full_name",
    er."av",
    ea."attribute_id",
    a."name" AS "attribute_name",
    ea."attribute_value"
FROM "superentity_readable" er
JOIN "entity_attribute" ea
    ON er."id" = ea."entity_id"
JOIN "attribute" a
    ON ea."attribute_id" = a."id"
ORDER BY ea."entity_id", ea."attribute_id";
```




I decided to remove the "fee" column of "superentity". The reason es that while it may be a interesting and funny additive, it is not practical as it is. It has no impact in any other aspect 

# To do
Check triggers
