--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: wiki; Type: TABLE; Schema: public; Owner: jonputer
--

CREATE TABLE public.wiki (
    inode integer,
    path character varying(255),
    title character varying(255),
    author character varying(255),
    links character varying(100),
    topic character varying(100),
    tags character varying(100),
    created date
);


ALTER TABLE public.wiki OWNER TO jonputer;

--
-- Data for Name: wiki; Type: TABLE DATA; Schema: public; Owner: jonputer
--

COPY public.wiki (inode, path, title, author, links, topic, tags, created) FROM stdin;
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	algebra	linear algebra	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	portugues	seila	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	portugues	seilasfdfkaj;lsdf	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	matematica	razao e proporcao	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	matematica	razao e proporcao	\N	\N
\N	assuntos/linear_systems.md	\N	jonh	matematica	razao e proporcao	\N	\N
\N	asd;kfaj;sdk	\N	\N	\N	\N	\N	\N
\N	teste 1	\N	\N	\N	\N	\N	\N
\N	teste 2	\N	\N	\N	\N	\N	\N
\N	teste 3	\N	\N	\N	\N	\N	\N
\N	teste 4	\N	\N	\N	\N	\N	\N
\N	teste 5	\N	\N	\N	\N	\N	\N
\N	teste 6	\N	\N	\N	\N	\N	\N
\N	teste 7	\N	\N	\N	\N	\N	\N
\N	teste 8	\N	\N	\N	\N	\N	\N
\N	teste 9	\N	\N	\N	\N	\N	\N
\N	teste 10	\N	\N	\N	\N	\N	\N
\N	teste 11	\N	\N	\N	\N	\N	\N
\N	teste 12	\N	\N	\N	\N	\N	\N
\N	teste 13	\N	\N	\N	\N	\N	\N
\N	teste 14	\N	\N	\N	\N	\N	\N
\N	teste 15	\N	\N	\N	\N	\N	\N
\N	teste 16	\N	\N	\N	\N	\N	\N
\N	teste 17	\N	\N	\N	\N	\N	\N
\N	teste 18	\N	\N	\N	\N	\N	\N
\N	teste 19	\N	\N	\N	\N	\N	\N
\N	teste 20	\N	\N	\N	\N	\N	\N
\N	teste 21	\N	\N	\N	\N	\N	\N
\N	teste 22	\N	\N	\N	\N	\N	\N
\N	teste 23	\N	\N	\N	\N	\N	\N
\N	teste 24	\N	\N	\N	\N	\N	\N
\N	teste 25	\N	\N	\N	\N	\N	\N
\N	teste 26	\N	\N	\N	\N	\N	\N
\N	teste 27	\N	\N	\N	\N	\N	\N
\N	teste 28	\N	\N	\N	\N	\N	\N
\N	teste 29	\N	\N	\N	\N	\N	\N
\N	teste 30	\N	\N	\N	\N	\N	\N
\N	teste 1	\N	\N	\N	\N	\N	\N
\N	teste 2	\N	\N	\N	\N	\N	\N
\N	teste 3	\N	\N	\N	\N	\N	\N
\N	teste 4	\N	\N	\N	\N	\N	\N
\N	teste 5	\N	\N	\N	\N	\N	\N
\N	teste 6	\N	\N	\N	\N	\N	\N
\N	teste 7	\N	\N	\N	\N	\N	\N
\N	teste 8	\N	\N	\N	\N	\N	\N
\N	teste 9	\N	\N	\N	\N	\N	\N
\N	teste 10	\N	\N	\N	\N	\N	\N
\N	teste 11	\N	\N	\N	\N	\N	\N
\N	teste 12	\N	\N	\N	\N	\N	\N
\N	teste 13	\N	\N	\N	\N	\N	\N
\N	teste 14	\N	\N	\N	\N	\N	\N
\N	teste 15	\N	\N	\N	\N	\N	\N
\N	teste 16	\N	\N	\N	\N	\N	\N
\N	teste 17	\N	\N	\N	\N	\N	\N
\N	teste 18	\N	\N	\N	\N	\N	\N
\N	teste 19	\N	\N	\N	\N	\N	\N
\N	teste 20	\N	\N	\N	\N	\N	\N
\N	teste 21	\N	\N	\N	\N	\N	\N
\N	teste 22	\N	\N	\N	\N	\N	\N
\N	teste 23	\N	\N	\N	\N	\N	\N
\N	teste 24	\N	\N	\N	\N	\N	\N
\N	teste 25	\N	\N	\N	\N	\N	\N
\N	teste 26	\N	\N	\N	\N	\N	\N
\N	teste 27	\N	\N	\N	\N	\N	\N
\N	teste 28	\N	\N	\N	\N	\N	\N
\N	teste 29	\N	\N	\N	\N	\N	\N
\N	teste 30	\N	\N	\N	\N	\N	\N
\N	teste 1	\N	\N	\N	\N	\N	\N
\N	teste 2	\N	\N	\N	\N	\N	\N
\N	teste 3	\N	\N	\N	\N	\N	\N
\N	teste 4	\N	\N	\N	\N	\N	\N
\N	teste 5	\N	\N	\N	\N	\N	\N
\N	teste 6	\N	\N	\N	\N	\N	\N
\N	teste 7	\N	\N	\N	\N	\N	\N
\N	teste 8	\N	\N	\N	\N	\N	\N
\N	teste 9	\N	\N	\N	\N	\N	\N
\N	teste 10	\N	\N	\N	\N	\N	\N
\N	teste 11	\N	\N	\N	\N	\N	\N
\N	teste 12	\N	\N	\N	\N	\N	\N
\N	teste 13	\N	\N	\N	\N	\N	\N
\N	teste 14	\N	\N	\N	\N	\N	\N
\N	teste 15	\N	\N	\N	\N	\N	\N
\N	teste 16	\N	\N	\N	\N	\N	\N
\N	teste 17	\N	\N	\N	\N	\N	\N
\N	teste 18	\N	\N	\N	\N	\N	\N
\N	teste 19	\N	\N	\N	\N	\N	\N
\N	teste 20	\N	\N	\N	\N	\N	\N
\N	teste 21	\N	\N	\N	\N	\N	\N
\N	teste 22	\N	\N	\N	\N	\N	\N
\N	teste 23	\N	\N	\N	\N	\N	\N
\N	teste 24	\N	\N	\N	\N	\N	\N
\N	teste 25	\N	\N	\N	\N	\N	\N
\N	teste 26	\N	\N	\N	\N	\N	\N
\N	teste 27	\N	\N	\N	\N	\N	\N
\N	teste 28	\N	\N	\N	\N	\N	\N
\N	teste 29	\N	\N	\N	\N	\N	\N
\N	teste 30	\N	\N	\N	\N	\N	\N
12	\N	\N	\N	\N	\N	\N	\N
\.


--
-- PostgreSQL database dump complete
--

