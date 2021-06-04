# Consulta SQL para buscar todos os dados das tabelas #_users do Joomla para a busca de SQL-injection

DELIMITER //
 
CREATE PROCEDURE `proc_INVADER` ()
BEGIN
    DECLARE done INT;
    DECLARE v_schema, v_table VARCHAR(64);

    DECLARE cur1 CURSOR FOR (
	  	SELECT 
		    DISTINCT TABLE_SCHEMA, TABLE_NAME
		FROM
		    information_schema.COLUMNS
		WHERE
		    1 = 1
	        AND TABLE_SCHEMA LIKE 'internet_%'
	        AND TABLE_NAME LIKE '%_users' 
	        AND TABLE_NAME NOT LIKE '%logs_users'
	        AND TABLE_NAME NOT LIKE '%fb_users'
	        AND TABLE_NAME NOT LIKE '%gallery_users'
	        AND TABLE_NAME NOT LIKE '%_system_users'
	        AND TABLE_NAME NOT LIKE '%_jev_users'
	        AND COLUMN_NAME LIKE 'name'
   	);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cur1;
 
    SET done = 0;
    SET @sql = '';
    
    WHILE done = 0 DO
        FETCH cur1 INTO v_schema, v_table;
        IF done = 0 THEN        
	        IF @sql <> '' THEN
	        	SET @sql = CONCAT(@sql, ' UNION (SELECT \'', v_schema, '\' as ESCHEMA, name, username, email, block FROM ', v_schema,'.' , v_table,')');
	       	ELSE
	       		SET @sql = CONCAT(@sql, '(SELECT \'', v_schema, '\' as ESCHEMA, name, username, email, block FROM ', v_schema,'.' , v_table,')');
	       	END IF;       
    	END IF;  
    END WHILE;

    PREPARE stmt from @sql;
    EXECUTE stmt ;
   	-- select @sql as log;
   	
    CLOSE cur1;
END //


#Como executar esta procedure
call proc_INVADER();

#Para remover a procedure
DROP PROCEDURE IF EXISTS proc_INVADER;
