-- Database: clinica_odontologica

-- DROP DATABASE IF EXISTS clinica_odontologica;

CREATE DATABASE clinica_odontologica
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Spain.1252'
    LC_CTYPE = 'Spanish_Spain.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

--\c clinica_odontologica

-- Table: public.especialidad

CREATE TABLE IF NOT EXISTS public.especialidad
(
    id_especialidad SERIAL,
    nombre character varying(50) COLLATE pg_catalog."default" NOT NULL,
    descripcion text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad),
    CONSTRAINT especialidad_nombre_key UNIQUE (nombre)
);

-- Table: public.odontologo

CREATE TABLE IF NOT EXISTS public.odontologo
(
    id_odontologo SERIAL,
    cedula character(10) COLLATE pg_catalog."default" NOT NULL,
    nombres character varying(100) COLLATE pg_catalog."default" NOT NULL,
    apellidos character varying(100) COLLATE pg_catalog."default" NOT NULL,
    id_especialidad integer NOT NULL,
    telefono character varying(15) COLLATE pg_catalog."default",
    email character varying(150) COLLATE pg_catalog."default" NOT NULL,
    horario_inicio time without time zone NOT NULL,
    horario_fin time without time zone NOT NULL,
    activo boolean NOT NULL,
    CONSTRAINT odontologo_pkey PRIMARY KEY (id_odontologo),
    CONSTRAINT odontologo_id_especialidad_fkey FOREIGN KEY (id_especialidad)
        REFERENCES public.especialidad (id_especialidad) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Table: public.estado_cita

CREATE TABLE IF NOT EXISTS public.estado_cita
(
    id_estado_cita SERIAL,
    nombre character varying(30) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT estado_cita_pkey PRIMARY KEY (id_estado_cita)
);

-- Table: public.grupo_sanguineo

CREATE TABLE IF NOT EXISTS public.grupo_sanguineo
(
    id_grupo_sanguineo SERIAL,
    nombre character varying(3) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT grupo_sanguineo_pkey PRIMARY KEY (id_grupo_sanguineo)
);

-- Table: public.paciente

CREATE TABLE IF NOT EXISTS public.paciente
(
    id_paciente SERIAL,
    cedula character(10) COLLATE pg_catalog."default" NOT NULL,
    nombres character varying(100) COLLATE pg_catalog."default" NOT NULL,
    apellidos character varying(100) COLLATE pg_catalog."default" NOT NULL,
    fecha_nac date,
    sexo character(1) COLLATE pg_catalog."default",
    telefono character varying(15) COLLATE pg_catalog."default",
    email character varying(150) COLLATE pg_catalog."default",
    direccion text COLLATE pg_catalog."default",
    fecha_registro timestamp without time zone NOT NULL,
    activo boolean NOT NULL,
    id_grupo_sanguineo integer,
    CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente),
    CONSTRAINT paciente_id_grupo_sanguineo_fkey FOREIGN KEY (id_grupo_sanguineo)
        REFERENCES public.grupo_sanguineo (id_grupo_sanguineo) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_cedula UNIQUE (cedula),
    CONSTRAINT uq_email UNIQUE (email)
);

-- Table: public.cita

CREATE TABLE IF NOT EXISTS public.cita
(
    id_cita SERIAL,
    id_paciente integer NOT NULL,
    id_odontologo integer NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    duracion_min smallint NOT NULL,
    motivo character varying(255) COLLATE pg_catalog."default",
    id_estado_cita integer NOT NULL,
    canal_agendamiento character varying(30) COLLATE pg_catalog."default",
    observaciones text COLLATE pg_catalog."default",
    fecha_registro timestamp without time zone NOT NULL,
    diagnostico text COLLATE pg_catalog."default" NOT NULL,
    indicaciones text COLLATE pg_catalog."default",
    proxima_cita timestamp without time zone,
    CONSTRAINT cita_pkey PRIMARY KEY (id_cita),
    CONSTRAINT cita_id_estado_cita_fkey FOREIGN KEY (id_estado_cita)
        REFERENCES public.estado_cita (id_estado_cita) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT cita_id_odontologo_fkey FOREIGN KEY (id_odontologo)
        REFERENCES public.odontologo (id_odontologo) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT cita_id_paciente_fkey FOREIGN KEY (id_paciente)
        REFERENCES public.paciente (id_paciente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Table: public.insumo

CREATE TABLE IF NOT EXISTS public.insumo
(
    id_insumo SERIAL,
    codigo character varying(30) COLLATE pg_catalog."default" NOT NULL,
    nombre character varying(150) COLLATE pg_catalog."default" NOT NULL,
    unidad_medida character varying(20) COLLATE pg_catalog."default" NOT NULL,
    stock_actual numeric(10,2) NOT NULL,
    stock_minimo numeric(10,2) NOT NULL,
    precio_unitario numeric(10,2),
    activo boolean NOT NULL,
    CONSTRAINT insumo_pkey PRIMARY KEY (id_insumo)
);

-- Table: public.tratamiento

CREATE TABLE IF NOT EXISTS public.tratamiento
(
    id_tratamiento SERIAL,
    nombre character varying(150) COLLATE pg_catalog."default" NOT NULL,
    descripcion text COLLATE pg_catalog."default",
    precio_base numeric(10,2) NOT NULL,
    duracion_estimada_min smallint,
    categoria character varying(80) COLLATE pg_catalog."default",
    activo boolean NOT NULL,
    CONSTRAINT tratamiento_pkey PRIMARY KEY (id_tratamiento)
);

-- Table: public.pieza_dental

CREATE TABLE IF NOT EXISTS public.pieza_dental
(
    id_pieza_dental SERIAL,
    codigo character varying(2) COLLATE pg_catalog."default" NOT NULL,
    nombre character varying(100) COLLATE pg_catalog."default" NOT NULL,
    cuadrante character varying(30) COLLATE pg_catalog."default" NOT NULL,
    tipo_denticion character varying(15) COLLATE pg_catalog."default" NOT NULL,
    estado boolean NOT NULL,
    CONSTRAINT pieza_dental_pkey PRIMARY KEY (id_pieza_dental),
    CONSTRAINT pieza_dental_codigo_key UNIQUE (codigo)
);

-- Table: public.detalle_consulta_tratamiento

CREATE TABLE IF NOT EXISTS public.detalle_consulta_tratamiento
(
    id_detalle_consulta_tratamiento SERIAL,
    id_cita integer NOT NULL,
    id_tratamiento integer NOT NULL,
    id_pieza_dental integer NOT NULL,
    cantidad integer NOT NULL,
    precio numeric(10,2) NOT NULL,
    observaciones character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT detalle_consulta_tratamiento_pkey PRIMARY KEY (id_detalle_consulta_tratamiento),
    CONSTRAINT detalle_consulta_tratamiento_id_cita_fkey FOREIGN KEY (id_cita)
        REFERENCES public.cita (id_cita) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT detalle_consulta_tratamiento_id_pieza_dental_fkey FOREIGN KEY (id_pieza_dental)
        REFERENCES public.pieza_dental (id_pieza_dental) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT detalle_consulta_tratamiento_id_tratamiento_fkey FOREIGN KEY (id_tratamiento)
        REFERENCES public.tratamiento (id_tratamiento) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Table: public.detalle_consulta_insumo

CREATE TABLE IF NOT EXISTS public.detalle_consulta_insumo
(
    id_detalle_consulta_insumo SERIAL,
    id_detalle_consulta_tratamiento integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad_utilizada numeric(10,2) NOT NULL,
    CONSTRAINT detalle_consulta_insumo_pkey PRIMARY KEY (id_detalle_consulta_insumo),
    CONSTRAINT detalle_consulta_insumo_id_detalle_consulta_tratamiento_fkey FOREIGN KEY (id_detalle_consulta_tratamiento)
        REFERENCES public.detalle_consulta_tratamiento (id_detalle_consulta_tratamiento) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT detalle_consulta_insumo_id_insumo_fkey FOREIGN KEY (id_insumo)
        REFERENCES public.insumo (id_insumo) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT detalle_consulta_insumo_id_detalle_consulta_tratamiento_id__key UNIQUE (id_detalle_consulta_tratamiento, id_insumo)
);

-- Table: public.usuario

CREATE TABLE IF NOT EXISTS public.usuario
(
    id_usuario SERIAL,
    nombre_usuario character varying(50) COLLATE pg_catalog."default" NOT NULL,
    password_hash character varying(255) COLLATE pg_catalog."default" NOT NULL,
    nombres character varying(100) COLLATE pg_catalog."default" NOT NULL,
    apellidos character varying(100) COLLATE pg_catalog."default" NOT NULL,
    rol character varying(20) COLLATE pg_catalog."default" NOT NULL,
    email character varying(150) COLLATE pg_catalog."default" NOT NULL,
    ultimo_acceso timestamp without time zone,
    activo boolean NOT NULL,
    CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario)
);

-- Table: public.metodo_pago

CREATE TABLE IF NOT EXISTS public.metodo_pago
(
    id_metodo_pago SERIAL,
    nombre character varying(50) COLLATE pg_catalog."default" NOT NULL,
    descripcion text COLLATE pg_catalog."default" NOT NULL,
    estado boolean NOT NULL,
    CONSTRAINT metodo_pago_pkey PRIMARY KEY (id_metodo_pago),
    CONSTRAINT metodo_pago_nombre_key UNIQUE (nombre)
);

-- Table: public.estado_factura

CREATE TABLE IF NOT EXISTS public.estado_factura
(
    id_estado_factura SERIAL,
    nombre character varying(30) COLLATE pg_catalog."default" NOT NULL,
    descripcion text COLLATE pg_catalog."default" NOT NULL,
    estado boolean NOT NULL,
    CONSTRAINT estado_factura_pkey PRIMARY KEY (id_estado_factura),
    CONSTRAINT estado_factura_nombre_key UNIQUE (nombre)
);

-- Table: public.factura

CREATE TABLE IF NOT EXISTS public.factura
(
    id_factura SERIAL,
    id_paciente integer NOT NULL,
    id_metodo_pago integer NOT NULL,
    id_usuario integer NOT NULL,
    numero_factura character varying(17) COLLATE pg_catalog."default" NOT NULL,
    fecha_emision date NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    iva numeric(10,2) NOT NULL,
    descuento numeric(10,2) NOT NULL,
    total numeric(10,2) NOT NULL,
    clave_acceso character varying(49) COLLATE pg_catalog."default" NOT NULL,
    numero_autorizacion character varying(60) COLLATE pg_catalog."default" NOT NULL,
    fecha_autorizacion timestamp without time zone NOT NULL,
    ambiente character varying(15) COLLATE pg_catalog."default" NOT NULL,
    tipo_emision character varying(20) COLLATE pg_catalog."default" NOT NULL,
    id_estado_factura integer NOT NULL,
    observaciones text COLLATE pg_catalog."default",
    CONSTRAINT factura_pkey PRIMARY KEY (id_factura),
    CONSTRAINT factura_id_estado_factura_fkey FOREIGN KEY (id_estado_factura)
        REFERENCES public.estado_factura (id_estado_factura) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT factura_id_metodo_pago_fkey FOREIGN KEY (id_metodo_pago)
        REFERENCES public.metodo_pago (id_metodo_pago) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT factura_id_paciente_fkey FOREIGN KEY (id_paciente)
        REFERENCES public.paciente (id_paciente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT factura_id_usuario_fkey FOREIGN KEY (id_usuario)
        REFERENCES public.usuario (id_usuario) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT factura_clave_acceso_key UNIQUE (clave_acceso),
    CONSTRAINT factura_numero_factura_key UNIQUE (numero_factura),
    CONSTRAINT chk_factura_total_positivo CHECK ((total >= (0)::numeric))
);

-- Table: public.producto_servicio

CREATE TABLE IF NOT EXISTS public.producto_servicio
(
    id_producto_servicio SERIAL,
    nombre character varying(100) COLLATE pg_catalog."default" NOT NULL,
    tipo character varying(100) COLLATE pg_catalog."default" NOT NULL,
    precio numeric(10,2) NOT NULL,
    stock integer NOT NULL,
    descripcion text COLLATE pg_catalog."default" NOT NULL,
    estado character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT producto_servicio_pkey PRIMARY KEY (id_producto_servicio)
);

-- Table: public.detalle_factura

CREATE TABLE IF NOT EXISTS public.detalle_factura
(
    id_detalle_factura SERIAL,
    id_factura integer NOT NULL,
    tipo_item character varying(20) COLLATE pg_catalog."default" NOT NULL,
    id_producto_servicio integer,
    id_detalle_consulta integer,
    cantidad integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    descuento numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    descripcion text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT detalle_factura_pkey PRIMARY KEY (id_detalle_factura),
    CONSTRAINT detalle_factura_id_detalle_consulta_fkey FOREIGN KEY (id_detalle_consulta)
        REFERENCES public.detalle_consulta_tratamiento (id_detalle_consulta_tratamiento) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT detalle_factura_id_factura_fkey FOREIGN KEY (id_factura)
        REFERENCES public.factura (id_factura) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT detalle_factura_id_producto_servicio_fkey FOREIGN KEY (id_producto_servicio)
        REFERENCES public.producto_servicio (id_producto_servicio) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_detalle_factura_tipo_item CHECK (((((tipo_item)::text = 'PRODUCTO_SERVICIO'::text) AND (id_producto_servicio IS NOT NULL) AND (id_detalle_consulta IS NULL)) OR (((tipo_item)::text = 'TRATAMIENTO'::text) AND (id_detalle_consulta IS NOT NULL) AND (id_producto_servicio IS NULL))))
);

-- Table: public.proveedor

CREATE TABLE IF NOT EXISTS public.proveedor
(
    id_proveedor SERIAL,
    ruc character(13) COLLATE pg_catalog."default" NOT NULL,
    nombre_empresa character varying(150) COLLATE pg_catalog."default" NOT NULL,
    contacto character varying(100) COLLATE pg_catalog."default",
    telefono character varying(15) COLLATE pg_catalog."default",
    email character varying(150) COLLATE pg_catalog."default",
    direccion text COLLATE pg_catalog."default",
    activo boolean NOT NULL,
    CONSTRAINT proveedor_pkey PRIMARY KEY (id_proveedor)
);

-- Table: public.orden_compra

CREATE TABLE IF NOT EXISTS public.orden_compra
(
    id_orden SERIAL,
    id_proveedor integer NOT NULL,
    id_usuario integer NOT NULL,
    fecha_orden date NOT NULL,
    fecha_entrega date,
    estado character varying(20) COLLATE pg_catalog."default" NOT NULL,
    total numeric(10,2),
    observaciones text COLLATE pg_catalog."default",
    solicitado_por integer,
    CONSTRAINT orden_compra_pkey PRIMARY KEY (id_orden),
    CONSTRAINT orden_compra_id_proveedor_fkey FOREIGN KEY (id_proveedor)
        REFERENCES public.proveedor (id_proveedor) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT orden_compra_id_usuario_fkey FOREIGN KEY (id_usuario)
        REFERENCES public.usuario (id_usuario) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT orden_compra_solicitado_por_fkey FOREIGN KEY (solicitado_por)
        REFERENCES public.usuario (id_usuario) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Table: public.detalle_orden_compra

CREATE TABLE IF NOT EXISTS public.detalle_orden_compra
(
    id_detalle_orden_compra SERIAL,
    id_orden integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad numeric(10,2) NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    CONSTRAINT detalle_orden_compra_pkey PRIMARY KEY (id_detalle_orden_compra),
    CONSTRAINT detalle_orden_compra_id_insumo_fkey FOREIGN KEY (id_insumo)
        REFERENCES public.insumo (id_insumo) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT detalle_orden_compra_id_orden_fkey FOREIGN KEY (id_orden)
        REFERENCES public.orden_compra (id_orden) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Table: public.historial_clinico

CREATE TABLE IF NOT EXISTS public.historial_clinico
(
    id_historial_clinico SERIAL,
    id_paciente integer NOT NULL,
    antecedentes text COLLATE pg_catalog."default",
    medicamentos text COLLATE pg_catalog."default",
    observacion_general text COLLATE pg_catalog."default",
    fecha_apertura date NOT NULL,
    ultima_actualizacion timestamp without time zone NOT NULL,
    CONSTRAINT historial_clinico_pkey PRIMARY KEY (id_historial_clinico),
    CONSTRAINT historial_clinico_id_paciente_fkey FOREIGN KEY (id_paciente)
        REFERENCES public.paciente (id_paciente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Table: public.tipo_alergia

CREATE TABLE IF NOT EXISTS public.tipo_alergia
(
    id_tipo_alergia SERIAL,
    nombre character varying(100) COLLATE pg_catalog."default" NOT NULL,
    descripcion text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tipo_alergia_pkey PRIMARY KEY (id_tipo_alergia)
);

-- Table: public.historial_alergia

CREATE TABLE IF NOT EXISTS public.historial_alergia
(
    id_historial_alergia SERIAL,
    id_historial_clinico integer NOT NULL,
    id_tipo_alergia integer NOT NULL,
    observaciones text COLLATE pg_catalog."default" NOT NULL,
    fecha_registro date NOT NULL,
    CONSTRAINT historial_alergia_pkey PRIMARY KEY (id_historial_alergia),
    CONSTRAINT historial_alergia_id_historial_clinico_fkey FOREIGN KEY (id_historial_clinico)
        REFERENCES public.historial_clinico (id_historial_clinico) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT historial_alergia_id_tipo_alergia_fkey FOREIGN KEY (id_tipo_alergia)
        REFERENCES public.tipo_alergia (id_tipo_alergia) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Table: public.insumo_proveedor

CREATE TABLE IF NOT EXISTS public.insumo_proveedor
(
    id_insumo_proveedor SERIAL,
    id_insumo integer NOT NULL,
    id_proveedor integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    activo boolean NOT NULL,
    CONSTRAINT insumo_proveedor_pkey PRIMARY KEY (id_insumo_proveedor),
    CONSTRAINT insumo_proveedor_id_insumo_fkey FOREIGN KEY (id_insumo)
        REFERENCES public.insumo (id_insumo) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT insumo_proveedor_id_proveedor_fkey FOREIGN KEY (id_proveedor)
        REFERENCES public.proveedor (id_proveedor) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT insumo_proveedor_id_insumo_id_proveedor_key UNIQUE (id_insumo, id_proveedor)
);

-- Table: public.movimiento_inventario

CREATE TABLE IF NOT EXISTS public.movimiento_inventario
(
    id_movimiento SERIAL,
    id_insumo integer NOT NULL,
    tipo character varying(20) COLLATE pg_catalog."default" NOT NULL,
    cantidad numeric(10,2) NOT NULL,
    motivo character varying(20) COLLATE pg_catalog."default",
    id_orden integer,
    fecha_movimiento timestamp without time zone NOT NULL,
    registrado_por integer,
    CONSTRAINT movimiento_inventario_pkey PRIMARY KEY (id_movimiento),
    CONSTRAINT movimiento_inventario_id_insumo_fkey FOREIGN KEY (id_insumo)
        REFERENCES public.insumo (id_insumo) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT movimiento_inventario_id_orden_fkey FOREIGN KEY (id_orden)
        REFERENCES public.orden_compra (id_orden) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT movimiento_inventario_registrado_por_fkey FOREIGN KEY (registrado_por)
        REFERENCES public.usuario (id_usuario) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Table: public.pago

CREATE TABLE IF NOT EXISTS public.pago
(
    id_pago SERIAL,
    id_factura integer NOT NULL,
    monto numeric(10,2) NOT NULL,
    id_metodo_pago integer NOT NULL,
    CONSTRAINT pago_pkey PRIMARY KEY (id_pago),
    CONSTRAINT pago_id_factura_fkey FOREIGN KEY (id_factura)
        REFERENCES public.factura (id_factura) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT pago_id_metodo_pago_fkey FOREIGN KEY (id_metodo_pago)
        REFERENCES public.metodo_pago (id_metodo_pago) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_pago_monto_positivo CHECK ((monto > (0)::numeric))
);

-- Table: public.reclamo_cliente

CREATE TABLE IF NOT EXISTS public.reclamo_cliente
(
    id_reclamo SERIAL,
    id_paciente integer NOT NULL,
    tipo character varying(20) COLLATE pg_catalog."default" NOT NULL,
    canal character varying(30) COLLATE pg_catalog."default" NOT NULL,
    descripcion text COLLATE pg_catalog."default" NOT NULL,
    estado character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT reclamo_cliente_pkey PRIMARY KEY (id_reclamo),
    CONSTRAINT reclamo_cliente_id_paciente_fkey FOREIGN KEY (id_paciente)
        REFERENCES public.paciente (id_paciente) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

INSERT INTO especialidad (nombre,descripcion) VALUES ('Odontología General', 'Atención dental integral y preventiva');
INSERT INTO especialidad (nombre,descripcion) VALUES ('Ortodoncia', 'Corrección de la posición dental y maxilar');
INSERT INTO especialidad (nombre,descripcion) VALUES ('Endodoncia', 'Tratamiento de conductos radiculares');
INSERT INTO especialidad (nombre,descripcion) VALUES ('Periodoncia', 'Tratamiento de encías y tejido de soporte dental');
INSERT INTO especialidad (nombre,descripcion) VALUES ('Odontopediatría', 'Atención odontológica especializada en niños');
INSERT INTO estado_cita (nombre) VALUES ('Programada');
INSERT INTO estado_cita (nombre) VALUES ('Confirmada');
INSERT INTO estado_cita (nombre) VALUES ('Completada');
INSERT INTO estado_cita (nombre) VALUES ('Cancelada');
INSERT INTO estado_cita (nombre) VALUES ('No asistió');
INSERT INTO grupo_sanguineo (nombre) VALUES ('O+');
INSERT INTO grupo_sanguineo (nombre) VALUES ('O-');
INSERT INTO grupo_sanguineo (nombre) VALUES ('A+');
INSERT INTO grupo_sanguineo (nombre) VALUES ('A-');
INSERT INTO grupo_sanguineo (nombre) VALUES ('B+');
INSERT INTO grupo_sanguineo (nombre) VALUES ('B-');
INSERT INTO grupo_sanguineo (nombre) VALUES ('AB+');
INSERT INTO grupo_sanguineo (nombre) VALUES ('AB-');
INSERT INTO estado_factura (nombre,descripcion,estado) VALUES ('Emitida', 'Factura generada y entregada al paciente', true);
INSERT INTO estado_factura (nombre,descripcion,estado) VALUES ('Pagada', 'Factura totalmente cancelada', true);
INSERT INTO estado_factura (nombre,descripcion,estado) VALUES ('Anulada', 'Factura anulada por error o solicitud del cliente', true);
INSERT INTO metodo_pago (nombre,descripcion,estado) VALUES ('Efectivo', 'Pago en efectivo en ventanilla', true);
INSERT INTO metodo_pago (nombre,descripcion,estado) VALUES ('Tarjeta de crédito', 'Pago con tarjeta de crédito', true);
INSERT INTO metodo_pago (nombre,descripcion,estado) VALUES ('Tarjeta de débito', 'Pago con tarjeta de débito', true);
INSERT INTO metodo_pago (nombre,descripcion,estado) VALUES ('Transferencia', 'Transferencia bancaria directa', true);
INSERT INTO tipo_alergia (nombre,descripcion) VALUES ('Penicilina', 'Alergia a antibióticos betalactámicos');
INSERT INTO tipo_alergia (nombre,descripcion) VALUES ('Látex', 'Alergia al contacto con látex (guantes, diques)');
INSERT INTO tipo_alergia (nombre,descripcion) VALUES ('Anestésicos locales', 'Alergia a lidocaína u otros anestésicos');
INSERT INTO tipo_alergia (nombre,descripcion) VALUES ('AINES', 'Alergia a antiinflamatorios no esteroideos');
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1686579303', 'Esperanza', 'Gelabert Quesada', 1, '0913356886', 'esperanza.gelabert@clinicaodontologica.com', '09:00:00', '17:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1239670711', 'Segismundo', 'Lucena Roca', 2, '0923756669', 'segismundo.lucena@clinicaodontologica.com', '08:00:00', '18:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1034126396', 'Mauricio', 'Aragonés Artigas', 1, '0922575562', 'mauricio.aragonés@clinicaodontologica.com', '08:00:00', '17:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1542621108', 'María Cristina', 'Pascual Alarcón', 5, '0913561597', 'maría cristina.pascual@clinicaodontologica.com', '08:00:00', '18:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1236696312', 'Poncio', 'Lago Guijarro', 4, '0989089901', 'poncio.lago@clinicaodontologica.com', '09:00:00', '17:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1814763202', 'Severiano', 'Medina Pont', 2, '0966722344', 'severiano.medina@clinicaodontologica.com', '09:00:00', '18:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1166944844', 'Maximiliano', 'Lumbreras Díaz', 2, '0955176955', 'maximiliano.lumbreras@clinicaodontologica.com', '08:00:00', '17:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1407943839', 'Bruno', 'Gomis Barrera', 1, '0958181396', 'bruno.gomis@clinicaodontologica.com', '09:00:00', '18:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1866647391', 'Samanta', 'Pinto Aller', 1, '0971662963', 'samanta.pinto@clinicaodontologica.com', '08:00:00', '18:00:00', true);
INSERT INTO odontologo (cedula,nombres,apellidos,id_especialidad,telefono,email,horario_inicio,horario_fin,activo) VALUES ('1084611066', 'Vidal', 'Iborra Robledo', 5, '0949349722', 'vidal.iborra@clinicaodontologica.com', '09:00:00', '17:00:00', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('11', 'Incisivo central', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('12', 'Incisivo lateral', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('13', 'Canino', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('14', 'Primer premolar', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('15', 'Segundo premolar', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('16', 'Primer molar', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('17', 'Segundo molar', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('18', 'Tercer molar', 'Superior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('21', 'Incisivo central', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('22', 'Incisivo lateral', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('23', 'Canino', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('24', 'Primer premolar', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('25', 'Segundo premolar', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('26', 'Primer molar', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('27', 'Segundo molar', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('28', 'Tercer molar', 'Superior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('31', 'Incisivo central', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('32', 'Incisivo lateral', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('33', 'Canino', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('34', 'Primer premolar', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('35', 'Segundo premolar', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('36', 'Primer molar', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('37', 'Segundo molar', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('38', 'Tercer molar', 'Inferior izquierdo', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('41', 'Incisivo central', 'Inferior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('42', 'Incisivo lateral', 'Inferior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('43', 'Canino', 'Inferior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('44', 'Primer premolar', 'Inferior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('45', 'Segundo premolar', 'Inferior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('46', 'Primer molar', 'Inferior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('47', 'Segundo molar', 'Inferior derecho', 'Permanente', true);
INSERT INTO pieza_dental (codigo,nombre,cuadrante,tipo_denticion,estado) VALUES ('48', 'Tercer molar', 'Inferior derecho', 'Permanente', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Limpieza dental', 'Profilaxis dental', 25.0, 30, 'Preventivo', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Blanqueamiento dental', 'Blanqueamiento con luz LED', 80.0, 60, 'Estético', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Extracción simple', 'Extracción de pieza dental sin complicaciones', 40.0, 30, 'Cirugía', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Extracción quirúrgica', 'Extracción de piezas retenidas o impactadas', 90.0, 60, 'Cirugía', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Endodoncia', 'Tratamiento de conducto radicular', 120.0, 90, 'Endodoncia', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Corona de porcelana', 'Colocación de corona de porcelana', 250.0, 60, 'Rehabilitación', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Corona de metal-porcelana', 'Colocación de corona metal-porcelana', 200.0, 60, 'Rehabilitación', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Curetaje periodontal', 'Limpieza profunda subgingival', 60.0, 45, 'Periodoncia', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Radiografía panorámica', 'Toma de radiografía panorámica', 22.0, 15, 'Diagnóstico', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Radiografía periapical', 'Toma de radiografía periapical', 12.0, 10, 'Diagnóstico', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Sellante dental', 'Aplicación de sellante de fosas y fisuras', 18.0, 20, 'Preventivo', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Aplicación de flúor', 'Aplicación tópica de flúor', 15.0, 15, 'Preventivo', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Resina compuesta simple', 'Restauración con resina, una superficie', 35.0, 30, 'Restaurador', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Resina compuesta compleja', 'Restauración con resina, varias superficies', 55.0, 45, 'Restaurador', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Ortodoncia - control mensual', 'Control mensual de brackets', 30.0, 20, 'Ortodoncia', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Ortodoncia - instalación', 'Instalación de brackets metálicos', 350.0, 90, 'Ortodoncia', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Placa de contención', 'Fabricación de placa de contención', 60.0, 30, 'Ortodoncia', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Implante dental', 'Colocación de implante osteointegrado', 600.0, 120, 'Cirugía', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Injerto óseo', 'Injerto óseo previo a implante', 300.0, 90, 'Cirugía', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Profilaxis infantil', 'Limpieza dental para niños', 20.0, 25, 'Odontopediatría', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Pulpotomía', 'Tratamiento pulpar en dientes temporales', 45.0, 40, 'Odontopediatría', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Mantenedor de espacio', 'Colocación de mantenedor de espacio', 70.0, 40, 'Odontopediatría', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Consulta de valoración', 'Diagnóstico y plan de tratamiento inicial', 15.0, 20, 'Diagnóstico', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Retiro de puntos', 'Retiro de puntos de sutura', 10.0, 10, 'Cirugía', true);
INSERT INTO tratamiento (nombre,descripcion,precio_base,duracion_estimada_min,categoria,activo) VALUES ('Férula de descarga', 'Fabricación de férula para bruxismo', 90.0, 30, 'Rehabilitación', true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-001', 'Guantes de látex', 'unidad', 10.12, 10.7, 4.48, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-002', 'Mascarillas quirúrgicas', 'unidad', 171.21, 26.66, 5.83, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-003', 'Algodón dental', 'paquete', 127.5, 14.12, 5.68, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-004', 'Gasas estériles', 'caja', 134.36, 22.55, 10.32, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-005', 'Anestesia local (lidocaína)', 'unidad', 122.22, 9.28, 10.99, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-006', 'Resina compuesta A2', 'caja', 92.99, 11.75, 13.9, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-007', 'Resina compuesta A3', 'rollo', 44.7, 13.11, 11.57, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-008', 'Ácido grabador', 'unidad', 46.58, 5.8, 4.87, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-009', 'Adhesivo dental', 'frasco', 14.17, 27.83, 8.59, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-010', 'Amalgama dental', 'frasco', 43.31, 17.48, 13.29, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-011', 'Hilo de sutura', 'paquete', 29.43, 8.49, 11.23, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-012', 'Aguja dental', 'rollo', 53.29, 19.61, 13.49, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-013', 'Eyector de saliva', 'paquete', 73.04, 29.93, 2.25, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-014', 'Vasos desechables', 'paquete', 19.09, 6.18, 1.82, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-015', 'Baberos desechables', 'caja', 158.62, 15.55, 1.14, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-016', 'Flúor gel tópico', 'paquete', 119.58, 16.7, 3.92, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-017', 'Sellante de fosas y fisuras', 'rollo', 172.3, 5.29, 10.87, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-018', 'Alginato', 'rollo', 150.42, 24.21, 5.23, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-019', 'Yeso dental', 'frasco', 87.52, 16.34, 14.32, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-020', 'Cemento provisional', 'frasco', 194.41, 24.05, 7.71, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-021', 'Cemento definitivo', 'unidad', 174.23, 12.46, 9.66, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-022', 'Fresas de diamante', 'rollo', 40.58, 14.35, 2.59, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-023', 'Fresas de carburo', 'rollo', 183.78, 19.97, 7.43, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-024', 'Discos de pulido', 'unidad', 185.89, 26.97, 12.51, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-025', 'Puntas de papel absorbente', 'frasco', 48.65, 11.02, 8.6, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-026', 'Limas endodónticas', 'unidad', 18.05, 17.15, 1.22, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-027', 'Hipoclorito de sodio', 'rollo', 153.4, 8.21, 7.23, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-028', 'EDTA gel', 'rollo', 33.86, 18.19, 9.18, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-029', 'Conos de gutapercha', 'caja', 185.85, 23.88, 10.41, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-030', 'Cemento sellador endodóntico', 'frasco', 80.4, 21.79, 5.73, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-031', 'Brackets metálicos', 'rollo', 90.85, 11.2, 1.15, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-032', 'Arcos de ortodoncia', 'unidad', 118.07, 10.75, 3.46, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-033', 'Ligas elásticas', 'unidad', 141.86, 6.47, 1.2, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-034', 'Cera ortodóntica', 'unidad', 172.07, 6.77, 3.72, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-035', 'Placas de acetato', 'paquete', 43.63, 8.31, 14.05, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-036', 'Jeringa carpule', 'rollo', 115.67, 11.07, 7.2, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-037', 'Rollos de algodón', 'paquete', 38.89, 7.42, 6.58, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-038', 'Papel articular', 'paquete', 82.81, 26.6, 1.0, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-039', 'Vaselina labial', 'unidad', 13.06, 23.21, 12.05, true);
INSERT INTO insumo (codigo,nombre,unidad_medida,stock_actual,stock_minimo,precio_unitario,activo) VALUES ('INS-040', 'Solución para enjuague bucal', 'unidad', 50.48, 9.76, 6.84, true);
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Cepillo dental adulto', 'producto', 3.5, 27, 'Producto ofrecido por la clínica: cepillo dental adulto.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Cepillo dental infantil', 'producto', 3.0, 11, 'Producto ofrecido por la clínica: cepillo dental infantil.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Pasta dental fluorada', 'producto', 4.2, 17, 'Producto ofrecido por la clínica: pasta dental fluorada.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Hilo dental', 'producto', 2.5, 29, 'Producto ofrecido por la clínica: hilo dental.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Enjuague bucal', 'producto', 5.8, 15, 'Producto ofrecido por la clínica: enjuague bucal.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Cepillo interdental', 'producto', 2.8, 55, 'Producto ofrecido por la clínica: cepillo interdental.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Kit de higiene oral', 'producto', 9.9, 59, 'Producto ofrecido por la clínica: kit de higiene oral.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Protector bucal deportivo', 'producto', 15.0, 4, 'Producto ofrecido por la clínica: protector bucal deportivo.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Estuche ortodóntico de limpieza', 'producto', 6.5, 28, 'Producto ofrecido por la clínica: estuche ortodóntico de limpieza.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Gel desensibilizante', 'producto', 7.2, 51, 'Producto ofrecido por la clínica: gel desensibilizante.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Consulta de urgencia', 'servicio', 20.0, 0, 'Servicio ofrecido por la clínica: consulta de urgencia.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Certificado odontológico', 'servicio', 8.0, 0, 'Servicio ofrecido por la clínica: certificado odontológico.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Toma de impresión dental', 'servicio', 12.0, 0, 'Servicio ofrecido por la clínica: toma de impresión dental.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Pulido dental cosmético', 'servicio', 18.0, 0, 'Servicio ofrecido por la clínica: pulido dental cosmético.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Fluorización adicional', 'servicio', 10.0, 0, 'Servicio ofrecido por la clínica: fluorización adicional.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Asesoría nutricional dental', 'servicio', 15.0, 0, 'Servicio ofrecido por la clínica: asesoría nutricional dental.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Revisión ortodóntica extra', 'servicio', 12.0, 0, 'Servicio ofrecido por la clínica: revisión ortodóntica extra.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Sesión de blanqueamiento express', 'servicio', 45.0, 0, 'Servicio ofrecido por la clínica: sesión de blanqueamiento express.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Placa de relajación muscular', 'servicio', 55.0, 0, 'Servicio ofrecido por la clínica: placa de relajación muscular.', 'Activo');
INSERT INTO producto_servicio (nombre,tipo,precio,stock,descripcion,estado) VALUES ('Fotografía clínica intraoral', 'servicio', 10.0, 0, 'Servicio ofrecido por la clínica: fotografía clínica intraoral.', 'Activo');
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('dcortés', 'hash_5b6eef81d796283e4a9f', 'Dionisio', 'Cortés', 'admin', 'dcortés@clinicaodontologica.com', '2026-07-01 21:57:45.142793', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('tborrás', 'hash_baa7ee58add0e85ab8d8', 'Teobaldo', 'Borrás', 'admin', 'tborrás@clinicaodontologica.com', '2026-08-17 20:22:37.985131', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('tmorell', 'hash_a62e390b7c95daa45448', 'Tadeo', 'Morell', 'admin', 'tmorell@clinicaodontologica.com', '2026-08-27 21:03:27.961668', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('scatalán', 'hash_9b4c8f9dad0fd10b84bd', 'Sonia', 'Catalán', 'admin', 'scatalán@clinicaodontologica.com', '2026-08-27 06:07:17.157735', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('mtudela', 'hash_fa0ad8388ef570e151d1', 'Miguela', 'Tudela', 'recepcionista', 'mtudela@clinicaodontologica.com', '2026-08-13 08:09:56.739825', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('dacevedo', 'hash_94b8cea7ef6401a90e68', 'Daniel', 'Acevedo', 'recepcionista', 'dacevedo@clinicaodontologica.com', '2026-07-10 13:28:38.130006', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('aamador', 'hash_d98ae484365fab04a243', 'Andrés', 'Amador', 'odontologo', 'aamador@clinicaodontologica.com', '2026-08-05 08:56:40.317226', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('ósegarra', 'hash_4f9acaab9bc66f359138', 'Óscar', 'Segarra', 'odontologo', 'ósegarra@clinicaodontologica.com', '2026-08-09 09:08:51.561577', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('efernandez', 'hash_ee08321713d5768c2cd8', 'Elisa', 'Fernandez', 'odontologo', 'efernandez@clinicaodontologica.com', '2026-06-30 19:29:41.150333', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('váguila', 'hash_6cfa8e4785e8f46ce61d', 'Venceslás', 'Águila', 'recepcionista', 'váguila@clinicaodontologica.com', '2026-08-09 13:54:21.136941', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('lfabra', 'hash_5b40471d58ba8cf3e181', 'Lupe', 'Fabra', 'odontologo', 'lfabra@clinicaodontologica.com', '2026-08-26 12:31:14.632065', true);
INSERT INTO usuario (nombre_usuario,password_hash,nombres,apellidos,rol,email,ultimo_acceso,activo) VALUES ('gcañizares', 'hash_e27f86b101f5dba5199e', 'Gil', 'Cañizares', 'admin', 'gcañizares@clinicaodontologica.com', '2026-07-14 21:35:47.754934', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('6002078344001', 'Dental Supply Ecuador', 'Gastón Mariño Linares', '0910289289', 'emperatriz68@pineiro.org', 'Rambla de Olimpia Uría 72 Piso 9 , Badajoz, 29153', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('9526836552001', 'Odontomedic S.A.', 'Enrique Colomer Botella', '0945594951', 'guijarronoelia@familia.com', 'Plaza Valentina Palomar 666 Puerta 1 , Huelva, 18800', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('8667072205001', 'Insumos Dentales del Pacífico', 'Isidora Ros Arteaga', '0948285503', 'omartorrent@banca.es', 'Camino Belén Benavides 29 Piso 4 , Ceuta, 36707', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('8380507338001', 'BioDent Import', 'Encarnación del Romero', '0930776478', 'pascualmohamed@mineria.com', 'Calle Román Guzman 81, Sevilla, 24893', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('6110572428001', 'Prodenta Cía. Ltda.', 'Victoriano Carrasco Sanz', '0939219319', 'eutropio75@penas.es', 'Acceso Gastón Arroyo 81, Teruel, 32649', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('5160575046001', 'Suministros Clínicos Andinos', 'Baltasar Tello', '0987736262', 'porcelainoa@fabrica.com', 'Vial de Marcela Sobrino 162 Piso 5 , Lugo, 15523', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('9851745355001', 'MedDental Guayaquil', 'Juana Solsona Mayoral', '0952091325', 'duartejose-manuel@hotel.com', 'Avenida de Samu Lerma 67 Piso 3 , Baleares, 17305', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('1245522987001', 'Distribuidora Sonrisa', 'Filomena Moll', '0988406989', 'maria-fernandacarpio@mineria.es', 'Ronda Prudencio Pacheco 49 Piso 1 , Madrid, 32504', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('3281169403001', 'OrtoSupplies S.A.', 'Teo Fuster', '0917634247', 'petrona23@supermercados.es', 'Camino Íngrid Sanmiguel 376 Piso 3 , Ourense, 14606', true);
INSERT INTO proveedor (ruc,nombre_empresa,contacto,telefono,email,direccion,activo) VALUES ('1798112150001', 'Global Dental Trade', 'Clímaco Borrego Portillo', '0989864260', 'geraldosaldana@hermanos.com', 'Acceso de Pablo Mena 91 Apt. 21 , Cuenca, 05861', true);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1072972420', 'Elodia', 'Morales Segura', '2002-02-19', 'M', '0964193837', 'elodia.morales123@gmail.com', 'Glorieta de Noé Torrens 53 Puerta 4 , Badajoz, 45265', '2026-04-19 09:55:28.541649', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1621609600', 'Raúl', 'Pla Gascón', '1984-06-29', 'M', '0993131979', 'raúl.pla84@gmail.com', 'Pasaje de Nicolasa Guerrero 38 Puerta 0 , Cáceres, 12457', '2025-05-02 09:43:16.414879', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1705849060', 'María Jesús', 'Esparza Urrutia', '1960-02-06', 'F', '0944999379', 'maría jesús.esparza210@gmail.com', 'Plaza de René Rueda 89, Tarragona, 37674', '2025-04-30 01:41:10.793487', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1256287095', 'Alexandra', 'Armas Sarmiento', '1985-02-07', 'F', '0963121477', 'alexandra.armas135@gmail.com', 'Vial Milagros Baena 5 Piso 9 , Valladolid, 24267', '2026-06-25 12:52:12.052147', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1490941149', 'María', 'España Pallarès', '1974-04-12', 'F', '0919736572', 'maría.españa10@gmail.com', 'Via Manu Villanueva 67, Ceuta, 34615', '2026-02-25 15:24:24.350240', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1666964667', 'Roxana', 'Alcalde Verdejo', '2025-05-31', 'M', '0919832887', 'roxana.alcalde551@gmail.com', 'Pasaje Abril Pol 22 Puerta 4 , Barcelona, 21718', '2025-01-24 05:17:57.301190', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1543189555', 'María Fernanda', 'Belmonte Vallejo', '1996-09-12', 'F', '0927778019', 'maría fernanda.belmonte956@gmail.com', 'Alameda de Camila Ortega 29 Puerta 6 , Zaragoza, 36095', '2025-05-25 13:38:32.769586', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1945820704', 'Juan Antonio', 'Caparrós Palomo', '1975-06-29', 'M', '0942787299', 'juan antonio.caparrós379@gmail.com', 'Callejón de Jenny Cadenas 66 Puerta 8 , Barcelona, 01156', '2026-07-08 14:21:52.558965', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1169379374', 'Aroa', 'Alfonso Badía', '1937-03-28', 'F', '0982909480', 'aroa.alfonso721@gmail.com', 'Paseo Ignacio Gelabert 48 Puerta 8 , Palencia, 10976', '2024-09-08 07:41:01.662474', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1656783995', 'Carmen', 'Fuente Gálvez', '1973-05-16', 'M', '0999639081', 'carmen.fuente837@gmail.com', 'Avenida Leocadio Merino 3 Apt. 07 , Albacete, 03342', '2025-03-11 12:56:56.384907', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1712308209', 'Macario', 'Murcia Uribe', '1974-06-27', 'M', '0928024248', 'macario.murcia271@gmail.com', 'Callejón Benita Ramón 84 Apt. 45 , Cantabria, 29145', '2026-07-31 14:04:34.037056', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1955321749', 'Belén', 'Maza Cases', '1997-04-25', 'M', '0984252420', 'belén.maza160@gmail.com', 'Ronda de Teodoro Collado 51 Piso 0 , Madrid, 43056', '2025-03-24 03:52:39.479279', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1302533494', 'Olga', 'Company Canet', '1986-02-27', 'M', '0956020613', 'olga.company209@gmail.com', 'Calle de Anastasio Arana 9, Alicante, 11993', '2025-06-04 15:58:42.139806', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1542678844', 'Nieves', 'Marín Medina', '1981-03-03', 'F', '0943704923', 'nieves.marín928@gmail.com', 'Via de Isidoro Rivas 1, Girona, 28484', '2026-06-29 11:28:31.414896', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1099104722', 'Cruz', 'Landa Cerdá', '2006-10-18', 'F', '0947135391', 'cruz.landa46@gmail.com', 'Camino de Abril Silva 30, Ciudad, 47858', '2025-05-12 00:23:46.744435', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1358153605', 'Juanita', 'Pizarro Tejera', '1951-09-11', 'M', '0995511909', 'juanita.pizarro269@gmail.com', 'Pasaje de Abril Julián 16 Piso 1 , Burgos, 31022', '2026-04-11 16:43:03.732332', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1795890631', 'Elvira', 'Rosa Iñiguez', '1994-01-08', 'F', '0984045292', 'elvira.rosa723@gmail.com', 'Rambla de Octavio Borrell 361, Baleares, 26865', '2026-03-02 12:55:19.955073', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1602269164', 'Mónica', 'Lucas Granados', '1990-05-23', 'M', '0925015458', 'mónica.lucas78@gmail.com', 'Vial de Juan Carlos Melero 71, Huelva, 22811', '2025-08-26 21:16:34.211217', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1585823118', 'Francisco Javier', 'Ferrera Ortiz', '1973-11-10', 'M', '0959555330', 'francisco javier.ferrera597@gmail.com', 'Plaza Basilio Fabregat 638 Piso 0 , Ceuta, 22441', '2025-10-11 10:11:49.223911', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1461479973', 'Miriam', 'Castelló Sala', '1975-04-12', 'M', '0915614174', 'miriam.castelló316@gmail.com', 'Glorieta de Marcela Díez 19, Alicante, 29787', '2025-01-07 04:01:04.267082', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1965274018', 'Lupe', 'Paz Bosch', '1968-10-19', 'M', '0958024342', 'lupe.paz216@gmail.com', 'Alameda de Cecilio Alberdi 50, Granada, 36952', '2025-06-12 18:27:15.019966', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1716114302', 'Hernando', 'Vallejo Gallardo', '1937-08-20', 'M', '0957469942', 'hernando.vallejo799@gmail.com', 'Ronda Evaristo Canet 2 Puerta 6 , Alicante, 22469', '2025-06-08 04:50:46.480913', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1666430218', 'José Mari', 'Checa Cuéllar', '2018-09-11', 'M', '0941774346', 'josé mari.checa886@gmail.com', 'Urbanización Dafne Ríos 768 Puerta 7 , Málaga, 39199', '2026-04-22 17:59:53.575397', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1858872154', 'Ximena', 'Font Briones', '1972-10-16', 'M', '0965337219', 'ximena.font26@gmail.com', 'Vial de Candelaria Mateos 5 Puerta 1 , Málaga, 38727', '2026-08-07 09:44:04.398330', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1790880074', 'Geraldo', 'Soria Pineda', '1949-11-21', 'F', '0965259205', 'geraldo.soria822@gmail.com', 'Paseo de Anastasio Quero 17, Cuenca, 40781', '2026-03-15 22:39:51.354484', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1286480450', 'Hugo', 'Baños Galvez', '1963-12-02', 'M', '0924508349', 'hugo.baños392@gmail.com', 'Urbanización de Maricruz Romeu 419, Guipúzcoa, 04102', '2026-07-23 23:50:03.624920', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1921907485', 'Moreno', 'Juárez Alfonso', '1946-11-13', 'F', '0939854548', 'moreno.juárez205@gmail.com', 'Pasadizo Conrado Giner 19 Puerta 4 , Las Palmas, 14488', '2025-01-12 21:34:20.505329', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1375442872', 'Guiomar', 'Pozuelo Berrocal', '1962-10-09', 'F', '0940547349', 'guiomar.pozuelo229@gmail.com', 'Glorieta de Aníbal Somoza 82, Ceuta, 02985', '2025-04-20 09:01:11.494740', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1708705238', 'Salvador', 'León Sanjuan', '2014-04-06', 'M', '0963481198', 'salvador.león337@gmail.com', 'Avenida Juanita Alba 13, Álava, 10143', '2026-08-20 00:22:18.649975', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1928091906', 'Nadia', 'Castell Morante', '1962-12-10', 'M', '0947463522', 'nadia.castell360@gmail.com', 'Cañada Espiridión Sedano 44 Apt. 20 , Segovia, 49812', '2025-01-27 04:02:18.062869', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1729627019', 'Noé', 'Marí Posada', '1953-12-12', 'F', '0913704481', 'noé.marí119@gmail.com', 'C. de Lorena Cano 78 Puerta 0 , Pontevedra, 04867', '2025-10-20 13:14:50.024167', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1191735734', 'Noelia', 'Bayo Cabezas', '1970-11-09', 'F', '0915134794', 'noelia.bayo112@gmail.com', 'Paseo de Adela Enríquez 48, Melilla, 16050', '2024-11-30 15:27:13.512083', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1371178705', 'Maite', 'Galvez Prada', '1966-03-14', 'F', '0968571795', 'maite.galvez621@gmail.com', 'C. Rosalva Jove 64, Toledo, 38524', '2026-08-02 23:52:59.038489', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1413600440', 'Moreno', 'Paredes Fonseca', '1999-01-09', 'M', '0944188276', 'moreno.paredes46@gmail.com', 'Plaza Anunciación Aramburu 34 Apt. 83 , Cáceres, 45703', '2025-10-12 23:46:17.764890', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1001815992', 'Bernardita', 'Lozano Pino', '1939-11-13', 'M', '0958884978', 'bernardita.lozano442@gmail.com', 'Callejón Manuela Piñeiro 69, Melilla, 08748', '2025-11-22 00:11:40.829840', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1713219781', 'Ambrosio', 'Frutos Torrents', '1983-08-16', 'F', '0993638503', 'ambrosio.frutos322@gmail.com', 'Paseo de Pascual Águila 51, Zaragoza, 06086', '2025-03-14 19:39:34.630049', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1772830248', 'Elisabet', 'Arcos Vara', '1986-09-12', 'F', '0978064830', 'elisabet.arcos317@gmail.com', 'Avenida de Natividad Navas 717, Barcelona, 23834', '2025-02-02 16:24:34.285147', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1350236225', 'Susana', 'Gracia Bayón', '1977-09-05', 'F', '0949682169', 'susana.gracia568@gmail.com', 'Avenida Ricardo Luján 97, Cáceres, 29085', '2025-05-30 08:45:07.989493', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1205986733', 'Chuy', 'Amat Cabrero', '1969-11-29', 'F', '0999245317', 'chuy.amat963@gmail.com', 'Alameda Leocadia Rueda 50, Málaga, 03718', '2024-11-26 08:51:39.521996', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1727264603', 'Domitila', 'Mancebo Torrens', '1945-10-04', 'M', '0992613013', 'domitila.mancebo583@gmail.com', 'Ronda de Juan Luis Duran 25, Cádiz, 02062', '2025-08-19 05:26:39.814741', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1436019893', 'Matilde', 'Dávila Polo', '2020-01-28', 'M', '0950785405', 'matilde.dávila294@gmail.com', 'Plaza Omar Caparrós 185 Apt. 55 , Zaragoza, 01416', '2025-12-03 12:10:13.320209', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1461588882', 'Melisa', 'Guijarro Ángel', '1962-03-08', 'F', '0972409658', 'melisa.guijarro453@gmail.com', 'Via Merche Prada 9, Valencia, 04375', '2024-11-02 23:23:31.431254', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1725449223', 'Belén', 'Vera Gilabert', '1979-07-04', 'M', '0978608612', 'belén.vera485@gmail.com', 'Cañada de Perla Bárcena 52, Valencia, 16676', '2026-05-05 13:04:02.012927', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1707435606', 'Valerio', 'Exposito Fuertes', '1948-12-17', 'M', '0948089166', 'valerio.exposito528@gmail.com', 'Calle de Anacleto Lumbreras 38, Segovia, 26031', '2025-05-07 05:56:00.917673', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1100273738', 'Fortunata', 'Artigas Marquez', '1949-07-11', 'M', '0951663795', 'fortunata.artigas231@gmail.com', 'Via de Marcelino Gilabert 98 Puerta 0 , Toledo, 48958', '2025-05-26 02:38:43.309916', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1158220114', 'Alma', 'Manzano Amores', '1975-06-02', 'M', '0916202700', 'alma.manzano251@gmail.com', 'Pasaje Carmela Bolaños 14, Zamora, 32397', '2026-06-01 03:36:44.854709', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1656350429', 'Óscar', 'Blanch Manjón', '1994-05-05', 'M', '0971124923', 'óscar.blanch425@gmail.com', 'Glorieta Zaida Ruano 64, Córdoba, 45797', '2024-09-25 19:29:24.195188', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1771318048', 'Clemente', 'Benítez Ordóñez', '1980-06-20', 'F', '0976354180', 'clemente.benítez410@gmail.com', 'Via Natanael Barrera 9 Puerta 6 , Cádiz, 43167', '2025-02-25 22:55:52.559157', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1158453521', 'Efraín', 'Herrero Plaza', '2024-04-25', 'M', '0924305904', 'efraín.herrero798@gmail.com', 'Paseo Andrés Vilanova 20 Apt. 49 , Valencia, 47287', '2026-08-21 12:11:45.633292', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1234978881', 'Jafet', 'Rozas Solís', '1957-12-19', 'M', '0979519112', 'jafet.rozas476@gmail.com', 'Rambla de Tomasa Bas 7 Puerta 9 , Navarra, 45612', '2024-12-04 11:21:22.917303', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1598509918', 'Estrella', 'Puig Benavente', '2019-11-12', 'M', '0926288475', 'estrella.puig468@gmail.com', 'Alameda de Victorino Vega 2, Ceuta, 09977', '2025-01-29 11:32:16.681599', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1860514523', 'Amando', 'Parra Lopez', '1967-01-28', 'F', '0999600766', 'amando.parra544@gmail.com', 'Callejón de Eusebia Pizarro 43 Puerta 2 , Barcelona, 09914', '2026-03-31 10:39:25.368768', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1810943524', 'Ulises', 'Baena Oliveras', '1957-06-10', 'F', '0992228802', 'ulises.baena835@gmail.com', 'Pasaje de Jose Manuel Verdú 3 Puerta 4 , Guipúzcoa, 46014', '2024-10-17 21:24:41.335785', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1891816852', 'Herminio', 'Heredia Chico', '1949-01-17', 'F', '0931361812', 'herminio.heredia762@gmail.com', 'Rambla de Miriam Peña 76, Teruel, 22530', '2025-08-09 22:11:07.114588', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1483258726', 'Virginia', 'Puig Sainz', '1982-11-28', 'F', '0943183955', 'virginia.puig861@gmail.com', 'Vial Lorenzo España 93, Valladolid, 29734', '2026-03-14 00:05:20.683245', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1822286180', 'Isaura', 'Maldonado Aranda', '1962-03-11', 'F', '0994120751', 'isaura.maldonado245@gmail.com', 'Via de Juan Mesa 26, Castellón, 13501', '2025-04-27 19:05:13.375649', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1472309605', 'Anabel', 'Rosales Mulet', '1955-12-03', 'M', '0948349783', 'anabel.rosales241@gmail.com', 'C. de Hermenegildo Ferrándiz 9, Teruel, 24761', '2026-04-10 12:51:39.466081', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1360613550', 'Norberto', 'Pedrero Canales', '2006-11-10', 'F', '0982498004', 'norberto.pedrero83@gmail.com', 'Avenida de Manola Lopez 83, Alicante, 07463', '2026-02-19 04:35:49.656740', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1161953189', 'Iker', 'Pulido Múgica', '1944-06-04', 'M', '0961410126', 'iker.pulido711@gmail.com', 'Via de Emperatriz Poza 89, Murcia, 31570', '2025-02-07 06:18:55.688663', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1758511779', 'Juan Carlos', 'Molins Montalbán', '2014-03-15', 'M', '0918620650', 'juan carlos.molins425@gmail.com', 'Callejón de Leire Millán 76, Albacete, 46531', '2025-02-05 04:14:21.205822', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1355281184', 'Evita', 'Prat Gomis', '1973-11-30', 'F', '0965804273', 'evita.prat64@gmail.com', 'Acceso Sancho Amaya 12 Puerta 1 , Zaragoza, 08413', '2026-08-17 21:48:03.015975', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1894310083', 'Francisco Javier', 'Vaquero Olivera', '1992-01-06', 'F', '0962274692', 'francisco javier.vaquero927@gmail.com', 'Acceso Edu Ferreras 1 Piso 4 , Zamora, 20150', '2024-12-15 08:47:57.058971', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1919909014', 'Leocadio', 'Quintanilla Vega', '1969-02-05', 'F', '0974019136', 'leocadio.quintanilla7@gmail.com', 'Callejón de Nayara Rovira 3 Piso 5 , Toledo, 02890', '2025-04-04 16:27:14.270872', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1320632895', 'Amarilis', 'Ortuño Marcos', '2003-06-14', 'F', '0966240084', 'amarilis.ortuño552@gmail.com', 'Glorieta de Gervasio Font 1 Puerta 6 , León, 04475', '2026-04-03 05:48:03.327632', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1524232414', 'Dora', 'Haro Sanjuan', '1983-01-10', 'M', '0946632757', 'dora.haro447@gmail.com', 'Calle Remigio Cueto 82, Teruel, 32071', '2026-04-19 21:56:34.376074', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1031165166', 'Roldán', 'Dominguez Redondo', '1988-07-31', 'F', '0955114543', 'roldán.dominguez685@gmail.com', 'Rambla Gabino Cámara 362, Sevilla, 04302', '2026-01-03 07:21:19.420643', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1777583839', 'Edmundo', 'Zamora Bosch', '2012-12-03', 'M', '0972732043', 'edmundo.zamora942@gmail.com', 'Rambla de Julio César Alba 22, Santa Cruz de Tenerife, 46307', '2026-02-07 18:58:53.908357', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1668143326', 'Manu', 'Agustín Arroyo', '1947-06-28', 'M', '0962884503', 'manu.agustín607@gmail.com', 'Paseo Anunciación Salcedo 44, Salamanca, 17332', '2026-05-05 11:44:30.602327', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1090137896', 'Atilio', 'Amores Yáñez', '1939-05-12', 'F', '0928213276', 'atilio.amores888@gmail.com', 'Alameda de Tomasa Hernandez 58 Puerta 8 , Cádiz, 10873', '2026-07-27 21:08:45.555449', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1195130056', 'Haydée', 'Serna Polo', '1961-11-24', 'M', '0944917589', 'haydée.serna389@gmail.com', 'Pasadizo de Rosario Llorente 75 Apt. 07 , Guadalajara, 25723', '2025-10-27 08:31:47.827801', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1227268503', 'Adelina', 'Torrijos Pedraza', '1936-08-01', 'F', '0953868501', 'adelina.torrijos346@gmail.com', 'Pasadizo Lupe Cadenas 827, Huelva, 22999', '2026-03-08 03:19:18.626582', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1298775766', 'Juan José', 'Gutierrez Castejón', '1994-07-28', 'F', '0943859311', 'juan josé.gutierrez855@gmail.com', 'Plaza de Rosendo Roldán 69, La Rioja, 42071', '2026-08-03 11:05:46.243314', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1504988121', 'Julie', 'Moll Olivares', '1994-02-18', 'M', '0982399599', 'julie.moll54@gmail.com', 'Avenida de Valentina Guerra 491 Apt. 56 , Guadalajara, 33924', '2025-07-17 16:54:37.101914', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1240756713', 'Camilo', 'Estevez Benítez', '1980-11-07', 'M', '0997477029', 'camilo.estevez42@gmail.com', 'Urbanización de Cipriano Bellido 9, Granada, 28483', '2025-11-14 14:02:41.080783', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1265518424', 'Sigfrido', 'Galvez Herrera', '1943-05-31', 'M', '0912735359', 'sigfrido.galvez637@gmail.com', 'Cañada Aníbal Bermudez 375, Navarra, 05137', '2025-07-17 00:40:47.426450', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1256135680', 'Roberta', 'Esteban Garzón', '1982-10-14', 'M', '0973560289', 'roberta.esteban686@gmail.com', 'Alameda Alba Lluch 10 Apt. 84 , Granada, 26192', '2026-01-25 15:47:49.185738', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1605557720', 'Lidia', 'Aguado Hidalgo', '1949-11-19', 'M', '0972415804', 'lidia.aguado717@gmail.com', 'Cañada Leandra Zorrilla 9 Piso 1 , Ceuta, 29378', '2026-02-27 13:11:46.404485', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1823450567', 'Arsenio', 'Acuña España', '1943-08-16', 'F', '0932520277', 'arsenio.acuña621@gmail.com', 'Cañada de Humberto Álvarez 1, Navarra, 18251', '2026-07-22 04:19:16.322027', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1835147672', 'María Manuela', 'Portillo Feijoo', '2025-03-05', 'M', '0951746937', 'maría manuela.portillo111@gmail.com', 'Pasadizo Chelo Paredes 9, Guadalajara, 13853', '2026-03-10 17:37:23.781869', true, 1);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1997385005', 'Ximena', 'Zurita Sobrino', '1987-09-02', 'F', '0987282128', 'ximena.zurita694@gmail.com', 'Cañada de Custodio Araujo 22 Piso 3 , Alicante, 34775', '2026-06-01 23:01:45.264884', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1425904456', 'Eduardo', 'Ureña Zabala', '2020-05-09', 'M', '0920200074', 'eduardo.ureña607@gmail.com', 'C. Simón Casares 413 Piso 8 , Navarra, 13793', '2026-06-02 03:20:42.624339', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1109415691', 'Carlota', 'Martí Gomila', '1999-12-24', 'F', '0990585882', 'carlota.martí825@gmail.com', 'Plaza de Efraín Olmedo 60, Málaga, 46716', '2025-05-26 08:26:03.234399', true, 2);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1854942461', 'Débora', 'Azorin Angulo', '1939-06-12', 'M', '0956600900', 'débora.azorin546@gmail.com', 'Via Marcia Agustín 95, Álava, 02098', '2026-05-16 19:18:49.078927', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1710303128', 'Elba', 'Nieto Bernad', '1944-10-26', 'F', '0919255216', 'elba.nieto519@gmail.com', 'Via Erasmo Roig 11 Puerta 9 , Las Palmas, 08440', '2024-09-11 21:59:38.360557', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1013585139', 'Encarnita', 'Arana Navarro', '1985-04-30', 'F', '0975793759', 'encarnita.arana109@gmail.com', 'Camino Rafaela Cabanillas 806 Piso 6 , Córdoba, 16664', '2026-05-29 04:58:01.090353', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1388896443', 'Ainoa', 'Chaparro Cabañas', '1980-06-01', 'F', '0930534124', 'ainoa.chaparro446@gmail.com', 'Glorieta Mirta Sarmiento 80, León, 21886', '2026-04-27 01:24:20.824858', true, 3);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1787906704', 'Dafne', 'Jove Lladó', '2023-12-15', 'F', '0992666356', 'dafne.jove828@gmail.com', 'Camino Nydia Cerdá 9 Piso 4 , Zamora, 50162', '2025-02-03 00:41:47.628420', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1499154414', 'Cruz', 'Lluch Álamo', '1962-04-07', 'F', '0989520597', 'cruz.lluch275@gmail.com', 'Plaza de Rosa María Anglada 23 Apt. 74 , Melilla, 33619', '2024-09-05 02:21:50.308023', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1914520040', 'Eugenio', 'Feijoo Herrera', '2005-10-14', 'M', '0921631697', 'eugenio.feijoo286@gmail.com', 'Cuesta Cándida Castañeda 34, Madrid, 46693', '2025-12-24 15:12:48.902595', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1261846370', 'Concha', 'Amador Abad', '2022-09-08', 'F', '0986483924', 'concha.amador625@gmail.com', 'Vial de Juan Carlos Gallardo 44, Tarragona, 04079', '2025-08-10 04:17:31.607737', true, 7);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1361203124', 'Daniela', 'Huertas Giner', '1977-11-02', 'M', '0976344695', 'daniela.huertas872@gmail.com', 'Avenida Arcelia Benitez 247 Puerta 2 , Jaén, 16019', '2026-03-18 14:07:43.136592', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1195249057', 'Maristela', 'Alfaro Ferreras', '2021-06-02', 'F', '0938470244', 'maristela.alfaro364@gmail.com', 'Via de Lilia Medina 5, Murcia, 31190', '2024-12-07 18:46:47.071619', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1365436049', 'Lalo', 'Luz Barco', '1945-02-03', 'F', '0990014570', 'lalo.luz719@gmail.com', 'Plaza de Segismundo Marquez 8, Palencia, 02442', '2025-03-05 19:49:52.793061', true, 5);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1596776072', 'Anselmo', 'Salamanca Barrera', '1984-02-04', 'M', '0979340535', 'anselmo.salamanca971@gmail.com', 'Rambla Baldomero Pedraza 15, Zamora, 27154', '2025-10-12 11:43:56.677104', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1091926217', 'Ale', 'Cruz Espinosa', '1994-12-25', 'M', '0964549859', 'ale.cruz501@gmail.com', 'Plaza de María Carmen López 596 Apt. 48 , Ávila, 35873', '2026-07-16 22:37:26.813692', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1741536135', 'Perla', 'Jordán Isern', '1939-12-27', 'F', '0996691619', 'perla.jordán729@gmail.com', 'Rambla Édgar Torralba 86 Piso 0 , León, 33646', '2026-06-30 01:27:56.888589', true, 8);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1481223755', 'Prudencio', 'Machado Sancho', '1999-05-17', 'M', '0922489409', 'prudencio.machado302@gmail.com', 'Vial de Maristela Rey 97 Puerta 9 , Valladolid, 37594', '2024-10-15 14:28:44.771441', true, 4);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1434222401', 'María Dolores', 'Benavides Benavides', '1942-11-06', 'M', '0951098277', 'maría dolores.benavides680@gmail.com', 'Rambla de Chema Español 6, Lugo, 15184', '2026-02-03 09:57:50.130506', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1508159580', 'Dani', 'Iglesia Campillo', '2015-12-17', 'F', '0967110154', 'dani.iglesia764@gmail.com', 'Alameda de Lisandro Lastra 15, Huelva, 07146', '2026-08-12 17:56:52.152457', true, 6);
INSERT INTO paciente (cedula,nombres,apellidos,fecha_nac,sexo,telefono,email,direccion,fecha_registro,activo,id_grupo_sanguineo) VALUES ('1377753674', 'Bernabé', 'Alarcón Salinas', '1981-11-22', 'F', '0946361787', 'bernabé.alarcón314@gmail.com', 'Vial de Juan Luis Parra 72, Albacete, 24133', '2025-11-16 00:56:55.833565', true, 5);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (30, 2, '2026-07-28 21:57:41.807890', 30, 'Sangrado de encías', 1, NULL, 'Paciente llegó puntual', '2026-07-25 21:57:41.807890', 'Gingivitis leve', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (76, 9, '2026-01-10 02:30:57.166150', 90, 'Sensibilidad dental', 1, 'Telefónico', 'Se reagendó una vez', '2026-01-07 02:30:57.166150', 'Sin hallazgos relevantes', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (91, 9, '2025-09-05 16:47:15.822287', 30, 'Sensibilidad dental', 1, 'Presencial', 'Se reagendó una vez', '2025-09-03 16:47:15.822287', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (2, 10, '2026-08-29 15:25:43.389198', 45, 'Seguimiento post-tratamiento', 4, 'App', 'Se reagendó una vez', '2026-08-27 15:25:43.389198', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', '2027-02-25 15:25:43.389198');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (15, 2, '2026-09-23 03:40:40.655592', 60, 'Seguimiento post-tratamiento', 1, NULL, NULL, '2026-09-21 03:40:40.655592', 'Gingivitis leve', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (32, 2, '2026-06-28 08:01:45.342542', 90, 'Emergencia por caída', 5, NULL, 'Paciente llegó puntual', '2026-06-20 08:01:45.342542', 'Requiere tratamiento de conducto', 'Volver en 6 meses para control', '2026-09-26 08:01:45.342542');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (76, 7, '2025-08-30 18:58:20.706300', 45, 'Dolor dental', 5, 'Presencial', 'Paciente llegó puntual', '2025-08-20 18:58:20.706300', 'Gingivitis leve', 'Tomar analgésico si hay dolor', '2025-10-29 18:58:20.706300');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (31, 3, '2026-04-17 00:34:03.299025', 90, 'Control de rutina', 2, 'Presencial', 'Requiere acompañante', '2026-04-10 00:34:03.299025', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (30, 5, '2026-03-11 06:02:49.246520', 45, 'Seguimiento post-tratamiento', 1, 'Telefónico', 'Se reagendó una vez', '2026-03-01 06:02:49.246520', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (70, 4, '2026-03-19 06:50:32.458357', 30, 'Sensibilidad dental', 2, 'Presencial', NULL, '2026-03-17 06:50:32.458357', 'Pieza retenida detectada en radiografía', 'Tomar analgésico si hay dolor', '2026-06-17 06:50:32.458357');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (57, 2, '2026-07-10 11:08:50.752054', 60, 'Sensibilidad dental', 4, 'WhatsApp', 'Requiere acompañante', '2026-07-03 11:08:50.752054', 'Caries en pieza afectada', NULL, '2026-10-08 11:08:50.752054');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (78, 5, '2025-11-14 03:48:21.797124', 20, 'Control de rutina', 2, NULL, NULL, '2025-11-04 03:48:21.797124', 'Pieza retenida detectada en radiografía', 'Tomar analgésico si hay dolor', '2026-01-13 03:48:21.797124');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (61, 9, '2026-03-29 14:29:56.237107', 60, 'Sensibilidad dental', 2, NULL, 'Requiere acompañante', '2026-03-19 14:29:56.237107', 'Pieza retenida detectada en radiografía', 'Volver en 6 meses para control', '2026-09-25 14:29:56.237107');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (45, 7, '2025-11-06 23:52:45.683904', 45, 'Sangrado de encías', 1, 'Telefónico', 'Se reagendó una vez', '2025-10-31 23:52:45.683904', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (52, 9, '2026-05-03 02:20:53.545334', 20, 'Seguimiento post-tratamiento', 1, 'WhatsApp', 'Se reagendó una vez', '2026-04-28 02:20:53.545334', 'Caries en pieza afectada', 'Volver en 6 meses para control', '2026-06-02 02:20:53.545334');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (85, 9, '2026-05-15 17:00:18.183627', 60, 'Emergencia por caída', 1, 'Telefónico', 'Se reagendó una vez', '2026-05-06 17:00:18.183627', 'Pieza retenida detectada en radiografía', 'Volver en 6 meses para control', '2026-06-14 17:00:18.183627');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (27, 5, '2026-01-20 22:36:53.927971', 90, 'Limpieza programada', 3, 'App', 'Requiere acompañante', '2026-01-19 22:36:53.927971', 'Caries en pieza afectada', 'Evitar alimentos duros por 24h', '2026-04-20 22:36:53.927971');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (71, 1, '2025-09-13 10:52:22.858818', 90, 'Emergencia por caída', 1, 'Telefónico', NULL, '2025-09-06 10:52:22.858818', 'Caries en pieza afectada', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (92, 5, '2026-04-02 13:21:19.552532', 90, 'Sensibilidad dental', 4, 'App', 'Requiere acompañante', '2026-03-30 13:21:19.552532', 'Requiere tratamiento de conducto', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (77, 9, '2026-02-16 20:04:27.100801', 30, 'Control de rutina', 3, 'App', 'Se reagendó una vez', '2026-02-08 20:04:27.100801', 'Sin hallazgos relevantes', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (39, 10, '2026-05-29 19:23:40.583202', 90, 'Seguimiento post-tratamiento', 2, 'App', 'Requiere acompañante', '2026-05-24 19:23:40.583202', 'Sin hallazgos relevantes', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (42, 4, '2026-03-03 05:04:34.680603', 30, 'Emergencia por caída', 2, 'App', NULL, '2026-02-26 05:04:34.680603', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', '2026-08-30 05:04:34.680603');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (50, 3, '2026-09-01 23:09:58.661588', 60, 'Dolor dental', 2, NULL, 'Se reagendó una vez', '2026-08-31 23:09:58.661588', 'Pieza retenida detectada en radiografía', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (59, 1, '2025-10-25 00:25:16.020516', 30, 'Emergencia por caída', 2, 'Presencial', 'Requiere acompañante', '2025-10-21 00:25:16.020516', 'Sin hallazgos relevantes', 'Volver en 6 meses para control', '2026-01-23 00:25:16.020516');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (87, 9, '2025-09-28 23:20:58.997152', 60, 'Sangrado de encías', 4, NULL, NULL, '2025-09-19 23:20:58.997152', 'Caries en pieza afectada', 'Evitar alimentos duros por 24h', '2025-12-27 23:20:58.997152');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (30, 2, '2025-12-19 12:02:01.242387', 60, 'Control de rutina', 1, 'App', 'Paciente llegó puntual', '2025-12-15 12:02:01.242387', 'Caries en pieza afectada', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (8, 5, '2025-10-26 05:42:11.654699', 45, 'Sangrado de encías', 4, 'Telefónico', 'Paciente llegó puntual', '2025-10-18 05:42:11.654699', 'Requiere tratamiento de conducto', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (11, 10, '2026-09-23 21:48:30.948198', 60, 'Revisión de ortodoncia', 4, NULL, 'Paciente llegó puntual', '2026-09-20 21:48:30.948198', 'Requiere tratamiento de conducto', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (86, 1, '2026-06-23 15:30:29.736273', 60, 'Sensibilidad dental', 5, 'Telefónico', NULL, '2026-06-16 15:30:29.736273', 'Sin hallazgos relevantes', 'Tomar analgésico si hay dolor', '2026-12-20 15:30:29.736273');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (89, 5, '2026-03-30 02:11:21.950583', 60, 'Sensibilidad dental', 2, 'App', 'Requiere acompañante', '2026-03-29 02:11:21.950583', 'Gingivitis leve', 'Volver en 6 meses para control', '2026-06-28 02:11:21.950583');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (90, 5, '2026-06-09 15:16:40.198239', 20, 'Emergencia por caída', 3, 'Presencial', NULL, '2026-05-31 15:16:40.198239', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', '2026-09-07 15:16:40.198239');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (100, 4, '2026-08-28 10:45:01.207702', 90, 'Sangrado de encías', 2, 'Telefónico', 'Se reagendó una vez', '2026-08-18 10:45:01.207702', 'Pieza retenida detectada en radiografía', 'Evitar alimentos duros por 24h', '2026-09-27 10:45:01.207702');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (40, 8, '2026-03-09 22:46:11.013997', 20, 'Sangrado de encías', 2, 'Presencial', 'Se reagendó una vez', '2026-03-04 22:46:11.013997', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (17, 9, '2026-06-19 13:04:47.484782', 45, 'Sensibilidad dental', 2, 'WhatsApp', 'Requiere acompañante', '2026-06-15 13:04:47.484782', 'Desgaste dental por bruxismo', 'Tomar analgésico si hay dolor', '2026-12-16 13:04:47.484782');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (10, 3, '2026-08-22 03:59:33.304456', 30, 'Emergencia por caída', 5, 'WhatsApp', NULL, '2026-08-16 03:59:33.304456', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', '2027-02-18 03:59:33.304456');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (48, 5, '2025-11-22 04:09:36.255884', 90, 'Emergencia por caída', 3, 'Presencial', 'Paciente llegó puntual', '2025-11-15 04:09:36.255884', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', '2026-01-21 04:09:36.255884');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (83, 2, '2026-04-10 15:53:36.674321', 60, 'Sensibilidad dental', 4, 'Presencial', 'Paciente llegó puntual', '2026-04-10 15:53:36.674321', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', '2026-05-10 15:53:36.674321');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (13, 4, '2026-08-28 21:12:55.714479', 90, 'Limpieza programada', 4, 'App', 'Se reagendó una vez', '2026-08-18 21:12:55.714479', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', '2026-10-27 21:12:55.714479');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (54, 2, '2026-01-07 18:05:19.614732', 60, 'Emergencia por caída', 3, 'Presencial', 'Se reagendó una vez', '2026-01-04 18:05:19.614732', 'Requiere tratamiento de conducto', 'Volver en 6 meses para control', '2026-04-07 18:05:19.614732');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (13, 6, '2026-04-11 05:54:10.006281', 90, 'Sangrado de encías', 1, 'App', 'Se reagendó una vez', '2026-04-08 05:54:10.006281', 'Caries en pieza afectada', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (28, 10, '2025-10-23 14:07:18.133301', 20, 'Dolor dental', 3, 'Telefónico', 'Paciente llegó puntual', '2025-10-14 14:07:18.133301', 'Gingivitis leve', NULL, '2025-12-22 14:07:18.133301');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (76, 4, '2026-01-07 08:47:23.613830', 30, 'Sangrado de encías', 2, NULL, NULL, '2026-01-03 08:47:23.613830', 'Pieza retenida detectada en radiografía', 'Evitar alimentos duros por 24h', '2026-04-07 08:47:23.613830');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (23, 2, '2026-08-18 04:34:21.270565', 20, 'Limpieza programada', 1, 'WhatsApp', 'Paciente llegó puntual', '2026-08-09 04:34:21.270565', 'Sin hallazgos relevantes', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (7, 3, '2026-08-01 03:32:54.213629', 60, 'Control de rutina', 1, 'App', 'Requiere acompañante', '2026-07-27 03:32:54.213629', 'Placa bacteriana acumulada', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (29, 10, '2026-03-10 22:35:21.443251', 20, 'Sensibilidad dental', 4, 'Presencial', NULL, '2026-03-03 22:35:21.443251', 'Pieza retenida detectada en radiografía', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (14, 8, '2026-01-24 00:01:22.619664', 60, 'Control de rutina', 1, 'WhatsApp', 'Paciente llegó puntual', '2026-01-23 00:01:22.619664', 'Gingivitis leve', 'Tomar analgésico si hay dolor', '2026-04-24 00:01:22.619664');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (49, 10, '2026-07-29 12:14:23.802287', 90, 'Sensibilidad dental', 4, NULL, 'Requiere acompañante', '2026-07-28 12:14:23.802287', 'Pieza retenida detectada en radiografía', NULL, '2026-09-27 12:14:23.802287');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (56, 8, '2025-09-02 10:12:40.813576', 30, 'Emergencia por caída', 3, 'App', 'Requiere acompañante', '2025-08-27 10:12:40.813576', 'Desgaste dental por bruxismo', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (41, 5, '2026-07-21 20:12:35.050573', 45, 'Limpieza programada', 4, 'Presencial', NULL, '2026-07-20 20:12:35.050573', 'Caries en pieza afectada', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (95, 6, '2025-11-24 08:46:40.539854', 30, 'Dolor dental', 5, NULL, 'Se reagendó una vez', '2025-11-14 08:46:40.539854', 'Caries en pieza afectada', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (86, 7, '2025-10-01 20:47:03.422828', 20, 'Sensibilidad dental', 5, 'WhatsApp', 'Se reagendó una vez', '2025-09-30 20:47:03.422828', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (62, 4, '2026-08-12 10:17:29.329167', 20, 'Sangrado de encías', 5, 'WhatsApp', NULL, '2026-08-08 10:17:29.329167', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', '2026-09-11 10:17:29.329167');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (78, 5, '2026-08-28 00:46:03.147950', 20, 'Limpieza programada', 3, 'WhatsApp', 'Se reagendó una vez', '2026-08-23 00:46:03.147950', 'Caries en pieza afectada', 'Evitar alimentos duros por 24h', '2027-02-24 00:46:03.147950');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (9, 3, '2026-09-22 13:39:19.295949', 20, 'Control de rutina', 5, 'Telefónico', 'Requiere acompañante', '2026-09-16 13:39:19.295949', 'Requiere tratamiento de conducto', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (40, 6, '2026-01-09 15:18:22.892640', 90, 'Control de rutina', 1, 'Telefónico', 'Paciente llegó puntual', '2025-12-31 15:18:22.892640', 'Caries en pieza afectada', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (85, 7, '2025-09-02 12:32:45.133572', 60, 'Seguimiento post-tratamiento', 4, 'WhatsApp', 'Paciente llegó puntual', '2025-08-25 12:32:45.133572', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (37, 10, '2026-04-09 10:17:05.118683', 60, 'Sensibilidad dental', 1, 'Telefónico', 'Requiere acompañante', '2026-03-31 10:17:05.118683', 'Caries en pieza afectada', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (28, 3, '2026-08-23 08:38:03.111866', 45, 'Sensibilidad dental', 3, 'Presencial', NULL, '2026-08-16 08:38:03.111866', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (49, 9, '2026-03-03 16:44:38.172072', 30, 'Sangrado de encías', 1, 'App', NULL, '2026-02-25 16:44:38.172072', 'Caries en pieza afectada', 'Volver en 6 meses para control', '2026-06-01 16:44:38.172072');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (74, 7, '2026-07-30 15:31:32.222170', 90, 'Emergencia por caída', 4, 'WhatsApp', NULL, '2026-07-24 15:31:32.222170', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (80, 8, '2026-07-26 17:46:31.400769', 45, 'Control de rutina', 4, 'Presencial', 'Paciente llegó puntual', '2026-07-20 17:46:31.400769', 'Placa bacteriana acumulada', 'Volver en 6 meses para control', '2027-01-22 17:46:31.400769');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (40, 6, '2026-07-05 10:34:13.328220', 30, 'Sangrado de encías', 2, 'Presencial', NULL, '2026-06-27 10:34:13.328220', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', '2026-10-03 10:34:13.328220');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (45, 3, '2025-09-28 18:32:20.579330', 30, 'Control de rutina', 2, 'WhatsApp', 'Paciente llegó puntual', '2025-09-26 18:32:20.579330', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', '2025-10-28 18:32:20.579330');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (23, 8, '2026-05-24 12:47:22.595979', 60, 'Seguimiento post-tratamiento', 5, NULL, 'Se reagendó una vez', '2026-05-14 12:47:22.595979', 'Sin hallazgos relevantes', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (61, 8, '2026-09-17 13:56:41.242865', 45, 'Sensibilidad dental', 5, 'Presencial', 'Se reagendó una vez', '2026-09-09 13:56:41.242865', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (5, 1, '2025-11-11 03:03:35.216071', 45, 'Sensibilidad dental', 1, 'Presencial', 'Requiere acompañante', '2025-11-04 03:03:35.216071', 'Placa bacteriana acumulada', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (74, 4, '2026-03-15 12:34:45.827370', 45, 'Seguimiento post-tratamiento', 5, 'Telefónico', NULL, '2026-03-08 12:34:45.827370', 'Caries en pieza afectada', 'Tomar analgésico si hay dolor', '2026-04-14 12:34:45.827370');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (65, 3, '2025-09-13 15:22:16.566253', 20, 'Revisión de ortodoncia', 4, 'App', 'Paciente llegó puntual', '2025-09-08 15:22:16.566253', 'Sin hallazgos relevantes', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (100, 6, '2026-08-04 14:42:12.740615', 90, 'Dolor dental', 3, 'Presencial', 'Se reagendó una vez', '2026-08-03 14:42:12.740615', 'Placa bacteriana acumulada', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (93, 10, '2025-09-24 03:43:17.683362', 30, 'Sangrado de encías', 1, NULL, 'Paciente llegó puntual', '2025-09-19 03:43:17.683362', 'Sin hallazgos relevantes', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (91, 2, '2026-03-08 17:16:54.079943', 45, 'Emergencia por caída', 3, 'Telefónico', NULL, '2026-02-26 17:16:54.079943', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', '2026-04-07 17:16:54.079943');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (47, 5, '2026-04-13 21:36:54.543833', 30, 'Revisión de ortodoncia', 3, 'App', 'Paciente llegó puntual', '2026-04-10 21:36:54.543833', 'Gingivitis leve', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (13, 9, '2025-11-26 11:48:16.084303', 90, 'Dolor dental', 3, NULL, 'Paciente llegó puntual', '2025-11-17 11:48:16.084303', 'Requiere tratamiento de conducto', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (89, 10, '2026-07-13 08:30:27.671589', 30, 'Seguimiento post-tratamiento', 1, 'App', 'Se reagendó una vez', '2026-07-03 08:30:27.671589', 'Desgaste dental por bruxismo', 'Evitar alimentos duros por 24h', '2026-10-11 08:30:27.671589');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (97, 8, '2026-06-29 20:03:31.416857', 30, 'Revisión de ortodoncia', 3, 'App', 'Paciente llegó puntual', '2026-06-24 20:03:31.416857', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (37, 7, '2026-03-25 00:53:48.660953', 90, 'Emergencia por caída', 2, 'Telefónico', 'Paciente llegó puntual', '2026-03-21 00:53:48.660953', 'Caries en pieza afectada', 'Volver en 6 meses para control', '2026-04-24 00:53:48.660953');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (92, 9, '2025-10-22 00:19:46.467141', 20, 'Sensibilidad dental', 1, 'Telefónico', 'Se reagendó una vez', '2025-10-15 00:19:46.467141', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', '2025-11-21 00:19:46.467141');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (29, 8, '2025-11-17 06:55:15.722191', 45, 'Dolor dental', 4, 'Presencial', 'Requiere acompañante', '2025-11-09 06:55:15.722191', 'Sin hallazgos relevantes', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (11, 6, '2026-06-11 09:52:17.340924', 30, 'Dolor dental', 3, 'Presencial', 'Se reagendó una vez', '2026-06-09 09:52:17.340924', 'Gingivitis leve', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (61, 3, '2026-07-29 21:08:55.949792', 60, 'Seguimiento post-tratamiento', 5, 'Presencial', NULL, '2026-07-29 21:08:55.949792', 'Sin hallazgos relevantes', 'Evitar alimentos duros por 24h', '2027-01-25 21:08:55.949792');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (15, 5, '2026-08-04 19:36:01.655559', 30, 'Sensibilidad dental', 1, 'Presencial', 'Paciente llegó puntual', '2026-07-29 19:36:01.655559', 'Desgaste dental por bruxismo', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (64, 10, '2026-09-06 09:50:25.456867', 90, 'Dolor dental', 5, NULL, 'Paciente llegó puntual', '2026-09-04 09:50:25.456867', 'Sin hallazgos relevantes', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (46, 4, '2025-09-13 02:46:11.622912', 90, 'Emergencia por caída', 2, 'Presencial', 'Se reagendó una vez', '2025-09-12 02:46:11.622912', 'Placa bacteriana acumulada', NULL, NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (61, 1, '2026-05-12 18:24:04.934006', 60, 'Sangrado de encías', 3, 'Presencial', 'Se reagendó una vez', '2026-05-11 18:24:04.934006', 'Sin hallazgos relevantes', 'Evitar alimentos duros por 24h', '2026-06-11 18:24:04.934006');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (99, 10, '2026-05-07 21:11:20.840518', 45, 'Limpieza programada', 1, 'WhatsApp', 'Se reagendó una vez', '2026-04-27 21:11:20.840518', 'Gingivitis leve', 'Volver en 6 meses para control', '2026-11-03 21:11:20.840518');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (81, 3, '2026-06-06 05:53:45.852776', 30, 'Control de rutina', 4, 'Presencial', 'Se reagendó una vez', '2026-06-03 05:53:45.852776', 'Caries en pieza afectada', 'Evitar alimentos duros por 24h', '2026-09-04 05:53:45.852776');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (40, 9, '2026-09-17 19:54:04.235304', 60, 'Seguimiento post-tratamiento', 3, 'Presencial', 'Paciente llegó puntual', '2026-09-13 19:54:04.235304', 'Sin hallazgos relevantes', NULL, '2026-12-16 19:54:04.235304');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (35, 2, '2025-10-10 05:34:05.676954', 45, 'Emergencia por caída', 4, 'App', 'Requiere acompañante', '2025-10-05 05:34:05.676954', 'Gingivitis leve', 'Volver en 6 meses para control', '2026-01-08 05:34:05.676954');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (67, 5, '2026-07-30 11:01:00.975143', 20, 'Emergencia por caída', 1, 'App', 'Paciente llegó puntual', '2026-07-22 11:01:00.975143', 'Sin hallazgos relevantes', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (42, 5, '2026-04-23 09:25:53.964921', 45, 'Seguimiento post-tratamiento', 5, 'App', 'Paciente llegó puntual', '2026-04-16 09:25:53.964921', 'Sin hallazgos relevantes', 'Volver en 6 meses para control', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (46, 10, '2026-01-06 21:49:33.620095', 60, 'Sensibilidad dental', 1, 'Presencial', 'Requiere acompañante', '2026-01-01 21:49:33.620095', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', '2026-03-07 21:49:33.620095');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (78, 8, '2026-03-01 07:02:20.276129', 20, 'Limpieza programada', 1, 'Telefónico', 'Se reagendó una vez', '2026-02-24 07:02:20.276129', 'Requiere tratamiento de conducto', NULL, '2026-08-28 07:02:20.276129');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (48, 6, '2025-10-08 14:25:43.165261', 60, 'Control de rutina', 5, 'Telefónico', 'Se reagendó una vez', '2025-10-02 14:25:43.165261', 'Sin hallazgos relevantes', 'Tomar analgésico si hay dolor', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (15, 1, '2025-09-16 11:10:44.874719', 30, 'Seguimiento post-tratamiento', 5, 'App', NULL, '2025-09-12 11:10:44.874719', 'Pieza retenida detectada en radiografía', 'Tomar analgésico si hay dolor', '2025-11-15 11:10:44.874719');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (79, 5, '2026-07-23 01:29:15.583565', 60, 'Revisión de ortodoncia', 1, 'Telefónico', NULL, '2026-07-16 01:29:15.583565', 'Gingivitis leve', 'Volver en 6 meses para control', '2026-10-21 01:29:15.583565');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (86, 6, '2025-12-05 00:03:34.126797', 20, 'Sensibilidad dental', 3, 'Telefónico', 'Paciente llegó puntual', '2025-11-30 00:03:34.126797', 'Placa bacteriana acumulada', 'Evitar alimentos duros por 24h', NULL);
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (26, 3, '2026-06-15 05:54:19.717505', 30, 'Seguimiento post-tratamiento', 1, 'WhatsApp', 'Se reagendó una vez', '2026-06-08 05:54:19.717505', 'Pieza retenida detectada en radiografía', 'Evitar alimentos duros por 24h', '2026-07-15 05:54:19.717505');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (9, 5, '2026-08-16 11:01:10.672384', 60, 'Seguimiento post-tratamiento', 5, 'App', 'Requiere acompañante', '2026-08-07 11:01:10.672384', 'Caries en pieza afectada', 'Evitar alimentos duros por 24h', '2026-09-15 11:01:10.672384');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (58, 8, '2025-10-15 00:24:38.764568', 90, 'Sangrado de encías', 2, NULL, 'Paciente llegó puntual', '2025-10-13 00:24:38.764568', 'Requiere tratamiento de conducto', NULL, '2025-12-14 00:24:38.764568');
INSERT INTO cita (id_paciente,id_odontologo,fecha_hora,duracion_min,motivo,id_estado_cita,canal_agendamiento,observaciones,fecha_registro,diagnostico,indicaciones,proxima_cita) VALUES (39, 3, '2026-07-22 04:21:06.785285', 30, 'Sangrado de encías', 2, 'WhatsApp', 'Se reagendó una vez', '2026-07-21 04:21:06.785285', 'Sin hallazgos relevantes', 'Evitar alimentos duros por 24h', '2026-10-20 04:21:06.785285');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (17, 21, 20, 1, 190.11, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (65, 21, 11, 1, 183.67, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (22, 22, 22, 1, 255.12, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (4, 3, 3, 1, 285.34, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (84, 7, 27, 1, 191.16, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (64, 21, 19, 1, 197.94, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (62, 8, 26, 1, 99.77, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (89, 2, 11, 1, 140.29, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (60, 7, 22, 1, 187.9, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (92, 11, 23, 1, 292.98, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (98, 12, 7, 1, 105.95, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (16, 9, 29, 1, 85.66, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (7, 10, 25, 1, 261.29, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (32, 6, 21, 1, 281.12, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (25, 25, 11, 1, 157.01, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (64, 10, 32, 1, 21.61, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (65, 15, 16, 1, 76.32, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (7, 2, 19, 1, 156.04, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (37, 18, 1, 1, 256.44, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (18, 9, 24, 1, 232.7, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (6, 13, 4, 1, 177.53, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (47, 18, 19, 1, 35.96, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (98, 18, 18, 1, 250.21, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (17, 4, 26, 1, 121.36, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (72, 12, 10, 1, 71.73, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (65, 2, 3, 1, 26.09, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (61, 17, 30, 1, 57.45, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (42, 20, 21, 1, 61.31, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (76, 11, 32, 1, 216.99, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (61, 1, 24, 1, 109.4, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (54, 19, 20, 1, 242.08, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (77, 16, 17, 1, 290.62, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (93, 2, 31, 1, 63.6, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (19, 22, 16, 1, 24.0, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (25, 1, 29, 1, 104.4, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (53, 23, 14, 1, 131.96, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (95, 24, 4, 1, 216.15, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (72, 11, 31, 1, 164.76, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (23, 15, 22, 1, 170.69, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (79, 16, 13, 1, 287.84, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (72, 10, 15, 1, 283.32, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (99, 10, 14, 1, 211.72, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (41, 16, 23, 1, 174.74, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (37, 4, 25, 1, 270.29, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (45, 25, 10, 1, 97.78, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (92, 3, 23, 1, 278.34, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (96, 16, 14, 1, 72.59, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (72, 23, 18, 1, 54.12, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (32, 2, 15, 1, 196.81, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (13, 14, 22, 1, 219.45, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (88, 25, 9, 1, 16.48, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (53, 21, 31, 1, 151.07, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (97, 10, 21, 1, 96.34, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (99, 3, 15, 1, 167.52, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (23, 14, 12, 1, 281.17, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (51, 16, 12, 1, 281.93, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (5, 1, 20, 1, 176.87, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (43, 10, 30, 1, 296.89, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (18, 17, 30, 1, 92.76, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (43, 6, 30, 1, 199.76, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (2, 24, 22, 1, 240.37, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (23, 20, 26, 1, 250.69, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (12, 13, 7, 1, 67.66, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (62, 11, 16, 1, 16.95, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (31, 15, 18, 1, 286.9, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (75, 24, 1, 1, 89.54, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (89, 8, 4, 1, 205.32, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (40, 6, 26, 1, 210.53, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (89, 4, 19, 1, 119.75, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (29, 5, 31, 1, 58.66, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (54, 23, 31, 1, 230.84, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (98, 8, 6, 1, 164.77, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (10, 19, 8, 1, 32.6, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (74, 18, 10, 1, 61.89, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (15, 22, 14, 1, 219.32, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (12, 17, 29, 1, 245.48, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (17, 17, 27, 1, 145.19, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (72, 15, 20, 1, 221.13, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (33, 1, 14, 1, 179.82, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (55, 12, 5, 1, 169.23, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (9, 16, 3, 1, 96.82, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (99, 5, 27, 1, 121.72, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (58, 13, 25, 1, 37.87, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (84, 12, 8, 1, 65.86, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (68, 5, 15, 1, 252.92, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (39, 15, 28, 1, 166.6, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (32, 15, 23, 1, 59.21, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (93, 25, 8, 1, 24.18, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (79, 25, 2, 1, 83.59, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (13, 20, 3, 1, 142.24, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (32, 24, 3, 1, 129.65, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (70, 7, 4, 1, 54.94, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (30, 24, 21, 1, 179.58, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (31, 10, 10, 1, 295.92, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (53, 10, 18, 1, 32.37, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (81, 22, 28, 1, 173.42, NULL);
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (45, 21, 25, 1, 238.95, 'Paciente sensible a la zona');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (90, 14, 27, 1, 57.53, 'Requirió anestesia adicional');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (24, 25, 31, 1, 83.68, 'Sin complicaciones');
INSERT INTO detalle_consulta_tratamiento (id_cita,id_tratamiento,id_pieza_dental,cantidad,precio,observaciones) VALUES (39, 23, 10, 1, 244.65, NULL);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (72, 27, 9.71);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (72, 34, 2.21);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (32, 17, 2.83);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (83, 6, 9.3);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (48, 6, 5.82);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (25, 4, 3.42);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (87, 39, 6.43);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (10, 13, 8.24);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (76, 36, 2.95);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (27, 22, 3.73);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (2, 14, 9.43);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (95, 8, 7.72);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (97, 31, 9.23);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (90, 39, 7.33);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (51, 16, 5.97);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (100, 19, 4.43);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (69, 23, 3.78);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (47, 33, 8.95);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (60, 7, 8.23);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (93, 31, 7.85);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (41, 14, 4.34);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (53, 3, 6.06);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (29, 10, 1.15);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (71, 38, 6.21);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (54, 19, 2.37);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (43, 15, 4.42);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (32, 32, 5.96);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (88, 22, 3.32);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (63, 32, 5.15);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (94, 23, 2.52);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (93, 35, 5.39);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (70, 4, 5.72);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (10, 4, 7.88);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (53, 9, 8.58);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (30, 5, 7.36);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (65, 30, 4.36);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (80, 40, 9.21);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (85, 32, 1.14);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (69, 36, 4.7);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (3, 34, 7.5);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (69, 19, 1.15);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (90, 28, 8.26);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (23, 7, 9.26);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (68, 10, 3.17);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (80, 34, 3.27);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (46, 18, 8.15);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (11, 24, 9.63);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (59, 37, 3.19);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (90, 15, 3.7);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (11, 3, 1.84);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (49, 25, 5.97);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (8, 1, 7.33);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (11, 32, 8.61);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (83, 22, 6.09);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (13, 34, 9.27);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (30, 14, 9.11);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (89, 37, 5.28);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (6, 5, 7.16);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (36, 35, 6.07);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (5, 12, 9.36);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (41, 2, 9.65);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (76, 10, 7.77);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (92, 26, 9.36);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (39, 11, 6.08);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (73, 25, 7.09);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (70, 22, 4.45);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (95, 9, 8.11);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (89, 6, 5.51);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (45, 4, 1.88);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (44, 39, 7.92);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (77, 26, 9.72);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (42, 2, 6.71);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (58, 32, 3.05);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (71, 25, 4.89);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (88, 38, 6.95);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (11, 40, 3.66);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (32, 5, 1.74);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (20, 25, 7.41);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (82, 10, 7.66);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (41, 24, 1.96);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (1, 20, 5.0);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (98, 18, 1.92);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (12, 12, 4.88);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (72, 36, 5.61);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (14, 2, 1.81);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (71, 6, 6.37);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (42, 25, 1.11);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (53, 25, 8.01);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (93, 36, 9.15);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (32, 37, 5.69);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (88, 25, 2.53);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (35, 20, 3.42);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (19, 5, 2.5);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (36, 27, 3.7);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (10, 24, 3.27);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (77, 40, 2.76);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (14, 9, 3.74);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (51, 22, 8.57);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (49, 22, 4.96);
INSERT INTO detalle_consulta_insumo (id_detalle_consulta_tratamiento,id_insumo,cantidad_utilizada) VALUES (56, 39, 2.23);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (42, 2, 8, '001-001-337351730', '2025-11-02', 79.28, 11.89, 5, 86.17, '9264523831555659474268744626770944596573856076360', '9264523831555659474268744626770944596573856076360', '2025-11-02 18:43:00', 'Pruebas', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (14, 1, 2, '001-001-277818216', '2026-08-19', 96.58, 14.49, 10, 101.07, '5623466194290873375307400703189755344761637844022', '5623466194290873375307400703189755344761637844022', '2026-08-19 09:36:00', 'PRODUCCION', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (47, 3, 4, '001-001-491291026', '2025-09-27', 54.44, 8.17, 5, 57.61, '5656538687260113165413166695413403018954648400722', '5656538687260113165413166695413403018954648400722', '2025-09-27 16:18:00', 'PRODUCCION', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (96, 4, 9, '001-001-548473747', '2025-11-15', 54.15, 8.12, 0, 62.27, '2595774247628028081827686467885551925959817402671', '2595774247628028081827686467885551925959817402671', '2025-11-15 10:45:00', 'Pruebas', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (51, 4, 3, '001-001-620005942', '2026-07-10', 256.64, 38.5, 5, 290.14, '3077476844588096687398432518787068091494998388030', '3077476844588096687398432518787068091494998388030', '2026-07-10 18:57:00', 'PRODUCCION', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (81, 3, 12, '001-001-751019451', '2026-06-16', 304.54, 45.68, 5, 345.22, '6704126068941037138177191506476146801753931205667', '6704126068941037138177191506476146801753931205667', '2026-06-16 08:54:00', 'Pruebas', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (78, 2, 12, '001-001-420639452', '2025-10-29', 125.26, 18.79, 0, 144.05, '7723260803338451490502993277446510099135766349229', '7723260803338451490502993277446510099135766349229', '2025-10-29 09:29:00', 'PRODUCCION', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (95, 2, 2, '001-001-013598910', '2026-01-16', 286.08, 42.91, 0, 328.99, '1957711728708207504345321572508243198597434720359', '1957711728708207504345321572508243198597434720359', '2026-01-16 10:14:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (60, 3, 5, '001-001-351436695', '2025-12-22', 43.69, 6.55, 5, 45.24, '0253645471972042388906871524097098573900180549223', '0253645471972042388906871524097098573900180549223', '2025-12-22 14:44:00', 'Pruebas', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (35, 2, 2, '001-001-217661026', '2025-11-10', 63.08, 9.46, 10, 62.54, '1143137448083762817930281985501710721469059091680', '1143137448083762817930281985501710721469059091680', '2025-11-10 13:07:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (22, 4, 12, '001-001-424126613', '2026-04-21', 203.49, 30.52, 5, 229.01, '6121280622450211856879735495313287095799162890928', '6121280622450211856879735495313287095799162890928', '2026-04-21 14:22:00', 'PRODUCCION', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (76, 3, 12, '001-001-749070817', '2026-04-09', 149.93, 22.49, 10, 162.42, '0795519843402250921798305978893931311979619697251', '0795519843402250921798305978893931311979619697251', '2026-04-09 12:46:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (94, 1, 12, '001-001-615076674', '2025-10-26', 162.72, 24.41, 10, 177.13, '0699259172918076842202103798435148661082390137580', '0699259172918076842202103798435148661082390137580', '2025-10-26 17:39:00', 'Pruebas', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (56, 2, 10, '001-001-955365303', '2026-05-12', 179.34, 26.9, 0, 206.24, '1216772220581342661012083346051834242207603595588', '1216772220581342661012083346051834242207603595588', '2026-05-12 14:34:00', 'Pruebas', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (61, 3, 2, '001-001-423917959', '2025-12-15', 362.08, 54.31, 0, 416.39, '5986617199814949682990333248765441579951253434602', '5986617199814949682990333248765441579951253434602', '2025-12-15 10:39:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (43, 2, 1, '001-001-800742775', '2026-05-24', 195.34, 29.3, 0, 224.64, '8083246081948246128778851351880188249728561035185', '8083246081948246128778851351880188249728561035185', '2026-05-24 13:22:00', 'PRODUCCION', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (89, 1, 5, '001-001-029474737', '2026-01-31', 160.76, 24.11, 0, 184.87, '8722226589641182697728842356509985526432326961520', '8722226589641182697728842356509985526432326961520', '2026-01-31 17:25:00', 'Pruebas', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (93, 1, 11, '001-001-534050002', '2026-06-05', 399.01, 59.85, 0, 458.86, '9475983766493316524775998622848354106564116548193', '9475983766493316524775998622848354106564116548193', '2026-06-05 17:57:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (92, 2, 2, '001-001-523535948', '2025-10-14', 139.73, 20.96, 0, 160.69, '3042751771444405798750072831530094554619471980292', '3042751771444405798750072831530094554619471980292', '2025-10-14 08:37:00', 'PRODUCCION', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (92, 1, 7, '001-001-941182098', '2026-04-06', 259.73, 38.96, 10, 288.69, '6501801412726041567485627467893415964200154970796', '6501801412726041567485627467893415964200154970796', '2026-04-06 15:18:00', 'Pruebas', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (13, 2, 1, '001-001-915095061', '2025-10-27', 123.32, 18.5, 0, 141.82, '4188016389273314486448117981945467688784484060857', '4188016389273314486448117981945467688784484060857', '2025-10-27 17:14:00', 'Pruebas', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (89, 1, 7, '001-001-710509207', '2026-02-24', 293.39, 44.01, 5, 332.4, '3638590618880429026424848414614500663526930245646', '3638590618880429026424848414614500663526930245646', '2026-02-24 15:07:00', 'PRODUCCION', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (1, 3, 6, '001-001-891081038', '2025-10-06', 257.13, 38.57, 0, 295.7, '5318487421182813706618455907545979618166384662332', '5318487421182813706618455907545979618166384662332', '2025-10-06 10:08:00', 'Pruebas', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (96, 3, 12, '001-001-588202183', '2025-11-28', 345.68, 51.85, 10, 387.53, '6262369695631345647828850161712286270818787527726', '6262369695631345647828850161712286270818787527726', '2025-11-28 14:24:00', 'Pruebas', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (71, 1, 1, '001-001-798509547', '2026-05-17', 108.02, 16.2, 10, 114.22, '8842673571714909710221804909576837507595715438632', '8842673571714909710221804909576837507595715438632', '2026-05-17 17:33:00', 'Pruebas', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (2, 1, 11, '001-001-371522501', '2025-10-15', 183.81, 27.57, 10, 201.38, '9208371270575542630097562626828874806070012089444', '9208371270575542630097562626828874806070012089444', '2025-10-15 13:01:00', 'Pruebas', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (69, 1, 11, '001-001-773400863', '2026-02-10', 251.16, 37.67, 10, 278.83, '0835266293801277826289869081053502772981162165079', '0835266293801277826289869081053502772981162165079', '2026-02-10 16:29:00', 'PRODUCCION', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (9, 3, 2, '001-001-211975523', '2025-12-03', 292.98, 43.95, 5, 331.93, '9362201436615891377623634474160288176788685720285', '9362201436615891377623634474160288176788685720285', '2025-12-03 18:49:00', 'PRODUCCION', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (29, 3, 3, '001-001-498969055', '2026-08-23', 205.44, 30.82, 0, 236.26, '3568861541969743240302934409375882516368539538446', '3568861541969743240302934409375882516368539538446', '2026-08-23 16:56:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (30, 1, 9, '001-001-690928176', '2026-07-28', 119.52, 17.93, 0, 137.45, '1371287442180051605021955076204981867816273452312', '1371287442180051605021955076204981867816273452312', '2026-07-28 16:43:00', 'Pruebas', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (13, 2, 8, '001-001-968094455', '2026-06-17', 249.75, 37.46, 0, 287.21, '8570695096448649473898542790552070553284145255693', '8570695096448649473898542790552070553284145255693', '2026-06-17 11:26:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (72, 4, 5, '001-001-329266243', '2026-07-08', 235.28, 35.29, 5, 265.57, '7867461243567190019402003965759864268205521020197', '7867461243567190019402003965759864268205521020197', '2026-07-08 13:42:00', 'Pruebas', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (26, 1, 12, '001-001-755508289', '2025-10-07', 36.76, 5.51, 0, 42.27, '5755382944015553152572434237688423727843572237351', '5755382944015553152572434237688423727843572237351', '2025-10-07 13:22:00', 'PRODUCCION', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (24, 2, 8, '001-001-791468252', '2025-09-24', 87.87, 13.18, 0, 101.05, '8222611966675046498849922507455361964602536252463', '8222611966675046498849922507455361964602536252463', '2025-09-24 15:27:00', 'PRODUCCION', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (97, 3, 6, '001-001-917325654', '2026-01-09', 166.23, 24.93, 5, 186.16, '1152022431918149857735536084643359201891561736478', '1152022431918149857735536084643359201891561736478', '2026-01-09 14:39:00', 'Pruebas', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (19, 2, 11, '001-001-867279680', '2025-09-01', 372.14, 55.82, 5, 422.96, '6580123226248359410769701108503702168322618068349', '6580123226248359410769701108503702168322618068349', '2025-09-01 16:59:00', 'Pruebas', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (18, 2, 10, '001-001-641651146', '2025-11-13', 188.05, 28.21, 10, 206.26, '4659420341057125647277575184276820657662652101144', '4659420341057125647277575184276820657662652101144', '2025-11-13 17:31:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (20, 1, 9, '001-001-023762859', '2025-12-08', 82.52, 12.38, 0, 94.9, '2140002474360071235182309739291706239917751423069', '2140002474360071235182309739291706239917751423069', '2025-12-08 11:40:00', 'Pruebas', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (22, 3, 10, '001-001-128472772', '2026-05-04', 164.37, 24.66, 0, 189.03, '0074530106996067712977841631844261137289501223063', '0074530106996067712977841631844261137289501223063', '2026-05-04 10:56:00', 'PRODUCCION', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (100, 2, 6, '001-001-774171683', '2026-07-15', 34.7, 5.21, 10, 29.91, '8167124306091011063465027096984637887065780251231', '8167124306091011063465027096984637887065780251231', '2026-07-15 18:15:00', 'PRODUCCION', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (72, 4, 12, '001-001-113294986', '2026-02-28', 308.85, 46.33, 10, 345.18, '3468114319433933747652792943795593328086255910313', '3468114319433933747652792943795593328086255910313', '2026-02-28 17:15:00', 'PRODUCCION', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (12, 4, 10, '001-001-985568087', '2025-09-12', 94.8, 14.22, 0, 109.02, '7718659537500738488266073305152073455223105030571', '7718659537500738488266073305152073455223105030571', '2025-09-12 10:30:00', 'PRODUCCION', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (84, 2, 9, '001-001-661421567', '2025-10-14', 398.86, 59.83, 10, 448.69, '2073906433503969410813781099880614025252471605601', '2073906433503969410813781099880614025252471605601', '2025-10-14 12:12:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (84, 1, 2, '001-001-417304550', '2026-05-13', 267.55, 40.13, 0, 307.68, '8086239038515490253313362958688805218603966221993', '8086239038515490253313362958688805218603966221993', '2026-05-13 16:08:00', 'PRODUCCION', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (75, 2, 3, '001-001-331784499', '2026-04-17', 278.53, 41.78, 10, 310.31, '9497651057181039937867111096665200718461341249992', '9497651057181039937867111096665200718461341249992', '2026-04-17 18:12:00', 'PRODUCCION', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (57, 4, 12, '001-001-348854017', '2026-08-17', 348.04, 52.21, 0, 400.25, '4768739556701488259037914872129694605158533048880', '4768739556701488259037914872129694605158533048880', '2026-08-17 13:44:00', 'PRODUCCION', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (16, 1, 2, '001-001-758305157', '2025-08-31', 185.27, 27.79, 0, 213.06, '0779615013881170379218907044864264460826821031056', '0779615013881170379218907044864264460826821031056', '2025-08-31 13:58:00', 'PRODUCCION', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (54, 2, 3, '001-001-721651677', '2026-03-19', 120.91, 18.14, 10, 129.05, '5597307388780418342205950767748256964748822114772', '5597307388780418342205950767748256964748822114772', '2026-03-19 17:26:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (45, 2, 1, '001-001-687858677', '2026-07-19', 88.46, 13.27, 0, 101.73, '2035713359818944011488489055650539701833516117387', '2035713359818944011488489055650539701833516117387', '2026-07-19 12:26:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (48, 4, 5, '001-001-232078428', '2026-04-18', 214.79, 32.22, 0, 247.01, '1779404519757188961747509650405635383123411206523', '1779404519757188961747509650405635383123411206523', '2026-04-18 13:17:00', 'PRODUCCION', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (74, 2, 3, '001-001-076496453', '2025-09-27', 131.44, 19.72, 0, 151.16, '5009030378664331780975086036749182319383401482355', '5009030378664331780975086036749182319383401482355', '2025-09-27 14:52:00', 'PRODUCCION', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (84, 1, 5, '001-001-572031196', '2025-12-21', 189.78, 28.47, 10, 208.25, '4659338574752609545458190187346088960115351635939', '4659338574752609545458190187346088960115351635939', '2025-12-21 14:45:00', 'Pruebas', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (2, 4, 3, '001-001-915370465', '2025-12-18', 124.73, 18.71, 0, 143.44, '9905912045674421158342810618691188869644832404772', '9905912045674421158342810618691188869644832404772', '2025-12-18 16:36:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (73, 4, 12, '001-001-395758263', '2026-03-20', 54.13, 8.12, 5, 57.25, '9075872556266665569504953392165372655627041072622', '9075872556266665569504953392165372655627041072622', '2026-03-20 09:38:00', 'PRODUCCION', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (20, 4, 6, '001-001-867412341', '2026-04-15', 78.41, 11.76, 0, 90.17, '4783019149724627367113377537418094696096949832063', '4783019149724627367113377537418094696096949832063', '2026-04-15 18:47:00', 'PRODUCCION', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (76, 2, 9, '001-001-362287577', '2025-10-29', 274.31, 41.15, 0, 315.46, '3000456372060582519063768111260497667272039281092', '3000456372060582519063768111260497667272039281092', '2025-10-29 14:11:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (70, 4, 4, '001-001-659241287', '2025-09-29', 260.9, 39.13, 5, 295.03, '7105248169627955944877509845936469059047610316863', '7105248169627955944877509845936469059047610316863', '2025-09-29 09:56:00', 'Pruebas', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (18, 1, 4, '001-001-027235037', '2025-10-07', 290.7, 43.6, 10, 324.3, '2376498903374265985720740962606980680815602387416', '2376498903374265985720740962606980680815602387416', '2025-10-07 16:08:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (76, 2, 6, '001-001-067883992', '2026-03-24', 57.09, 8.56, 0, 65.65, '7131251763180097526741124216576083451996895462011', '7131251763180097526741124216576083451996895462011', '2026-03-24 15:31:00', 'PRODUCCION', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (6, 1, 11, '001-001-391049333', '2026-07-24', 121.18, 18.18, 5, 134.36, '2684105105024547821224180504261341323052144722179', '2684105105024547821224180504261341323052144722179', '2026-07-24 10:36:00', 'PRODUCCION', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (67, 4, 4, '001-001-635205123', '2025-10-01', 194.66, 29.2, 5, 218.86, '2772358515090470547842507912604378704784734680830', '2772358515090470547842507912604378704784734680830', '2025-10-01 14:48:00', 'Pruebas', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (70, 2, 11, '001-001-086929108', '2025-10-18', 251.98, 37.8, 0, 289.78, '7096813631507292149592723262034517652679890840829', '7096813631507292149592723262034517652679890840829', '2025-10-18 09:10:00', 'Pruebas', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (19, 4, 3, '001-001-939516731', '2025-08-29', 89.66, 13.45, 0, 103.11, '2951346208296436356843171249703419729866120312150', '2951346208296436356843171249703419729866120312150', '2025-08-29 13:22:00', 'PRODUCCION', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (70, 2, 9, '001-001-323797339', '2026-02-15', 57.38, 8.61, 0, 65.99, '4414307937429951594679153484006529205460513699318', '4414307937429951594679153484006529205460513699318', '2026-02-15 13:24:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (45, 3, 5, '001-001-478433630', '2026-02-04', 350.98, 52.65, 0, 403.63, '2874417874851395395306214591824835472713661621960', '2874417874851395395306214591824835472713661621960', '2026-02-04 12:31:00', 'PRODUCCION', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (47, 4, 10, '001-001-468224997', '2026-07-23', 348.65, 52.3, 5, 395.95, '9837025146303690260167513387263531127491258756987', '9837025146303690260167513387263531127491258756987', '2026-07-23 09:26:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (17, 1, 8, '001-001-373887548', '2026-04-05', 131.51, 19.73, 0, 151.24, '1495913711663294710441065490300165260172538765087', '1495913711663294710441065490300165260172538765087', '2026-04-05 16:13:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (97, 1, 12, '001-001-105962981', '2025-12-09', 370.45, 55.57, 10, 416.02, '8461618945473454327043476824948889306635613697813', '8461618945473454327043476824948889306635613697813', '2025-12-09 11:21:00', 'PRODUCCION', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (16, 2, 7, '001-001-778678110', '2025-11-19', 204.65, 30.7, 10, 225.35, '5789369951414290784016336765442455850798148401678', '5789369951414290784016336765442455850798148401678', '2025-11-19 10:31:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (92, 4, 8, '001-001-820350719', '2026-01-06', 52.66, 7.9, 5, 55.56, '6654853496393008370830333626590330348592659335816', '6654853496393008370830333626590330348592659335816', '2026-01-06 13:31:00', 'Pruebas', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (39, 3, 7, '001-001-216636673', '2025-12-18', 203.81, 30.57, 0, 234.38, '8520942708030842763845246471078529749567456531163', '8520942708030842763845246471078529749567456531163', '2025-12-18 14:26:00', 'Pruebas', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (27, 4, 5, '001-001-884452640', '2026-01-12', 121.95, 18.29, 0, 140.24, '2641128454601128618940806894360971179589928218353', '2641128454601128618940806894360971179589928218353', '2026-01-12 11:59:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (14, 2, 4, '001-001-294792955', '2026-02-04', 181.4, 27.21, 0, 208.61, '8056154227143369077096236796524099939728143867207', '8056154227143369077096236796524099939728143867207', '2026-02-04 15:30:00', 'Pruebas', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (55, 1, 3, '001-001-749989539', '2026-03-14', 111.78, 16.77, 0, 128.55, '3687400667146301598786734726871418982996699171442', '3687400667146301598786734726871418982996699171442', '2026-03-14 09:23:00', 'PRODUCCION', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (2, 4, 8, '001-001-888260923', '2026-04-15', 272.71, 40.91, 0, 313.62, '2298273422871170924256048932345050943668780539618', '2298273422871170924256048932345050943668780539618', '2026-04-15 08:37:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (65, 4, 6, '001-001-942634458', '2026-04-06', 192.55, 28.88, 0, 221.43, '3511018879286723839718670120274990374488108115285', '3511018879286723839718670120274990374488108115285', '2026-04-06 17:00:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (32, 4, 11, '001-001-101259462', '2026-07-21', 356.07, 53.41, 0, 409.48, '2913913047462630649997188277560227302346912879963', '2913913047462630649997188277560227302346912879963', '2026-07-21 09:53:00', 'Pruebas', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (63, 4, 7, '001-001-511573220', '2025-09-10', 114.71, 17.21, 10, 121.92, '4786440342614652494119852000140652205161130825466', '4786440342614652494119852000140652205161130825466', '2025-09-10 12:21:00', 'PRODUCCION', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (11, 3, 11, '001-001-114171677', '2026-04-23', 179.18, 26.88, 0, 206.06, '0114689646936633101098266467134401179485258006798', '0114689646936633101098266467134401179485258006798', '2026-04-23 17:38:00', 'Pruebas', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (52, 4, 9, '001-001-634623588', '2025-11-01', 292.6, 43.89, 5, 331.49, '2005526816644174455698748734963491260411479425932', '2005526816644174455698748734963491260411479425932', '2025-11-01 18:10:00', 'PRODUCCION', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (9, 3, 7, '001-001-122373597', '2026-03-15', 250.85, 37.63, 0, 288.48, '5497775888610979797681551123777481381297084212746', '5497775888610979797681551123777481381297084212746', '2026-03-15 11:09:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (55, 4, 7, '001-001-964290232', '2026-01-08', 188.91, 28.34, 10, 207.25, '7301089039107669067652465379025974257668741303771', '7301089039107669067652465379025974257668741303771', '2026-01-08 16:18:00', 'PRODUCCION', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (71, 3, 9, '001-001-365833374', '2025-11-14', 305.25, 45.79, 0, 351.04, '0852834578251794503275796822685137151741440412064', '0852834578251794503275796822685137151741440412064', '2025-11-14 16:33:00', 'Pruebas', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (64, 4, 8, '001-001-739827291', '2026-01-24', 373.1, 55.97, 5, 424.07, '7415449556401591813251332017493217050043433881167', '7415449556401591813251332017493217050043433881167', '2026-01-24 18:28:00', 'PRODUCCION', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (12, 4, 7, '001-001-249991020', '2026-02-16', 361.1, 54.16, 0, 415.26, '5987687577515165051481910727848640804483210112034', '5987687577515165051481910727848640804483210112034', '2026-02-16 10:03:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (92, 1, 5, '001-001-418694577', '2025-09-04', 48.51, 7.28, 0, 55.79, '4338127547310444428296257340629397549404829094583', '4338127547310444428296257340629397549404829094583', '2025-09-04 13:53:00', 'PRODUCCION', 'NORMAL', 3, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (37, 1, 3, '001-001-793691643', '2025-11-13', 218.29, 32.74, 0, 251.03, '3311524693632742934506604964877576008663883176049', '3311524693632742934506604964877576008663883176049', '2025-11-13 15:00:00', 'PRODUCCION', 'NORMAL', 3, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (98, 3, 11, '001-001-989344305', '2026-01-14', 286.59, 42.99, 0, 329.58, '0637243297218385456565010252571696525496909492643', '0637243297218385456565010252571696525496909492643', '2026-01-14 08:56:00', 'PRODUCCION', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (54, 4, 6, '001-001-005539737', '2026-07-03', 162.82, 24.42, 0, 187.24, '0507940213604856321230379767650003801943606523072', '0507940213604856321230379767650003801943606523072', '2026-07-03 17:50:00', 'PRODUCCION', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (60, 4, 10, '001-001-664893750', '2026-04-26', 49.5, 7.42, 0, 56.92, '4311507156247427034973871333056058841297366953596', '4311507156247427034973871333056058841297366953596', '2026-04-26 14:21:00', 'PRODUCCION', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (6, 4, 4, '001-001-987792654', '2026-07-22', 11.44, 1.72, 0, 13.16, '6424788348003514693912221821121816832433157647181', '6424788348003514693912221821121816832433157647181', '2026-07-22 11:12:00', 'Pruebas', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (41, 4, 11, '001-001-262583173', '2025-12-29', 369.2, 55.38, 10, 414.58, '5821262155477761387351754945676284224318207252053', '5821262155477761387351754945676284224318207252053', '2025-12-29 15:29:00', 'Pruebas', 'NORMAL', 2, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (64, 3, 5, '001-001-410567662', '2025-10-30', 19.64, 2.95, 5, 17.59, '2630856790002133862799779028744564571327457774731', '2630856790002133862799779028744564571327457774731', '2025-10-30 14:13:00', 'Pruebas', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (4, 3, 3, '001-001-620094970', '2025-08-27', 350.76, 52.61, 0, 403.37, '9088346475307919366689235115480150641092260051841', '9088346475307919366689235115480150641092260051841', '2025-08-27 09:08:00', 'Pruebas', 'NORMAL', 2, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (9, 4, 4, '001-001-139513728', '2026-04-10', 349.48, 52.42, 0, 401.9, '4746955620103859845728477268128749153928262967249', '4746955620103859845728477268128749153928262967249', '2026-04-10 16:07:00', 'Pruebas', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (65, 3, 7, '001-001-484188832', '2026-03-28', 74.29, 11.14, 0, 85.43, '5406737830193740529188101253076132062688678330077', '5406737830193740529188101253076132062688678330077', '2026-03-28 11:23:00', 'PRODUCCION', 'NORMAL', 1, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (3, 4, 1, '001-001-015633641', '2026-02-04', 141.48, 21.22, 0, 162.7, '6090867058366934213060226260847497795203639711769', '6090867058366934213060226260847497795203639711769', '2026-02-04 18:30:00', 'PRODUCCION', 'NORMAL', 2, NULL);
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (78, 4, 7, '001-001-548710143', '2026-05-20', 259.83, 38.97, 0, 298.8, '5700712420142362794813707487273209986285160490991', '5700712420142362794813707487273209986285160490991', '2026-05-20 10:37:00', 'PRODUCCION', 'NORMAL', 1, 'Cliente frecuente');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (11, 4, 12, '001-001-501517160', '2025-12-06', 131.47, 19.72, 0, 151.19, '2122462709314577870387951724436014110574999346540', '2122462709314577870387951724436014110574999346540', '2025-12-06 09:24:00', 'PRODUCCION', 'NORMAL', 1, 'Pago pendiente de confirmación');
INSERT INTO factura (id_paciente,id_metodo_pago,id_usuario,numero_factura,fecha_emision,subtotal,iva,descuento,total,clave_acceso,numero_autorizacion,fecha_autorizacion,ambiente,tipo_emision,id_estado_factura,observaciones) VALUES (33, 3, 9, '001-001-761420896', '2026-02-22', 200.56, 30.08, 0, 230.64, '6697208666624626980769359514823963348706731793398', '6697208666624626980769359514823963348706731793398', '2026-02-22 08:06:00', 'PRODUCCION', 'NORMAL', 3, 'Pago pendiente de confirmación');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (68, 'PRODUCTO_SERVICIO', 10, NULL, 3, 44.52, 0, 133.56, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (23, 'PRODUCTO_SERVICIO', 5, NULL, 1, 13.49, 0, 13.49, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (65, 'TRATAMIENTO', NULL, 73, 2, 247.1, 0, 494.2, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (26, 'TRATAMIENTO', NULL, 24, 3, 245.62, 0, 736.86, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (34, 'PRODUCTO_SERVICIO', 20, NULL, 2, 8.33, 0, 16.66, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (11, 'PRODUCTO_SERVICIO', 13, NULL, 1, 9.23, 0, 9.23, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (44, 'TRATAMIENTO', NULL, 31, 3, 151.2, 0, 453.6, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (2, 'TRATAMIENTO', NULL, 97, 2, 287.24, 2, 572.48, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (6, 'TRATAMIENTO', NULL, 67, 1, 240.66, 1, 239.66, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (78, 'PRODUCTO_SERVICIO', 16, NULL, 2, 45.9, 2, 89.8, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (55, 'PRODUCTO_SERVICIO', 11, NULL, 2, 59.97, 0, 119.94, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (47, 'PRODUCTO_SERVICIO', 20, NULL, 2, 5.32, 0, 10.64, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (43, 'TRATAMIENTO', NULL, 59, 1, 263.1, 1, 262.1, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (93, 'TRATAMIENTO', NULL, 78, 1, 50.02, 2, 48.02, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (36, 'TRATAMIENTO', NULL, 58, 2, 191.23, 1, 381.46, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (66, 'PRODUCTO_SERVICIO', 7, NULL, 3, 2.18, 0, 6.54, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (3, 'PRODUCTO_SERVICIO', 11, NULL, 1, 41.32, 0, 41.32, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (78, 'PRODUCTO_SERVICIO', 20, NULL, 2, 48.05, 0, 96.1, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (55, 'PRODUCTO_SERVICIO', 4, NULL, 3, 44.59, 0, 133.77, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (78, 'TRATAMIENTO', NULL, 19, 3, 262.91, 2, 786.73, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (92, 'TRATAMIENTO', NULL, 64, 1, 242.09, 0, 242.09, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (87, 'PRODUCTO_SERVICIO', 15, NULL, 1, 57.39, 1, 56.39, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (85, 'TRATAMIENTO', NULL, 28, 1, 63.57, 0, 63.57, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (14, 'PRODUCTO_SERVICIO', 1, NULL, 3, 11.29, 0, 33.87, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (50, 'PRODUCTO_SERVICIO', 9, NULL, 1, 40.62, 0, 40.62, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (86, 'TRATAMIENTO', NULL, 82, 3, 221.74, 0, 665.22, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (89, 'PRODUCTO_SERVICIO', 19, NULL, 1, 46.45, 2, 44.45, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (9, 'PRODUCTO_SERVICIO', 13, NULL, 2, 39.93, 2, 77.86, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (56, 'TRATAMIENTO', NULL, 34, 1, 47.97, 0, 47.97, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (15, 'TRATAMIENTO', NULL, 95, 2, 183.78, 0, 367.56, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (96, 'TRATAMIENTO', NULL, 48, 3, 51.31, 0, 153.93, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (49, 'TRATAMIENTO', NULL, 8, 2, 183.17, 0, 366.34, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (50, 'PRODUCTO_SERVICIO', 12, NULL, 2, 48.26, 0, 96.52, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (67, 'TRATAMIENTO', NULL, 51, 1, 17.62, 1, 16.62, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (41, 'TRATAMIENTO', NULL, 29, 2, 157.45, 1, 313.9, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (19, 'PRODUCTO_SERVICIO', 2, NULL, 1, 36.74, 0, 36.74, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (65, 'TRATAMIENTO', NULL, 91, 2, 178.58, 0, 357.16, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (64, 'PRODUCTO_SERVICIO', 13, NULL, 3, 5.41, 0, 16.23, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (20, 'TRATAMIENTO', NULL, 29, 3, 214.62, 0, 643.86, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (100, 'TRATAMIENTO', NULL, 94, 2, 126.67, 0, 253.34, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (3, 'PRODUCTO_SERVICIO', 14, NULL, 2, 41.32, 0, 82.64, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (97, 'PRODUCTO_SERVICIO', 3, NULL, 2, 32.61, 0, 65.22, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (37, 'TRATAMIENTO', NULL, 71, 3, 127.23, 0, 381.69, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (42, 'TRATAMIENTO', NULL, 39, 3, 145.4, 0, 436.2, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (74, 'TRATAMIENTO', NULL, 90, 2, 152.5, 0, 305.0, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (27, 'TRATAMIENTO', NULL, 26, 3, 224.57, 0, 673.71, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (47, 'TRATAMIENTO', NULL, 19, 3, 122.32, 1, 365.96, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (87, 'TRATAMIENTO', NULL, 13, 1, 116.34, 1, 115.34, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (23, 'TRATAMIENTO', NULL, 66, 1, 200.28, 2, 198.28, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (56, 'TRATAMIENTO', NULL, 93, 3, 130.14, 0, 390.42, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (16, 'TRATAMIENTO', NULL, 63, 2, 101.27, 2, 200.54, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (23, 'PRODUCTO_SERVICIO', 3, NULL, 3, 47.11, 1, 140.33, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (36, 'PRODUCTO_SERVICIO', 1, NULL, 2, 8.96, 0, 17.92, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (16, 'PRODUCTO_SERVICIO', 17, NULL, 3, 15.05, 2, 43.15, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (74, 'PRODUCTO_SERVICIO', 4, NULL, 2, 48.07, 0, 96.14, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (50, 'PRODUCTO_SERVICIO', 14, NULL, 3, 19.31, 0, 57.93, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (13, 'PRODUCTO_SERVICIO', 18, NULL, 1, 12.72, 0, 12.72, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (51, 'PRODUCTO_SERVICIO', 17, NULL, 1, 50.55, 2, 48.55, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (92, 'TRATAMIENTO', NULL, 85, 1, 270.82, 0, 270.82, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (77, 'TRATAMIENTO', NULL, 72, 1, 142.46, 0, 142.46, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (16, 'TRATAMIENTO', NULL, 74, 1, 73.78, 0, 73.78, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (12, 'PRODUCTO_SERVICIO', 3, NULL, 1, 58.84, 2, 56.84, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (39, 'PRODUCTO_SERVICIO', 6, NULL, 3, 26.54, 0, 79.62, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (32, 'PRODUCTO_SERVICIO', 17, NULL, 1, 54.47, 0, 54.47, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (85, 'PRODUCTO_SERVICIO', 19, NULL, 1, 30.45, 0, 30.45, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (67, 'PRODUCTO_SERVICIO', 18, NULL, 3, 31.61, 0, 94.83, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (85, 'TRATAMIENTO', NULL, 5, 1, 68.6, 0, 68.6, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (28, 'TRATAMIENTO', NULL, 71, 3, 76.57, 0, 229.71, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (36, 'TRATAMIENTO', NULL, 80, 3, 135.27, 2, 403.81, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (33, 'PRODUCTO_SERVICIO', 6, NULL, 2, 25.2, 0, 50.4, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (33, 'PRODUCTO_SERVICIO', 5, NULL, 3, 33.08, 0, 99.24, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (81, 'PRODUCTO_SERVICIO', 7, NULL, 3, 43.44, 2, 128.32, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (85, 'TRATAMIENTO', NULL, 20, 2, 105.16, 1, 209.32, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (49, 'TRATAMIENTO', NULL, 32, 3, 37.09, 0, 111.27, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (69, 'TRATAMIENTO', NULL, 71, 3, 130.93, 0, 392.79, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (82, 'TRATAMIENTO', NULL, 43, 2, 236.75, 0, 473.5, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (29, 'PRODUCTO_SERVICIO', 4, NULL, 1, 23.88, 0, 23.88, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (49, 'TRATAMIENTO', NULL, 23, 1, 165.05, 0, 165.05, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (76, 'PRODUCTO_SERVICIO', 17, NULL, 1, 22.24, 2, 20.24, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (37, 'PRODUCTO_SERVICIO', 4, NULL, 3, 54.0, 0, 162.0, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (41, 'PRODUCTO_SERVICIO', 12, NULL, 1, 48.75, 2, 46.75, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (71, 'PRODUCTO_SERVICIO', 19, NULL, 2, 9.4, 0, 18.8, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (88, 'TRATAMIENTO', NULL, 17, 3, 55.66, 2, 164.98, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (95, 'PRODUCTO_SERVICIO', 12, NULL, 1, 43.04, 0, 43.04, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (87, 'PRODUCTO_SERVICIO', 15, NULL, 3, 12.62, 0, 37.86, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (60, 'PRODUCTO_SERVICIO', 14, NULL, 2, 32.19, 0, 64.38, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (40, 'TRATAMIENTO', NULL, 53, 2, 234.61, 0, 469.22, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (82, 'TRATAMIENTO', NULL, 94, 1, 83.41, 0, 83.41, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (22, 'TRATAMIENTO', NULL, 96, 1, 96.47, 1, 95.47, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (2, 'PRODUCTO_SERVICIO', 17, NULL, 3, 56.08, 0, 168.24, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (62, 'PRODUCTO_SERVICIO', 18, NULL, 3, 42.48, 1, 126.44, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (2, 'TRATAMIENTO', NULL, 1, 3, 218.54, 2, 653.62, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (96, 'PRODUCTO_SERVICIO', 17, NULL, 1, 41.68, 0, 41.68, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (78, 'PRODUCTO_SERVICIO', 17, NULL, 1, 54.42, 0, 54.42, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (10, 'PRODUCTO_SERVICIO', 17, NULL, 1, 22.49, 0, 22.49, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (55, 'PRODUCTO_SERVICIO', 6, NULL, 2, 23.65, 0, 47.3, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (44, 'TRATAMIENTO', NULL, 99, 3, 259.47, 0, 778.41, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (39, 'PRODUCTO_SERVICIO', 9, NULL, 2, 14.36, 2, 26.72, 'Producto o servicio adicional');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (51, 'TRATAMIENTO', NULL, 83, 2, 161.93, 0, 323.86, 'Tratamiento aplicado en consulta');
INSERT INTO detalle_factura (id_factura,tipo_item,id_producto_servicio,id_detalle_consulta,cantidad,precio_unitario,descuento,subtotal,descripcion) VALUES (60, 'PRODUCTO_SERVICIO', 12, NULL, 1, 2.34, 1, 1.34, 'Producto o servicio adicional');
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (43, 93.01, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (1, 108.17, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (52, 109.59, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (56, 150.15, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (68, 156.72, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (53, 41.53, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (1, 50.91, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (29, 143.86, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (39, 112.53, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (69, 244.41, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (57, 198.6, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (21, 46.26, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (1, 110.97, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (15, 60.92, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (18, 121.39, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (5, 52.29, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (62, 288.11, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (16, 129.22, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (88, 215.72, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (97, 230.5, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (65, 219.17, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (17, 37.37, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (3, 42.21, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (65, 9.03, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (7, 205.1, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (55, 293.05, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (56, 146.66, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (63, 29.37, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (32, 187.2, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (32, 87.94, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (34, 298.31, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (86, 247.08, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (61, 213.41, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (90, 220.48, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (25, 297.8, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (30, 40.54, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (5, 85.79, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (19, 130.76, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (12, 259.98, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (53, 159.87, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (29, 104.17, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (8, 155.41, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (39, 37.47, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (36, 283.18, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (32, 99.35, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (24, 17.06, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (85, 224.7, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (37, 144.26, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (56, 59.53, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (47, 103.61, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (13, 202.34, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (43, 111.37, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (96, 234.75, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (31, 196.82, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (75, 118.29, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (17, 190.72, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (6, 178.04, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (25, 212.87, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (10, 282.84, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (39, 218.98, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (69, 217.63, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (17, 61.55, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (98, 256.76, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (47, 137.3, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (56, 24.97, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (68, 279.74, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (22, 181.75, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (38, 18.41, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (89, 61.11, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (64, 206.98, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (22, 134.13, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (72, 234.91, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (78, 85.09, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (1, 52.2, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (76, 210.53, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (65, 213.79, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (39, 256.48, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (91, 84.21, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (22, 71.06, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (38, 16.53, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (36, 278.54, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (7, 194.51, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (27, 162.71, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (84, 107.5, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (42, 29.56, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (93, 44.42, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (42, 295.65, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (46, 69.69, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (23, 80.52, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (69, 198.91, 1);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (93, 225.0, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (84, 80.92, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (57, 70.09, 3);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (27, 176.59, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (20, 136.59, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (48, 48.76, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (12, 151.31, 4);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (24, 245.6, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (25, 173.05, 2);
INSERT INTO pago (id_factura,monto,id_metodo_pago) VALUES (83, 88.2, 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 3, '2026-02-24', NULL, 'CANCELADA', 1046.68, NULL, 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 2, '2026-02-09', NULL, 'CANCELADA', 405.62, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 12, '2025-09-01', '2025-09-03', 'PARCIAL', 924.78, 'Entrega parcial confirmada', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 2, '2026-06-09', NULL, 'PENDIENTE', 1157.0, 'Pendiente de factura del proveedor', 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 4, '2026-03-03', NULL, 'PENDIENTE', 438.1, 'Pendiente de factura del proveedor', 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 1, '2025-11-26', NULL, 'PENDIENTE', 836.44, 'Entrega parcial confirmada', 12);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 4, '2026-08-15', '2026-09-01', 'PARCIAL', 1151.52, 'Entrega parcial confirmada', 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 6, '2026-02-17', NULL, 'CANCELADA', 274.04, NULL, 9);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 11, '2026-04-21', NULL, 'PENDIENTE', 80.75, NULL, 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 5, '2025-10-21', NULL, 'PENDIENTE', 791.74, 'Entrega parcial confirmada', 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 4, '2026-07-14', NULL, 'PENDIENTE', 378.68, 'Entrega parcial confirmada', 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 11, '2025-12-19', '2025-12-28', 'RECIBIDA', 1386.45, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 8, '2025-11-10', '2025-11-15', 'PARCIAL', 375.56, 'Entrega parcial confirmada', 6);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 10, '2025-12-11', '2025-12-16', 'RECIBIDA', 572.72, NULL, 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (10, 3, '2026-03-11', '2026-03-26', 'PARCIAL', 819.2, 'Pendiente de factura del proveedor', 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 3, '2025-11-12', '2025-11-23', 'RECIBIDA', 555.16, NULL, 5);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 11, '2026-07-06', '2026-07-16', 'RECIBIDA', 1225.54, 'Pendiente de factura del proveedor', 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 3, '2026-02-16', '2026-02-28', 'PARCIAL', 264.28, 'Entrega parcial confirmada', 12);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 2, '2025-10-30', NULL, 'PENDIENTE', 887.87, 'Pendiente de factura del proveedor', 5);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 2, '2026-08-11', '2026-08-17', 'RECIBIDA', 313.71, 'Entrega parcial confirmada', 6);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 8, '2026-06-07', NULL, 'CANCELADA', 747.87, 'Entrega parcial confirmada', 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 3, '2026-01-30', '2026-02-13', 'PARCIAL', 657.06, 'Entrega parcial confirmada', 9);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 8, '2026-03-26', '2026-04-09', 'PARCIAL', 171.25, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 10, '2025-10-11', '2025-10-15', 'PARCIAL', 391.03, NULL, 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 6, '2025-09-30', NULL, 'CANCELADA', 1438.54, NULL, 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 6, '2025-10-02', '2025-10-13', 'PARCIAL', 717.56, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 4, '2026-02-03', '2026-02-06', 'PARCIAL', 1133.14, NULL, 12);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 7, '2026-03-21', NULL, 'PENDIENTE', 1059.38, 'Entrega parcial confirmada', 6);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 12, '2025-09-07', NULL, 'PENDIENTE', 1010.98, NULL, 8);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (10, 3, '2026-01-22', NULL, 'PENDIENTE', 262.99, NULL, 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 2, '2025-09-19', NULL, 'PENDIENTE', 875.32, 'Entrega parcial confirmada', 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 8, '2025-11-26', '2025-12-14', 'PARCIAL', 1062.92, 'Entrega parcial confirmada', 8);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 12, '2025-12-04', '2025-12-20', 'RECIBIDA', 1183.03, 'Pendiente de factura del proveedor', 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 2, '2025-09-28', '2025-10-01', 'PARCIAL', 1327.68, NULL, 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 9, '2025-09-22', '2025-09-24', 'PARCIAL', 624.77, 'Entrega parcial confirmada', 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 9, '2026-02-02', '2026-02-22', 'RECIBIDA', 777.72, 'Pendiente de factura del proveedor', 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 3, '2026-01-11', '2026-01-15', 'RECIBIDA', 806.18, NULL, 12);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 7, '2026-02-26', NULL, 'PENDIENTE', 367.41, NULL, 12);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 10, '2026-04-27', NULL, 'PENDIENTE', 1234.01, 'Entrega parcial confirmada', 8);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 11, '2026-02-12', NULL, 'CANCELADA', 1249.52, NULL, 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 11, '2026-07-27', NULL, 'CANCELADA', 332.36, NULL, 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 6, '2026-05-10', '2026-05-12', 'RECIBIDA', 397.32, NULL, 9);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 2, '2026-07-01', '2026-07-03', 'PARCIAL', 1146.96, 'Entrega parcial confirmada', 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 4, '2025-09-19', NULL, 'PENDIENTE', 398.49, NULL, 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (10, 1, '2025-12-02', NULL, 'CANCELADA', 116.24, 'Entrega parcial confirmada', 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 1, '2026-07-20', '2026-07-31', 'RECIBIDA', 1440.17, 'Pendiente de factura del proveedor', 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 7, '2026-03-14', '2026-03-20', 'RECIBIDA', 1068.85, NULL, 6);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 12, '2026-08-26', NULL, 'PENDIENTE', 778.16, NULL, 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (10, 7, '2026-07-20', NULL, 'CANCELADA', 900.22, NULL, 5);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 3, '2026-05-11', NULL, 'CANCELADA', 164.19, 'Pendiente de factura del proveedor', 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 4, '2026-06-20', '2026-06-27', 'PARCIAL', 1490.45, 'Pendiente de factura del proveedor', 9);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (10, 11, '2026-04-03', '2026-04-19', 'RECIBIDA', 1188.76, 'Entrega parcial confirmada', 5);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 10, '2025-11-26', NULL, 'CANCELADA', 108.02, 'Pendiente de factura del proveedor', 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 4, '2025-09-25', '2025-09-29', 'PARCIAL', 1439.12, 'Pendiente de factura del proveedor', 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 2, '2025-12-24', NULL, 'PENDIENTE', 256.8, 'Entrega parcial confirmada', 9);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 8, '2026-03-08', NULL, 'PENDIENTE', 709.47, NULL, 5);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 2, '2026-02-13', '2026-03-05', 'RECIBIDA', 576.83, NULL, 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 12, '2025-09-07', NULL, 'CANCELADA', 424.02, 'Entrega parcial confirmada', 5);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 11, '2026-05-13', '2026-05-18', 'PARCIAL', 1458.94, 'Entrega parcial confirmada', 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 5, '2025-11-20', NULL, 'CANCELADA', 643.1, 'Pendiente de factura del proveedor', 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 8, '2026-06-25', '2026-07-13', 'RECIBIDA', 1275.01, 'Entrega parcial confirmada', 6);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 11, '2026-01-17', NULL, 'CANCELADA', 783.62, 'Entrega parcial confirmada', 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 10, '2025-10-16', NULL, 'PENDIENTE', 1124.51, NULL, 12);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 1, '2025-11-27', '2025-12-02', 'PARCIAL', 471.46, NULL, 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 2, '2026-07-13', '2026-07-27', 'PARCIAL', 1317.53, 'Pendiente de factura del proveedor', 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 8, '2026-01-07', NULL, 'CANCELADA', 981.6, 'Entrega parcial confirmada', 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 3, '2026-04-13', NULL, 'PENDIENTE', 1380.32, 'Entrega parcial confirmada', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 7, '2026-02-15', '2026-02-19', 'RECIBIDA', 510.06, 'Pendiente de factura del proveedor', 8);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 12, '2026-05-04', NULL, 'CANCELADA', 215.77, 'Entrega parcial confirmada', 1);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 3, '2025-12-23', NULL, 'CANCELADA', 261.0, NULL, 6);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (10, 1, '2026-02-26', NULL, 'CANCELADA', 140.48, 'Entrega parcial confirmada', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 4, '2025-09-25', NULL, 'PENDIENTE', 356.66, NULL, 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 5, '2026-04-19', '2026-04-26', 'RECIBIDA', 171.21, NULL, 5);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 2, '2026-07-26', '2026-08-11', 'RECIBIDA', 1313.37, 'Pendiente de factura del proveedor', 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 3, '2026-08-15', NULL, 'PENDIENTE', 184.04, 'Entrega parcial confirmada', 6);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 3, '2026-06-05', '2026-06-18', 'PARCIAL', 1415.82, 'Entrega parcial confirmada', 8);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 12, '2026-06-07', '2026-06-22', 'PARCIAL', 564.3, 'Pendiente de factura del proveedor', 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 1, '2026-05-19', '2026-05-23', 'PARCIAL', 1097.95, 'Pendiente de factura del proveedor', 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 6, '2025-11-24', '2025-11-26', 'RECIBIDA', 268.23, 'Entrega parcial confirmada', 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 6, '2025-11-22', NULL, 'PENDIENTE', 1198.42, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 9, '2026-07-26', NULL, 'PENDIENTE', 1482.95, NULL, 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (8, 11, '2025-12-09', NULL, 'PENDIENTE', 102.9, 'Pendiente de factura del proveedor', 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 12, '2025-12-24', '2026-01-07', 'PARCIAL', 363.4, NULL, 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (10, 1, '2026-03-25', '2026-04-07', 'RECIBIDA', 73.48, 'Entrega parcial confirmada', 9);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 12, '2026-03-16', NULL, 'CANCELADA', 990.92, 'Entrega parcial confirmada', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 6, '2026-03-26', '2026-04-14', 'RECIBIDA', 667.48, 'Entrega parcial confirmada', 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 8, '2025-11-19', NULL, 'CANCELADA', 591.03, 'Pendiente de factura del proveedor', 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 9, '2025-10-20', NULL, 'CANCELADA', 603.27, 'Pendiente de factura del proveedor', 12);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 11, '2026-05-16', '2026-05-21', 'RECIBIDA', 1493.28, NULL, 2);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 10, '2026-07-26', NULL, 'CANCELADA', 200.33, 'Pendiente de factura del proveedor', 10);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 2, '2025-09-03', NULL, 'CANCELADA', 779.87, NULL, 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (5, 7, '2026-04-14', '2026-04-23', 'PARCIAL', 1176.48, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (2, 4, '2025-09-07', NULL, 'CANCELADA', 1428.3, 'Entrega parcial confirmada', 8);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (7, 11, '2025-11-13', NULL, 'CANCELADA', 61.03, 'Entrega parcial confirmada', 4);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (9, 5, '2025-09-10', '2025-09-20', 'RECIBIDA', 495.73, 'Entrega parcial confirmada', 11);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 1, '2026-06-09', NULL, 'CANCELADA', 97.38, NULL, 3);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (6, 9, '2026-05-20', '2026-06-01', 'RECIBIDA', 297.1, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (4, 9, '2025-11-04', NULL, 'CANCELADA', 329.36, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (1, 10, '2026-05-01', NULL, 'CANCELADA', 236.86, 'Pendiente de factura del proveedor', 7);
INSERT INTO orden_compra (id_proveedor,id_usuario,fecha_orden,fecha_entrega,estado,total,observaciones,solicitado_por) VALUES (3, 7, '2026-02-10', '2026-02-28', 'RECIBIDA', 279.74, NULL, 2);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (91, 9, 52.9, 9.55, 505.2);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (51, 17, 84.55, 2.55, 215.6);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (42, 14, 13.86, 0.58, 8.04);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (2, 38, 19.54, 9.35, 182.7);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (70, 6, 59.32, 0.57, 33.81);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (94, 9, 98.42, 9.59, 943.85);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (100, 23, 22.72, 9.86, 224.02);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (29, 20, 23.41, 12.64, 295.9);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (93, 25, 78.19, 9.96, 778.77);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (36, 6, 93.82, 9.49, 890.35);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (82, 38, 87.36, 1.84, 160.74);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (77, 8, 15.17, 4.38, 66.44);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (24, 6, 12.35, 12.7, 156.84);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (27, 26, 14.56, 11.97, 174.28);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (53, 5, 51.22, 9.46, 484.54);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (27, 27, 40.65, 4.84, 196.75);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (58, 11, 22.08, 0.35, 7.73);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (23, 37, 64.97, 12.85, 834.86);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (16, 22, 99.41, 7.36, 731.66);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (79, 39, 56.92, 2.54, 144.58);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (95, 17, 93.03, 3.05, 283.74);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (4, 35, 7.19, 7.77, 55.87);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (20, 14, 87.35, 1.9, 165.96);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (28, 2, 36.12, 3.45, 124.61);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (94, 9, 30.42, 7.33, 222.98);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (12, 23, 72.27, 9.85, 711.86);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (60, 32, 46.43, 14.21, 659.77);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (25, 17, 21.43, 10.37, 222.23);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (92, 18, 96.38, 1.72, 165.77);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (99, 38, 34.6, 11.95, 413.47);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (93, 32, 46.18, 6.8, 314.02);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (77, 18, 82.51, 9.42, 777.24);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (78, 25, 45.78, 8.59, 393.25);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (48, 5, 47.69, 13.36, 637.14);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (66, 17, 60.75, 4.54, 275.81);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (83, 34, 38.46, 0.64, 24.61);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (24, 21, 45.79, 2.95, 135.08);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (32, 5, 25.44, 5.7, 145.01);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (19, 21, 16.62, 4.92, 81.77);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (2, 22, 25.31, 8.6, 217.67);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (42, 15, 58.36, 5.91, 344.91);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (78, 14, 55.09, 1.72, 94.75);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (36, 39, 94.9, 12.15, 1153.04);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (86, 5, 59.53, 9.76, 581.01);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (88, 28, 35.19, 4.94, 173.84);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (26, 4, 81.26, 7.58, 615.95);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (36, 27, 16.33, 6.9, 112.68);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (77, 21, 61.16, 3.7, 226.29);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (3, 19, 6.69, 11.79, 78.88);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (74, 1, 91.61, 4.41, 404.0);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (52, 3, 90.1, 13.79, 1242.48);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (6, 22, 66.25, 1.23, 81.49);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (13, 27, 73.71, 4.27, 314.74);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (97, 23, 43.03, 8.44, 363.17);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (41, 32, 63.17, 6.02, 380.28);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (90, 30, 51.87, 9.69, 502.62);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (16, 24, 94.08, 1.72, 161.82);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (29, 4, 83.42, 2.25, 187.69);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (42, 28, 26.5, 1.5, 39.75);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (93, 24, 82.53, 8.16, 673.44);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (1, 4, 29.67, 11.82, 350.7);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (15, 4, 94.98, 1.31, 124.42);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (43, 40, 80.2, 5.82, 466.76);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (90, 11, 92.86, 8.84, 820.88);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (16, 9, 35.34, 2.39, 84.46);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (75, 27, 65.51, 10.09, 661.0);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (67, 34, 27.85, 7.27, 202.47);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (63, 18, 35.58, 11.02, 392.09);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (29, 6, 30.06, 4.58, 137.67);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (11, 23, 58.06, 13.12, 761.75);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (85, 14, 71.02, 1.31, 93.04);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (64, 4, 25.19, 10.12, 254.92);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (60, 25, 22.85, 1.75, 39.99);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (27, 38, 77.35, 7.81, 604.1);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (41, 20, 72.31, 9.9, 715.87);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (65, 7, 91.84, 3.44, 315.93);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (47, 25, 97.63, 13.04, 1273.1);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (66, 13, 79.1, 2.98, 235.72);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (36, 28, 20.6, 4.75, 97.85);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (74, 7, 18.99, 13.17, 250.1);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (96, 8, 27.85, 13.43, 374.03);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (24, 18, 7.72, 10.0, 77.2);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (58, 23, 30.23, 13.92, 420.8);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (11, 23, 45.99, 2.43, 111.76);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (65, 28, 53.25, 0.99, 52.72);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (35, 24, 14.29, 9.8, 140.04);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (94, 28, 23.42, 3.0, 70.26);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (23, 39, 31.21, 9.19, 286.82);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (67, 28, 15.37, 0.94, 14.45);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (32, 8, 25.86, 0.99, 25.6);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (5, 37, 30.29, 1.17, 35.44);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (13, 18, 26.51, 9.38, 248.66);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (92, 26, 42.23, 1.7, 71.79);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (94, 18, 52.04, 2.73, 142.07);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (27, 23, 65.51, 10.65, 697.68);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (37, 1, 13.95, 7.65, 106.72);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (90, 40, 50.29, 4.72, 237.37);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (89, 16, 21.17, 10.29, 217.84);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (22, 12, 36.55, 6.94, 253.66);
INSERT INTO detalle_orden_compra (id_orden,id_insumo,cantidad,precio_unitario,subtotal) VALUES (2, 31, 45.65, 0.51, 23.28);
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (1, 'Diabetes tipo 2', NULL, NULL, '2025-01-14', '2026-03-25 00:26:25.576635');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (2, NULL, 'Metformina 850mg', 'Paciente colaborador', '2025-03-23', '2026-07-07 10:52:35.282038');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (3, 'Cirugía cardíaca previa', NULL, 'Paciente colaborador', '2024-09-11', '2026-05-22 18:39:51.410928');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (4, 'Hipertensión controlada', 'Ninguno', NULL, '2024-11-28', '2025-11-18 18:37:48.397229');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (5, NULL, NULL, 'Requiere sedación leve para procedimientos', '2024-10-13', '2026-02-20 20:35:20.213143');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (6, 'Diabetes tipo 2', 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2025-06-16', '2025-10-30 00:46:04.397506');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (7, 'Cirugía cardíaca previa', 'Losartán 50mg', NULL, '2025-01-15', '2026-06-05 21:43:48.818169');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (8, NULL, NULL, 'Paciente colaborador', '2024-10-14', '2025-09-22 05:17:05.400331');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (9, 'Diabetes tipo 2', 'Ninguno', 'Paciente colaborador', '2025-02-05', '2025-12-16 10:44:41.162590');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (10, 'Diabetes tipo 2', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2025-07-10', '2026-01-28 10:08:10.162862');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (11, 'Sin antecedentes relevantes', 'Metformina 850mg', 'Paciente colaborador', '2025-07-16', '2025-11-26 04:19:39.766456');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (12, 'Sin antecedentes relevantes', NULL, 'Paciente colaborador', '2025-01-05', '2026-04-30 11:39:31.713797');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (13, 'Diabetes tipo 2', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2025-01-14', '2025-12-17 16:51:55.939053');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (14, 'Cirugía cardíaca previa', 'Ninguno', NULL, '2025-04-16', '2025-12-12 00:25:22.256954');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (15, 'Diabetes tipo 2', NULL, NULL, '2025-07-12', '2025-10-07 11:48:41.509534');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (16, 'Sin antecedentes relevantes', 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2024-12-29', '2026-07-28 07:32:19.571787');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (17, 'Hipertensión controlada', 'Metformina 850mg', 'Paciente colaborador', '2025-01-19', '2025-10-10 22:21:29.271343');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (18, NULL, 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2025-07-04', '2026-07-10 18:49:28.600920');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (19, 'Sin antecedentes relevantes', 'Metformina 850mg', NULL, '2024-11-20', '2026-03-04 04:24:08.346304');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (20, NULL, 'Losartán 50mg', 'Paciente colaborador', '2025-05-16', '2025-09-20 12:23:10.636563');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (21, NULL, 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2024-11-15', '2026-04-22 07:01:47.446823');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (22, 'Cirugía cardíaca previa', 'Ninguno', 'Requiere sedación leve para procedimientos', '2024-11-28', '2026-07-12 05:16:47.148425');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (23, 'Hipertensión controlada', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2024-12-11', '2025-10-05 20:15:59.660015');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (24, 'Diabetes tipo 2', 'Metformina 850mg', 'Paciente colaborador', '2025-01-27', '2025-10-21 13:14:03.275823');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (25, 'Cirugía cardíaca previa', 'Ninguno', 'Paciente colaborador', '2024-11-03', '2026-03-05 20:50:45.880593');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (26, 'Diabetes tipo 2', 'Losartán 50mg', NULL, '2024-10-09', '2025-10-26 18:20:36.097939');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (27, 'Cirugía cardíaca previa', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2024-10-30', '2026-02-18 12:31:03.739907');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (28, NULL, 'Ninguno', 'Paciente colaborador', '2025-06-21', '2026-05-26 23:03:00.570980');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (29, 'Cirugía cardíaca previa', 'Metformina 850mg', 'Paciente colaborador', '2024-11-10', '2026-02-24 17:39:42.842118');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (30, NULL, NULL, 'Paciente colaborador', '2025-01-18', '2025-11-19 23:06:38.623815');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (31, 'Hipertensión controlada', 'Ninguno', 'Requiere sedación leve para procedimientos', '2025-06-14', '2026-05-17 05:47:11.195383');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (32, 'Hipertensión controlada', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2025-01-29', '2025-12-10 21:27:49.131976');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (33, 'Cirugía cardíaca previa', 'Losartán 50mg', 'Paciente colaborador', '2025-04-04', '2026-04-25 14:40:59.095739');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (34, 'Sin antecedentes relevantes', 'Metformina 850mg', NULL, '2024-10-26', '2026-08-16 23:26:26.154319');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (35, 'Diabetes tipo 2', NULL, 'Paciente colaborador', '2025-02-08', '2026-01-07 18:05:29.015987');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (36, NULL, 'Losartán 50mg', 'Paciente colaborador', '2025-01-17', '2025-09-05 15:07:19.695050');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (37, 'Cirugía cardíaca previa', NULL, NULL, '2025-07-16', '2026-08-28 02:18:24.590277');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (38, 'Sin antecedentes relevantes', 'Metformina 850mg', NULL, '2024-09-09', '2026-03-28 05:07:57.080724');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (39, 'Sin antecedentes relevantes', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2024-09-24', '2025-11-21 19:14:34.996233');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (40, NULL, NULL, 'Paciente colaborador', '2025-05-07', '2026-07-04 05:39:24.355533');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (41, 'Hipertensión controlada', 'Metformina 850mg', 'Paciente colaborador', '2024-10-23', '2026-02-07 00:51:15.564243');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (42, 'Cirugía cardíaca previa', 'Losartán 50mg', NULL, '2025-02-19', '2025-09-23 21:41:56.415603');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (43, 'Diabetes tipo 2', 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2024-11-19', '2026-05-09 06:19:19.916003');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (44, 'Hipertensión controlada', 'Ninguno', 'Requiere sedación leve para procedimientos', '2025-05-28', '2026-03-15 07:49:09.027824');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (45, NULL, 'Metformina 850mg', NULL, '2025-03-14', '2025-10-25 19:57:40.500193');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (46, NULL, 'Ninguno', 'Paciente colaborador', '2025-03-06', '2026-01-30 09:37:12.999797');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (47, 'Hipertensión controlada', 'Ninguno', 'Paciente colaborador', '2025-03-28', '2025-12-04 16:54:05.656185');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (48, 'Sin antecedentes relevantes', NULL, 'Paciente colaborador', '2025-07-01', '2026-04-03 02:06:57.061764');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (49, 'Diabetes tipo 2', 'Metformina 850mg', NULL, '2025-08-06', '2025-10-07 19:47:03.382296');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (50, 'Cirugía cardíaca previa', 'Ninguno', 'Requiere sedación leve para procedimientos', '2025-08-21', '2026-05-12 02:57:48.061982');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (51, 'Diabetes tipo 2', 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2024-12-20', '2026-08-21 12:27:13.083078');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (52, 'Hipertensión controlada', 'Metformina 850mg', NULL, '2025-05-18', '2025-10-03 20:52:22.768002');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (53, 'Sin antecedentes relevantes', 'Losartán 50mg', 'Paciente colaborador', '2024-10-26', '2025-10-30 12:21:56.830926');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (54, 'Diabetes tipo 2', NULL, 'Paciente colaborador', '2025-06-26', '2025-12-04 21:51:53.598706');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (55, 'Cirugía cardíaca previa', 'Ninguno', 'Requiere sedación leve para procedimientos', '2024-12-24', '2026-07-17 06:45:30.531738');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (56, 'Hipertensión controlada', 'Ninguno', 'Paciente colaborador', '2025-06-04', '2026-08-01 21:38:11.810089');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (57, NULL, 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2025-05-11', '2026-04-09 21:16:50.720186');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (58, 'Sin antecedentes relevantes', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2025-02-08', '2026-01-05 04:11:11.999767');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (59, 'Diabetes tipo 2', 'Ninguno', 'Paciente colaborador', '2025-02-08', '2026-05-16 12:17:35.110541');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (60, 'Sin antecedentes relevantes', 'Ninguno', 'Paciente colaborador', '2024-09-19', '2025-09-20 17:37:36.719637');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (61, 'Sin antecedentes relevantes', 'Ninguno', NULL, '2025-03-16', '2026-08-14 15:19:48.539856');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (62, 'Cirugía cardíaca previa', NULL, 'Paciente colaborador', '2025-04-29', '2026-03-16 16:41:28.360257');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (63, NULL, 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2025-07-12', '2026-07-24 20:42:01.300263');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (64, 'Diabetes tipo 2', 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2024-09-26', '2025-11-12 20:18:45.063535');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (65, 'Cirugía cardíaca previa', 'Metformina 850mg', NULL, '2024-09-08', '2026-06-10 00:12:11.090256');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (66, 'Cirugía cardíaca previa', 'Metformina 850mg', NULL, '2024-11-18', '2026-02-01 18:05:48.473221');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (67, 'Sin antecedentes relevantes', 'Losartán 50mg', 'Paciente colaborador', '2024-10-09', '2025-12-23 01:53:29.756276');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (68, NULL, 'Ninguno', 'Requiere sedación leve para procedimientos', '2025-05-17', '2026-01-29 02:57:10.391634');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (69, 'Sin antecedentes relevantes', NULL, NULL, '2024-10-05', '2026-07-16 08:10:53.655204');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (70, NULL, 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2025-04-28', '2026-02-13 09:23:14.151759');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (71, NULL, 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2025-01-18', '2026-07-06 09:16:03.075376');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (72, NULL, 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2025-08-19', '2026-03-11 15:29:18.798589');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (73, 'Sin antecedentes relevantes', 'Metformina 850mg', NULL, '2025-06-26', '2025-09-18 21:16:52.957535');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (74, NULL, NULL, 'Requiere sedación leve para procedimientos', '2025-04-05', '2026-05-10 23:37:14.169412');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (75, 'Hipertensión controlada', 'Losartán 50mg', 'Requiere sedación leve para procedimientos', '2025-06-18', '2026-06-15 07:05:25.464146');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (76, 'Sin antecedentes relevantes', 'Losartán 50mg', NULL, '2024-09-21', '2026-05-02 17:32:19.648249');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (77, 'Hipertensión controlada', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2024-10-13', '2025-09-06 11:15:30.808430');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (78, 'Diabetes tipo 2', NULL, 'Paciente colaborador', '2025-07-20', '2025-12-14 22:27:01.550565');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (79, 'Cirugía cardíaca previa', 'Losartán 50mg', NULL, '2025-02-12', '2025-12-01 15:20:06.294647');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (80, NULL, NULL, NULL, '2024-09-23', '2025-10-23 11:20:31.584786');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (81, 'Cirugía cardíaca previa', NULL, 'Requiere sedación leve para procedimientos', '2025-07-04', '2026-05-14 10:11:18.424629');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (82, NULL, 'Losartán 50mg', NULL, '2024-09-05', '2026-07-10 17:35:42.283137');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (83, NULL, 'Ninguno', NULL, '2024-10-03', '2026-08-03 01:40:09.769778');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (84, 'Cirugía cardíaca previa', 'Ninguno', 'Paciente colaborador', '2025-05-24', '2026-04-29 07:26:13.086900');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (85, NULL, NULL, 'Paciente colaborador', '2025-07-07', '2026-04-03 14:02:00.539883');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (86, 'Sin antecedentes relevantes', 'Ninguno', NULL, '2024-11-23', '2026-06-30 08:22:33.211344');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (87, 'Hipertensión controlada', 'Metformina 850mg', 'Requiere sedación leve para procedimientos', '2024-10-06', '2026-01-22 22:22:44.646559');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (88, 'Sin antecedentes relevantes', NULL, 'Paciente colaborador', '2024-10-06', '2025-11-26 09:09:04.099835');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (89, 'Hipertensión controlada', NULL, NULL, '2024-10-31', '2026-02-21 10:49:39.633706');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (90, 'Hipertensión controlada', 'Losartán 50mg', NULL, '2025-04-06', '2025-11-29 07:20:35.597397');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (91, 'Cirugía cardíaca previa', 'Losartán 50mg', 'Paciente colaborador', '2025-06-10', '2026-07-20 21:29:46.896712');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (92, 'Sin antecedentes relevantes', 'Metformina 850mg', 'Paciente colaborador', '2024-09-20', '2025-10-15 00:30:07.347210');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (93, NULL, 'Ninguno', 'Paciente colaborador', '2024-09-24', '2026-06-22 17:18:14.304537');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (94, 'Diabetes tipo 2', 'Ninguno', 'Paciente colaborador', '2025-04-08', '2025-11-13 10:08:17.382242');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (95, NULL, 'Ninguno', 'Paciente colaborador', '2025-01-25', '2025-10-10 23:35:38.841704');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (96, 'Sin antecedentes relevantes', 'Losartán 50mg', NULL, '2025-06-04', '2026-06-20 17:04:09.712440');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (97, 'Diabetes tipo 2', 'Ninguno', NULL, '2024-11-26', '2026-03-15 17:43:56.393983');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (98, 'Cirugía cardíaca previa', 'Ninguno', NULL, '2025-06-01', '2026-05-15 20:39:22.246424');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (99, 'Cirugía cardíaca previa', 'Metformina 850mg', NULL, '2025-08-26', '2025-09-05 01:00:59.402691');
INSERT INTO historial_clinico (id_paciente,antecedentes,medicamentos,observacion_general,fecha_apertura,ultima_actualizacion) VALUES (100, 'Cirugía cardíaca previa', 'Ninguno', NULL, '2024-11-02', '2025-10-25 07:16:01.742322');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (46, 2, 'Detectada durante anamnesis', '2026-03-04');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (93, 4, 'Reportada por familiar', '2026-06-24');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (2, 2, 'Reportada por familiar', '2025-01-12');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (65, 2, 'Reportada por familiar', '2025-03-13');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (91, 4, 'Reacción leve reportada por el paciente', '2025-05-27');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (23, 2, 'Reportada por familiar', '2026-03-07');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (84, 3, 'Detectada durante anamnesis', '2026-08-04');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (92, 2, 'Reportada por familiar', '2025-04-08');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (98, 3, 'Detectada durante anamnesis', '2025-05-13');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (9, 4, 'Detectada durante anamnesis', '2026-05-15');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (61, 2, 'Reportada por familiar', '2026-05-04');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (17, 3, 'Reportada por familiar', '2025-08-07');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (75, 4, 'Reacción leve reportada por el paciente', '2025-12-30');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (6, 1, 'Confirmada en consulta previa', '2026-03-10');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (30, 1, 'Reacción leve reportada por el paciente', '2026-04-08');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (64, 4, 'Reportada por familiar', '2025-01-18');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (98, 2, 'Confirmada en consulta previa', '2025-06-19');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (14, 2, 'Detectada durante anamnesis', '2025-06-21');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (97, 4, 'Reacción leve reportada por el paciente', '2026-08-04');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (8, 3, 'Reacción leve reportada por el paciente', '2025-06-03');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (5, 1, 'Detectada durante anamnesis', '2025-01-13');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (98, 3, 'Reacción leve reportada por el paciente', '2024-11-17');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (23, 3, 'Reacción leve reportada por el paciente', '2026-01-25');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (90, 4, 'Detectada durante anamnesis', '2025-03-29');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (18, 2, 'Confirmada en consulta previa', '2025-01-03');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (33, 4, 'Detectada durante anamnesis', '2025-10-01');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (87, 3, 'Confirmada en consulta previa', '2026-04-06');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (26, 2, 'Detectada durante anamnesis', '2025-02-15');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (68, 2, 'Reacción leve reportada por el paciente', '2024-08-27');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (75, 1, 'Reacción leve reportada por el paciente', '2026-08-13');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (27, 1, 'Confirmada en consulta previa', '2024-09-24');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (1, 3, 'Detectada durante anamnesis', '2026-03-09');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (73, 1, 'Reportada por familiar', '2026-01-22');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (24, 4, 'Confirmada en consulta previa', '2026-02-18');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (27, 4, 'Reportada por familiar', '2026-07-15');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (46, 2, 'Reacción leve reportada por el paciente', '2025-07-06');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (57, 4, 'Detectada durante anamnesis', '2025-02-11');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (10, 1, 'Confirmada en consulta previa', '2025-10-04');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (67, 3, 'Reacción leve reportada por el paciente', '2025-07-26');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (16, 4, 'Confirmada en consulta previa', '2024-11-06');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (7, 3, 'Reacción leve reportada por el paciente', '2024-12-11');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (29, 3, 'Reportada por familiar', '2025-03-27');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (50, 3, 'Reacción leve reportada por el paciente', '2025-01-17');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (21, 3, 'Reacción leve reportada por el paciente', '2025-09-17');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (69, 2, 'Reportada por familiar', '2025-10-04');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (52, 1, 'Reacción leve reportada por el paciente', '2025-02-24');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (75, 4, 'Reportada por familiar', '2025-10-29');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (84, 1, 'Reacción leve reportada por el paciente', '2025-12-11');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (44, 4, 'Reportada por familiar', '2026-07-02');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (26, 3, 'Reacción leve reportada por el paciente', '2024-09-28');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (18, 2, 'Reportada por familiar', '2026-01-28');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (97, 1, 'Confirmada en consulta previa', '2024-10-06');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (64, 1, 'Reacción leve reportada por el paciente', '2025-03-12');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (45, 1, 'Detectada durante anamnesis', '2026-08-17');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (77, 1, 'Detectada durante anamnesis', '2026-02-28');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (17, 3, 'Reacción leve reportada por el paciente', '2026-01-19');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (14, 1, 'Detectada durante anamnesis', '2025-06-17');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (65, 2, 'Reportada por familiar', '2026-01-01');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (56, 4, 'Reportada por familiar', '2026-08-19');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (30, 1, 'Reacción leve reportada por el paciente', '2024-09-12');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (4, 2, 'Detectada durante anamnesis', '2025-01-11');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (88, 1, 'Detectada durante anamnesis', '2026-08-25');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (7, 4, 'Detectada durante anamnesis', '2026-07-05');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (90, 2, 'Detectada durante anamnesis', '2025-09-30');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (90, 4, 'Confirmada en consulta previa', '2025-08-09');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (15, 4, 'Reacción leve reportada por el paciente', '2026-03-28');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (79, 3, 'Reportada por familiar', '2025-03-09');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (25, 3, 'Detectada durante anamnesis', '2024-09-06');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (8, 2, 'Confirmada en consulta previa', '2026-03-10');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (12, 1, 'Confirmada en consulta previa', '2025-08-29');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (53, 1, 'Reacción leve reportada por el paciente', '2025-04-22');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (93, 2, 'Reacción leve reportada por el paciente', '2025-07-08');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (10, 1, 'Confirmada en consulta previa', '2026-02-07');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (57, 2, 'Reportada por familiar', '2025-06-29');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (6, 3, 'Reportada por familiar', '2026-06-07');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (78, 2, 'Reportada por familiar', '2026-02-10');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (17, 4, 'Detectada durante anamnesis', '2024-10-16');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (85, 1, 'Reacción leve reportada por el paciente', '2026-05-21');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (10, 3, 'Confirmada en consulta previa', '2026-01-21');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (64, 3, 'Confirmada en consulta previa', '2026-03-27');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (57, 3, 'Reportada por familiar', '2024-10-18');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (100, 3, 'Confirmada en consulta previa', '2025-10-11');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (68, 3, 'Reportada por familiar', '2026-06-05');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (90, 1, 'Reacción leve reportada por el paciente', '2025-06-08');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (45, 4, 'Detectada durante anamnesis', '2024-11-03');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (36, 1, 'Confirmada en consulta previa', '2026-08-05');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (18, 2, 'Reportada por familiar', '2025-07-21');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (95, 2, 'Reacción leve reportada por el paciente', '2025-02-21');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (48, 2, 'Reacción leve reportada por el paciente', '2025-09-15');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (31, 4, 'Detectada durante anamnesis', '2024-11-18');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (15, 1, 'Detectada durante anamnesis', '2026-06-20');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (5, 3, 'Reportada por familiar', '2024-10-15');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (76, 4, 'Reportada por familiar', '2026-06-16');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (11, 1, 'Reportada por familiar', '2025-12-21');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (79, 4, 'Detectada durante anamnesis', '2025-11-05');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (3, 4, 'Detectada durante anamnesis', '2024-11-02');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (57, 1, 'Confirmada en consulta previa', '2025-01-30');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (27, 4, 'Confirmada en consulta previa', '2025-07-19');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (85, 4, 'Reacción leve reportada por el paciente', '2025-09-09');
INSERT INTO historial_alergia (id_historial_clinico,id_tipo_alergia,observaciones,fecha_registro) VALUES (85, 3, 'Reacción leve reportada por el paciente', '2025-10-01');
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (35, 6, 14.07, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (39, 6, 13.86, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (17, 10, 3.4, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (2, 6, 10.94, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (40, 7, 13.01, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (4, 2, 8.39, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (19, 9, 7.06, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (37, 10, 11.58, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (17, 3, 14.41, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (30, 4, 2.15, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (1, 5, 12.03, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (18, 2, 14.98, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (35, 5, 5.2, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (26, 1, 9.31, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (24, 5, 9.96, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (39, 1, 2.04, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (37, 6, 12.57, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (12, 8, 7.05, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (29, 1, 7.1, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (23, 8, 9.64, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (36, 4, 6.25, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (38, 2, 4.29, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (40, 9, 4.85, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (5, 8, 2.86, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (18, 5, 13.06, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (9, 4, 9.53, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (10, 10, 9.91, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (15, 2, 9.89, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (12, 9, 12.94, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (38, 6, 0.82, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (15, 1, 14.29, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (17, 5, 0.44, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (23, 9, 10.83, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (39, 4, 5.38, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (5, 9, 6.77, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (33, 2, 3.71, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (21, 10, 5.7, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (27, 2, 9.7, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (19, 3, 0.57, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (22, 7, 13.48, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (24, 8, 14.15, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (19, 10, 0.66, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (24, 1, 4.5, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (2, 2, 9.21, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (21, 9, 10.79, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (33, 10, 10.75, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (14, 7, 12.49, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (3, 3, 5.84, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (6, 2, 14.39, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (15, 10, 7.65, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (37, 9, 11.06, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (35, 2, 12.74, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (34, 1, 9.19, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (34, 9, 6.73, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (18, 4, 12.57, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (19, 4, 5.06, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (24, 4, 6.95, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (8, 4, 6.79, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (27, 6, 1.38, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (36, 9, 1.33, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (29, 7, 3.6, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (9, 9, 3.83, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (27, 10, 10.06, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (39, 5, 11.98, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (22, 6, 1.95, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (27, 7, 7.67, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (32, 4, 13.52, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (30, 1, 2.67, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (27, 5, 11.53, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (31, 2, 2.07, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (3, 7, 0.55, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (11, 2, 2.16, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (34, 7, 13.58, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (23, 3, 6.15, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (19, 2, 5.18, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (22, 10, 9.21, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (7, 1, 1.29, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (27, 8, 11.16, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (28, 5, 11.41, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (9, 3, 10.91, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (38, 9, 1.44, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (1, 10, 8.98, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (30, 7, 4.94, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (38, 5, 14.18, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (7, 4, 4.6, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (22, 1, 8.55, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (34, 10, 7.72, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (21, 7, 4.91, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (12, 3, 0.82, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (34, 5, 8.71, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (40, 6, 1.67, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (8, 5, 4.25, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (29, 4, 13.3, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (19, 5, 14.83, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (18, 3, 1.62, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (11, 1, 9.06, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (3, 9, 8.16, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (13, 1, 7.43, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (14, 5, 14.14, true);
INSERT INTO insumo_proveedor (id_insumo,id_proveedor,precio_unitario,activo) VALUES (37, 7, 11.03, true);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (34, 'ENTRADA', 41.72, 'AJUSTE', NULL, '2026-02-05 10:58:38.947956', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (8, 'SALIDA', 44.56, 'MERMA', NULL, '2025-10-14 00:59:36.923404', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (6, 'ENTRADA', 49.66, 'COMPRA', 11, '2025-08-31 23:06:29.735310', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (15, 'ENTRADA', 17.03, 'AJUSTE', NULL, '2026-06-15 09:27:55.444947', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (30, 'ENTRADA', 35.63, 'AJUSTE', NULL, '2025-12-25 02:25:47.775628', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (28, 'ENTRADA', 46.69, 'AJUSTE', NULL, '2026-08-19 06:21:45.566225', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (36, 'ENTRADA', 47.51, 'COMPRA', NULL, '2025-11-01 16:38:01.392845', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (25, 'ENTRADA', 33.99, 'AJUSTE', NULL, '2026-02-06 13:41:10.315007', 8);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (10, 'SALIDA', 40.88, 'AJUSTE', NULL, '2025-09-26 16:25:48.852426', 8);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (19, 'ENTRADA', 10.73, 'COMPRA', 93, '2025-12-27 18:43:38.501537', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (14, 'ENTRADA', 22.28, 'AJUSTE', NULL, '2025-09-03 22:31:58.310437', 9);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (40, 'ENTRADA', 35.79, 'COMPRA', 34, '2026-02-19 18:47:35.334138', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (25, 'ENTRADA', 32.25, 'AJUSTE', NULL, '2026-03-20 02:51:49.564998', 9);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (12, 'SALIDA', 42.19, 'MERMA', NULL, '2026-01-01 08:51:13.362494', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (32, 'SALIDA', 40.04, 'MERMA', NULL, '2025-12-22 18:33:40.649572', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (23, 'SALIDA', 15.48, 'USO_CLINICO', NULL, '2026-08-04 02:20:05.602353', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (19, 'SALIDA', 48.5, 'MERMA', NULL, '2026-07-05 13:22:20.214623', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (28, 'ENTRADA', 9.63, 'AJUSTE', NULL, '2026-07-06 10:30:35.938130', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (8, 'SALIDA', 35.15, 'AJUSTE', NULL, '2026-07-19 10:46:41.628652', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (31, 'SALIDA', 30.45, 'AJUSTE', NULL, '2026-01-30 06:36:55.363633', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (2, 'SALIDA', 14.13, 'USO_CLINICO', NULL, '2025-12-13 20:37:29.547211', 7);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (4, 'SALIDA', 13.82, 'MERMA', NULL, '2025-09-15 14:12:15.490922', 7);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (26, 'SALIDA', 21.83, 'MERMA', NULL, '2026-01-22 22:45:28.263988', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (18, 'SALIDA', 36.68, 'MERMA', NULL, '2025-10-03 20:53:42.093130', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (3, 'SALIDA', 22.93, 'USO_CLINICO', NULL, '2025-10-22 13:54:58.902358', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (11, 'ENTRADA', 39.2, 'COMPRA', 79, '2026-06-17 23:47:23.103180', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (22, 'ENTRADA', 30.64, 'COMPRA', 3, '2025-12-20 16:41:09.426290', 7);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (6, 'SALIDA', 45.7, 'AJUSTE', NULL, '2026-06-21 11:46:58.247044', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (4, 'ENTRADA', 18.74, 'COMPRA', 69, '2026-05-06 18:07:09.665882', 7);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (15, 'SALIDA', 40.26, 'MERMA', NULL, '2026-01-11 18:09:09.577423', 6);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (27, 'ENTRADA', 28.09, 'COMPRA', 5, '2025-09-26 23:20:58.716312', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (34, 'ENTRADA', 25.57, 'AJUSTE', NULL, '2026-01-01 04:44:04.382345', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (11, 'SALIDA', 15.77, 'USO_CLINICO', NULL, '2025-11-20 12:58:52.331891', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (16, 'ENTRADA', 14.35, 'COMPRA', 49, '2026-04-07 13:09:25.110251', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (26, 'ENTRADA', 41.1, 'AJUSTE', NULL, '2025-12-02 07:10:30.141190', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (5, 'ENTRADA', 25.72, 'AJUSTE', NULL, '2026-03-11 03:44:58.408793', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (1, 'ENTRADA', 5.68, 'AJUSTE', NULL, '2025-11-28 12:48:15.523212', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (39, 'SALIDA', 39.45, 'MERMA', NULL, '2026-03-30 09:08:50.911566', 9);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (2, 'SALIDA', 14.43, 'USO_CLINICO', NULL, '2026-07-19 03:35:28.420265', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (17, 'SALIDA', 19.45, 'MERMA', NULL, '2026-01-26 14:16:17.216081', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (15, 'SALIDA', 28.49, 'MERMA', NULL, '2026-02-22 13:11:11.074265', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (35, 'ENTRADA', 19.74, 'AJUSTE', NULL, '2025-12-02 20:35:21.848703', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (26, 'SALIDA', 38.37, 'AJUSTE', NULL, '2025-10-06 00:25:39.893116', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (29, 'ENTRADA', 29.32, 'COMPRA', 30, '2026-03-03 15:44:17.356119', 8);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (24, 'SALIDA', 28.59, 'AJUSTE', NULL, '2026-02-11 10:24:11.340955', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (22, 'ENTRADA', 40.67, 'COMPRA', NULL, '2026-03-02 22:32:42.007725', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (14, 'SALIDA', 30.08, 'USO_CLINICO', NULL, '2025-12-18 13:31:38.754957', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (26, 'SALIDA', 26.65, 'AJUSTE', NULL, '2026-01-06 08:08:43.949813', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (4, 'SALIDA', 13.35, 'MERMA', NULL, '2026-05-09 06:01:03.702317', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (22, 'ENTRADA', 2.79, 'AJUSTE', NULL, '2025-10-03 14:43:45.016550', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (18, 'ENTRADA', 38.0, 'AJUSTE', NULL, '2025-10-05 12:40:43.985274', 9);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (32, 'SALIDA', 48.01, 'USO_CLINICO', NULL, '2026-07-14 20:13:55.924244', 6);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (30, 'SALIDA', 26.21, 'AJUSTE', NULL, '2026-01-04 08:57:49.347811', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (6, 'ENTRADA', 21.86, 'COMPRA', 97, '2025-10-05 09:18:38.549541', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (11, 'ENTRADA', 9.14, 'AJUSTE', NULL, '2026-02-04 01:59:40.955947', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (3, 'SALIDA', 25.26, 'AJUSTE', NULL, '2025-08-30 22:36:40.969247', 9);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (32, 'ENTRADA', 37.7, 'AJUSTE', NULL, '2026-06-06 21:50:35.551410', 7);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (1, 'SALIDA', 6.76, 'MERMA', NULL, '2026-06-04 09:24:31.297946', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (18, 'SALIDA', 31.14, 'MERMA', NULL, '2025-10-14 17:36:11.737994', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (11, 'ENTRADA', 15.22, 'COMPRA', 92, '2026-05-07 00:59:44.546977', 6);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (34, 'SALIDA', 24.13, 'USO_CLINICO', NULL, '2026-07-12 10:02:48.354451', 6);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (9, 'ENTRADA', 26.69, 'AJUSTE', NULL, '2026-05-28 08:05:56.647550', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (21, 'SALIDA', 9.78, 'MERMA', NULL, '2025-10-01 22:26:23.435620', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (1, 'SALIDA', 35.37, 'USO_CLINICO', NULL, '2026-06-04 03:12:58.567092', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (7, 'SALIDA', 17.22, 'USO_CLINICO', NULL, '2026-06-05 21:08:13.328285', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (30, 'ENTRADA', 4.27, 'COMPRA', 2, '2025-11-14 05:55:57.338672', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (18, 'SALIDA', 41.22, 'MERMA', NULL, '2025-11-10 11:44:30.974589', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (20, 'SALIDA', 31.6, 'MERMA', NULL, '2026-05-20 21:53:14.336861', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (36, 'ENTRADA', 4.8, 'COMPRA', NULL, '2025-09-12 04:57:58.502473', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (18, 'ENTRADA', 13.88, 'COMPRA', NULL, '2026-05-05 14:58:51.287892', 9);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (38, 'SALIDA', 17.18, 'AJUSTE', NULL, '2025-10-03 17:44:43.708882', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (18, 'SALIDA', 11.26, 'USO_CLINICO', NULL, '2026-07-25 08:55:46.451787', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (14, 'ENTRADA', 46.55, 'COMPRA', NULL, '2026-05-18 00:45:31.475247', 8);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (1, 'SALIDA', 4.81, 'USO_CLINICO', NULL, '2025-10-23 12:17:13.178558', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (33, 'SALIDA', 21.84, 'MERMA', NULL, '2026-08-23 04:52:49.359382', 6);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (20, 'ENTRADA', 12.8, 'AJUSTE', NULL, '2026-03-05 01:42:50.898393', 7);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (25, 'SALIDA', 18.39, 'AJUSTE', NULL, '2025-09-17 00:41:15.578679', 6);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (34, 'ENTRADA', 44.28, 'COMPRA', 82, '2025-11-10 09:33:55.350729', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (10, 'SALIDA', 28.46, 'MERMA', NULL, '2025-09-22 09:34:56.494371', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (17, 'ENTRADA', 28.34, 'AJUSTE', NULL, '2026-06-13 19:07:52.148780', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (23, 'ENTRADA', 2.24, 'AJUSTE', NULL, '2026-05-23 13:38:39.660429', 8);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (23, 'SALIDA', 11.48, 'AJUSTE', NULL, '2026-03-11 11:22:24.891943', 4);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (25, 'SALIDA', 9.77, 'AJUSTE', NULL, '2025-11-26 13:15:05.015395', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (13, 'SALIDA', 18.69, 'USO_CLINICO', NULL, '2026-08-19 07:24:32.768670', 1);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (38, 'SALIDA', 17.09, 'MERMA', NULL, '2025-11-19 17:41:07.182109', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (33, 'ENTRADA', 30.73, 'COMPRA', 83, '2026-06-27 23:33:47.215122', 8);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (26, 'ENTRADA', 49.79, 'AJUSTE', NULL, '2025-10-05 02:37:53.965329', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (4, 'ENTRADA', 43.3, 'AJUSTE', NULL, '2026-02-19 18:08:00.963934', 10);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (30, 'SALIDA', 9.51, 'AJUSTE', NULL, '2026-03-03 18:37:55.445903', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (35, 'ENTRADA', 2.87, 'COMPRA', 92, '2026-01-15 00:46:57.732761', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (12, 'ENTRADA', 5.06, 'COMPRA', NULL, '2026-08-01 17:02:52.746054', 11);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (4, 'SALIDA', 5.78, 'AJUSTE', NULL, '2026-08-20 03:56:13.553855', 5);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (13, 'ENTRADA', 17.3, 'AJUSTE', NULL, '2025-09-06 05:35:05.225371', 12);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (11, 'SALIDA', 26.3, 'AJUSTE', NULL, '2025-09-09 17:27:55.857918', 7);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (27, 'ENTRADA', 4.18, 'COMPRA', 11, '2026-04-09 09:11:24.516696', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (29, 'ENTRADA', 14.5, 'COMPRA', 53, '2025-08-28 20:11:34.630124', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (1, 'SALIDA', 14.41, 'MERMA', NULL, '2025-10-17 15:00:04.124418', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (22, 'SALIDA', 28.84, 'AJUSTE', NULL, '2026-05-09 01:24:23.422519', 2);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (37, 'SALIDA', 5.32, 'USO_CLINICO', NULL, '2026-05-04 03:28:35.831306', 3);
INSERT INTO movimiento_inventario (id_insumo,tipo,cantidad,motivo,id_orden,fecha_movimiento,registrado_por) VALUES (6, 'ENTRADA', 16.56, 'COMPRA', 2, '2025-08-28 19:04:28.312839', 4);
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (82, 'Trato al cliente', 'WhatsApp', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (93, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (83, 'Facturación', 'Telefónico', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (7, 'Tiempo de espera', 'Correo', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (36, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (29, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (23, 'Trato al cliente', 'Correo', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (57, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (46, 'Calidad de atención', 'Correo', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (99, 'Calidad de atención', 'WhatsApp', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (88, 'Facturación', 'Presencial', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (50, 'Facturación', 'Telefónico', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (56, 'Trato al cliente', 'Correo', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (44, 'Calidad de atención', 'Correo', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (66, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (60, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (67, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (60, 'Calidad de atención', 'Correo', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (73, 'Tiempo de espera', 'Presencial', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (90, 'Servicio', 'Correo', 'Reclamo relacionado con servicio registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (21, 'Tiempo de espera', 'WhatsApp', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (44, 'Servicio', 'Telefónico', 'Reclamo relacionado con servicio registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (40, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (24, 'Servicio', 'WhatsApp', 'Reclamo relacionado con servicio registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (59, 'Calidad de atención', 'WhatsApp', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (52, 'Tiempo de espera', 'Telefónico', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (93, 'Trato al cliente', 'Correo', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (87, 'Tiempo de espera', 'Correo', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (30, 'Calidad de atención', 'Presencial', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (55, 'Trato al cliente', 'WhatsApp', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (4, 'Facturación', 'Telefónico', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (77, 'Calidad de atención', 'Telefónico', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (97, 'Facturación', 'Telefónico', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (43, 'Servicio', 'Presencial', 'Reclamo relacionado con servicio registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (99, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (51, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (85, 'Facturación', 'Telefónico', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (39, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (31, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (93, 'Facturación', 'Telefónico', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (72, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (21, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (71, 'Tiempo de espera', 'Telefónico', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (86, 'Tiempo de espera', 'WhatsApp', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (32, 'Servicio', 'WhatsApp', 'Reclamo relacionado con servicio registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (41, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (37, 'Tiempo de espera', 'WhatsApp', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (10, 'Trato al cliente', 'WhatsApp', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (95, 'Calidad de atención', 'Presencial', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (78, 'Facturación', 'Telefónico', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (47, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (77, 'Tiempo de espera', 'Presencial', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (30, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (6, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (12, 'Trato al cliente', 'WhatsApp', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (24, 'Tiempo de espera', 'Telefónico', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (40, 'Tiempo de espera', 'WhatsApp', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (34, 'Tiempo de espera', 'Telefónico', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (51, 'Calidad de atención', 'Presencial', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (11, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (52, 'Servicio', 'Telefónico', 'Reclamo relacionado con servicio registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (17, 'Calidad de atención', 'WhatsApp', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (59, 'Servicio', 'WhatsApp', 'Reclamo relacionado con servicio registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (86, 'Tiempo de espera', 'WhatsApp', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (39, 'Tiempo de espera', 'Correo', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (82, 'Servicio', 'WhatsApp', 'Reclamo relacionado con servicio registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (48, 'Tiempo de espera', 'Correo', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (47, 'Servicio', 'Telefónico', 'Reclamo relacionado con servicio registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (69, 'Tiempo de espera', 'Presencial', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (1, 'Trato al cliente', 'Correo', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (66, 'Calidad de atención', 'WhatsApp', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (7, 'Tiempo de espera', 'Correo', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (16, 'Tiempo de espera', 'WhatsApp', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (7, 'Calidad de atención', 'Correo', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (55, 'Trato al cliente', 'Correo', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (70, 'Trato al cliente', 'Telefónico', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (46, 'Tiempo de espera', 'Presencial', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (42, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (15, 'Trato al cliente', 'Presencial', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (95, 'Tiempo de espera', 'Telefónico', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (11, 'Calidad de atención', 'Presencial', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (94, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (36, 'Trato al cliente', 'WhatsApp', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (80, 'Facturación', 'WhatsApp', 'Reclamo relacionado con facturación registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (10, 'Trato al cliente', 'Correo', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (19, 'Calidad de atención', 'Presencial', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (66, 'Servicio', 'Correo', 'Reclamo relacionado con servicio registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (96, 'Trato al cliente', 'WhatsApp', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (3, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (84, 'Servicio', 'WhatsApp', 'Reclamo relacionado con servicio registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (25, 'Calidad de atención', 'Correo', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (79, 'Calidad de atención', 'Telefónico', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (7, 'Trato al cliente', 'WhatsApp', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (98, 'Tiempo de espera', 'Correo', 'Reclamo relacionado con tiempo de espera registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (89, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'Resuelto');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (86, 'Servicio', 'WhatsApp', 'Reclamo relacionado con servicio registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (87, 'Trato al cliente', 'Correo', 'Reclamo relacionado con trato al cliente registrado por el paciente.', 'Pendiente');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (53, 'Facturación', 'Presencial', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (85, 'Facturación', 'Correo', 'Reclamo relacionado con facturación registrado por el paciente.', 'En proceso');
INSERT INTO reclamo_cliente (id_paciente,tipo,canal,descripcion,estado) VALUES (60, 'Calidad de atención', 'Correo', 'Reclamo relacionado con calidad de atención registrado por el paciente.', 'Pendiente');


-- =========================================================================
-- CONSULTAS SELECT DE VERIFICACIÓN (punto 4: mínimo 5 tipos exigidos)
-- =========================================================================

-- 1) JOIN entre múltiples tablas (Pregunta 3)
-- ¿Cuál es el detalle completo de las citas de un paciente específico,
-- incluyendo el tratamiento aplicado, la pieza dental intervenida y el
-- odontólogo responsable?
SELECT p.nombres, p.apellidos, c.fecha_hora, o.nombres AS odontologo,
       t.nombre AS tratamiento, pd.nombre AS pieza_dental, dct.precio
FROM cita c
INNER JOIN paciente p ON p.id_paciente = c.id_paciente
INNER JOIN odontologo o ON o.id_odontologo = c.id_odontologo
INNER JOIN detalle_consulta_tratamiento dct ON dct.id_cita = c.id_cita
INNER JOIN tratamiento t ON t.id_tratamiento = dct.id_tratamiento
INNER JOIN pieza_dental pd ON pd.id_pieza_dental = dct.id_pieza_dental
WHERE c.id_paciente = 2;

-- 2) GROUP BY con función de agregación (Pregunta 1)
-- ¿Cuántas citas hay registradas por cada estado?
SELECT ec.nombre AS estado, COUNT(*) AS total_citas
FROM cita c
INNER JOIN estado_cita ec ON ec.id_estado_cita = c.id_estado_cita
GROUP BY ec.nombre
ORDER BY total_citas DESC;

-- 3) Subconsulta (Pregunta 16)
-- ¿Qué tratamientos tienen un precio promedio superior al promedio
-- general de todos los tratamientos?
SELECT t.nombre, ROUND(AVG(dct.precio), 2) AS precio_promedio
FROM detalle_consulta_tratamiento dct
INNER JOIN tratamiento t ON t.id_tratamiento = dct.id_tratamiento
GROUP BY t.nombre
HAVING AVG(dct.precio) > (
    SELECT AVG(precio) FROM detalle_consulta_tratamiento
)
ORDER BY precio_promedio DESC;

-- 4) Filtro compuesto con AND (Pregunta 34)
-- ¿Cuáles son los movimientos de inventario registrados por motivo de
-- merma, y qué insumos se han visto más afectados?
SELECT i.nombre AS insumo, mi.cantidad, mi.fecha_movimiento
FROM movimiento_inventario mi
INNER JOIN insumo i ON i.id_insumo = mi.id_insumo
WHERE mi.tipo = 'SALIDA' AND mi.motivo = 'MERMA'
ORDER BY mi.cantidad DESC;

-- 5) Reporte útil para la toma de decisiones (Pregunta 4)
-- ¿Qué insumos se encuentran actualmente por debajo de su stock mínimo?
SELECT nombre, stock_actual, stock_minimo
FROM insumo
WHERE stock_actual < stock_minimo
  AND activo = true;
