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

ALTER TABLE ONLY public.donation_types DROP CONSTRAINT donation_types_pkey;
ALTER TABLE public.donation_types ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.donation_types_id_seq;
DROP TABLE public.donation_types;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: donation_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE donation_types (
    id integer NOT NULL,
    name character varying,
    non_monetary boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    inactive boolean DEFAULT false NOT NULL
);


--
-- Name: donation_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE donation_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: donation_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE donation_types_id_seq OWNED BY donation_types.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY donation_types ALTER COLUMN id SET DEFAULT nextval('donation_types_id_seq'::regclass);


--
-- Data for Name: donation_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY donation_types (id, name, non_monetary, created_at, updated_at, inactive) FROM stdin;
1	Cash	f	2015-10-07 00:59:11.991576	2015-10-07 00:59:11.991576	f
2	Check	f	2015-10-07 00:59:23.89352	2015-10-07 00:59:23.89352	f
3	ReStore	t	2015-10-07 00:59:36.803092	2015-10-08 21:06:57.719683	f
4	PayPal	f	2015-10-08 21:07:08.71915	2015-10-08 21:07:08.71915	f
5	Credit Card	f	2015-10-08 21:07:18.905221	2015-10-08 21:07:18.905221	f
6	EFT	f	2015-10-08 21:07:28.132806	2015-10-08 21:07:28.132806	f
8	ReStore DropOff	t	2015-10-08 21:07:56.527345	2015-10-08 21:07:56.527345	f
9	ReStore PickUp	t	2015-10-08 21:08:10.720128	2015-10-08 21:08:10.720128	f
7	Other Monetary	f	2015-10-08 21:07:41.351242	2015-10-08 21:52:33.418875	f
10	Other Non-Monetary	t	2015-10-08 21:52:46.5182	2015-10-08 23:15:56.852698	f
\.


--
-- Name: donation_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('donation_types_id_seq', 10, true);


--
-- Name: donation_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY donation_types
    ADD CONSTRAINT donation_types_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

