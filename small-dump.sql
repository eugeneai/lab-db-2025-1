postgres@study:~$ pg_dump -n eugeneai --insert study
--
-- PostgreSQL database dump
--

\restrict rR7pb20h0NQqICH509JPm4omAU0bkINoRvQpBEyaaGmDaqEXZPuFhNUX7fkn2H8

-- Dumped from database version 14.19 (Ubuntu 14.19-1.pgdg22.04+1)
-- Dumped by pg_dump version 14.19 (Ubuntu 14.19-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: eugeneai; Type: SCHEMA; Schema: -; Owner: student
--

CREATE SCHEMA eugeneai;


ALTER SCHEMA eugeneai OWNER TO student;

--
-- Name: SCHEMA eugeneai; Type: COMMENT; Schema: -; Owner: student
--

COMMENT ON SCHEMA eugeneai IS 'База данных, ПРИМЕР от препода.
Персональная CRM, вариант 65
Github: https://github.com/eugeneai/lab-db-2025-1
DeepSeek: https://chat.deepseek.com/share/qsw0aj5ur8x724w3mk';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: contact; Type: TABLE; Schema: eugeneai; Owner: student
--

CREATE TABLE eugeneai.contact (
    id integer NOT NULL,
    family_name character varying(100) NOT NULL,
    work_place character varying(100),
    phone character varying(20)
);


ALTER TABLE eugeneai.contact OWNER TO student;

--
-- Name: contact_id_seq; Type: SEQUENCE; Schema: eugeneai; Owner: student
--

CREATE SEQUENCE eugeneai.contact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eugeneai.contact_id_seq OWNER TO student;

--
-- Name: contact_id_seq; Type: SEQUENCE OWNED BY; Schema: eugeneai; Owner: student
--

ALTER SEQUENCE eugeneai.contact_id_seq OWNED BY eugeneai.contact.id;


--
-- Name: meeting; Type: TABLE; Schema: eugeneai; Owner: student
--

CREATE TABLE eugeneai.meeting (
    id integer NOT NULL,
    contact_id integer NOT NULL,
    meeting_time timestamp without time zone NOT NULL,
    topic text,
    place text
);


ALTER TABLE eugeneai.meeting OWNER TO student;

--
-- Name: meeting_id_seq; Type: SEQUENCE; Schema: eugeneai; Owner: student
--

CREATE SEQUENCE eugeneai.meeting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eugeneai.meeting_id_seq OWNER TO student;

--
-- Name: meeting_id_seq; Type: SEQUENCE OWNED BY; Schema: eugeneai; Owner: student
--

ALTER SEQUENCE eugeneai.meeting_id_seq OWNED BY eugeneai.meeting.id;


--
-- Name: note; Type: TABLE; Schema: eugeneai; Owner: student
--

CREATE TABLE eugeneai.note (
    id integer NOT NULL,
    meeting_id integer NOT NULL,
    note_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    note_text text NOT NULL
);


ALTER TABLE eugeneai.note OWNER TO student;

--
-- Name: note_id_seq; Type: SEQUENCE; Schema: eugeneai; Owner: student
--

CREATE SEQUENCE eugeneai.note_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eugeneai.note_id_seq OWNER TO student;

--
-- Name: note_id_seq; Type: SEQUENCE OWNED BY; Schema: eugeneai; Owner: student
--

ALTER SEQUENCE eugeneai.note_id_seq OWNED BY eugeneai.note.id;


--
-- Name: two_weeks_meetings; Type: VIEW; Schema: eugeneai; Owner: student
--

CREATE VIEW eugeneai.two_weeks_meetings AS
 SELECT m.meeting_time AS "Дата и время",
    c.family_name AS "Контакт",
    m.topic AS "Тема",
    m.place AS "Место"
   FROM (eugeneai.meeting m
     JOIN eugeneai.contact c ON ((m.contact_id = c.id)))
  WHERE ((m.meeting_time >= (CURRENT_DATE - '7 days'::interval)) AND (m.meeting_time <= (CURRENT_DATE + '7 days'::interval)))
  ORDER BY m.meeting_time;


ALTER TABLE eugeneai.two_weeks_meetings OWNER TO student;

--
-- Name: contact id; Type: DEFAULT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.contact ALTER COLUMN id SET DEFAULT nextval('eugeneai.contact_id_seq'::regclass);


--
-- Name: meeting id; Type: DEFAULT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.meeting ALTER COLUMN id SET DEFAULT nextval('eugeneai.meeting_id_seq'::regclass);


--
-- Name: note id; Type: DEFAULT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.note ALTER COLUMN id SET DEFAULT nextval('eugeneai.note_id_seq'::regclass);


--
-- Data for Name: contact; Type: TABLE DATA; Schema: eugeneai; Owner: student
--

INSERT INTO eugeneai.contact VALUES (1, 'John Lee', 'МФТИ', '+7(913)999-20-30');
INSERT INTO eugeneai.contact VALUES (3, 'John Wang', 'МГУ', '+7(913)924-21-31');
INSERT INTO eugeneai.contact VALUES (2, 'Sam Clinton', 'МИТ', '+1(234)5678900');


--
-- Data for Name: meeting; Type: TABLE DATA; Schema: eugeneai; Owner: student
--

INSERT INTO eugeneai.meeting VALUES (1, 2, '2025-11-11 12:41:09.029324', 'Подготовка научной статьи', 'Washington DC, 1st str., 28-51');
INSERT INTO eugeneai.meeting VALUES (2, 2, '2025-11-11 12:41:53.276792', 'Проведение экспериментов на животных', 'Washington DC, 1st str., lab. 20');
INSERT INTO eugeneai.meeting VALUES (3, 1, '2025-11-11 12:42:51.366582', 'Продление контракта с НАСА', 'New-York, 30th ave., N 20-45');
INSERT INTO eugeneai.meeting VALUES (4, 3, '2025-11-11 12:43:41.886128', 'Обсуждение результатов скдебного заседания от 2025-11-11', 'New-York, 30th ave., N 20-45');


--
-- Data for Name: note; Type: TABLE DATA; Schema: eugeneai; Owner: student
--

INSERT INTO eugeneai.note VALUES (1, 4, '2025-11-11 12:46:20.253116+08', 'Ответчик не согласен с результатами заседания, будет подана аппеляция');
INSERT INTO eugeneai.note VALUES (2, 3, '2025-11-11 12:47:14.664337+08', 'Подготовить документы, согласовать с И. Маском');
INSERT INTO eugeneai.note VALUES (3, 3, '2025-11-11 12:47:50.33464+08', 'Опубликовать сообщение о продлении в социальной сети X');
INSERT INTO eugeneai.note VALUES (4, 3, '2025-11-11 12:48:15.832481+08', 'Передать привет с благодарностью Д. Трампу');
INSERT INTO eugeneai.note VALUES (5, 2, '2025-11-11 12:49:08.566336+08', 'Подготовить лабораторное оборудования для проведения когнитивных тестов с млекопитающими');
INSERT INTO eugeneai.note VALUES (6, 2, '2025-11-11 12:49:59.47296+08', 'Зарезервировать вреемя на проведение эксперимента с использованием "полосы препятствий"');
INSERT INTO eugeneai.note VALUES (7, 2, '2025-11-11 12:50:40.633871+08', 'Выделить две группы белых мышей (основная и контрольная группа) для когнитивных тестов');
INSERT INTO eugeneai.note VALUES (8, 1, '2025-11-11 12:51:41.272638+08', 'Обсудить проект статьи с коллегами из лаборатории');


--
-- Name: contact_id_seq; Type: SEQUENCE SET; Schema: eugeneai; Owner: student
--

SELECT pg_catalog.setval('eugeneai.contact_id_seq', 3, true);


--
-- Name: meeting_id_seq; Type: SEQUENCE SET; Schema: eugeneai; Owner: student
--

SELECT pg_catalog.setval('eugeneai.meeting_id_seq', 4, true);


--
-- Name: note_id_seq; Type: SEQUENCE SET; Schema: eugeneai; Owner: student
--

SELECT pg_catalog.setval('eugeneai.note_id_seq', 8, true);


--
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id);


--
-- Name: meeting meeting_pkey; Type: CONSTRAINT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.meeting
    ADD CONSTRAINT meeting_pkey PRIMARY KEY (id);


--
-- Name: note note_pkey; Type: CONSTRAINT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.note
    ADD CONSTRAINT note_pkey PRIMARY KEY (id);


--
-- Name: idx_meeting_contact; Type: INDEX; Schema: eugeneai; Owner: student
--

CREATE INDEX idx_meeting_contact ON eugeneai.meeting USING btree (contact_id);


--
-- Name: idx_meeting_time; Type: INDEX; Schema: eugeneai; Owner: student
--

CREATE INDEX idx_meeting_time ON eugeneai.meeting USING btree (meeting_time);


--
-- Name: idx_note_meeting; Type: INDEX; Schema: eugeneai; Owner: student
--

CREATE INDEX idx_note_meeting ON eugeneai.note USING btree (meeting_id);


--
-- Name: meeting meeting_contact_id_fkey; Type: FK CONSTRAINT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.meeting
    ADD CONSTRAINT meeting_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES eugeneai.contact(id) ON DELETE CASCADE;


--
-- Name: note note_meeting_id_fkey; Type: FK CONSTRAINT; Schema: eugeneai; Owner: student
--

ALTER TABLE ONLY eugeneai.note
    ADD CONSTRAINT note_meeting_id_fkey FOREIGN KEY (meeting_id) REFERENCES eugeneai.meeting(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--
