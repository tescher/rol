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

--
-- Data for Name: donation_types; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- Name: donation_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('donation_types_id_seq', 10, true);


--
-- PostgreSQL database dump complete
--

