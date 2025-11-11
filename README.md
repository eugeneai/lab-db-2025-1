**Лабораторные работы по БД**

Перечень [лабораторных работ](https://edu.irnok.net/doku.php?id=db:main#%D0%BB%D0%B0%D0%B1%D0%BE%D1%80%D0%B0%D1%82%D0%BE%D1%80%D0%BD%D0%B0%D1%8F_%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0_5_%D1%82%D1%80%D0%B8%D0%B3%D0%B3%D0%B5%D1%80%D1%8B)

Telegram: [at]eugeneai

Ссылка на НОВЫЙ чат Deepseek: https://chat.deepseek.com/share/qsw0aj5ur8x724w3mk

# Постановка задачи (вариант 65)

**Учет контактов и взаимодействий (личная CRM)**

*Сущности:* Контакты (ФИО, место работы, телефон), встречи (дата, тема, место), заметки (дата, текст заметки по контакту).

*Процессы:* Регистрируются все встречи и важные события, связанные с контактами.

*Выходные документы:*

  - Выдать список предстоящих встреч на неделю с указанием контактов и тем, отсортированный по дате и времени.
  - Для заданного контакта выдать историю всех встреч и заметок, отсортированную по дате.

# Лабораторная работа 1 (Проектирование логической и физической модели БД)

<Картинки>

## Промпт к Дипсик

Ссылка на чат:
https://chat.deepseek.com/share/54zhri5m87p2xoywp5

```text
Лаба по проектированию информационной модели для реляционных баз данных.
Предполагаем встречи с только одним контактом (Я и он).
 Предполагаем Postgresql. 
Есть ошибки, замечания, неточности?

# Учет контактов и взаимодействий (личная CRM)*

Дополнительные ограничения:
1. Можно организовать с одним контактом несколько встреч
2. Встречи только с одним контактом.
## Постановка задачи

*Сущности:*
    Контакты (ФИО, место_работы, телефон),
    Встречи (дата, тема, место),
    Заметки (дата, текст_заметки_по_контакту).

*Процессы:* (Отношения)
    Регистрируются все встречи и важные события, связанные с контактами.

*Выходные документы:*

  - Выдать список предстоящих встреч на неделю с указанием контактов и тем, отсортированный по дате и времени.

  - Для заданного контакта выдать историю всех встреч и заметок, отсортированную по дате.

## ER-Модель
### Базовые сущности

    Контакт(ФИО, место_работы, телефон), ключевой набор - телефон
    Встреча(время_встречи, тема, место), ключевой набор - время_встречи

### Отношения

    [Контакт]-1,Required------------------N,Optional-[Встреча]

    [Контакт]-N,Required-----Заметка------M,Optional-[Встреча]
                              текст

    Т.е. отношение "Заметка" содержит атрибут "текст_заметки_по_контакту"

## Логическая модель

Используя правило 1,Required -- N,Optional получаем две *таблицы*

  - ```Contact(family_name, work_place, phone)```, primary key - phone

  - ```Meeting(contact_phone, meeting_time, topic, place)```, primary key - meeting_time

Используя правило N,* -- M,* получаем итого три *таблицы*:

  - ```Contact(family_name, work_place, phone)```, primary key - phone
  - ```Meeting(contact_phone, meeting_time, topic, place)```, primary key - meeting_time
  - ```Note(pk, contact_phone, meeting_time, note)```, secondary key - (contact_phone, meeting_time)

## Физическая модель

Зададим типы данных для атрибутов:

  - ```family_name::varchar```
  - ```work_place::varchar```
  - ```phone::Decimal(10)```
  - ```meeting_time::datetime```
  - ```topic::text```
  - ```place::text```
  - ```pk::integer```
  - ```contact_phone::Decimal(10)```
  - ```note:text```

## Проверка нормальных форм

### Первая нормальная форма

Все значения всех атрибутов атомарные.

### Вторая нормальная форма

Выполняется: нет зависимостей неключевых атрибутов от части ключа

### Третья нормальная форма

Нет транзитивных зависимостей неключей от неключей

### Нормальная форма Бойса-Кодда

Не выполняется, т.к. note (в Note) зависит транзитивно от (contact_phone, meeting_time), а те от pk.
```
# Рестарт проекта с целью лучшего приближения к допущениям и качеству результата

# Отчет по проектированию информационной модели для реляционной БД "Личная CRM"

## Содержание
1. [Постановка задачи](#постановка-задачи)
2. [Концептуальная модель (ER)](#концептуальная-модель-er)
3. [Логическая модель](#логическая-модель)
4. [Физическая модель](#физическая-модель)
5. [SQL DDL](#sql-ddl)
6. [Примеры запросов](#примеры-запросов)
7. [Эволюция проекта](#эволюция-проекта)

## Постановка задачи

### Цель проекта
Разработать реляционную базу данных для учета личных контактов и взаимодействий (личная CRM система).

### Бизнес-требования
- Учет контактов с основной информацией
- Регистрация встреч с контактами
- Ведение заметок по встречам
- Формирование отчетов по предстоящим и прошедшим встречам

### Ограничения
- ✅ Одна встреча проводится только с одним контактом
- ✅ С одним контактом может быть организовано несколько встреч
- ✅ Заметки привязываются к конкретным встречам

### Выходные документы
1. Список предстоящих встреч на неделю с контактами и темами
2. История всех встреч и заметок для заданного контакта

## Концептуальная модель (ER)

```mermaid
erDiagram
    CONTACT ||--o{ MEETING : "имеет"
    MEETING ||--o{ NOTE : "содержит"
    
    CONTACT {
        integer id PK "Суррогатный ключ"
        string family_name "ФИО"
        string work_place "Место работы"
        string phone "Телефон"
    }
    
    MEETING {
        integer id PK "Суррогатный ключ"
        timestamp meeting_time "Дата и время"
        string topic "Тема"
        string place "Место"
    }
    
    NOTE {
        integer id PK "Суррогатный ключ"
        timestamp note_date "Дата заметки"
        string note_text "Текст заметки"
    }
```

### Описание сущностей
- **CONTACT** - информация о контактах (людях)
- **MEETING** - информация о запланированных и состоявшихся встречах  
- **NOTE** - текстовые заметки, сделанные во время или после встреч

## Логическая модель

```mermaid
erDiagram
    CONTACT {
        integer id PK "Первичный ключ"
        varchar family_name "ФИО (обязательно)"
        varchar work_place "Место работы"
        varchar phone "Телефон"
    }
    
    MEETING {
        integer id PK "Первичный ключ"
        integer contact_id FK "Ссылка на контакт"
        timestamp meeting_time "Дата/время встречи"
        text topic "Тема встречи"
        text place "Место встречи"
    }
    
    NOTE {
        integer id PK "Первичный ключ"
        integer meeting_id FK "Ссылка на встречу"
        timestamp note_date "Дата создания заметки"
        text note_text "Текст заметки"
    }
    
    CONTACT ||--o{ MEETING : "один контакт → много встреч"
    MEETING ||--o{ NOTE : "одна встреча → много заметок"
```

### Связи между сущностями
- **Contact → Meeting**: 1:N (один ко многим)
- **Meeting → Note**: 1:N (один ко многим)

## Физическая модель

### Таблицы и типы данных PostgreSQL

```mermaid
erDiagram
    CONTACT {
        integer id PK "SERIAL PRIMARY KEY"
        varchar family_name "NOT NULL"
        varchar work_place "NULL"
        varchar phone "NULL"
        }
    
    MEETING {
        integer id PK "SERIAL PRIMARY KEY"
        integer contact_id FK "NOT NULL REFERENCES Contact(id) ON DELETE CASCADE"
        timestamp meeting_time "NOT NULL"
        text topic "NULL"
        text place "NULL"
        }
    
    NOTE {
        integer id PK "SERIAL PRIMARY KEY"
        integer meeting_id FK "NOT NULL REFERENCES Meeting(id) ON DELETE CASCADE"
        timestamp note_date "NOT NULL DEFAULT CURRENT_TIMESTAMP"
        text note_text "NOT NULL"
        }
    
    CONTACT ||--o{ MEETING : "FOREIGN KEY (contact_id)"
    MEETING ||--o{ NOTE : "FOREIGN KEY (meeting_id)"
```

### Индексы для оптимизации
```sql
-- Для быстрого поиска встреч по дате
CREATE INDEX idx_meeting_time ON Meeting(meeting_time);

-- Для быстрого поиска встреч по контакту  
CREATE INDEX idx_meeting_contact ON Meeting(contact_id);

-- Для быстрого поиска заметок по встрече
CREATE INDEX idx_note_meeting ON Note(meeting_id);
```

## SQL DDL

### Полный скрипт создания базы данных

```sql
-- Таблица контактов
CREATE TABLE Contact (
    id SERIAL PRIMARY KEY,
    family_name VARCHAR(100) NOT NULL,
    work_place VARCHAR(100),
    phone VARCHAR(20)
);

-- Таблица встреч
CREATE TABLE Meeting (
    id SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL,
    meeting_time TIMESTAMP NOT NULL,
    topic TEXT,
    place TEXT,
    FOREIGN KEY (contact_id) REFERENCES Contact(id) ON DELETE CASCADE
);

-- Таблица заметок
CREATE TABLE Note (
    id SERIAL PRIMARY KEY,
    meeting_id INTEGER NOT NULL,
    note_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note_text TEXT NOT NULL,
    FOREIGN KEY (meeting_id) REFERENCES Meeting(id) ON DELETE CASCADE
);

-- Создание индексов для оптимизации запросов
CREATE INDEX idx_meeting_time ON Meeting(meeting_time);
CREATE INDEX idx_meeting_contact ON Meeting(contact_id);
CREATE INDEX idx_note_meeting ON Note(meeting_id);
```

## Примеры запросов

### 1. Предстоящие встречи на неделю

```sql
SELECT 
    m.meeting_time as "Дата и время",
    c.family_name as "Контакт",
    m.topic as "Тема",
    m.place as "Место"
FROM Meeting m
JOIN Contact c ON m.contact_id = c.id
WHERE m.meeting_time BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY m.meeting_time;
```

### 2. История встреч и заметок по контакту

```sql
-- Для контакта с ID = 1
SELECT 
    m.meeting_time as "Дата",
    'Встреча' as "Тип",
    m.topic as "Тема/Заметка",
    m.place as "Место",
    NULL as "Текст заметки"
FROM Meeting m
WHERE m.contact_id = 1

UNION ALL

SELECT 
    n.note_date as "Дата",
    'Заметка' as "Тип", 
    'Заметка к встрече: ' || m.topic as "Тема/Заметка",
    NULL as "Место",
    n.note_text as "Текст заметки"
FROM Note n
JOIN Meeting m ON n.meeting_id = m.id
WHERE m.contact_id = 1

ORDER BY "Дата" DESC;
```

### 3. Поиск контактов по месту работы

```sql
SELECT 
    family_name as "ФИО",
    work_place as "Место работы", 
    phone as "Телефон"
FROM Contact
WHERE work_place ILIKE '%компания%'
ORDER BY family_name;
```

## Эволюция проекта

### Ключевые решения и исправления

#### 1. Выбор первичных ключей
- **Было**: Использование телефонного номера и времени встречи как PK
- **Стало**: Введение суррогатных ключей `id SERIAL PRIMARY KEY`
- **Причина**: Обеспечение стабильности, неизменяемости и уникальности идентификаторов

#### 2. Нормализация структуры
- **Было**: Избыточная связь Note с Contact и Meeting
- **Стало**: Чистая иерархия Contact → Meeting → Note
- **Причина**: Устранение транзитивных зависимостей и избыточности данных

#### 3. Типы данных
- **Было**: `phone::Decimal(10)`
- **Стало**: `phone::VARCHAR(20)`
- **Причина**: Поддержка международных форматов номеров и специальных символов

### Проверка нормальных форм

| Нормальная форма | Состояние | Комментарий |
|------------------|-----------|-------------|
| 1NF | ✅ Выполнена | Все атрибуты атомарны |
| 2NF | ✅ Выполнена | Нет зависимостей от части ключа |
| 3NF | ✅ Выполнена | Нет транзитивных зависимостей |
| BCNF | ✅ Выполнена | Все детерминанты - потенциальные ключи |

### Преимущества финальной модели

1. **Гибкость**: Легко расширяется новыми полями и сущностями
2. **Производительность**: Оптимизированные индексы для частых запросов
3. **Целостность**: FOREIGN KEY constraints гарантируют согласованность данных
4. **Масштабируемость**: Четкая нормализованная структура
5. **Поддержка**: Удобство администрирования и разработки

---

*Проект разработан для PostgreSQL 12+. Последнее обновление: ${current_date}*

## Выполнение запросов вручную

>> Выдать список предстоящих встреч на неделю с указанием контактов и тем, отсортированный по дате и времени.

```sql
SELECT c.family_name AS "ФИО", c.work_place AS "Учреждение", c.phone AS "Тел.",
m.topic AS "Тема", m.place AS "Место", m.meeting_time
FROM eugeneai.meeting AS m
JOIN eugeneai.contact AS c ON c.id = m.contact_id 
WHERE m.meeting_time BETWEEN '2025-11-11 12:41:00' AND '2025-11-11 12:41:59'
ORDER BY m.meeting_time;
```

|ФИО	|Учреждение	|Тел.	|Тема	|Место	meeting_time|
|-----|-----------|-----|-----|-------------------|
|Sam Clinton	|МИТ	+1(234)5678900	|Подготовка научной статьи	|Washington DC, 1st str., 28-51	|2025-11-11 12:41:09.029324|
|Sam Clinton	|МИТ	+1(234)5678900	|Проведение экспериментов на животных	|Washington DC, 1st str., lab. 20	|2025-11-11 12:41:53.276792|

<img width="932" height="51" alt="image" src="https://github.com/user-attachments/assets/a22bf64d-f29f-4ac6-bc43-b871c7a8da75" />

**Запрос от Дипсик**

```sql
SELECT 
    m.meeting_time as "Дата и время",
    c.family_name as "Контакт",
    m.topic as "Тема",
    m.place as "Место"
FROM eugeneai.Meeting m
JOIN eugeneai.Contact c ON m.contact_id = c.id
WHERE m.meeting_time BETWEEN CURRENT_DATE - INTERVAL '7 days' AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY m.meeting_time;
```

```text
Дата и время	Контакт	Тема	Место
2025-11-11 12:41:09.029324	Sam Clinton	Подготовка научной статьи	Washington DC, 1st str., 28-51
2025-11-11 12:41:53.276792	Sam Clinton	Проведение экспериментов на животных	Washington DC, 1st str., lab. 20
2025-11-11 12:42:51.366582	John Lee	Продление контракта с НАСА	New-York, 30th ave., N 20-45
2025-11-11 12:43:41.886128	John Wang	Обсуждение результатов скдебного заседания от 2025-11-11	New-York, 30th ave., N 20-45
```

<img width="863" height="85" alt="image" src="https://github.com/user-attachments/assets/026bcd5c-4657-4909-a0e9-bf8e047f9911" />

### Vew для этого запроса 

```sql
-- Выдать список предстоящих встреч на неделю 
-- с указанием контактов и тем, отсортированный по дате и времени.
CREATE OR REPLACE VIEW two_weeks_meetings
AS
SELECT 
    m.meeting_time as "Дата и время",
    c.family_name as "Контакт",
    m.topic as "Тема",
    m.place as "Место"
FROM eugeneai.Meeting m
JOIN eugeneai.Contact c ON m.contact_id = c.id
WHERE m.meeting_time BETWEEN CURRENT_DATE - INTERVAL '7 days' AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY m.meeting_time;
```

**Проверка**

```sql
SELECT * FROM eugeneai.two_weeks_meetings
WHERE "Контакт" LIKE 'S%m%';
```

```text
Дата и время	Контакт	Тема	Место
2025-11-11 12:41:09.029324	Sam Clinton	Подготовка научной статьи	Washington DC, 1st str., 28-51
2025-11-11 12:41:53.276792	Sam Clinton	Проведение экспериментов на животных	Washington DC, 1st str., lab. 20
```

<img width="736" height="51" alt="image" src="https://github.com/user-attachments/assets/56231afa-a0c1-4fb6-935d-ea33d15600f9" />



Ссылка на чат: https://chat.deepseek.com/share/qsw0aj5ur8x724w3mk



