**Лабораторные работы по БД**

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

Отличная работа! Модель в целом продумана и логична, но есть несколько важных замечаний и неточностей, которые стоит исправить для создания более качественной и надежной базы данных.

### Критические замечания и рекомендации

#### 1. Выбор первичного ключа для `Contact`
**Проблема:** Использование `phone` в качестве первичного ключа — это **плохая практика**.
*   **Неуникальность:** Человек может сменить номер телефона. Что тогда произойдет с историей встреч и заметок?
*   **Необязательность:** Не у всех контактов может быть телефон.
*   **Суррогатный vs. Естественный ключ:** Номер телефона — это "естественный" ключ, который может меняться. В реляционном моделировании почти всегда предпочтительнее использовать **суррогатный ключ** — искусственный, неизменяемый идентификатор.

**Исправление:**
```sql
-- Было: Contact(phone, family_name, work_place)
-- Стало:
Contact(
    contact_id SERIAL PRIMARY KEY, -- Суррогатный ключ
    family_name VARCHAR NOT NULL,
    work_place VARCHAR,
    phone VARCHAR(20) -- Тип изменен на VARCHAR
);
```

#### 2. Выбор первичного ключа для `Meeting`
**Проблема:** Использование `meeting_time` в качестве первичного ключа ненадежно.
*   **Неуникальность:** Возможны две встречи, начинающиеся в одну и ту же секунду.
*   **Изменяемость:** Время встречи может быть перенесено. Изменение первичного ключа — очень дорогая операция, которая затрагивает все внешние ключи.

**Исправление:**
```sql
-- Было: Meeting(contact_phone, meeting_time, topic, place)
-- Стало:
Meeting(
    meeting_id SERIAL PRIMARY KEY, -- Суррогатный ключ
    contact_id INTEGER NOT NULL REFERENCES Contact(contact_id),
    meeting_time TIMESTAMP NOT NULL,
    topic TEXT,
    place TEXT
);
```

#### 3. Структура и смысл таблицы `Note`
**Проблема:** Ваша модель предполагает, что заметка *обязательно* привязана и к контакту, и к встрече (`contact_phone, meeting_time`). Это слишком жесткое ограничение.
*   **Гибкость:** Часто нужно сделать заметку о контакте вообще, без привязки к конкретной встрече (например, "Любит классическую музыку").
*   **Смысл связи:** Связь N:M между `Contact` и `Meeting` через `Note` не имеет логического смысла. Заметка — это не связующая сущность, а самостоятельная, которая может относиться к контакту и/или к встрече.

**Исправление:** Сделаем `Note` независимой сущностью с двумя опциональными внешними ключами.
```sql
Note(
    note_id SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL REFERENCES Contact(contact_id), -- Заметка ВСЕГДА о контакте
    meeting_id INTEGER NULL REFERENCES Meeting(meeting_id), -- Но НЕ ВСЕГДА о встрече
    note_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Полезно для сортировки
);
```
*   **`contact_id` - `NOT NULL`:** Любая заметка должна быть о каком-то контакте.
*   **`meeting_id` - `NULL`:** Поле опциональное. Если заметка сделана во время/о встрече — заполняем. Если это общая заметка о контакте — оставляем `NULL`.

#### 4. Неточности в типах данных
*   **`phone::Decimal(10)`:** Номера телефонов — это не числа. В них могут быть плюсы, скобки, дефисы (например, `+7 (999) 123-45-67`). Лучший тип — `VARCHAR(20)`.
*   **`meeting_time::datetime`:** В PostgreSQL правильный тип — `TIMESTAMP` или `TIMESTAMPTZ` (если нужны часовые пояса).
*   **`note:text`:** Верно, но лучше использовать более описательное имя, например, `note_text`.

---

### Исправленная и улучшенная модель

#### Логическая модель
*   **`Contact`** (`contact_id`, family_name, work_place, phone)
*   **`Meeting`** (`meeting_id`, `contact_id`, meeting_time, topic, place)
*   **`Note`** (`note_id`, `contact_id`, `meeting_id`, note_text, created_at)

#### Физическая модель (DDL для PostgreSQL)
```sql
CREATE TABLE Contact (
    contact_id SERIAL PRIMARY KEY,
    family_name VARCHAR(100) NOT NULL,
    work_place VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE Meeting (
    meeting_id SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL REFERENCES Contact(contact_id) ON DELETE CASCADE,
    meeting_time TIMESTAMP NOT NULL,
    topic TEXT,
    place TEXT
);

CREATE TABLE Note (
    note_id SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL REFERENCES Contact(contact_id) ON DELETE CASCADE,
    meeting_id INTEGER NULL REFERENCES Meeting(meeting_id) ON DELETE SET NULL,
    note_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для ускорения часто используемых запросов
CREATE INDEX idx_meeting_time ON Meeting(meeting_time);
CREATE INDEX idx_note_contact_created ON Note(contact_id, created_at);
```

#### Проверка нормальных форм (для исправленной модели)
*   **1NF:** Соблюдена.
*   **2NF:** Соблюдена, так как все неключевые атрибуты полностью зависят от целого первичного ключа (суррогатного `id`).
*   **3NF/BCNF:** Соблюдена. Нет транзитивных зависимостей, и каждый детерминант является потенциальным ключом.

---

### Примеры запросов для "Выходных документов"

**1. Список предстоящих встреч на неделю:**
```sql
SELECT
    c.family_name,
    m.meeting_time,
    m.topic,
    m.place
FROM Meeting m
JOIN Contact c ON m.contact_id = c.contact_id
WHERE m.meeting_time >= CURRENT_DATE
  AND m.meeting_time < CURRENT_DATE + INTERVAL '7 days'
ORDER BY m.meeting_time;
```

**2. История встреч и заметок для заданного контакта:**
```sql
-- Используем UNION для объединения встреч и заметок в одну хронологическую ленту
(
    SELECT
        m.meeting_time AS event_date,
        'Meeting: ' || m.topic AS event_description,
        m.place AS details
    FROM Meeting m
    WHERE m.contact_id = 1 -- Подставьте нужный contact_id
)
UNION ALL
(
    SELECT
        n.created_at AS event_date,
        'Note: ' || LEFT(n.note_text, 50) AS event_description, -- Обрезаем текст для краткости
        NULL AS details
    FROM Note n
    WHERE n.contact_id = 1
)
ORDER BY event_date DESC;
```

**Итог:** После внесения этих правок ваша модель станет значительно более **гибкой, надежной и соответствующей стандартам реляционного проектирования**. Удачи в сдаче лабы

## Промпт 2

```text
Из-за существования двух видов заметок требуется теперь
(2. История встреч и заметок для заданного контакта:) делать union.
Не проще ли первую заметку сделать заметкой о контакте?
при этом не надо будет усложнять структуру.
```

**Отличное замечание! Вы абсолютно правы.**

Усложнение структуры и запросов `UNION` — это явный признак того, что модель можно упростить. Ваше предложение сделать все заметки "заметками о контакте" — это правильный и более чистый подход.

### Упрощенная модель

#### Логическая модель
*   **`Contact`** (`contact_id`, family_name, work_place, phone)
*   **`Meeting`** (`meeting_id`, `contact_id`, meeting_time, topic, place)
*   **`Note`** (`note_id`, `contact_id`, note_text, created_at)

#### Физическая модель (DDL)
```sql
CREATE TABLE Contact (
    contact_id SERIAL PRIMARY KEY,
    family_name VARCHAR(100) NOT NULL,
    work_place VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE Meeting (
    meeting_id SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL REFERENCES Contact(contact_id) ON DELETE CASCADE,
    meeting_time TIMESTAMP NOT NULL,
    topic TEXT,
    place TEXT
);

CREATE TABLE Note (
    note_id SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL REFERENCES Contact(contact_id) ON DELETE CASCADE,
    note_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы
CREATE INDEX idx_meeting_time ON Meeting(meeting_time);
CREATE INDEX idx_note_contact_created ON Note(contact_id, created_at);
```

### Преимущества упрощенной модели:

1. **Проще структура** - на одну таблицу и связь меньше
2. **Проще запросы** - не нужен `UNION`
3. **Более гибко** - можно делать заметки любого типа:
   - Общие заметки о контакте
   - Заметки о прошедших встречах (просто указываем в тексте "Встреча 15.05: обсудили проект X")
   - Заметки о планах на будущее

### Упрощенный запрос для истории:

```sql
-- История встреч и заметок для контакта
SELECT
    m.meeting_time AS event_date,
    'Meeting' AS event_type,
    'Тема: ' || m.topic AS event_description,
    m.place AS details
FROM Meeting m
WHERE m.contact_id = 1

UNION ALL

SELECT
    n.created_at AS event_date,
    'Note' AS event_type,
    n.note_text AS event_description,
    NULL AS details
FROM Note n
WHERE n.contact_id = 1

ORDER BY event_date DESC;
```

**Еще более простой вариант** (если не нужно разделять типы событий):
```sql
-- Просто все события в хронологическом порядке
SELECT created_at, note_text as event_text
FROM Note 
WHERE contact_id = 1
UNION ALL
SELECT meeting_time, topic as event_text  
FROM Meeting
WHERE contact_id = 1
ORDER BY created_at DESC;
```

### Когда стоит сохранить связь Note-Meeting?

Только если нужны **строгая привязка** и **автоматическая валидация**:
- Гарантия, что заметка относится к конкретной встрече
- Автоматическое удаление заметок при удалении встречи
- Сложные отчеты "заметки по встречам"

Но для личной CRM это избыточно. Ваше предложение проще и практичнее.

**Вывод:** Ваш подход лучше для данной задачи. Используйте упрощенную модель с заметками только о контактах.

## Полученные диаграммы:
### ER-диаграмма

```mermaid
erDiagram
    CONTACT ||--o{ MEETING : has
    CONTACT ||--o{ NOTE : has
    
    CONTACT {
        integer contact_id PK "SERIAL"
        varchar family_name
        varchar work_place
        varchar phone
    }
    
    MEETING {
        integer meeting_id PK "SERIAL"
        integer contact_id FK
        timestamp meeting_time
        text topic
        text place
    }
    
    NOTE {
        integer note_id PK "SERIAL"
        integer contact_id FK
        text note_text
        timestamp created_at
    }
```

## Логическая модель в виде Диаграммы классов UML-2.4

```mermaid
classDiagram
    class Contact {
        +contact_id: Integer (PK)
        +family_name: String
        +work_place: String
        +phone: String
        +getMeetings() List~Meeting~
        +getNotes() List~Note~
    }
    
    class Meeting {
        +meeting_id: Integer (PK)
        +contact_id: Integer (FK)
        +meeting_time: DateTime
        +topic: String
        +place: String
        +getContact() Contact
    }
    
    class Note {
        +note_id: Integer (PK)
        +contact_id: Integer (FK)
        +note_text: String
        +created_at: DateTime
        +getContact() Contact
    }
    
    Contact "1" -- "*" Meeting : имеет
    Contact "1" -- "*" Note : содержит
```

## Физическая модель БД

```mermaid
erDiagram
    contact {
        integer contact_id PK "SERIAL"
        varchar family_name "NOT NULL"
        varchar work_place
        varchar phone
    }
    
    meeting {
        integer meeting_id PK "SERIAL"
        integer contact_id FK "NOT NULL"
        timestamp meeting_time "NOT NULL"
        text topic
        text place
    }
    
    note {
        integer note_id PK "SERIAL"
        integer contact_id FK "NOT NULL"
        text note_text "NOT NULL"
        timestamp created_at "DEFAULT CURRENT_TIMESTAMP"
    }
    
    contact ||--o{ meeting : "FOREIGN KEY (contact_id) REFERENCES contact(contact_id)"
    contact ||--o{ note : "FOREIGN KEY (contact_id) REFERENCES contact(contact_id)"
```

## Заключение

В первой лаборной работе при помощи теоетического инстрментария проектирования БД и большой языковой модели "Дипсик" произведено проектирование ER-, логичсекой и физической модели (диаграмм) базы данных варианта 65. Основные замечания, решенные в ходе выполнения лабораторной работы:

  1. Реализовано две итерации консультации с БЯМ;
  2. БЯМ исправила три существенные ошибки проектирования (суррогатные индексы, перепроектирование ER, типы данных);
  3. Суррогатные ключи позволяют стабилизировать структуру данных в базе данных;
  4. Упрощена модель (уделен внешний ключ в Заметке).
  5. Телефон следует записывать в текстовом формате.



