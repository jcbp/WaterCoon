
DELIMITER $$

-- TABLE field

DROP PROCEDURE IF EXISTS get_field $$

CREATE PROCEDURE get_field()
BEGIN
      SELECT * FROM field
      ORDER BY field_id;
END $$


DROP PROCEDURE IF EXISTS insert_field $$

CREATE PROCEDURE insert_field(IN field_id int(11), IN list_id int(11), IN field_type_id int(3), IN order_index int(3), IN `name` varchar(128), IN `values` varchar(256), IN style varchar(256), IN width int(3), IN default_value blob(65535), IN field_timestamp timestamp)
BEGIN
      IF field_id<=0 OR ISNULL(field_id) THEN
            INSERT INTO field (`list_id`, `field_type_id`, `order_index`, `name`, `values`, `style`, `width`, `default_value`, `field_timestamp`)
            VALUES (`list_id`, `field_type_id`, `order_index`, `name`, `values`, `style`, `width`, `default_value`, `field_timestamp`);
      END IF;
END $$

            
-- TABLE field_history

DROP PROCEDURE IF EXISTS get_field_history $$

CREATE PROCEDURE get_field_history()
BEGIN
      SELECT * FROM field_history
      ORDER BY field_history_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_field_history $$

CREATE PROCEDURE insert_field_history(IN field_history_id int(11), IN username varchar(40), IN operation varchar(3), IN value blob(65535), IN field_history_timestamp timestamp)
BEGIN
      IF field_history_id<=0 OR ISNULL(field_history_id) THEN
            INSERT INTO field_history (`username`, `operation`, `value`, `field_history_timestamp`)
            VALUES (`username`, `operation`, `value`, `field_history_timestamp`);
      END IF;
END $$

            
-- TABLE field_type

DROP PROCEDURE IF EXISTS get_field_type $$

CREATE PROCEDURE get_field_type()
BEGIN
      SELECT * FROM field_type
      ORDER BY field_type_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_field_type $$

CREATE PROCEDURE insert_field_type(IN field_type_id int(3), IN name varchar(24), IN description varchar(256), IN default_width int(3))
BEGIN
      IF field_type_id<=0 OR ISNULL(field_type_id) THEN
            INSERT INTO field_type (`name`, `description`, `default_width`)
            VALUES (`name`, `description`, `default_width`);
      END IF;
END $$

            
-- TABLE field_value

DROP PROCEDURE IF EXISTS get_field_value $$

CREATE PROCEDURE get_field_value()
BEGIN
      SELECT * FROM field_value
      ORDER BY field_value_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_field_value $$

CREATE PROCEDURE insert_field_value(IN field_value_id int(11), IN list_id int(11), IN field_id int(11), IN user_id int(11), IN value blob(65535), IN issue_id int(11))
BEGIN
      IF field_value_id<=0 OR ISNULL(field_value_id) THEN
            INSERT INTO field_value (`list_id`, `field_id`, `user_id`, `value`, `issue_id`)
            VALUES (`list_id`, `field_id`, `user_id`, `value`, `issue_id`);
      END IF;
END $$

            
-- TABLE issue

DROP PROCEDURE IF EXISTS get_issue $$

CREATE PROCEDURE get_issue()
BEGIN
      SELECT * FROM issue
      ORDER BY issue_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_issue $$

CREATE PROCEDURE insert_issue(IN issue_id int(11), IN list_id int(11), IN order_index int(8))
BEGIN
      IF issue_id<=0 OR ISNULL(issue_id) THEN
            INSERT INTO issue (`list_id`, `order_index`)
            VALUES (`list_id`, `order_index`);
      END IF;
END $$

            
-- TABLE list

DROP PROCEDURE IF EXISTS get_list $$

CREATE PROCEDURE get_list()
BEGIN
      SELECT * FROM list
      ORDER BY list_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_list $$

CREATE PROCEDURE insert_list(IN list_id int(11), IN project_id int(11), IN name varchar(128), IN list_timestamp timestamp, IN description varchar(512), IN is_template int(1))
BEGIN
      IF list_id<=0 OR ISNULL(list_id) THEN
            INSERT INTO list (`project_id`, `name`, `list_timestamp`, `description`, `is_template`)
            VALUES (`project_id`, `name`, `list_timestamp`, `description`, `is_template`);
      END IF;
END $$

            
-- TABLE list_history

DROP PROCEDURE IF EXISTS get_list_history $$

CREATE PROCEDURE get_list_history()
BEGIN
      SELECT * FROM list_history
      ORDER BY list_history_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_list_history $$

CREATE PROCEDURE insert_list_history(IN list_history_id int(11), IN username varchar(40), IN operation varchar(3), IN list_history_timestamp timestamp)
BEGIN
      IF list_history_id<=0 OR ISNULL(list_history_id) THEN
            INSERT INTO list_history (`username`, `operation`, `list_history_timestamp`)
            VALUES (`username`, `operation`, `list_history_timestamp`);
      END IF;
END $$

            
-- TABLE permission_type

DROP PROCEDURE IF EXISTS get_permission_type $$

CREATE PROCEDURE get_permission_type()
BEGIN
      SELECT * FROM permission_type
      ORDER BY permission_type_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_permission_type $$

CREATE PROCEDURE insert_permission_type(IN permission_type_id int(3), IN name varchar(32))
BEGIN
      IF permission_type_id<=0 OR ISNULL(permission_type_id) THEN
            INSERT INTO permission_type (`name`)
            VALUES (`name`);
      END IF;
END $$

            
-- TABLE project

DROP PROCEDURE IF EXISTS get_project $$

CREATE PROCEDURE get_project()
BEGIN
      SELECT * FROM project
      ORDER BY project_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_project $$

CREATE PROCEDURE insert_project(IN project_id int(11), IN name varchar(64), IN project_timestamp timestamp, IN description varchar(512))
BEGIN
      IF project_id<=0 OR ISNULL(project_id) THEN
            INSERT INTO project (`name`, `project_timestamp`, `description`)
            VALUES (`name`, `project_timestamp`, `description`);
      END IF;
END $$

            
-- TABLE project_history

DROP PROCEDURE IF EXISTS get_project_history $$

CREATE PROCEDURE get_project_history()
BEGIN
      SELECT * FROM project_history
      ORDER BY project_history_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_project_history $$

CREATE PROCEDURE insert_project_history(IN project_history_id int(11), IN username varchar(40), IN operation varchar(3), IN project_history_timestamp timestamp)
BEGIN
      IF project_history_id<=0 OR ISNULL(project_history_id) THEN
            INSERT INTO project_history (`username`, `operation`, `project_history_timestamp`)
            VALUES (`username`, `operation`, `project_history_timestamp`);
      END IF;
END $$

            
-- TABLE user

DROP PROCEDURE IF EXISTS get_user $$

CREATE PROCEDURE get_user()
BEGIN
      SELECT * FROM user
      ORDER BY user_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_user $$

CREATE PROCEDURE insert_user(IN user_id int(11), IN username varchar(40), IN password varchar(128), IN email varchar(256), IN hash varchar(128), IN user_timestamp timestamp)
BEGIN
      IF user_id<=0 OR ISNULL(user_id) THEN
            INSERT INTO user (`username`, `password`, `email`, `hash`, `user_timestamp`)
            VALUES (`username`, `password`, `email`, `hash`, `user_timestamp`);
      END IF;
END $$

            
-- TABLE user_list

DROP PROCEDURE IF EXISTS get_user_list $$

CREATE PROCEDURE get_user_list()
BEGIN
      SELECT * FROM user_list
      ORDER BY user_list_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_user_list $$

CREATE PROCEDURE insert_user_list(IN user_id int(11), IN list_id int(11), IN permission_type_id int(3))
BEGIN
      IF user_id<=0 OR ISNULL(user_id) THEN
            INSERT INTO user_list (`list_id`, `permission_type_id`)
            VALUES (`list_id`, `permission_type_id`);
      END IF;
END $$

            
-- TABLE user_project

DROP PROCEDURE IF EXISTS get_user_project $$

CREATE PROCEDURE get_user_project()
BEGIN
      SELECT * FROM user_project
      ORDER BY user_project_id;
END $$

            
DROP PROCEDURE IF EXISTS insert_user_project $$

CREATE PROCEDURE insert_user_project(IN user_id int(5), IN project_id int(11), IN permission_type_id int(5))
BEGIN
      IF user_id<=0 OR ISNULL(user_id) THEN
            INSERT INTO user_project (`project_id`, `permission_type_id`)
            VALUES (`project_id`, `permission_type_id`);
      END IF;
END $$
           

DELIMITER ;
