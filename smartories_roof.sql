-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 22, 2022 at 01:23 PM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `roof`
--

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `dept_id` int(20) NOT NULL,
  `department` varchar(99) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`dept_id`, `department`) VALUES
(1, 'Production'),
(2, 'Quality Analysis'),
(3, 'Maintenance'),
(4, 'General');

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location` (
  `location_id` varchar(20) NOT NULL,
  `location` varchar(20) NOT NULL,
  `detailed_address` varchar(99) NOT NULL,
  `notes` varchar(99) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `privileges`
--

CREATE TABLE `privileges` (
  `id` int(11) NOT NULL,
  `privilege` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `privileges`
--

INSERT INTO `privileges` (`id`, `privilege`) VALUES
(0, 'No access'),
(1, 'view'),
(2, 'edit'),
(3, 'create/delete');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `sno` int(90) NOT NULL,
  `roles` varchar(98) NOT NULL,
  `last_updated_by` varchar(90) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`sno`, `roles`, `last_updated_by`, `last_updated_on`) VALUES
(1, 'SmartAdmin', 'UM1001', '2022-11-22 12:20:38'),
(2, 'SmartUser', 'UM1001', '2022-11-22 12:20:46'),
(3, 'SiteAdmin', 'UM1001', '2022-11-22 12:20:53'),
(4, 'SiteUsers', 'UM1001', '2022-11-22 12:20:58'),
(5, 'Operator', 'UM1001', '2022-11-22 12:21:04');

-- --------------------------------------------------------

--
-- Table structure for table `sites`
--

CREATE TABLE `sites` (
  `sno` int(20) NOT NULL,
  `site_id` varchar(10) NOT NULL,
  `site_name` varchar(20) NOT NULL,
  `location_id` varchar(20) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_updated_by` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sites`
--

INSERT INTO `sites` (`sno`, `site_id`, `site_name`, `location_id`, `last_updated_on`, `last_updated_by`) VALUES
(1, 'smartories', 'Smartories', 'LO1001', '2022-11-22 12:21:31', 'UM1001');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` varchar(99) NOT NULL,
  `first_name` varchar(90) NOT NULL,
  `last_name` varchar(96) NOT NULL,
  `role` varchar(99) NOT NULL,
  `phone` bigint(98) NOT NULL,
  `designation` varchar(99) NOT NULL,
  `department` varchar(99) NOT NULL,
  `site_id` varchar(97) NOT NULL,
  `status` varchar(99) NOT NULL,
  `last_updated_by` varchar(98) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `username` varchar(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `first_name`, `last_name`, `role`, `phone`, `designation`, `department`, `site_id`, `status`, `last_updated_by`, `last_updated_on`, `username`) VALUES
('UM1001', 'smarttories', 'madhan', 'Smart Admin', 987654321, 'Admin', 'Admin', 'smartories', '1', 'UM1001', '2022-11-22 12:22:59', 'admin@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `user_access_control`
--

CREATE TABLE `user_access_control` (
  `user_id` varchar(99) NOT NULL,
  `site_id` varchar(90) NOT NULL,
  `oee_financial_drill_down` int(99) NOT NULL,
  `opportunity_insights` int(90) NOT NULL,
  `oee_drill_down` int(98) NOT NULL,
  `operator_user_interface` int(99) NOT NULL,
  `production_data_management` int(99) NOT NULL,
  `settings_machine` int(97) NOT NULL,
  `settings_part` int(99) NOT NULL,
  `settings_general` int(98) NOT NULL,
  `settings_user_management` int(80) NOT NULL,
  `last_updated_by` varchar(98) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user_access_control`
--

INSERT INTO `user_access_control` (`user_id`, `site_id`, `oee_financial_drill_down`, `opportunity_insights`, `oee_drill_down`, `operator_user_interface`, `production_data_management`, `settings_machine`, `settings_part`, `settings_general`, `settings_user_management`, `last_updated_by`, `last_updated_on`) VALUES
('UM1001', 'smartories', 3, 3, 3, 3, 3, 3, 3, 3, 3, 'UM1001', '2022-11-22 12:22:27');

-- --------------------------------------------------------

--
-- Table structure for table `user_credintials`
--

CREATE TABLE `user_credintials` (
  `rno` int(90) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `password` varchar(100) NOT NULL,
  `created_by` varchar(20) NOT NULL,
  `last_updated_by` varchar(20) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_on` varchar(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user_credintials`
--

INSERT INTO `user_credintials` (`rno`, `user_id`, `password`, `created_by`, `last_updated_by`, `last_updated_on`, `created_on`) VALUES
(1, 'UM1001', '$2y$10$bgUGvggNv5h7vhfXWEUa5.9GDUaRH0NMvMzjqucBYp5mTFLxxw70a', 'Manual', 'UM1001', '2022-11-22 12:22:44', '2022-06-14 15:02:40');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`dept_id`);

--
-- Indexes for table `location`
--
ALTER TABLE `location`
  ADD UNIQUE KEY `location_id` (`location_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`sno`);

--
-- Indexes for table `sites`
--
ALTER TABLE `sites`
  ADD PRIMARY KEY (`sno`),
  ADD UNIQUE KEY `site_id` (`site_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `user_access_control`
--
ALTER TABLE `user_access_control`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `user_credintials`
--
ALTER TABLE `user_credintials`
  ADD PRIMARY KEY (`rno`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `dept_id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `sites`
--
ALTER TABLE `sites`
  MODIFY `sno` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `user_credintials`
--
ALTER TABLE `user_credintials`
  MODIFY `rno` int(90) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
