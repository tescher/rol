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

ALTER TABLE ONLY public.interest_categories DROP CONSTRAINT interest_categories_pkey;
ALTER TABLE public.interest_categories ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.interest_categories_id_seq;
DROP TABLE public.interest_categories;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: interest_categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE interest_categories (
    id integer NOT NULL,
    name character varying,
    string character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.interest_categories OWNER TO postgres;

--
-- Name: interest_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE interest_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.interest_categories_id_seq OWNER TO postgres;

--
-- Name: interest_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE interest_categories_id_seq OWNED BY interest_categories.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY interest_categories ALTER COLUMN id SET DEFAULT nextval('interest_categories_id_seq'::regclass);


--
-- Data for Name: interest_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY interest_categories (id, name, string, created_at, updated_at) FROM stdin;
4	Office	\N	2015-02-06 17:49:32.23501	2015-02-06 17:49:32.23501
6	Public Events	\N	2015-10-09 22:17:03.804856	2015-10-09 22:17:03.804856
7	ReStore	\N	2015-10-09 22:17:18.116442	2015-10-09 22:17:18.116442
5	Construction - Light	\N	2015-02-06 17:49:41.540354	2015-10-09 22:17:41.226113
8	Construction - Skilled	\N	2015-10-09 22:17:53.58681	2015-10-09 22:17:53.58681
\.


--
-- Name: interest_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('interest_categories_id_seq', 8, true);


--
-- Name: interest_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY interest_categories
    ADD CONSTRAINT interest_categories_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

