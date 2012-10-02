
--
-- Base de datos: `domsurco_watercoon`
--

-- USE domsurco_watercoon;


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
-- Volcado de datos para la tabla `issue`
--

INSERT INTO `issue` (`issue_id`, `order_index`) VALUES
(1, 1),
(2, 2);

--
-- Volcado de datos para la tabla `issue_list`
--

INSERT INTO `issue_list` (`issue_id`, `list_id`) VALUES
(1, 1),
(2, 1);

--
-- Volcado de datos para la tabla `field`
--

INSERT INTO `field` (`field_id`, `list_id`, `field_type_id`, `order_index`, `name`, `values`, `style`, `default_value`, `field_timestamp`) VALUES
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

INSERT INTO `field_value` (`field_value_id`, `list_id`, `field_id`, `user_id`, `value`, `issue_id`) VALUES
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
-- Volcado de datos para la tabla `tag`
--

INSERT INTO `tag` (`tag_id`, `name`, `tag_timestamp`) VALUES
(1, 'watercoon', NULL),
(2, 'watercoon Demos', NULL),
(3, 'watercoon2', NULL),
(4, 'test1', NULL),
(5, 'test2', NULL);

--
-- Volcado de datos para la tabla `list`
--

INSERT INTO `list` (`list_id`, `name`, `description`, `is_template`, `list_timestamp`) VALUES
(1, 'Task', 'Descripción para la lista de tareas', 0, NULL),
(2, 'Simple Todo', 'Descripción para la lista de Demos: Simple Todo', 0, NULL),
(3, 'Complex Todo', 'Descripción para la lista de Demos: Complex Todo', 0, NULL);

--
-- Volcado de datos para la tabla `tag_user_list`
--

INSERT INTO `tag_user_list` (`tag_id`, `user_id`, `list_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(2, 1, 3),
(3, 1, 1),
(3, 2, 1),
(5, 4, 1),
(5, 6, 1);

--
-- Volcado de datos para la tabla `user_list`
--

INSERT INTO `user_list` (`user_id`, `list_id`, `permission_type_id`) VALUES
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


/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
