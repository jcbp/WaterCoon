
USE watercoon;

DELIMITER $$

DROP PROCEDURE IF EXISTS `get_user_by_name` $$
-- Devuelve los datos de un usuario a partir de su nombre
CREATE PROCEDURE `watercoon`.`get_user_by_name` (IN name varchar(40))
BEGIN
    SELECT * FROM user
    WHERE LOWER(user.username) = LOWER(name);
END $$


DROP PROCEDURE IF EXISTS `get_field_by_sheet_id` $$
-- Devuelve las columnas (campos) de una hoja
CREATE PROCEDURE `watercoon`.`get_field_by_sheet_id` (IN sheet_id INT(11))
BEGIN
    SELECT field_id, f.order_index, ft.name 'field_type', f.name, `values`, COALESCE(f.width, ft.default_width) 'width', f.style, default_value, field_timestamp
    FROM field AS f
        INNER JOIN sheet AS s ON f.sheet_id = s.sheet_id
        INNER JOIN field_type ft ON ft.field_type_id = f.field_type_id
    WHERE f.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `get_field_value_by_sheet_id` $$
-- Devuelve los datos (field_value) de una hoja
CREATE PROCEDURE `watercoon`.`get_field_value_by_sheet_id` (IN sheet_id INT(11))
BEGIN
    SELECT field_value_id, field_id, i.order_index, user_id, value, fv.issue_id
    FROM field_value AS fv
        INNER JOIN sheet AS s ON fv.sheet_id = s.sheet_id
        INNER JOIN issue AS i ON fv.issue_id = i.issue_id
    WHERE fv.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `insert_issue_and_field_value` $$
-- Inserta un nuevo Issue, establece el valor para la celda del campo especificado (field_id) y
-- crea todos los registros para el Issue con el valor default (field.default_value) si lo tuviese
CREATE PROCEDURE `watercoon`.`insert_issue_and_field_value` (IN user_id INT(11), IN order_index TINYINT, IN field_id INT(11), IN user_id_as_value INT(11), IN value TEXT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tmp_default_value VARCHAR(256);
    DECLARE tmp_field_id INT(11);
    DECLARE issue_id INT(11);
    DECLARE permission_id SMALLINT;

    DECLARE sheet_id INT(11) DEFAULT (SELECT sheet_id
    FROM field AS f
    WHERE f.field_id = field_id);

    DECLARE field_cur CURSOR FOR SELECT f.field_id, f.default_value
    FROM field AS f
    WHERE f.sheet_id = sheet_id;

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

    SET permission_id = (SELECT permission_type_id
    FROM user_sheet AS us
    WHERE us.user_id = user_id AND us.sheet_id = sheet_id);

    -- Se requiere al menos permisos de Editor(2)
    IF permission_id <= 2 THEN
        INSERT INTO issue (sheet_id, order_index)
            VALUES (sheet_id, order_index);

        SET issue_id = (SELECT LAST_INSERT_ID());

        INSERT INTO field_value (sheet_id, field_id, value, issue_id)
            VALUES (sheet_id, field_id, value, issue_id);
        
        OPEN field_cur;

        REPEAT
            FETCH field_cur INTO tmp_field_id, tmp_default_value;
            IF NOT done AND field_id <> tmp_field_id THEN
                INSERT INTO field_value (sheet_id, field_id, value, issue_id)
                    VALUES (sheet_id, tmp_field_id, tmp_default_value, issue_id);
            END IF;
        UNTIL done END REPEAT;

        CLOSE field_cur;

        SELECT fv.field_value_id, fv.field_id, i.order_index, fv.user_id, fv.value, fv.issue_id
        FROM field_value AS fv
            INNER JOIN issue AS i ON i.issue_id = issue_id
        WHERE fv.issue_id = issue_id;
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You have not permission to perform this action';
    END IF;
END $$


DROP PROCEDURE IF EXISTS `update_field_value` $$
-- Actualiza el valor de una celda (field_value)
CREATE PROCEDURE `watercoon`.`update_field_value` (IN field_value_id INT(11), IN user_id INT(11), IN value TEXT)
BEGIN
    UPDATE field_value AS fv
    SET fv.user_id = user_id, fv.value = value
    WHERE fv.field_value_id = field_value_id;
END $$


DROP PROCEDURE IF EXISTS `get_project_by_user_id` $$
-- Devuelve los proyectos para un usuario dado
CREATE PROCEDURE `watercoon`.`get_project_by_user_id` (IN user_id INT(11))
BEGIN
    SELECT p.project_id, p.name, p.project_timestamp FROM project AS p
        INNER JOIN user_project AS up ON p.project_id = up.project_id
    WHERE up.user_id = user_id
    ORDER BY p.project_id ASC;
END $$


DROP PROCEDURE IF EXISTS `get_sheet_by_project_id` $$
-- Devuelve las hojas de un proyecto dado
CREATE PROCEDURE `watercoon`.`get_sheet_by_project_id` (IN project_id INT(11), IN user_id INT(11))
BEGIN
    SELECT * FROM sheet AS s
        INNER JOIN user_sheet AS us ON s.sheet_id = us.sheet_id
    WHERE s.project_id = project_id AND us.user_id = user_id
    ORDER BY s.sheet_id ASC;
END $$


DROP PROCEDURE IF EXISTS `insert_project_with_user` $$
-- Crea un nuevo proyecto y lo asocia con el usuario que lo crea, con el mayor de los privilegios (1)
CREATE PROCEDURE `watercoon`.`insert_project_with_user` (IN name VARCHAR(64), IN user_id INT(11))
BEGIN
    DECLARE project_id INT(11);

    INSERT INTO project (`name`, `project_timestamp`)
    VALUES (`name`, NULL);

    SET project_id = (SELECT LAST_INSERT_ID());

    INSERT INTO user_project (`user_id`, `project_id`, `permission_type_id`)
    VALUES (user_id, project_id, 1);
    
    SELECT * FROM project AS p
    WHERE p.project_id = project_id;
END $$


DROP PROCEDURE IF EXISTS `insert_sheet_with_user` $$
-- Crea una nueva hoja y la asocia con el usuario que la crea, con el mayor de los privilegios (1)
CREATE PROCEDURE `watercoon`.`insert_sheet_with_user` (IN project_id INT(11), IN name VARCHAR(64), IN user_id INT(11))
BEGIN
    DECLARE sheet_id INT(11);

    INSERT INTO sheet (`project_id`, `name`)
    VALUES (`project_id`, `name`);

    SET sheet_id = (SELECT LAST_INSERT_ID());

    -- Se agrega el usuario con permisos de Administrador (1)
    INSERT INTO user_sheet (`user_id`, `sheet_id`, `permission_type_id`)
    VALUES (user_id, sheet_id, 1);

    -- Se crean las columnas default
    INSERT INTO field (`sheet_id`, `field_type_id`, `order_index`, `name`) VALUES
    (sheet_id, 1, 1, 'Column 1'),
    (sheet_id, 1, 2, 'Column 2'),
    (sheet_id, 1, 3, 'Column 3');

    SELECT * FROM sheet AS s
    WHERE s.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `insert_field_with_order_index` $$
-- Inserta una columna o campo (field) en la posición especificada
-- *TODO*: AGREGAR VALIDACION DE PERMISOS
CREATE PROCEDURE `watercoon`.`insert_field_with_order_index` (IN sheet_id INT(11), IN field_type_id INT(11), IN order_index TINYINT, IN name VARCHAR(128), IN `values` VARCHAR(256), IN default_value VARCHAR(256))
BEGIN
    DECLARE last_field_id INT(11);

    UPDATE field AS f
    SET f.order_index = f.order_index + 1
    WHERE f.order_index >= order_index AND f.sheet_id = sheet_id;

    INSERT INTO field (`sheet_id`, `field_type_id`, `order_index`, `name`, `values`, `default_value`)
    VALUES (sheet_id, field_type_id, order_index, name, `values`, default_value);

    SET last_field_id = (SELECT LAST_INSERT_ID());
    
    SELECT field_id, f.order_index, ft.name 'field_type', f.name, `values` 'values', default_value, field_timestamp
    FROM field AS f
        INNER JOIN field_type ft ON ft.field_type_id = f.field_type_id
    WHERE f.field_id = last_field_id;
END $$


DROP PROCEDURE IF EXISTS `insert_user_sheet_by_user_email` $$
-- Asocia un usuario a una hoja a partir del email
-- Si el usuario no existe se lo registra con el email especificado
-- *TODO*: AGREGAR VALIDACION DE PERMISOS
CREATE PROCEDURE `watercoon`.`insert_user_sheet_by_user_email` (IN sheet_id INT(11), IN email VARCHAR(256), IN permission_type_id TINYINT)
BEGIN
    DECLARE var_user_id INT(11);
    DECLARE var_project_id INT(11);
    
    -- Se obtiene el user_id a partir del email
    SET var_user_id = (SELECT user_id
        FROM user AS u
        WHERE u.email = email
        LIMIT 1);

    -- Se obtiene el project_id a partir del sheet_id
    SET var_project_id = (SELECT project_id FROM sheet AS s
        WHERE s.sheet_id = sheet_id);

    -- Si el usuario no existe se lo registra solo con el email
    -- Cuando se dé de alta el usuario se utiliza este mismo id para conservar las asociaciones previas
    IF ISNULL(var_user_id) THEN
        INSERT INTO user (email)
        VALUES (email);
        SET var_user_id = LAST_INSERT_ID();
    END IF;

    -- Si la hoja ya tiene el usuario asociado
    IF EXISTS (SELECT * FROM user_sheet AS us
               WHERE us.user_id = var_user_id AND us.sheet_id = sheet_id) THEN
        -- Se actualizan los permisos del usuario sobre la hoja
        UPDATE user_sheet AS us
        SET us.permission_type_id = permission_type_id
        WHERE us.user_id = var_user_id AND us.sheet_id = sheet_id;
    ELSE
        -- Sino, se asocia el usuario a la hoja, con los permisos especificados
        INSERT IGNORE INTO user_sheet (user_id, sheet_id, permission_type_id)
        VALUES (var_user_id, sheet_id, permission_type_id);
    END IF;

    -- Si el usuario no esta asociado al proyecto al cual pertenece
    IF NOT EXISTS (SELECT * FROM user_project AS up
               WHERE up.user_id = var_user_id AND up.project_id = var_project_id) THEN
        -- Se asocia el usuario al proyecto con permiso de watcher(3)
        INSERT INTO user_project (user_id, project_id, permission_type_id)
        VALUES (var_user_id, var_project_id, 3);
    END IF;
END $$


DROP PROCEDURE IF EXISTS `get_user_by_sheet_id` $$
-- Retorna los usuarios asociados a una hoja dada
CREATE PROCEDURE `watercoon`.`get_user_by_sheet_id` (IN sheet_id INT(11))
BEGIN
    SELECT u.user_id, u.username, u.email, u.user_timestamp FROM user_sheet AS us
        INNER JOIN user AS u ON u.user_id = us.user_id
    WHERE us.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `get_sheet_permission` $$
-- Retorna el permiso que tiene un usuario para una hoja dada
CREATE PROCEDURE `watercoon`.`get_sheet_permission` (IN user_id INT(11), IN sheet_id INT(11))
BEGIN
    SELECT permission_type_id
    FROM user_sheet AS us
    WHERE us.user_id = user_id AND us.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `delete_field` $$
-- Elimina una columna y todos los datos asociados (field_value)
-- *TODO*: AGREGAR VALIDACION DE PERMISOS
CREATE PROCEDURE `watercoon`.`delete_field` (IN field_id INT(11))
BEGIN
    DELETE FROM field
    WHERE field.field_id = field_id;

    DELETE fv FROM field_value AS fv
    WHERE fv.field_id = field_id;
END $$


DROP PROCEDURE IF EXISTS `update_field_style` $$
-- Actualiza el estilo para el campo dado
CREATE PROCEDURE `watercoon`.`update_field_style` (IN field_id INT(11), IN style VARCHAR(256))
BEGIN
    UPDATE field AS f
    SET f.style = style
    WHERE f.field_id = field_id;
END $$


DROP PROCEDURE IF EXISTS `get_user_list` $$
-- Para un usuario dato, devuelve todos los usuarios con los que comparte alguna hoja
-- *TODO*: refactorizar este SP
CREATE PROCEDURE `watercoon`.`get_user_list` (IN user_id INT(11))
BEGIN
    SELECT DISTINCT u.user_id, u.username, u.email, u.user_timestamp FROM user_sheet AS us2
        INNER JOIN user AS u ON u.user_id = us2.user_id
    WHERE us2.sheet_id IN (SELECT sheet_id FROM user_sheet AS us
                           WHERE us.user_id = user_id);
END $$


DROP PROCEDURE IF EXISTS `insert_user` $$
-- Registra un nuevo usuario
CREATE PROCEDURE `watercoon`.`insert_user` (IN username VARCHAR(40), IN password VARCHAR(128), IN email VARCHAR(256))
BEGIN
    IF EXISTS(SELECT * FROM user WHERE user.username = username) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The user already exists';
    ELSE
        INSERT INTO user (username, password, email)
        VALUES (username, password, email)
            ON DUPLICATE KEY UPDATE user.username = username, user.password = password;
    END IF;
END $$


-- *TODO*: ARMAR STORED PARA TRAER USUARIOS POR sheet_id, PARA USAR EN LOS field_type DE USUARIOS (5)


-- DROP PROCEDURE IF EXISTS `insert_field_value_without_sheet_id` $$
-- 
-- CREATE PROCEDURE `watercoon`.`insert_field_value_without_sheet_id` (IN issue_id INT(11), IN field_id INT(11), IN user_id INT(11), IN value TEXT)
-- BEGIN
--     DECLARE sheet_id INT(11) DEFAULT (SELECT sheet_id
--     FROM issue AS i
--     WHERE i.issue_id = issue_id);
-- 
--     INSERT INTO field_value (`sheet_id`, `field_id`, `user_id`, `value`, `issue_id`)
--     VALUES (sheet_id, field_id, user_id, value, issue_id);
-- END $$


-- DROP PROCEDURE IF EXISTS `get_issue_field_value_by_sheet_id` $$
-- 
-- CREATE PROCEDURE `watercoon`.`get_issue_field_value_by_sheet_id` (IN sheet_id INT(11))
-- BEGIN
--     SELECT field_value_id, field_id, i.order_index, user_id, value, fv.issue_id
--     FROM field_value AS fv
--         INNER JOIN sheet AS s ON fv.sheet_id = s.sheet_id
--         INNER JOIN issue AS i ON fv.issue_id = i.issue_id
--     WHERE fv.sheet_id = sheet_id;
-- END $$

DELIMITER ;