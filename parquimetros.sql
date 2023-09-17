CREATE DATABASE parquimetros;

# selecciono la base de datos sobre la cual voy a hacer modificaciones
USE parquimetros;


CREATE TABLE Conductores (
 dni INT UNSIGNED NOT NULL ,
 nombre VARCHAR(45) NOT NULL, 
 apellido  VARCHAR(45) NOT NULL,
 direccion VARCHAR(45) NOT NULL, 
 telefono VARCHAR(45), 
 registro INT UNSIGNED NOT NULL, 
 
 CONSTRAINT pk_conductores
 PRIMARY KEY (dni)

) ENGINE=InnoDB;


CREATE TABLE Automoviles (
 patente CHAR(6),
 marca VARCHAR(45) NOT NULL,
 modelo VARCHAR(45) NOT NULL,
 color VARCHAR(45) NOT NULL,
 dni INT UNSIGNED NOT NULL ,

CONSTRAINT pk_automoviles
 PRIMARY KEY (patente),

 CONSTRAINT FK_Automoviles
 FOREIGN KEY (dni) REFERENCES Conductores(dni)

)ENGINE=InnoDB;


CREATE TABLE Tipos_tarjeta (
 tipo VARCHAR(45) NOT NULL ,
 descuento DECIMAL(3,2) UNSIGNED NOT NULL CHECK (descuento >= 0 AND descuento <= 1),

 CONSTRAINT pk_Tipos_tarjeta
 PRIMARY KEY (tipo)

) ENGINE=InnoDB;


CREATE TABLE Tarjetas  (
 patente CHAR(6) NOT NULL,
 id_tarjeta INT UNSIGNED NOT NULL AUTO_INCREMENT  ,
 saldo DECIMAL(5,2) NOT NULL, 
 tipo VARCHAR(25) NOT NULL,

 CONSTRAINT pk_tarjetas
 PRIMARY KEY (id_tarjeta),

 CONSTRAINT FK_Tarjetas
 FOREIGN KEY (patente) REFERENCES Automoviles(patente),
  CONSTRAINT FK_Tipos_tarjeta
 FOREIGN KEY (tipo) REFERENCES Tipos_tarjeta(tipo)


) ENGINE=InnoDB;


CREATE TABLE Recargas (
 id_tarjeta INT UNSIGNED NOT NULL AUTO_INCREMENT,
 fecha  DATE NOT NULL,
 hora TIME NOT NULL,
 saldo_anterior DECIMAL(5,2) NOT NULL, 
 saldo_posterior DECIMAL(5,2) NOT NULL, 
 CONSTRAINT pk_recargas
 PRIMARY KEY (id_tarjeta,fecha,hora),
 
 CONSTRAINT FK_Recargas
 FOREIGN KEY (id_tarjeta) REFERENCES Tarjetas(id_tarjeta)

 
 

) ENGINE=InnoDB;


CREATE TABLE Inspectores (
 legajo INT UNSIGNED NOT NULL ,
 dni INT UNSIGNED NOT NULL ,
 nombre VARCHAR(45) NOT NULL, 
 apellido  VARCHAR(45) NOT NULL,
 password  VARCHAR(32) NOT NULL, 
 
 CONSTRAINT pk_Inspectores
 PRIMARY KEY (legajo)

) ENGINE=InnoDB;


CREATE TABLE Ubicaciones (
 calle VARCHAR(45),
 altura INT UNSIGNED NOT NULL,
 tarifa DECIMAL(5,2) UNSIGNED NOT NULL CHECK (tarifa >= 0),
 
 CONSTRAINT pk_Ubicaciones
 PRIMARY KEY(altura,calle)
) ENGINE=InnoDB;


CREATE TABLE Parquimetros (
 id_parq INT UNSIGNED NOT NULL ,
 numero INT UNSIGNED NOT NULL, 
 calle VARCHAR(45) NOT NULL,
 altura INT UNSIGNED NOT NULL,



 CONSTRAINT FK_Parquimetros_Ubicaciones
 FOREIGN KEY (altura,calle) REFERENCES Ubicaciones(altura,calle),

 CONSTRAINT pk_Parquimetros
 PRIMARY KEY(id_parq)

) ENGINE=InnoDB;


CREATE TABLE Estacionamientos (
 id_parq INT UNSIGNED NOT NULL ,
 fecha_ent DATE NOT NULL, 
 hora_ent TIME NOT NULL,
 fecha_sal DATE , 
 hora_sal TIME ,
 id_tarjeta INT UNSIGNED NOT NULL ,

 CONSTRAINT FK_Estacionamientos_Tarjetas
 FOREIGN KEY (id_tarjeta) REFERENCES Tarjetas(id_tarjeta),

 CONSTRAINT FK_Estacionamientos_Parquimetros
 FOREIGN KEY (id_parq) REFERENCES Parquimetros(id_parq),

 CONSTRAINT pk_Estacionamientos
 PRIMARY KEY (id_parq,fecha_ent,hora_ent)

) ENGINE=InnoDB;


CREATE TABLE Accede (
 fecha DATE NOT NULL, 
 hora TIME NOT NULL,
 legajo INT UNSIGNED NOT NULL ,
 id_parq INT UNSIGNED NOT NULL ,


 CONSTRAINT FK_Accede
 FOREIGN KEY (id_parq) REFERENCES Parquimetros(id_parq),

 CONSTRAINT FK_Accede_Inspectores
 FOREIGN KEY (legajo) REFERENCES Inspectores(legajo),

 CONSTRAINT pk_Accede 
 PRIMARY KEY(id_parq,fecha,hora)


) ENGINE=InnoDB;

CREATE TABLE Asociado_con (
 id_asociado_con INT UNSIGNED NOT NULL AUTO_INCREMENT,
 dia ENUM('do', 'lu', 'ma', 'mi', 'ju', 'vi', 'sa') NOT NULL, 
 turno ENUM('m', 't') NOT NULL,
 calle VARCHAR(45) NOT NULL,
 altura INT UNSIGNED NOT NULL,
 legajo INT UNSIGNED NOT NULL ,

 CONSTRAINT FK_Asociado_con_Inspectores
 FOREIGN KEY (legajo) REFERENCES Inspectores(legajo),
 
 CONSTRAINT FK_Asociado_con_Ubicaciones
 FOREIGN KEY (altura,calle) REFERENCES Ubicaciones(altura,calle),
 
 CONSTRAINT pk_Asociado_con
 PRIMARY KEY (id_asociado_con)

) ENGINE=InnoDB;

CREATE TABLE Multa (
 numero INT UNSIGNED NOT NULL AUTO_INCREMENT,
 fecha DATE NOT NULL, 
 hora TIME NOT NULL,
 id_asociado_con INT UNSIGNED NOT NULL,
 patente CHAR(6) NOT NULL,


 CONSTRAINT FK_Multa_Asociado_con
 FOREIGN KEY (id_asociado_con) REFERENCES Asociado_con(id_asociado_con),
 
 CONSTRAINT FK_Multa_Automoviles
 FOREIGN KEY (patente) REFERENCES Automoviles(patente),

 CONSTRAINT pk_Multa
 PRIMARY KEY (numero)

) ENGINE=InnoDB;



CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON parquimetros.* TO 'admin'@'localhost' WITH GRANT OPTION;

CREATE USER 'venta'@'%' IDENTIFIED BY 'venta';
GRANT INSERT, UPDATE ON parquimetros.Tarjetas TO 'venta'@'%';
GRANT INSERT ON parquimetros.Recargas TO 'venta'@'%';

CREATE USER 'inspector'@'%' IDENTIFIED BY 'inspector';
GRANT SELECT ON parquimetros.Estacionamientos TO 'inspector'@'%';
GRANT SELECT (legajo), UPDATE (legajo) ON parquimetros.Inspectores TO 'inspector'@'%';
GRANT SELECT(legajo,password) ON parquimetros.Inspectores TO 'inspector'@'%';
/*GRANT EXECUTE ON FUNCTION parquimetros.patentes_estacionamiento_abierto TO 'inspector'@'%';*/
GRANT INSERT ON parquimetros.Multa TO 'inspector'@'%';
GRANT INSERT ON parquimetros.Accede TO 'inspector'@'%';


/*CREATE VIEW estacionados AS
SELECT u.calle, u.altura e.fecha_ent e.hora_ent t.patente
FROM Ubicaciones(
    SELECT
    id_tarjeta
    FROM Tarjetas t
    INNER JOIN Estacionamientos e
    ON t.id_tarjeta = e.id_tarjeta
    WHERE (e.hora_ent != NULL AND e.fecha_ent != NULL AND e.hora_sal = NULL)
);
*/

CREATE VIEW estacionados AS
SELECT u.calle, u.altura, e.fecha_ent, e.hora_ent, t.patente
FROM Ubicaciones u
INNER JOIN (
    SELECT
    id_tarjeta
    FROM Tarjetas t
    INNER JOIN Estacionamientos e
    ON t.id_tarjeta = e.id_tarjeta
    WHERE (e.hora_ent IS NOT NULL AND e.fecha_ent IS NOT NULL AND e.hora_sal IS NULL)
) t
ON u.id_tarjeta = t.id_tarjeta;


INSERT INTO Conductores VALUES (44321404, "tobias", "Gatti", "ed gon" ,2916446463 ,1);
INSERT INTO Conductores VALUES (44490499, "amparo", "gutierrez", "La cautiva y Los piquillines", 2915223437, 4);


INSERT INTO Automoviles VALUES("MBU", "volkswagen","a","rojo",44321404);


INSERT INTO Tipos_tarjetas VALUES("A",0,15 );

INSERT INTO Tarjetas VALUES(123, 215.56,"A","MBU");

INSERT INTO Recargas VALUES(123,'20-06-2017', '10:00:20',333.44,342.55);

INSERT INTO Inspectores (legajo, dni, nombre, apellido, passwrd)
VALUES (1, 55555555, 'Inspector', 'Apellido', 'contrasena_hash');

INSERT INTO Ubicaciones (calle, altura, tarifa)
VALUES ('Calle Principal', 100, 2.50);

INSERT INTO Parquimetros (id_parq, numero, calle, altura)
VALUES (1, 'PQ001', 'Calle Principal', 100);

INSERT INTO Estacionamientos (id_parq, fecha_ent, hora_ent, fecha_sal, hora_sal, id_tarjeta)
VALUES (1, '2023-09-15', '10:00:00', '2023-09-15', '11:00:00', 1);

INSERT INTO Accede (fecha, hora, legajo, id_parq)
VALUES ('2023-09-15', '10:00:00', 1, 1);

INSERT INTO Asociado_con (id_asociado_con, dia, turno, calle, altura, legajo)
VALUES (1, 'LU', 'M', 'Calle Principal', 100, 1);

INSERT INTO Multa (numero, fecha, hora, id_asociado_con, patente)
VALUES (1, '2023-09-15', '11:30:00', 1, 'ABC123');
