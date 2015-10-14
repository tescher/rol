--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.contact_types DROP CONSTRAINT contact_types_pkey;
ALTER TABLE public.contact_types ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.contact_types_id_seq;
DROP TABLE public.contact_types;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contact_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_types (
    id integer NOT NULL,
    name character varying,
    inactive boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contact_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_types_id_seq OWNED BY contact_types.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_types ALTER COLUMN id SET DEFAULT nextval('contact_types_id_seq'::regclass);


--
-- Data for Name: contact_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY contact_types (id, name, inactive, created_at, updated_at) FROM stdin;
1	Advertisement	f	2015-10-14 20:12:48.551262	2015-10-14 20:12:48.551262
2	Church	f	2015-10-14 20:13:08.731229	2015-10-14 20:13:08.731229
3	Employer	f	2015-10-14 20:13:19.526288	2015-10-14 20:13:19.526288
4	Friend	f	2015-10-14 20:13:29.365701	2015-10-14 20:13:29.365701
5	HFHSCA Event	f	2015-10-14 20:13:45.672038	2015-10-14 20:13:45.672038
6	Other	f	2015-10-14 20:13:59.315332	2015-10-14 20:13:59.315332
7	Website	f	2015-10-14 20:14:09.718812	2015-10-14 20:14:09.718812
\.


--
-- Name: contact_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('contact_types_id_seq', 7, true);


--
-- Name: contact_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_types
    ADD CONSTRAINT contact_types_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

