-- CREACION BASE DE DATOS EN PHP MY ADMIN 

CREATE USER 'integrador_2023'@'localhost' IDENTIFIED VIA mysql_native_password USING '***';GRANT ALL PRIVILEGES ON *.* TO 'integrador_2023'@'localhost' 
REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
CREATE DATABASE IF NOT EXISTS `integrador_2023`;GRANT ALL PRIVILEGES ON `integrador\_2023`.* TO 'integrador_2023'@'localhost';
GRANT ALL PRIVILEGES ON `integrador\_2023\_%`.* TO 'integrador_2023'@'localhost';

-- CREACION DE FUNCION PARA LLENAR CALENDARIO Y CAPITAL LETTER

SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS `UC_Words`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `UC_Words`( str VARCHAR(255) ) RETURNS varchar(255) CHARSET utf8
BEGIN  
	DECLARE c CHAR(1);  
	DECLARE s VARCHAR(255);  
	DECLARE i INT DEFAULT 1;  
	DECLARE bool INT DEFAULT 1;  
	DECLARE punct CHAR(17) DEFAULT ' ()[]{},.-_!@;:?/';  
	SET s = LCASE( str );  
	WHILE i < LENGTH( str ) DO  
    	BEGIN  
        	SET c = SUBSTRING( s, i, 1 );  
            IF LOCATE( c, punct ) > 0 THEN  
        		SET bool = 1;  
      		ELSEIF bool=1 THEN  
        		BEGIN  
          			IF c >= 'a' AND c <= 'z' THEN  
             			BEGIN  
               				SET s = CONCAT(LEFT(s,i-1),UCASE(c),SUBSTRING(s,i+1));  
               				SET bool = 0;  
             			END;  
           			ELSEIF c >= '0' AND c <= '9' THEN  
            			SET bool = 0;  
          			END IF;  
       			END;  
      		END IF;  
      		SET i = i+1;  
    	END;  
  	END WHILE;  
  	RETURN s;  
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `Llenar_dimension_calendario`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Llenar_dimension_calendario`(IN `startdate` DATE, IN `stopdate` DATE)
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
    	INSERT INTO dim_calendario VALUES (
        	YEAR(currentdate)*10000+MONTH(currentdate)*100 + DAY(currentdate),
        	currentdate,
        	YEAR(currentdate),
        	MONTH(currentdate),
        	DAY(currentdate),
        	QUARTER(currentdate),
        	DATE_FORMAT(currentdate,'%W'),
        	DATE_FORMAT(currentdate,'%M'));
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;


-- CREACION DE TABLAS AUXILIARES Y CARGA / CREACION REALES CON SUS ESTRUCTURAS 

DROP TABLE IF EXISTS fact_ventas;
CREATE TABLE IF NOT EXISTS fact_ventas (
	IdVentas			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Fecha				DATE,
	Fecha_Entrega		DATE,
	IdCanal				INT,
	IdCliente			INT,
	IdSucursal			INT,
	IdEmpleado			INT,
	IdProducto			INT,
	Producto			VARCHAR(200) DEFAULT '-',
	IdProducto2			INT NOT NULL DEFAULT 0,
	Precio				DOUBLE,
	Cantidad			INT)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_empleados;
CREATE TABLE IF NOT EXISTS dim_empleados (
	IdEmpleado			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Nombre_Apellido		VARCHAR(100),
	IdSucursal			INT,
	IdSector			INT,
	IdCargo				INT)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_clientes;
CREATE TABLE IF NOT EXISTS dim_clientes (
	IdCliente			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Nombre_Apellido		VARCHAR(100),
	Edad				INT,
	Rango_Etario		VARCHAR(150))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_localidad;
CREATE TABLE IF NOT EXISTS dim_localidad (
	IdLocalidad			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Localidad			VARCHAR(200))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_sucursales;
CREATE TABLE IF NOT EXISTS dim_sucursales (
	IdSucursal			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Sucursal			VARCHAR(100),
	Domicilio			VARCHAR(200),
	Localidad			VARCHAR(100),
	Latitud2			VARCHAR(100),
	Longitud2			VARCHAR(100))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_productos;
CREATE TABLE IF NOT EXISTS dim_productos (
	IdProducto			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Producto			VARCHAR(200),
	Tipo				VARCHAR(100),
	Precio				DOUBLE,
	IdTipoProducto		INT NOT NULL DEFAULT 0)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_tipoproducto;
CREATE TABLE IF NOT EXISTS dim_tipoproducto (
	IdTipoProducto		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	TipoProducto		VARCHAR(100))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_sector;
CREATE TABLE IF NOT EXISTS dim_sector (
	IdSector			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Sector				VARCHAR(50))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_cargo;
CREATE TABLE IF NOT EXISTS dim_cargo (
	IdCargo				INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Cargo				VARCHAR(50))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS dim_canal;
CREATE TABLE IF NOT EXISTS dim_canal (
	IdCanal				INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Canal				VARCHAR(50))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS aux_ventas;
CREATE TABLE IF NOT EXISTS aux_ventas (
	IdVentas			INT NOT NULL,
	Fecha				DATE,
	Fecha_Entrega		DATE,
	IdCanal				INT NOT NULL,
	IdCliente			INT NOT NULL,
	IdSucursal			INT NOT NULL,
	IdEmpleado			INT NOT NULL,
	IdProducto			INT NOT NULL,
	Precio				DOUBLE,
	Cantidad			INT)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\Users\\Usuario\\Documents\\TABLAS_INT\\aux_ventas.csv' 
INTO TABLE aux_ventas
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS aux_clientes;
CREATE TABLE IF NOT EXISTS aux_clientes (
	ID					INTEGER,
	Provincia			VARCHAR(50),
	Nombre_y_Apellido	VARCHAR(80),
	Domicilio			VARCHAR(150),
	Telefono			VARCHAR(30),
	Edad				VARCHAR(5),
	Localidad			VARCHAR(80),
	X					VARCHAR(30),
	Y					VARCHAR(30),
	col10				VARCHAR(1))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\Users\\Usuario\\Documents\\TABLAS_INT\\aux_clientes.csv'
INTO TABLE aux_clientes
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS aux_canal;
CREATE TABLE IF NOT EXISTS aux_canal (
  	IdCanal				INTEGER,
  	Canal 				VARCHAR(50))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\Users\\Usuario\\Documents\\TABLAS_INT\\aux_canal.csv'
INTO TABLE aux_canal
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS aux_empleados;
CREATE TABLE IF NOT EXISTS aux_empleados (
	IDEmpleado			INTEGER,
	Apellido			VARCHAR(100),
	Nombre				VARCHAR(100),
	Sucursal			VARCHAR(50),
	Sector				VARCHAR(50),
	Cargo				VARCHAR(50),
	Salario2			VARCHAR(30)) 
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\Users\\Usuario\\Documents\\TABLAS_INT\\aux_empleados.csv'
INTO TABLE aux_empleados
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS aux_productos;
CREATE TABLE IF NOT EXISTS aux_productos (
	IDProducto			INTEGER,
	Concepto			VARCHAR(100),
	Tipo				VARCHAR(50),
	Precio2				VARCHAR(30))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\Users\\Usuario\\Documents\\TABLAS_INT\\aux_productos.csv'
INTO TABLE aux_productos
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS aux_sucursales;
CREATE TABLE IF NOT EXISTS aux_sucursales (
	ID					INTEGER,
	Sucursal			VARCHAR(40),
	Domicilio			VARCHAR(150),
	Localidad			VARCHAR(80),
	Provincia			VARCHAR(50),
	Latitud2			VARCHAR(30),
	Longitud2			VARCHAR(30)) 
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\Users\\Usuario\\Documents\\TABLAS_INT\\aux_sucursales.csv'
INTO TABLE aux_sucursales
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS dim_calendario;
CREATE TABLE dim_calendario (
	IdCalendario		INT,
	Fecha				DATE NOT NULL PRIMARY KEY,
	Año					INT NOT NULL,
	Mes					INT NOT NULL,
	Dia					INT NOT NULL,
	Trimestre			INT NOT NULL,
	Nombre_Dia			VARCHAR(10) NOT NULL,
	Nombre_Mes			VARCHAR(10) NOT NULL)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

TRUNCATE TABLE dim_calendario;
CALL Llenar_dimension_calendario('2015-01-01','2020-12-31')