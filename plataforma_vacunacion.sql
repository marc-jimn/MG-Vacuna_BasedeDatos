-- =============================================================
-- PERSONAL
-- =============================================================

CREATE TABLE personal (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_empleado VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(150) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    curp VARCHAR(18) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(150),
    foto TEXT,
    fecha_nacimiento DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
    CONSTRAINT chk_personal_estado
        CHECK (estado IN ('activo', 'vacaciones', 'baja'))
);

-- Secuencia para generar números de empleado
CREATE SEQUENCE IF NOT EXISTS personal_numero_seq
START WITH 1
INCREMENT BY 1;

-- Función que genera el número automáticamente
CREATE OR REPLACE FUNCTION generar_numero_empleado()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.numero_empleado IS NULL OR NEW.numero_empleado = '' THEN
        NEW.numero_empleado :=
            'EMP-' || LPAD(
                nextval('personal_numero_seq')::TEXT,
                3,
                '0'
            );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_generar_numero_empleado ON personal;

CREATE TRIGGER trg_generar_numero_empleado
BEFORE INSERT ON personal
FOR EACH ROW
EXECUTE FUNCTION generar_numero_empleado();

-- =============================================================
-- ROL
-- =============================================================

CREATE TABLE IF NOT EXISTS rol (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL
);

INSERT INTO rol (nombre, descripcion)
VALUES
(
    'Administrador general',
    'Controla todo el sistema: usuarios, campañas, reportes y configuración.'
),
(
    'Coordinador de campaña',
    'Organiza las campañas de vacunación, las fechas y las localidades que se visitan.'
),
(
    'Responsable de brigada',
    'Está al frente de una brigada en campo y supervisa sus visitas y registros.'
),
(
    'Encargado de inventario',
    'Controla las vacunas e insumos: entradas, salidas y existencias.'
),
(
	'Médico',
    'Atiende y valora a los pacientes durante las brigadas.'
),
(
    'Enfermero',
    'Aplica las vacunas a las personas durante las jornadas de salud.'
),
(
    'Conductor',
    'Maneja el vehículo que lleva a la brigada y el material a las comunidades.'
)
ON CONFLICT (nombre) DO UPDATE
SET descripcion = EXCLUDED.descripcion;

ALTER TABLE personal
ADD COLUMN IF NOT EXISTS rol_id BIGINT;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_personal_rol'
          AND conrelid = 'personal'::regclass
    ) THEN
        ALTER TABLE personal
        ADD CONSTRAINT fk_personal_rol
        FOREIGN KEY (rol_id)
        REFERENCES rol(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_personal_rol_id
ON personal(rol_id);

--------------------------------------------------
--------------------------------------------------

BEGIN;

INSERT INTO personal (
    numero_empleado,
    nombres,
    apellido_paterno,
    apellido_materno,
    curp,
    telefono,
    correo,
    foto,
    fecha_nacimiento,
    estado,
    rol_id
)
VALUES
('EMP-001','Roberto','Sánchez','Pérez','SAPR850315HXXNBR00','9617483702','roberto.sanchez27@mgvacuna.mx','/uploads/personal/EMP-001.jpg','1978-03-15','activo',1),
('EMP-002','Pedro','Morales','Díaz','MODI790722HXXRZD00','9617483704','pedro.morales56@mgvacuna.mx','/uploads/personal/EMP-002.jpg','1992-07-22','baja',2),
('EMP-003','Ana','Hernández','López','HELA920614MXXRPN00','9617483701','ana.hernandez43@mgvacuna.mx','/uploads/personal/EMP-003.jpg','1993-06-14','activo',5),
('EMP-004','Laura','Méndez','García','MEGA880921MXXNRR00','9617483703','laura.mendez81@mgvacuna.mx','/uploads/personal/EMP-004.jpg','1997-09-21','activo',6),
('EMP-005','Juan','Pérez','Ruiz','PERU950412HXXZJN00','9617483706','juan.perez74@mgvacuna.mx','/uploads/personal/EMP-005.jpg','1995-04-12','activo',6),
('EMP-006','Sofía','Ramírez','Torres','RATS900823MXXMRR00','9617483707','sofia.ramirez19@mgvacuna.mx','/uploads/personal/EMP-006.jpg','2001-08-23','activo',6),
('EMP-007','Carlos','Gómez','Vázquez','GOVC820517HXXMZR00','9617483708','carlos.gomez62@mgvacuna.mx','/uploads/personal/EMP-007.jpg','1990-05-17','activo',7),
('EMP-008','Daniela','Ruiz','Castillo','RUCA960211MXXZNS00','9617483711','daniela.ruiz68@mgvacuna.mx','/uploads/personal/EMP-008.jpg','1980-02-11','activo',3),
('EMP-009','Miguel','Díaz','Castro','DICA870930HXXZGS00','9617483710','miguel.diaz41@mgvacuna.mx','/uploads/personal/EMP-009.jpg','2000-09-30','activo',6),
('EMP-010','José','Torres','Luna','TOLU910708HXXRNS00','9617483712','jose.torres24@mgvacuna.mx','/uploads/personal/EMP-010.jpg','2000-07-08','activo',6),
('EMP-011','Patricia','Vázquez','Flores','VAFP800126MXXZRL00','9617483713','patricia.vazquez93@mgvacuna.mx','/uploads/personal/EMP-011.jpg','2002-01-26','activo',6),
('EMP-012','Luis','Jiménez','Ortiz','JIOL850619HXXMRR00','9617483714','luis.jimenez37@mgvacuna.mx','/uploads/personal/EMP-012.jpg','2001-06-19','activo',3),
('EMP-013','Gabriela','Castro','Núñez','CANG930305MXXSXB00','9617483715','gabriela.castro51@mgvacuna.mx','/uploads/personal/EMP-013.jpg','1986-03-05','activo',6),
('EMP-014','Fernando','Aguilar','Domínguez','AUDF770914HXXGMR00','9617483716','fernando.aguilar76@mgvacuna.mx','/uploads/personal/EMP-014.jpg','1994-09-14','activo',7),
('EMP-015','Jorge','Luna','Mendoza','LUMJ890427HXXNDR00','9617483718','jorge.luna64@mgvacuna.mx','/uploads/personal/EMP-015.jpg','1992-04-27','activo',6),
('EMP-016','Ricardo','Núñez','Vega','NUVR810812HXXXGC00','9617483720','ricardo.nunez82@mgvacuna.mx','/uploads/personal/EMP-016.jpg','1975-08-12','activo',7),
('EMP-017','Andrea','Salazar','Flores','SAFA970219MXXLNR00','9617483717','andrea.salazar28@mgvacuna.mx','/uploads/personal/EMP-017.jpg','1997-02-19','activo',2),
('EMP-018','Valeria','Ortiz','Santos','OISV940611MXXRNL00','9617483719','valeria.ortiz17@mgvacuna.mx','/uploads/personal/EMP-018.jpg','1996-06-11','activo',6),
('EMP-019','Arturo','Mendoza','León','MELA860923HXXNTR00','9617483722','arturo.mendoza39@mgvacuna.mx','/uploads/personal/EMP-019.jpg','1996-09-23','activo',5),
('EMP-020','Carmen','Flores','Ríos','FORC900130MXXLRS00','9617483721','carmen.flores45@mgvacuna.mx','/uploads/personal/EMP-020.jpg','1967-01-30','activo',5),
('EMP-021','Óscar','Ríos','Navarro','RINO780516HXXSVS00','9617483724','oscar.rios26@mgvacuna.mx','/uploads/personal/EMP-021.jpg','1998-05-16','vacaciones',3),
('EMP-022','Diana','Aguilar','Solís','AUSD920827MXXGLN00','9617483723','diana.aguilar71@mgvacuna.mx','/uploads/personal/EMP-022.jpg','1998-08-27','activo',6),
('EMP-023','Paola','Cabrera','Vargas','CAVP950309MXXBRR00','9617483725','paola.cabrera58@mgvacuna.mx','/uploads/personal/EMP-023.jpg','1998-03-09','activo',3),
('EMP-024','Emilio','Delgado','Pineda','DEPE830721HXXLNM00','9617483726','emilio.delgado34@mgvacuna.mx','/uploads/personal/EMP-024.jpg','1982-07-21','activo',5),
('EMP-025','Natalia','Acosta','Herrera','AOHN990415MXXCST00','9617483727','natalia.acosta92@mgvacuna.mx','/uploads/personal/EMP-025.jpg','1981-04-15','activo',6),
('EMP-026','Iván','Campos','Cortés','CACI880628HXXMPR00','9617483728','ivan.campos47@mgvacuna.mx','/uploads/personal/EMP-026.jpg','1990-06-28','activo',7),
('EMP-027','Fernanda','Rojas','Valdez','ROVF960902MXXJLN00','9617483729','fernanda.rojas63@mgvacuna.mx','/uploads/personal/EMP-027.jpg','1992-09-02','activo',6),
('EMP-028','Alejandra','Medina','Ochoa','MEOA910118MXXDCL00','9617483731','alejandra.medina55@mgvacuna.mx','/uploads/personal/EMP-028.jpg','1993-01-18','activo',6),
('EMP-029','Héctor','Vargas','Cervantes','VACH800724HXXRRC00','9617483732','hector.vargas87@mgvacuna.mx','/uploads/personal/EMP-029.jpg','1987-07-24','activo',6),
('EMP-030','Samuel','Pineda','Carrillo','PICS930510HXXNMR00','9617483734','samuel.pineda46@mgvacuna.mx','/uploads/personal/EMP-030.jpg','1974-05-10','activo',6),
('EMP-031','Diego','Fuentes','Pacheco','FUPD970831HXXNCC00','9617483730','diego.fuentes18@mgvacuna.mx','/uploads/personal/EMP-031.jpg','1992-08-31','activo',5),
('EMP-032','Mónica','Contreras','Ibarra','COIM850207MXXNBR00','9617483733','monica.contreras29@mgvacuna.mx','/uploads/personal/EMP-032.jpg','1991-02-07','activo',6),
('EMP-033','Adrián','Cortés','Espinosa','COEA890619HXXRDS00','9617483736','adrian.cortes21@mgvacuna.mx','/uploads/personal/EMP-033.jpg','1992-06-19','activo',5),
('EMP-034','Claudia','Herrera','Montes','HEMC940925MXXRNL00','9617483735','claudia.herrera73@mgvacuna.mx','/uploads/personal/EMP-034.jpg','1982-09-25','activo',6),
('EMP-035','Pablo','Pacheco','Serrano','PASP820314HXXCBB00','9617483738','pablo.pacheco35@mgvacuna.mx','/uploads/personal/EMP-035.jpg','1979-03-14','activo',4),
('EMP-036','Renata','Valdez','Mejía','VAMR980722MXXLJN00','9617483737','renata.valdez66@mgvacuna.mx','/uploads/personal/EMP-036.jpg','1990-07-22','activo',6),
('EMP-037','Ángel','Acosta','Jiménez','AOJA860105HXXCMN00','9617483740','angel.acosta52@mgvacuna.mx','/uploads/personal/EMP-037.jpg','1988-01-05','activo',6),
('EMP-038','Ximena','Beltrán','Ochoa','OOBX000417MXXCLN00','9617483739','ximena.beltran89@mgvacuna.mx','/uploads/personal/EMP-038.jpg','2001-04-17','activo',2),
('EMP-039','Elena','Cruz','Jiménez','CUJE910812MXXRML00','9617483709','elena.cruz85@mgvacuna.mx','/uploads/personal/EMP-039.jpg','1989-08-12','vacaciones',5),
('EMP-040','María','López','Gómez','LOGM870226MXXPZR00','9617483705','maria.lopez32@mgvacuna.mx','/uploads/personal/EMP-040.jpg','1973-02-26','activo',6)

ON CONFLICT (numero_empleado)
DO UPDATE SET
    nombres = EXCLUDED.nombres,
    apellido_paterno = EXCLUDED.apellido_paterno,
    apellido_materno = EXCLUDED.apellido_materno,
    curp = EXCLUDED.curp,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    foto = EXCLUDED.foto,
    fecha_nacimiento = EXCLUDED.fecha_nacimiento,
    estado = EXCLUDED.estado,
    rol_id = EXCLUDED.rol_id,
    fecha_actualizacion = CURRENT_TIMESTAMP;
	
COMMIT;

-- =============================================================
-- CAMPAÑAS
-- =============================================================

CREATE TABLE IF NOT EXISTS campanias (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    categoria VARCHAR(20) NOT NULL DEFAULT 'humana',
    icono VARCHAR(100),

    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,

    -- NUEVAS Y EXISTENTES DOSIS
    dosis_asignadas INTEGER NOT NULL DEFAULT 0,
    objetivo_dosis INTEGER NOT NULL DEFAULT 0,

    estado VARCHAR(20) NOT NULL DEFAULT 'planeada',
    responsable_id BIGINT,

    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_campania_responsable
        FOREIGN KEY (responsable_id)
        REFERENCES personal(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT chk_campania_fechas
        CHECK (fecha_fin >= fecha_inicio),

    CONSTRAINT chk_campania_dosis_asignadas
        CHECK (dosis_asignadas >= 0),

    CONSTRAINT chk_campania_objetivo
        CHECK (objetivo_dosis >= 0),

    CONSTRAINT chk_campania_estado
        CHECK (
            estado IN (
                'activa',
                'planeada',
                'finalizada',
                'cancelada'
            )
        ),

    CONSTRAINT chk_campania_categoria
        CHECK (categoria IN ('veterinaria', 'humana'))
);

-- =============================================================
-- ÍNDICES
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_campanias_estado
ON campanias(estado);

CREATE INDEX IF NOT EXISTS idx_campanias_responsable
ON campanias(responsable_id);

CREATE INDEX IF NOT EXISTS idx_campanias_categoria
ON campanias(categoria);

INSERT INTO campanias (
    codigo,
    nombre,
    descripcion,
    categoria,
    fecha_inicio,
    fecha_fin,
    dosis_asignadas,
    objetivo_dosis,
    estado,
    responsable_id
) VALUES

-- CAM-001
(
    'CAM-001',
    'Unidos contra el sarampión 2025-2026',
    'Vacunación para prevenir brotes de sarampión y recuperar esquemas incompletos de la población.',
    'humana',
    '2025-09-24',
    '2026-04-30',
    5200,
    4800,
    'finalizada',
    2
),

-- CAM-002
(
    'CAM-002',
    'Vacunación invernal 2025-2026',
    'Aplicación de vacunas contra influenza, COVID-19 y neumococo a población prioritaria.',
    'humana',
    '2025-10-13',
    '2026-03-03',
    0,
    0,
    'cancelada',
    17
),

-- CAM-003
(
    'CAM-003',
    'Semana Nacional de Vacunación 2026',
    'Aplicación y actualización de esquemas básicos de vacunación en niños, adolescentes y adultos.',
    'humana',
    '2026-04-25',
    '2026-05-02',
    2100,
    1850,
    'finalizada',
    2
),

-- CAM-004
(
    'CAM-004',
    'Vacunación Tdpa y Td',
    'Aplicación de vacunas contra tétanos, difteria y tosferina, especialmente a embarazadas y personas con esquemas incompletos.',
    'humana',
    '2026-06-01',
    '2026-07-31',
    4800,
    4300,
    'finalizada',
    38
),

-- CAM-005
(
    'CAM-005',
    'Campaña contra neumococo en adultos mayores',
    'Vacunación de adultos mayores para disminuir el riesgo de enfermedades neumocócicas graves.',
    'humana',
    '2026-08-01',
    '2026-09-30',
    3950,
    3500,
    'finalizada',
    2
),

-- CAM-006
(
    'CAM-006',
    'Vacunación contra VPH 2026',
    'Vacunación escolar para prevenir infecciones por virus del papiloma humano y cánceres asociados.',
    'humana',
    '2026-10-16',
    '2026-12-11',
    1650,
    1500,
    'planeada',
    17
),

-- CAM-007
(
    'CAM-007',
    'Campaña de vacunación contra influenza 2026-2027',
    'Vacunación preventiva de niños, adultos mayores, embarazadas y personas con factores de riesgo durante la temporada invernal.',
    'humana',
    '2026-10-16',
    '2027-04-02',
    3300,
    3000,
    'planeada',
    38
),

-- CAM-008
(
    'CAM-008',
    'Campaña contra hepatitis B',
    'Vacunación de personas sin esquema completo, trabajadores de salud y grupos con mayor riesgo de exposición.',
    'humana',
    '2027-02-01',
    '2027-03-31',
    2750,
    2400,
    'activa',
    NULL
),

-- CAM-009
(
    'CAM-009',
    'Campaña de vacunación infantil',
    'Recuperación de esquemas de vacunación infantil contra poliomielitis, difteria, tétanos, tosferina y otras enfermedades prevenibles.',
    'humana',
    '2027-01-15',
    '2027-03-15',
    4100,
    3700,
    'activa',
    NULL
),

-- CAM-010
(
    'CAM-010',
    'Chucho Móvil 2027',
    'Programa de vacunación gratuita contra la rabia para perros y gatos mediante unidades móviles que recorrerán colonias, parques y espacios públicos.',
    'veterinaria',
    '2027-01-11',
    '2027-03-31',
    8800,
    8000,
    'planeada',
    17
),

-- CAM-011
(
    'CAM-011',
    'Protege a tu Cachorro 2027 – Parvovirus',
    'Jornada de vacunación dirigida a cachorros y perros jóvenes para prevenir el parvovirus canino, enfermedad viral altamente contagiosa que puede provocar vómitos, diarrea intensa y deshidratación.',
    'veterinaria',
    '2027-04-01',
    '2027-06-30',
    4650,
    4200,
    'activa',
    NULL
),

-- CAM-012
(
    'CAM-012',
    'Un Hogar sin Moquillo 2027',
    'Campaña de vacunación preventiva contra el moquillo canino, enfermedad viral contagiosa que afecta los sistemas respiratorio, digestivo y nervioso de los perros.',
    'veterinaria',
    '2027-07-01',
    '2027-09-30',
    3450,
    3100,
    'activa',
    NULL
);

-- =============================================================
-- LOCALIDADES
-- =============================================================

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE localidades (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    tipo VARCHAR(30),
    municipio VARCHAR(120) NOT NULL DEFAULT 'Tuxtla Gutiérrez',
    estado VARCHAR(120) NOT NULL DEFAULT 'Chiapas',
    codigo_postal VARCHAR(10),
    poblacion INTEGER,
    ubicacion GEOGRAPHY(Point, 4326),
    color_marcador VARCHAR(7) NOT NULL DEFAULT '#2878B8',

    activa BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_localidad_poblacion
        CHECK (poblacion IS NULL OR poblacion >= 0),

    CONSTRAINT chk_localidad_tipo
        CHECK (
            tipo IS NULL OR
            tipo IN (
                'localidad',
                'colonia',
                'barrio',
                'ejido',
                'rancheria',
                'otro'
            )
        ),

    CONSTRAINT chk_localidad_color
        CHECK (color_marcador ~ '^#[0-9A-Fa-f]{6}$')
);

CREATE INDEX idx_localidades_ubicacion
ON localidades
USING GIST (ubicacion);

--------------------------------------------------
--------------------------------------------------

INSERT INTO localidades (
    codigo,
    nombre,
    tipo,
    municipio,
    estado,
    codigo_postal,
    poblacion,
    ubicacion,
    color_marcador
)

VALUES
(
    'LOC-001',
    'Copoya',
    'localidad',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29100',
    9868,
    ST_SetSRID(ST_MakePoint(-93.11939, 16.71158), 4326)::geography,
    '#E76F70'
),

(
    'LOC-002',
    'El Jobo',
    'localidad',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29100',
    5798,
    ST_SetSRID(ST_MakePoint(-93.10433, 16.70227), 4326)::geography,
    '#F28C45'
),

(
    'LOC-003',
    'Terán',
    'ejido',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29050',
    8280,
    ST_SetSRID(ST_MakePoint(-93.16353, 16.75280), 4326)::geography,
    '#E5A13A'
),

(
    'LOC-004',
    'Patria Nueva',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29045',
    3930,
    ST_SetSRID(ST_MakePoint(-93.07174, 16.75345), 4326)::geography,
    '#D85D87'
),

(
    'LOC-005',
    'Centro',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29000',
    3500,
    ST_SetSRID(ST_MakePoint(-93.13333, 16.73333), 4326)::geography,
    '#E85D5D'
),

(
    'LOC-006',
    'Cerro Hueco',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29094',
    4000,
    ST_SetSRID(ST_MakePoint(-93.09197, 16.71884), 4326)::geography,
    '#D9A441'
),

(
    'LOC-007',
    'Las Granjas',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29019',
    14700,
    ST_SetSRID(ST_MakePoint(-93.1052211, 16.7915898), 4326)::geography,
    '#D98269'
),

(
    'LOC-008',
    'Plan de Ayala',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29020',
    6130,
    ST_SetSRID(ST_MakePoint(-93.188, 16.775), 4326)::geography,
    '#C77C55'
),

(
    'LOC-009',
    '24 de Junio',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29047',
    5540,
    ST_SetSRID(ST_MakePoint(-93.0939, 16.7694), 4326)::geography,
    '#CC668E'
),

(
    'LOC-010',
    'Las Águilas',
    'otro',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29049',
    1960,
    ST_SetSRID(ST_MakePoint(-93.08874, 16.78277), 4326)::geography,
    '#C99B42'
),

(
    'LOC-011',
    'Jardines Pedregal',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29049',
    6170,
    ST_SetSRID(ST_MakePoint(-93.08892, 16.76993), 4326)::geography,
    '#5278C7'
),

(
    'LOC-012',
    'San Fernando',
    'otro',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29120',
    11867,
    ST_SetSRID(ST_MakePoint(-93.1160, 16.7538), 4326)::geography,
    '#399B83'
),

(
    'LOC-013',
    'Loma Bonita de Terán',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29059',
    8000,
    ST_SetSRID(ST_MakePoint(-93.16947, 16.73123), 4326)::geography,
    '#8065B9'
),

(
    'LOC-014',
    'Ampliación Terán',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29059',
    8280,
    ST_SetSRID(ST_MakePoint(-93.14376, 16.76284), 4326)::geography,
    '#368FAE'
),

(
    'LOC-015',
    'Real del Bosque',
    'otro',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29040',
    42000,
    ST_SetSRID(ST_MakePoint(-93.17074, 16.70109), 4326)::geography,
    '#548D69'
),

(
    'LOC-016',
    'Los Tamarindos',
    'colonia',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29059',
    NULL,
    ST_SetSRID(ST_MakePoint(-93.15978, 16.7448), 4326)::geography,
    '#6575B9'
)

ON CONFLICT (codigo) DO NOTHING;

--------------------------------------------------
--------------------------------------------------

CREATE TABLE campanias_localidades (
    campania_id BIGINT NOT NULL,
    localidad_id BIGINT NOT NULL,

    CONSTRAINT pk_campanias_localidades
        PRIMARY KEY (campania_id, localidad_id),

    CONSTRAINT fk_cl_campania
        FOREIGN KEY (campania_id)
        REFERENCES campanias(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_cl_localidad
        FOREIGN KEY (localidad_id)
        REFERENCES localidades(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_cl_localidad
    ON campanias_localidades(localidad_id);

INSERT INTO campanias_localidades (campania_id, localidad_id)
VALUES
    (6, 1),
    (6, 2),
    (7, 3),
    (7, 4),
    (7, 5),
    (7, 6),
    (7, 2),
    (10, 3),
    (10, 4),
    (10, 7),
    (10, 1),
    (10, 8),
    (10, 9),
    (10, 10)
ON CONFLICT (campania_id, localidad_id) DO NOTHING;

-- =============================================================
-- VEHICULOS
-- =============================================================

CREATE TABLE vehiculos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    numero_economico VARCHAR(30) NOT NULL UNIQUE,
    marca VARCHAR(80) NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    anio INTEGER,
    placas VARCHAR(20) UNIQUE,
    color VARCHAR(40),
    capacidad_personas INTEGER,
    kilometraje INTEGER NOT NULL DEFAULT 0,
    foto TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'disponible',
    conductor_id BIGINT,

    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vehiculos_conductor
        FOREIGN KEY (conductor_id)
        REFERENCES personal(id),

    CONSTRAINT chk_vehiculos_estado
        CHECK (
            estado IN (
                'disponible',
                'en_uso',
                'mantenimiento',
                'fuera_servicio'
            )
        ),

    CONSTRAINT chk_vehiculos_anio
        CHECK (anio IS NULL OR anio BETWEEN 1980 AND 2100),

    CONSTRAINT chk_vehiculos_capacidad
        CHECK (capacidad_personas IS NULL OR capacidad_personas > 0),

    CONSTRAINT chk_vehiculos_kilometraje
        CHECK (kilometraje >= 0)
);

INSERT INTO vehiculos (
    numero_economico,
    marca,
    modelo,
    anio,
    placas,
    color,
    capacidad_personas,
    kilometraje,
    foto,
    estado,
    conductor_id,
    fecha_creacion,
    fecha_actualizacion
)
VALUES

-- 1. Nissan Urvan
(
    'VS-001', 'Nissan', 'Urvan', 2021,
    'DYA-482-C', 'Blanco', 15, 86450,
    'uploads/vehiculos/nissan-urvan-001.png',
    'en_uso', 26,
    '2026-01-12 08:30:00-06',
    '2026-10-28 09:15:00-06'
),

-- 2. Nissan Urvan
(
    'VS-002', 'Nissan', 'Urvan', 2020,
    'DYA-593-C', 'Blanco', 15, 112300,
    'uploads/vehiculos/nissan-urvan-002.png',
    'en_uso', 7,
    '2026-01-12 08:35:00-06',
    '2026-10-29 10:20:00-06'
),

-- 3. Toyota Hiace
(
    'VS-003', 'Toyota', 'Hiace', 2022,
    'DYA-614-C', 'Blanco', 15, 64800,
    'uploads/vehiculos/toyota-hiace-003.png',
    'en_uso', 16,
    '2026-02-05 09:00:00-06',
    '2026-11-02 08:45:00-06'
),

-- 4. Nissan NP300
(
    'VS-004', 'Nissan', 'NP300', 2019,
    'CW-3842-B', 'Blanco', 5, 138600,
    'uploads/vehiculos/nissan-np300-004.png',
    'en_uso', 14,
    '2026-01-15 11:20:00-06',
    '2026-10-30 12:10:00-06'
),

-- 5. Ford Ranger
(
    'VS-005', 'Ford', 'Ranger', 2018,
    'CW-5291-B', 'Blanco', 5, 165200,
    'uploads/vehiculos/ford-ranger-005.png',
    'mantenimiento', NULL,
    '2026-01-18 08:00:00-06',
    '2026-11-03 14:30:00-06'
),

-- 6. Nissan Urvan
(
    'VS-006', 'Nissan', 'Urvan', 2017,
    'DYA-728-C', 'Blanco', 15, 194500,
    'uploads/vehiculos/nissan-urvan-006.png',
    'fuera_servicio', NULL,
    '2026-01-20 10:00:00-06',
    '2026-10-15 16:00:00-06'
),

-- 7. Toyota Hiace
(
    'VS-007', 'Toyota', 'Hiace', 2018,
    'DYA-836-C', 'Blanco', 15, 178900,
    'uploads/vehiculos/toyota-hiace-007.png',
    'fuera_servicio', NULL,
    '2026-01-22 09:30:00-06',
    '2026-09-22 13:45:00-06'
),

-- 8. Nissan NP300
(
    'VS-008', 'Nissan', 'NP300', 2016,
    'CW-6472-B', 'Blanco', 5, 210350,
    'uploads/vehiculos/nissan-np300-008.png',
    'fuera_servicio', NULL,
    '2026-01-25 08:45:00-06',
    '2026-08-19 11:30:00-06'
),

-- 9. Nissan Urvan
(
    'VS-009', 'Nissan', 'Urvan', 2023,
    'DYA-942-C', 'Blanco', 15, 32700,
    'uploads/vehiculos/nissan-urvan-009.png',
    'disponible', NULL,
    '2026-03-10 10:15:00-06',
    '2026-11-04 09:00:00-06'
),

-- 10. Ford Transit
(
    'VS-010', 'Ford', 'Transit', 2022,
    'DYA-157-C', 'Blanco', 15, 51200,
    'uploads/vehiculos/ford-transit-010.png',
    'disponible', NULL,
    '2026-03-15 09:20:00-06',
    '2026-11-05 08:30:00-06'
);

UPDATE vehiculos
SET foto = CASE

    WHEN marca = 'Nissan' AND modelo = 'Urvan'
        THEN '/uploads/transporte/nissan-urvan.png'

    WHEN marca = 'Toyota' AND modelo = 'Hiace'
        THEN '/uploads/transporte/toyota-hiace.png'

    WHEN marca = 'Nissan' AND modelo = 'NP300'
        THEN '/uploads/transporte/nissan-np300.png'

    WHEN marca = 'Ford' AND modelo = 'Ranger'
        THEN '/uploads/transporte/ford-ranger.png'

    WHEN marca = 'Ford' AND modelo = 'Transit'
        THEN '/uploads/transporte/ford-transit.png'

    ELSE foto

END;

-- =============================================================
-- Biológicos
-- =============================================================

BEGIN;

CREATE TABLE public.biologicos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(220) NOT NULL,
    nombre_corto VARCHAR(100) NOT NULL,
    fabricante VARCHAR(180),
    presentacion VARCHAR(100) NOT NULL,

    dosis_por_envase SMALLINT NOT NULL
        CHECK (dosis_por_envase > 0),

    temperatura_min_c NUMERIC(5,2),
    temperatura_max_c NUMERIC(5,2),

    stock_minimo_dosis INTEGER NOT NULL DEFAULT 0
        CHECK (stock_minimo_dosis >= 0),

    tipo VARCHAR(20) NOT NULL
        CHECK (tipo IN ('humano', 'veterinario')),

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_temperatura_biologico
        CHECK (
            temperatura_min_c IS NULL
            OR temperatura_max_c IS NULL
            OR temperatura_min_c <= temperatura_max_c
        )
);

CREATE TABLE public.campanias_biologicos (
    campania_id BIGINT NOT NULL,
    biologico_id BIGINT NOT NULL,

    dosis_asignadas INTEGER NOT NULL DEFAULT 0
        CHECK (dosis_asignadas >= 0),

    objetivo_dosis INTEGER NOT NULL DEFAULT 0
        CHECK (objetivo_dosis >= 0),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_campanias_biologicos
        PRIMARY KEY (campania_id, biologico_id),

    CONSTRAINT fk_cb_campania
        FOREIGN KEY (campania_id)
        REFERENCES public.campanias(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_cb_biologico
        FOREIGN KEY (biologico_id)
        REFERENCES public.biologicos(id)
        ON DELETE RESTRICT
);


CREATE INDEX idx_campanias_biologicos_biologico
    ON public.campanias_biologicos(biologico_id);

COMMENT ON TABLE public.biologicos IS
'Catálogo general de vacunas y otros biológicos humanos y veterinarios.';

COMMENT ON COLUMN public.biologicos.stock_minimo_dosis IS
'Stock mínimo expresado en dosis, no en envases.';

COMMENT ON TABLE public.campanias_biologicos IS
'Biológicos asociados a cada campaña y cantidades correspondientes.';

COMMIT;

INSERT INTO public.biologicos (
    codigo,
    nombre,
    nombre_corto,
    fabricante,
    presentacion,
    dosis_por_envase,
    temperatura_min_c,
    temperatura_max_c,
    stock_minimo_dosis,
    tipo
)
VALUES

-- BIOLÓGICOS HUMANOS

(
    'BIO-INF',
    'Vacuna contra Influenza',
    'Influenza',
    'Sanofi Pasteur',
    'Jeringa prellenada',
    1,
    2,
    8,
    100,
    'humano'
),

(
    'BIO-SRP',
    'Vacuna contra el sarampión, la rubéola y la parotiditis',
    'SRP',
    'Merck Sharp & Dohme (MSD)',
    'Frasco unidosis',
    1,
    2,
    8,
    80,
    'humano'
),

(
    'BIO-TD',
    'Vacuna contra el tétanos y la difteria',
    'TD',
    'BIRMEX',
    'Frasco multidosis',
    10,
    2,
    8,
    80,
    'humano'
),

(
    'BIO-COVID',
    'Vacuna contra la enfermedad por coronavirus 2019',
    'COVID-19',
    'Pfizer',
    'Frasco multidosis',
    6,
    2,
    8,
    60,
    'humano'
),

(
    'BIO-BCG',
    'Vacuna contra la tuberculosis meníngea',
    'BCG',
    'AJ Vaccines',
    'Frasco multidosis',
    10,
    2,
    8,
    50,
    'humano'
),

(
    'BIO-NEUMO',
    'Vacuna contra la enfermedad neumocócica',
    'Neumococo',
    'Pfizer',
    'Jeringa prellenada',
    1,
    2,
    8,
    30,
    'humano'
),

(
    'BIO-VPH',
    'Vacuna contra el virus del papiloma humano',
    'VPH',
    'Merck Sharp & Dohme (MSD)',
    'Jeringa prellenada',
    1,
    2,
    8,
    20,
    'humano'
),

(
    'BIO-HEPB',
    'Vacuna contra la hepatitis B',
    'Hepatitis B',
    'Merck Sharp & Dohme (MSD)',
    'Frasco unidosis',
    1,
    2,
    8,
    30,
    'humano'
),

-- BIOLÓGICOS VETERINARIOS

(
    'BIO-RAB',
    'Vacuna antirrábica para perros y gatos',
    'Rabia',
    'MSD Animal Health',
    'Frasco multidosis',
    10,
    2,
    8,
    100,
    'veterinario'
),

(
    'BIO-PARVO',
    'Vacuna contra el parvovirus canino',
    'Parvovirus',
    'Zoetis',
    'Frasco unidosis',
    1,
    2,
    8,
    50,
    'veterinario'
),

(
    'BIO-MOQ',
    'Vacuna contra el moquillo canino',
    'Moquillo',
    'MSD Animal Health',
    'Frasco unidosis',
    1,
    2,
    8,
    50,
    'veterinario'
)

ON CONFLICT (codigo)
DO UPDATE SET
    nombre = EXCLUDED.nombre,
    nombre_corto = EXCLUDED.nombre_corto,
    fabricante = EXCLUDED.fabricante,
    presentacion = EXCLUDED.presentacion,
    dosis_por_envase = EXCLUDED.dosis_por_envase,
    temperatura_min_c = EXCLUDED.temperatura_min_c,
    temperatura_max_c = EXCLUDED.temperatura_max_c,
    stock_minimo_dosis = EXCLUDED.stock_minimo_dosis,
    tipo = EXCLUDED.tipo,
    updated_at = NOW(); 

INSERT INTO public.campanias_biologicos (
    campania_id,
    biologico_id
)
SELECT
    c.id,
    b.id
FROM (
    VALUES
        ('CAM-001', 'BIO-SRP'),
        ('CAM-002', 'BIO-INF'),
        ('CAM-002', 'BIO-COVID'),
        ('CAM-002', 'BIO-NEUMO'),
        ('CAM-003', 'BIO-BCG'),
        ('CAM-003', 'BIO-SRP'),
        ('CAM-003', 'BIO-TD'),
        ('CAM-003', 'BIO-HEPB'),
        ('CAM-004', 'BIO-TD'),
        ('CAM-005', 'BIO-NEUMO'),
        ('CAM-006', 'BIO-VPH'),
        ('CAM-007', 'BIO-INF'),
        ('CAM-008', 'BIO-HEPB'),
        ('CAM-009', 'BIO-BCG'),
        ('CAM-009', 'BIO-SRP'),
        ('CAM-009', 'BIO-TD'),
        ('CAM-009', 'BIO-HEPB'),
        ('CAM-010', 'BIO-RAB'),
        ('CAM-011', 'BIO-PARVO'),
        ('CAM-012', 'BIO-MOQ')
) AS relaciones(codigo_campania, codigo_biologico)

INNER JOIN public.campanias c
    ON c.codigo = relaciones.codigo_campania

INNER JOIN public.biologicos b
    ON b.codigo = relaciones.codigo_biologico

ON CONFLICT (campania_id, biologico_id)
DO NOTHING;

-- =============================================================
-- BRIGADAS
-- =============================================================

BEGIN;

-- =============================================================
-- TABLA: BRIGADAS
-- =============================================================

CREATE TABLE public.brigadas (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    campania_id BIGINT NOT NULL,

    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT,

    -- Estados permitidos de la brigada.
    estado VARCHAR(20) NOT NULL DEFAULT 'disponible'
        CHECK (
            estado IN (
                'disponible',
                'asignada',
                'en_ruta',
                'en_visita',
                'terminada',
                'cancelada'
            )
        ),

    capacidad_personal SMALLINT NOT NULL DEFAULT 5
        CHECK (capacidad_personal = 5),

    dosis_asignadas INTEGER NOT NULL DEFAULT 0
        CHECK (dosis_asignadas >= 0),

    objetivo_dosis INTEGER NOT NULL DEFAULT 0
        CHECK (objetivo_dosis >= 0),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Relaciones.
    CONSTRAINT fk_brigadas_campania
        FOREIGN KEY (campania_id)
        REFERENCES public.campanias(id)
        ON DELETE CASCADE,

    -- Evitar códigos repetidos dentro de una campaña.
    CONSTRAINT uq_brigadas_codigo_campania
        UNIQUE (campania_id, codigo),

    -- Necesaria para las relaciones compuestas.
    CONSTRAINT uq_brigadas_id_campania
        UNIQUE (id, campania_id)
);

-- =============================================================
-- TABLA: BRIGADA_INTEGRANTES
-- =============================================================

CREATE TABLE public.brigada_integrantes (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    brigada_id BIGINT NOT NULL,
    campania_id BIGINT NOT NULL,
    personal_id BIGINT NOT NULL,

    funcion VARCHAR(20) NOT NULL
        CHECK (
            funcion IN (
                'responsable',
                'medico',
                'enfermero',
                'conductor'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_bi_brigada
        FOREIGN KEY (brigada_id, campania_id)
        REFERENCES public.brigadas(id, campania_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_bi_personal
        FOREIGN KEY (personal_id)
        REFERENCES public.personal(id)
        ON DELETE RESTRICT,

    -- Una persona no se repite dentro de la misma brigada.
    CONSTRAINT uq_brigada_personal
        UNIQUE (brigada_id, personal_id)
);

-- Una sola persona para responsable, médico y conductor.
-- Se permiten dos enfermeros.

CREATE UNIQUE INDEX uq_brigada_funcion_individual
ON public.brigada_integrantes (
    brigada_id,
    funcion
)
WHERE funcion IN (
    'responsable',
    'medico',
    'conductor'
);

CREATE INDEX idx_brigada_integrantes_personal
ON public.brigada_integrantes(personal_id);

CREATE INDEX idx_brigada_integrantes_brigada
ON public.brigada_integrantes(brigada_id);

-- =============================================================
-- TABLA: BRIGADA_LOCALIDADES
-- =============================================================

CREATE TABLE public.brigada_localidades (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    campania_id BIGINT NOT NULL,
    brigada_id BIGINT NOT NULL,
    localidad_id BIGINT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_bl_brigada
        FOREIGN KEY (brigada_id, campania_id)
        REFERENCES public.brigadas(id, campania_id)
        ON DELETE CASCADE,

    -- La localidad debe pertenecer a la campaña.
    CONSTRAINT fk_bl_campania_localidad
        FOREIGN KEY (campania_id, localidad_id)
        REFERENCES public.campanias_localidades(
            campania_id,
            localidad_id
        )
        ON DELETE RESTRICT,

    -- Una localidad solo puede pertenecer a una brigada
    -- dentro de la misma campaña.
    CONSTRAINT uq_localidad_por_campania
        UNIQUE (campania_id, localidad_id)
);

-- =============================================================
-- ÍNDICES
-- =============================================================

CREATE INDEX idx_brigadas_campania
ON public.brigadas(campania_id);

CREATE INDEX idx_brigada_localidades_brigada
ON public.brigada_localidades(brigada_id);

-- =============================================================
-- COMENTARIOS
-- =============================================================

COMMENT ON TABLE public.brigadas IS
'Equipos de trabajo asignados a una campaña de vacunación.';

COMMENT ON TABLE public.brigada_integrantes IS
'Personal que integra cada brigada y función que desempeña.';

COMMENT ON TABLE public.brigada_localidades IS
'Localidades asignadas a cada brigada dentro de una campaña.';

COMMENT ON COLUMN public.brigada_integrantes.funcion IS
'Responsable, médico, enfermero o conductor.';

COMMENT ON COLUMN public.brigadas.capacidad_personal IS
'Cada brigada está integrada por cinco personas.';

COMMENT ON COLUMN public.brigadas.estado IS
'Disponible, asignada, en_ruta, en_visita, terminada o cancelada.';

COMMIT;

BEGIN;

INSERT INTO public.brigadas (
    campania_id,
    codigo,
    nombre,
    descripcion,
    estado,
    capacidad_personal,
    dosis_asignadas,
    objetivo_dosis
)
VALUES

-- =====================================================
-- CAM-006: VACUNACIÓN CONTRA VPH 2026
-- BIO-VPH
-- =====================================================

(
    6,
    'BRI-001',
    'Brigada VPH Esperanza',
    'Equipo de vacunación encargado de realizar jornadas de inmunización contra el virus del papiloma humano en instituciones educativas, promoviendo la prevención de infecciones y cánceres asociados.',
    'disponible',
    5,
    1039,
    945
),

(
    6,
    'BRI-002',
    'Brigada Juvenil Saludable',
    'Brigada enfocada en la aplicación de vacunas contra el VPH a estudiantes, brindando orientación sobre la importancia de la vacunación y la prevención de enfermedades relacionadas.',
    'disponible',
    5,
    611,
    555
),

-- =====================================================
-- CAM-007: VACUNACIÓN CONTRA INFLUENZA 2026-2027
-- BIO-INF
-- =====================================================

(
    7,
    'BRI-003',
    'Brigada Comunitaria Antigripal',
    'Brigada móvil responsable de acercar los servicios de vacunación contra la influenza a diferentes colonias y comunidades, facilitando el acceso a la población en general.',
    'disponible',
    5,
    1579,
    1436
),

(
    7,
    'BRI-004',
    'Brigada Invierno Seguro',
    'Equipo encargado de realizar jornadas de vacunación contra la influenza en centros de salud y espacios comunitarios, priorizando la protección de la población durante la temporada invernal.',
    'disponible',
    5,
    971,
    882
),

(
    7,
    'BRI-005',
    'Brigada Salud Materno Infantil',
    'Equipo enfocado en la vacunación de mujeres embarazadas, niños y población infantil, promoviendo la protección contra la influenza y reduciendo los riesgos de complicaciones.',
    'disponible',
    5,
    750,
    682
),

-- =====================================================
-- CAM-010: CHUCHO MÓVIL 2027
-- BIO-RAB
-- =====================================================

(
    10,
    'BRI-006',
    'Brigada Patitas Protegidas',
    'Equipo veterinario encargado de aplicar vacunas antirrábicas a perros y gatos, promoviendo la tenencia responsable y la prevención de la rabia.',
    'disponible',
    5,
    2566,
    2333
),

(
    10,
    'BRI-007',
    'Brigada Guardianes de la Rabia',
    'Equipo responsable de ejecutar acciones de vacunación preventiva para perros y gatos, contribuyendo al control de la rabia y a la protección de la salud pública.',
    'disponible',
    5,
	2065,
    1877
),

(
    10,
    'BRI-008',
    'Brigada Huellitas Saludables',
    'Brigada móvil dedicada a realizar jornadas gratuitas de vacunación antirrábica para mascotas en colonias y espacios públicos, acercando los servicios veterinarios a la comunidad.',
    'disponible',
    5,
    1446,
    1314
),

(
    10,
    'BRI-009',
    'Brigada Amigos de Cuatro Patas',
    'Brigada encargada de recorrer diferentes sectores de la ciudad mediante unidades móviles para proporcionar vacunación antirrábica gratuita y orientación a los propietarios de mascotas.',
    'disponible',
    5,
    1756,
    1597
),

(
    10,
    'BRI-010',
    'Brigada Huellas de Esperanza',
    'Brigada veterinaria móvil encargada de realizar jornadas gratuitas de vacunación antirrábica para perros y gatos en colonias y comunidades, promoviendo la tenencia responsable de mascotas y contribuyendo a la prevención de la rabia y la protección de la salud pública.',
    'disponible',
    5,
    967,
    879
)

ON CONFLICT (campania_id, codigo)
DO UPDATE SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    estado = EXCLUDED.estado,
    capacidad_personal = EXCLUDED.capacidad_personal,
    dosis_asignadas = EXCLUDED.dosis_asignadas,
    objetivo_dosis = EXCLUDED.objetivo_dosis,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;

-- =====================================================
-- INSERTAR INTEGRANTES DE LAS 10 BRIGADAS
-- =====================================================

INSERT INTO public.brigada_integrantes (
    brigada_id,
    campania_id,
    personal_id,
    funcion
)

SELECT
    b.id,
    datos.campania_id,
    datos.personal_id,
    datos.funcion

FROM (
    VALUES

    -- =============================================
    -- CAM-006: BRI-001
    -- =============================================

    (6, 'BRI-001', 23, 'responsable'),
    (6, 'BRI-001', 24, 'medico'),
    (6, 'BRI-001', 27, 'enfermero'),
    (6, 'BRI-001',  6, 'enfermero'),
    (6, 'BRI-001', 26, 'conductor'),

    -- =============================================
    -- CAM-006: BRI-002
    -- =============================================

    (6, 'BRI-002',  8, 'responsable'),
    (6, 'BRI-002', 33, 'medico'),
    (6, 'BRI-002', 13, 'enfermero'),
    (6, 'BRI-002', 25, 'enfermero'),
    (6, 'BRI-002', 16, 'conductor'),

    -- =============================================
    -- CAM-007: BRI-003
    -- =============================================

    (7, 'BRI-003', 23, 'responsable'),
    (7, 'BRI-003', 20, 'medico'),
    (7, 'BRI-003', 37, 'enfermero'),
    (7, 'BRI-003', 28, 'enfermero'),
    (7, 'BRI-003', 14, 'conductor'),

    -- =============================================
    -- CAM-007: BRI-004
    -- =============================================

    (7, 'BRI-004', 12, 'responsable'),
    (7, 'BRI-004', 19, 'medico'),
    (7, 'BRI-004', 40, 'enfermero'),
    (7, 'BRI-004',  9, 'enfermero'),
    (7, 'BRI-004',  7, 'conductor'),

    -- =============================================
    -- CAM-007: BRI-005
    -- =============================================

    (7, 'BRI-005',  8, 'responsable'),
    (7, 'BRI-005',  3, 'medico'),
    (7, 'BRI-005',  4, 'enfermero'),
    (7, 'BRI-005', 10, 'enfermero'),
    (7, 'BRI-005', 26, 'conductor'),

    -- =============================================
    -- CAM-010: BRI-006
    -- =============================================

    (10, 'BRI-006', 12, 'responsable'),
    (10, 'BRI-006', 20, 'medico'),
    (10, 'BRI-006', 36, 'enfermero'),
    (10, 'BRI-006', 18, 'enfermero'),
    (10, 'BRI-006', 16, 'conductor'),

    -- =============================================
    -- CAM-010: BRI-007
    -- (Anteriormente BRI-008)
    -- =============================================

    (10, 'BRI-007', 23, 'responsable'),
    (10, 'BRI-007', 31, 'medico'),
    (10, 'BRI-007',  5, 'enfermero'),
    (10, 'BRI-007', 30, 'enfermero'),
    (10, 'BRI-007', 26, 'conductor'),

    -- =============================================
    -- CAM-010: BRI-008
    -- (Anteriormente BRI-007)
    -- =============================================

    (10, 'BRI-008',  8, 'responsable'),
    (10, 'BRI-008',  3, 'medico'),
    (10, 'BRI-008', 11, 'enfermero'),
    (10, 'BRI-008', 29, 'enfermero'),
    (10, 'BRI-008',  7, 'conductor'),

    -- =============================================
    -- CAM-010: BRI-009
    -- =============================================

    (10, 'BRI-009', 12, 'responsable'),
    (10, 'BRI-009', 19, 'medico'),
    (10, 'BRI-009', 15, 'enfermero'),
    (10, 'BRI-009', 32, 'enfermero'),
    (10, 'BRI-009', 14, 'conductor'),

    -- =============================================
    -- CAM-010: BRI-010
    -- =============================================

    (10, 'BRI-010',  8, 'responsable'),
    (10, 'BRI-010', 24, 'medico'),
    (10, 'BRI-010', 22, 'enfermero'),
    (10, 'BRI-010', 34, 'enfermero'),
    (10, 'BRI-010',  7, 'conductor')

) AS datos(
    campania_id,
    codigo_brigada,
    personal_id,
    funcion
)

INNER JOIN public.brigadas b
    ON b.codigo = datos.codigo_brigada
   AND b.campania_id = datos.campania_id

ON CONFLICT (brigada_id, personal_id)
DO UPDATE SET
    funcion = EXCLUDED.funcion;

COMMIT;

BEGIN;

INSERT INTO public.brigada_localidades (
    campania_id,
    brigada_id,
    localidad_id
)
SELECT
    datos.campania_id,
    b.id,
    datos.localidad_id
FROM (
    VALUES
        -- CAMPAÑA 6: VPH
        (6, 'BRI-001', 1), -- Copoya
        (6, 'BRI-002', 2), -- El Jobo

        -- CAMPAÑA 7: INFLUENZA
        (7, 'BRI-003', 3), -- Terán
        (7, 'BRI-003', 4), -- Patria Nueva
        (7, 'BRI-004', 5), -- Centro
        (7, 'BRI-004', 6), -- Cerro Hueco
        (7, 'BRI-005', 2), -- El Jobo

        -- CAMPAÑA 10: CHUCHO MÓVIL
        (10, 'BRI-006', 7), -- Las Granjas
        (10, 'BRI-007', 1), -- Copoya
        (10, 'BRI-007', 10), -- Las Águilas
        (10, 'BRI-008', 3), -- Terán
        (10, 'BRI-009', 8), -- Plan de Ayala
        (10, 'BRI-009', 4), -- Patria Nueva
        (10, 'BRI-010', 9)  -- 24 de Junio

) AS datos(
    campania_id,
    codigo_brigada,
    localidad_id
)
INNER JOIN public.brigadas b
    ON b.codigo = datos.codigo_brigada
   AND b.campania_id = datos.campania_id;

COMMIT;

-- =====================================================
-- VISITAS
-- =====================================================

BEGIN;

CREATE TABLE public.puntos_vacunacion (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    localidad_id BIGINT NOT NULL,
    nombre VARCHAR(180) NOT NULL,
    direccion TEXT,
    referencia TEXT,
    ubicacion GEOGRAPHY(Point, 4326),
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_puntos_localidad
        FOREIGN KEY (localidad_id)
        REFERENCES public.localidades(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_punto_por_localidad
        UNIQUE (localidad_id, nombre)

);

CREATE TABLE public.visitas (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brigada_localidad_id BIGINT NOT NULL,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,

    estado VARCHAR(20) NOT NULL DEFAULT 'planeada'
        CHECK (
            estado IN (
                'planeada',
                'activa',
                'completada',
                'cancelada'
            )
        ),

    observaciones TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_visitas_brigada_localidad
        FOREIGN KEY (brigada_localidad_id)
        REFERENCES public.brigada_localidades(id)
        ON DELETE CASCADE

);

CREATE TABLE public.visita_jornadas (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visita_id BIGINT NOT NULL,
    punto_vacunacion_id BIGINT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,

    dosis_asignadas INTEGER NOT NULL DEFAULT 0
        CHECK (dosis_asignadas >= 0),

    objetivo_dosis INTEGER NOT NULL DEFAULT 0
        CHECK (objetivo_dosis >= 0),

    estado VARCHAR(20) NOT NULL DEFAULT 'programada'
        CHECK (
            estado IN (
                'programada',
                'en_curso',
                'completada',
                'cancelada'
            )
        ),

    observaciones TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_jornadas_visita
        FOREIGN KEY (visita_id)
        REFERENCES public.visitas(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_jornadas_punto
        FOREIGN KEY (punto_vacunacion_id)
        REFERENCES public.puntos_vacunacion(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_jornada_fechas
        CHECK (fecha_fin >= fecha_inicio),

    CONSTRAINT chk_jornada_horarios
        CHECK (hora_fin > hora_inicio)
);

CREATE INDEX idx_puntos_vacunacion_localidad
    ON public.puntos_vacunacion(localidad_id);

CREATE INDEX idx_puntos_vacunacion_ubicacion
    ON public.puntos_vacunacion
    USING GIST (ubicacion);

CREATE INDEX idx_visitas_brigada_localidad
    ON public.visitas(brigada_localidad_id);

CREATE INDEX idx_visita_jornadas_visita
    ON public.visita_jornadas(visita_id);

CREATE INDEX idx_visita_jornadas_punto
    ON public.visita_jornadas(punto_vacunacion_id);

CREATE INDEX idx_visita_jornadas_fechas
    ON public.visita_jornadas(fecha_inicio, fecha_fin);

COMMENT ON TABLE public.puntos_vacunacion IS
'Catálogo de centros de salud, escuelas, parques y otros lugares donde se realizan jornadas de vacunación.';

COMMENT ON TABLE public.visitas IS
'Agrupación de jornadas de vacunación de una brigada en una localidad asignada.';

COMMENT ON TABLE public.visita_jornadas IS
'Programación de cada punto de vacunación con fechas, horarios, dosis asignadas y objetivo.';

COMMENT ON COLUMN public.puntos_vacunacion.ubicacion IS
'Coordenadas geográficas del punto de vacunación. Se utilizarán para calcular recorridos.';

COMMENT ON COLUMN public.visita_jornadas.fecha_inicio IS
'Primer día del periodo de atención en el punto de vacunación.';

COMMENT ON COLUMN public.visita_jornadas.fecha_fin IS
'Último día del periodo de atención en el punto de vacunación.';

COMMENT ON COLUMN public.visita_jornadas.dosis_asignadas IS
'Dosis asignadas a este punto de vacunación para el periodo indicado.';

COMMIT;

BEGIN;

INSERT INTO public.visitas (
    brigada_localidad_id,
    codigo,
    nombre,
    estado
)

SELECT
    bl.id,
    datos.codigo_visita,
    datos.nombre_visita,
    'planeada'

FROM (
    VALUES

    ('CAM-006', 'BRI-001', 'LOC-001', 'VIS-001', 'Visita 1 - Copoya'),
    ('CAM-006', 'BRI-002', 'LOC-002', 'VIS-002', 'Visita 2 - El Jobo'),

    ('CAM-007', 'BRI-003', 'LOC-003', 'VIS-003', 'Visita 3 - Terán'),
    ('CAM-007', 'BRI-003', 'LOC-004', 'VIS-004', 'Visita 4 - Patria Nueva'),

    ('CAM-007', 'BRI-004', 'LOC-005', 'VIS-005', 'Visita 5 - Centro'),
    ('CAM-007', 'BRI-004', 'LOC-006', 'VIS-006', 'Visita 6 - Cerro Hueco'),

    ('CAM-007', 'BRI-005', 'LOC-002', 'VIS-007', 'Visita 7 - El Jobo'),

    ('CAM-010', 'BRI-006', 'LOC-007', 'VIS-008', 'Visita 8 - Las Granjas'),

    ('CAM-010', 'BRI-007', 'LOC-001', 'VIS-009', 'Visita 9 - Copoya'),
    ('CAM-010', 'BRI-007', 'LOC-010', 'VIS-010', 'Visita 10 - Las Águilas'),

    ('CAM-010', 'BRI-008', 'LOC-003', 'VIS-011', 'Visita 11 - Terán'),

    ('CAM-010', 'BRI-009', 'LOC-008', 'VIS-012', 'Visita 12 - Plan de Ayala'),
    ('CAM-010', 'BRI-009', 'LOC-004', 'VIS-013', 'Visita 13 - Patria Nueva'),

    ('CAM-010', 'BRI-010', 'LOC-009', 'VIS-014', 'Visita 14 - 24 de Junio')

) AS datos(
    codigo_campania,
    codigo_brigada,
    codigo_localidad,
    codigo_visita,
    nombre_visita
)

INNER JOIN public.campanias c
    ON c.codigo = datos.codigo_campania

INNER JOIN public.brigadas b
    ON b.campania_id = c.id
   AND b.codigo = datos.codigo_brigada

INNER JOIN public.localidades l
    ON l.codigo = datos.codigo_localidad

INNER JOIN public.brigada_localidades bl
    ON bl.brigada_id = b.id
   AND bl.localidad_id = l.id
   AND bl.campania_id = c.id

ON CONFLICT (codigo)
DO UPDATE SET
    brigada_localidad_id = EXCLUDED.brigada_localidad_id,
    nombre = EXCLUDED.nombre,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;

BEGIN;

INSERT INTO public.puntos_vacunacion (
    localidad_id,
    nombre,
    activo
)

SELECT
    l.id,
    datos.nombre_punto,
    TRUE

FROM (
    VALUES

    -- =============================================
    -- COP0YA - LOC-001
    -- =============================================

    ('LOC-001', 'Centro de Salud Copoya'),
    ('LOC-001', 'Primaria Lázaro Cárdenas'),
    ('LOC-001', 'Plaza Comunitaria IDH Copoya'),
    ('LOC-001', 'Domo de cancha de básquetbol'),
    ('LOC-001', 'Parque Central de Copoya'),

    -- =============================================
    -- EL JOBO - LOC-002
    -- =============================================

    ('LOC-002', 'Centro de Salud El Jobo'),
    ('LOC-002', 'Primaria Francisco Sarabia'),
    ('LOC-002', 'Secundaria Moisés Sáenz Garza'),
    ('LOC-002', 'Centro Ejidal del Jobo'),

    -- =============================================
    -- TERÁN - LOC-003
    -- =============================================

    ('LOC-003', 'Centro de Salud Terán'),
    ('LOC-003', 'Casa de la Cultura de Terán'),
    ('LOC-003', 'Parque de Terán'),

    -- =============================================
    -- PATRIA NUEVA - LOC-004
    -- =============================================

    ('LOC-004', 'Centro de Salud Patria Nueva'),
    ('LOC-004', 'Cancha comunitaria'),
    ('LOC-004', 'Agencia Municipal Patria Nueva'),
    ('LOC-004', 'Unidad Deportiva Patria Nueva'),

    -- =============================================
    -- CENTRO - LOC-005
    -- =============================================

    ('LOC-005', 'Centro de Salud Urbano'),
    ('LOC-005', 'Plaza Central'),

    -- =============================================
    -- CERRO HUECO - LOC-006
    -- =============================================

    ('LOC-006', 'Agencia Municipal de Cerro Hueco'),

    -- =============================================
    -- LAS GRANJAS - LOC-007
    -- =============================================

    ('LOC-007', 'Centro de Salud Urbano Las Granjas'),
    ('LOC-007', 'Agencia Municipal Las Granjas'),
    ('LOC-007', 'Parque El Aguaje'),

    -- =============================================
    -- PLAN DE AYALA - LOC-008
    -- =============================================

    ('LOC-008', 'Agencia Municipal Plan de Ayala'),
    ('LOC-008', 'Parque Central de Plan de Ayala'),

    -- =============================================
    -- 24 DE JUNIO - LOC-009
    -- =============================================

    ('LOC-009', 'Parque comunitario 24 de Junio'),

    -- =============================================
    -- LAS ÁGUILAS - LOC-010
    -- =============================================

    ('LOC-010', 'Parque comunitario de Las Águilas')

) AS datos(codigo_localidad, nombre_punto)

INNER JOIN public.localidades l
    ON l.codigo = datos.codigo_localidad

ON CONFLICT (localidad_id, nombre)
DO UPDATE SET
    activo = TRUE,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;

BEGIN;

-- Evitar duplicar una misma jornada al ejecutar nuevamente.
CREATE UNIQUE INDEX IF NOT EXISTS uq_visita_jornada_punto_periodo
ON public.visita_jornadas (
    visita_id,
    punto_vacunacion_id,
    fecha_inicio,
    fecha_fin
);


-- =====================================================
-- INSERTAR JORNADAS
-- =====================================================

WITH datos (
    codigo_visita,
    codigo_localidad,
    nombre_punto,
    fecha_inicio,
    fecha_fin,
    hora_inicio,
    hora_fin,
    dosis_asignadas,
    objetivo_dosis
) AS (

    VALUES

    -- =============================================
    -- CAM-006 | BRI-001 | COP0YA | VIS-001
    -- =============================================

    (
        'VIS-001', 'LOC-001',
        'Centro de Salud Copoya',
        DATE '2026-10-19', DATE '2026-10-23',
        TIME '08:00', TIME '13:00',
        315, 286
    ),

    (
        'VIS-001', 'LOC-001',
        'Primaria Lázaro Cárdenas',
        DATE '2026-10-26', DATE '2026-10-30',
        TIME '08:30', TIME '13:30',
        284, 259
    ),

    (
        'VIS-001', 'LOC-001',
        'Plaza Comunitaria IDH Copoya',
        DATE '2026-11-03', DATE '2026-11-06',
        TIME '08:30', TIME '13:30',
        252, 229
    ),

    (
        'VIS-001', 'LOC-001',
        'Domo de cancha de básquetbol',
        DATE '2026-11-09', DATE '2026-11-13',
        TIME '08:00', TIME '14:00',
        188, 171
    ),

    -- =============================================
    -- CAM-006 | BRI-002 | EL JOBO | VIS-002
    -- =============================================

    (
        'VIS-002', 'LOC-002',
        'Centro de Salud El Jobo',
        DATE '2026-11-16', DATE '2026-11-20',
        TIME '08:00', TIME '13:00',
        250, 227
    ),

    (
        'VIS-002', 'LOC-002',
        'Primaria Francisco Sarabia',
        DATE '2026-11-23', DATE '2026-11-27',
        TIME '08:00', TIME '13:00',
        220, 200
    ),

    (
        'VIS-002', 'LOC-002',
        'Secundaria Moisés Sáenz Garza',
        DATE '2026-11-30', DATE '2026-12-04',
        TIME '08:00', TIME '14:00',
        141, 128
    ),

    -- =============================================
    -- CAM-007 | BRI-003 | TERÁN | VIS-003
    -- =============================================

    (
        'VIS-003', 'LOC-003',
        'Centro de Salud Terán',
        DATE '2026-11-14', DATE '2026-11-15',
        TIME '08:00', TIME '13:30',
        650, 591
    ),

    (
        'VIS-003', 'LOC-003',
        'Casa de la Cultura de Terán',
        DATE '2027-01-11', DATE '2027-01-15',
        TIME '08:00', TIME '14:00',
        421, 383
    ),

    -- =============================================
    -- CAM-007 | BRI-003 | PATRIA NUEVA | VIS-004
    -- =============================================

    (
        'VIS-004', 'LOC-004',
        'Centro de Salud Patria Nueva',
        DATE '2026-11-21', DATE '2026-11-22',
        TIME '08:00', TIME '14:00',
        308, 280
    ),

    (
        'VIS-004', 'LOC-004',
        'Cancha comunitaria',
        DATE '2026-12-05', DATE '2026-12-08',
        TIME '08:00', TIME '13:30',
        200, 182
    ),

    -- =============================================
    -- CAM-007 | BRI-004 | CENTRO | VIS-005
    -- =============================================

    (
        'VIS-005', 'LOC-005',
        'Centro de Salud Urbano',
        DATE '2027-02-01', DATE '2027-02-05',
        TIME '08:00', TIME '14:00',
        300, 273
    ),

    (
        'VIS-005', 'LOC-005',
        'Plaza Central',
        DATE '2027-02-08', DATE '2027-02-12',
        TIME '08:00', TIME '14:00',
        153, 139
    ),

    -- =============================================
    -- CAM-007 | BRI-004 | CERRO HUECO | VIS-006
    -- =============================================
    (
        'VIS-006', 'LOC-006',
        'Agencia Municipal de Cerro Hueco',
        DATE '2027-02-15', DATE '2027-02-19',
        TIME '08:00', TIME '14:00',
        518, 470
    ),

    -- =============================================
    -- CAM-007 | BRI-005 | EL JOBO | VIS-007
    -- =============================================

    (
        'VIS-007', 'LOC-002',
        'Centro de Salud El Jobo',
        DATE '2027-02-06', DATE '2027-02-07',
        TIME '08:00', TIME '14:00',
        450, 409
    ),

    (
        'VIS-007', 'LOC-002',
        'Centro Ejidal del Jobo',
        DATE '2027-03-01', DATE '2027-03-05',
        TIME '08:00', TIME '14:00',
        300, 273
    ),

    -- =============================================
    -- CAM-010 | BRI-006 | LAS GRANJAS | VIS-008
    -- =============================================

    (
        'VIS-008', 'LOC-007',
        'Centro de Salud Urbano Las Granjas',
        DATE '2027-01-05', DATE '2027-01-08',
        TIME '09:00', TIME '14:30',
        1000, 909
    ),

    (
        'VIS-008', 'LOC-007',
        'Agencia Municipal Las Granjas',
        DATE '2027-01-25', DATE '2027-01-28',
        TIME '09:00', TIME '14:30',
        900, 818
    ),

    (
        'VIS-008', 'LOC-007',
        'Parque El Aguaje',
        DATE '2027-02-13', DATE '2027-02-14',
        TIME '09:00', TIME '14:00',
        666, 606
    ),

    -- =============================================
    -- CAM-010 | BRI-007 | COP0YA | VIS-009
    -- =============================================

    (
        'VIS-009', 'LOC-001',
        'Centro de Salud Copoya',
        DATE '2027-01-16', DATE '2027-01-19',
        TIME '09:00', TIME '14:30',
        900, 818
    ),

    (
        'VIS-009', 'LOC-001',
        'Parque Central de Copoya',
        DATE '2027-01-22', DATE '2027-01-24',
        TIME '09:00', TIME '14:00',
        823, 748
    ),

    -- =============================================
    -- CAM-010 | BRI-007 | LAS ÁGUILAS | VIS-010
    -- =============================================

    (
        'VIS-010', 'LOC-010',
        'Parque comunitario de Las Águilas',
        DATE '2027-02-25', DATE '2027-02-28',
        TIME '09:00', TIME '14:00',
        342, 311
    ),

    -- =============================================
    -- CAM-010 | BRI-008 | TERÁN | VIS-011
    -- =============================================

    (
        'VIS-011', 'LOC-003',
        'Parque de Terán',
        DATE '2027-03-20', DATE '2027-03-30',
        TIME '09:00', TIME '14:30',
        1446, 1314
    ),

    -- =============================================
    -- CAM-010 | BRI-009 | PLAN DE AYALA | VIS-012
    -- =============================================

    (
        'VIS-012', 'LOC-008',
        'Agencia Municipal Plan de Ayala',
        DATE '2027-03-06', DATE '2027-03-07',
        TIME '09:00', TIME '14:30',
        650, 591
    ),

    (
        'VIS-012', 'LOC-008',
        'Parque Central de Plan de Ayala',
        DATE '2027-03-09', DATE '2027-03-13',
        TIME '09:00', TIME '14:00',
        420, 382
    ),

    -- =============================================
    -- CAM-010 | BRI-009 | PATRIA NUEVA | VIS-013
    -- =============================================

    (
        'VIS-013', 'LOC-004',
        'Agencia Municipal Patria Nueva',
        DATE '2027-01-09', DATE '2027-01-10',
        TIME '09:00', TIME '14:30',
        400, 364
    ),

    (
        'VIS-013', 'LOC-004',
        'Unidad Deportiva Patria Nueva',
        DATE '2027-02-20', DATE '2027-02-21',
        TIME '09:00', TIME '14:00',
        286, 260
    ),

    -- =============================================
    -- CAM-010 | BRI-010 | 24 DE JUNIO | VIS-014
    -- =============================================

    (
        'VIS-014', 'LOC-009',
        'Parque comunitario 24 de Junio',
        DATE '2027-01-29', DATE '2027-01-31',
        TIME '09:00', TIME '14:30',
        967, 879
    )

)

INSERT INTO public.visita_jornadas (
    visita_id,
    punto_vacunacion_id,
    fecha_inicio,
    fecha_fin,
    hora_inicio,
    hora_fin,
    dosis_asignadas,
    objetivo_dosis,
    estado
)

SELECT
    v.id,
    p.id,
    d.fecha_inicio,
    d.fecha_fin,
    d.hora_inicio,
    d.hora_fin,
    d.dosis_asignadas,
    d.objetivo_dosis,
    'programada'

FROM datos d

INNER JOIN public.visitas v
    ON v.codigo = d.codigo_visita

INNER JOIN public.localidades l
    ON l.codigo = d.codigo_localidad

INNER JOIN public.puntos_vacunacion p
    ON p.localidad_id = l.id
   AND p.nombre = d.nombre_punto

ON CONFLICT (
    visita_id,
    punto_vacunacion_id,
    fecha_inicio,
    fecha_fin
)
DO UPDATE SET
    hora_inicio = EXCLUDED.hora_inicio,
    hora_fin = EXCLUDED.hora_fin,
    dosis_asignadas = EXCLUDED.dosis_asignadas,
    objetivo_dosis = EXCLUDED.objetivo_dosis,
    estado = EXCLUDED.estado,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;

-- =====================================================
-- COORDENADAS DE LOS PUNTOS DE VACUNACIÓN
-- TUxtla Gutiérrez, Chiapas
-- =====================================================

WITH coordenadas (
    codigo_localidad,
    nombre_punto,
    latitud,
    longitud
) AS (
    VALUES

    -- =============================================
    -- COPOYA | LOC-001
    -- =============================================

    ('LOC-001', 'Centro de Salud Copoya',
        16.70985, -93.12274),

    ('LOC-001', 'Primaria Lázaro Cárdenas',
        16.7363, -93.1365),

    ('LOC-001', 'Plaza Comunitaria IDH Copoya',
        16.7139, -93.1194),

    ('LOC-001', 'Domo de cancha de básquetbol',
        16.71422, -93.11817),

    ('LOC-001', 'Parque Central de Copoya',
        16.71415, -93.11945),

    -- =============================================
    -- EL JOBO | LOC-002
    -- =============================================

    ('LOC-002', 'Centro de Salud El Jobo',
        16.7040, -93.1068),

    ('LOC-002', 'Primaria Francisco Sarabia',
        16.70456, -93.103163),

    ('LOC-002', 'Secundaria Moisés Sáenz Garza',
        16.701387, -93.102564),

    ('LOC-002', 'Centro Ejidal del Jobo',
        16.7036, -93.1054),

    -- =============================================
    -- TERÁN | LOC-003
    -- =============================================

    ('LOC-003', 'Centro de Salud Terán',
        16.752882, -93.166290),

    ('LOC-003', 'Casa de la Cultura de Terán',
        16.753835, -93.165416),

    ('LOC-003', 'Parque de Terán',
        16.75360, -93.16267),

    -- =============================================
    -- PATRIA NUEVA | LOC-004
    -- =============================================

    ('LOC-004', 'Centro de Salud Patria Nueva',
        16.7644, -93.0768),

    ('LOC-004', 'Cancha comunitaria',
        16.766723, -93.076722),

    ('LOC-004', 'Agencia Municipal Patria Nueva',
        16.758425, -93.073427),

    ('LOC-004', 'Unidad Deportiva Patria Nueva',
        16.753359, -93.073616),

    -- =============================================
    -- CENTRO | LOC-005
    -- =============================================

    ('LOC-005', 'Centro de Salud Urbano',
        16.74695, -93.07268),

    ('LOC-005', 'Plaza Central',
        16.752718, -93.116515),

    -- =============================================
    -- CERRO HUECO | LOC-006
    -- =============================================

    ('LOC-006', 'Agencia Municipal de Cerro Hueco',
        16.72647, -93.08460),

    -- =============================================
    -- LAS GRANJAS | LOC-007
    -- =============================================

    ('LOC-007', 'Centro de Salud Urbano Las Granjas',
        16.782806, -93.102389),

    ('LOC-007', 'Agencia Municipal Las Granjas',
        16.784534, -93.104443),

    ('LOC-007', 'Parque El Aguaje',
        16.782451, -93.104278),

    -- =============================================
    -- PLAN DE AYALA | LOC-008
    -- =============================================

    ('LOC-008', 'Agencia Municipal Plan de Ayala',
        16.755490, -93.183420),

    ('LOC-008', 'Parque Central de Plan de Ayala',
        16.7570, -93.1815),

    -- =============================================
    -- 24 DE JUNIO | LOC-009
    -- =============================================

    ('LOC-009', 'Parque comunitario 24 de Junio',
        16.7583, -93.0886),

    -- =============================================
    -- LAS ÁGUILAS | LOC-010
    -- =============================================

    ('LOC-010', 'Parque comunitario de Las Águilas',
        16.762953, -93.082725)
),

actualizados AS (
    UPDATE public.puntos_vacunacion p

    SET
        ubicacion = ST_SetSRID(
            ST_MakePoint(
                c.longitud,
                c.latitud
            ),
            4326
        )::geography,

        updated_at = CURRENT_TIMESTAMP

    FROM coordenadas c

    INNER JOIN public.localidades l
        ON l.codigo = c.codigo_localidad

    WHERE p.localidad_id = l.id
      AND p.nombre = c.nombre_punto

    RETURNING p.id
)

-- =====================================================
-- CATÁLOGO DE ORÍGENES DE RECORRIDOS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.origenes_recorrido (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(180) NOT NULL,
    direccion TEXT,
    referencia TEXT,
	
    municipio VARCHAR(120) NOT NULL
        DEFAULT 'Tuxtla Gutiérrez',

    estado VARCHAR(120) NOT NULL
        DEFAULT 'Chiapas',

    codigo_postal VARCHAR(10),
    ubicacion GEOGRAPHY(Point, 4326) NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Solo puede existir un origen principal.

CREATE UNIQUE INDEX IF NOT EXISTS
    uq_origen_recorrido_principal
ON public.origenes_recorrido (es_principal)
WHERE es_principal = TRUE;


-- =====================================================
-- REGISTRAR JURISDICCIÓN SANITARIA 1
-- =====================================================

INSERT INTO public.origenes_recorrido (
    codigo,
    nombre,
    direccion,
    referencia,
    municipio,
    estado,
    codigo_postal,
    ubicacion,
    es_principal,
    activo
)
VALUES (
    'ORI-001',
    'Jurisdicción Sanitaria 1',
    'Av. 10ª Norte Poniente #987, Col. Vista Hermosa / Centro',
    'Esquina con 9ª Norte Poniente',
    'Tuxtla Gutiérrez',
    'Chiapas',
    '29030',

    ST_SetSRID(
        ST_MakePoint(
            -93.1235,
            16.7601
        ),
        4326
    )::geography,

    TRUE,

    TRUE
)

ON CONFLICT (codigo)
DO UPDATE SET
    nombre = EXCLUDED.nombre,
    direccion = EXCLUDED.direccion,
    referencia = EXCLUDED.referencia,
    municipio = EXCLUDED.municipio,
    estado = EXCLUDED.estado,
    codigo_postal = EXCLUDED.codigo_postal,
    ubicacion = EXCLUDED.ubicacion,
    es_principal = TRUE,
    activo = TRUE,
    updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- TABLA DE RECORRIDOS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.recorridos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visita_jornada_id BIGINT NOT NULL,
    origen_id BIGINT NOT NULL,
    geometria GEOMETRY(Geometry, 4326),
    distancia_m NUMERIC(12, 2),
    duracion_seg INTEGER,
    modo_transporte VARCHAR(20) NOT NULL DEFAULT 'driving',
    proveedor VARCHAR(50),
    instrucciones JSONB,
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    error_detalle TEXT,
    calculado_at TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_recorrido_jornada
        UNIQUE (visita_jornada_id),

    CONSTRAINT fk_recorrido_jornada
        FOREIGN KEY (visita_jornada_id)
        REFERENCES public.visita_jornadas(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_recorrido_origen
        FOREIGN KEY (origen_id)
        REFERENCES public.origenes_recorrido(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_recorrido_distancia
        CHECK (
            distancia_m IS NULL OR distancia_m >= 0
        ),

    CONSTRAINT chk_recorrido_duracion
        CHECK (
            duracion_seg IS NULL OR duracion_seg >= 0
        ),

    CONSTRAINT chk_recorrido_modo
        CHECK (
            modo_transporte IN (
                'driving',
                'walking',
                'cycling'
            )
        ),

    CONSTRAINT chk_recorrido_estado
        CHECK (
            estado IN (
                'pendiente',
                'calculado',
                'error'
            )
        )
);

-- Índice espacial para consultar y trabajar
-- con las geometrías de los recorridos.

CREATE INDEX IF NOT EXISTS
    idx_recorridos_geometria
ON public.recorridos
USING GIST (geometria);

-- Índice por origen.

CREATE INDEX IF NOT EXISTS
    idx_recorridos_origen
ON public.recorridos (origen_id);

-- =====================================================
-- PREPARAR RECORRIDOS PARA LAS JORNADAS EXISTENTES
-- =====================================================

INSERT INTO public.recorridos (
    visita_jornada_id,
    origen_id,
    modo_transporte,
    estado
)

SELECT
    j.id,
    o.id,
    'driving',
    'pendiente'

FROM public.visita_jornadas j

CROSS JOIN public.origenes_recorrido o

WHERE o.codigo = 'ORI-001'
  AND o.activo = TRUE

ON CONFLICT (visita_jornada_id)
DO NOTHING;

SELECT
    v.codigo AS visita,
    p.nombre AS punto,
    r.estado,
    ROUND(r.distancia_m, 2) AS distancia_metros,
    r.duracion_seg,
    r.proveedor,
    r.calculado_at,

    CASE
        WHEN r.geometria IS NOT NULL
            THEN ST_GeometryType(r.geometria)
        ELSE 'SIN GEOMETRÍA'
    END AS tipo_geometria,

    CASE
        WHEN r.geometria IS NOT NULL
            THEN ST_SRID(r.geometria)
        ELSE NULL
    END AS srid

FROM recorridos r

INNER JOIN visita_jornadas j
    ON j.id = r.visita_jornada_id

INNER JOIN visitas v
    ON v.id = j.visita_id

INNER JOIN puntos_vacunacion p
    ON p.id = j.punto_vacunacion_id

WHERE v.codigo = 'VIS-001'

ORDER BY j.fecha_inicio;

-- =============================================================
-- INVENTARIO
-- =============================================================

BEGIN;

ALTER TABLE campanias_biologicos
    ADD COLUMN IF NOT EXISTS stock_minimo INTEGER NOT NULL DEFAULT 0
    CHECK (stock_minimo >= 0);

CREATE UNIQUE INDEX IF NOT EXISTS uq_campanias_biologicos_campania_biologico
    ON campanias_biologicos (campania_id, biologico_id);

CREATE TABLE IF NOT EXISTS inventario_biologico_lotes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campania_id BIGINT NOT NULL,
    biologico_id BIGINT NOT NULL,
    codigo_lote VARCHAR(80) NOT NULL,
    fabricante VARCHAR(180) NOT NULL,
    fecha_caducidad DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    observaciones TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_lote_campania_biologico FOREIGN KEY (campania_id, biologico_id)
        REFERENCES campanias_biologicos (campania_id, biologico_id) ON DELETE RESTRICT,
    CONSTRAINT uq_lote_por_campania_biologico UNIQUE (campania_id, biologico_id, codigo_lote)
);

CREATE TABLE IF NOT EXISTS movimientos_biologicos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lote_id BIGINT NOT NULL REFERENCES inventario_biologico_lotes(id) ON DELETE RESTRICT,
    tipo_movimiento VARCHAR(32) NOT NULL CHECK (tipo_movimiento IN (
        'recepcion_campania',
        'recepcion_programada',
        'entrega_brigada',
        'entrega_visita',
        'entrega_jornada',
        'aplicacion',
        'devolucion_jornada',
        'devolucion_visita',
        'devolucion_brigada',
        'devolucion_campania',
        'merma',
        'ajuste_entrada',
        'ajuste_salida'
    )),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    brigada_id BIGINT REFERENCES brigadas(id) ON DELETE RESTRICT,
    visita_id BIGINT REFERENCES visitas(id) ON DELETE RESTRICT,
    visita_jornada_id BIGINT REFERENCES visita_jornadas(id) ON DELETE RESTRICT,
    fecha_operacion DATE NOT NULL DEFAULT CURRENT_DATE,
    persona_entrega VARCHAR(180),
    persona_recibe VARCHAR(180),
    observaciones TEXT,
    clave_registro VARCHAR(120) UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_movimiento_biologico_nivel CHECK (
        (tipo_movimiento IN ('recepcion_campania', 'recepcion_programada', 'devolucion_campania', 'ajuste_entrada', 'ajuste_salida')
            AND brigada_id IS NULL AND visita_id IS NULL AND visita_jornada_id IS NULL)
        OR
        (tipo_movimiento IN ('entrega_brigada', 'devolucion_brigada')
            AND brigada_id IS NOT NULL AND visita_id IS NULL AND visita_jornada_id IS NULL)
        OR
        (tipo_movimiento IN ('entrega_visita', 'devolucion_visita')
            AND brigada_id IS NULL AND visita_id IS NOT NULL AND visita_jornada_id IS NULL)
        OR
        (tipo_movimiento IN ('entrega_jornada', 'aplicacion', 'devolucion_jornada', 'merma')
            AND brigada_id IS NULL AND visita_id IS NULL AND visita_jornada_id IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_mov_biologicos_lote_fecha
    ON movimientos_biologicos (lote_id, fecha_operacion DESC);
CREATE INDEX IF NOT EXISTS idx_mov_biologicos_jornada
    ON movimientos_biologicos (visita_jornada_id)
    WHERE visita_jornada_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mov_biologicos_visita
    ON movimientos_biologicos (visita_id)
    WHERE visita_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mov_biologicos_brigada
    ON movimientos_biologicos (brigada_id)
    WHERE brigada_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS insumos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(180) NOT NULL UNIQUE,
    unidad VARCHAR(40) NOT NULL,
    stock_minimo NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
    stock_objetivo_reposicion NUMERIC(14,2),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    observaciones TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_insumo_objetivo_reposicion CHECK (stock_objetivo_reposicion IS NULL OR stock_objetivo_reposicion >= stock_minimo)
);

CREATE TABLE IF NOT EXISTS movimientos_insumos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    insumo_id BIGINT NOT NULL REFERENCES insumos(id) ON DELETE RESTRICT,
    tipo_movimiento VARCHAR(24) NOT NULL CHECK (tipo_movimiento IN (
        'entrada', 'salida', 'ajuste_positivo', 'ajuste_negativo'
    )),
    cantidad NUMERIC(14,2) NOT NULL CHECK (cantidad > 0),
    fecha_operacion DATE NOT NULL DEFAULT CURRENT_DATE,
    responsable VARCHAR(180),
    observaciones TEXT,
    clave_registro VARCHAR(120) UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mov_insumos_insumo_fecha
    ON movimientos_insumos (insumo_id, fecha_operacion DESC);

CREATE TABLE IF NOT EXISTS notificaciones (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo VARCHAR(60) NOT NULL,
    categoria VARCHAR(30) NOT NULL CHECK (categoria IN (
        'biologicos', 'insumos', 'campanias', 'brigadas', 'visitas', 'general'
    )),
    severidad VARCHAR(16) NOT NULL CHECK (severidad IN (
        'info', 'success', 'warning', 'danger'
    )),
    titulo VARCHAR(180) NOT NULL,
    mensaje TEXT NOT NULL,
    campania_id BIGINT REFERENCES campanias(id) ON DELETE SET NULL,
    visita_id BIGINT REFERENCES visitas(id) ON DELETE SET NULL,
    visita_jornada_id BIGINT REFERENCES visita_jornadas(id) ON DELETE SET NULL,
    lote_id BIGINT REFERENCES inventario_biologico_lotes(id) ON DELETE SET NULL,
    insumo_id BIGINT REFERENCES insumos(id) ON DELETE SET NULL,
    movimiento_biologico_id BIGINT REFERENCES movimientos_biologicos(id) ON DELETE SET NULL,
    movimiento_insumo_id BIGINT REFERENCES movimientos_insumos(id) ON DELETE SET NULL,
    clave_deduplicacion VARCHAR(160),
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    leida_at TIMESTAMPTZ,
    resuelta_at TIMESTAMPTZ,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notificaciones_feed
    ON notificaciones (fecha_creacion DESC);
CREATE INDEX IF NOT EXISTS idx_notificaciones_pendientes
    ON notificaciones (fecha_creacion DESC)
    WHERE leida_at IS NULL AND resuelta_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_notificacion_activa_clave
    ON notificaciones (clave_deduplicacion)
    WHERE clave_deduplicacion IS NOT NULL AND resuelta_at IS NULL;

CREATE OR REPLACE VIEW vw_existencias_insumos AS
SELECT
    i.id AS insumo_id,
    i.codigo,
    i.nombre,
    i.unidad,
    i.stock_minimo,
    i.stock_objetivo_reposicion,
    COALESCE(SUM(
        CASE
            WHEN mi.tipo_movimiento IN ('entrada', 'ajuste_positivo') THEN mi.cantidad
            WHEN mi.tipo_movimiento IN ('salida', 'ajuste_negativo') THEN -mi.cantidad
            ELSE 0
        END
    ), 0)::NUMERIC(14,2) AS existencia_actual,
    MAX(mi.fecha_operacion) FILTER (WHERE mi.tipo_movimiento = 'entrada') AS ultimo_reabastecimiento,
    GREATEST(COALESCE(i.stock_objetivo_reposicion, i.stock_minimo) - COALESCE(SUM(
        CASE
            WHEN mi.tipo_movimiento IN ('entrada', 'ajuste_positivo') THEN mi.cantidad
            WHEN mi.tipo_movimiento IN ('salida', 'ajuste_negativo') THEN -mi.cantidad
            ELSE 0
        END
    ), 0), 0)::NUMERIC(14,2) AS cantidad_sugerida_reponer,
    (COALESCE(SUM(
        CASE
            WHEN mi.tipo_movimiento IN ('entrada', 'ajuste_positivo') THEN mi.cantidad
            WHEN mi.tipo_movimiento IN ('salida', 'ajuste_negativo') THEN -mi.cantidad
            ELSE 0
        END
    ), 0) < i.stock_minimo) AS bajo_stock_minimo
FROM insumos i
LEFT JOIN movimientos_insumos mi ON mi.insumo_id = i.id
GROUP BY i.id, i.codigo, i.nombre, i.unidad, i.stock_minimo, i.stock_objetivo_reposicion;

CREATE OR REPLACE VIEW vw_conciliacion_jornadas_biologicas AS
WITH contexto AS (
    SELECT
        c.id AS campania_id,
        c.codigo AS campania_codigo,
        b.id AS brigada_id,
        b.codigo AS brigada_codigo,
        v.id AS visita_id,
        v.codigo AS visita_codigo,
        vj.id AS visita_jornada_id,
        vj.fecha_inicio,
        vj.fecha_fin,
        vj.estado AS jornada_estado,
        vj.dosis_asignadas,
        vj.objetivo_dosis,
        pv.id AS punto_id,
        pv.nombre AS punto_nombre
    FROM visita_jornadas vj
    JOIN visitas v ON v.id = vj.visita_id
    JOIN brigada_localidades bl ON bl.id = v.brigada_localidad_id
    JOIN brigadas b ON b.id = bl.brigada_id
    JOIN campanias c ON c.id = b.campania_id
    LEFT JOIN puntos_vacunacion pv ON pv.id = vj.punto_vacunacion_id
), movimientos AS (
    SELECT
        m.visita_jornada_id,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'entrega_jornada'), 0) AS dosis_entregadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'aplicacion'), 0) AS dosis_aplicadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_jornada'), 0) AS dosis_devueltas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'merma'), 0) AS dosis_merma
    FROM movimientos_biologicos m
    WHERE m.visita_jornada_id IS NOT NULL
    GROUP BY m.visita_jornada_id
), conciliacion AS (
    SELECT
        x.*,
        COALESCE(m.dosis_entregadas, 0) AS dosis_entregadas,
        COALESCE(m.dosis_aplicadas, 0) AS dosis_aplicadas,
        COALESCE(m.dosis_devueltas, 0) AS dosis_devueltas,
        COALESCE(m.dosis_merma, 0) AS dosis_merma,
        COALESCE(m.dosis_entregadas, 0)
            - COALESCE(m.dosis_aplicadas, 0)
            - COALESCE(m.dosis_devueltas, 0)
            - COALESCE(m.dosis_merma, 0) AS diferencia
    FROM contexto x
    LEFT JOIN movimientos m ON m.visita_jornada_id = x.visita_jornada_id
)
SELECT
    conciliacion.*,
    GREATEST(diferencia, 0) AS dosis_sin_justificar,
    GREATEST(-diferencia, 0) AS exceso_registrado,
    CASE
        WHEN dosis_entregadas = 0 THEN 'sin_entrega'
        WHEN diferencia = 0 THEN 'cuadrado'
        WHEN diferencia > 0 THEN 'faltante'
        ELSE 'exceso_registrado'
    END AS estado_conciliacion
FROM conciliacion;

CREATE OR REPLACE VIEW vw_resumen_inventario_biologico_campanias AS
WITH plan AS (
    SELECT
        cb.campania_id,
        cb.biologico_id,
        COALESCE(SUM(vj.dosis_asignadas), 0) AS dosis_asignadas,
        COALESCE(SUM(vj.objetivo_dosis), 0) AS objetivo_vacunacion
    FROM campanias_biologicos cb
    LEFT JOIN brigadas b ON b.campania_id = cb.campania_id
    LEFT JOIN brigada_localidades bl ON bl.brigada_id = b.id
    LEFT JOIN visitas v ON v.brigada_localidad_id = bl.id
    LEFT JOIN visita_jornadas vj ON vj.visita_id = v.id
    GROUP BY cb.campania_id, cb.biologico_id
), mov AS (
    SELECT
        l.campania_id,
        l.biologico_id,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'recepcion_campania'), 0) AS dosis_recibidas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'recepcion_programada'), 0) AS dosis_programadas_recibir,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'entrega_brigada'), 0) AS entregadas_a_brigadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'entrega_visita'), 0) AS entregadas_a_visitas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'entrega_jornada'), 0) AS entregadas_a_jornadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'aplicacion'), 0) AS dosis_aplicadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_jornada'), 0) AS devueltas_por_jornadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_visita'), 0) AS devueltas_por_visitas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_brigada'), 0) AS devueltas_por_brigadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_campania'), 0) AS devueltas_a_campania,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'merma'), 0) AS dosis_merma,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'ajuste_entrada'), 0) AS ajustes_entrada,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'ajuste_salida'), 0) AS ajustes_salida
    FROM movimientos_biologicos m
    JOIN inventario_biologico_lotes l ON l.id = m.lote_id
    GROUP BY l.campania_id, l.biologico_id
), conciliacion AS (
    SELECT
        c.campania_id,
        SUM(c.dosis_sin_justificar) AS dosis_sin_justificar,
        SUM(c.exceso_registrado) AS exceso_registrado
    FROM vw_conciliacion_jornadas_biologicas c
    GROUP BY c.campania_id
)
SELECT
    ca.id AS campania_id,
    ca.codigo AS campania_codigo,
    ca.nombre AS campania_nombre,
    bio.id AS biologico_id,
    bio.codigo AS biologico_codigo,
    bio.nombre AS biologico_nombre,
    cb.stock_minimo,
    COALESCE(p.dosis_asignadas, 0) AS dosis_asignadas,
    COALESCE(p.objetivo_vacunacion, 0) AS objetivo_vacunacion,
    COALESCE(m.dosis_recibidas, 0) AS dosis_recibidas,
    COALESCE(m.dosis_programadas_recibir, 0) AS dosis_programadas_recibir,
    COALESCE(m.dosis_recibidas, 0) + COALESCE(m.dosis_programadas_recibir, 0) - COALESCE(p.dosis_asignadas, 0) AS reserva_proyectada,
    GREATEST(COALESCE(p.dosis_asignadas, 0) + cb.stock_minimo - COALESCE(m.dosis_recibidas, 0) - COALESCE(m.dosis_programadas_recibir, 0), 0) AS dosis_faltantes_para_plan_y_reserva,
    (COALESCE(m.dosis_recibidas, 0) + COALESCE(m.dosis_programadas_recibir, 0) - COALESCE(p.dosis_asignadas, 0) < cb.stock_minimo) AS bajo_stock_minimo,
    COALESCE(m.entregadas_a_brigadas, 0) AS entregadas_a_brigadas,
    COALESCE(m.entregadas_a_visitas, 0) AS entregadas_a_visitas,
    COALESCE(m.entregadas_a_jornadas, 0) AS entregadas_a_jornadas,
    COALESCE(m.dosis_aplicadas, 0) AS dosis_aplicadas,
    COALESCE(m.devueltas_por_jornadas, 0) AS devueltas_por_jornadas,
    COALESCE(m.devueltas_por_visitas, 0) AS devueltas_por_visitas,
    COALESCE(m.devueltas_por_brigadas, 0) AS devueltas_por_brigadas,
    COALESCE(m.devueltas_a_campania, 0) AS devueltas_a_campania,
    COALESCE(m.dosis_merma, 0) AS dosis_merma,
    COALESCE(co.dosis_sin_justificar, 0) AS dosis_sin_justificar,
    COALESCE(co.exceso_registrado, 0) AS exceso_registrado,
    COALESCE(m.dosis_recibidas, 0)
        + COALESCE(m.devueltas_a_campania, 0)
        + COALESCE(m.ajustes_entrada, 0)
        - COALESCE(m.entregadas_a_brigadas, 0)
        - COALESCE(m.ajustes_salida, 0) AS existencia_en_campania
FROM campanias_biologicos cb
JOIN campanias ca ON ca.id = cb.campania_id
JOIN biologicos bio ON bio.id = cb.biologico_id
LEFT JOIN plan p ON p.campania_id = cb.campania_id AND p.biologico_id = cb.biologico_id
LEFT JOIN mov m ON m.campania_id = cb.campania_id AND m.biologico_id = cb.biologico_id
LEFT JOIN conciliacion co ON co.campania_id = cb.campania_id;

COMMIT;

BEGIN;

UPDATE campanias_biologicos cb
SET stock_minimo = x.stock_minimo
FROM (VALUES
    ('CAM-006', 'BIO-VPH', 20),
    ('CAM-007', 'BIO-INF', 100),
    ('CAM-010', 'BIO-RAB', 100)
) AS x(campania_codigo, biologico_codigo, stock_minimo)
JOIN campanias c ON c.codigo = x.campania_codigo
JOIN biologicos b ON b.codigo = x.biologico_codigo
WHERE cb.campania_id = c.id AND cb.biologico_id = b.id;

INSERT INTO inventario_biologico_lotes
    (campania_id, biologico_id, codigo_lote, fabricante, fecha_caducidad, activo, observaciones)
SELECT c.id, b.id, x.codigo_lote, x.fabricante, x.fecha_caducidad, x.activo, x.observaciones
FROM (VALUES
    ('CAM-006', 'BIO-VPH', 'VPH26-MSD-014', 'Merck Sharp & Dohme', DATE '2029-10-14', TRUE,
     'Lote y caducidad propuestos; verificar contra envase y acta de recepcion.'),
    ('CAM-007', 'BIO-INF', 'INF26-SAN-027', 'Sanofi Pasteur', DATE '2027-10-15', TRUE,
     'Lote y caducidad propuestos; verificar contra envase y acta de recepcion.'),
    ('CAM-010', 'BIO-RAB', 'RAB27-MSD-009', 'MSD Animal Health', DATE '2031-01-09', FALSE,
     'Lote y caducidad propuestos; lote pendiente de recepcion. Verificar contra envase y acta; confirmar conservacion segun indicaciones del fabricante.')
) AS x(campania_codigo, biologico_codigo, codigo_lote, fabricante, fecha_caducidad, activo, observaciones)
JOIN campanias c ON c.codigo = x.campania_codigo
JOIN biologicos b ON b.codigo = x.biologico_codigo
JOIN campanias_biologicos cb ON cb.campania_id = c.id AND cb.biologico_id = b.id
ON CONFLICT (campania_id, biologico_id, codigo_lote)
DO UPDATE SET fabricante = EXCLUDED.fabricante,
              fecha_caducidad = EXCLUDED.fecha_caducidad,
              activo = EXCLUDED.activo,
              observaciones = EXCLUDED.observaciones,
              updated_at = NOW();

INSERT INTO movimientos_biologicos
    (lote_id, tipo_movimiento, cantidad, fecha_operacion, persona_recibe,
     observaciones, clave_registro)
SELECT l.id, CASE WHEN x.campania_codigo = 'CAM-010' THEN 'recepcion_programada' ELSE 'recepcion_campania' END, x.cantidad, x.fecha_recepcion,
       CASE WHEN x.campania_codigo = 'CAM-010' THEN NULL ELSE x.responsable END,
       x.observaciones, x.clave
FROM (VALUES
    ('CAM-006', 'BIO-VPH', 'VPH26-MSD-014', 1670, DATE '2026-10-14', 'Andrea Salazar Flores',
     'Recepcion reportada. Empaques integros; se indico conservacion de 2 a 8 °C, sujeta a comprobacion del registro de temperatura. Lote/caducidad propuestos.',
     'SEED-RECEPCION-CAM006'),
    ('CAM-007', 'BIO-INF', 'INF26-SAN-027', 3400, DATE '2026-10-15', 'Ximena Beltran Ochoa',
     'Recepcion reportada. Empaques integros y sin alteracion visible; verificar monitoreo de cadena de frio. Lote/caducidad propuestos.',
     'SEED-RECEPCION-CAM007'),
    ('CAM-010', 'BIO-RAB', 'RAB27-MSD-009', 8900, DATE '2027-01-09', 'Andrea Salazar Flores',
     'Recepcion programada para el 09/01/2027 (dos dias antes del inicio de CAM-010). Responsable previsto: Andrea Salazar Flores. No contabilizar como existencia fisica hasta confirmar la entrega. Lote/caducidad propuestos; confirmar conservacion con indicaciones del fabricante.',
     'SEED-RECEPCION-CAM010')
) AS x(campania_codigo, biologico_codigo, codigo_lote, cantidad, fecha_recepcion, responsable, observaciones, clave)
JOIN campanias c ON c.codigo = x.campania_codigo
JOIN biologicos b ON b.codigo = x.biologico_codigo
JOIN inventario_biologico_lotes l ON l.campania_id = c.id AND l.biologico_id = b.id AND l.codigo_lote = x.codigo_lote
ON CONFLICT (clave_registro) DO NOTHING;

INSERT INTO movimientos_biologicos
    (lote_id, tipo_movimiento, cantidad, brigada_id, fecha_operacion,
     observaciones, clave_registro)
SELECT l.id, 'entrega_brigada', 851, br.id, DATE '2026-10-19',
       'Traspaso consolidado de 851 dosis para los tres puntos atendidos de VIS-001. Fecha de referencia; validar contra el comprobante de entrega.',
       'SEED-VIS001-ENTREGA-BRI001'
FROM campanias c
JOIN biologicos b ON b.codigo = 'BIO-VPH'
JOIN inventario_biologico_lotes l ON l.campania_id = c.id AND l.biologico_id = b.id AND l.codigo_lote = 'VPH26-MSD-014'
JOIN brigadas br ON br.codigo = 'BRI-001' AND br.campania_id = c.id
WHERE c.codigo = 'CAM-006'
  AND NOT EXISTS (SELECT 1 FROM movimientos_biologicos m WHERE m.clave_registro = 'SEED-VIS001-ENTREGA-BRI001')
ON CONFLICT (clave_registro) DO NOTHING;

INSERT INTO movimientos_biologicos
    (lote_id, tipo_movimiento, cantidad, visita_id, fecha_operacion,
     observaciones, clave_registro)
SELECT l.id, 'entrega_visita', 851, v.id, DATE '2026-10-19',
       'Traspaso consolidado de 851 dosis recibidas para VIS-001 y distribuidas entre sus tres puntos atendidos. Fecha de referencia; validar contra el comprobante de entrega.',
       'SEED-VIS001-ENTREGA-VISITA'
FROM campanias c
JOIN biologicos b ON b.codigo = 'BIO-VPH'
JOIN inventario_biologico_lotes l ON l.campania_id = c.id AND l.biologico_id = b.id AND l.codigo_lote = 'VPH26-MSD-014'
JOIN visitas v ON v.codigo = 'VIS-001'
WHERE c.codigo = 'CAM-006'
  AND NOT EXISTS (SELECT 1 FROM movimientos_biologicos m WHERE m.clave_registro = 'SEED-VIS001-ENTREGA-VISITA')
ON CONFLICT (clave_registro) DO NOTHING;

WITH datos AS (
    SELECT * FROM (VALUES
      ('SEED-VIS001-CENTRO-ENTREGA', 'entrega_jornada', 'Centro de Salud Copoya', 315, 'inicio', 'Entrega registrada para la jornada; fecha operativa tomada del inicio programado.'),
      ('SEED-VIS001-CENTRO-APLICACION', 'aplicacion', 'Centro de Salud Copoya', 301, 'fin', 'Cantidad aplicada de ejemplo para pruebas; sustituir por el dato real validado.'),
      ('SEED-VIS001-CENTRO-DEVOLUCION', 'devolucion_jornada', 'Centro de Salud Copoya', 14, 'fin', 'Devolucion completa: 315 entregadas menos 301 aplicadas = 14 devueltas.'),
      ('SEED-VIS001-PRIMARIA-ENTREGA', 'entrega_jornada', 'Primaria Lazaro Cardenas', 284, 'inicio', 'Entrega registrada para la jornada; fecha operativa tomada del inicio programado.'),
      ('SEED-VIS001-PRIMARIA-APLICACION', 'aplicacion', 'Primaria Lazaro Cardenas', 271, 'fin', 'Cantidad aplicada de ejemplo para pruebas; sustituir por el dato real validado.'),
      ('SEED-VIS001-PRIMARIA-DEVOLUCION', 'devolucion_jornada', 'Primaria Lazaro Cardenas', 13, 'fin', 'Devolucion completa: 284 entregadas menos 271 aplicadas = 13 devueltas.'),
      ('SEED-VIS001-PLAZA-ENTREGA', 'entrega_jornada', 'Plaza Comunitaria IDH Copoya', 252, 'inicio', 'Entrega registrada para la jornada; fecha operativa tomada del inicio programado.'),
      ('SEED-VIS001-PLAZA-APLICACION', 'aplicacion', 'Plaza Comunitaria IDH Copoya', 240, 'fin', 'Cantidad aplicada de ejemplo para pruebas; sustituir por el dato real validado.'),
      ('SEED-VIS001-PLAZA-DEVOLUCION', 'devolucion_jornada', 'Plaza Comunitaria IDH Copoya', 10, 'fin', 'Devolucion incompleta. De 252 entregadas, 240 aplicadas y 10 devueltas, quedan 2 dosis sin justificar.')
    ) AS v(clave, tipo_movimiento, punto_nombre, cantidad, fecha_ref, observaciones)
)
INSERT INTO movimientos_biologicos
    (lote_id, tipo_movimiento, cantidad, visita_jornada_id, fecha_operacion,
     observaciones, clave_registro)
SELECT
    l.id,
    d.tipo_movimiento,
    d.cantidad,
    vj.id,
    CASE WHEN d.fecha_ref = 'inicio' THEN vj.fecha_inicio ELSE vj.fecha_fin END,
    d.observaciones,
    d.clave
FROM datos d
JOIN visitas v ON v.codigo = 'VIS-001'
JOIN visita_jornadas vj ON vj.visita_id = v.id
JOIN puntos_vacunacion pv ON pv.id = vj.punto_vacunacion_id AND pv.nombre = d.punto_nombre
JOIN campanias c ON c.codigo = 'CAM-006'
JOIN biologicos b ON b.codigo = 'BIO-VPH'
JOIN inventario_biologico_lotes l ON l.campania_id = c.id AND l.biologico_id = b.id AND l.codigo_lote = 'VPH26-MSD-014'
WHERE NOT EXISTS (
    SELECT 1 FROM movimientos_biologicos existente WHERE existente.clave_registro = d.clave
)
ON CONFLICT (clave_registro) DO NOTHING;

INSERT INTO insumos (codigo, nombre, unidad, stock_minimo, stock_objetivo_reposicion)
VALUES
('INS-001', 'Guantes de nitrilo', 'Cajas', 10, NULL),
('INS-002', 'Cubrebocas quirurgicos', 'Cajas', 10, NULL),
('INS-003', 'Gel antibacterial', 'Litros', 5, NULL),
('INS-004', 'Gasas esteriles', 'Paquetes', 15, NULL),
('INS-005', 'Algodon', 'Rollos', 10, NULL),
('INS-006', 'Alcohol al 70%', 'Litros', 5, NULL),
('INS-007', 'Jeringas desechables de 1 ml', 'Piezas', 500, NULL),
('INS-008', 'Agujas desechables', 'Piezas', 500, NULL),
('INS-009', 'Torundas de algodon', 'Paquetes', 15, NULL),
('INS-010', 'Curitas o apositos adhesivos', 'Cajas', 5, NULL),
('INS-011', 'Contenedores para punzocortantes', 'Piezas', 5, NULL),
('INS-012', 'Bolsas rojas para residuos biologicos', 'Paquetes', 10, NULL),
('INS-013', 'Bolsas negras para basura comun', 'Paquetes', 5, NULL),
('INS-014', 'Solucion desinfectante', 'Litros', 5, NULL),
('INS-015', 'Campos desechables', 'Paquetes', 5, NULL),
('INS-016', 'Cinta microporosa', 'Rollos', 10, 20),
('INS-017', 'Termometros digitales', 'Piezas', 3, NULL),
('INS-018', 'Termos portavacunas', 'Piezas', 3, NULL),
('INS-019', 'Paquetes refrigerantes', 'Piezas', 20, NULL),
('INS-020', 'Hojas de registro de vacunacion', 'Paquetes', 10, 20),
('INS-021', 'Plumas', 'Piezas', 15, NULL),
('INS-022', 'Etiquetas para identificacion', 'Rollos', 5, NULL),
('INS-023', 'Caretas de proteccion', 'Piezas', 5, NULL),
('INS-024', 'Batas desechables', 'Piezas', 30, NULL)
ON CONFLICT (codigo)
DO UPDATE SET nombre = EXCLUDED.nombre,
              unidad = EXCLUDED.unidad,
              stock_minimo = EXCLUDED.stock_minimo,
              stock_objetivo_reposicion = EXCLUDED.stock_objetivo_reposicion,
              updated_at = NOW();

INSERT INTO movimientos_insumos
    (insumo_id, tipo_movimiento, cantidad, fecha_operacion, observaciones, clave_registro)
SELECT i.id, 'entrada', x.existencia, x.fecha_reabastecimiento,
       'Existencia inicial capturada con los datos proporcionados.',
       'SEED-STOCK-' || x.codigo
FROM (VALUES
('INS-001', 30, DATE '2026-10-05'),
('INS-002', 40, DATE '2026-10-08'),
('INS-003', 25, DATE '2026-10-10'),
('INS-004', 50, DATE '2026-10-02'),
('INS-005', 30, DATE '2026-10-02'),
('INS-006', 20, DATE '2026-10-05'),
('INS-007', 2000, DATE '2026-10-12'),
('INS-008', 2000, DATE '2026-10-12'),
('INS-009', 60, DATE '2026-10-02'),
('INS-010', 20, DATE '2026-10-06'),
('INS-011', 20, DATE '2026-10-09'),
('INS-012', 30, DATE '2026-10-09'),
('INS-013', 20, DATE '2026-10-09'),
('INS-014', 15, DATE '2026-10-10'),
('INS-015', 20, DATE '2026-10-07'),
('INS-016', 3, DATE '2026-09-15'),
('INS-017', 12, DATE '2026-10-11'),
('INS-018', 12, DATE '2026-10-11'),
('INS-019', 60, DATE '2026-10-11'),
('INS-020', 4, DATE '2026-09-20'),
('INS-021', 50, DATE '2026-10-08'),
('INS-022', 15, DATE '2026-10-08'),
('INS-023', 15, DATE '2026-10-05'),
('INS-024', 100, DATE '2026-10-05')
) AS x(codigo, existencia, fecha_reabastecimiento)
JOIN insumos i ON i.codigo = x.codigo
ON CONFLICT (clave_registro) DO NOTHING;

INSERT INTO notificaciones
    (tipo, categoria, severidad, titulo, mensaje, campania_id, lote_id,
     clave_deduplicacion, metadata)
SELECT
    'recepcion_biologico_registrada', 'biologicos', 'info',
    'Recepcion de biologico registrada',
    x.mensaje,
    c.id,
    l.id,
    x.clave,
    jsonb_build_object('dosis_recibidas', x.cantidad, 'fecha_recepcion', x.fecha_recepcion)
FROM (VALUES
    ('CAM-006', 'BIO-VPH', 'VPH26-MSD-014', 1670, DATE '2026-10-14', 'Se registraron 1,670 dosis de BIO-VPH para VPH 2026.', 'SEED-NOTIF-RECEPCION-CAM006'),
    ('CAM-007', 'BIO-INF', 'INF26-SAN-027', 3400, DATE '2026-10-15', 'Se registraron 3,400 dosis de BIO-INF para Influenza 2026-2027.', 'SEED-NOTIF-RECEPCION-CAM007')
) AS x(campania_codigo, biologico_codigo, codigo_lote, cantidad, fecha_recepcion, mensaje, clave)
JOIN campanias c ON c.codigo = x.campania_codigo
JOIN biologicos b ON b.codigo = x.biologico_codigo
JOIN inventario_biologico_lotes l ON l.campania_id = c.id AND l.biologico_id = b.id AND l.codigo_lote = x.codigo_lote
ON CONFLICT DO NOTHING;

-- =============================================================
-- NOTIFICACIONES
-- =============================================================

INSERT INTO notificaciones
    (tipo, categoria, severidad, titulo, mensaje, campania_id, visita_id,
     visita_jornada_id, clave_deduplicacion)
SELECT
    'conciliacion_jornada_completa', 'biologicos', 'success',
    'Jornada finalizada y conciliada',
    x.mensaje,
    c.id,
    v.id,
    vj.id,
    x.clave
FROM (VALUES
    ('Centro de Salud Copoya', 'SEED-NOTIF-CENTRO', 'Centro de Salud Copoya: jornada finalizada. Se registraron 315 dosis entregadas, 301 aplicadas y 14 devueltas. La conciliacion esta completa.'),
    ('Primaria Lazaro Cardenas', 'SEED-NOTIF-PRIMARIA', 'Primaria Lazaro Cardenas: jornada finalizada. Se registraron 284 dosis entregadas, 271 aplicadas y 13 devueltas. La conciliacion esta completa.')
) AS x(punto_nombre, clave, mensaje)
JOIN visitas v ON v.codigo = 'VIS-001'
JOIN campanias c ON c.codigo = 'CAM-006'
JOIN visita_jornadas vj ON vj.visita_id = v.id
JOIN puntos_vacunacion pv ON pv.id = vj.punto_vacunacion_id AND pv.nombre = x.punto_nombre
ON CONFLICT DO NOTHING;

INSERT INTO notificaciones
    (tipo, categoria, severidad, titulo, mensaje, campania_id, visita_id,
     visita_jornada_id, clave_deduplicacion, metadata)
SELECT
    'diferencia_biologico_jornada', 'biologicos', 'danger',
    'Devolucion incompleta: 2 dosis sin justificar',
    'Plaza Comunitaria IDH Copoya: jornada finalizada con 252 dosis entregadas, 240 aplicadas y 10 devueltas. Se esperaban 12 dosis devueltas; faltan 2 por aclarar.',
    c.id, v.id, vj.id, 'SEED-NOTIF-PLAZA-DIFERENCIA',
    jsonb_build_object('dosis_entregadas', 252, 'dosis_aplicadas', 240,
                       'dosis_devueltas', 10, 'dosis_sin_justificar', 2)
FROM visitas v
JOIN campanias c ON c.codigo = 'CAM-006'
JOIN visita_jornadas vj ON vj.visita_id = v.id
JOIN puntos_vacunacion pv ON pv.id = vj.punto_vacunacion_id
WHERE v.codigo = 'VIS-001'
  AND pv.nombre = 'Plaza Comunitaria IDH Copoya'
ON CONFLICT DO NOTHING;

INSERT INTO notificaciones
    (tipo, categoria, severidad, titulo, mensaje, insumo_id,
     clave_deduplicacion, metadata)
SELECT
    'stock_minimo_insumo', 'insumos', 'danger',
    'Insumo por debajo del stock minimo',
    x.mensaje,
    i.id,
    x.clave,
    jsonb_build_object('existencia_actual', x.existencia, 'stock_minimo', x.stock_minimo,
                       'objetivo_reposicion', 20, 'cantidad_sugerida_reponer', x.cantidad_sugerida)
FROM (VALUES
    ('INS-016', 3::NUMERIC, 10::NUMERIC, 17::NUMERIC, 'Cinta microporosa: existencia de 3 rollos, por debajo del minimo de 10. La reposicion sugerida es de 17 rollos para alcanzar una existencia objetivo de 20.', 'SEED-NOTIF-STOCK-CINTA'),
    ('INS-020', 4::NUMERIC, 10::NUMERIC, 16::NUMERIC, 'Hojas de registro de vacunacion: existencia de 4 paquetes, por debajo del minimo de 10. La reposicion sugerida es de 16 paquetes para alcanzar una existencia objetivo de 20.', 'SEED-NOTIF-STOCK-HOJAS')
) AS x(codigo, existencia, stock_minimo, cantidad_sugerida, mensaje, clave)
JOIN insumos i ON i.codigo = x.codigo
ON CONFLICT DO NOTHING;

COMMIT;

BEGIN;

WITH datos AS (
    SELECT * FROM (VALUES
      ('SEED-VIS001-PRIMARIA-ENTREGA', 'entrega_jornada', 284, 'inicio',
       'Entrega registrada para la jornada; cantidad proporcionada para Primaria Lázaro Cárdenas.'),
      ('SEED-VIS001-PRIMARIA-APLICACION', 'aplicacion', 271, 'fin',
       'Cantidad aplicada de ejemplo para pruebas; sustituir por el dato real validado.'),
      ('SEED-VIS001-PRIMARIA-DEVOLUCION', 'devolucion_jornada', 13, 'fin',
       'Devolución completa: 284 entregadas menos 271 aplicadas = 13 devueltas.')
    ) AS x(clave, tipo_movimiento, cantidad, fecha_ref, observaciones)
)
INSERT INTO movimientos_biologicos
    (lote_id, tipo_movimiento, cantidad, visita_jornada_id, fecha_operacion,
     observaciones, clave_registro)
SELECT
    l.id,
    d.tipo_movimiento,
    d.cantidad,
    vj.id,
    CASE WHEN d.fecha_ref = 'inicio' THEN vj.fecha_inicio ELSE vj.fecha_fin END,
    d.observaciones,
    d.clave
FROM datos d
JOIN visitas v ON v.codigo = 'VIS-001'
JOIN visita_jornadas vj ON vj.visita_id = v.id
JOIN puntos_vacunacion pv ON pv.id = vj.punto_vacunacion_id
JOIN campanias c ON c.codigo = 'CAM-006'
JOIN biologicos b ON b.codigo = 'BIO-VPH'
JOIN inventario_biologico_lotes l
  ON l.campania_id = c.id AND l.biologico_id = b.id AND l.codigo_lote = 'VPH26-MSD-014'
WHERE translate(lower(pv.nombre), 'áéíóúüñ', 'aeiouun')
      LIKE '%primaria lazaro cardenas%'
  AND NOT EXISTS (
      SELECT 1 FROM movimientos_biologicos existente
      WHERE existente.clave_registro = d.clave
  )
ON CONFLICT (clave_registro) DO NOTHING;

-- Aviso positivo por la jornada de Primaria Lázaro Cárdenas.
INSERT INTO notificaciones
    (tipo, categoria, severidad, titulo, mensaje, campania_id, visita_id,
     visita_jornada_id, clave_deduplicacion, metadata)
SELECT
    'conciliacion_jornada_completa', 'biologicos', 'success',
    'Jornada finalizada y conciliada',
    'Primaria Lázaro Cárdenas: jornada finalizada. Se registraron 284 dosis entregadas, 271 aplicadas y 13 devueltas. La conciliación está completa.',
    c.id, v.id, vj.id, 'SEED-NOTIF-PRIMARIA',
    jsonb_build_object('entregadas',284,'aplicadas',271,'devueltas',13)
FROM visitas v
JOIN brigada_localidades bl ON bl.id = v.brigada_localidad_id
JOIN brigadas br ON br.id = bl.brigada_id
JOIN campanias c ON c.id = br.campania_id AND c.codigo = 'CAM-006'
JOIN visita_jornadas vj ON vj.visita_id = v.id
JOIN puntos_vacunacion pv ON pv.id = vj.punto_vacunacion_id
WHERE v.codigo = 'VIS-001'
  AND translate(lower(pv.nombre), 'áéíóúüñ', 'aeiouun')
      LIKE '%primaria lazaro cardenas%'
  AND NOT EXISTS (
      SELECT 1 FROM notificaciones n WHERE n.clave_deduplicacion = 'SEED-NOTIF-PRIMARIA'
  )
ON CONFLICT DO NOTHING;

COMMIT;



BEGIN;

CREATE OR REPLACE VIEW vw_resumen_inventario_biologico_campanias AS
WITH plan AS (
    SELECT
        cb.campania_id,
        cb.biologico_id,
        COALESCE(SUM(vj.dosis_asignadas), 0) AS dosis_asignadas,
        COALESCE(SUM(vj.objetivo_dosis), 0) AS objetivo_vacunacion
    FROM campanias_biologicos cb
    LEFT JOIN brigadas b ON b.campania_id = cb.campania_id
    LEFT JOIN brigada_localidades bl ON bl.brigada_id = b.id
    LEFT JOIN visitas v ON v.brigada_localidad_id = bl.id
    LEFT JOIN visita_jornadas vj ON vj.visita_id = v.id
    GROUP BY cb.campania_id, cb.biologico_id
), mov AS (
    SELECT
        l.campania_id,
        l.biologico_id,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'recepcion_campania'), 0) AS dosis_recibidas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'recepcion_programada'), 0) AS dosis_programadas_recibir,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'entrega_brigada'), 0) AS entregadas_a_brigadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'entrega_visita'), 0) AS entregadas_a_visitas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'entrega_jornada'), 0) AS entregadas_a_jornadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'aplicacion'), 0) AS dosis_aplicadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_jornada'), 0) AS devueltas_por_jornadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_visita'), 0) AS devueltas_por_visitas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_brigada'), 0) AS devueltas_por_brigadas,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'devolucion_campania'), 0) AS devueltas_a_campania,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'merma'), 0) AS dosis_merma,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'ajuste_entrada'), 0) AS ajustes_entrada,
        COALESCE(SUM(m.cantidad) FILTER (WHERE m.tipo_movimiento = 'ajuste_salida'), 0) AS ajustes_salida
    FROM movimientos_biologicos m
    JOIN inventario_biologico_lotes l ON l.id = m.lote_id
    GROUP BY l.campania_id, l.biologico_id
), conciliacion AS (
    SELECT
        c.campania_id,
        SUM(c.dosis_sin_justificar) AS dosis_sin_justificar,
        SUM(c.exceso_registrado) AS exceso_registrado
    FROM vw_conciliacion_jornadas_biologicas c
    GROUP BY c.campania_id
)
SELECT
    ca.id AS campania_id,
    ca.codigo AS campania_codigo,
    ca.nombre AS campania_nombre,
    bio.id AS biologico_id,
    bio.codigo AS biologico_codigo,
    bio.nombre AS biologico_nombre,
    cb.stock_minimo,
    COALESCE(p.dosis_asignadas, 0) AS dosis_asignadas,
    COALESCE(p.objetivo_vacunacion, 0) AS objetivo_vacunacion,
    COALESCE(m.dosis_recibidas, 0) AS dosis_recibidas,
    COALESCE(m.dosis_programadas_recibir, 0) AS dosis_programadas_recibir,
    COALESCE(m.dosis_recibidas, 0) + COALESCE(m.dosis_programadas_recibir, 0) - COALESCE(p.dosis_asignadas, 0) AS reserva_proyectada,
    GREATEST(COALESCE(p.dosis_asignadas, 0) + cb.stock_minimo - COALESCE(m.dosis_recibidas, 0) - COALESCE(m.dosis_programadas_recibir, 0), 0) AS dosis_faltantes_para_plan_y_reserva,
    (COALESCE(m.dosis_recibidas, 0) + COALESCE(m.dosis_programadas_recibir, 0) - COALESCE(p.dosis_asignadas, 0) < cb.stock_minimo) AS bajo_stock_minimo,
    COALESCE(m.entregadas_a_brigadas, 0) AS entregadas_a_brigadas,
    COALESCE(m.entregadas_a_visitas, 0) AS entregadas_a_visitas,
    COALESCE(m.entregadas_a_jornadas, 0) AS entregadas_a_jornadas,
    COALESCE(m.dosis_aplicadas, 0) AS dosis_aplicadas,
    COALESCE(m.devueltas_por_jornadas, 0) AS devueltas_por_jornadas,
    COALESCE(m.devueltas_por_visitas, 0) AS devueltas_por_visitas,
    COALESCE(m.devueltas_por_brigadas, 0) AS devueltas_por_brigadas,
    COALESCE(m.devueltas_a_campania, 0) AS devueltas_a_campania,
    COALESCE(m.dosis_merma, 0) AS dosis_merma,
    COALESCE(co.dosis_sin_justificar, 0) AS dosis_sin_justificar,
    COALESCE(co.exceso_registrado, 0) AS exceso_registrado,
    COALESCE(m.dosis_recibidas, 0)
        + COALESCE(m.devueltas_por_brigadas, 0)
        + COALESCE(m.ajustes_entrada, 0)
        - COALESCE(m.entregadas_a_brigadas, 0)
        - COALESCE(m.devueltas_a_campania, 0)
        - COALESCE(m.ajustes_salida, 0) AS existencia_en_campania
FROM campanias_biologicos cb
JOIN campanias ca ON ca.id = cb.campania_id
JOIN biologicos bio ON bio.id = cb.biologico_id
LEFT JOIN plan p ON p.campania_id = cb.campania_id AND p.biologico_id = cb.biologico_id
LEFT JOIN mov m ON m.campania_id = cb.campania_id AND m.biologico_id = cb.biologico_id
LEFT JOIN conciliacion co ON co.campania_id = cb.campania_id;

COMMIT;