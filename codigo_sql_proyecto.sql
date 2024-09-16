-- Creamos un nuevo esquema
CREATE SCHEMA classicmodels;

-- Revisamos duplicados
SELECT COUNT(*) AS REG_TOTALES,COUNT(DISTINCT productcode) AS VAL_DIST_COD
FROM raw_classiscmodels.products;
-- Revisar longitud de los campos
SELECT LENGTH(productcode) FROM raw_classiscmodels.products;
SELECT LENGTH(productcode) FROM raw_classiscmodels.products ORDER BY 1 DESC
LIMIT 1;
SELECT MAX(LENGTH(productcode)) FROM raw_classiscmodels.products;

-- Creamos la tabla de productos

CREATE TABLE classicmodels.dim_productos (
pk_producto varchar(15),
    nombre_producto varchar(60),
    cod_linea varchar(40),
    escala varchar(10),
    fabricante varchar(50),
    desc_producto varchar(4000),
    stock int,
    imp_compra decimal(15,2),
    imp_vend_recom decimal (15,2),
PRIMARY KEY (PK_PRODUCTO)
); 

-- Podemos modificar la tabla (nombre, añadir campos, modificar campos, eliminar campos)

RENAME TABLE classicmodels.TD_productos TO classicmodels.dim_productos;
ALTER TABLE classicmodels.dim_productos RENAME COLUMN estoc TO stock;
ALTER TABLE classicmodels.dim_productos ADD COLUMN EJEMPLO VARCHAR(2);
ALTER TABLE classicmodels.dim_productos DROP COLUMN EJEMPLO;
ALTER TABLE classicmodels.dim_productos MODIFY desc_producto VARCHAR(3000);

-- VALORES DISTINTOS DEL CAMPO PRODUCTLINE

SELECT DISTINCT(PRODUCTLINE) FROM raw_classiscmodels.products;

TRUNCATE TABLE classicmodels.dim_productos;

INSERT INTO classicmodels.dim_productos
select productcode,productname,
case 
		when productline ='Vintage Cars' then 'Coches Vintage'
		when productline ='Trucks and Buses' then 'Camiones y Autobuses'
        when productline ='Trains' then 'Trenes'
		when productline ='Ships' then 'Buques'
		when productline ='Planes' then 'Aviones'
        when productline ='Motorcycles' then 'Motos'
		when productline ='Classic Cars' then 'Coches clasicos'
	end,
productScale,productVendor,productDescription,quantityInStock,buyPrice,
MSRP from raw_classiscmodels.products;


-- Comprobar que la carga ha sido correcta, a nivel de num registros y comparan un registro entero.

-- Creamos la tabla de clientes

create table classicmodels.dim_clientes (
    pk_cliente int,
    nom_empresa varchar(50),
    nom_contacto_emp varchar(50),
    apell_contacto_emp varchar(50),
    direccion_emp varchar(120),
    cod_postal varchar(20),
    ciudad varchar(20),
    pais varchar(15),
    cod_representante_int int,
    imp_limite_cred numeric(15,2),
PRIMARY KEY (pk_cliente)
);

-- Vamos a probar el maximo de valores que caben 
INSERT INTO classicmodels.dim_clientes (pk_cliente,imp_limite_cred)
VALUES (1,1234567891234.22); -- Vemos que un 15,2 son 2 decimales i 13 enteros (15-2)


-- Revisamos duplicados si hay 
SELECT COUNT(CUSTOMERNUMBER), COUNT(DISTINCT CUSTOMERNUMBER)
FROM raw_classiscmodels.customers;

SELECT COUNT(country), COUNT(DISTINCT country)
FROM raw_classiscmodels.customers;

-- Juntamos dos campos (direccion)
SELECT ADDRESSLINE1,ADDRESSLINE2,
CONCAT(ADDRESSLINE1,' - ',COALESCE(ADDRESSLINE2,'')),
CONCAT(ADDRESSLINE1,' - ',ADDRESSLINE2)
 FROM Raw_classiscmodels.customers;


/* INICIO CLASE 20240722 */

	-- Funcion SUBSTR corta una cadena de caracteres desde la posicion x 
    -- hasta y posiciones. substr(campo, x , y)
	/* Función INSTR busca en una cadena de caracteres el caracter X. instr(campo, x). 
	Devuelve la posición en la que se encuentra el caracter buscado*/
	
    SELECT LASTNAMEFIRSTNAME,
    SUBSTR(LASTNAMEFIRSTNAME,1,2),
    instr(LASTNAMEFIRSTNAME,',') as pos_coma,
    SUBSTR(LASTNAMEFIRSTNAME,1,instr(LASTNAMEFIRSTNAME,',')-1) apellido,
    SUBSTR(LASTNAMEFIRSTNAME,instr(LASTNAMEFIRSTNAME,',')+1,99) nombre
    from raw_classiscmodels.customers;

	# Buscamos la SELECT que nos devuelve los datos tal y como queremos insertarlos

	select customernumber,customername,
	substr(lastnamefirstname,instr(lastnamefirstname,',')+1,99) as nombre,
	substr(lastnamefirstname,1,instr(lastnamefirstname,',')-1) as apellido,
	concat(addressline1,' ',coalesce(addressline2,'')) as direccion,
	postalcode,city,country,salesRepEmployeenumber,creditLimit
	from raw_classiscmodels.customers;

	# Hacemos el insert
	insert into dim_clientes
	select customernumber,customername,
	substr(lastnamefirstname,instr(lastnamefirstname,',')+1,99) as nombre,
	substr(lastnamefirstname,1,instr(lastnamefirstname,',')-1) as apellido,
	concat(addressline1,' ',coalesce(addressline2,'')) as direccion,
	postalcode,city,country,salesRepEmployeenumber,creditLimit
	from raw_classiscmodels.customers;

# 2) Creamos la tabla de pagos, pero con ID de empresa en vez de nombre de empresa y fecha pago en formato datetime.

	-- Revisamos que tiene la tabla
    

	# Miramos duplicados buscando el campo PK.
	SELECT checknumber,COUNT(*) FROM raw_classiscmodels.payments
	GROUP BY checknumber ORDER BY 2 DESC
	;
    
    SELECT COUNT(*),COUNT(DISTINCT checknumber) FROM raw_classiscmodels.payments
	;

	# Cambiar el campo paymentDate a Datetime. 
	select paymentdate,
    STR_TO_DATE(paymentdate,'%Y%m%d %H:%i:%s') as fec_pago
    from raw_classiscmodels.payments;
        
    # Cremos la sentencia de Create Table
    
    create table classicmodels.fac_pagos (
		pk_pago varchar(12),
		id_cliente int,
		fec_pago datetime,
		imp_pago decimal(15,2),
	primary key (pk_pago));


	#La función STR_TO_DATE pasa una cadena de caracteres a formato fecha, con la mascara X.  STR_TO_DATE(campo, x)
	-- web: https://www.w3schools.com/sql/sql_ref_mysql.asp

    
	# Añadir el ID empresa en vez del nombre empresa

    
    # La función join permite cruzar información de dos tablas diferentes mediante uno o mas campos.  
    -- https://joins.spathon.com
    -- Tipo de join
    -- Campo de cruce
    -- Cardinalidad
    
	select p.customername,c.customerNumber 
    from raw_classiscmodels.payments p
    left join 
    raw_classiscmodels.customers c
    on p.customername = c.customername;
    
	# Seleccionamos los datos en el formato que queremos cargarlos.
	
    select checknumber,c.customernumber,
	STR_TO_DATE(paymentDate, "%Y%m%d %H:%i:%s") as fec_pago ,
    p.amount 
    from raw_classiscmodels.payments p 
	left join raw_classiscmodels.customers c
	on p.customername = c.customername;
    
	# insert into classicmodels.fac_pagos (hay un error =p)
    
    insert into classicmodels.fac_pagos
    select checknumber,c.customernumber,
    STR_TO_DATE(paymentDate, "%Y%m%d %H:%i:%s") as fec_pago ,
    p.amount 
    from raw_classiscmodels.payments p 
	left join raw_classiscmodels.customers c
	on p.customername = c.customername;

	# Buscamos el registro con un error mediante un like
    
	select * from raw_classiscmodels.payments 
    where paymentDate like '20040119%';


    # Lo corregimos eliminando en la carga el sobrante
     SELECT 
    paymentDate,
    substr(paymentDate,1,17) 
    from raw_classiscmodels.payments  where paymentDate like '%20040119%';

    SELECT 
    paymentDate,
    substr(paymentDate,1,17) campo_acortado,
    STR_TO_DATE(substr(paymentDate,1,17), "%Y%m%d %H:%i:%s") fec_pago_corregida
    from raw_classiscmodels.payments  where paymentDate like '%20040119%';
    
	# Realizamos el insert corregido
     
	insert into classicmodels.fac_pagos
	select p.checknumber,c.customernumber,
	STR_TO_DATE(substr(paymentDate,1,17), "%Y%m%d %H:%i:%s"),p.amount from raw_classiscmodels.payments p 
	left join raw_classiscmodels.customers c
	on p.customername = c.customername;
    
# 3) Generar e insertar la tabla de pedidos. 
-- Guardar los campos en formato Date.

	-- Miramos que hay en la tabla y que campos podria ser PK
        select ordernumber,count(*) 
        from raw_classiscmodels.orders group by 1 order 
        by 2 desc ;
    -- Creamos la tabla 
        create table classicmodels.fac_pedidos (
		pk_pedido int,
		id_cliente int,
		fec_pedido date,
		fec_entrega_aprox date,
		fec_envio date,
		estado_envio varchar(20),
		desc_comentario_envio varchar(200),
	primary key (pk_pedido));
    
    # Seleccionamos e insertamos los datos que queremos cargar
   insert into classicmodels.fac_pedidos
	select 
    ordernumber,
	customernumber,
	STR_TO_DATE(orderdate, "%Y%m%d"),
	STR_TO_DATE(requireddate, "%Y%m%d"),
	STR_TO_DATE(shippedDate, "%Y%m%d"),
    status
	,comments from raw_classiscmodels.orders;
    
# 4) Creamos la tabla de detalle de pedidos. En este caso, atención con la clave primaria.

	-- Revisamos la tabla y buscamos campos posibles de PK
	select CONCAT(ordernumber,productCode),count(*) 
    from raw_classiscmodels.orderdetails
    group by 1;
    
    
    -- Creamos la tabla   
        create table classicmodels.fac_detalle_pedidos (
		pk_pedido int,
		pk_cod_producto varchar(10),
		num_productos int,
		imp_prod_ud decimal(15,2),
		PRIMARY KEY (pk_pedido,pk_cod_producto))
        ;

    
    
    -- Insertamos los datos
	insert into classicmodels.fac_detalle_pedidos
	select ordernumber,productCode,quantityOrdered,priceEach
	from raw_classiscmodels.orderdetails;

    INSERT INTO classicmodels.fac_detalle_pedidos
    (pk_pedido,pk_cod_producto) VALUES ('10101','VALERIA');
    

# 7) Jugar con las fechas en diferentes formatos. 10-31-24 , Jan 15 2025, 2024/12/31

	-- Probar con "from dual"
    select str_to_date('10-31-2024',"%m-%d-%Y") from dual;
	select str_to_date('Jan 15 2025',"%b %d %Y") from dual;
	select str_to_date('24/12/31',"%Y/%m/%d") from dual;
    
# 8) Identificar joins entre tablas

	-- Customer con pedidos
    
    select * from classicmodels.dim_clientes c
    left join classicmodels.fac_pedidos p
    on c.pk_cliente = p.id_cliente;
    
    -- Detalle pedidos con pedido detalle. 
    
	select * from classicmodels.fac_pedidos p
    left join classicmodels.fac_detalle_pedidos dp
    on p.pk_pedido = dp.pk_pedido;
    
    -- Ejemplo de cardinadiladad con detalle pedidos y customers.
    # Pedidos por cliente
	select c.pk_cliente,count(*) from classicmodels.dim_clientes c
    left join classicmodels.fac_pedidos p
    on c.pk_cliente = p.id_cliente
    group by pk_cliente;
    
	select c.pk_cliente,count(*),count(distinct dp.pk_cod_producto) from classicmodels.fac_pedidos p
    left join classicmodels.fac_detalle_pedidos dp
    on p.pk_pedido = dp.pk_pedido
    left join classicmodels.dim_clientes c
    on c.pk_cliente = p.id_cliente
    group by pk_cliente;
    
# 9) Cargar con duplicados

	#Insertamos un duplicado en origen (podemos porque no hay PK definida) 
	INSERT INTO raw_classiscmodels.customers (customerNumber, customerName, phone, addressLine1, addressLine2 , 
	city, state, postalCode, country, salesRepEmployeeNumber, creditLimit, lastNameFirstName) 
	VALUES (103,'Registro Duplicado','0','0',NULL,'0',NULL,'0','0',0,0.00,'0');

	# Borramos los datos de la tabla de dim_clientes e inentamos realizar el mismo insert de antes:
    
    Truncate classicmodels.dim_clientes ;
    
	insert into classicmodels.dim_clientes 
	select customernumber,customername,
	substr(lastnamefirstname,instr(lastnamefirstname,',')+1,99),
	substr(lastnamefirstname,1,instr(lastnamefirstname,',')-1),
	concat(addressline1,' - ',addressline2),
	postalcode,city,country,salesRepEmployeenumber,creditLimit
	from raw_classiscmodels.customers;
    
    # Buscamos el duplicado.

    select * from raw_classiscmodels.customers where customernumber=103;
    
	# Insertamos el duplicado en una tabla de rechazos que creamos en tiempo de ejecución
    
    create table classicmodels.dim_cliente_rechazos
    as
	select customernumber,customername,
	substr(lastnamefirstname,instr(lastnamefirstname,',')+1,99) nombre,
	substr(lastnamefirstname,1,instr(lastnamefirstname,',')-1) apellido,
	concat(addressline1,' - ',addressline2) direccion,
	postalcode,city,country,salesRepEmployeenumber,creditLimit,
    sysdate()
	from raw_classiscmodels.customers
    where customernumber=103 and phone=0;
    
    
    # filtramos este registro en la carga "normal"
	insert into classicmodels.dim_clientes 
	select customernumber,customername,
	substr(lastnamefirstname,instr(lastnamefirstname,',')+1,99),
	substr(lastnamefirstname,1,instr(lastnamefirstname,',')-1),
	concat(addressline1,' - ',addressline2),
	postalcode,city,country,salesRepEmployeenumber,creditLimit
	from raw_classiscmodels.customers
    where not(customernumber=103 and phone='0');
    
    select customernumber,customername,
	substr(lastnamefirstname,instr(lastnamefirstname,',')+1,99),
	substr(lastnamefirstname,1,instr(lastnamefirstname,',')-1),
	concat(addressline1,' - ',addressline2),
	postalcode,city,country,salesRepEmployeenumber,creditLimit
	from raw_classiscmodels.customers
    where customernumber != 103 and phone != 0;










