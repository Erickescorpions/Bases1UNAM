PGDMP         	                z           PROYECTO    13.2 (Debian 13.2-1.pgdg100+1)    14.3 (Debian 14.3-1.pgdg100+1) D               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    90575    PROYECTO    DATABASE     _   CREATE DATABASE "PROYECTO" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'es_MX.UTF-8';
    DROP DATABASE "PROYECTO";
                postgres    false            �            1255    91829    borrar_orden() 	   PROCEDURE     g   CREATE PROCEDURE public.borrar_orden()
    LANGUAGE plpgsql
    AS $$
begin
	drop view orden;
end;
$$;
 &   DROP PROCEDURE public.borrar_orden();
       public          postgres    false            �            1255    91689    cerrar_orden(integer) 	   PROCEDURE     �  CREATE PROCEDURE public.cerrar_orden(id_mesero integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
	total float = sum("precio") from "CUENTA";
BEGIN
	if exists(select * from "MESERO" where "MESERO"."num_Empleado" = id_mesero) then
		create or replace view orden as(SELECT "descripción", "precio"
		FROM "PRODUCTO" prod FULL OUTER JOIN "LISTA_ORDEN" lst on
		prod."id_Producto" = lst."id_Producto"
		WHERE lst."id_Producto" is not null);
		insert into "ORDEN" VALUES (CONCAT('ORD-',
		CAST (nextval('sec_orden') as varchar)),
		now(), id_mesero, total);
	else
		raise notice 'Error: El empleado no es mesero';
	end if;
	delete from "CUENTA";
END;
$$;
 7   DROP PROCEDURE public.cerrar_orden(id_mesero integer);
       public          postgres    false            �            1255    92002 �   crear_factura(character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, integer, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.crear_factura(rfc character varying, rs character varying, nombre character varying, appat character varying, apmat character varying, estado character varying, colonia character varying, cp integer, calle character varying, num integer, folio character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO "FACTURA" VALUES(rfc, rs, nombre, apPat, apMat, estado, colonia, cp, calle, num, folio);
end;
$$;
   DROP PROCEDURE public.crear_factura(rfc character varying, rs character varying, nombre character varying, appat character varying, apmat character varying, estado character varying, colonia character varying, cp integer, calle character varying, num integer, folio character varying);
       public          postgres    false            �            1255    91608    crear_orden()    FUNCTION     �  CREATE FUNCTION public.crear_orden() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if exists(SELECT * FROM "PRODUCTO" WHERE NEW."id_Producto" = "id_Producto" and "disponibilidad" > 0) then
		update "PRODUCTO" set "disponibilidad" = "disponibilidad" - 1 WHERE NEW."id_Producto" = "id_Producto";
		raise notice 'Producto % añadido', NEW."id_Producto";
		return new;
	else
		raise notice 'Lo sentimos, producto % no disponible', NEW."id_Producto";
		return null;
	end if;
end;
$$;
 $   DROP FUNCTION public.crear_orden();
       public          postgres    false            �            1255    91678    cta_orden(integer) 	   PROCEDURE     ]  CREATE PROCEDURE public.cta_orden(id_prod integer)
    LANGUAGE plpgsql
    AS $$
declare
	precio int = "precio" from "PRODUCTO" WHERE "id_Producto" = id_prod limit 1;
begin 
	if exists(select "id_Producto" from "LISTA_ORDEN" where "id_Producto" = id_prod) then
		insert into "CUENTA" values(precio);
	else
		raise notice 'Error';
	end if;
END;
$$;
 2   DROP PROCEDURE public.cta_orden(id_prod integer);
       public          postgres    false            �            1255    91680    nueva_orden(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.nueva_orden(id_prod integer)
    LANGUAGE plpgsql
    AS $$
begin
	insert into "LISTA_ORDEN" VALUES(id_Prod);
	CALL cta_Orden(id_Prod);
END;
$$;
 4   DROP PROCEDURE public.nueva_orden(id_prod integer);
       public          postgres    false            �            1255    91813     ordenes_entre_fechas(date, date) 	   PROCEDURE     �  CREATE PROCEDURE public.ordenes_entre_fechas(inicio date, fin date)
    LANGUAGE plpgsql
    AS $$
BEGIN
	if exists(select * from "ORDEN" where "fecha" BETWEEN inicio
			 AND fin) 
	then
		raise notice 'Número de ventas: %', count("folio")
			from "ORDEN" where "fecha" between inicio and fin;
		raise notice 'Monto total: %', sum("total") from
			"ORDEN" where "fecha" between inicio and fin;
	else
		raise notice 'Error: No hay ordenes registradas en ese intervalo';
	end if;
END;
$$;
 C   DROP PROCEDURE public.ordenes_entre_fechas(inicio date, fin date);
       public          postgres    false            �            1255    91756    ordenes_por_fecha(date) 	   PROCEDURE     �  CREATE PROCEDURE public.ordenes_por_fecha(fec date)
    LANGUAGE plpgsql
    AS $$
BEGIN
	if exists(select * from "ORDEN" where "fecha" = fec) then
		raise notice 'Número de ventas: %', count("folio")
			from "ORDEN" where "fecha" = fec;
		raise notice 'Monto total: %', sum("total") from
			"ORDEN" where "fecha" = fec;
	else
		raise notice 'Error: No hay ordenes registradas';
	end if;
END;
$$;
 3   DROP PROCEDURE public.ordenes_por_fecha(fec date);
       public          postgres    false            �            1255    91742    resumen_mesero(integer) 	   PROCEDURE     �  CREATE PROCEDURE public.resumen_mesero(id_mesero integer)
    LANGUAGE plpgsql
    AS $$
begin
	if exists(select * from "MESERO" 
			WHERE id_mesero = "num_Empleado") THEN
		raise notice 'Mesero: %', id_mesero;
		raise notice 'Ordenes levantadas: %', count("folio")
			from "ORDEN";
		raise notice 'Total pagado: %', sum("total") from "ORDEN";
	else
		raise notice 'Error: El empleado no es mesero';
	end if;
end;
$$;
 9   DROP PROCEDURE public.resumen_mesero(id_mesero integer);
       public          postgres    false            �            1255    91524    verificar_producto()    FUNCTION     �  CREATE FUNCTION public.verificar_producto() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		IF EXISTS(SELECT "disponibilidad" FROM "PRODUCTO" WHERE "disponibilidad" > 0) THEN
			UPDATE "PRODUCTO" SET "disponibilidad" = "disponibilidad" - 1;
			RAISE NOTICE 'Producto: % añadido', "descripción" FROM "PRODUCTO";
		ELSE
			RAISE EXCEPTION 'Lo sentimos, producto: % no disponible', "descripción" FROM "PRODUCTO";
		END IF;
	END;
$$;
 +   DROP FUNCTION public.verificar_producto();
       public          postgres    false            �            1259    91233    EMPLEADO    TABLE     D  CREATE TABLE public."EMPLEADO" (
    "num_Empleado" integer NOT NULL,
    rfc character varying(13) NOT NULL,
    "fecha_Nacimiento" date NOT NULL,
    foto bytea NOT NULL,
    "nombre_Pila" character varying(50) NOT NULL,
    "ap_Paterno" character varying(50) NOT NULL,
    "ap_Materno" character varying(50),
    sueldo double precision NOT NULL,
    edad smallint NOT NULL,
    estado character varying(30) NOT NULL,
    colonia character varying(30) NOT NULL,
    "código_Postal" integer NOT NULL,
    calle character varying(50) NOT NULL,
    "número" integer NOT NULL
);
    DROP TABLE public."EMPLEADO";
       public         heap    postgres    false            �            1259    91274    ADMINISTRATIVO    TABLE       CREATE TABLE public."ADMINISTRATIVO" (
    "num_Empleado" integer,
    rfc character varying(13),
    "fecha_Nacimiento" date,
    foto bytea,
    "nombre_Pila" character varying(50),
    "ap_Paterno" character varying(50),
    "ap_Materno" character varying(50),
    sueldo double precision,
    edad smallint,
    estado character varying(30),
    colonia character varying(30),
    "código_Postal" integer,
    calle character varying(50),
    "número" integer,
    rol character varying(30) NOT NULL
)
INHERITS (public."EMPLEADO");
 $   DROP TABLE public."ADMINISTRATIVO";
       public         heap    postgres    false    202            �            1259    90637 
   CATEGORÍA    TABLE     ]   CREATE TABLE public."CATEGORÍA" (
    "nombre_Categoría" character varying(30) NOT NULL
);
     DROP TABLE public."CATEGORÍA";
       public         heap    postgres    false            �            1259    91266    COCINERO    TABLE     �  CREATE TABLE public."COCINERO" (
    "num_Empleado" integer,
    rfc character varying(13),
    "fecha_Nacimiento" date,
    foto bytea,
    "nombre_Pila" character varying(50),
    "ap_Paterno" character varying(50),
    "ap_Materno" character varying(50),
    sueldo double precision,
    edad smallint,
    especialidad character varying(30) NOT NULL
)
INHERITS (public."EMPLEADO");
    DROP TABLE public."COCINERO";
       public         heap    postgres    false    202            �            1259    91672    CUENTA    TABLE     >   CREATE TABLE public."CUENTA" (
    precio double precision
);
    DROP TABLE public."CUENTA";
       public         heap    postgres    false            �            1259    91292    FACTURA    TABLE     L  CREATE TABLE public."FACTURA" (
    "rfc_Cliente" character varying(50) NOT NULL,
    "razón_Social" character varying(50) NOT NULL,
    "nombre_Pila" character varying(50) NOT NULL,
    "ap_Paterno" character varying(50) NOT NULL,
    "ap_Materno" character varying(50),
    estado character varying(30) NOT NULL,
    colonia character varying(50) NOT NULL,
    "código_Postal" integer NOT NULL,
    calle character varying(50) NOT NULL,
    "número" integer NOT NULL,
    "folio_ORDEN" character varying(7),
    CONSTRAINT ord_chk CHECK ((("folio_ORDEN")::text ~~ 'ORD-%'::text))
);
    DROP TABLE public."FACTURA";
       public         heap    postgres    false            �            1259    91302    FAMILIAR    TABLE     .  CREATE TABLE public."FAMILIAR" (
    curp character varying(18) NOT NULL,
    parentesco character varying(50) NOT NULL,
    "nombre_Pila_fam" character varying(50) NOT NULL,
    "ap_Paterno_fam" character varying(50) NOT NULL,
    "ap_Materno_fam" character varying(50),
    "num_Empleado" integer
);
    DROP TABLE public."FAMILIAR";
       public         heap    postgres    false            �            1259    91513    LISTA_ORDEN    TABLE     J   CREATE TABLE public."LISTA_ORDEN" (
    "id_Producto" integer NOT NULL
);
 !   DROP TABLE public."LISTA_ORDEN";
       public         heap    postgres    false            �            1259    91258    MESERO    TABLE     Q  CREATE TABLE public."MESERO" (
    "num_Empleado" integer,
    rfc character varying(13),
    "fecha_Nacimiento" date,
    foto bytea,
    "nombre_Pila" character varying(50),
    "ap_Paterno" character varying(50),
    "ap_Materno" character varying(50),
    sueldo double precision,
    edad smallint,
    estado character varying(30),
    colonia character varying(30),
    "código_Postal" integer,
    calle character varying(50),
    "número" integer,
    "hora_Entrada" time without time zone NOT NULL,
    "hora_Salida" time without time zone NOT NULL
)
INHERITS (public."EMPLEADO");
    DROP TABLE public."MESERO";
       public         heap    postgres    false    202            �            1259    91505 	   sec_orden    SEQUENCE     }   CREATE SEQUENCE public.sec_orden
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999
    CACHE 1
    CYCLE;
     DROP SEQUENCE public.sec_orden;
       public          postgres    false            �            1259    91253    ORDEN    TABLE     �   CREATE TABLE public."ORDEN" (
    folio character(50) DEFAULT nextval('public.sec_orden'::regclass) NOT NULL,
    fecha date NOT NULL,
    "num_Mesero" integer,
    total double precision
);
    DROP TABLE public."ORDEN";
       public         heap    postgres    false    210            �            1259    90626    PRODUCTO    TABLE     �  CREATE TABLE public."PRODUCTO" (
    tipo character varying(10) NOT NULL,
    "id_Producto" integer NOT NULL,
    "descripción" character varying(100) NOT NULL,
    receta character varying(150) NOT NULL,
    precio double precision NOT NULL,
    "nombre_Categoría_CATEGORÍA" character varying(30),
    disponibilidad integer,
    CONSTRAINT tipo_chk CHECK ((((tipo)::text = 'ALIMENTO'::text) OR ((tipo)::text = 'BEBIDA'::text)))
);
    DROP TABLE public."PRODUCTO";
       public         heap    postgres    false            �            1259    91243 	   TELÉFONO    TABLE     a   CREATE TABLE public."TELÉFONO" (
    "teléfono" bigint NOT NULL,
    "num_Empleado" integer
);
    DROP TABLE public."TELÉFONO";
       public         heap    postgres    false            �            1259    91909 	   fam_admin    VIEW     �  CREATE VIEW public.fam_admin AS
 SELECT "FAMILIAR"."num_Empleado",
    "FAMILIAR".curp,
    "FAMILIAR".parentesco,
    "FAMILIAR"."nombre_Pila_fam",
    "FAMILIAR"."ap_Paterno_fam",
    "FAMILIAR"."ap_Materno_fam",
    "ADMINISTRATIVO".rfc,
    "ADMINISTRATIVO"."fecha_Nacimiento",
    "ADMINISTRATIVO".foto,
    "ADMINISTRATIVO"."nombre_Pila",
    "ADMINISTRATIVO"."ap_Paterno",
    "ADMINISTRATIVO"."ap_Materno",
    "ADMINISTRATIVO".sueldo,
    "ADMINISTRATIVO".edad,
    "ADMINISTRATIVO".estado,
    "ADMINISTRATIVO".colonia,
    "ADMINISTRATIVO"."código_Postal",
    "ADMINISTRATIVO".calle,
    "ADMINISTRATIVO"."número",
    "ADMINISTRATIVO".rol
   FROM (public."FAMILIAR"
     JOIN public."ADMINISTRATIVO" USING ("num_Empleado"));
    DROP VIEW public.fam_admin;
       public          postgres    false    207    207    207    207    207    207    207    207    207    207    207    209    209    209    209    209    209    207    207    207    207            �            1259    91904    fam_cocineros    VIEW     �  CREATE VIEW public.fam_cocineros AS
 SELECT "FAMILIAR"."num_Empleado",
    "FAMILIAR".curp,
    "FAMILIAR".parentesco,
    "FAMILIAR"."nombre_Pila_fam",
    "FAMILIAR"."ap_Paterno_fam",
    "FAMILIAR"."ap_Materno_fam",
    "COCINERO".rfc,
    "COCINERO"."fecha_Nacimiento",
    "COCINERO".foto,
    "COCINERO"."nombre_Pila",
    "COCINERO"."ap_Paterno",
    "COCINERO"."ap_Materno",
    "COCINERO".sueldo,
    "COCINERO".edad,
    "COCINERO".estado,
    "COCINERO".colonia,
    "COCINERO"."código_Postal",
    "COCINERO".calle,
    "COCINERO"."número",
    "COCINERO".especialidad
   FROM (public."FAMILIAR"
     JOIN public."COCINERO" USING ("num_Empleado"));
     DROP VIEW public.fam_cocineros;
       public          postgres    false    209    209    209    209    209    209    206    206    206    206    206    206    206    206    206    206    206    206    206    206    206            �            1259    91899    fam_meseros    VIEW     �  CREATE VIEW public.fam_meseros AS
 SELECT "FAMILIAR"."num_Empleado",
    "FAMILIAR".curp,
    "FAMILIAR".parentesco,
    "FAMILIAR"."nombre_Pila_fam",
    "FAMILIAR"."ap_Paterno_fam",
    "FAMILIAR"."ap_Materno_fam",
    "MESERO".rfc,
    "MESERO"."fecha_Nacimiento",
    "MESERO".foto,
    "MESERO"."nombre_Pila",
    "MESERO"."ap_Paterno",
    "MESERO"."ap_Materno",
    "MESERO".sueldo,
    "MESERO".edad,
    "MESERO".estado,
    "MESERO".colonia,
    "MESERO"."código_Postal",
    "MESERO".calle,
    "MESERO"."número",
    "MESERO"."hora_Entrada",
    "MESERO"."hora_Salida"
   FROM (public."FAMILIAR"
     JOIN public."MESERO" USING ("num_Empleado"));
    DROP VIEW public.fam_meseros;
       public          postgres    false    209    209    209    209    209    205    205    205    205    205    205    205    205    205    205    205    205    205    205    205    205    209            �            1259    91869 
   info_admin    VIEW     )  CREATE VIEW public.info_admin AS
 SELECT emp."num_Empleado",
    emp.rfc,
    emp."fecha_Nacimiento",
    emp.foto,
    emp."nombre_Pila",
    emp."ap_Paterno",
    emp."ap_Materno",
    emp.sueldo,
    emp.edad,
    emp.estado,
    emp.colonia,
    emp."código_Postal",
    emp.calle,
    emp."número",
    adm.rol
   FROM (public."EMPLEADO" emp
     JOIN public."ADMINISTRATIVO" adm USING ("num_Empleado", rfc, "fecha_Nacimiento", foto, "nombre_Pila", "ap_Paterno", "ap_Materno", sueldo, edad, estado, colonia, "código_Postal", calle, "número"));
    DROP VIEW public.info_admin;
       public          postgres    false    207    207    207    207    207    207    207    207    207    207    207    207    207    207    207    202    202    202    202    202    202    202    202    202    202    202    202    202    202            �            1259    91864    info_cocineros    VIEW     0  CREATE VIEW public.info_cocineros AS
 SELECT emp."num_Empleado",
    emp.rfc,
    emp."fecha_Nacimiento",
    emp.foto,
    emp."nombre_Pila",
    emp."ap_Paterno",
    emp."ap_Materno",
    emp.sueldo,
    emp.edad,
    emp.estado,
    emp.colonia,
    emp."código_Postal",
    emp.calle,
    emp."número",
    coc.especialidad
   FROM (public."EMPLEADO" emp
     JOIN public."COCINERO" coc USING ("num_Empleado", rfc, "fecha_Nacimiento", foto, "nombre_Pila", "ap_Paterno", "ap_Materno", sueldo, edad, estado, colonia, "código_Postal", calle, "número"));
 !   DROP VIEW public.info_cocineros;
       public          postgres    false    206    206    206    206    206    206    206    206    206    206    206    206    206    206    202    202    202    202    202    202    202    202    202    202    202    202    202    202    206            �            1259    91859    info_meseros    VIEW     E  CREATE VIEW public.info_meseros AS
 SELECT emp."num_Empleado",
    emp.rfc,
    emp."fecha_Nacimiento",
    emp.foto,
    emp."nombre_Pila",
    emp."ap_Paterno",
    emp."ap_Materno",
    emp.sueldo,
    emp.edad,
    emp.estado,
    emp.colonia,
    emp."código_Postal",
    emp.calle,
    emp."número",
    mes."hora_Entrada",
    mes."hora_Salida"
   FROM (public."EMPLEADO" emp
     JOIN public."MESERO" mes USING ("num_Empleado", rfc, "fecha_Nacimiento", foto, "nombre_Pila", "ap_Paterno", "ap_Materno", sueldo, edad, estado, colonia, "código_Postal", calle, "número"));
    DROP VIEW public.info_meseros;
       public          postgres    false    202    205    205    205    205    205    205    205    205    205    205    205    205    205    205    205    205    202    202    202    202    202    202    202    202    202    202    202    202    202            �            1259    91938    lista_productos    VIEW     �   CREATE VIEW public.lista_productos AS
 SELECT "PRODUCTO"."id_Producto",
    "PRODUCTO"."descripción",
    "PRODUCTO".precio
   FROM public."PRODUCTO"
  WHERE ("PRODUCTO".disponibilidad > 0);
 "   DROP VIEW public.lista_productos;
       public          postgres    false    200    200    200    200            �            1259    91743    mas_vendido    VIEW     <  CREATE VIEW public.mas_vendido AS
 SELECT "PRODUCTO".tipo,
    "PRODUCTO"."id_Producto",
    "PRODUCTO"."descripción",
    "PRODUCTO".receta,
    "PRODUCTO".precio,
    "PRODUCTO"."nombre_Categoría_CATEGORÍA",
    "PRODUCTO".disponibilidad
   FROM public."PRODUCTO"
  ORDER BY "PRODUCTO".disponibilidad
 LIMIT 1;
    DROP VIEW public.mas_vendido;
       public          postgres    false    200    200    200    200    200    200    200            �            1259    91747    no_disponibles    VIEW     9  CREATE VIEW public.no_disponibles AS
 SELECT "PRODUCTO".tipo,
    "PRODUCTO"."id_Producto",
    "PRODUCTO"."descripción",
    "PRODUCTO".receta,
    "PRODUCTO".precio,
    "PRODUCTO"."nombre_Categoría_CATEGORÍA",
    "PRODUCTO".disponibilidad
   FROM public."PRODUCTO"
  WHERE ("PRODUCTO".disponibilidad = 0);
 !   DROP VIEW public.no_disponibles;
       public          postgres    false    200    200    200    200    200    200    200            �            1259    91929 	   tel_admin    VIEW     o  CREATE VIEW public.tel_admin AS
 SELECT "TELÉFONO"."num_Empleado",
    "TELÉFONO"."teléfono",
    "ADMINISTRATIVO".rfc,
    "ADMINISTRATIVO"."fecha_Nacimiento",
    "ADMINISTRATIVO".foto,
    "ADMINISTRATIVO"."nombre_Pila",
    "ADMINISTRATIVO"."ap_Paterno",
    "ADMINISTRATIVO"."ap_Materno",
    "ADMINISTRATIVO".sueldo,
    "ADMINISTRATIVO".edad,
    "ADMINISTRATIVO".estado,
    "ADMINISTRATIVO".colonia,
    "ADMINISTRATIVO"."código_Postal",
    "ADMINISTRATIVO".calle,
    "ADMINISTRATIVO"."número",
    "ADMINISTRATIVO".rol
   FROM (public."TELÉFONO"
     JOIN public."ADMINISTRATIVO" USING ("num_Empleado"));
    DROP VIEW public.tel_admin;
       public          postgres    false    207    207    207    207    207    207    207    203    203    207    207    207    207    207    207    207    207            �            1259    91924    tel_cocinero    VIEW     !  CREATE VIEW public.tel_cocinero AS
 SELECT "TELÉFONO"."num_Empleado",
    "TELÉFONO"."teléfono",
    "COCINERO".rfc,
    "COCINERO"."fecha_Nacimiento",
    "COCINERO".foto,
    "COCINERO"."nombre_Pila",
    "COCINERO"."ap_Paterno",
    "COCINERO"."ap_Materno",
    "COCINERO".sueldo,
    "COCINERO".edad,
    "COCINERO".estado,
    "COCINERO".colonia,
    "COCINERO"."código_Postal",
    "COCINERO".calle,
    "COCINERO"."número",
    "COCINERO".especialidad
   FROM (public."TELÉFONO"
     JOIN public."COCINERO" USING ("num_Empleado"));
    DROP VIEW public.tel_cocinero;
       public          postgres    false    206    206    203    203    206    206    206    206    206    206    206    206    206    206    206    206    206            �            1259    91919 
   tel_mesero    VIEW       CREATE VIEW public.tel_mesero AS
 SELECT "TELÉFONO"."num_Empleado",
    "TELÉFONO"."teléfono",
    "MESERO".rfc,
    "MESERO"."fecha_Nacimiento",
    "MESERO".foto,
    "MESERO"."nombre_Pila",
    "MESERO"."ap_Paterno",
    "MESERO"."ap_Materno",
    "MESERO".sueldo,
    "MESERO".edad,
    "MESERO".estado,
    "MESERO".colonia,
    "MESERO"."código_Postal",
    "MESERO".calle,
    "MESERO"."número",
    "MESERO"."hora_Entrada",
    "MESERO"."hora_Salida"
   FROM (public."TELÉFONO"
     JOIN public."MESERO" USING ("num_Empleado"));
    DROP VIEW public.tel_mesero;
       public          postgres    false    205    205    203    203    205    205    205    205    205    205    205    205    205    205    205    205    205    205                      0    91274    ADMINISTRATIVO 
   TABLE DATA           �   COPY public."ADMINISTRATIVO" ("num_Empleado", rfc, "fecha_Nacimiento", foto, "nombre_Pila", "ap_Paterno", "ap_Materno", sueldo, edad, estado, colonia, "código_Postal", calle, "número", rol) FROM stdin;
    public          postgres    false    207   }       	          0    90637 
   CATEGORÍA 
   TABLE DATA           ;   COPY public."CATEGORÍA" ("nombre_Categoría") FROM stdin;
    public          postgres    false    201   �}                 0    91266    COCINERO 
   TABLE DATA           �   COPY public."COCINERO" ("num_Empleado", rfc, "fecha_Nacimiento", foto, "nombre_Pila", "ap_Paterno", "ap_Materno", sueldo, edad, estado, colonia, "código_Postal", calle, "número", especialidad) FROM stdin;
    public          postgres    false    206   �}                 0    91672    CUENTA 
   TABLE DATA           *   COPY public."CUENTA" (precio) FROM stdin;
    public          postgres    false    212   �~       
          0    91233    EMPLEADO 
   TABLE DATA           �   COPY public."EMPLEADO" ("num_Empleado", rfc, "fecha_Nacimiento", foto, "nombre_Pila", "ap_Paterno", "ap_Materno", sueldo, edad, estado, colonia, "código_Postal", calle, "número") FROM stdin;
    public          postgres    false    202   �~                 0    91292    FACTURA 
   TABLE DATA           �   COPY public."FACTURA" ("rfc_Cliente", "razón_Social", "nombre_Pila", "ap_Paterno", "ap_Materno", estado, colonia, "código_Postal", calle, "número", "folio_ORDEN") FROM stdin;
    public          postgres    false    208   �~                 0    91302    FAMILIAR 
   TABLE DATA           }   COPY public."FAMILIAR" (curp, parentesco, "nombre_Pila_fam", "ap_Paterno_fam", "ap_Materno_fam", "num_Empleado") FROM stdin;
    public          postgres    false    209   o                 0    91513    LISTA_ORDEN 
   TABLE DATA           6   COPY public."LISTA_ORDEN" ("id_Producto") FROM stdin;
    public          postgres    false    211   �                 0    91258    MESERO 
   TABLE DATA           �   COPY public."MESERO" ("num_Empleado", rfc, "fecha_Nacimiento", foto, "nombre_Pila", "ap_Paterno", "ap_Materno", sueldo, edad, estado, colonia, "código_Postal", calle, "número", "hora_Entrada", "hora_Salida") FROM stdin;
    public          postgres    false    205   �                 0    91253    ORDEN 
   TABLE DATA           D   COPY public."ORDEN" (folio, fecha, "num_Mesero", total) FROM stdin;
    public          postgres    false    204   U�                 0    90626    PRODUCTO 
   TABLE DATA           �   COPY public."PRODUCTO" (tipo, "id_Producto", "descripción", receta, precio, "nombre_Categoría_CATEGORÍA", disponibilidad) FROM stdin;
    public          postgres    false    200   ��                 0    91243 	   TELÉFONO 
   TABLE DATA           B   COPY public."TELÉFONO" ("teléfono", "num_Empleado") FROM stdin;
    public          postgres    false    203   H�                  0    0 	   sec_orden    SEQUENCE SET     8   SELECT pg_catalog.setval('public.sec_orden', 89, true);
          public          postgres    false    210            r           2606    91281     ADMINISTRATIVO ADMINISTRATIVO_pk 
   CONSTRAINT     n   ALTER TABLE ONLY public."ADMINISTRATIVO"
    ADD CONSTRAINT "ADMINISTRATIVO_pk" PRIMARY KEY ("num_Empleado");
 N   ALTER TABLE ONLY public."ADMINISTRATIVO" DROP CONSTRAINT "ADMINISTRATIVO_pk";
       public            postgres    false    207            g           2606    90641    CATEGORÍA CATEGORÍA_pk 
   CONSTRAINT     k   ALTER TABLE ONLY public."CATEGORÍA"
    ADD CONSTRAINT "CATEGORÍA_pk" PRIMARY KEY ("nombre_Categoría");
 F   ALTER TABLE ONLY public."CATEGORÍA" DROP CONSTRAINT "CATEGORÍA_pk";
       public            postgres    false    201            p           2606    91273    COCINERO COCINERO_pk 
   CONSTRAINT     b   ALTER TABLE ONLY public."COCINERO"
    ADD CONSTRAINT "COCINERO_pk" PRIMARY KEY ("num_Empleado");
 B   ALTER TABLE ONLY public."COCINERO" DROP CONSTRAINT "COCINERO_pk";
       public            postgres    false    206            i           2606    91240    EMPLEADO EMPLEADO_pk 
   CONSTRAINT     b   ALTER TABLE ONLY public."EMPLEADO"
    ADD CONSTRAINT "EMPLEADO_pk" PRIMARY KEY ("num_Empleado");
 B   ALTER TABLE ONLY public."EMPLEADO" DROP CONSTRAINT "EMPLEADO_pk";
       public            postgres    false    202            t           2606    91296    FACTURA FACTURA_pk 
   CONSTRAINT     _   ALTER TABLE ONLY public."FACTURA"
    ADD CONSTRAINT "FACTURA_pk" PRIMARY KEY ("rfc_Cliente");
 @   ALTER TABLE ONLY public."FACTURA" DROP CONSTRAINT "FACTURA_pk";
       public            postgres    false    208            v           2606    91306    FAMILIAR FAMILIAR_pk 
   CONSTRAINT     X   ALTER TABLE ONLY public."FAMILIAR"
    ADD CONSTRAINT "FAMILIAR_pk" PRIMARY KEY (curp);
 B   ALTER TABLE ONLY public."FAMILIAR" DROP CONSTRAINT "FAMILIAR_pk";
       public            postgres    false    209            n           2606    91265    MESERO MESERO_pk 
   CONSTRAINT     ^   ALTER TABLE ONLY public."MESERO"
    ADD CONSTRAINT "MESERO_pk" PRIMARY KEY ("num_Empleado");
 >   ALTER TABLE ONLY public."MESERO" DROP CONSTRAINT "MESERO_pk";
       public            postgres    false    205            a           2606    90631    PRODUCTO PRODUCTO_pk 
   CONSTRAINT     a   ALTER TABLE ONLY public."PRODUCTO"
    ADD CONSTRAINT "PRODUCTO_pk" PRIMARY KEY ("id_Producto");
 B   ALTER TABLE ONLY public."PRODUCTO" DROP CONSTRAINT "PRODUCTO_pk";
       public            postgres    false    200            c           2606    91544    PRODUCTO nomprod_un 
   CONSTRAINT     Z   ALTER TABLE ONLY public."PRODUCTO"
    ADD CONSTRAINT nomprod_un UNIQUE ("descripción");
 ?   ALTER TABLE ONLY public."PRODUCTO" DROP CONSTRAINT nomprod_un;
       public            postgres    false    200            e           2606    91484    PRODUCTO producto_un 
   CONSTRAINT     Z   ALTER TABLE ONLY public."PRODUCTO"
    ADD CONSTRAINT producto_un UNIQUE ("id_Producto");
 @   ALTER TABLE ONLY public."PRODUCTO" DROP CONSTRAINT producto_un;
       public            postgres    false    200            k           1259    91843    fki_TELÉFONO_FK    INDEX     T   CREATE INDEX "fki_TELÉFONO_FK" ON public."TELÉFONO" USING btree ("num_Empleado");
 &   DROP INDEX public."fki_TELÉFONO_FK";
       public            postgres    false    203            l           1259    91482    fki_mesero_ord    INDEX     J   CREATE INDEX fki_mesero_ord ON public."ORDEN" USING btree ("num_Mesero");
 "   DROP INDEX public.fki_mesero_ord;
       public            postgres    false    204            j           1259    91823    ind_apellidos    INDEX     `   CREATE INDEX ind_apellidos ON public."EMPLEADO" USING btree ("ap_Paterno" varchar_pattern_ops);
 !   DROP INDEX public.ind_apellidos;
       public            postgres    false    202            y           2620    91633    LISTA_ORDEN crear_orden    TRIGGER     u   CREATE TRIGGER crear_orden BEFORE INSERT ON public."LISTA_ORDEN" FOR EACH ROW EXECUTE FUNCTION public.crear_orden();
 2   DROP TRIGGER crear_orden ON public."LISTA_ORDEN";
       public          postgres    false    239    211            w           2606    91287    PRODUCTO CATEGORÍA_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public."PRODUCTO"
    ADD CONSTRAINT "CATEGORÍA_fk" FOREIGN KEY ("nombre_Categoría_CATEGORÍA") REFERENCES public."CATEGORÍA"("nombre_Categoría") MATCH FULL ON UPDATE CASCADE ON DELETE SET NULL;
 D   ALTER TABLE ONLY public."PRODUCTO" DROP CONSTRAINT "CATEGORÍA_fk";
       public          postgres    false    201    200    2919            x           2606    91477    ORDEN mesero_ord    FK CONSTRAINT     �   ALTER TABLE ONLY public."ORDEN"
    ADD CONSTRAINT mesero_ord FOREIGN KEY ("num_Mesero") REFERENCES public."MESERO"("num_Empleado") NOT VALID;
 <   ALTER TABLE ONLY public."ORDEN" DROP CONSTRAINT mesero_ord;
       public          postgres    false    205    204    2926               {   x��A
�0�����e�h���EI������g��:���������C�Sg���x��(Q7SY�@^Tާd�>�����$��0�m0�V�|��CUtiƾ<����9��q      	   N   x��Q
�0C�{�mE*�I�	��?��'�!���s���襸��/#Fщ0��P�Y^�̨MGxY�f�ϻ���         �   x�%�A��0еr�\ �l74Yjb�c������,K��k�Ls���N|���`����?��g7�l<����D��UH"YY#�`�7����%���NZ��VI,�!�G �����ֈPxO�E��o�:{����&�M5�R�T%�̿�ƍ��9��Oa����'E��NR��r|u]�a4~            x������ � �      
      x������ � �         d   x����0��)� �Q�Q�V�*P�+�H�R�b1���͙Z��~s,�k�m�β�M��z�\�Iw�?��2^O",��(%�mf�̧��>������         :   x��
�44424�t����t
r����w	�tu��r�t�4����� G            x������ � �         o   x�%�A
�0DדS��$Q0�}ͧb
AJYJ���7Ex��c�a�T�����u�]�Z�?D�,��G{�����N#	O,q{!j�,R6�l��5J�=0x0\�F{�bjo��8�         8   x��rѵ0W p���sq�r���� ����aa����� %��         �  x��VK��6]�O�$)��n/a��Т���꩹�,R��:}�<��YS�q�$� &%�tZd���^qG	���.$���~�d<�pR��hQ���KKmEz8�шQ��'CU͉妒JiQ����3iu����w�؊� �w٭ю3Z���,m��
�����᾿�z��l˨��U��|6�>���J���V�2I�M����.ͼ�
�4A��1B��i:a�λ샌�	Y�����V��LÃ>����!\�=��!��G1��GK���p-�]�E�%���"UH��)�����-m�C�$�4J���:}�>�Y�E&��S��P9���{��k�[�_��"��f�h�V��8�(IU�J��6{W�i���H±�Hg����'=7�V��1d;�v|wٸ��7�	�r�B�A�ͱ|�A���N`��1c�\M~B�S�тsf�e.lK���N�ڛ�e$D~7V���q�zc�H�U�ӝ�Kcm�m!*��3i���č�UTa�]ycM��!� ��^:}X���}G�N��ϾY�3��@Lc�)� ��(�v�P��ȡ���!K
x��*���u1��y����"@�FNogc"�a��Y.*�1z�@k��e@�׿͸��ZIg0]8%��k��+ܠl�פ����E�@^,;�c�j�!�qҋi��b�w$��HF��y�"O����F���o:$��^�q�>�/����f%a�J�܋ ��
ͼ�igl�,�.�_�k��S������+�øJg��]:_ca�5z:-��9n������W@�a~��@��{�D��T�5���#7�e�Ze׉$:�x��Cc�!�3�:cBu4�"�!T��k�	�39����Z\�Z��XE;�
�k��S�]�N�I`��.nU�ۭ��c;� Lz�㏷��� ssŬ            x�3555516NC.S�ȉ���� [�H     