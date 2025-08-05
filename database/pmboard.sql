-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Aug 05, 2025 at 05:02 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pmboard`
--

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `finish_date` date DEFAULT NULL,
  `progress` int(3) NOT NULL DEFAULT 0,
  `owner_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `title`, `description`, `finish_date`, `progress`, `owner_id`) VALUES
(1, 'Interactive application - company 1', 'Create interactive application for fetching data of company 1', NULL, 100, 1),
(2, 'Api developement for company 3', 'Build api to retriev data of company 3', NULL, 15, 2),
(3, 'Build Leage page', 'Display every user with order of their experience field', NULL, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `finish_date` date DEFAULT NULL,
  `progress` int(3) DEFAULT 0,
  `parent_project_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `title`, `description`, `finish_date`, `progress`, `parent_project_id`) VALUES
(1, 'Initialization of program', 'Initialize application and install all necessary libraries', '2025-08-05', 100, 1),
(2, 'Implement create/register using keyCloak', 'register company to keyCloak and implement on frontend redirections and implement saving access token on useContext.', '2025-08-05', 100, 1),
(3, 'implement Home page', 'requirement:\r\nHome page must include a admin dashboard that super user will be able to delete, update and insert new ...', '2025-08-05', 100, 1),
(4, 'Fix Branch conflicts', 'Check all lines of code and keep or replace ...', NULL, 28, 2);

--
-- Triggers `tasks`
--
DELIMITER $$
CREATE TRIGGER `prevent_edit_completed_task` BEFORE UPDATE ON `tasks` FOR EACH ROW BEGIN
    -- Prevent editing if already completed
    IF OLD.progress = 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot edit a completed task';
    END IF;

    -- If progress is being set to 100 now, set finish_date
    IF NEW.progress = 100 AND OLD.progress <> 100 THEN
        SET NEW.finish_date = CURDATE();
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_project_progress` AFTER UPDATE ON `tasks` FOR EACH ROW BEGIN
    DECLARE total_progress DECIMAL(5,2);
    DECLARE task_count INT;

    SELECT SUM(progress), COUNT(*) 
    INTO total_progress, task_count
    FROM tasks
    WHERE parent_project_id = NEW.parent_project_id;

    UPDATE projects
    SET progress = FLOOR(total_progress / task_count)
    WHERE id = NEW.parent_project_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_project_progress_after_insert` AFTER INSERT ON `tasks` FOR EACH ROW BEGIN
    DECLARE total_progress DECIMAL(5,2);
    DECLARE task_count INT;

    SELECT SUM(progress), COUNT(*) 
    INTO total_progress, task_count
    FROM tasks
    WHERE parent_project_id = NEW.parent_project_id;

    UPDATE projects
    SET progress = FLOOR(total_progress / task_count)
    WHERE id = NEW.parent_project_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(12) NOT NULL,
  `joined_date` date NOT NULL,
  `refresh_token` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `joined_date`, `refresh_token`) VALUES
(1, 'user1', '2025-08-05', NULL),
(2, 'user2', '2025-08-04', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Owner_of_project` (`owner_id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `parent_project_of_task` (`parent_project_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `Owner_of_project` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `parent_project_of_task` FOREIGN KEY (`parent_project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
