-- =====================================================================
-- CBCS  |  05_nba.sql  |  Owner: Member 5 (NBA / DarkNight)
-- Tables: NBA_Games, GameParticipations
-- Runs after 01_locations_personnel.sql and 02_club_members.sql,
-- because GameParticipations references ClubMembers(memberID).
-- Target: MySQL 8.0.16+ (CHECK constraints are enforced from 8.0.16;
-- older servers parse and ignore them, so the script still runs).
--
-- NOTE: teamPlayedFor must equal the homeTeam or awayTeam of that game;
-- this can't be a CHECK across tables, so it's enforced by the data.
-- =====================================================================

-- ---------------------------------------------------------------------
-- NBA_Games
-- One NBA game: the two teams, where/when it was played and the final
-- score. Table name is NBA_Games exactly, as required by the assignment.
-- Scores are non-negative and the two teams must differ.
-- ---------------------------------------------------------------------
CREATE TABLE NBA_Games (
    gameID        INT           NOT NULL AUTO_INCREMENT,
    gameDate      DATE          NOT NULL,
    gameLocation  VARCHAR(100)  NOT NULL,
    homeTeam      VARCHAR(50)   NOT NULL,
    awayTeam      VARCHAR(50)   NOT NULL,
    homeScore     INT           NOT NULL,
    awayScore     INT           NOT NULL,
    CONSTRAINT pk_nbagames        PRIMARY KEY (gameID),
    CONSTRAINT ck_nba_homescore   CHECK (homeScore >= 0),
    CONSTRAINT ck_nba_awayscore   CHECK (awayScore >= 0),
    CONSTRAINT ck_nba_teams       CHECK (homeTeam <> awayTeam)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- ---------------------------------------------------------------------
-- GameParticipations
-- The PlayedIn M-N relationship between club members and NBA games:
-- one row per (member, game) pair, so PK = (memberID, gameID).
-- A member can play many games and a game has many members.
-- teamPlayedFor records which side of that game the member played for
-- (see the cross-table note in the file header).
-- ON DELETE CASCADE on both sides: if a member or a game is removed,
-- their participation rows go with it.
-- ---------------------------------------------------------------------
CREATE TABLE GameParticipations (
    memberID       INT           NOT NULL,
    gameID         INT           NOT NULL,
    teamPlayedFor  VARCHAR(50)   NOT NULL,
    points         INT           NOT NULL,
    details        VARCHAR(255),
    CONSTRAINT pk_gameparticipations PRIMARY KEY (memberID, gameID),
    CONSTRAINT fk_gp_member FOREIGN KEY (memberID)
        REFERENCES ClubMembers (memberID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_gp_game   FOREIGN KEY (gameID)
        REFERENCES NBA_Games (gameID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_gp_points CHECK (points >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
