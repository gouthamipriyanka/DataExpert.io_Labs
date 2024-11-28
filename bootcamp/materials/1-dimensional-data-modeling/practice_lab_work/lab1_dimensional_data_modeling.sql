
-- ---------------CREATING STRUCT TYPES-----------------
-- CREATE TYPE season_stats AS (
--                         gp Integer,
--                         pts Integer,
--                         reb REAL,
--                         ast REAL,
--                         weight Integer,
--                         season Integer

-- );

-- CREATE TYPE scoring_class AS ENUM('star','good','average','bad'
-- );

---------CREATING A TABLE WITH STRUCT AND ARRAY TYPES-----------
-- CREATE TABLE players (
--                 player_name TEXT,
--                 age Integer,
--                 height TEXT,
--                 college TEXT,
--                 country TEXT,
--                 draft_year TEXT,
--                 draft_round TEXT,
--                 draft_number TEXT,
--                 season_stats season_stats[],
--                 scoring_class scoring_class,
--                 years_since_last_season Integer,
--                 current_season Integer,
--                 PRIMARY KEY (player_name, current_season)
-- );


---------DEFINING THE PIPELINE-----------------
-- INSERT INTO players

-- -(seed query when there is no past data to populate the CT with null values)
-- WITH yesterday AS (
--                 SELECT * FROM players
--                 WHERE current_season = 2000
-- ), today AS (
--     SELECT * FROM player_seasons
--     WHERE season = 2001
-- )

-- SELECT 
--         COALESCE(t.player_name,y.player_name) as player_name,
--         COALESCE(t.age,y.age) as age,
--         COALESCE(t.height,y.height) as height,
--         COALESCE(t.college,y.college) as college,
--         COALESCE(t.country,y.country) as country,
--         COALESCE(t.draft_year,y.draft_year) as draft_year,
--         COALESCE(t.draft_round,y.draft_round) as draft_round,
--         COALESCE(t.draft_number,y.draft_number) as draft_number,
--         CASE    
--             WHEN y.season_stats IS NULL
--             THEN ARRAY[ROW(
--                 t.gp,
--                 t.pts,
--                 t.reb,
--                 t.ast,
--                 t.weight,
--                 t.season)::season_stats]
--             WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
--                 t.gp,
--                 t.pts,
--                 t.reb,
--                 t.ast,
--                 t.weight,
--                 t.season)::season_stats]
--             ELSE y.season_stats
--         END as season_stats,
--         CASE
--             WHEN t.season IS NOT NULL THEN
--                 CASE 
--                     WHEN t.pts > 20 THEN 'star'
--                     WHEN t.pts > 15 THEN 'good' 
--                     WHEN t.pts > 10 THEN 'average' 
--                     ELSE 'bad'
--                 END:: scoring_class
--             ELSE y.scoring_class
--         END AS scoring_class, 
--         CASE 
--             WHEN t.season IS NOT NULL THEN 0
--             ELSE y.years_since_last_season + 1
--         END as years_since_last_season,

--         COALESCE(t.season,y.current_season+1) as current_season
    
-- FROM today t
-- FULL OUTER JOIN yesterday y
-- ON t.player_name = y.player_name ;


---------------TO UNNEST THE VALUES OF THE TABLES IF WE NEED TO JOIN IT WITH OTHER TABLES---------------
---------------WITH CLAUSE SHOULD ALWAYS FOLLOW A SELECT STATEMENT TO AVOID ERRORS----------------------

-- WITH unnested AS (
--     SELECT player_name ,
--         UNNEST(season_stats)::season_stats AS season_stats
--         FROM players
-- WHERE current_season = 2001
-- )

-- SELECT player_name,
--         (season_stats).*
--         FROM unnested ;

-- DROP TABLE players ;

-- TRUNCATE TABLE players ;

-- SELECT * FROM players 
-- WHERE current_season = 2000
-- AND player_name = 'Michael Jordan';

-- ANALYTICS QUERY TO KNOW HOW IMPROVED THE BEST FROM FIRST TO LATEST MATCH-------
--CARDNALITY CALCULATES THE LENGTH OF THE ARRAY----------
---CARDINALITY[SEASON_STATS] GIVES THE INDEX OF THE LAST ELEMENT OF THE SEASON_STATS ARRAY-----
-----WE USE CASE BECAUSE DIVISION BY 0 IS NOT POSSIBLE IF THERE ARE NO PREVIOUS POINTS FOR A PLAYER---------

SELECT  player_name,
         
        (season_stats[CARDINALITY(season_stats)]::season_stats).pts/
        CASE 
            WHEN (season_stats[1]::season_stats).pts = 0 THEN 1
            ELSE (season_stats[1]::season_stats).pts
        END as improvement_points
FROM players
WHERE current_season = 2001
AND scoring_class = 'star';