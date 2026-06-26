-- ============================================================
--  SISTEMA DE BIBLIOTECA - DDL PostgreSQL
-- ============================================================

-- ============================================================
--  MÓDULO 1: CATÁLOGO DE LIBROS
-- ============================================================

CREATE TABLE IDIOMAS (
    idIdioma     SERIAL        PRIMARY KEY,
    nombreIdioma VARCHAR(50)   NOT NULL
);

CREATE TABLE EDITORIALES (
    idEditorial  SERIAL        PRIMARY KEY,
    nombre       VARCHAR(150)  NOT NULL,
    pais         VARCHAR(80),
    contacto     VARCHAR(100)
);

CREATE TABLE CATEGORIAS (
    idCategoria      SERIAL        PRIMARY KEY,
    nombreCategoria  VARCHAR(100)  NOT NULL,
    descripcion      TEXT
);

CREATE TABLE LIBROS (
    idLibro          SERIAL        PRIMARY KEY,
    titulo           VARCHAR(255)  NOT NULL,
    isbn             VARCHAR(20)   UNIQUE,
    anioPublicacion  INT,
    edicion          VARCHAR(50),
    idEditorial      INT           NOT NULL REFERENCES EDITORIALES(idEditorial),
    idCategoria      INT           NOT NULL REFERENCES CATEGORIAS(idCategoria),
    idIdioma         INT           NOT NULL REFERENCES IDIOMAS(idIdioma)
);

CREATE TABLE AUTORES (
    idAutor      SERIAL        PRIMARY KEY,
    nombre       VARCHAR(150)  NOT NULL,
    nacionalidad VARCHAR(80),
    biografia    TEXT
);

CREATE TABLE LIBRO_AUTOR (
    idLibroAutor  SERIAL  PRIMARY KEY,
    idLibro       INT     NOT NULL REFERENCES LIBROS(idLibro),
    idAutor       INT     NOT NULL REFERENCES AUTORES(idAutor),
    UNIQUE (idLibro, idAutor)
);

CREATE TABLE PALABRAS_CLAVE (
    idPalabraClave  SERIAL        PRIMARY KEY,
    palabra         VARCHAR(100)  NOT NULL UNIQUE
);

CREATE TABLE LIBRO_PALABRA_CLAVE (
    idLibroPalabra  SERIAL  PRIMARY KEY,
    idLibro         INT     NOT NULL REFERENCES LIBROS(idLibro),
    idPalabraClave  INT     NOT NULL REFERENCES PALABRAS_CLAVE(idPalabraClave),
    UNIQUE (idLibro, idPalabraClave)
);

CREATE TABLE UBICACIONES_FISICAS (
    idUbicacion  SERIAL       PRIMARY KEY,
    seccion      VARCHAR(50),
    pasillo      VARCHAR(50),
    estanteria   VARCHAR(50)
);

CREATE TABLE EDICION_VOLUMEN (
    idEdicionVolumen  SERIAL        PRIMARY KEY,
    codigoBarras      VARCHAR(50)   UNIQUE,
    estadoFisico      VARCHAR(50),
    disponibilidad    VARCHAR(30),
    idLibro           INT           NOT NULL REFERENCES LIBROS(idLibro),
    idUbicacion       INT           REFERENCES UBICACIONES_FISICAS(idUbicacion)
);


-- ============================================================
--  MÓDULO 2: USUARIOS Y MEMBRESÍAS (MODIFICADO)
-- ============================================================

CREATE TABLE TIPOS_USUARIO (
    idTipoUsuario  SERIAL        PRIMARY KEY,
    nombreTipo     VARCHAR(80)   NOT NULL,
    descripcion    TEXT
);

CREATE TABLE PERSONA (
    idPersona    SERIAL        PRIMARY KEY,
    pNombre      VARCHAR(80)   NOT NULL,
    sNombre      VARCHAR(80),
    pApellido    VARCHAR(80)   NOT NULL,
    sApellido    VARCHAR(80),
    correo       VARCHAR(150)  UNIQUE NOT NULL,
    telefono     VARCHAR(20),
    direccion    TEXT
);

CREATE TABLE USUARIOS (
    idUsuario       SERIAL        PRIMARY KEY,
    passwordHash    VARCHAR(255)  NOT NULL,
    fechaRegistro   DATE          DEFAULT CURRENT_DATE,
    idPersona       INT           NOT NULL UNIQUE REFERENCES PERSONA(idPersona),
    idTipoUsuario   INT           NOT NULL REFERENCES TIPOS_USUARIO(idTipoUsuario)
);



CREATE TABLE MEMBRESIAS (
    idMembresia      SERIAL          PRIMARY KEY,
    nombreMembresia  VARCHAR(100)    NOT NULL,
    descripcion      TEXT,
    costo            NUMERIC(10,2),
    duracionMeses    INT
);

CREATE TABLE HISTORIAL_MEMBRESIAS (
    idHistorialMembresia  SERIAL  PRIMARY KEY,
    idUsuario             INT     NOT NULL REFERENCES USUARIOS(idUsuario),
    idMembresia           INT     NOT NULL REFERENCES MEMBRESIAS(idMembresia),
    fechaInicio           DATE    NOT NULL,
    fechaFin              DATE
);

-- ============================================================
--  MÓDULO 3: PRÉSTAMOS, DEVOLUCIONES Y RESERVAS
-- ============================================================

CREATE TABLE PRESTAMOS (
    idPrestamo              SERIAL  PRIMARY KEY,
    fechaPrestamo           DATE    NOT NULL DEFAULT CURRENT_DATE,
    fechaLimiteDevolucion   DATE    NOT NULL,
    idUsuario               INT     NOT NULL REFERENCES USUARIOS(idUsuario)
);

CREATE TABLE DETALLES_PRESTAMO (
    idDetallePrestamo  SERIAL  PRIMARY KEY,
    idPrestamo         INT     NOT NULL REFERENCES PRESTAMOS(idPrestamo),
    idEdicionVolumen   INT     NOT NULL REFERENCES EDICION_VOLUMEN(idEdicionVolumen),
    UNIQUE (idPrestamo, idEdicionVolumen)
);

CREATE TABLE DEVOLUCIONES (
    idDevolucion     SERIAL        PRIMARY KEY,
    fechaDevolucion  DATE          NOT NULL DEFAULT CURRENT_DATE,
    estadoEntrega    VARCHAR(50),
    idEdicionVolumen INT           NOT NULL REFERENCES EDICION_VOLUMEN(idEdicionVolumen)
);

CREATE TABLE RESERVAS (
    idReserva        SERIAL        PRIMARY KEY,
    fechaReserva     DATE          NOT NULL DEFAULT CURRENT_DATE,
    estadoReserva    VARCHAR(50),
    idUsuario        INT           NOT NULL REFERENCES USUARIOS(idUsuario),
    idEdicionVolumen INT           NOT NULL REFERENCES EDICION_VOLUMEN(idEdicionVolumen)
);

CREATE TABLE HISTORIAL_PRESTAMOS (
    idHistorial      SERIAL  PRIMARY KEY,
    idUsuario        INT     NOT NULL REFERENCES USUARIOS(idUsuario),
    idEdicionVolumen INT     NOT NULL REFERENCES EDICION_VOLUMEN(idEdicionVolumen),
    fechaPrestamo    DATE    NOT NULL,
    fechaDevolucion  DATE
);


-- ============================================================
--  MÓDULO 4: VENTAS
-- ============================================================

CREATE TABLE ROLES_EMPLEADO (
    idRol        SERIAL        PRIMARY KEY,
    nombreRol    VARCHAR(80)   NOT NULL,
    descripcion  TEXT
);

CREATE TABLE TURNOS (
    idTurno      SERIAL       PRIMARY KEY,
    nombreTurno  VARCHAR(80)  NOT NULL,
    horaInicio   TIME         NOT NULL,
    horaFin      TIME         NOT NULL
);

CREATE TABLE EMPLEADOS (
    idEmpleado         SERIAL        PRIMARY KEY,
    fechaContratacion  DATE,
    idPersona          INT           NOT NULL UNIQUE REFERENCES PERSONA(idPersona),
    idRol              INT           NOT NULL REFERENCES ROLES_EMPLEADO(idRol),
    idTurno            INT           REFERENCES TURNOS(idTurno)
);

CREATE TABLE PERMISOS (
    idPermiso       SERIAL        PRIMARY KEY,
    nombrePermiso   VARCHAR(100)  NOT NULL,
    descripcion     TEXT
);

CREATE TABLE ROL_PERMISO (
    idRolPermiso  SERIAL  PRIMARY KEY,
    idRol         INT     NOT NULL REFERENCES ROLES_EMPLEADO(idRol),
    idPermiso     INT     NOT NULL REFERENCES PERMISOS(idPermiso),
    UNIQUE (idRol, idPermiso)
);

CREATE TABLE PRODUCTOS_VENTA (
    idProducto       SERIAL          PRIMARY KEY,
    nombre           VARCHAR(150)    NOT NULL,
    descripcion      TEXT,
    precio           NUMERIC(10,2)   NOT NULL,
    stockDisponible  INT             NOT NULL DEFAULT 0
);

CREATE TABLE VENTAS (
    idVenta     SERIAL          PRIMARY KEY,
    fechaVenta  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idUsuario   INT             REFERENCES USUARIOS(idUsuario),
    idEmpleado  INT             NOT NULL REFERENCES EMPLEADOS(idEmpleado),
    total       NUMERIC(10,2)   NOT NULL
);

CREATE TABLE DETALLES_VENTA (
    idDetalleVenta  SERIAL          PRIMARY KEY,
    idVenta         INT             NOT NULL REFERENCES VENTAS(idVenta),
    idProducto      INT             NOT NULL REFERENCES PRODUCTOS_VENTA(idProducto),
    cantidad        INT             NOT NULL,
    precioUnitario  NUMERIC(10,2)   NOT NULL,
    subtotal        NUMERIC(10,2)   NOT NULL
);

CREATE TABLE METODOS_PAGO (
    idMetodoPago   SERIAL        PRIMARY KEY,
    nombreMetodo   VARCHAR(80)   NOT NULL
);

CREATE TABLE PAGOS_VENTAS (
    idPagoVenta   SERIAL          PRIMARY KEY,
    idVenta       INT             NOT NULL REFERENCES VENTAS(idVenta),
    idMetodoPago  INT             NOT NULL REFERENCES METODOS_PAGO(idMetodoPago),
    monto         NUMERIC(10,2)   NOT NULL
);


-- ============================================================
--  MÓDULO 5: PROVEEDORES Y PRESUPUESTOS
-- ============================================================

CREATE TABLE PROVEEDORES (
    idProveedor     SERIAL        PRIMARY KEY,
    nombreEmpresa   VARCHAR(150)  NOT NULL,
    contacto        VARCHAR(100),
    telefono        VARCHAR(20),
    correo          VARCHAR(150)
);

CREATE TABLE PRESUPUESTOS (
    idPresupuesto  SERIAL          PRIMARY KEY,
    anio           INT             NOT NULL,
    montoAsignado  NUMERIC(12,2)   NOT NULL
);

CREATE TABLE ORDENES_COMPRA (
    idOrdenCompra  SERIAL          PRIMARY KEY,
    fechaOrden     DATE            NOT NULL DEFAULT CURRENT_DATE,
    totalOrden     NUMERIC(12,2)   NOT NULL,
    idProveedor    INT             NOT NULL REFERENCES PROVEEDORES(idProveedor),
    idPresupuesto  INT             REFERENCES PRESUPUESTOS(idPresupuesto)
);

CREATE TABLE DETALLES_ORDEN (
    idDetalleOrden  SERIAL          PRIMARY KEY,
    idOrdenCompra   INT             NOT NULL REFERENCES ORDENES_COMPRA(idOrdenCompra),
    cantidad        INT             NOT NULL,
    precioUnitario  NUMERIC(10,2)   NOT NULL
);


-- ============================================================
--  MÓDULO 6: RECURSOS DIGITALES
-- ============================================================

CREATE TABLE RECURSOS_DIGITALES (
    idRecurso      SERIAL        PRIMARY KEY,
    titulo         VARCHAR(255)  NOT NULL,
    tipoRecurso    VARCHAR(80),
    formato        VARCHAR(50),
    urlAcceso      TEXT
);

CREATE TABLE DESCARGAS_ACCESOS (
    idDescarga   SERIAL       PRIMARY KEY,
    fechaAcceso  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipoAccion   VARCHAR(50),
    idUsuario    INT          NOT NULL REFERENCES USUARIOS(idUsuario),
    idRecurso    INT          NOT NULL REFERENCES RECURSOS_DIGITALES(idRecurso)
);

CREATE TABLE DISPOSITIVOS_PRESTADOS (
    idDispositivo     SERIAL        PRIMARY KEY,
    nombreDispositivo VARCHAR(100)  NOT NULL,
    tipoDispositivo   VARCHAR(80),
    numeroSerie       VARCHAR(80)   UNIQUE,
    estado            VARCHAR(50)
);


-- ============================================================
--  MÓDULO 7: EVENTOS
-- ============================================================

CREATE TABLE EVENTOS (
    idEvento        SERIAL        PRIMARY KEY,
    nombreEvento    VARCHAR(150)  NOT NULL,
    descripcion     TEXT,
    fechaEvento     DATE          NOT NULL,
    capacidadMaxima INT,
    lugar           VARCHAR(150)
);

CREATE TABLE ASISTENCIAS_EVENTOS (
    idAsistencia   SERIAL       PRIMARY KEY,
    idEvento       INT          NOT NULL REFERENCES EVENTOS(idEvento),
    idUsuario      INT          NOT NULL REFERENCES USUARIOS(idUsuario),
    fechaRegistro  DATE         NOT NULL DEFAULT CURRENT_DATE,
    asistencia     VARCHAR(20),
    UNIQUE (idEvento, idUsuario)
);