-- phpMyAdmin SQL Dump
-- version 4.8.0.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 23, 2018 at 10:11 PM
-- Server version: 5.7.22
-- PHP Version: 7.2.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hobofo`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `calc_elo` (IN `match_id` INT(11))  NO SQL
BEGIN
DECLARE t1 INT;
DECLARE t2 INT;
DECLARE winner INT;
DECLARE k INT;
DECLARE eloChange INT;
DECLARE t1elo INT;
DECLARE t2elo INT;
DECLARE R1 DOUBLE;
DECLARE R2 DOUBLE;
DECLARE E1 DOUBLE;
DECLARE E2 DOUBLE;

SELECT Matches.team1_id, Matches.team2_id, Matches.winner_id, Matchtypes.k
INTO t1, t2, winner, k
FROM Matches 
INNER JOIN Matchtypes ON Matches.matchtype_id = Matchtypes.id
WHERE Matches.id = match_id;

CALL get_team_elo(t1, t1elo);
CALL get_team_elo(t2, t2elo);

SET R1 = POW(10, (t1elo / 400));
SET R2 = POW(10, (t2elo / 400));

SET E1 = R1 / (R1 + R2);
SET E2 = R2 / (R2 + R1);

IF winner = t1 THEN
	SET eloChange = k*(1-E1);

		INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player1_id, match_id, Teams.tournament_id, eloChange
    FROM Teams WHERE Teams.id = t1;
    INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player2_id, match_id, Teams.tournament_id, eloChange
    FROM Teams WHERE Teams.id = t1;
    
        INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player1_id, match_id, Teams.tournament_id, -1 * eloChange
    FROM Teams WHERE Teams.id = t2;
    INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player2_id, match_id, Teams.tournament_id, -1 * eloChange
    FROM Teams WHERE Teams.id = t2;
ELSEIF winner = t2 THEN
	SET eloChange = k*(1-E2);

	INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player1_id, match_id, Teams.tournament_id, eloChange
    FROM Teams WHERE Teams.id = t2;
    INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player2_id, match_id, Teams.tournament_id, eloChange
    FROM Teams WHERE Teams.id = t2;
    
        INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player1_id, match_id, Teams.tournament_id, -1 * eloChange
    FROM Teams WHERE Teams.id = t1;
    INSERT INTO elo_changes (player_id, match_id, tournament_id, elo_change)
    SELECT Teams.player2_id, match_id, Teams.tournament_id, -1 * eloChange
    FROM Teams WHERE Teams.id = t1;
END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_team_elo` (IN `team_id` INT(11), OUT `team_elo` INT(11))  NO SQL
SELECT SUM(Players.elo)
FROM Teams
INNER JOIN Players ON Teams.player1_id = Players.id OR Teams.player2_id = Players.id
WHERE Teams.id = team_id
INTO team_elo$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `current_rating`
-- (See below for the actual view)
--
CREATE TABLE `current_rating` (
`id` int(11)
,`name` varchar(60)
,`rating` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `current_ratings`
-- (See below for the actual view)
--
CREATE TABLE `current_ratings` (
`id` int(11)
,`name` varchar(60)
,`rating` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `elo_changes`
--

CREATE TABLE `elo_changes` (
  `id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `match_id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `elo_change` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `elo_changes`
--

INSERT INTO `elo_changes` (`id`, `player_id`, `match_id`, `tournament_id`, `elo_change`, `created`) VALUES
(2, 1, 1, 1, 23, '2017-11-06 22:06:44'),
(3, 2, 1, 1, 23, '2017-11-06 22:06:44'),
(4, 3, 1, 1, -23, '2017-11-06 22:06:44'),
(5, 4, 1, 1, -23, '2017-11-06 22:06:44'),
(6, 1, 1, 1, 23, '2017-11-06 22:12:46'),
(7, 2, 1, 1, 23, '2017-11-06 22:12:46'),
(8, 3, 1, 1, -23, '2017-11-06 22:12:46'),
(9, 4, 1, 1, -23, '2017-11-06 22:12:46'),
(10, 3, 1, 1, 2, '2017-11-06 22:15:43'),
(11, 4, 1, 1, 2, '2017-11-06 22:15:43'),
(12, 1, 1, 1, -2, '2017-11-06 22:15:43'),
(13, 2, 1, 1, -2, '2017-11-06 22:15:43'),
(14, 2, 2, -1, 27, '2018-05-22 10:02:11'),
(15, 4, 2, -1, 27, '2018-05-22 10:02:11'),
(16, 1, 2, -1, -27, '2018-05-22 10:02:11'),
(17, 3, 2, -1, -27, '2018-05-22 10:02:11'),
(18, 2, 2, -1, 24, '2018-05-22 10:51:58'),
(19, 4, 2, -1, 24, '2018-05-22 10:51:58'),
(20, 1, 2, -1, -24, '2018-05-22 10:51:58'),
(21, 3, 2, -1, -24, '2018-05-22 10:51:58');

--
-- Triggers `elo_changes`
--
DELIMITER $$
CREATE TRIGGER `elo_change_update_player` AFTER INSERT ON `elo_changes` FOR EACH ROW UPDATE Players
SET Players.elo = Players.elo + NEW.elo_change
WHERE Players.id = NEW.player_id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Groups`
--

CREATE TABLE `Groups` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `group_number` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Groups`
--

INSERT INTO `Groups` (`id`, `tournament_id`, `group_number`, `created`) VALUES
(1, 1, 1, '2017-11-05 15:39:19');

-- --------------------------------------------------------

--
-- Table structure for table `Matches`
--

CREATE TABLE `Matches` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `team1_id` int(11) NOT NULL,
  `team2_id` int(11) NOT NULL,
  `team1_score` int(11) DEFAULT NULL,
  `team2_score` int(11) DEFAULT NULL,
  `winner_id` int(11) DEFAULT NULL,
  `matchtype_id` int(11) NOT NULL,
  `table_id` int(11) DEFAULT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `started` datetime DEFAULT NULL,
  `ended` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Matches`
--

INSERT INTO `Matches` (`id`, `tournament_id`, `group_id`, `team1_id`, `team2_id`, `team1_score`, `team2_score`, `winner_id`, `matchtype_id`, `table_id`, `created`, `started`, `ended`) VALUES
(1, 1, 1, 1, 2, 2, 7, 1, 1, 1, '2017-11-05 23:47:39', '2017-11-05 00:00:00', '2017-11-05 07:00:00'),
(2, -1, -1, 3, 4, 1, 2, 4, 3, NULL, '2018-05-22 09:51:20', NULL, NULL);

--
-- Triggers `Matches`
--
DELIMITER $$
CREATE TRIGGER `winner_changed_update_elo` AFTER UPDATE ON `Matches` FOR EACH ROW BEGIN
DECLARE formerChanges INT;

IF OLD.winner_id != NEW.winner_id THEN 
	SELECT COUNT(*)
    FROM elo_changes
    WHERE NEW.id = elo_changes.match_id
    INTO formerChanges;
    
    IF formerChanges > 0 THEN
		INSERT INTO Users (name, password, role_id) VALUES (1, 1, 1);
	END IF;
    
END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Matchtypes`
--

CREATE TABLE `Matchtypes` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `k` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Matchtypes`
--

INSERT INTO `Matchtypes` (`id`, `name`, `k`) VALUES
(1, 'FT7', 24),
(2, 'BO3', 28),
(3, 'BO5', 32);

-- --------------------------------------------------------

--
-- Table structure for table `Memberships`
--

CREATE TABLE `Memberships` (
  `id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Players`
--

CREATE TABLE `Players` (
  `id` int(11) NOT NULL,
  `name` varchar(60) NOT NULL,
  `phone` varchar(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active_membership` tinyint(1) NOT NULL DEFAULT '0',
  `last_paid_membership` datetime DEFAULT NULL,
  `rating` int(11) NOT NULL DEFAULT '0',
  `elo` int(11) NOT NULL DEFAULT '1150',
  `receive_sms` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Players`
--

INSERT INTO `Players` (`id`, `name`, `phone`, `created`, `active_membership`, `last_paid_membership`, `rating`, `elo`, `receive_sms`) VALUES
(1, 'Sven Wonsyld', '28906978', '2018-05-24 00:09:04', 0, NULL, 0, 1892, 1),
(2, 'Troels Trier', '28966601', '2018-05-24 00:09:04', 0, NULL, 0, 1698, 1),
(3, 'Niels Wonsyld', '20912899', '2018-05-24 00:09:04', 0, NULL, 0, 1635, 1),
(4, 'Hannes Wallimann', '98989898', '2018-05-24 00:09:04', 0, NULL, 0, 1617, 1),
(5, 'Joakim Sandal', '25474588', '2018-05-24 00:09:04', 0, NULL, 0, 1601, 1),
(6, 'Jacob Hviid', '26482500', '2018-05-24 00:09:04', 0, NULL, 0, 1596, 1),
(7, 'Jonathan Juel', '28262887', '2018-05-24 00:09:04', 0, NULL, 0, 1591, 1),
(8, 'Asker Hardenberg', '41436439', '2018-05-24 00:09:04', 0, NULL, 0, 1590, 1),
(9, 'Rasmus Sebulonsen', '24943929', '2018-05-24 00:09:04', 0, NULL, 0, 1585, 1),
(10, 'Martin Søgaard', '51432783', '2018-05-24 00:09:04', 0, NULL, 0, 1549, 1),
(11, 'Lea Kvistgaard', '30662956', '2018-05-24 00:09:04', 0, NULL, 0, 1516, 1),
(12, 'Amalie Bremer', '28940212', '2018-05-24 00:09:04', 0, NULL, 0, 1490, 1),
(13, 'Kim Eskildsen', '23395323', '2018-05-24 00:09:04', 0, NULL, 0, 1465, 1),
(14, 'Lars Christiansen', '31554275', '2018-05-24 00:09:04', 0, NULL, 0, 1461, 1),
(15, 'Nikolai Lorenzen', '20952592', '2018-05-24 00:09:04', 0, NULL, 0, 1433, 1),
(16, 'Kevin Lee Manaa', '40400881', '2018-05-24 00:09:04', 0, NULL, 0, 1431, 1),
(17, 'Tobias Walsøe', '23318494', '2018-05-24 00:09:04', 0, NULL, 0, 1422, 1),
(18, 'Christoffer Faurskov', '22243926', '2018-05-24 00:09:04', 0, NULL, 0, 1408, 1),
(19, 'Kristian Schmidt', '28125351', '2018-05-24 00:09:04', 0, NULL, 0, 1369, 1),
(20, 'Jean Hickel', '53351153', '2018-05-24 00:09:04', 0, NULL, 0, 1366, 1),
(21, 'Kåre Lassen', '40805950', '2018-05-24 00:09:04', 0, NULL, 0, 1358, 1),
(22, 'Malthe Petersen', '22632696', '2018-05-24 00:09:04', 0, NULL, 0, 1354, 1),
(23, 'Mathias Severin', '26791601', '2018-05-24 00:09:04', 0, NULL, 0, 1353, 1),
(24, 'Peter Sonne-Holm', '28197381', '2018-05-24 00:09:04', 0, NULL, 0, 1339, 1),
(25, 'Emil Savery', '53763661', '2018-05-24 00:09:04', 0, NULL, 0, 1325, 1),
(26, 'Camilla Lohmann', '27512817', '2018-05-24 00:09:04', 0, NULL, 0, 1323, 1),
(27, 'Rasmus Lund', '26813948', '2018-05-24 00:09:04', 0, NULL, 0, 1318, 1),
(28, 'Jonas Gundersen', '30253027', '2018-05-24 00:09:04', 0, NULL, 0, 1310, 1),
(29, 'Thomas Bjerremand', '22934864', '2018-05-24 00:09:04', 0, NULL, 0, 1309, 1),
(30, 'David Kvistgaard', '40981262', '2018-05-24 00:09:04', 0, NULL, 0, 1304, 1),
(31, 'Krisztian Bali', '56565656', '2018-05-24 00:09:04', 0, NULL, 0, 1302, 1),
(32, 'Gunnar Sørensen', '28484371', '2018-05-24 00:09:04', 0, NULL, 0, 1287, 1),
(33, 'Amalie Wolff', '26843487', '2018-05-24 00:09:04', 0, NULL, 0, 1287, 1),
(34, 'Nermin Durakovic', '31777272', '2018-05-24 00:09:04', 0, NULL, 0, 1287, 1),
(35, 'Niels Thomsen', '23449788', '2018-05-24 00:09:04', 0, NULL, 0, 1275, 1),
(36, 'Terkel Wonsyld', '52409279', '2018-05-24 00:09:04', 0, NULL, 0, 1271, 1),
(37, 'Simon Kussef Lauridsen', '31197499', '2018-05-24 00:09:04', 0, NULL, 0, 1271, 1),
(38, 'Zen Thomsen', '20405838', '2018-05-24 00:09:04', 0, NULL, 0, 1268, 1),
(39, 'Albert Hald-Bjerrum', '26118112', '2018-05-24 00:09:04', 0, NULL, 0, 1263, 1),
(40, 'Kåre Kiib', '60247787', '2018-05-24 00:09:04', 0, NULL, 0, 1263, 1),
(41, 'Søren Olesen', '30682996', '2018-05-24 00:09:04', 0, NULL, 0, 1260, 1),
(42, 'Lasse Møller', '22237469', '2018-05-24 00:09:04', 0, NULL, 0, 1260, 1),
(43, 'Johannes Grosbøll-Poulsen', '20442347', '2018-05-24 00:09:04', 0, NULL, 0, 1247, 1),
(44, 'Anders von der Recke', '60126640', '2018-05-24 00:09:04', 0, NULL, 0, 1243, 1),
(45, 'Lars Kofod Jensen', '23351908', '2018-05-24 00:09:04', 0, NULL, 0, 1240, 1),
(46, 'Aslak Vangguard', '20837117', '2018-05-24 00:09:04', 0, NULL, 0, 1240, 1),
(47, 'Jacob Jacobsen', '51265383', '2018-05-24 00:09:04', 0, NULL, 0, 1239, 1),
(48, 'Simon Kvistgaard', '30742037', '2018-05-24 00:09:04', 0, NULL, 0, 1238, 1),
(49, 'Casper Vesterskov', '29701988', '2018-05-24 00:09:04', 0, NULL, 0, 1236, 1),
(50, 'Maria Steinaa', '41416068', '2018-05-24 00:09:04', 0, NULL, 0, 1235, 1),
(51, 'Sebastian Johansson', '40947999', '2018-05-24 00:09:04', 0, NULL, 0, 1230, 1),
(52, 'Sture Sandø', '40894720', '2018-05-24 00:09:04', 0, NULL, 0, 1221, 1),
(53, 'Honore Legin', '74250176', '2018-05-24 00:09:04', 0, NULL, 0, 1221, 1),
(54, 'Michael Billing', '21723612', '2018-05-24 00:09:04', 0, NULL, 0, 1220, 1),
(55, 'Andreas Tandrup Christensen', '31136273', '2018-05-24 00:09:04', 0, NULL, 0, 1216, 1),
(56, 'Laurits Pilegaard', '28110381', '2018-05-24 00:09:04', 0, NULL, 0, 1213, 1),
(57, 'Toke Grøfte', '26149019', '2018-05-24 00:09:04', 0, NULL, 0, 1212, 1),
(58, 'Jakob T-Bomb Nielsen', '53628252', '2018-05-24 00:09:04', 0, NULL, 0, 1209, 1),
(59, 'Kalle Hansen', '41312051', '2018-05-24 00:09:04', 0, NULL, 0, 1206, 1),
(60, 'Jaroslaw Jerzy', '13371337', '2018-05-24 00:09:04', 0, NULL, 0, 1205, 1),
(61, 'Morten Kiilerich', '29112295', '2018-05-24 00:09:04', 0, NULL, 0, 1202, 1),
(62, 'Tobias Aam', '20966676', '2018-05-24 00:09:04', 0, NULL, 0, 1202, 1),
(63, 'Nikolaj \"Roxanne\" Benzon', '53524741', '2018-05-24 00:09:04', 0, NULL, 0, 1199, 1),
(64, 'Emil Vibild', '26136337', '2018-05-24 00:09:04', 0, NULL, 0, 1198, 1),
(65, 'Christian Bech', '22270074', '2018-05-24 00:09:04', 0, NULL, 0, 1196, 1),
(66, 'Martin Christensen', '23358655', '2018-05-24 00:09:04', 0, NULL, 0, 1191, 1),
(67, 'David Ahrenkiel', '51621573', '2018-05-24 00:09:04', 0, NULL, 0, 1191, 1),
(68, 'Ljubomir Kracun', '42424333', '2018-05-24 00:09:04', 0, NULL, 0, 1186, 1),
(69, 'Sofus Bellers-Pedersen', '51660440', '2018-05-24 00:09:04', 0, NULL, 0, 1186, 1),
(70, 'Christopher Hostrup', '26713963', '2018-05-24 00:09:04', 0, NULL, 0, 1186, 1),
(71, 'Peter Toubro', '29367904', '2018-05-24 00:09:04', 0, NULL, 0, 1184, 1),
(72, 'Mads Breumsøe', '40516030', '2018-05-24 00:09:04', 0, NULL, 0, 1183, 1),
(73, 'Bo Josephsen', '41723326', '2018-05-24 00:09:04', 0, NULL, 0, 1179, 1),
(74, 'Rasmus Mortensen', '50576742', '2018-05-24 00:09:04', 0, NULL, 0, 1179, 1),
(75, 'Mads Mølgaard', '42428617', '2018-05-24 00:09:04', 0, NULL, 0, 1175, 1),
(76, 'Nathalie Saltz', '42335566', '2018-05-24 00:09:04', 0, NULL, 0, 1175, 1),
(77, 'John J-LO Laurits Olesen', '31413305', '2018-05-24 00:09:04', 0, NULL, 0, 1174, 1),
(78, 'Julie Hallas Hartvig', '22881255', '2018-05-24 00:09:04', 0, NULL, 0, 1171, 1),
(79, 'Jesper Rosengaard', '30452305', '2018-05-24 00:09:04', 0, NULL, 0, 1169, 1),
(80, 'Marco Kristensen', '53613427', '2018-05-24 00:09:04', 0, NULL, 0, 1168, 1),
(81, 'Joachim Sestoft', '25475103', '2018-05-24 00:09:04', 0, NULL, 0, 1166, 1),
(82, 'Barvagt 1', '88888888', '2018-05-24 00:09:04', 0, NULL, 0, 1165, 1),
(83, 'Sebastian Mesterton Graae', '30261974', '2018-05-24 00:09:04', 0, NULL, 0, 1164, 1),
(84, 'Nana Dall', '22778462', '2018-05-24 00:09:04', 0, NULL, 0, 1162, 1),
(85, 'Vivien de Neergaard', '25385520', '2018-05-24 00:09:04', 0, NULL, 0, 1161, 1),
(86, 'Julie Anna Monies', '25546061', '2018-05-24 00:09:04', 0, NULL, 0, 1158, 1),
(87, 'Martin BoBo Thomsen', '31313137', '2018-05-24 00:09:04', 0, NULL, 0, 1157, 1),
(88, 'Thobias Berg', '22542534', '2018-05-24 00:09:04', 0, NULL, 0, 1157, 1),
(89, 'Christian Würtz', '21685442', '2018-05-24 00:09:04', 0, NULL, 0, 1156, 1),
(90, 'David Andersen', '42740881', '2018-05-24 00:09:04', 0, NULL, 0, 1156, 1),
(91, 'Tomas Lieberkind', '53131337', '2018-05-24 00:09:04', 0, NULL, 0, 1156, 1),
(92, 'Niels Dreijer', '51761331', '2018-05-24 00:09:04', 0, NULL, 0, 1155, 1),
(93, 'Kristian Bast', '60157200', '2018-05-24 00:09:04', 0, NULL, 0, 1154, 1),
(94, 'Mads Friis', '24432492', '2018-05-24 00:09:04', 0, NULL, 0, 1152, 1),
(95, 'Benjamin Bendtsen', '29467299', '2018-05-24 00:09:04', 0, NULL, 0, 1151, 1),
(96, 'Mikkel Uldall', '28895037', '2018-05-24 00:09:04', 0, NULL, 0, 1150, 1),
(97, 'Mikkel Ian Hansen', '30426190', '2018-05-24 00:09:04', 0, NULL, 0, 1150, 1),
(98, 'Frederik Vitkov', '21371090', '2018-05-24 00:09:04', 0, NULL, 0, 1148, 1),
(99, 'Nikolaj Friiiis Østergaard', '21702017', '2018-05-24 00:09:04', 0, NULL, 0, 1148, 1),
(100, 'Villiam Nybjerg', '41394754', '2018-05-24 00:09:04', 0, NULL, 0, 1147, 1),
(101, 'Line Stampe Nielsen', '22292009', '2018-05-24 00:09:04', 0, NULL, 0, 1146, 1),
(102, 'Tanja Lauridsen', '26276046', '2018-05-24 00:09:04', 0, NULL, 0, 1145, 1),
(103, 'Kim Kragh', '42707921', '2018-05-24 00:09:04', 0, NULL, 0, 1145, 1),
(104, 'Mia von G. Petersen', '51346552', '2018-05-24 00:09:04', 0, NULL, 0, 1144, 1),
(105, 'Kasper Birkelund', '40686574', '2018-05-24 00:09:04', 0, NULL, 0, 1142, 1),
(106, 'Nina Nørgaard Sørensen', '28152752', '2018-05-24 00:09:04', 0, NULL, 0, 1142, 1),
(107, 'August Olsen', '93999194', '2018-05-24 00:09:04', 0, NULL, 0, 1142, 1),
(108, 'Rene Adam', '26237007', '2018-05-24 00:09:04', 0, NULL, 0, 1140, 1),
(109, 'Peter Beljaev', '61775977', '2018-05-24 00:09:04', 0, NULL, 0, 1140, 1),
(110, 'Axel Lass', '22561955', '2018-05-24 00:09:04', 0, NULL, 0, 1139, 1),
(111, 'Philip Henriks', '29405513', '2018-05-24 00:09:04', 0, NULL, 0, 1139, 1),
(112, 'Thomas Holst-Hansen', '26839224', '2018-05-24 00:09:04', 0, NULL, 0, 1138, 1),
(113, 'Thomas Werchmeister', '26990086', '2018-05-24 00:09:04', 0, NULL, 0, 1137, 1),
(114, 'Magnus Nørgaard', '29702077', '2018-05-24 00:09:04', 0, NULL, 0, 1137, 1),
(115, 'Mikkel Laybourn', '28892847', '2018-05-24 00:09:04', 0, NULL, 0, 1136, 1),
(116, 'Andreas Sihm', '50534662', '2018-05-24 00:09:04', 0, NULL, 0, 1135, 1),
(117, 'Morten Lau Jeppesen', '42406455', '2018-05-24 00:09:04', 0, NULL, 0, 1135, 1),
(118, 'Bjarke Hou Kammersgaard', '61333789', '2018-05-24 00:09:04', 0, NULL, 0, 1135, 1),
(119, 'Daniel Schultz', '31102099', '2018-05-24 00:09:04', 0, NULL, 0, 1134, 1),
(120, 'Louise Meilstrup', '26208662', '2018-05-24 00:09:04', 0, NULL, 0, 1134, 1),
(121, 'Tue Rønhave Laursen', '26114213', '2018-05-24 00:09:04', 0, NULL, 0, 1134, 1),
(122, 'Anna Rosenmai', '26831386', '2018-05-24 00:09:04', 0, NULL, 0, 1133, 1),
(123, 'Nis Simonsen', '31654439', '2018-05-24 00:09:04', 0, NULL, 0, 1132, 1),
(124, 'Simon Gerbild', '60244171', '2018-05-24 00:09:04', 0, NULL, 0, 1132, 1),
(125, 'Simon Nelbom', '26480041', '2018-05-24 00:09:04', 0, NULL, 0, 1131, 1),
(126, 'Stephane Hamacher', '25136060', '2018-05-24 00:09:04', 0, NULL, 0, 1131, 1),
(127, 'Peter Bast', '60717346', '2018-05-24 00:09:04', 0, NULL, 0, 1131, 1),
(128, 'Mikkel Exner', '61714765', '2018-05-24 00:09:04', 0, NULL, 0, 1129, 1),
(129, 'Astrid Larsen', '28188377', '2018-05-24 00:09:04', 0, NULL, 0, 1129, 1),
(130, 'Rune Barfred', '22825151', '2018-05-24 00:09:04', 0, NULL, 0, 1128, 1),
(131, 'Benjamin Congiatta', '51942404', '2018-05-24 00:09:04', 0, NULL, 0, 1127, 1),
(132, 'Rasmus Fisker', '28298309', '2018-05-24 00:09:04', 0, NULL, 0, 1127, 1),
(133, 'Christopher Bonde', '60159551', '2018-05-24 00:09:04', 0, NULL, 0, 1126, 1),
(134, 'Martin Grove', '23962334', '2018-05-24 00:09:04', 0, NULL, 0, 1126, 1),
(135, 'Jonathan Walsøe', '60865158', '2018-05-24 00:09:04', 0, NULL, 0, 1126, 1),
(136, 'Simon Andreas Hansen', '61113557', '2018-05-24 00:09:04', 0, NULL, 0, 1126, 1),
(137, 'Christian Drüke', '31731076', '2018-05-24 00:09:04', 0, NULL, 0, 1125, 1),
(138, 'Loui Baeré', '53633060', '2018-05-24 00:09:04', 0, NULL, 0, 1124, 1),
(139, 'Jeppe \"Lille stol\" Bertelsen', '28888312', '2018-05-24 00:09:04', 0, NULL, 0, 1123, 1),
(140, 'Thias Boesen', '20313984', '2018-05-24 00:09:04', 0, NULL, 0, 1123, 1),
(141, 'Mikkel Jespersen', '25364283', '2018-05-24 00:09:04', 0, NULL, 0, 1123, 1),
(142, 'Morten Rasmussen', '31182207', '2018-05-24 00:09:04', 0, NULL, 0, 1123, 1),
(143, 'Simon Høj', '42600580', '2018-05-24 00:09:04', 0, NULL, 0, 1122, 1),
(144, 'Kasper Polaris Mou', '31694156', '2018-05-24 00:09:04', 0, NULL, 0, 1122, 1),
(145, 'Magnus Reinhold', '25345056', '2018-05-24 00:09:04', 0, NULL, 0, 1121, 1),
(146, 'Camilla Bech Jørgensen', '28760912', '2018-05-24 00:09:04', 0, NULL, 0, 1121, 1),
(147, 'Kasper Ditlevsen', '31533434', '2018-05-24 00:09:04', 0, NULL, 0, 1121, 1),
(148, 'Cecilie Gunris', '30223805', '2018-05-24 00:09:04', 0, NULL, 0, 1120, 1),
(149, 'Mikkel Agersnap', '26363727', '2018-05-24 00:09:04', 0, NULL, 0, 1120, 1),
(150, 'Nicholas Marx Stenaae', '42213336', '2018-05-24 00:09:04', 0, NULL, 0, 1119, 1),
(151, 'Julian Dünnwald', '28923990', '2018-05-24 00:09:04', 0, NULL, 0, 1118, 1),
(152, 'Anders Hansen', '61604324', '2018-05-24 00:09:04', 0, NULL, 0, 1118, 1),
(153, 'Mads Akselbo Holm', '25397139', '2018-05-24 00:09:04', 0, NULL, 0, 1118, 1),
(154, 'Sheku Sankoh', '22132613', '2018-05-24 00:09:04', 0, NULL, 0, 1117, 1),
(155, 'Jens Didrik Bjerre Donatzsky Hansen', '42164804', '2018-05-24 00:09:04', 0, NULL, 0, 1117, 1),
(156, 'Kasper Møller ', '42919023', '2018-05-24 00:09:04', 0, NULL, 0, 1117, 1),
(157, 'William Unmack', '60462856', '2018-05-24 00:09:04', 0, NULL, 0, 1117, 1),
(158, 'Rune Søndergaard', '26820854', '2018-05-24 00:09:04', 0, NULL, 0, 1116, 1),
(159, 'Barvagt 3', '12121212', '2018-05-24 00:09:04', 0, NULL, 0, 1116, 1),
(160, 'Kristian Pedersen', '61799999', '2018-05-24 00:09:04', 0, NULL, 0, 1116, 1),
(161, 'Michael Bang', '28574520', '2018-05-24 00:09:04', 0, NULL, 0, 1116, 1),
(162, 'Jonathan Ranmar', '20617511', '2018-05-24 00:09:04', 0, NULL, 0, 1116, 1),
(163, 'Martin Thygesen', '31767611', '2018-05-24 00:09:04', 0, NULL, 0, 1116, 1),
(164, 'Coco Jensen', '61462471', '2018-05-24 00:09:04', 0, NULL, 0, 1116, 1),
(165, 'Niels Schøtt Hvidberg', '23939123', '2018-05-24 00:09:04', 0, NULL, 0, 1115, 1),
(166, 'Jan Chu', '26566976', '2018-05-24 00:09:04', 0, NULL, 0, 1115, 1),
(167, 'Pia Buhl', '51909360', '2018-05-24 00:09:04', 0, NULL, 0, 1115, 1),
(168, 'Joachim Sejr', '41954713', '2018-05-24 00:09:04', 0, NULL, 0, 1115, 1),
(169, 'Miki Tejlbo', '28257131', '2018-05-24 00:09:04', 0, NULL, 0, 1115, 1),
(170, 'Morten Døssing', '60514899', '2018-05-24 00:09:04', 0, NULL, 0, 1115, 1),
(171, 'Kim Uffe Pedersen', '61781004', '2018-05-24 00:09:04', 0, NULL, 0, 1114, 1),
(172, 'Nicolai Jacobsen', '21950063', '2018-05-24 00:09:04', 0, NULL, 0, 1114, 1),
(173, 'Alexander Brandi', '22123959', '2018-05-24 00:09:04', 0, NULL, 0, 1114, 1),
(174, 'Tobias Rasmussen', '26363653', '2018-05-24 00:09:04', 0, NULL, 0, 1114, 1),
(175, 'Ulrik Nikolajsen', '51900052', '2018-05-24 00:09:04', 0, NULL, 0, 1114, 1),
(176, 'Andreas Jonsson', '29870342', '2018-05-24 00:09:04', 0, NULL, 0, 1114, 1),
(177, 'Emil Erichsen', '26195008', '2018-05-24 00:09:04', 0, NULL, 0, 1114, 1),
(178, 'Mikael Selsmark Hansen', '20437379', '2018-05-24 00:09:04', 0, NULL, 0, 1113, 1),
(179, 'Kasper Weidick', '22996585', '2018-05-24 00:09:04', 0, NULL, 0, 1113, 1),
(180, 'Martin Andersen', '71574867', '2018-05-24 00:09:04', 0, NULL, 0, 1113, 1),
(181, 'Christian Petersen', '51290341', '2018-05-24 00:09:04', 0, NULL, 0, 1113, 1),
(182, 'Oluf Pedersen', '20703744', '2018-05-24 00:09:04', 0, NULL, 0, 1113, 1),
(183, 'Kåre Peitersen', '29404076', '2018-05-24 00:09:04', 0, NULL, 0, 1113, 1),
(184, 'Rasmus Andersen', '61403031', '2018-05-24 00:09:04', 0, NULL, 0, 1113, 1),
(185, 'Rene Petræus', '20716566', '2018-05-24 00:09:04', 0, NULL, 0, 1112, 1),
(186, 'Klaus Malmberg', '31413884', '2018-05-24 00:09:04', 0, NULL, 0, 1112, 1),
(187, 'Jacob Kofod', '51846171', '2018-05-24 00:09:04', 0, NULL, 0, 1112, 1),
(188, 'Kasper B. Olesen', '61700029', '2018-05-24 00:09:04', 0, NULL, 0, 1112, 1),
(189, 'Ian Aaboe', '60127007', '2018-05-24 00:09:04', 0, NULL, 0, 1112, 1),
(190, 'Brian Hansen', '29284366', '2018-05-24 00:09:04', 0, NULL, 0, 1111, 1),
(191, 'Anton Pedersen', '22375376', '2018-05-24 00:09:04', 0, NULL, 0, 1111, 1),
(192, 'Lea Korsholm', '28199168', '2018-05-24 00:09:04', 0, NULL, 0, 1111, 1),
(193, 'Peter Enevoldsen', '42765610', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(194, 'Jakob Tolstrup Bech', '29609730', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(195, 'Micelle Ruberg', '26801082', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(196, 'Jacob Bundgaard Knudsen', '61466439', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(197, 'Anna Handberg', '22769830', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(198, 'Andreas Bech', '21203044', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(199, 'Jonatan May', '26165562', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(200, 'Rasmus Knap', '28195190', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(201, 'Martin Nørr', '30946780', '2018-05-24 00:09:04', 0, NULL, 0, 1110, 1),
(202, 'Martina Iversen', '25334937', '2018-05-24 00:09:04', 0, NULL, 0, 1109, 1),
(203, 'Rune Mortensen', '41263300', '2018-05-24 00:09:04', 0, NULL, 0, 1109, 1),
(204, 'Pelle Reehaug', '28155181', '2018-05-24 00:09:04', 0, NULL, 0, 1109, 1),
(205, 'Antoine Perret', '25731314', '2018-05-24 00:09:04', 0, NULL, 0, 1109, 1),
(206, 'Jonathan Siahaan', '50533210', '2018-05-24 00:09:04', 0, NULL, 0, 1109, 1),
(207, 'Oliver Rohde', '26782587', '2018-05-24 00:09:04', 0, NULL, 0, 1109, 1),
(208, 'Thomas Christensen', '42458170', '2018-05-24 00:09:04', 0, NULL, 0, 1109, 1),
(209, 'Anders Kær Bennetsen', '22865678', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(210, 'Jacob Dyrhauge', '29808090', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(211, 'Steen Wulff', '61275024', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(212, 'Lasse Axholt', '22304376', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(213, 'Nick Thomsen', '50880216', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(214, 'Jack Mazin', '26253482', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(215, 'Anders Poulsen', '51929699', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(216, 'Tommy Bøndergaard', '51903389', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(217, 'Jens Luckenbach', '31232791', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(218, 'Villads Bang Pelle', '22769432', '2018-05-24 00:09:04', 0, NULL, 0, 1108, 1),
(219, 'Per Bach', '61266328', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(220, 'Claus Laustsen', '24695957', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(221, 'Anton Paulsen', '26716264', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(222, 'Mads Bramsen', '23982040', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(223, 'Frede Sunde Silfen', '28150420', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(224, 'David Hansen', '40926592', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(225, 'Rolf Amfelt', '61679592', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(226, 'Kristine Louise ', '22813360', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(227, 'Camilla Mann ', '29901991', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(228, 'Laust Deleuran', '22475710', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(229, 'Buster Marker Jønsson', '61609190', '2018-05-24 00:09:04', 0, NULL, 0, 1107, 1),
(230, 'Katrine Scheibye', '40139898', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(231, 'Patrick Asschenfeldt', '30100350', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(232, 'Tivas Laursen', '53807712', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(233, 'Nicolai Seidelin', '22790598', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(234, 'Nicolai Mathiesen', '28769548', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(235, 'Sune Voss', '40514476', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(236, 'Simon Kristensen', '42422415', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(237, 'Barvagt 2', '88888889', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(238, 'Carsten Snejbjerg', '51906117', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(239, 'Stine Frøkiær', '51801656', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(240, 'Joen Joensen', '22465235', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(241, 'Rasmus Jakobsen', '51928080', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(242, 'Nanna Hilton', '26178010', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(243, 'Morten Petersen', '30750663', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(244, 'Anne Rønne', '29802777', '2018-05-24 00:09:04', 0, NULL, 0, 1106, 1),
(245, 'Maja Kjems', '26282666', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(246, 'Anders Friis', '22165590', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(247, 'Bernt Elkjær', '24497510', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(248, 'Martin Todorov', '30132209', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(249, 'Christian Hesselberg', '22886728', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(250, 'Morten Vedel ', '30647402', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(251, 'Stíne Rosenbeck', '29618445', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(252, 'Rune Hilbert', '28766855', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(253, 'Ignas Danielius', '50299475', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(254, 'Christoffer Aarslew', '26167376', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(255, 'Christian Ipsen', '29278247', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(256, 'Nicklas Andersen', '40592978', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(257, 'Tobias Falck Kaag', '61344561', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(258, 'Jacob Sjöblom', '21155840', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(259, 'Emil Madsen', '50538056', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(260, 'Benjamin Olsen', '20624500', '2018-05-24 00:09:04', 0, NULL, 0, 1105, 1),
(261, 'Martin Milling', '29406282', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(262, 'Christian Stoltze', '24220326', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(263, 'Nicki Snejbjerg', '52585309', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(264, 'Bjørn Nordkvist Birk', '28259306', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(265, 'Christian Engelbrekt', '28944567', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(266, 'Lau Kaspersen', '22284796', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(267, 'Anna-Louise Bundgaard', '26822619', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(268, 'Magnus Stagsted', '31705220', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(269, 'Nadi Othman', '26436098', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(270, 'Patrick Nygaard', '30703266', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(271, 'Nick Borch', '41661317', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(272, 'Anders Sparre Jakobsen', '61334514', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(273, 'Mads Gosvig', '28941773', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(274, 'Mattis Riskjær Bentsen', '28145113', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(275, 'Heine Kaarsberg', '50805063', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(276, 'Lea Pedersen', '28121592', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(277, 'Gustav Rødsgaard', '20575550', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(278, 'Bjørn Vedel', '51926730', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(279, 'Andreas Simonsen', '22395584', '2018-05-24 00:09:04', 0, NULL, 0, 1104, 1),
(280, 'Joakim Brüchmann', '28193347', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(281, 'Vasil Aleksandrov', '27718965', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(282, 'Kristoffer Tuborg', '42921698', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(283, 'Thor Larholm', '27511600', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(284, 'Anders Nyborg', '50578324', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(285, 'Jakob Holm Ullum', '29800004', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(286, 'Nicki Bertelsen', '60891530', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(287, 'Kristian Winther', '21602025', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(288, 'Charlotte Rhee', '40424311', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(289, 'Jakob Petri', '31411234', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(290, 'Stig Søgaard', '31258594', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(291, 'Frederik Fenger', '60613860', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(292, 'Christian Taylor', '28152151', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(293, 'Lise Grand', '51723067', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(294, 'Frederik Løvenørn', '41170750', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(295, 'Sebastian Risbøl', '31526256', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(296, 'Joachim August', '40994683', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(297, 'Kasper Ring', '31155333', '2018-05-24 00:09:04', 0, NULL, 0, 1103, 1),
(298, 'Jens Axel Thorbøll', '31610706', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(299, 'Cong Nguyen', '31141984', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(300, 'Line Høvring', '26122814', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(301, 'Nicholas Hansen', '26283115', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(302, 'Edita Talic', '23713192', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(303, 'Pascal Ossian', '28198012', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(304, 'Christian Nonnemann', '60504527', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(305, 'Signe Baggesen', '41272440', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(306, 'Jesper Bækdal', '23259716', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(307, 'Kristoffer Strunge', '27287722', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(308, 'Sisse Fihl Skyum', '30662289', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(309, 'Kim Sørensen', '29993334', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(310, 'Christian Bøggild', '26145573', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(311, 'Johannes Pham', '20655720', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(312, 'Anne Ryelund Nielsen', '61435674', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(313, 'Jasmina Pelivani', '61240130', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(314, 'Peter Poulsen', '25542851', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(315, 'Kristian Simonsen', '24222606', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(316, 'Nilas Aleksander', '26433344', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(317, 'Frederic Daniel Andre Terrible', '25147850', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(318, 'Mathias Frost', '28257121', '2018-05-24 00:09:04', 0, NULL, 0, 1102, 1),
(319, 'Mikkel Hjalager Bach', '27850251', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(320, 'Sonni Bartsch', '30116869', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(321, 'Cecilie Frode-Jensen', '40173259', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(322, 'Mads Andersen', '51944791', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(323, 'Jonas Jørgensen', '30696020', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(324, 'Mikkel Bujok', '22263703', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(325, 'Daniel Jensen', '29266190', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(326, 'Mads Bjerg Frandsen', '22862529', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(327, 'Kim Lynge', '27280119', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(328, 'Petra Sardést', '20829229', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(329, 'Hans-Peter Krogh Andersen', '30335671', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(330, 'Kim Trap', '26491219', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(331, 'Andreas Kristensen', '26351831', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(332, 'Patrick Mikkelsen', '50558525', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(333, 'Arbi Jebali', '41747966', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(334, 'Pencho Dimitrov', '30954793', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(335, 'Marie List Amstrup', '31376444', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(336, 'Steffen Wiese', '60143353', '2018-05-24 00:09:04', 0, NULL, 0, 1101, 1),
(337, 'Stine Larsen', '61140635', '2018-05-24 00:09:04', 0, NULL, 0, 1100, 1),
(338, 'Ann-Mari Runge', '50705544', '2018-05-24 00:09:04', 0, NULL, 0, 1100, 1);

-- --------------------------------------------------------

--
-- Table structure for table `rating_changes`
--

CREATE TABLE `rating_changes` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `rating_change` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `rating_changes`
--

INSERT INTO `rating_changes` (`id`, `tournament_id`, `player_id`, `rating_change`, `created`) VALUES
(1, 1, 1, 1200, '2017-11-05 15:40:34'),
(2, 1, 1, 1200, '2017-09-01 00:00:00'),
(3, 1, 2, 20, '2017-11-05 15:51:28');

-- --------------------------------------------------------

--
-- Table structure for table `Roles`
--

CREATE TABLE `Roles` (
  `id` int(11) NOT NULL,
  `name` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Roles`
--

INSERT INTO `Roles` (`id`, `name`) VALUES
(1, 'admin'),
(2, 'Competent'),
(3, 'Barvagt');

-- --------------------------------------------------------

--
-- Table structure for table `tables`
--

CREATE TABLE `tables` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `occupied` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tables`
--

INSERT INTO `tables` (`id`, `name`, `occupied`) VALUES
(1, 'Bord 1', 0),
(2, 'Bord 2', 0),
(3, 'Bord 3', 0),
(4, 'Bord 4', 0),
(5, 'Bord 5', 0);

-- --------------------------------------------------------

--
-- Table structure for table `Teams`
--

CREATE TABLE `Teams` (
  `id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `player1_id` int(11) NOT NULL,
  `player2_id` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Teams`
--

INSERT INTO `Teams` (`id`, `tournament_id`, `group_id`, `player1_id`, `player2_id`, `created`) VALUES
(1, 1, 1, 1, 2, '2017-11-05 20:52:40'),
(2, 1, 1, 3, 4, '2017-11-05 20:52:40'),
(3, -1, -1, 1, 3, '2018-05-22 09:49:02'),
(4, -1, -1, 2, 4, '2018-05-22 09:49:43');

-- --------------------------------------------------------

--
-- Table structure for table `Tournaments`
--

CREATE TABLE `Tournaments` (
  `id` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `started` datetime DEFAULT NULL,
  `ended` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Tournaments`
--

INSERT INTO `Tournaments` (`id`, `created`, `started`, `ended`) VALUES
(1, '2017-11-05 15:39:01', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `id` int(11) NOT NULL,
  `name` varchar(1) NOT NULL,
  `password` varchar(1) NOT NULL,
  `role_id` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Users`
--

INSERT INTO `Users` (`id`, `name`, `password`, `role_id`) VALUES
(1, '1', '1', 1);

-- --------------------------------------------------------

--
-- Structure for view `current_rating`
--
DROP TABLE IF EXISTS `current_rating`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `current_rating`  AS  select `players`.`id` AS `id`,`players`.`name` AS `name`,sum(`rating_changes`.`rating_change`) AS `rating` from (`players` join `rating_changes` on((`players`.`id` = `rating_changes`.`player_id`))) where (`rating_changes`.`created` >= (curdate() - interval 8 week)) group by `players`.`id` order by `rating` desc ;

-- --------------------------------------------------------

--
-- Structure for view `current_ratings`
--
DROP TABLE IF EXISTS `current_ratings`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `current_ratings`  AS  select `players`.`id` AS `id`,`players`.`name` AS `name`,sum(`rating_changes`.`rating_change`) AS `rating` from (`players` left join `rating_changes` on((`players`.`id` = `rating_changes`.`player_id`))) where (`rating_changes`.`created` >= (curdate() - interval 8 week)) group by `players`.`id` order by `rating` desc ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `elo_changes`
--
ALTER TABLE `elo_changes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Groups`
--
ALTER TABLE `Groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Matches`
--
ALTER TABLE `Matches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Matchtypes`
--
ALTER TABLE `Matchtypes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Memberships`
--
ALTER TABLE `Memberships`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Players`
--
ALTER TABLE `Players`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rating_changes`
--
ALTER TABLE `rating_changes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Roles`
--
ALTER TABLE `Roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tables`
--
ALTER TABLE `tables`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Teams`
--
ALTER TABLE `Teams`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Tournaments`
--
ALTER TABLE `Tournaments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `elo_changes`
--
ALTER TABLE `elo_changes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `Groups`
--
ALTER TABLE `Groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `Matches`
--
ALTER TABLE `Matches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Matchtypes`
--
ALTER TABLE `Matchtypes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Memberships`
--
ALTER TABLE `Memberships`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Players`
--
ALTER TABLE `Players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=339;

--
-- AUTO_INCREMENT for table `rating_changes`
--
ALTER TABLE `rating_changes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Roles`
--
ALTER TABLE `Roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tables`
--
ALTER TABLE `tables`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `Teams`
--
ALTER TABLE `Teams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `Tournaments`
--
ALTER TABLE `Tournaments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `Users`
--
ALTER TABLE `Users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
