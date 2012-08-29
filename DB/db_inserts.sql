

USE watercoon;


-- Borrado de datos

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

DELETE FROM `sheet`
WHERE sheet_id < 1000;

DELETE FROM `user_sheet`
WHERE sheet_id < 1000;

DELETE FROM `sheet_history`
WHERE sheet_history_id < 1000;

DELETE FROM `user`
WHERE user_id < 1000;

DELETE FROM `user_project`
WHERE user_id < 1000;


-- Inserción de datos

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `watercoon`
--

--
-- Volcado de datos para la tabla `field_type`
--

INSERT INTO `field_type` (`field_type_id`, `name`, `description`, `default_width`) VALUES
(1, 'text', 'Caracteres y Números', 300),
(2, 'longText', 'Caracteres y Números (multi-línea)', 250),
(3, 'boolean', 'Verdadero o Falso', 60),
(4, 'date', 'Fecha', 100),
(5, 'user', 'Lista de Usuarios', 200),
(6, 'customList', 'Lista de Valores Personalizados', 250),
(7, 'percent', 'Valor en Porcentajes', 100);

--
-- Volcado de datos para la tabla `issue`
--

INSERT INTO `issue` (`issue_id`, `sheet_id`, `order_index`) VALUES
(1, 1, 1),
(2, 1, 2);

--
-- Volcado de datos para la tabla `field`
--

INSERT INTO `field` (`field_id`, `sheet_id`, `field_type_id`, `order_index`, `name`, `values`, `style`, `default_value`, `field_timestamp`) VALUES
(1, 1, 1, 1, 'Title', NULL, NULL, NULL, NULL),
(2, 1, 6, 2, 'Priority', 'Low,Normal,High', 'font-weight: bold;', 'Normal', NULL),
(3, 1, 6, 3, 'Status', 'To Do,In Progress,On Hold,Done,Verified', 'text-decoration: underline;', 'To Do', NULL),
(4, 1, 2, 4, 'Description', NULL, 'font-style: italic;', NULL, NULL),
(5, 1, 5, 5, 'Asignee', NULL, NULL, NULL, NULL),
(6, 2, 3, 1, 'Done', NULL, NULL, NULL, NULL),
(7, 2, 1, 2, 'Todo', 'Item 1,Item 2, Item 3', NULL, 'Item 1', NULL),
(8, 2, 2, 3, 'Notes', NULL, NULL, NULL, NULL),
(9, 3, 7, 2, '% Complete', NULL, NULL, NULL, NULL),
(10, 3, 1, 1, 'Title', NULL, NULL, NULL, NULL),
(11, 3, 6, 3, 'Status', 'To Do,In Progress,On Hold,Done,Verified', NULL, 'To Do', NULL),
(12, 3, 6, 4, 'Priority', 'Low,Normal,High', NULL, 'Normal', NULL),
(13, 3, 2, 5, 'Description', NULL, NULL, NULL, NULL),
(14, 3, 4, 6, 'Due Date', NULL, NULL, NULL, NULL);

--
-- Volcado de datos para la tabla `field_value`
--

INSERT INTO `field_value` (`field_value_id`, `sheet_id`, `field_id`, `user_id`, `value`, `issue_id`) VALUES
(1, 1, 1, NULL, 'Tarea de prueba', 1),
(2, 1, 2, NULL, 'Low', 1),
(3, 1, 3, NULL, 'To Do', 1),
(4, 1, 4, NULL, 'Esto es una descripción de prueba', 1),
(5, 1, 5, 1, NULL, 1),
(6, 1, 1, NULL, 'Otra tarea', 2),
(7, 1, 2, NULL, 'Normal', 2),
(8, 1, 3, NULL, 'Done', 2),
(9, 1, 4, NULL, 'Esta es otra tarea de *prueba*, esto es un texto largo y ocupa el campo _Description_.', 2),
(10, 1, 5, 1, NULL, 2);

--
-- Volcado de datos para la tabla `project`
--

INSERT INTO `project` (`project_id`, `name`, `project_timestamp`) VALUES
(1, 'WaterCoon', NULL),
(2, 'WaterCoon Demos', NULL);

--
-- Volcado de datos para la tabla `sheet`
--

INSERT INTO `sheet` (`sheet_id`, `project_id`, `name`, `sheet_timestamp`) VALUES
(1, 1, 'Task', NULL),
(2, 2, 'Simple Todo', NULL),
(3, 2, 'Complex Todo', NULL);

--
-- Volcado de datos para la tabla `sheet`
--

INSERT INTO `user_sheet` (`user_id`, `sheet_id`, `permission_type_id`) VALUES
(1, 1, 1),
(1, 2, 1),
(1, 3, 1),
(2, 1, 1),
(4, 1, 1),
(6, 1, 1);

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`user_id`, `username`, `password`, `email`, `hash`, `user_timestamp`) VALUES
(1, 'pepe', '$1$o0psTp.x$gLqbQkvh1vLa4cO5iNZzh0', 'pepe@mail.com', NULL, NULL),
(2, 'pedro', '$1$pQ9QIbN5$ti52KDsQdyCmw9EQJVa151', 'pedro@mail.com', NULL, NULL),
(3, NULL, NULL, 'pipo@mail.com', NULL, NULL),
(4, NULL, NULL, 'marta@mail.com', NULL, NULL),
(5, NULL, NULL, 'mirta@mail.com', NULL, NULL),
(6, 'coco', '$1$Fqucq4fO$abIu3/kAfFQ7Cz.WyV4Ht0', 'coco@mail.com', NULL, NULL);

--
-- Volcado de datos para la tabla `user_project`
--

INSERT INTO `user_project` (`user_id`, `project_id`, `permission_type_id`) VALUES
(1, 1, 1),
(1, 2, 1),
(2, 1, 1),
(4, 1, 1),
(6, 1, 1);

--
-- Volcado de datos para la tabla `permission_type`
--

INSERT INTO `permission_type` (`permission_type_id`, `name`) VALUES
(1, 'Administrator'),
(2, 'Editor'),
(3, 'Watcher');


-- Reset AUTO_INCREMENT index

ALTER TABLE `field` AUTO_INCREMENT = 1;
ALTER TABLE `field_history` AUTO_INCREMENT = 1;
ALTER TABLE `field_type` AUTO_INCREMENT = 1;
ALTER TABLE `field_value` AUTO_INCREMENT = 1;
ALTER TABLE `issue` AUTO_INCREMENT = 1;
ALTER TABLE `permission_type` AUTO_INCREMENT = 1;
ALTER TABLE `project` AUTO_INCREMENT = 1;
ALTER TABLE `project_history` AUTO_INCREMENT = 1;
ALTER TABLE `sheet` AUTO_INCREMENT = 1;
ALTER TABLE `user_sheet` AUTO_INCREMENT = 1;
ALTER TABLE `sheet_history` AUTO_INCREMENT = 1;
ALTER TABLE `user` AUTO_INCREMENT = 1;
ALTER TABLE `user_project` AUTO_INCREMENT = 1;


/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
