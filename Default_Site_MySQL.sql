-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 22, 2022 at 01:18 PM
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
-- Database: `s1003`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `child_records_create` (IN `production_id` VARCHAR(90))   BEGIN
	
    #production info table value get variable declaration
    DECLARE machinename varchar(90);
    DECLARE cal_date varchar(99);
    DECLARE sh_date varchar(99);
    DECLARE sh_id char(90);
    DECLARE s_time varchar(90);
    DECLARE e_time varchar(90);
    DECLARE actual_scount int(90);
    
    DECLARE new_pid varchar(90);
    DECLARE tool_cid varchar(90);
    DECLARE part varchar(80);
    DECLARE t_id varchar(90);
    DECLARE loop_end int(90);
    DECLARE part_pc int(90);
    DECLARE production_count varchar(90);
    DECLARE pmn BIGINT(90);
    DECLARE production_check varchar(90);
    
    SELECT machine_id,calendar_date,shift_date,shift_id,start_time,	end_time,actual_shot_count,production INTO machinename,cal_date,sh_date,sh_id,s_time,e_time,actual_scount,production_check from pdm_production_info WHERE production_event_id = production_id;    
    SELECT 	tool_changeover_id,no_of_part,count(tool_changeover_id),tool_id INTO tool_cid ,loop_end,pmn,t_id  FROM pdm_tool_changeover WHERE machine_id = machinename ORDER BY last_updated_on DESC LIMIT 1;
    
    #SELECT machinename;
    #SELECT tool_cid;
    #SELECT loop_end;
    IF pmn > 0 THEN
	    FOR i IN 1..loop_end
    	DO
    		#tool change over one by one part selection
    		SELECT part_id INTO part FROM tool_changeover WHERE id = tool_cid AND part_order = i;
        
            #part based nic selection
            SELECT part_produced_cycle INTO part_pc FROM settings_part_current WHERE part_id = part;
       
           #SELECT actual_scount;
           #SELECT part_pc;
           # each parts based production count assigning
           SELECT actual_scount*part_pc INTO production_count;
        
    	IF i = 1 THEN
            IF production_check = NULL THEN
                UPDATE `pdm_production_info` SET `part_id`=part,`tool_id`=t_id,`hierarchy`='parent' WHERE production_event_id = production_id;
            ELSE
                UPDATE `pdm_production_info` SET `part_id`=part,`tool_id`=t_id,`production`=production_count,`correction_min_counts`=CONCAT('-',production_count),`rejection_max_counts`=production_count,`hierarchy`='parent' WHERE production_event_id = production_id;
			END IF;
        	#updation query
    		#SELECT CONCAT('FIRST LOOP',part);
            #SELECT production_count;
        ELSEIF i > 1 THEN
        	SELECT id_generation() INTO new_pid;
        	#child record insertion
            IF production_check = NULL THEN
                INSERT INTO `pdm_production_info`(`production_event_id`,`machine_id`, `calendar_date`, `shift_date`, `shift_id`, `start_time`, `end_time`, `part_id`, `tool_id`, `actual_shot_count`,`hierarchy`) VALUES(CONCAT('PE',new_pid),machinename,cal_date,sh_date,sh_id,s_time,e_time,part,t_id,actual_scount,production_id); 
            ELSE
                INSERT INTO `pdm_production_info`(`production_event_id`,`machine_id`, `calendar_date`, `shift_date`, `shift_id`, `start_time`, `end_time`, `part_id`, `tool_id`, `actual_shot_count`, `production`, `correction_min_counts`, `rejection_max_counts`,`hierarchy`) VALUES(CONCAT('PE',new_pid),machinename,cal_date,sh_date,sh_id,s_time,e_time,part,t_id,actual_scount,production_count,CONCAT('-',production_count),production_count,production_id); 
            END IF;
        	#SELECT part;
            #SELECT production_count;
        END IF;
    END FOR;
    #SELECT  part_id  FROM tool_changeover WHERE id = tool_cid; 
    #SELECT tool_cid;
    #SELECT part;
	END IF;



END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `production_event_id_generation` () RETURNS VARCHAR(90) CHARSET utf8mb4  BEGIN
	DECLARE pid varchar(90);
    
	SELECT count(r_no) into pid FROM pdm_production_info ORDER BY last_updated_on DESC LIMIT 1;
    IF pid = 0 THEN
    	SET pid = pid+1001;
        RETURN pid;
    ELSE 
    	SET pid = pid+1001;
        RETURN pid;
    END IF;
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pdm_downtime_reason_mapping`
--

CREATE TABLE `pdm_downtime_reason_mapping` (
  `r_no` bigint(20) NOT NULL,
  `machine_event_id` varchar(45) NOT NULL,
  `machine_id` varchar(45) NOT NULL,
  `split_id` varchar(45) NOT NULL,
  `calendar_date` varchar(45) NOT NULL,
  `shift_date` varchar(45) NOT NULL,
  `Shift_id` varchar(45) NOT NULL,
  `start_time` varchar(45) NOT NULL,
  `end_time` varchar(45) NOT NULL,
  `downtime_reason_id` varchar(45) NOT NULL,
  `split_duration` float NOT NULL,
  `tool_id` varchar(45) NOT NULL,
  `part_id` varchar(45) NOT NULL,
  `notes` varchar(45) NOT NULL,
  `last_updated_by` varchar(90) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `pdm_events`
--

CREATE TABLE `pdm_events` (
  `r_no` int(11) NOT NULL,
  `machine_event_id` varchar(45) NOT NULL,
  `calendar_date` varchar(45) NOT NULL,
  `shift_date` varchar(45) NOT NULL,
  `machine_id` varchar(45) NOT NULL,
  `shift_id` varchar(45) NOT NULL,
  `tool_id` varchar(45) NOT NULL,
  `part_id` varchar(45) NOT NULL,
  `record_created_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `start_time` varchar(45) NOT NULL,
  `end_time` varchar(45) NOT NULL,
  `shot_count` bigint(45) NOT NULL,
  `event` varchar(45) NOT NULL,
  `duration` float NOT NULL,
  `reason_mapped` int(1) NOT NULL,
  `is_split` int(2) NOT NULL,
  `timestamp` datetime DEFAULT NULL,
  `source` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `pdm_events`
--
DELIMITER $$
CREATE TRIGGER `generate_event_id` BEFORE INSERT ON `pdm_events` FOR EACH ROW BEGIN
	DECLARE x INT;
    DECLARE k CHARACTER(100);
    DECLARE l CHARACTER(100);
 
    SELECT
      downtime_reason_id
    INTO
      x
    FROM
      settings_downtime_reasons
    WHERE
      downtime_category = 'Unplanned'
    AND 
      downtime_reason='Unnamed';
      
    SET NEW.machine_event_id = CONCAT("ME",(SELECT COUNT(machine_event_id) FROM pdm_events)+1000+1);
   	
    IF NEW.event != "Active" THEN
    	INSERT INTO pdm_downtime_reason_mapping(machine_event_id,machine_id,split_id,calendar_date,shift_date,Shift_id,start_time,end_time,downtime_reason_id,split_duration,tool_id,part_id,notes,last_updated_by)VALUES(NEW.machine_event_id,NEW.machine_id,0,NEW.calendar_date,NEW.shift_date,NEW.shift_id,NEW.start_time,NEW.end_time,x,NEW.duration,New.tool_id,New.part_id,"","");
    END IF;
    
    #Update ToolchangeOver
    SELECT 
    	tool_changeover_id,machine_event_id
    INTO
    	k,l
    FROM
    	pdm_tool_changeover
    WHERE
    	machine_id = NEW.machine_id
    ORDER BY
    	tool_changeover_id  ASC
    LIMIT 1;
    
    IF l is NULL THEN
    	UPDATE `pdm_tool_changeover` SET shift_date=NEW.shift_date,calendar_date=NEW.calendar_date,event_start_time=NEW.start_time,shift_id=NEW.shift_id,machine_event_id=NEW.machine_event_id WHERE tool_changeover_id=k;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pdm_production_info`
--

CREATE TABLE `pdm_production_info` (
  `r_no` bigint(20) NOT NULL,
  `production_event_id` varchar(45) NOT NULL,
  `machine_id` varchar(45) NOT NULL,
  `calendar_date` varchar(45) NOT NULL,
  `shift_date` varchar(45) NOT NULL,
  `shift_id` varchar(45) NOT NULL,
  `start_time` varchar(45) NOT NULL,
  `end_time` varchar(45) NOT NULL,
  `part_id` varchar(45) NOT NULL,
  `tool_id` varchar(45) NOT NULL,
  `actual_shot_count` bigint(99) NOT NULL,
  `production` varchar(98) DEFAULT NULL,
  `correction_min_counts` varchar(97) DEFAULT NULL,
  `corrections` varchar(98) DEFAULT NULL,
  `correction_notes` varchar(90) DEFAULT NULL,
  `rejection_max_counts` varchar(45) DEFAULT NULL,
  `rejections` varchar(45) DEFAULT NULL,
  `rejections_notes` varchar(100) DEFAULT NULL,
  `reject_reason` varchar(100) DEFAULT NULL,
  `last_updated_by` varchar(45) DEFAULT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `hierarchy` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `pdm_tool_changeover`
--

CREATE TABLE `pdm_tool_changeover` (
  `tool_changeover_id` varchar(90) NOT NULL,
  `machine_id` varchar(99) NOT NULL,
  `no_of_part` varchar(90) NOT NULL,
  `tool_id` varchar(90) NOT NULL,
  `shift_date` varchar(90) DEFAULT NULL,
  `calendar_date` varchar(90) DEFAULT NULL,
  `event_start_time` varchar(90) DEFAULT NULL,
  `shift_id` varchar(98) DEFAULT NULL,
  `machine_event_id` varchar(90) DEFAULT NULL,
  `last_updated_by` varchar(90) DEFAULT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `settings_current_shift_performance`
--

CREATE TABLE `settings_current_shift_performance` (
  `r_no` int(90) NOT NULL,
  `oee` int(99) NOT NULL,
  `green` int(99) NOT NULL,
  `yellow` int(99) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_updated_by` varchar(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_current_shift_performance`
--

INSERT INTO `settings_current_shift_performance` (`r_no`, `oee`, `green`, `yellow`, `last_updated_on`, `last_updated_by`) VALUES
(1, 99, 80, 65, '2022-11-22 09:58:36', 'UM1001');

-- --------------------------------------------------------

--
-- Table structure for table `settings_downtime_reasons`
--

CREATE TABLE `settings_downtime_reasons` (
  `downtime_reason_id` varchar(45) NOT NULL,
  `downtime_category` varchar(45) NOT NULL,
  `downtime_reason` varchar(45) NOT NULL,
  `image_id` varchar(6) NOT NULL,
  `is_default` int(5) NOT NULL,
  `status` int(1) NOT NULL,
  `last_updated_by` varchar(25) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_downtime_reasons`
--

INSERT INTO `settings_downtime_reasons` (`downtime_reason_id`, `downtime_category`, `downtime_reason`, `image_id`, `is_default`, `status`, `last_updated_by`, `last_updated_on`) VALUES
('0', 'Unplanned', 'Unnamed', '', 1, 1, 'UM1001', '2022-11-22 09:53:09'),
('1', 'Planned', 'Machine OFF', '', 1, 1, 'UM1001', '2022-11-22 09:53:45'),
('2', 'Planned', 'Tool Changeover', '', 1, 1, 'UM1001', '2022-11-22 09:54:13'),
('3', 'Unplanned', 'Tool Changeover', '', 1, 1, 'UM1001', '2022-11-22 09:54:34');

-- --------------------------------------------------------

--
-- Table structure for table `settings_downtime_reasons_images`
--

CREATE TABLE `settings_downtime_reasons_images` (
  `image_id` varchar(20) NOT NULL,
  `original_file_name` varchar(100) NOT NULL,
  `original_file_extension` varchar(45) NOT NULL,
  `original_file_size_kb` float NOT NULL,
  `uploaded_file_location` varchar(200) NOT NULL,
  `uploaded_file_name` varchar(100) NOT NULL,
  `uploaded_file_extension` varchar(45) NOT NULL,
  `status` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `settings_downtime_threshold`
--

CREATE TABLE `settings_downtime_threshold` (
  `downtime_threshold` bigint(90) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_updated_by` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_downtime_threshold`
--

INSERT INTO `settings_downtime_threshold` (`downtime_threshold`, `last_updated_on`, `last_updated_by`) VALUES
(60, '2022-11-22 09:59:33', 'UM1001');

-- --------------------------------------------------------

--
-- Table structure for table `settings_financial_metrics_goals`
--

CREATE TABLE `settings_financial_metrics_goals` (
  `overall_teep` float NOT NULL,
  `overall_ooe` float NOT NULL,
  `overall_oee` float NOT NULL,
  `availability` float NOT NULL,
  `performance` float NOT NULL,
  `quality` float NOT NULL,
  `oee_target` float NOT NULL,
  `last_updated_by` varchar(90) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_financial_metrics_goals`
--

INSERT INTO `settings_financial_metrics_goals` (`overall_teep`, `overall_ooe`, `overall_oee`, `availability`, `performance`, `quality`, `oee_target`, `last_updated_by`, `last_updated_on`) VALUES
(99, 99, 99, 99, 99, 99, 99, 'UM1001', '2022-11-22 09:59:15');

-- --------------------------------------------------------

--
-- Table structure for table `settings_machine_current`
--

CREATE TABLE `settings_machine_current` (
  `machine_id` varchar(45) NOT NULL,
  `machine_name` varchar(45) NOT NULL,
  `rate_per_hour` float NOT NULL,
  `machine_offrate_per_hour` float NOT NULL,
  `tonnage` int(10) NOT NULL,
  `machine_brand` varchar(45) NOT NULL,
  `machine_serial_number` varchar(45) NOT NULL,
  `status` int(1) NOT NULL,
  `last_updated_by` varchar(90) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `settings_machine_current`
--
DELIMITER $$
CREATE TRIGGER `default_toolchangeover` AFTER INSERT ON `settings_machine_current` FOR EACH ROW BEGIN
	DECLARE x CHARACTER(100);
    DECLARE y CHARACTER(100);
 
    SELECT
      tool_changeover_id
    INTO
      x
    FROM
      pdm_tool_changeover
    ORDER BY
    	tool_changeover_id DESC
    LIMIT 1;
    
    IF x IS NULL THEN
   		SET y = 1001;
    ELSE
    	SET y=x+1;
    END IF;
    	INSERT INTO pdm_tool_changeover(tool_changeover_id ,machine_id,no_of_part,tool_id,last_updated_by)VALUES(y,NEW.machine_id,1,"TL1001",NEW.last_updated_by);
        INSERT INTO tool_changeover(id,machine_id,part_id,part_order) VALUES(y,NEW.machine_id,"PT1001",1);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `settings_machine_iot`
--

CREATE TABLE `settings_machine_iot` (
  `machine_id` varchar(45) NOT NULL,
  `iot_gateway_topic` varchar(100) NOT NULL,
  `site_id` varchar(45) NOT NULL,
  `location_id` varchar(45) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_updated_by` varchar(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `settings_machine_log`
--

CREATE TABLE `settings_machine_log` (
  `machine_id` varchar(45) NOT NULL,
  `machine_name` varchar(45) NOT NULL,
  `rate_per_hour` int(10) NOT NULL,
  `machine_offrate_per_hour` int(10) NOT NULL,
  `tonnage` int(10) NOT NULL,
  `machine_brand` varchar(45) NOT NULL,
  `status` int(10) NOT NULL,
  `machine_serial_number` varchar(45) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_updated_by` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `settings_part_current`
--

CREATE TABLE `settings_part_current` (
  `part_id` varchar(45) NOT NULL,
  `part_name` varchar(45) NOT NULL,
  `NICT` int(10) NOT NULL,
  `part_produced_cycle` int(10) NOT NULL,
  `part_price` float NOT NULL,
  `part_weight` int(10) NOT NULL,
  `tool_id` varchar(45) NOT NULL,
  `material_price` float NOT NULL,
  `material_name` varchar(45) NOT NULL,
  `status` int(1) NOT NULL,
  `last_updated_by` varchar(90) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_part_current`
--

INSERT INTO `settings_part_current` (`part_id`, `part_name`, `NICT`, `part_produced_cycle`, `part_price`, `part_weight`, `tool_id`, `material_price`, `material_name`, `status`, `last_updated_by`, `last_updated_on`) VALUES
('PT1001', 'No Part', 0, 0, 0, 0, 'TL1001', 0, '', 0, 'UM1001', '2022-11-22 09:55:22');

-- --------------------------------------------------------

--
-- Table structure for table `settings_part_log`
--

CREATE TABLE `settings_part_log` (
  `part_id` varchar(45) NOT NULL,
  `part_name` varchar(45) NOT NULL,
  `NICT` int(10) NOT NULL,
  `part_produced_cycle` int(6) NOT NULL,
  `part_price` float NOT NULL,
  `part_weight` float NOT NULL,
  `tool_id` varchar(45) NOT NULL,
  `material_price` float NOT NULL,
  `material_name` varchar(45) NOT NULL,
  `status` varchar(1) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_updated_by` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_part_log`
--

INSERT INTO `settings_part_log` (`part_id`, `part_name`, `NICT`, `part_produced_cycle`, `part_price`, `part_weight`, `tool_id`, `material_price`, `material_name`, `status`, `last_updated_on`, `last_updated_by`) VALUES
('PT1001', 'No Part', 0, 0, 0, 0, 'TL1001', 0, '', '0', '2022-11-22 09:55:46', 'UM1001');

-- --------------------------------------------------------

--
-- Table structure for table `settings_quality_reasons`
--

CREATE TABLE `settings_quality_reasons` (
  `quality_reason_id` bigint(90) NOT NULL,
  `quality_reason_name` varchar(90) NOT NULL,
  `image_id` varchar(20) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_updated_by` varchar(25) NOT NULL,
  `status` int(99) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `settings_quality_reasons_images`
--

CREATE TABLE `settings_quality_reasons_images` (
  `image_id` varchar(45) NOT NULL,
  `original_file_name` varchar(100) NOT NULL,
  `original_file_extension` varchar(50) NOT NULL,
  `original_file_size_kb` float NOT NULL,
  `uploaded_file_location` varchar(200) NOT NULL,
  `uploaded_file_name` varchar(100) NOT NULL,
  `uploaded_file_extension` varchar(50) NOT NULL,
  `status` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `settings_shift_management`
--

CREATE TABLE `settings_shift_management` (
  `shift_log_id` varchar(6) NOT NULL,
  `start_time` varchar(45) NOT NULL,
  `duration` varchar(10) NOT NULL,
  `last_updated_by` varchar(45) NOT NULL,
  `last_updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_shift_management`
--

INSERT INTO `settings_shift_management` (`shift_log_id`, `start_time`, `duration`, `last_updated_by`, `last_updated_on`) VALUES
('sf01', '09:00:00', '12:00', 'UM1001', '2022-11-22 09:57:06');

-- --------------------------------------------------------

--
-- Table structure for table `settings_shift_table`
--

CREATE TABLE `settings_shift_table` (
  `shifts` varchar(10) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_shift_table`
--

INSERT INTO `settings_shift_table` (`shifts`, `start_time`, `end_time`) VALUES
('A01', '09:00:00', '21:00:00'),
('B01', '21:00:00', '09:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `settings_tool_table`
--

CREATE TABLE `settings_tool_table` (
  `tool_id` varchar(45) NOT NULL,
  `tool_name` varchar(45) NOT NULL,
  `tool_status` int(1) NOT NULL,
  `last_updated_by` varchar(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `settings_tool_table`
--

INSERT INTO `settings_tool_table` (`tool_id`, `tool_name`, `tool_status`, `last_updated_by`) VALUES
('TL1001', 'No Tool', 0, 'UM1001');

-- --------------------------------------------------------

--
-- Table structure for table `tool_changeover`
--

CREATE TABLE `tool_changeover` (
  `r_no` bigint(20) NOT NULL,
  `id` varchar(90) DEFAULT NULL,
  `machine_id` varchar(90) DEFAULT NULL,
  `part_id` varchar(90) DEFAULT NULL,
  `part_order` int(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pdm_downtime_reason_mapping`
--
ALTER TABLE `pdm_downtime_reason_mapping`
  ADD PRIMARY KEY (`r_no`);

--
-- Indexes for table `pdm_events`
--
ALTER TABLE `pdm_events`
  ADD PRIMARY KEY (`r_no`);

--
-- Indexes for table `pdm_production_info`
--
ALTER TABLE `pdm_production_info`
  ADD PRIMARY KEY (`r_no`),
  ADD UNIQUE KEY `production_event_id` (`production_event_id`);

--
-- Indexes for table `pdm_tool_changeover`
--
ALTER TABLE `pdm_tool_changeover`
  ADD PRIMARY KEY (`tool_changeover_id`);

--
-- Indexes for table `settings_current_shift_performance`
--
ALTER TABLE `settings_current_shift_performance`
  ADD PRIMARY KEY (`r_no`);

--
-- Indexes for table `settings_downtime_reasons`
--
ALTER TABLE `settings_downtime_reasons`
  ADD PRIMARY KEY (`downtime_reason_id`);

--
-- Indexes for table `settings_downtime_reasons_images`
--
ALTER TABLE `settings_downtime_reasons_images`
  ADD PRIMARY KEY (`image_id`);

--
-- Indexes for table `settings_machine_current`
--
ALTER TABLE `settings_machine_current`
  ADD PRIMARY KEY (`machine_id`),
  ADD UNIQUE KEY `machine_serial_number` (`machine_serial_number`);

--
-- Indexes for table `settings_machine_iot`
--
ALTER TABLE `settings_machine_iot`
  ADD PRIMARY KEY (`machine_id`);

--
-- Indexes for table `settings_part_current`
--
ALTER TABLE `settings_part_current`
  ADD UNIQUE KEY `part_id` (`part_id`);

--
-- Indexes for table `settings_quality_reasons`
--
ALTER TABLE `settings_quality_reasons`
  ADD PRIMARY KEY (`quality_reason_id`);

--
-- Indexes for table `settings_quality_reasons_images`
--
ALTER TABLE `settings_quality_reasons_images`
  ADD PRIMARY KEY (`image_id`);

--
-- Indexes for table `settings_tool_table`
--
ALTER TABLE `settings_tool_table`
  ADD PRIMARY KEY (`tool_id`);

--
-- Indexes for table `tool_changeover`
--
ALTER TABLE `tool_changeover`
  ADD PRIMARY KEY (`r_no`),
  ADD KEY `id` (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pdm_downtime_reason_mapping`
--
ALTER TABLE `pdm_downtime_reason_mapping`
  MODIFY `r_no` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pdm_events`
--
ALTER TABLE `pdm_events`
  MODIFY `r_no` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pdm_production_info`
--
ALTER TABLE `pdm_production_info`
  MODIFY `r_no` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `settings_current_shift_performance`
--
ALTER TABLE `settings_current_shift_performance`
  MODIFY `r_no` int(90) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `settings_quality_reasons`
--
ALTER TABLE `settings_quality_reasons`
  MODIFY `quality_reason_id` bigint(90) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tool_changeover`
--
ALTER TABLE `tool_changeover`
  MODIFY `r_no` bigint(20) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
