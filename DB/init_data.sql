
--
-- Base de datos: `domsurco_watercoon`
--

USE watercoon;

--
-- Borrado de datos
--

DELETE FROM `field`
WHERE field_id < 1000;

DELETE FROM `field_history`
WHERE field_history_id < 1000;

DELETE FROM `field_type`
WHERE field_type_id < 1000;

DELETE FROM `field_value`
WHERE field_value_id < 1000;

DELETE FROM `issue`
WHERE issue_id < 1000;

DELETE FROM `permission_type`
WHERE permission_type_id < 1000;

DELETE FROM `project`
WHERE project_id < 1000;

DELETE FROM `project_history`
WHERE project_history_id < 1000;

DELETE FROM `list`
WHERE list_id < 1000;

DELETE FROM `user_list`
WHERE list_id < 1000;

DELETE FROM `list_history`
WHERE list_history_id < 1000;

DELETE FROM `user`
WHERE user_id < 1000;

DELETE FROM `user_project`
WHERE user_id < 1000;

--
-- Inserción de datos
--

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Volcado de datos para la tabla `field_type`
--

INSERT INTO `field_type` (`field_type_id`, `name`, `description`, `default_width`) VALUES
(1, 'text', 'Caracteres y Números', 300),
(2, 'longText', 'Caracteres y Números (multi-línea)', 250),
(3, 'boolean', 'Verdadero o Falso', 80),
(4, 'date', 'Fecha', 100),
(5, 'user', 'Lista de Usuarios', 200),
(6, 'customList', 'Lista de Valores Personalizados', 250),
(7, 'percent', 'Valor en Porcentajes', 100);


--
-- Volcado de datos para la tabla `permission_type`
--

INSERT INTO `permission_type` (`permission_type_id`, `name`) VALUES
(1, 'Administrator'),
(2, 'Editor'),
(3, 'Watcher');


--
-- Reset AUTO_INCREMENT index
--

ALTER TABLE `field` AUTO_INCREMENT = 1;
ALTER TABLE `field_history` AUTO_INCREMENT = 1;
ALTER TABLE `field_type` AUTO_INCREMENT = 1;
ALTER TABLE `field_value` AUTO_INCREMENT = 1;
ALTER TABLE `issue` AUTO_INCREMENT = 1;
ALTER TABLE `permission_type` AUTO_INCREMENT = 1;
ALTER TABLE `project` AUTO_INCREMENT = 1;
ALTER TABLE `project_history` AUTO_INCREMENT = 1;
ALTER TABLE `list` AUTO_INCREMENT = 1;
ALTER TABLE `user_list` AUTO_INCREMENT = 1;
ALTER TABLE `list_history` AUTO_INCREMENT = 1;
ALTER TABLE `user` AUTO_INCREMENT = 1;
ALTER TABLE `user_project` AUTO_INCREMENT = 1;


/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
