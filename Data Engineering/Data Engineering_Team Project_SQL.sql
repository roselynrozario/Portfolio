/***********************************************
**      MSc Applied Data Science
**     DATA ENGINEERING PLATFORMS 
** File:   Final Project DDL
** Desc:   Creating Tables for Dataset
** Auth:   Naoki Tsumoto, Roselyn Rozario, Ankit Gubiligari, Nakul Vadlamudi 
** Group:  4
************************************************/

-- -----------------------------------------------------
-- Select Database
-- -----------------------------------------------------
DROP DATABASE IF EXISTS teamproject;
CREATE DATABASE teamproject;
USE teamproject;

-- -----------------------------------------------------
-- Table `Countries`
-- -----------------------------------------------------
CREATE TABLE Countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    ioc CHAR(3)
);

-- -----------------------------------------------------
-- Table `Players`
-- -----------------------------------------------------
CREATE TABLE Players (
    player_id INT PRIMARY KEY,
    name_first VARCHAR(255),
    name_last VARCHAR(255),
    hand CHAR(1),
    dob DATE,
    country_id INT,
    height INT,
    wikidata_id VARCHAR(255),
    CONSTRAINT fk_players_countries FOREIGN KEY (country_id)
		REFERENCES Countries(country_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- -----------------------------------------------------
-- Table `Tournaments`
-- -----------------------------------------------------
CREATE TABLE Tournaments (
    tourney_id VARCHAR(255) PRIMARY KEY,
    tourney_name VARCHAR(255),
    surface VARCHAR(255),
    draw_size INT,
    tourney_level CHAR(1),
    tourney_date DATE
);

-- -----------------------------------------------------
-- Table `Matches`
-- -----------------------------------------------------
CREATE TABLE Matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    tourney_id VARCHAR(255),
    match_num INT,
    winner_id INT,
    winner_seed INT,
    winner_entry VARCHAR(255),
    winner_name VARCHAR(255),
    winner_hand CHAR(1),
    winner_ht INT,
    winner_ioc CHAR(3),
    winner_age INT,
    loser_id INT,
    loser_seed INT,
    loser_entry VARCHAR(255),
    loser_name VARCHAR(255),
    loser_hand CHAR(1),
    loser_ht INT,
    loser_ioc CHAR(3),
    loser_age INT,
    score VARCHAR(255),
    best_of INT,
    round VARCHAR(255),
    minutes INT,
    w_ace INT,
    w_df INT,
    w_svpt INT,
    w_1stIn INT,
    w_1stWon INT,
    w_2ndWon INT,
    w_SvGms INT,
    w_bpSaved INT,
    w_bpFaced INT,
    l_ace INT,
    l_df INT,
    l_svpt INT,
    l_1stIn INT,
    l_1stWon INT,
    l_2ndWon INT,
    l_SvGms INT,
    l_bpSaved INT,
    l_bpFaced INT,
    winner_rank INT,
    winner_rank_points INT,
    loser_rank INT,
    loser_rank_points INT,
    matchDescription VARCHAR(255),
	CONSTRAINT fk_matches_tournaments FOREIGN KEY (tourney_id)
		REFERENCES Tournaments(tourney_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- -----------------------------------------------------
-- Table `Rankings`
-- -----------------------------------------------------
CREATE TABLE Rankings (
    ranking_id INT AUTO_INCREMENT PRIMARY KEY,
    ranking_date DATE,
    `rank` INT,
    player_id INT,
    points INT,
	CONSTRAINT fk_rankings_players FOREIGN KEY (player_id)
		REFERENCES Players(player_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION
);
 
-- -----------------------------------------------------
-- Table `players_matches`
-- -----------------------------------------------------
CREATE TABLE players_matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT,
    match_id INT,
    CONSTRAINT fk_playersmatches_players FOREIGN KEY (player_id)
		REFERENCES Players(player_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT fk_playersmatches_matches FOREIGN KEY (match_id)
		REFERENCES Matches(match_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION
);


/***********************************************
**      MSc Applied Data Science
**     DATA ENGINEERING PLATFORMS 
** File:   Final Project DML
** Desc:   Loading Data into Tables
** Auth:   Naoki Tsumoto, Roselyn Rozario, Ankit Gubiligari, Nakul Vadlamudi 
** Group:  4
************************************************/

-- -----------------------------------------------------
-- Enable File Load and Updates
-- -----------------------------------------------------
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE "secure_file_priv";

-- -----------------------------------------------------
-- Select Database
-- -----------------------------------------------------
USE teamproject;

-- -----------------------------------------------------
-- Temporary Table - `TempPlayers`
-- -----------------------------------------------------
# Drop the existing temporary table
DROP TEMPORARY TABLE IF EXISTS TempPlayers;

# Create a new temporary table based on the structure of Countries
CREATE TEMPORARY TABLE TempPlayers (
    player_id INT,
    name_first VARCHAR(255),
    name_last VARCHAR(255),
    hand CHAR(1),
    dob DATE,
    ioc CHAR(3),
    height INT,
    wikidata_id VARCHAR(255)
);

# Load Data into the Temporary Table
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\atp_players_till_2022.csv'
INTO TABLE TempPlayers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(
    player_id, 
    name_first, 
    name_last, 
    hand, 
    @dob_value, 
    ioc, 
    @height_value, 
    wikidata_id
)
SET height = CASE 
    WHEN @height_value = '' THEN NULL 
    ELSE @height_value 
END,
dob = CASE 
    WHEN @dob_value LIKE '%0000.0' THEN NULL
    WHEN @dob_value = '' THEN NULL 
    ELSE @dob_value 
END;

-- -----------------------------------------------------
-- Importing Data - `Countries` Table
-- -----------------------------------------------------
INSERT INTO Countries (ioc)
SELECT DISTINCT ioc FROM TempPlayers
WHERE ioc NOT IN (SELECT ioc FROM Countries);

-- -----------------------------------------------------
-- Importing Data - `Players` Table
-- -----------------------------------------------------
INSERT INTO Players (player_id, name_first, name_last, hand, dob, country_id, height, wikidata_id)
SELECT 
    tp.player_id,
    tp.name_first,
    tp.name_last,
    tp.hand,
    tp.dob,
    c.country_id,
    tp.height,
    tp.wikidata_id
FROM TempPlayers AS tp
JOIN Countries AS c ON tp.ioc = c.ioc;

# Drop the temporary table
DROP TEMPORARY TABLE TempPlayers;

-- -----------------------------------------------------
-- Importing Data - `Tournaments` Table
-- -----------------------------------------------------

# Drop the existing temporary table
DROP TEMPORARY TABLE IF EXISTS TempTournaments;

# Create a new temporary table based on the structure of Tournaments
CREATE TEMPORARY TABLE TempTournaments LIKE Tournaments;

# Remove the primary key or unique constraint from the temporary table
ALTER TABLE TempTournaments DROP PRIMARY KEY;

# Load Data into the Temporary Table
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\atp-matches-till-2022_match_id.csv'
INTO TABLE TempTournaments
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(
    @dummy,
    tourney_id,
    tourney_name,
    surface,
    draw_size,
    tourney_level,
    tourney_date,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy
);

# Insert unique data into the Tournaments table
INSERT IGNORE INTO Tournaments
SELECT DISTINCT * FROM TempTournaments;

# Drop the temporary table
DROP TEMPORARY TABLE TempTournaments;

-- -----------------------------------------------------
-- Importing Data - `Matches` Table
-- -----------------------------------------------------
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\atp-matches-till-2022_match_id.csv'
INTO TABLE Matches 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(
	match_id,
    tourney_id,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    @dummy,
    match_num,
    winner_id,
    @winner_seed_value,
    winner_entry,
    winner_name,
    winner_hand,
    @winner_ht_value,
    winner_ioc,
    @winner_age_value,
    loser_id,
    @loser_seed_value,
    loser_entry,
    loser_name,
    loser_hand,
    @loser_ht_value,
    loser_ioc,
    @loser_age_value,
    score,
    best_of,
    round,
    @minutes_value,
    @w_ace_value,
    @w_df_value,
    @w_svpt_value,
    @w_1stIn_value,
    @w_1stWon_value,
    @w_2ndWon_value,
    @w_SvGms_value,
    @w_bpSaved_value,
    @w_bpFaced_value,
    @l_ace_value,
    @l_df_value,
    @l_svpt_value,
    @l_1stIn_value,
    @l_1stWon_value,
    @l_2ndWon_value,
    @l_SvGms_value,
    @l_bpSaved_value,
    @l_bpFaced_value,
    @winner_rank_value,
    @winner_rank_points_value,
    @loser_rank_value,
    @loser_rank_points_value    
)
SET 
winner_seed = CASE 
    WHEN @winner_seed_value = '' THEN NULL 
    ELSE @winner_seed_value 
END,
winner_ht = CASE 
    WHEN @winner_ht_value = '' THEN NULL 
    ELSE @winner_ht_value 
END,
winner_age = CASE 
    WHEN @winner_age_value = '' THEN NULL 
    ELSE @winner_age_value 
END,
loser_seed = CASE 
    WHEN @loser_seed_value = '' THEN NULL 
    ELSE @loser_seed_value 
END,
loser_ht = CASE 
    WHEN @loser_ht_value = '' THEN NULL 
    ELSE @loser_ht_value 
END,
loser_age = CASE 
    WHEN @loser_age_value = '' THEN NULL 
    ELSE @loser_age_value 
END,
minutes = CASE 
    WHEN @minutes_value = '' THEN NULL 
    ELSE @minutes_value 
END,
w_ace = CASE 
    WHEN @w_ace_value = '' THEN NULL 
    ELSE @w_ace_value 
END,
w_df = CASE 
    WHEN @w_df_value = '' THEN NULL 
    ELSE @w_df_value 
END,
w_svpt = CASE 
    WHEN @w_svpt_value = '' THEN NULL 
    ELSE @w_svpt_value 
END,
w_1stIn = CASE 
    WHEN @w_1stIn_value = '' THEN NULL 
    ELSE @w_1stIn_value 
END,
w_1stWon = CASE 
    WHEN @w_1stWon_value = '' THEN NULL 
    ELSE @w_1stWon_value 
END,
w_2ndWon = CASE 
    WHEN @w_2ndWon_value = '' THEN NULL 
    ELSE @w_2ndWon_value 
END,
w_SvGms = CASE 
    WHEN @w_SvGms_value = '' THEN NULL 
    ELSE @w_SvGms_value 
END,
w_bpSaved = CASE 
    WHEN @w_bpSaved_value = '' THEN NULL 
    ELSE @w_bpSaved_value 
END,
w_bpFaced = CASE 
    WHEN @w_bpFaced_value = '' THEN NULL 
    ELSE @w_bpFaced_value 
END,
l_ace = CASE 
    WHEN @l_ace_value = '' THEN NULL 
    ELSE @l_ace_value 
END,
l_df = CASE 
    WHEN @l_df_value = '' THEN NULL 
    ELSE @l_df_value 
END,
l_svpt = CASE 
    WHEN @l_svpt_value = '' THEN NULL 
    ELSE @l_svpt_value 
END,
l_1stIn = CASE 
    WHEN @l_1stIn_value = '' THEN NULL 
    ELSE @l_1stIn_value 
END,
l_1stWon = CASE 
    WHEN @l_1stWon_value = '' THEN NULL 
    ELSE @l_1stWon_value 
END,
l_2ndWon = CASE 
    WHEN @l_2ndWon_value = '' THEN NULL 
    ELSE @l_2ndWon_value 
END,
l_SvGms = CASE 
    WHEN @l_SvGms_value = '' THEN NULL 
    ELSE @l_SvGms_value 
END,
l_bpSaved = CASE 
    WHEN @l_bpSaved_value = '' THEN NULL 
    ELSE @l_bpSaved_value 
END,
l_bpFaced = CASE 
    WHEN @l_bpFaced_value = '' THEN NULL 
    ELSE @l_bpFaced_value 
END,
winner_rank = CASE 
    WHEN @winner_rank_value = '' THEN NULL 
    ELSE @winner_rank_value 
END,
winner_rank_points = CASE 
    WHEN @winner_rank_points_value = '' THEN NULL 
    ELSE @winner_rank_points_value 
END,
loser_rank = CASE 
    WHEN @loser_rank_value = '' THEN NULL 
    ELSE @loser_rank_value 
END,
loser_rank_points = CASE 
    WHEN @loser_rank_points_value = '' THEN NULL 
    ELSE @loser_rank_points_value 
END;

-- -----------------------------------------------------
-- Importing Data - `Rankings` Table
-- -----------------------------------------------------
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\atp_rankings_till_2022_ranking_id.csv'
INTO TABLE Rankings 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
( 
	ranking_id, 
    @ranking_date, 
    `rank`, 
    player_id, 
    @points_value 
)
SET 
ranking_date = STR_TO_DATE(@ranking_date, '%Y%m%d'),
points = CASE 
	WHEN @points_value = ' ' OR @points_value = '' OR @points_value REGEXP '^[^0-9]+$' THEN NULL 
	ELSE CAST(@points_value AS SIGNED) 
END;

-- -----------------------------------------------------
-- Importing Data - `players_matches` Table
-- -----------------------------------------------------
# Populating the players_matches table with winners and losers from the Matches table

# Insert winners' data into the players_matches table
INSERT INTO players_matches (player_id, match_id)
SELECT winner_id, match_id FROM Matches;

# Insert losers' data into the players_matches table
INSERT INTO players_matches (player_id, match_id)
SELECT loser_id, match_id FROM Matches;


/***********************************************
**      MSc Applied Data Science
**     DATA ENGINEERING PLATFORMS 
** File:   Final Project Queries
** Desc:   SQL Queries for EDA
** Auth:   Naoki Tsumoto, Roselyn Rozario, Ankit Gubiligari, Nakul Vadlamudi 
** Group:  4
************************************************/

-- -------------------------------------------------------------------------
-- Select Database
-- -------------------------------------------------------------------------
USE teamproject;

-- -------------------------------------------------------------------------
-- Investigating Player Performance on Surfaces Based on Their Country
-- -------------------------------------------------------------------------

SELECT DISTINCT surface FROM tournaments;

SELECT DISTINCT ioc FROM countries;

SELECT 
	c.ioc AS countryInitials,
    p.name_first AS firstName,
    p.name_last AS lastName,
    COUNT(a.winner_id) as winnerCount
FROM 
	countries c 
		INNER JOIN
	players p ON c.country_id = p.country_id
		INNER JOIN
	players_matches m ON p.player_id = m.player_id
		INNER JOIN
	matches a ON m.match_id = a.match_id
		INNER JOIN
	tournaments t ON a.tourney_id = t.tourney_id
GROUP BY 
    c.ioc, p.name_first, p.name_last
ORDER BY 
    c.ioc, COUNT(a.winner_id) DESC;

# ALT
SELECT 
    c.ioc AS countryInitials,
    COUNT(a.winner_id) AS winnerCount
FROM 
    countries c 
        INNER JOIN players p ON c.country_id = p.country_id
        INNER JOIN players_matches m ON p.player_id = m.player_id
        INNER JOIN matches a ON m.match_id = a.match_id
        INNER JOIN tournaments t ON a.tourney_id = t.tourney_id
GROUP BY 
    c.ioc
ORDER BY 
    COUNT(a.winner_id) DESC;

SELECT 
	t.surface,
	p.name_first AS firstName,
    p.name_last AS lastName,
    c.ioc AS countryInitials,
    COUNT(a.winner_id) as winnerCount
FROM 
	countries c 
		INNER JOIN
	players p ON c.country_id = p.country_id
		INNER JOIN
	players_matches m ON p.player_id = m.player_id
		INNER JOIN
	matches a ON m.match_id = a.match_id
		INNER JOIN
	tournaments t ON a.tourney_id = t.tourney_id
GROUP BY t.surface, p.name_first, p.name_last, c.ioc;

# ALT
SELECT 
    t.surface,
    COUNT(a.winner_id) AS winnerCount
FROM 
    countries c 
        INNER JOIN players p ON c.country_id = p.country_id
        INNER JOIN players_matches m ON p.player_id = m.player_id
        INNER JOIN matches a ON m.match_id = a.match_id
        INNER JOIN tournaments t ON a.tourney_id = t.tourney_id
GROUP BY 
    t.surface
ORDER BY 
    COUNT(a.winner_id) DESC;

# Group the players’ countries and count that group’s wins for each surface

SELECT 
    t.surface AS Surface,
    c.ioc AS CountryInitials,
    COUNT(a.winner_id) AS WinnerCount
FROM 
    tournaments t
    INNER JOIN matches a ON t.tourney_id = a.tourney_id
    INNER JOIN players_matches m ON a.match_id = m.match_id
    INNER JOIN players p ON m.player_id = p.player_id
    INNER JOIN countries c ON p.country_id = c.country_id
GROUP BY 
    t.surface, c.ioc
ORDER BY 
    t.surface, COUNT(a.winner_id) DESC;
    
-- ----------------------------------------------------------------------------------------
-- Investigating Characteristics' (e.g., dominant hand used, age, mentality) Impact on Player Performance
-- ----------------------------------------------------------------------------------------

# Winning probability by hand

SELECT m.winner_hand,
CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM matches),2),'%') AS winningProbability
FROM players p 
JOIN matches m 
ON p.player_id=m.winner_id
WHERE m.winner_hand <> ''
GROUP BY m.winner_hand;

-- If the player is right handed, he is more likely to win the match. This is purely based on correlation and hence does not imply causation.

# Winning probability by age group

SELECT 
	CASE
		WHEN m.winner_age BETWEEN 13 AND 19 THEN 'Teen'
		WHEN m.winner_age BETWEEN 20 AND 29 THEN '20s'
		WHEN m.winner_age BETWEEN 30 AND 39 THEN '30s'
		WHEN m.winner_age BETWEEN 40 AND 49 THEN '40s'
		WHEN m.winner_age BETWEEN 50 AND 59 THEN '50s'
		ELSE 'Other'
	END AS age_group,
    CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM matches),2),'%') AS winningProbability
FROM players p 
JOIN matches m 
ON p.player_id=m.winner_id
GROUP BY age_group
ORDER BY COUNT(*)/(SELECT COUNT(*) FROM matches) DESC;

-- If the player is in 20s, they have the highest probability to win followed by those in 30s.

# Analysis of Player Height on Rank and Amount of Points Scored:
SELECT a.player_id,
       a.name_first,
       a.name_last,
       MAX(a.height) AS height,
       MAX(b.`rank`) AS player_rank,
       MAX(b.points) AS points
FROM teamproject.players a 
JOIN teamproject.rankings b ON a.player_id = b.player_id
WHERE a.height IS NOT NULL
GROUP BY a.player_id, a.name_first, a.name_last
ORDER BY MAX(a.height) DESC;

# Player's Mentality Analysis of Score, Round, and Minutes Played:
SELECT a.player_id,
       a.name_first,
       a.name_last,
       MAX(d.best_of) AS Number_of_Sets,
       MAX(d.score) AS Score,
       MAX(d.round) AS Round,
       MAX(d.minutes) AS Minutes
FROM teamproject.players a 
JOIN teamproject.players_matches c ON a.player_id = c.player_id
JOIN teamproject.matches d ON c.match_id = d.match_id
WHERE d.Minutes is not NULL
GROUP BY a.player_id, a.name_first, a.name_last
ORDER BY MAX(d.Minutes) DESC;

# Winner and Loser Age vs. Tourney Level
SELECT a.player_id,
       a.name_first,
       a.name_last,
       MAX(d.winner_name) AS WinnerName,
       MAX(d.winner_age) AS WinnerAge,
        MAX(d.loser_name) AS LoserName,
       MAX(d.loser_age) AS LoserAge,
       MAX(e.tourney_level) AS TourneyLevel
FROM teamproject.players a 
JOIN teamproject.players_matches c ON a.player_id = c.player_id
JOIN teamproject.matches d ON c.match_id = d.match_id
JOIN teamproject.Tournaments e ON d.tourney_id = e.tourney_id
WHERE d.winner_age is not Null AND d.loser_age is not Null
GROUP BY a.player_id, a.name_first, a.name_last;

-- ----------------------------------------------------------------------------------------
-- Player's Game Performance - How Players Win Points In A Game
-- ----------------------------------------------------------------------------------------

# Due to the extensive computational load, separate tables for winners and losers are created to divide and manage the calculations more efficiently

# Remove existing WinnerStats view if it exists
DROP VIEW IF EXISTS WinnerStats;

# Create a view for winners' statistics
CREATE VIEW WinnerStats AS
SELECT 
    p.player_id,
    p.name_first,
    p.name_last,
    c.ioc AS country,
    SUM(COALESCE(m.w_ace, 0)) AS total_aces, -- Total aces achieved by the winner
    SUM(COALESCE(m.w_df, 0)) AS total_double_faults, -- Total double faults made by the winner
    SUM(COALESCE(m.w_svpt, 0)) AS total_service_points -- Total service points played by the winner
FROM 
    Matches m
    JOIN Players p ON m.winner_id = p.player_id
    JOIN Countries c ON p.country_id = c.country_id
GROUP BY 
    p.player_id, p.name_first, p.name_last, c.ioc;

# Remove existing LoserStats view if it exists
DROP VIEW IF EXISTS LoserStats;

# Create a view for losers' statistics
CREATE VIEW LoserStats AS
SELECT 
    p.player_id,
    p.name_first,
    p.name_last,
    c.ioc AS country,
    SUM(COALESCE(m.l_ace, 0)) AS total_aces, -- Total aces achieved by the loser
    SUM(COALESCE(m.l_df, 0)) AS total_double_faults, -- Total double faults made by the loser
    SUM(COALESCE(m.l_svpt, 0)) AS total_service_points -- Total service points played by the loser
FROM 
    Matches m
    JOIN Players p ON m.loser_id = p.player_id
    JOIN Countries c ON p.country_id = c.country_id
GROUP BY 
    p.player_id, p.name_first, p.name_last, c.ioc;

# Remove existing WinnerAdvancedStats view if it exists
DROP VIEW IF EXISTS WinnerAdvancedStats;

# Create a view for advanced statistics of winners
CREATE VIEW WinnerAdvancedStats AS
SELECT 
    p.player_id,
    COALESCE(SUM(m.w_bpFaced - m.w_bpSaved) / NULLIF(SUM(m.w_bpFaced), 0), 0) AS breakpoint_efficiency, -- Breakpoint efficiency for the winner
    COALESCE(SUM(m.w_1stWon + m.w_2ndWon) / NULLIF(SUM(m.w_svpt), 0), 0) AS serve_effectiveness -- Serve effectiveness for the winner
FROM 
    Matches m
    JOIN Players p ON m.winner_id = p.player_id
GROUP BY 
    p.player_id;

# Remove existing LoserAdvancedStats view if it exists
DROP VIEW IF EXISTS LoserAdvancedStats;

# Create a view for advanced statistics of losers
CREATE VIEW LoserAdvancedStats AS
SELECT 
    p.player_id,
    COALESCE(SUM(m.l_bpFaced - m.l_bpSaved) / NULLIF(SUM(m.l_bpFaced), 0), 0) AS breakpoint_efficiency, -- Breakpoint efficiency for the loser
    COALESCE(SUM(m.l_1stWon + m.l_2ndWon) / NULLIF(SUM(m.l_svpt), 0), 0) AS serve_effectiveness -- Serve effectiveness for the loser
FROM 
    Matches m
    JOIN Players p ON m.loser_id = p.player_id
GROUP BY 
    p.player_id;

# Remove existing ComprehensivePlayerStats view if it exists
DROP VIEW IF EXISTS ComprehensivePlayerStats;

# Create a comprehensive view combining all statistics
CREATE VIEW ComprehensivePlayerStats AS
SELECT 
    w.player_id,
    w.name_first,
    w.name_last,
    w.country,
    w.total_aces AS total_aces_won, -- Total aces when the player won
    l.total_aces AS total_aces_lost, -- Total aces when the player lost
    w.total_double_faults AS total_double_faults_won, -- Total double faults when the player won
    l.total_double_faults AS total_double_faults_lost, -- Total double faults when the player lost
    w.total_service_points AS total_service_points_won, -- Total service points when the player won
    l.total_service_points AS total_service_points_lost, -- Total service points when the player lost
    wa.breakpoint_efficiency AS breakpoint_efficiency_won, -- Breakpoint efficiency when the player won
    la.breakpoint_efficiency AS breakpoint_efficiency_lost, -- Breakpoint efficiency when the player lost
    wa.serve_effectiveness AS serve_effectiveness_won, -- Serve effectiveness when the player won
    la.serve_effectiveness AS serve_effectiveness_lost -- Serve effectiveness when the player lost
FROM 
    WinnerStats w
    JOIN LoserStats l ON w.player_id = l.player_id
    JOIN WinnerAdvancedStats wa ON w.player_id = wa.player_id
    JOIN LoserAdvancedStats la ON l.player_id = la.player_id;

# Check the created views
SELECT * FROM WinnerStats LIMIT 50;
SELECT * FROM LoserStats LIMIT 50;
SELECT * FROM WinnerAdvancedStats LIMIT 50;
SELECT * FROM LoserAdvancedStats LIMIT 50;
SELECT * FROM ComprehensivePlayerStats LIMIT 50;

-- ----------------------------------------------------------------------------------------
-- Impact of External Factors (e.g., seed, tournament level, etc.) on Player Performance 
-- ----------------------------------------------------------------------------------------

# Remove existing WinnerStats view if it exists
DROP VIEW IF EXISTS WinnerSeedWinningProbability;
DROP VIEW IF EXISTS LoserSeedWinningProbability;
DROP VIEW IF EXISTS WinnerEntryWinningProbability;
DROP VIEW IF EXISTS LoserEntryWinningProbability;

# Winning probability of winning players in the respective seeds
CREATE VIEW WinnerSeedWinningProbability AS
SELECT 
	CASE
		WHEN m.winner_seed BETWEEN 1 AND 10 THEN 'High'
		WHEN m.winner_seed BETWEEN 11 AND 20 THEN 'Upper Medium'
		WHEN m.winner_seed BETWEEN 21 AND 30 THEN 'Lower Medium'
		ELSE 'Low'
	END AS seedGroup,
    CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM matches),2),'%') AS winningProbability
FROM players p 
JOIN matches m 
ON p.player_id=m.winner_id
GROUP BY seedGroup
ORDER BY COUNT(*)/(SELECT COUNT(*) FROM matches) DESC;

# Winning probability of losing players in the respective seeds
CREATE VIEW LoserSeedWinningProbability AS
SELECT 
	CASE
		WHEN m.loser_seed BETWEEN 1 AND 10 THEN 'High'
		WHEN m.loser_seed BETWEEN 11 AND 20 THEN 'Upper Medium'
		WHEN m.loser_seed BETWEEN 21 AND 30 THEN 'Lower Medium'
		ELSE 'Low'
	END AS seedGroup,
    CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM matches),2),'%') AS winningProbability
FROM players p 
JOIN matches m 
ON p.player_id=m.loser_id
GROUP BY seedGroup
ORDER BY COUNT(*)/(SELECT COUNT(*) FROM matches) DESC;

# Winner entry's winning probability
CREATE VIEW WinnerEntryWinningProbability AS
SELECT 
	CASE
		WHEN m.winner_entry = 'Q' THEN 'Qualifier'
		WHEN m.winner_entry = 'WC' THEN 'Wild Card'
		WHEN m.winner_entry = 'LL' THEN 'Lucky Loser'
        WHEN m.winner_entry = 'PR' THEN 'Protected Ranking'
		ELSE 'Special Exempt'
	END AS entryType,
    CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM matches),2),'%') AS winningProbability
FROM players p 
JOIN matches m 
ON p.player_id=m.winner_id
GROUP BY entryType
ORDER BY COUNT(*)/(SELECT COUNT(*) FROM matches) DESC;

# Losing entry's winning probability
CREATE VIEW LoserEntryWinningProbability AS
SELECT 
	CASE
		WHEN m.loser_entry = 'Q' THEN 'Qualifier'
		WHEN m.loser_entry = 'WC' THEN 'Wild Card'
		WHEN m.loser_entry = 'LL' THEN 'Lucky Loser'
        WHEN m.loser_entry = 'PR' THEN 'Protected Ranking'
		ELSE 'Special Exempt'
	END AS entryType,
    CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM matches),2),'%') AS winningProbability
FROM players p 
JOIN matches m 
ON p.player_id=m.loser_id
GROUP BY entryType
ORDER BY COUNT(*)/(SELECT COUNT(*) FROM matches) DESC;

# Check the created views
SELECT * FROM WinnerSeedWinningProbability LIMIT 50;
SELECT * FROM LoserSeedWinningProbability LIMIT 50;
SELECT * FROM WinnerEntryWinningProbability LIMIT 50;
SELECT * FROM LoserEntryWinningProbability LIMIT 50;