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

ALTER TABLE ONLY public.interests DROP CONSTRAINT interests_pkey;
ALTER TABLE public.interests ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.interests_id_seq;
DROP TABLE public.interests;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: interests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE interests (
    id integer NOT NULL,
    name character varying,
    interest_category_id integer,
    highlight boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    inactive boolean DEFAULT false NOT NULL
);


--
-- Name: interests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE interests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE interests_id_seq OWNED BY interests.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY interests ALTER COLUMN id SET DEFAULT nextval('interests_id_seq'::regclass);


--
-- Data for Name: interests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY interests (id, name, interest_category_id, highlight, created_at, updated_at, inactive) FROM stdin;
7	Data Entry	4	f	2015-02-06 17:50:05.737589	2015-02-06 17:50:05.737589	f
9	Painting	5	f	2015-02-06 17:50:33.451562	2015-09-13 14:40:39.083624	f
8	Reception	4	f	2015-02-06 17:50:21.576781	2015-10-09 22:18:33.500788	f
11	Mailings	4	f	2015-10-09 22:18:45.528119	2015-10-09 22:18:45.528119	f
12	Website	4	f	2015-10-09 22:18:58.179736	2015-10-09 22:18:58.179736	f
10	Drywall	8	f	2015-02-06 17:50:45.973437	2015-10-09 22:19:15.967555	f
14	Insulation	5	f	2015-10-09 22:19:50.62127	2015-10-09 22:19:50.62127	f
15	Caulking	5	f	2015-10-09 22:20:03.179194	2015-10-09 22:20:03.179194	f
16	Landscaping	5	f	2015-10-09 22:20:17.788077	2015-10-09 22:20:17.788077	f
17	Provide Lunch	4	t	2015-10-09 22:20:30.154078	2015-10-09 22:20:30.154078	f
18	Siding	8	f	2015-10-09 22:20:49.125777	2015-10-09 22:20:49.125777	f
19	Trim - Finish Work	8	f	2015-10-09 22:21:02.486389	2015-10-09 22:21:02.486389	f
20	Info Tables	6	f	2015-10-09 22:21:20.18592	2015-10-09 22:21:20.18592	f
21	Fundraisers	6	f	2015-10-09 22:21:39.967496	2015-10-09 22:21:39.967496	f
22	WomenBuild	6	f	2015-10-09 22:21:52.971884	2015-10-09 22:21:52.971884	f
23	Shanty Town	6	f	2015-10-09 22:22:06.347121	2015-10-09 22:22:06.347121	f
24	Customer Care	7	f	2015-10-09 22:22:20.811057	2015-10-09 22:22:20.811057	f
25	Cashiering	7	f	2015-10-09 22:22:33.588927	2015-10-09 22:22:33.588927	f
26	Stocking	7	f	2015-10-09 22:22:45.487274	2015-10-09 22:22:45.487274	f
27	Deconstruction	7	t	2015-10-09 22:22:59.79123	2015-10-09 22:22:59.79123	f
13	Cleaning - Sweeping	5	f	2015-10-09 22:19:37.836666	2015-10-09 22:40:22.033698	f
\.


--
-- Name: interests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('interests_id_seq', 27, true);


--
-- Name: interests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interests
    ADD CONSTRAINT interests_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

