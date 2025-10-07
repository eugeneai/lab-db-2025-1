** Лабораторные работы по БД **

# Постановка задачи (вариант 65)

** Учет контактов и взаимодействий (личная CRM) **

*Сущности:* Контакты (ФИО, место работы, телефон), встречи (дата, тема, место), заметки (дата, текст заметки по контакту).

*Процессы:* Регистрируются все встречи и важные события, связанные с контактами.

*Выходные документы:*

  - Выдать список предстоящих встреч на неделю с указанием контактов и тем, отсортированный по дате и времени.
  - Для заданного контакта выдать историю всех встреч и заметок, отсортированную по дате.

# Лабораторная работа 1 (Проектирование логической и физической модели БД)





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
