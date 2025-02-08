USE DATABASE MovieLens_FERRET;
CREATE OR REPLACE STAGE movielens_stage FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');


CREATE OR REPLACE TABLE ratings(
    id INT,
    user_id INT,
    movie_id INT,
    rating FLOAT,
    timestamp STRING
);

CREATE OR REPLACE TABLE movies(
    movie_id INT,
    title STRING,
    release_year INT 
);

CREATE OR REPLACE TABLE genres_movies(
    id INT,
    movie_id INT,
    genre_id INT 
);

CREATE OR REPLACE TABLE genres(
    genre_id INT,
    name STRING
);

CREATE OR REPLACE TABLE users(
    user_id INT,
    age INT,
    gender STRING,
    occupation STRING,
    zip_code STRING
);

CREATE OR REPLACE TABLE occupations(
    occupation_id INT,
    name STRING
);

CREATE OR REPLACE TABLE age_group(
    agegroup_id INT,
    name STRING
);



COPY INTO ratings
FROM @movielens_stage/ratings.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO movies
FROM @movielens_stage/movies.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO genres_movies
FROM @movielens_stage/genres_movies.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO genres
FROM @movielens_stage/genres.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO users
FROM @movielens_stage/users.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO occupations
FROM @movielens_stage/occupations.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO age_group
FROM @movielens_stage/age_group.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);



SELECT * FROM ratings;
SELECT * FROM movies;
SELECT * FROM genres_movies;
SELECT * FROM genres;
SELECT * FROM users;
SELECT * FROM occupations;
SELECT * FROM age_group;



CREATE OR REPLACE TABLE dim_movies AS
SELECT
    DISTINCT movie_id,
    title
FROM movies;

CREATE OR REPLACE TABLE bridge_genres_movies AS
SELECT
    DISTINCT id,
    movie_id,
    genre_id
FROM genres_movies;

CREATE OR REPLACE TABLE dim_genres AS
SELECT
    DISTINCT genre_id,
    name
FROM genres;
    
CREATE OR REPLACE TABLE dim_users AS
SELECT DISTINCT
    user_id,
    a.name AS agegroup,
    gender,
    o.name AS occupation,
    zip_code
FROM users u
JOIN occupations o ON u.occupation = o.occupation_id
JOIN age_group a ON u.age = a.agegroup_id; 

CREATE OR REPLACE TABLE dim_date AS
SELECT
    DISTINCT
    TO_DATE(TO_TIMESTAMP(timestamp, 'YYYY-MM-DD HH24:MI:SS')) AS date,
    DATE_PART('year', TO_TIMESTAMP(timestamp, 'YYYY-MM-DD HH24:MI:SS')) AS year,
    DATE_PART('month', TO_TIMESTAMP(timestamp, 'YYYY-MM-DD HH24:MI:SS')) AS month,
    DATE_PART('day', TO_TIMESTAMP(timestamp, 'YYYY-MM-DD HH24:MI:SS')) AS day
FROM ratings;


SELECT * FROM dim_movies;
SELECT * FROM bridge_genres_movies;
SELECT * FROM dim_genres;
SELECT * FROM dim_users;
SELECT * FROM dim_date;


CREATE OR REPLACE TABLE fact_ratings AS
SELECT
    r.user_id,
    r.movie_id,
    r.rating,
    d.date AS date_id
FROM ratings r
JOIN dim_date d ON CAST(r.timestamp AS DATE) = d.date;


SELECT * FROM fact_ratings;

DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS genres_movies;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS occupations;
DROP TABLE IF EXISTS age_group; 


CREATE SCHEMA analyzing;

CREATE OR REPLACE VIEW analyzing.count_rating_statistics AS
SELECT 
    m.title,
    COUNT(rating) AS count_rating,
    ROUND(AVG(rating), 2) AS avg_rating
FROM public.fact_ratings f
JOIN public.dim_movies m ON f.movie_id = m.movie_id
GROUP BY f.movie_id, m.title;

SELECT * FROM analyzing.count_rating_statistics;

CREATE OR REPLACE VIEW analyzing.user_rating_statistics AS
SELECT
    u.gender,
    u.occupation,
    u.agegroup,
    rating
FROM 
    public.fact_ratings f
JOIN 
    public.dim_users u
ON f.user_id = u.user_id;

SELECT * FROM analyzing.user_rating_statistics;

CREATE OR REPLACE VIEW analyzing.genre_rating_statistics AS
SELECT 
    g.name,
    COUNT(f.rating) AS count_rating,
    ROUND(AVG(f.rating), 2) AS average_rating
FROM 
    public.fact_ratings f
JOIN 
    public.bridge_genres_movies b
ON 
    f.movie_id = b.movie_id
JOIN
    public.dim_genres g
ON 
    b.genre_id = g.genre_id
GROUP BY 
    g.name;

SELECT * FROM analyzing.genre_rating_statistics;

CREATE OR REPLACE VIEW analyzing.date_rating_statistics AS
SELECT
    d.year,
    d.month,
    d.day,
    COUNT(rating) AS count_rating,
    ROUND(AVG(rating), 2) AS average_rating
FROM
    public.fact_ratings f
JOIN 
     public.dim_date d
ON 
    f.date_id = d.date
GROUP BY
    d.year, d.month, d.day
ORDER BY
    d.year, d.month, d.day ASC;

SELECT * FROM analyzing.date_rating_statistics;
