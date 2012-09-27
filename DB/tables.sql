SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- DROP SCHEMA IF EXISTS `watercoon` ;
-- CREATE SCHEMA IF NOT EXISTS `watercoon` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
-- USE `watercoon` ;

-- -----------------------------------------------------
-- Table `list_history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `list_history` ;

CREATE  TABLE IF NOT EXISTS `list_history` (
  `list_history_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(40) NOT NULL ,
  `operation` ENUM('DEL','INS','UPD') NOT NULL ,
  `list_history_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`list_history_id`) ,
  UNIQUE INDEX `sheet_history_id_UNIQUE` (`list_history_id` ASC) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `field_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `field_type` ;

CREATE  TABLE IF NOT EXISTS `field_type` (
  `field_type_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(24) CHARACTER SET 'latin1' COLLATE 'latin1_spanish_ci' NOT NULL ,
  `description` VARCHAR(256) CHARACTER SET 'latin1' COLLATE 'latin1_spanish_ci' NOT NULL ,
  `default_width` TINYINT UNSIGNED NOT NULL ,
  PRIMARY KEY (`field_type_id`) ,
  UNIQUE INDEX `data_type_id_UNIQUE` (`field_type_id` ASC) )
ENGINE = MyISAM
AUTO_INCREMENT = 8;


-- -----------------------------------------------------
-- Table `project`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `project` ;

CREATE  TABLE IF NOT EXISTS `project` (
  `project_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(64) CHARACTER SET 'latin1' NOT NULL ,
  `project_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `description` VARCHAR(512) NULL ,
  PRIMARY KEY (`project_id`) ,
  UNIQUE INDEX `project_id_UNIQUE` (`project_id` ASC) )
ENGINE = MyISAM
AUTO_INCREMENT = 2;


-- -----------------------------------------------------
-- Table `list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `list` ;

CREATE  TABLE IF NOT EXISTS `list` (
  `list_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `project_id` INT(11) UNSIGNED NOT NULL ,
  `name` VARCHAR(128) CHARACTER SET 'latin1' COLLATE 'latin1_spanish_ci' NOT NULL ,
  `list_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `description` VARCHAR(512) NULL ,
  `is_template` TINYINT(1) NULL ,
  PRIMARY KEY (`list_id`) ,
  UNIQUE INDEX `sheet_id_UNIQUE` (`list_id` ASC) ,
  INDEX `project_id_idx` (`project_id` ASC) )
ENGINE = MyISAM
AUTO_INCREMENT = 3;


-- -----------------------------------------------------
-- Table `user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `user` ;

CREATE  TABLE IF NOT EXISTS `user` (
  `user_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(40) CHARACTER SET 'latin1' NULL ,
  `password` VARCHAR(128) CHARACTER SET 'latin1' NULL ,
  `email` VARCHAR(256) CHARACTER SET 'latin1' NOT NULL ,
  `hash` VARCHAR(128) NULL DEFAULT NULL ,
  `user_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`user_id`) ,
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) ,
  UNIQUE INDEX `username_UNIQUE` (`username` ASC) ,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) )
ENGINE = MyISAM
AUTO_INCREMENT = 2;


-- -----------------------------------------------------
-- Table `field`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `field` ;

CREATE  TABLE IF NOT EXISTS `field` (
  `field_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `list_id` INT(11) UNSIGNED NOT NULL ,
  `field_type_id` TINYINT UNSIGNED NOT NULL ,
  `order_index` TINYINT UNSIGNED NOT NULL ,
  `name` VARCHAR(128) CHARACTER SET 'latin1' COLLATE 'latin1_spanish_ci' NOT NULL ,
  `values` VARCHAR(256) CHARACTER SET 'latin1' COLLATE 'latin1_spanish_ci' NULL DEFAULT NULL COMMENT 'comma separated values' ,
  `style` VARCHAR(256) NULL ,
  `width` TINYINT UNSIGNED NULL ,
  `default_value` TEXT CHARACTER SET 'latin1' COLLATE 'latin1_spanish_ci' NULL DEFAULT NULL ,
  `field_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`field_id`) ,
  UNIQUE INDEX `field_id_UNIQUE` (`field_id` ASC) ,
  INDEX `list_id` (`list_id` ASC) ,
  INDEX `field_type_id` (`field_type_id` ASC) )
ENGINE = MyISAM
AUTO_INCREMENT = 6;


-- -----------------------------------------------------
-- Table `issue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `issue` ;

CREATE  TABLE IF NOT EXISTS `issue` (
  `issue_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `list_id` INT(11) UNSIGNED NOT NULL ,
  `order_index` MEDIUMINT UNSIGNED NOT NULL ,
  PRIMARY KEY (`issue_id`) ,
  UNIQUE INDEX `issue_id_UNIQUE` (`issue_id` ASC) ,
  INDEX `list_id` (`list_id` ASC) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `field_value`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `field_value` ;

CREATE  TABLE IF NOT EXISTS `field_value` (
  `field_value_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `list_id` INT(11) UNSIGNED NOT NULL ,
  `field_id` INT(11) UNSIGNED NOT NULL ,
  `user_id` INT(11) UNSIGNED NULL ,
  `value` TEXT NULL ,
  `issue_id` INT(11) UNSIGNED NOT NULL ,
  PRIMARY KEY (`field_value_id`) ,
  UNIQUE INDEX `field_value_id` (`field_value_id` ASC) ,
  INDEX `list_id` (`list_id` ASC) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `field_id` (`field_id` ASC) ,
  INDEX `issue_id` (`issue_id` ASC) )
ENGINE = MyISAM
AUTO_INCREMENT = 2;


-- -----------------------------------------------------
-- Table `permission_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `permission_type` ;

CREATE  TABLE IF NOT EXISTS `permission_type` (
  `permission_type_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(32) NOT NULL ,
  PRIMARY KEY (`permission_type_id`) ,
  UNIQUE INDEX `user_type_id_UNIQUE` (`permission_type_id` ASC) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `user_project`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `user_project` ;

CREATE  TABLE IF NOT EXISTS `user_project` (
  `user_id` SMALLINT UNSIGNED NOT NULL ,
  `project_id` INT(11) UNSIGNED NOT NULL ,
  `permission_type_id` SMALLINT UNSIGNED NOT NULL COMMENT 'values:owner,admin,watch' ,
  INDEX `user_id_idx` (`user_id` ASC) ,
  INDEX `project_id_idx` (`project_id` ASC) ,
  INDEX `permission_type_id_idx` (`permission_type_id` ASC) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `field_history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `field_history` ;

CREATE  TABLE IF NOT EXISTS `field_history` (
  `field_history_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(40) NOT NULL ,
  `operation` ENUM('DEL','INS','UPD') NOT NULL ,
  `value` TEXT NULL ,
  `field_history_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`field_history_id`) ,
  UNIQUE INDEX `field_history_id_UNIQUE` (`field_history_id` ASC) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `project_history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `project_history` ;

CREATE  TABLE IF NOT EXISTS `project_history` (
  `project_history_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(40) NOT NULL ,
  `operation` ENUM('DEL','INS','UPD') NOT NULL ,
  `project_history_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`project_history_id`) ,
  UNIQUE INDEX `sheet_history_id_UNIQUE` (`project_history_id` ASC) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `user_list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `user_list` ;

CREATE  TABLE IF NOT EXISTS `user_list` (
  `user_id` INT(11) UNSIGNED NOT NULL ,
  `list_id` INT(11) UNSIGNED NOT NULL ,
  `permission_type_id` TINYINT UNSIGNED NOT NULL ,
  INDEX `fk_user_list_user` (`user_id` ASC) ,
  INDEX `fk_user_list_sheet` (`list_id` ASC) ,
  INDEX `fk_user_list_permission_type` (`permission_type_id` ASC) )
ENGINE = MyISAM;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
