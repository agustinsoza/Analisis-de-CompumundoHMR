# DESCRIPCION DE BASE DE DATOS

Creamos la base de datos llamada integrador_2023 con las tablas:

**fact_ventas:** esta tabla será la tabla de hechos de la base de datos la cual nos permitirá analizar las ventas realizadas por la empresa en un periodo de tiempo. Sus campos son:

* IdVenta (PK) (INT)
* Fecha (FK) (DATE)
* Fecha_Entrega (DATE)
* IdCanal (FK) (INT)
* IdCliente (FK) (INT)
* IdEmpleado (FK) (INT)
* IdProducto (FK) (INT)
* Precio (DOUBLE)
* Cantidad (INT)

Las demás tablas serán las tablas de dimensiones que permitirán analizar estas ventas desde distintos enfoques.

**dim_clientes:**

* IdCliente (PK) (INT)
* Nombre_Apellido (VARCHAR(100))
* Edad (INT)
* Rango_Etario (VARCHAR(100))

**dim_Empleados:**

* IdEmpleado (PK) (INT)
* Nombre_Apellido (VARCHAR(100))
* IdSucursal (FK) (INT)
* IdCargo (FK) (INT)
•IdSector (FK) (INT)

**dim_Sucursales:**

* IdSucursales (PK) (INT)
* Sucursal (VARCHAR(100))
* Domicilio (VARCHAR(200))
* IdLocalidad (FK) (INT)

**dim_Localidad:**

* IdLocalidad (PK) (INT)
* Localidad (VARCHAR(200))

**dim_Cargo:**

* IdCargo (PK) (INT)
* Cargo VARCHAR(50)
