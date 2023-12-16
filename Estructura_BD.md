# DESCRIPCION DE BASE DE DATOS

Creamos la base de datos llamada integrador_2023 con las tablas:

### fact_ventas:  
Esta tabla será la tabla de hechos de la base de datos la cual nos permitirá analizar las ventas realizadas por la empresa en un periodo de tiempo. Sus campos son:

* IdVenta (PK) (INT)
* Fecha (FK) (DATE)
* Fecha_Entrega (DATE)
* IdCanal (FK) (INT)
* IdCliente (FK) (INT)
* IdSucursal (INT)
* IdEmpleado (FK) (INT)
* IdProducto (FK) (INT)
* Producto (VARCHAR(200))
* IdProducto2 (INT)
* Precio (DOUBLE)
* Cantidad (INT)

Las demás tablas serán las tablas de dimensiones que permitirán analizar estas ventas desde distintos enfoques.

### dim_clientes:

* IdCliente (PK) (INT)
* Nombre_Apellido (VARCHAR(100))
* Edad (INT)
* Rango_Etario (VARCHAR(100))

### dim_empleados:

* IdEmpleado (PK) (INT)
* Nombre_Apellido (VARCHAR(100))
* IdSucursal (FK) (INT)
* IdSector (FK) (INT)
* IdCargo (FK) (INT)

### dim_sucursales:

* IdSucursales (PK) (INT)
* Sucursal (VARCHAR(100))
* Domicilio (VARCHAR(200))
* Localidad (FK) (INT)
* Latitud2 (VARCHAR(100))
* Longitud2 (VARCHAR(100))

### dim_localidad:

* IdLocalidad (PK) (INT)
* Localidad (VARCHAR(200))

### dim_cargo:

* IdCargo (PK) (INT)
* Cargo (VARCHAR(50))

### dim_canal:

* IdCanal (PK) (INT)
* Canal (VARCHAR(100))

### dim_producto:

* IdProducto (PK) (INT)
* Producto (VARCHAR(200))
* Tipo (VARCHAR(100))
* Precio (DOUBLE)
* IdTipoProducto (INT)

### dim_tipoProducto:

* IdTipoProducto (PK) (INT)
* TipoProducto (VARCHAR(100))

### dim_sector:

* IdSector (PK) (INT)
* Sector (VARCHAR(50))


