-- MODIFICACION DE CAMPOS

ALTER TABLE aux_clientes DROP col10;
ALTER TABLE aux_clientes DROP Latitud;
ALTER TABLE aux_clientes DROP Longitud;

ALTER TABLE aux_empleados DROP Salario2;

ALTER TABLE aux_productos ADD Precio FLOAT NOT NULL DEFAULT '0' AFTER Precio2;
UPDATE aux_productos SET Precio = CAST(REPLACE(Precio2,',','.') AS FLOAT);
ALTER TABLE aux_productos DROP Precio2;
ALTER TABLE aux_productos CHANGE Concepto Producto VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NULL DEFAULT NULL;

-- IMPUTACION DE DATOS FALTANTES

UPDATE aux_clientes SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE aux_clientes SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);
UPDATE aux_clientes SET Nombre_y_Apellido = 'Sin Dato' WHERE TRIM(Nombre_y_Apellido) = "" OR ISNULL(Nombre_y_Apellido);
UPDATE aux_clientes SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);

UPDATE aux_empleados SET Apellido = 'Sin Dato' WHERE TRIM(Apellido) = "" OR ISNULL(Apellido);
UPDATE aux_empleados SET Nombre = 'Sin Dato' WHERE TRIM(Nombre) = "" OR ISNULL(Nombre);
UPDATE aux_empleados SET Sucursal = 'Sin Dato' WHERE TRIM(Sucursal) = "" OR ISNULL(Sucursal);
UPDATE aux_empleados SET Sector = 'Sin Dato' WHERE TRIM(Sector) = "" OR ISNULL(Sector);
UPDATE aux_empleados SET Cargo = 'Sin Dato' WHERE TRIM(Cargo) = "" OR ISNULL(Cargo);

UPDATE aux_productos SET Producto = 'Sin Dato' WHERE TRIM(Producto) = "" OR ISNULL(Producto);
UPDATE aux_productos SET Tipo = 'Sin Dato' WHERE TRIM(Tipo) = "" OR ISNULL(Tipo);

UPDATE aux_sucursales SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE aux_sucursales SET Sucursal = 'Sin Dato' WHERE TRIM(Sucursal) = "" OR ISNULL(Sucursal);
UPDATE aux_sucursales SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);
UPDATE aux_sucursales SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);

-- NORMALIZACION A LETRA CAPITAL

UPDATE aux_clientes 	SET Provincia = UC_Words(TRIM(Provincia)),
							Localidad = UC_Words(TRIM(Localidad)),
							Domicilio = UC_Words(TRIM(Domicilio)),
							Nombre_y_Apellido = UC_Words(TRIM(Nombre_y_Apellido));
					
UPDATE aux_sucursales 	SET Provincia = UC_Words(TRIM(Provincia)),
							Localidad = UC_Words(TRIM(Localidad)),
							Domicilio = UC_Words(TRIM(Domicilio)),
							Sucursal = UC_Words(TRIM(Sucursal));
					
UPDATE aux_productos 	SET Producto = UC_Words(TRIM(Producto)),
							Tipo = UC_Words(TRIM(Tipo));
					
UPDATE aux_empleados 	SET Sucursal = UC_Words(TRIM(Sucursal)),
							Sector = UC_Words(TRIM(Sector)),
							Cargo = UC_Words(TRIM(Cargo)),
							Nombre = UC_Words(TRIM(Nombre)),
							Apellido = UC_Words(TRIM(Apellido));
							
-- CREACION TABLA AUX LOCALIDAD Y CORRECCION DE ERRORES

DROP TABLE IF EXISTS aux_localidad;
CREATE TABLE IF NOT EXISTS aux_localidad (
	Localidad_Original		VARCHAR(80),
	Provincia_Original		VARCHAR(50),
	Localidad_Normalizada	VARCHAR(80),
	Provincia_Normalizada	VARCHAR(50),
	IdLocalidad				INTEGER)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO aux_localidad (Localidad_Original, Provincia_Original, Localidad_Normalizada, Provincia_Normalizada, IdLocalidad)
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM aux_clientes
UNION
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM aux_sucursales;

UPDATE aux_localidad SET Provincia_Normalizada = 'Buenos Aires'
WHERE Provincia_Original IN ('B. Aires',
                            'B.Aires',
                            'Bs As',
                            'Bs.As.',
                            'Buenos Aires',
                            'C Debuenos Aires',
                            'Caba',
                            'Ciudad De Buenos Aires',
                            'Pcia Bs As',
                            'Prov De Bs As.',
                            'Provincia De Buenos Aires');
							
UPDATE aux_localidad SET Localidad_Normalizada = 'Capital Federal'
WHERE Localidad_Original IN ('Boca De Atencion Monte Castro',
                            'Caba',
                            'Cap.   Federal',
                            'Cap. Fed.',
                            'Capfed',
                            'Capital',
                            'Capital Federal',
                            'Cdad De Buenos Aires',
                            'Ciudad De Buenos Aires')
AND Provincia_Normalizada = 'Buenos Aires';
							
DELETE FROM aux_localidad
WHERE Provincia_Normalizada <> 'Buenos Aires';

-- CORRECCION PRECIOS TABLA AUX_PRODUCTOS

UPDATE aux_ventas v JOIN aux_productos p ON (v.IdProducto = p.IdProducto) 
SET v.Precio = p.Precio
WHERE v.Precio = 0;

-- INCORPORACION DE RANGO ETARIO

ALTER TABLE aux_clientes ADD Rango_Etario VARCHAR(20) NOT NULL DEFAULT '-' AFTER Edad;

UPDATE aux_clientes SET Rango_Etario = '1_Hasta 30 años' WHERE Edad <= 30;
UPDATE aux_clientes SET Rango_Etario = '2_De 31 a 40 años' WHERE Edad <= 40 AND Rango_Etario = '-';
UPDATE aux_clientes SET Rango_Etario = '3_De 41 a 50 años' WHERE Edad <= 50 AND Rango_Etario = '-';
UPDATE aux_clientes SET Rango_Etario = '4_De 51 a 60 años' WHERE Edad <= 60 AND Rango_Etario = '-';
UPDATE aux_clientes SET Rango_Etario = '5_Desde 60 años' WHERE Edad > 60 AND Rango_Etario = '-';

-- CORRECCION TABLAS AUX ANTES DE CARGA

UPDATE aux_clientes c JOIN aux_localidad l
	ON (c.Provincia = l.Provincia_Original 
    	AND c.Localidad = l.Localidad_Original)
SET c.Provincia = l.Provincia_Normalizada;

UPDATE aux_sucursales s JOIN aux_localidad l
	ON (s.Provincia = l.Provincia_Original 
    	AND s.Localidad = l.Localidad_Original)
SET s.Provincia = l.Provincia_Normalizada;

UPDATE aux_sucursales s JOIN aux_localidad l
	ON (s.Localidad = l.Localidad_Original)
SET s.Localidad = l.Localidad_Normalizada;

UPDATE aux_empleados e JOIN aux_sucursales s
	ON (e.Sucursal = s.Sucursal)
SET e.Sucursal = '0' WHERE s.Provincia <> 'Buenos Aires';

UPDATE aux_empleados SET Sucursal = 0 WHERE Sucursal = 'Mendoza 1';
UPDATE aux_empleados SET Sucursal = 0 WHERE Sucursal = 'Mendoza 2';

DELETE FROM aux_clientes WHERE Provincia <> 'Buenos Aires';
DELETE FROM aux_sucursales WHERE Provincia <> 'Buenos Aires';
DELETE FROM aux_empleados WHERE Sucursal = '0';
DELETE FROM aux_ventas WHERE IdSucursal NOT BETWEEN 1 AND 22;

ALTER TABLE aux_empleados ADD IdSucursal INT NOT NULL DEFAULT 0 AFTER Cargo;
ALTER TABLE aux_empleados ADD IdSector INT NOT NULL DEFAULT 0 AFTER IdSucursal;
ALTER TABLE aux_empleados ADD IdCargo INT NOT NULL DEFAULT 0 AFTER IdSector;

-- CARGA DE TABLAS DIM CON TABLAS AUX

INSERT INTO fact_ventas (Fecha, Fecha_Entrega, IdCanal, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad)
	SELECT Fecha, Fecha_Entrega, IdCanal, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad
	FROM aux_ventas;

UPDATE fact_ventas v JOIN aux_productos p
	ON(v.IdProducto = p.IdProducto)
SET v.Producto = p.Producto;

INSERT INTO dim_canal (IdCanal, Canal)
	SELECT IdCanal, Canal
	FROM aux_canal;

INSERT INTO dim_cargo (Cargo)
	SELECT DISTINCT Cargo 
	FROM aux_empleados;

INSERT INTO dim_clientes (Nombre_Apellido, Edad, Rango_Etario)
	SELECT Nombre_y_Apellido, Edad, Rango_Etario
	FROM aux_clientes;

INSERT INTO dim_localidad (Localidad)
	SELECT Localidad_Normalizada
	FROM aux_localidad;

INSERT INTO dim_productos (Producto, Tipo, Precio,)
	SELECT Producto, Tipo, Precio
	FROM aux_productos;

UPDATE fact_ventas v JOIN dim_productos p
	ON (v.Producto = p.Producto)
SET v.IdProducto2 = p.IdProducto;

ALTER TABLE fact_ventas DROP IdProducto;
ALTER TABLE fact_ventas DROP Producto;
ALTER TABLE fact_ventas CHANGE IdProducto2 IdProducto INT NOT NULL;

UPDATE fact_ventas v JOIN dim_productos p
	ON (v.IDProducto = p.IDProducto)
SET v.Precio = p.Precio;

ALTER TABLE fact_ventas ADD IdEmpleado2 INT NOT NULL DEFAULT 0 AFTER IdEmpleado;
ALTER TABLE dim_empleados ADD IdEmpleado2 INT NOT NULL DEFAULT 0 AFTER IDEmpleado;

INSERT INTO dim_sector (Sector)
	SELECT DISTINCT Sector
	FROM aux_empleados;

INSERT INTO dim_sucursales (Sucursal, Domicilio, Localidad, Latitud2, Longitud2)
	SELECT Sucursal, Domicilio, Localidad, Latitud2, Longitud2
	FROM aux_sucursales;

ALTER TABLE dim_sucursales ADD IdLocalidad INT NOT NULL DEFAULT 0 AFTER Localidad;

UPDATE dim_sucursales s JOIN dim_localidad l
	ON (s.Localidad = l.Localidad)
SET s.IdLocalidad = l.IdLocalidad;

ALTER TABLE dim_sucursales DROP Localidad;

INSERT INTO dim_tipoproducto (TipoProducto)
	SELECT DISTINCT Tipo
	FROM aux_productos;

UPDATE dim_productos p JOIN dim_tipoproducto tp 
	ON (p.Tipo = tp.Tipo)
SET p.IdTipoProducto = tp.IdTipoProducto;

ALTER TABLE dim_productos DROP Tipo;

UPDATE aux_empleados e JOIN dim_sucursales s
	ON (e.Sucursal = s.Sucursal)
SET e.IdSucursal = s.IdSucursal;

UPDATE aux_empleados e JOIN dim_sector s
	ON (e.Sector = s.Sector)
SET e.IdSector = s.IdSector;

UPDATE aux_empleados e JOIN dim_cargo c
	ON (e.Cargo = c.Cargo)
SET e.IdCargo = c.IdCargo;

INSERT INTO dim_empleados (IdEmpleado2, Nombre_Apellido, IdSucursal, IdSector, IdCargo)
	SELECT IdEmpleado, CONCAT(Nombre,' ',Apellido), IdSucursal, IdSector, IdCargo
	FROM aux_empleados;

UPDATE fact_ventas v JOIN dim_empleados e
	ON (v.IdEmpleado = e.IdEmpleado2)
SET v.IdEmpleado2 = e.IDEmpleado;

ALTER TABLE dim_empleados DROP IdEmpleado2;
ALTER TABLE fact_ventas DROP IDEmpleado;
ALTER TABLE fact_ventas CHANGE IdEmpleado2 IdEmpleado INT;
	
-- CASTEO DE LATITUD Y LONGITUD A DOUBLE

ALTER TABLE dim_sucursales ADD Latitud DOUBLE NOT NULL DEFAULT '0' AFTER Longitud2, ADD Longitud DOUBLE NOT NULL DEFAULT '0' AFTER Latitud;
UPDATE dim_sucursales SET Latitud = CAST(REPLACE(Latitud2,',','.') AS DOUBLE);
UPDATE dim_sucursales SET Longitud = CAST(REPLACE(Longitud2,',','.') AS DOUBLE);
ALTER TABLE dim_sucursales DROP Latitud2;
ALTER TABLE dim_sucursales DROP Longitud2;

-- CREACION DE CLAVES FORANEAS 

ALTER TABLE fact_ventas ADD INDEX(Fecha);
ALTER TABLE fact_ventas ADD INDEX(IdCanal);
ALTER TABLE fact_ventas ADD INDEX(IdCliente);
ALTER TABLE fact_ventas ADD INDEX(IdSucursal);
ALTER TABLE fact_ventas ADD INDEX(IdEmpleado);
ALTER TABLE fact_ventas ADD INDEX(IdProducto);

ALTER TABLE dim_productos ADD INDEX(IdTipoProducto);

ALTER TABLE dim_empleados ADD INDEX(IdSucursal);
ALTER TABLE dim_empleados ADD INDEX(IdCargo);
ALTER TABLE dim_empleados ADD INDEX(IdSector);

ALTER TABLE dim_sucursales ADD INDEX(IdLocalidad);

-- MODIFICACION DE Nombre_Dia y Nombre_Mes A ESPAÑOL

UPDATE dim_calendario	SET Nombre_Dia = 'Lunes' WHERE Nombre_Dia = 'Monday';
UPDATE dim_calendario	SET Nombre_Dia = 'Martes' WHERE Nombre_Dia = 'Tuesday';
UPDATE dim_calendario	SET Nombre_Dia = 'Miercoles' WHERE Nombre_Dia = 'Wednesday';
UPDATE dim_calendario	SET Nombre_Dia = 'Jueves' WHERE Nombre_Dia = 'Thursday';
UPDATE dim_calendario	SET Nombre_Dia = 'Viernes' WHERE Nombre_Dia = 'Friday';
UPDATE dim_calendario	SET Nombre_Dia = 'Sabado' WHERE Nombre_Dia = 'Saturday';
UPDATE dim_calendario	SET Nombre_Dia = 'Domingo' WHERE Nombre_Dia = 'Sunday';

UPDATE dim_calendario	SET Nombre_Mes = 'Enero' WHERE Nombre_Mes = 'January';
UPDATE dim_calendario	SET Nombre_Mes = 'Febrero' WHERE Nombre_Mes = 'February';
UPDATE dim_calendario	SET Nombre_Mes = 'Marzo' WHERE Nombre_Mes = 'March';
UPDATE dim_calendario	SET Nombre_Mes = 'Abril' WHERE Nombre_Mes = 'April';
UPDATE dim_calendario	SET Nombre_Mes = 'Mayo' WHERE Nombre_Mes = 'May';
UPDATE dim_calendario	SET Nombre_Mes = 'Junio' WHERE Nombre_Mes = 'June';
UPDATE dim_calendario	SET Nombre_Mes = 'Julio' WHERE Nombre_Mes = 'July';
UPDATE dim_calendario	SET Nombre_Mes = 'Agosto' WHERE Nombre_Mes = 'August';
UPDATE dim_calendario	SET Nombre_Mes = 'Septiembre' WHERE Nombre_Mes = 'September';
UPDATE dim_calendario	SET Nombre_Mes = 'Octubre' WHERE Nombre_Mes = 'October';
UPDATE dim_calendario	SET Nombre_Mes = 'Noviembre' WHERE Nombre_Mes = 'November';
UPDATE dim_calendario	SET Nombre_Mes = 'Diciembre' WHERE Nombre_Mes = 'December';

-- CORRECCIONES 

UPDATE fact_ventas SET Cantidad = 1 WHERE Cantidad = 0;

UPDATE dim_productos SET Precio = 1351.35 WHERE IdProducto = 165;
