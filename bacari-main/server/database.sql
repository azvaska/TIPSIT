DROP 
CREATE DATABASE bacari;
USE bacari;

CREATE TABLE users(
    id INT NOT NULL,
    username VARCHAR(32) NOT NULL,
    email VARCHAR(64) NOT NULL,
    password VARCHAR(80) NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id),
    UNIQUE (username),
    UNIQUE (email)
);

CREATE TABLE bacari(
    id INT NOT NULL,
    name text NOT NULL,
    lat REAL NOT NULL,
    lng REAL NOT NULL,
    location POINT NOT NULL,
    PRIMARY KEY (id),
    SPATIAL INDEX (location)
);

CREATE TABLE scores(
    id INT NOT NULL AUTO_INCREMENT,
    value INT NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO bacari VALUES (NULL, 'Bacaro Risorto Castello', 45.434974, 12.342632, ST_GeomFromText('POINT(45.434974 12.342632)'));

INSERT INTO bacari VALUES (NULL, 'Cicchetteria venexiana da Luca e Fred', 45.443636, 12.326209, ST_GeomFromText('POINT(45.443636 12.326209)'));
INSERT INTO bacari VALUES ('305d3fcc-80ee-4912-95bd-9910915a587d', 'IDROSCIMMIA MEGAGALATTICA guardate monkay spin idro scimmiooooo', 45.448636, 12.321209, ST_GeomFromText('POINT(45.448636 12.321209)'));
