
DELIMITER $$

DROP PROCEDURE IF EXISTS `get_user_by_name` $$

CREATE PROCEDURE `planwriter`.`get_user_by_name` (IN name varchar(40))
BEGIN
    SELECT * FROM user
    WHERE LOWER(user.username) = LOWER(name);
END $$


DROP PROCEDURE IF EXISTS `get_field_by_sheet_id` $$

CREATE PROCEDURE `planwriter`.`get_field_by_sheet_id` (IN sheet_id INT(11))
BEGIN
    SELECT field_id, f.order_index, ft.name 'field_type', f.name, `values`, default_value, field_timestamp
    FROM field AS f
        INNER JOIN sheet AS s ON f.sheet_id = s.sheet_id
        INNER JOIN field_type ft ON ft.field_type_id = f.field_type_id
    WHERE f.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `get_field_value_by_sheet_id` $$

CREATE PROCEDURE `planwriter`.`get_field_value_by_sheet_id` (IN sheet_id INT(11))
BEGIN
    SELECT field_value_id, field_id, i.order_index, user_id, value, fv.issue_id
    FROM field_value AS fv
        INNER JOIN sheet AS s ON fv.sheet_id = s.sheet_id
        INNER JOIN issue AS i ON fv.issue_id = i.issue_id
    WHERE fv.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `insert_issue_and_field_value` $$

CREATE PROCEDURE `planwriter`.`insert_issue_and_field_value` (IN order_index TINYINT, IN field_id INT(11), IN user_id INT(11), IN value TEXT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tmp_default_value VARCHAR(256);
    DECLARE tmp_field_id INT(11);
    DECLARE issue_id INT(11);

    DECLARE sheet_id INT(11) DEFAULT (SELECT sheet_id
    FROM field AS f
    WHERE f.field_id = field_id);

    DECLARE field_cur CURSOR FOR SELECT f.field_id, f.default_value
    FROM field AS f
    WHERE f.sheet_id = sheet_id;

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

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
END $$


DROP PROCEDURE IF EXISTS `update_field_value` $$

CREATE PROCEDURE `planwriter`.`update_field_value` (IN field_value_id INT(11), IN user_id INT(11), IN value TEXT)
BEGIN
    UPDATE field_value AS fv
    SET fv.user_id = user_id, fv.value = value
    WHERE fv.field_value_id = field_value_id;
END $$


DROP PROCEDURE IF EXISTS `get_project_by_user_id` $$

CREATE PROCEDURE `planwriter`.`get_project_by_user_id` (IN user_id INT(11))
BEGIN
    SELECT p.project_id, p.name, p.project_timestamp FROM project AS p
        INNER JOIN user_project AS up ON p.project_id = up.project_id
    WHERE up.user_id = user_id
    ORDER BY p.project_id ASC;
END $$


DROP PROCEDURE IF EXISTS `get_sheet_by_project_id` $$

CREATE PROCEDURE `planwriter`.`get_sheet_by_project_id` (IN project_id INT(11), IN user_id INT(11))
BEGIN
    SELECT * FROM sheet AS s
        INNER JOIN user_sheet AS us ON s.sheet_id = us.sheet_id
    WHERE s.project_id = project_id AND us.user_id = user_id
    ORDER BY s.sheet_id ASC;
END $$


DROP PROCEDURE IF EXISTS `insert_project_with_user` $$

CREATE PROCEDURE `planwriter`.`insert_project_with_user` (IN name VARCHAR(64), IN user_id INT(11))
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

CREATE PROCEDURE `planwriter`.`insert_sheet_with_user` (IN project_id INT(11), IN name VARCHAR(64), IN user_id INT(11))
BEGIN
    DECLARE sheet_id INT(11);

    INSERT INTO sheet (`project_id`, `name`)
    VALUES (`project_id`, `name`);

    SET sheet_id = (SELECT LAST_INSERT_ID());

    INSERT INTO user_sheet (`user_id`, `sheet_id`, `permission_type_id`)
    VALUES (user_id, sheet_id, 1);

    SELECT * FROM sheet AS s
    WHERE s.sheet_id = sheet_id;
END $$


DROP PROCEDURE IF EXISTS `insert_field_with_order_index` $$

CREATE PROCEDURE `planwriter`.`insert_field_with_order_index` (IN sheet_id INT(11), IN field_type_id INT(11), IN order_index TINYINT, IN name VARCHAR(128), IN `values` VARCHAR(256), IN default_value VARCHAR(256))
BEGIN
    DECLARE last_field_id INT(11);

    UPDATE field AS f
    SET f.order_index = f.order_index + 1
    WHERE f.order_index >= order_index AND f.sheet_id = sheet_id;

    INSERT INTO field (`sheet_id`, `field_type_id`, `order_index`, `name`, `values`, `default_value`)
    VALUES (sheet_id, field_type_id, order_index, name, `values`, default_value);

    SET last_field_id = (SELECT LAST_INSERT_ID());
    
    SELECT field_id, f.order_index, ft.name 'field_type', f.name, `values`, default_value, field_timestamp
    FROM field AS f
        INNER JOIN field_type ft ON ft.field_type_id = f.field_type_id
    WHERE f.field_id = last_field_id;
END $$



-- DROP PROCEDURE IF EXISTS `insert_field_value_without_sheet_id` $$
-- 
-- CREATE PROCEDURE `planwriter`.`insert_field_value_without_sheet_id` (IN issue_id INT(11), IN field_id INT(11), IN user_id INT(11), IN value TEXT)
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
-- CREATE PROCEDURE `planwriter`.`get_issue_field_value_by_sheet_id` (IN sheet_id INT(11))
-- BEGIN
--     SELECT field_value_id, field_id, i.order_index, user_id, value, fv.issue_id
--     FROM field_value AS fv
--         INNER JOIN sheet AS s ON fv.sheet_id = s.sheet_id
--         INNER JOIN issue AS i ON fv.issue_id = i.issue_id
--     WHERE fv.sheet_id = sheet_id;
-- END $$

DELIMITER ;