-- Таблица: icon_types
-- Описание типов иконок
CREATE TABLE icon_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    system_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT icon_types_system_name_unique UNIQUE (system_name)
);

-- Начальное заполнение icon_types
INSERT INTO
    icon_types (
        id,
        name,
        system_name,
        created_at,
        updated_at
    )
VALUES (
        1,
        'По умолчанию',
        'DEFAULT',
        '2024-01-31 12:05:27+00',
        '2024-01-31 12:05:27+00'
    );

-- Таблица: icons
-- Описание иконок
CREATE TABLE icons (
    id BIGINT PRIMARY KEY,
    icon_type_id BIGINT NOT NULL,
    disk VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(255) NOT NULL,
    size INTEGER NOT NULL,
    path VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    FOREIGN KEY (icon_type_id) REFERENCES icon_types (id)
);

-- -- Начальное заполнение icons
-- INSERT INTO icons (id, icon_type_id, disk, original_name, mime_type, size, path, created_at, updated_at) VALUES
-- (1, 1, 'icon', 'ALIGN_LEFT.svg', 'image/svg+xml', 0, 'https://s3.baes.dev.internal.k8s.indev.by/icon/default/ALIGN_LEFT.svg', '2024-02-01 01:18:07+00', '2025-03-27 14:23:55+00');

-- Таблица: region_groups
-- Описание групп регионов
CREATE TABLE region_groups (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Начальное заполнение region_groups
INSERT INTO
    region_groups (id, name)
VALUES (1, 'Национальные объекты ОДД'),
    (2, 'Региональные объекты ОДД');

-- Таблица: region_types
-- Описание типов регионов
CREATE TABLE region_types (
    id BIGINT PRIMARY KEY,
    region_group_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    min_zoom INTEGER NOT NULL CHECK (min_zoom BETWEEN 4 AND 19),
    max_zoom INTEGER NOT NULL CHECK (max_zoom BETWEEN 4 AND 19),
    is_meta BOOLEAN NOT NULL,
    color VARCHAR(255) NOT NULL,
    icon_id BIGINT,
    is_target BOOLEAN NOT NULL,
    is_national BOOLEAN NOT NULL,
    is_ate_region BOOLEAN NOT NULL,
    is_ate_district BOOLEAN NOT NULL,
    is_ate_object BOOLEAN NOT NULL,
    is_structured BOOLEAN NOT NULL,
    FOREIGN KEY (region_group_id) REFERENCES region_groups (id),
    FOREIGN KEY (icon_id) REFERENCES icons (id)
);

-- Начальное заполнение region_types
INSERT INTO
    region_types (
        id,
        region_group_id,
        name,
        min_zoom,
        max_zoom,
        is_meta,
        color,
        icon_id,
        is_target,
        is_national,
        is_ate_region,
        is_ate_district,
        is_ate_object,
        is_structured
    )
VALUES (
        1,
        1,
        'Национальный объект',
        4,
        6,
        FALSE,
        '#000000',
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        2,
        2,
        'Регионы',
        7,
        8,
        FALSE,
        '#000000',
        NULL,
        TRUE,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        3,
        2,
        'Административные районы',
        9,
        10,
        FALSE,
        '#000000',
        NULL,
        TRUE,
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        FALSE
    ),
    (
        4,
        2,
        'Крупнейшие города-областные центры',
        10,
        12,
        FALSE,
        '#000000',
        NULL,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        TRUE,
        FALSE
    ),
    (
        5,
        2,
        'Города с населением более 50 тысяч',
        10,
        13,
        FALSE,
        '#000000',
        NULL,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        TRUE,
        FALSE
    ),
    (
        6,
        2,
        'Города',
        10,
        13,
        FALSE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        TRUE,
        FALSE
    ),
    (
        7,
        2,
        'Административные районы городов',
        13,
        14,
        FALSE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        TRUE,
        FALSE
    ),
    (
        8,
        2,
        'Города мета-анализа с высоким уровнем БДД',
        4,
        6,
        FALSE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        9,
        2,
        'Города мета-анализа со средним уровнем БДД',
        4,
        6,
        TRUE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        10,
        2,
        'Города мета-анализа с низким уровнем БДД',
        4,
        6,
        TRUE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        11,
        1,
        'Страны мета-анализа с высоким уровнем БДД',
        4,
        6,
        TRUE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        12,
        1,
        'Страны мета-анализа со средним уровнем БДД',
        4,
        6,
        TRUE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        13,
        1,
        'Страны мета-анализа с низким уровнем БДД',
        4,
        6,
        TRUE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE
    ),
    (
        14,
        2,
        'Структурный',
        4,
        6,
        TRUE,
        '#000000',
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        TRUE
    );

-- Таблица: regions
-- Описание регионов
CREATE TABLE regions (
    id BIGINT PRIMARY KEY,
    region_type_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    parent_id BIGINT,
    geom GEOGRAPHY,
    info_position GEOGRAPHY,
    icon_id BIGINT,
    FOREIGN KEY (region_type_id) REFERENCES region_types (id),
    FOREIGN KEY (parent_id) REFERENCES regions (id),
    FOREIGN KEY (icon_id) REFERENCES icons (id)
);

-- Таблица: region_attribute_types
-- Описание характеристик регионов
CREATE TABLE region_attribute_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(255),
    system_name VARCHAR(255),
    attribute_type VARCHAR(255) NOT NULL CHECK (
        attribute_type IN (
            'permanent',
            'temporary',
            'calculated'
        )
    ),
    is_diagram BOOLEAN NOT NULL,
    format_type JSONB NOT NULL,
    CONSTRAINT region_attribute_types_system_name_unique UNIQUE (system_name)
);

-- Начальное заполнение region_attribute_types
INSERT INTO
    region_attribute_types (
        id,
        name,
        unit,
        system_name,
        attribute_type,
        is_diagram,
        format_type
    )
VALUES (
        1,
        'Площадь',
        'км²',
        'AREA',
        'permanent',
        FALSE,
        '{}'
    ),
    (
        2,
        'Население',
        'чел',
        'POPULATION',
        'temporary',
        FALSE,
        '{}'
    ),
    (
        3,
        'Автомобилизация',
        NULL,
        'MOTORIZATION',
        'temporary',
        FALSE,
        '{}'
    ),
    (
        4,
        'Индекс человеческого развития',
        NULL,
        'HDI',
        'temporary',
        FALSE,
        '{}'
    ),
    (
        5,
        'ВВП',
        NULL,
        'GDP',
        'temporary',
        FALSE,
        '{}'
    ),
    (
        6,
        'ВВП ППС',
        NULL,
        'GDP_2',
        'temporary',
        FALSE,
        '{}'
    ),
    (
        7,
        'Социальный риск',
        NULL,
        'SOCIAL_RISK',
        'temporary',
        FALSE,
        '{}'
    ),
    (
        8,
        'Плотность населения',
        'чел/км²',
        'POPULATION_DENSITY',
        'calculated',
        TRUE,
        '{"formula": {"variables": [{"k": 1000}], "expression": "P*k/S", "attribute_types": [{"P": 2}, {"S": 1}]}}'
    ),
    (
        9,
        'Количество автомобилей',
        NULL,
        'CARS_QUANTITY',
        'calculated',
        TRUE,
        '{"formula": {"expression": "MOTORIZATION * POPULATION * 1000", "attribute_types": [{"MOTORIZATION": 3}, {"POPULATION": 2}]}}'
    ),
    (
        10,
        'Количество погибших',
        NULL,
        'DEATH_QUANTITY',
        'calculated',
        TRUE,
        '{"formula": {"expression": "SOCIAL_RISK * POPULATION", "attribute_types": [{"SOCIAL_RISK": 7}, {"POPULATION": 2}]}}'
    ),
    (
        11,
        'Степень упорядоченности',
        NULL,
        'ORDER_DEGREE',
        'calculated',
        TRUE,
        '{"formula": {"expression": "SOCIAL_RISK * POPULATION / (0.0003 * ((MOTORIZATION * 1000 * POPULATION)^0.33))", "attribute_types": [{"SOCIAL_RISK": 7}, {"POPULATION": 2}, {"MOTORIZATION": 3}]}}'
    ),
    (
        12,
        'Пробег',
        'км',
        'MILEAGE',
        'calculated',
        TRUE,
        '{"formula": {"expression": "MOTORIZATION * POPULATION * 1000 * 0.85 * 20000", "attribute_types": [{"MOTORIZATION": 3}, {"POPULATION": 2}]}}'
    ),
    (
        13,
        'Транспортный риск',
        NULL,
        'TRANSPORT_RISK',
        'calculated',
        TRUE,
        '{"formula": {"expression": "SOCIAL_RISK / (MOTORIZATION * 1000)", "attribute_types": [{"SOCIAL_RISK": 7}, {"MOTORIZATION": 3}]}}'
    ),
    (
        14,
        'Пробеговый риск',
        NULL,
        'MILEAGE_RISK',
        'calculated',
        TRUE,
        '{"formula": {"expression": "SOCIAL_RISK / (MOTORIZATION * 1000 * 0.85 * 20000)", "attribute_types": [{"SOCIAL_RISK": 7}, {"MOTORIZATION": 3}]}}'
    );

-- Таблица: region_attribute_type_region_type
-- Настройка использования характеристик для типов регионов
CREATE TABLE region_attribute_type_region_type (
    region_attribute_type_id BIGINT NOT NULL,
    region_type_id BIGINT NOT NULL,
    PRIMARY KEY (
        region_attribute_type_id,
        region_type_id
    ),
    FOREIGN KEY (region_attribute_type_id) REFERENCES region_attribute_types (id),
    FOREIGN KEY (region_type_id) REFERENCES region_types (id)
);

-- Таблица: region_attributes
-- Значения характеристик регионов
CREATE TABLE region_attributes (
    id BIGINT PRIMARY KEY,
    region_id BIGINT NOT NULL,
    region_attribute_type_id BIGINT NOT NULL,
    value VARCHAR(255) NOT NULL,
    year INTEGER,
    FOREIGN KEY (region_id) REFERENCES regions (id),
    FOREIGN KEY (region_attribute_type_id) REFERENCES region_attribute_types (id)
);

-- Таблица: ate_regions
-- Описание административно-территориальных единиц (регионы)
CREATE TABLE ate_regions (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    relevance BOOLEAN NOT NULL
);

-- Начальное заполнение ate_regions
INSERT INTO
    ate_regions (id, name, relevance)
VALUES (1, 'Брестская', TRUE),
    (2, 'Витебская', TRUE),
    (3, 'Гомельская', TRUE),
    (4, 'Гродненская', TRUE),
    (5, 'Минск', TRUE),
    (6, 'Минская', TRUE),
    (7, 'Могилевская', TRUE);

-- Таблица: ate_districts
-- Описание административно-территориальных единиц (районы)
CREATE TABLE ate_districts (
    id BIGINT PRIMARY KEY,
    ate_region_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    relevance BOOLEAN NOT NULL,
    FOREIGN KEY (ate_region_id) REFERENCES ate_regions (id)
);

-- Таблица: ate_categories
-- Описание категорий административно-территориальных единиц
CREATE TABLE ate_categories (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    shortname VARCHAR(255) NOT NULL,
    relevance BOOLEAN NOT NULL
);

-- Таблица: ate_objects
-- Описание объектов административно-территориальных единиц
CREATE TABLE ate_objects (
    id BIGINT PRIMARY KEY,
    ate_region_id BIGINT NOT NULL,
    ate_district_id BIGINT NOT NULL,
    ate_category_id BIGINT NOT NULL,
    ate_parent_id BIGINT NOT NULL,
    coato VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    relevance BOOLEAN NOT NULL,
    FOREIGN KEY (ate_region_id) REFERENCES ate_regions (id),
    FOREIGN KEY (ate_district_id) REFERENCES ate_districts (id),
    FOREIGN KEY (ate_category_id) REFERENCES ate_categories (id),
    FOREIGN KEY (ate_parent_id) REFERENCES ate_objects (id),
    CONSTRAINT ate_objects_coato_unique UNIQUE (coato)
);

-- Таблица: ate_object_region
-- Связь объектов АТЕ и регионов
CREATE TABLE ate_object_region (
    ate_object_id BIGINT NOT NULL,
    region_id BIGINT NOT NULL,
    PRIMARY KEY (ate_object_id, region_id),
    FOREIGN KEY (ate_object_id) REFERENCES ate_objects (id),
    FOREIGN KEY (region_id) REFERENCES regions (id),
    CONSTRAINT ate_object_region_region_id_unique UNIQUE (region_id)
);

-- Таблица: odd_groups
-- Описание групп локальных объектов ОДД
CREATE TABLE odd_groups (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL
);

-- Начальное заполнение odd_groups
INSERT INTO
    odd_groups (id, name, color)
VALUES (
        1,
        'Автомобильные дороги',
        'blue'
    ),
    (
        2,
        'Улицы населенных пунктов',
        'orange'
    ),
    (
        3,
        'Объекты тяготения',
        '#000000'
    ),
    (4, 'Маршруты', '#000000');

-- Таблица: odd_types
-- Описание типов локальных объектов ОДД
CREATE TABLE odd_types (
    id BIGINT PRIMARY KEY,
    odd_group_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL,
    zoom_width JSONB NOT NULL,
    short_name VARCHAR(255),
    accident_factor_id BIGINT,
    FOREIGN KEY (odd_group_id) REFERENCES odd_groups (id)
    -- FOREIGN KEY (accident_factor_id) REFERENCES accident_factors(id)
);

-- Начальное заполнение odd_types
INSERT INTO
    odd_types (
        id,
        odd_group_id,
        name,
        color,
        zoom_width,
        short_name,
        accident_factor_id
    )
VALUES (
        1,
        1,
        'Магистральные автомобильные дороги (номер с буквой М)',
        '#ba55d3',
        '{}',
        'М',
        2107
    ),
    (
        2,
        1,
        'Республиканские автомобильные дороги (номер с буквой Р)',
        '#6495ed',
        '{}',
        'Н',
        2108
    ),
    (
        3,
        1,
        'Местные автомобильные дороги (номер с буквой Н)',
        '#7b7676',
        '{}',
        'Р',
        2109
    ),
    (
        4,
        1,
        'Подъезды к республиканским автомобильным дорогам',
        '#000000',
        '{}',
        'П',
        2110
    ),
    (
        5,
        2,
        'Магистраль-артерия',
        '#fc0000',
        '{"10": {"lineWidth": 2}, "11": {"lineWidth": 3}, "12": {"lineWidth": 4}, "13": {"lineWidth": 5}, "14": {"lineWidth": 6}, "15": {"lineWidth": 7}, "16": {"lineWidth": 8}, "17": {"lineWidth": 10}, "18": {"lineWidth": 12}, "19": {"lineWidth": 15}}',
        NULL,
        NULL
    ),
    (
        6,
        2,
        'Магистраль',
        '#ff8a00',
        '{}',
        NULL,
        NULL
    ),
    (
        7,
        2,
        'Улица-коллектор',
        '#ffc804',
        '{}',
        NULL,
        NULL
    ),
    (
        8,
        2,
        'Жилая улица',
        '#f3f704',
        '{}',
        NULL,
        NULL
    ),
    (
        9,
        2,
        'Проезд',
        '#bfbfbf',
        '{}',
        NULL,
        NULL
    ),
    (
        10,
        3,
        'Городская площадь, пешеходная зона',
        '#40e0d0',
        '{}',
        NULL,
        NULL
    ),
    (
        11,
        3,
        'Учреждение образования',
        '#008080',
        '{}',
        NULL,
        NULL
    ),
    (
        12,
        3,
        'Торговый центр, рынок',
        '#8b0000',
        '{}',
        NULL,
        NULL
    ),
    (
        13,
        3,
        'Вокзал',
        '#00008b',
        '{}',
        NULL,
        NULL
    ),
    (
        14,
        3,
        'Транспортный пересадочный узел',
        '#4169e1',
        '{}',
        NULL,
        NULL
    ),
    (
        15,
        3,
        'Объект социальной сферы',
        '#fa8072',
        '{}',
        NULL,
        NULL
    ),
    (
        16,
        3,
        'Жилая зона высокой плотности',
        '#ffa500',
        '{}',
        NULL,
        NULL
    ),
    (
        17,
        3,
        'Жилая зона низкой плотности',
        '#f0e68c',
        '{}',
        NULL,
        NULL
    ),
    (
        18,
        3,
        'Рекреационная зона',
        '#3cb371',
        '{}',
        NULL,
        NULL
    ),
    (
        19,
        3,
        'Торговая зона',
        '#b22222',
        '{}',
        NULL,
        NULL
    ),
    (
        20,
        3,
        'Промышленная зона',
        '#ba55d3',
        '{}',
        NULL,
        NULL
    ),
    (
        21,
        3,
        'Деловая зона',
        '#6495ed',
        '{}',
        NULL,
        NULL
    ),
    (
        22,
        3,
        'Объект автосервиса',
        '#4b0082',
        '{}',
        NULL,
        NULL
    );

-- Таблица: odds
-- Локальные объекты ОДД
CREATE TABLE odds (
    id BIGINT PRIMARY KEY,
    odd_type_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    geom GEOGRAPHY,
    odd_owner_id BIGINT,
    odd_operator_id BIGINT,
    osm_ref VARCHAR(255),
    FOREIGN KEY (odd_type_id) REFERENCES odd_types (id)
    -- FOREIGN KEY (odd_owner_id) REFERENCES odd_owners(id),
    -- FOREIGN KEY (odd_operator_id) REFERENCES odd_operators(id)
);

-- Таблица: odd_attribute_types
-- Описание характеристик локальных объектов ОДД
CREATE TABLE odd_attribute_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    system_name VARCHAR(255),
    unit VARCHAR(255),
    date_const BOOLEAN NOT NULL,
    format_type JSONB NOT NULL
    -- CONSTRAINT odd_attribute_types_system_name_unique UNIQUE (system_name)
);

-- Начальное заполнение odd_attribute_types
INSERT INTO
    odd_attribute_types (
        id,
        name,
        unit,
        system_name,
        date_const,
        format_type
    )
VALUES (
        1,
        'Длина',
        'км',
        'LENGTH',
        TRUE,
        '{"real": {"max": 1000, "min": 0, "accuracy": 3}}'
    ),
    (
        2,
        'Основная техническая категория',
        NULL,
        'ROAD_CATEGORY',
        TRUE,
        '{"string": {"max": 3, "min": 1}}'
    ),
    (
        3,
        'Основная категория (СН 3.03.2022)',
        NULL,
        'STREET_CATEGORY',
        TRUE,
        '{"string": {"max": 2, "min": 1}}'
    ),
    (
        4,
        'Основной статус мобильности',
        NULL,
        'MOBILITY_STATUS',
        TRUE,
        '{"integer": {"max": 5, "min": 1}}'
    ),
    (
        5,
        'Основной статус тяготения',
        NULL,
        'GRAVITY_STATUS',
        TRUE,
        '{"integer": {"max": 3, "min": 1}}'
    ),
    (
        102,
        'Мощность',
        'пеш/сутки',
        'POWER',
        FALSE,
        '{"integer": {"max": 100, "min": 0}}'
    ),
    (
        103,
        'Тяготение',
        'чел',
        'GRAVITY',
        FALSE,
        '{"integer": {"max": 1000, "min": 0}}'
    ),
    (
        104,
        'Мощность',
        'кол-во уч.',
        'POWER',
        FALSE,
        '{"integer": {"max": 100, "min": 0}}'
    ),
    (
        105,
        'Мощность',
        'пасс/сутки',
        'POWER',
        FALSE,
        '{"integer": {"max": 100, "min": 0}}'
    ),
    (
        106,
        'Мощность',
        'работающих',
        'POWER',
        FALSE,
        '{"integer": {"max": 100, "min": 0}}'
    ),
    (
        107,
        'Мощность',
        'пос/сутки',
        'POWER',
        FALSE,
        '{"integer": {"max": 100, "min": 0}}'
    ),
    (
        108,
        'Контактные данные',
        NULL,
        'CONTACTS',
        FALSE,
        '{"json": {}}'
    ),
    (
        109,
        'Руководство',
        NULL,
        'BOSSES',
        FALSE,
        '{"json": {}}'
    ),
    (
        110,
        'График работы',
        NULL,
        'WORK_SCHEDULE',
        FALSE,
        '{"json": {}}'
    );

-- Таблица: odd_attribute_type_odd_type
-- Настройка использования характеристик для типов локальных объектов ОДД
CREATE TABLE odd_attribute_type_odd_type (
    odd_attribute_type_id BIGINT NOT NULL,
    odd_type_id BIGINT NOT NULL,
    PRIMARY KEY (
        odd_attribute_type_id,
        odd_type_id
    ),
    FOREIGN KEY (odd_attribute_type_id) REFERENCES odd_attribute_types (id),
    FOREIGN KEY (odd_type_id) REFERENCES odd_types (id)
);

-- Таблица: odd_attributes
-- Значения характеристик локальных объектов ОДД
CREATE TABLE odd_attributes (
    id BIGINT PRIMARY KEY,
    odd_id BIGINT NOT NULL,
    odd_attribute_type_id BIGINT NOT NULL,
    value INTEGER NOT NULL,
    FOREIGN KEY (odd_id) REFERENCES odds (id),
    FOREIGN KEY (odd_attribute_type_id) REFERENCES odd_attribute_types (id)
);

-- Таблица: odd_owners
-- Описание владельцев локальных объектов ОДД
CREATE TABLE odd_owners (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица: odd_operators
-- Описание операторов локальных объектов ОДД
CREATE TABLE odd_operators (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица: odd_region
-- Связь локальных объектов ОДД и региональных объектов ОДД
CREATE TABLE odd_region (
    odd_id BIGINT NOT NULL,
    region_id BIGINT NOT NULL,
    PRIMARY KEY (odd_id, region_id),
    FOREIGN KEY (odd_id) REFERENCES odds (id),
    FOREIGN KEY (region_id) REFERENCES regions (id),
    CONSTRAINT odd_region_odd_id_unique UNIQUE (odd_id)
);

-- Таблица: odd_rd_road
-- Связь объектов автомобильных дорог
CREATE TABLE odd_rd_road (
    odd_id BIGINT NOT NULL,
    rd_road_id BIGINT NOT NULL,
    PRIMARY KEY (odd_id, rd_road_id),
    FOREIGN KEY (odd_id) REFERENCES odds (id)
    -- FOREIGN KEY (rd_road_id) REFERENCES rd_roads(id),
    -- CONSTRAINT odd_rd_road_odd_id_unique UNIQUE (odd_id)
    -- CONSTRAINT odd_rd_road_rd_road_id_unique UNIQUE (rd_road_id)
);

-- Таблица: rd_roads
-- Описание дорог
CREATE TABLE rd_roads (
    id BIGINT PRIMARY KEY,
    number VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    type SMALLINT NOT NULL CHECK (type IN (1, 2, 3)),
    registration_date TIMESTAMP WITHOUT TIME ZONE,
    cancellation_date TIMESTAMP WITHOUT TIME ZONE
);

-- Таблица: rd_organisation_info
-- Информация о дорожных организациях
CREATE TABLE rd_organisation_info (
    id BIGINT PRIMARY KEY,
    ate_region_id BIGINT NOT NULL,
    ate_district_id BIGINT,
    ate_object_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    short_name VARCHAR(255) NOT NULL,
    relevance BOOLEAN NOT NULL,
    FOREIGN KEY (ate_region_id) REFERENCES ate_regions (id),
    FOREIGN KEY (ate_district_id) REFERENCES ate_districts (id),
    FOREIGN KEY (ate_object_id) REFERENCES ate_objects (id)
);

-- Таблица: rd_road_ates
-- Описание границ территориальных единиц на участках дороги
CREATE TABLE rd_road_ates (
    id BIGINT PRIMARY KEY,
    rd_road_id BIGINT NOT NULL,
    begin NUMERIC(10, 3) NOT NULL,
    segment_end NUMERIC(10, 3) NOT NULL,
    ate_region_id BIGINT NOT NULL,
    ate_object_id BIGINT NOT NULL,
    registration_date TIMESTAMP WITHOUT TIME ZONE,
    cancellation_date TIMESTAMP WITHOUT TIME ZONE,
    FOREIGN KEY (rd_road_id) REFERENCES rd_roads (id),
    FOREIGN KEY (ate_region_id) REFERENCES ate_regions (id),
    FOREIGN KEY (ate_object_id) REFERENCES ate_objects (id)
);

-- Таблица: odd_categories
-- Описание технических категорий автомобильных дорог
CREATE TABLE odd_categories (
    id BIGINT PRIMARY KEY,
    odd_group_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    color VARCHAR(255) NOT NULL,
    zoom_width JSONB NOT NULL,
    accident_factor_id BIGINT,
    FOREIGN KEY (odd_group_id) REFERENCES odd_groups (id)
    -- FOREIGN KEY (accident_factor_id) REFERENCES accident_factors(id)
);

-- Начальное заполнение odd_categories
INSERT INTO
    odd_categories (
        id,
        odd_group_id,
        name,
        description,
        color,
        zoom_width,
        accident_factor_id
    )
VALUES (
        1,
        1,
        'I-а',
        NULL,
        '#a52a2a',
        '{"10": {"lineWidth": 2}, "11": {"lineWidth": 3}, "12": {"lineWidth": 4}, "13": {"lineWidth": 5}, "14": {"lineWidth": 6}, "15": {"lineWidth": 7}, "16": {"lineWidth": 8}, "17": {"lineWidth": 10}, "18": {"lineWidth": 12}, "19": {"lineWidth": 15}}',
        60201
    ),
    (
        2,
        1,
        'I-б',
        NULL,
        '#ff0000',
        '{}',
        60202
    ),
    (
        3,
        1,
        'I-в',
        NULL,
        '#ffa500',
        '{}',
        60203
    ),
    (
        4,
        1,
        'II',
        NULL,
        '#bba400',
        '{}',
        60204
    ),
    (
        5,
        1,
        'III',
        NULL,
        '#889300',
        '{}',
        60205
    ),
    (
        6,
        1,
        'IV',
        NULL,
        '#448200',
        '{}',
        60206
    ),
    (
        7,
        1,
        'V',
        NULL,
        '#008000',
        '{}',
        60207
    );

-- Таблица: rd_segments
-- Описание участков автомобильных дорог
CREATE TABLE rd_segments (
    id BIGINT PRIMARY KEY,
    rd_road_id BIGINT NOT NULL,
    odd_category_id INTEGER NOT NULL,
    region_id BIGINT NOT NULL,
    distance_from NUMERIC(10, 3) NOT NULL,
    distance_to NUMERIC(10, 3) NOT NULL,
    mobility SMALLINT NOT NULL CHECK (mobility IN (1, 2, 3, 4, 5)),
    req_level SMALLINT NOT NULL CHECK (req_level IN (1, 2, 3, 4, 5)),
    geom GEOGRAPHY,
    FOREIGN KEY (rd_road_id) REFERENCES rd_roads (id),
    FOREIGN KEY (odd_category_id) REFERENCES odd_categories (id),
    FOREIGN KEY (region_id) REFERENCES regions (id)
);

-- Таблица: rd_segment_organisations
-- Описание организаций на участках дорог
CREATE TABLE rd_segment_organisations (
    id BIGINT PRIMARY KEY,
    rd_segment_id BIGINT NOT NULL,
    rd_organisation_info_id BIGINT NOT NULL,
    type SMALLINT CHECK (type IN (1, 2, 3)),
    FOREIGN KEY (rd_segment_id) REFERENCES rd_segments (id),
    FOREIGN KEY (rd_organisation_info_id) REFERENCES rd_organisation_info (id)
);

-- Таблица: odd_eva_objects
-- Связь объектов улиц населенных пунктов
CREATE TABLE odd_eva_objects (
    odd_id BIGINT NOT NULL,
    eva_object_id BIGINT NOT NULL,
    PRIMARY KEY (odd_id, eva_object_id),
    FOREIGN KEY (odd_id) REFERENCES odds (id)
    -- FOREIGN KEY (eva_object_id) REFERENCES eva_objects(id),
    -- CONSTRAINT odd_eva_object_odd_id_unique UNIQUE (odd_id)
    -- CONSTRAINT odd_eva_object_eva_object_id_unique UNIQUE (eva_object_id)
);

-- Таблица: eva_objects
-- Элементы внутренних адресов
CREATE TABLE eva_objects (
    id BIGINT PRIMARY KEY,
    ate_object_id BIGINT NOT NULL,
    eva_object_type_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    relevance BOOLEAN NOT NULL,
    registration_date TIMESTAMP WITHOUT TIME ZONE,
    cancellation_date TIMESTAMP WITHOUT TIME ZONE,
    FOREIGN KEY (ate_object_id) REFERENCES ate_objects (id)
    -- FOREIGN KEY (eva_object_type_id) REFERENCES eva_object_types(id)
);

-- Таблица: eva_object_types
-- Типы элементов внутренних адресов
CREATE TABLE eva_object_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(255) NOT NULL,
    relevance BOOLEAN NOT NULL
);

-- Таблица: adr_objects
-- Описание координатных объектов
CREATE TABLE adr_objects (
    id BIGINT PRIMARY KEY,
    ate_object_id BIGINT NOT NULL,
    geom GEOGRAPHY NOT NULL,
    type INTEGER,
    relevance BOOLEAN NOT NULL,
    FOREIGN KEY (ate_object_id) REFERENCES ate_objects (id)
);

-- Таблица: adr_internal_objects
-- Описание внутренних объектов
CREATE TABLE adr_internal_objects (
    id BIGINT PRIMARY KEY,
    eva_object_id BIGINT NOT NULL,
    distance NUMERIC(10, 3),
    house_number INTEGER,
    house_index VARCHAR(255),
    corpus_number INTEGER,
    relevance BOOLEAN NOT NULL,
    FOREIGN KEY (eva_object_id) REFERENCES eva_objects (id)
);

-- Таблица: adr_object_adr_internal_object
-- Связь координатных и внутренних объектов
CREATE TABLE adr_object_adr_internal_object (
    adr_object_id BIGINT NOT NULL,
    adr_internal_object_id BIGINT NOT NULL,
    PRIMARY KEY (
        adr_object_id,
        adr_internal_object_id
    ),
    FOREIGN KEY (adr_object_id) REFERENCES adr_objects (id),
    FOREIGN KEY (adr_internal_object_id) REFERENCES adr_internal_objects (id)
);

-- Таблица: net_types
-- Описание типов сетей
CREATE TABLE net_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    system_name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL,
    CONSTRAINT net_types_system_name_unique UNIQUE (system_name)
);

-- Начальное заполнение net_types
INSERT INTO
    net_types (id, name, system_name, color)
VALUES (
        1,
        'Транспортная система',
        'TRANSPORT',
        '#000000'
    ),
    (
        2,
        'Пешеходная сеть',
        'PEDESTRIAN',
        '#000000'
    ),
    (
        3,
        'Велосипедная сеть',
        'BICYCLE',
        '#000000'
    ),
    (
        4,
        'ГОПТ (ОТ)',
        'PUBLIC_TRANSPORT',
        '#000000'
    );

-- Таблица: node_types
-- Описание типов узлов
CREATE TABLE node_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    icon_id BIGINT,
    min_zoom INTEGER NOT NULL CHECK (min_zoom BETWEEN 4 AND 20),
    max_zoom INTEGER NOT NULL CHECK (max_zoom BETWEEN 4 AND 20),
    zoom_width JSONB NOT NULL,
    FOREIGN KEY (icon_id) REFERENCES icons (id)
);

-- Начальное заполнение node_types
INSERT INTO
    node_types (
        id,
        name,
        min_zoom,
        max_zoom,
        zoom_width,
        icon_id
    )
VALUES (
        1,
        'Мост',
        13,
        20,
        '{"13": {"variant": "point", "nodeSize": 8}, "14": {"variant": "point", "nodeSize": 10}, "15": {"variant": "point", "nodeSize": 12}, "16": {"variant": "icon", "nodeSize": 15}, "17": {"variant": "icon", "nodeSize": 20}, "18": {"variant": "icon", "nodeSize": 25}, "19": {"variant": "icon", "nodeSize": 30}}',
        NULL
    ),
    (
        2,
        'Тоннель',
        13,
        20,
        '{}',
        NULL
    ),
    (
        3,
        'Путепровод',
        13,
        20,
        '{}',
        NULL
    ),
    (
        4,
        'Пересечение в разных уровнях',
        13,
        20,
        '{}',
        NULL
    ),
    (
        5,
        'Примыкание к магистрали',
        13,
        20,
        '{}',
        NULL
    ),
    (
        6,
        'Отклонение с магистрали',
        13,
        20,
        '{}',
        NULL
    ),
    (
        7,
        'Переплетение съездов',
        13,
        20,
        '{}',
        NULL
    ),
    (
        8,
        'Пересечение каноническое',
        13,
        20,
        '{}',
        NULL
    ),
    (
        9,
        'Пересечение сложное',
        13,
        20,
        '{}',
        NULL
    ),
    (
        10,
        'Кольцевое пересечение',
        13,
        20,
        '{}',
        NULL
    ),
    (
        11,
        'Миникольцо',
        13,
        20,
        '{}',
        NULL
    ),
    (
        12,
        'Разрезанное кольцо',
        13,
        20,
        '{}',
        NULL
    ),
    (
        13,
        'ЖД переезд',
        13,
        20,
        '{}',
        NULL
    ),
    (
        14,
        'Пересечение с МПТ',
        13,
        20,
        '{}',
        NULL
    ),
    (
        15,
        'Пешеходный переход',
        13,
        20,
        '{}',
        NULL
    ),
    (
        16,
        'Велопереезд',
        13,
        20,
        '{}',
        NULL
    ),
    (
        17,
        'Точка',
        13,
        20,
        '{}',
        NULL
    );

-- Таблица: net_type_node_type
-- Настройка использования типов узлов в сетях
CREATE TABLE net_type_node_type (
    node_type_id BIGINT NOT NULL,
    net_type_id BIGINT NOT NULL,
    PRIMARY KEY (node_type_id, net_type_id),
    FOREIGN KEY (node_type_id) REFERENCES node_types (id),
    FOREIGN KEY (net_type_id) REFERENCES net_types (id)
);

-- Таблица: node_regulation_types
-- Описание типов регулирования узлов
CREATE TABLE node_regulation_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(255),
    icon_id BIGINT,
    FOREIGN KEY (icon_id) REFERENCES icons (id)
);

-- Начальное заполнение node_regulation_types
INSERT INTO
    node_regulation_types (id, name, short_name, icon_id)
VALUES (
        1,
        'нерегулируемый',
        'НР',
        NULL
    ),
    (
        2,
        'локальное регулирование',
        'ЛР',
        NULL
    ),
    (
        3,
        'локальное гибкое регулирование',
        'ЛГР',
        NULL
    ),
    (
        4,
        'системное регулирование',
        'АСУД',
        NULL
    ),
    (5, 'приоритет', NULL, NULL),
    (
        6,
        'системное регулирование',
        'АСУД',
        NULL
    ),
    (
        7,
        'по расписанию',
        'РАСП',
        NULL
    );

-- Таблица: net_type_node_regulation_type
-- Настройка использования типов регулирования узлов в сетях
CREATE TABLE net_type_node_regulation_type (
    node_regulation_type_id BIGINT NOT NULL,
    net_type_id BIGINT NOT NULL,
    PRIMARY KEY (
        node_regulation_type_id,
        net_type_id
    ),
    FOREIGN KEY (node_regulation_type_id) REFERENCES node_regulation_types (id),
    FOREIGN KEY (net_type_id) REFERENCES net_types (id)
);

-- Таблица: nodes
-- Описание узлов УДС
CREATE TABLE nodes (
    id BIGINT PRIMARY KEY,
    net_type_id BIGINT NOT NULL,
    node_type_id BIGINT NOT NULL,
    node_regulation_type_id BIGINT NOT NULL,
    region_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    geom GEOGRAPHY NOT NULL,
    zone_geom GEOGRAPHY,
    osm_codes VARCHAR(255),
    FOREIGN KEY (net_type_id) REFERENCES net_types (id),
    FOREIGN KEY (node_type_id) REFERENCES node_types (id),
    FOREIGN KEY (node_regulation_type_id) REFERENCES node_regulation_types (id),
    FOREIGN KEY (region_id) REFERENCES regions (id)
);

-- Таблица: node_geometry_types
-- Описание типов геометрий узла
CREATE TABLE node_geometry_types (
    id BIGINT PRIMARY KEY,
    net_type_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    system_name VARCHAR(255) NOT NULL,
    direction VARCHAR(255) NOT NULL CHECK (direction IN ('ac', 'abcd')),
    CONSTRAINT node_geometry_types_system_name_unique UNIQUE (system_name),
    FOREIGN KEY (net_type_id) REFERENCES net_types (id)
);

-- Начальное заполнение node_geometry_types
INSERT INTO
    node_geometry_types (
        id,
        net_type_id,
        name,
        system_name,
        direction
    )
VALUES (1, 1, 'Мост', 'Bridge', 'ac'),
    (
        2,
        1,
        'Тоннель',
        'Tunnel',
        'ac'
    ),
    (
        3,
        1,
        'Путепровод',
        'Overpass',
        'abcd'
    ),
    (
        4,
        1,
        'Пересечение в разных уровнях',
        'Bridge-Intersection',
        'abcd'
    ),
    (
        5,
        1,
        'Примыкание',
        'Adjacency',
        'ac'
    ),
    (
        6,
        1,
        'Отклонение',
        'Deviation',
        'ac'
    ),
    (
        7,
        1,
        'Переплетение',
        'Interlacing',
        'ac'
    ),
    (
        8,
        1,
        'Пересечение',
        'Cross_Intersection',
        'abcd'
    ),
    (
        9,
        1,
        'Переход',
        'Crosswalk',
        'abcd'
    ),
    (
        10,
        1,
        'Переезд',
        'Crossing',
        'abcd'
    ),
    (
        11,
        1,
        'Кольцевые пересечения',
        'Roundabout',
        'abcd'
    );

-- Таблица: node_geometry_attribute_types
-- Описание типов характеристик геометрий узла
CREATE TABLE node_geometry_attribute_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(255) NOT NULL,
    system_name VARCHAR(255),
    format_type JSONB NOT NULL,
    color VARCHAR(255) NOT NULL,
    CONSTRAINT node_geometry_attribute_types_system_name_unique UNIQUE (system_name)
);

-- Таблица: node_geometry_attribute_type_node_geometry_type
-- Настройка использования типов характеристик в геометриях узла
CREATE TABLE node_geometry_attribute_type_node_geometry_type (
    node_geometry_type_id BIGINT NOT NULL,
    node_geometry_attribute_type_id BIGINT NOT NULL,
    PRIMARY KEY (
        node_geometry_type_id,
        node_geometry_attribute_type_id
    ),
    FOREIGN KEY (node_geometry_type_id) REFERENCES node_geometry_types (id),
    FOREIGN KEY (
        node_geometry_attribute_type_id
    ) REFERENCES node_geometry_attribute_types (id)
);

-- Таблица: node_geometry_type_node_type
-- Настройка использования типа геометрии узла в типе узла УДС
CREATE TABLE node_geometry_type_node_type (
    node_type_id BIGINT NOT NULL,
    node_geometry_type_id BIGINT NOT NULL,
    PRIMARY KEY (
        node_type_id,
        node_geometry_type_id
    ),
    FOREIGN KEY (node_type_id) REFERENCES node_types (id),
    FOREIGN KEY (node_geometry_type_id) REFERENCES node_geometry_types (id)
);

-- Таблица: node_geometries
-- Значения характеристик геометрии узла
CREATE TABLE node_geometries (
    id BIGINT PRIMARY KEY,
    node_id BIGINT NOT NULL,
    node_geometry_attribute_type_id BIGINT NOT NULL,
    direction VARCHAR(255) NOT NULL CHECK (
        direction IN ('a', 'b', 'c', 'd')
    ),
    value VARCHAR(255) NOT NULL,
    FOREIGN KEY (node_id) REFERENCES nodes (id),
    FOREIGN KEY (
        node_geometry_attribute_type_id
    ) REFERENCES node_geometry_attribute_types (id),
    CONSTRAINT node_geometries_unique UNIQUE (
        direction,
        node_geometry_attribute_type_id,
        node_id
    )
);

-- Таблица: node_geometry_dimensions
-- Описание стандартных значений габаритов
CREATE TABLE node_geometry_dimensions (
    odd_type1_id BIGINT NOT NULL,
    odd_type2_id BIGINT NOT NULL,
    value1 NUMERIC(3, 1),
    value2 NUMERIC(3, 1),
    PRIMARY KEY (odd_type1_id, odd_type2_id),
    FOREIGN KEY (odd_type1_id) REFERENCES odd_types (id),
    FOREIGN KEY (odd_type2_id) REFERENCES odd_types (id)
);

-- Начальное заполнение node_geometry_dimensions для улиц
INSERT INTO
    node_geometry_dimensions (
        odd_type1_id,
        odd_type2_id,
        value1,
        value2
    )
VALUES (4, 4, 40, 40),
    (4, 5, 30, 40),
    (4, 6, 25, 40),
    (4, 7, 15, 40),
    (4, 8, 10, 40),
    (5, 4, 40, 30),
    (5, 5, 30, 30),
    (5, 6, 25, 30),
    (5, 7, 15, 30),
    (5, 8, 10, 30),
    (6, 4, 40, 25),
    (6, 5, 30, 25),
    (6, 6, 25, 25),
    (6, 7, 15, 25),
    (6, 8, 10, 25),
    (7, 4, 40, 15),
    (7, 5, 30, 15),
    (7, 6, 25, 15),
    (7, 7, 15, 15),
    (7, 8, 10, 15),
    (8, 4, 40, 10),
    (8, 5, 30, 10),
    (8, 6, 25, 10),
    (8, 7, 15, 10),
    (8, 8, 10, 10);

-- Начальное заполнение node_geometry_dimensions для автомобильных дорог
INSERT INTO
    node_geometry_dimensions (
        odd_type1_id,
        odd_type2_id,
        value1,
        value2
    )
VALUES (1, 1, 60, 60),
    (1, 2, 40, 60),
    (1, 3, 30, 60),
    (2, 1, 60, 40),
    (2, 2, 40, 40),
    (2, 3, 30, 40),
    (3, 1, 60, 30),
    (3, 2, 40, 30),
    (3, 3, 30, 30);

-- Таблица: node_geometry_attributes
-- Описание стандартных значений характеристик геометрии узла
CREATE TABLE node_geometry_attributes (
    id BIGINT PRIMARY KEY,
    link_type_id BIGINT NOT NULL,
    node_geometry_attribute_type_id BIGINT NOT NULL,
    value NUMERIC(3, 1),
    FOREIGN KEY (link_type_id) REFERENCES link_types (id),
    FOREIGN KEY (
        node_geometry_attribute_type_id
    ) REFERENCES node_geometry_attribute_types (id),
    CONSTRAINT node_geometry_attribute_unique UNIQUE (
        node_geometry_attribute_type_id,
        link_type_id
    )
);

-- Таблица: link_types
-- Описание типов связей
CREATE TABLE link_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL,
    zoom_width JSONB NOT NULL,
    mobility INTEGER NOT NULL CHECK (mobility IN (1, 2, 3, 4, 5))
);

-- Таблица: links
-- Связи УДС
CREATE TABLE links (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255),
    net_type_id BIGINT NOT NULL,
    link_type_id BIGINT NOT NULL,
    node_a_id BIGINT NOT NULL,
    node_a_direction VARCHAR(255) CHECK (
        node_a_direction IN (
            'a',
            'b',
            'c',
            'd',
            'ta',
            'tb',
            'tc',
            'td'
        )
    ),
    node_c_id BIGINT NOT NULL,
    node_c_direction VARCHAR(255) CHECK (
        node_c_direction IN (
            'a',
            'b',
            'c',
            'd',
            'ta',
            'tb',
            'tc',
            'td'
        )
    ),
    geom GEOGRAPHY,
    gravity INTEGER NOT NULL CHECK (gravity IN (1, 2, 3)),
    one_way_traffic BOOLEAN NOT NULL,
    osm_ref VARCHAR(255),
    node_a_distance NUMERIC(5, 2),
    node_c_distance NUMERIC(5, 2),
    zone_geom GEOGRAPHY,
    FOREIGN KEY (net_type_id) REFERENCES net_types (id),
    FOREIGN KEY (link_type_id) REFERENCES link_types (id),
    FOREIGN KEY (node_a_id) REFERENCES nodes (id),
    FOREIGN KEY (node_c_id) REFERENCES nodes (id),
    CONSTRAINT links_node_a_unique UNIQUE (node_a_id, node_a_direction),
    CONSTRAINT links_node_c_unique UNIQUE (node_c_id, node_c_direction)
);

-- Таблица: link_odd
-- Связь УДС и объектов тяготения
CREATE TABLE link_odd (
    link_id BIGINT NOT NULL,
    odd_id BIGINT NOT NULL,
    PRIMARY KEY (link_id, odd_id),
    FOREIGN KEY (link_id) REFERENCES links (id),
    FOREIGN KEY (odd_id) REFERENCES odds (id)
);

-- Таблица: link_conflict_types
-- Описание типов элементов ОДД на связи УДС
CREATE TABLE link_conflict_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    icon_id BIGINT,
    color VARCHAR(255),
    FOREIGN KEY (icon_id) REFERENCES icons (id)
);

-- Начальное заполнение link_conflict_types
INSERT INTO
    link_conflict_types (id, name, icon_id, color)
VALUES (
        1,
        'Пешеходный переход',
        NULL,
        NULL
    ),
    (
        2,
        'Велосипедный переезд',
        NULL,
        NULL
    ),
    (
        3,
        'Неразрешенный пешеходный переход',
        NULL,
        NULL
    ),
    (
        4,
        'Остановка ГОПТ открытая',
        NULL,
        NULL
    ),
    (
        5,
        'Остановка ГОПТ в кармане',
        NULL,
        NULL
    ),
    (
        6,
        'Остановка ГОПТ закрытая',
        NULL,
        NULL
    ),
    (
        7,
        'Ограничение скорости (значение)',
        NULL,
        NULL
    ),
    (
        8,
        'Ограничение движения (значения)',
        NULL,
        NULL
    ),
    (
        9,
        'Ограничение стоянки (значение)',
        NULL,
        NULL
    ),
    (
        10,
        'Ограничение остановки (значение)',
        NULL,
        NULL
    ),
    (11, 'Съезд', NULL, NULL),
    (12, 'Въезд', NULL, NULL),
    (13, 'Проезд', NULL, NULL),
    (
        14,
        'Островок безопасности',
        NULL,
        NULL
    ),
    (
        15,
        'Полуостровок безопасности',
        NULL,
        NULL
    ),
    (
        16,
        'Искусственная неровность',
        NULL,
        NULL
    ),
    (
        17,
        'Средство успокоения движения (значение)',
        NULL,
        NULL
    ),
    (
        18,
        'Школьная стоянка',
        NULL,
        NULL
    ),
    (
        19,
        'Внеуличная стоянка',
        NULL,
        NULL
    ),
    (
        20,
        'Уличная стоянка (Значение: вдоль,30,45,60,90)',
        NULL,
        NULL
    ),
    (
        21,
        'Неразрешенная парковка',
        NULL,
        NULL
    ),
    (
        22,
        'Неразрешенная остановка',
        NULL,
        NULL
    ),
    (
        23,
        'Ограждение транспортное',
        NULL,
        NULL
    ),
    (
        24,
        'Ограждение пешеходное',
        NULL,
        NULL
    ),
    (
        25,
        'Ограждение от животных',
        NULL,
        NULL
    ),
    (
        26,
        'Место для отдыха',
        NULL,
        NULL
    ),
    (
        27,
        'Объект автосервиса',
        NULL,
        NULL
    );

-- Таблица: link_conflict_type_net_type
-- Настройка типов элементов ОДД в сетях
CREATE TABLE link_conflict_type_net_type (
    conflict_type_id BIGINT NOT NULL,
    net_type_id BIGINT NOT NULL,
    PRIMARY KEY (conflict_type_id, net_type_id),
    FOREIGN KEY (conflict_type_id) REFERENCES link_conflict_types (id),
    FOREIGN KEY (net_type_id) REFERENCES net_types (id)
);

-- Таблица: link_conflicts
-- Элементы ОДД на связях УДС
CREATE TABLE link_conflicts (
    id BIGINT PRIMARY KEY,
    link_id BIGINT NOT NULL,
    link_conflict_type_id BIGINT NOT NULL,
    direction VARCHAR(255) NOT NULL CHECK (direction IN ('ac', 'ca')),
    "from" DOUBLE PRECISION NOT NULL,
    "to" DOUBLE PRECISION NOT NULL,
    FOREIGN KEY (link_id) REFERENCES links (id),
    FOREIGN KEY (link_conflict_type_id) REFERENCES link_conflict_types (id)
);

-- Таблица: link_cross_element_types
-- Описание типов элементов поперечного профиля
CREATE TABLE link_cross_element_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    system_name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL,
    CONSTRAINT link_cross_element_types_system_name_unique UNIQUE (system_name)
);

-- Начальное заполнение link_cross_element_types
INSERT INTO
    link_cross_element_types (id, name, system_name, color)
VALUES (
        1,
        'Полоса',
        'traffic_lane',
        '#BFBFBF'
    ),
    (
        2,
        'Выделенная полоса',
        'lane_bus',
        '#990033'
    ),
    (
        3,
        'Велодорожка',
        'lane_bike',
        '#00CC99'
    ),
    (
        4,
        'Трамвайный путь',
        'lane_tram',
        '#808080'
    ),
    (
        5,
        'Проезд',
        'connector',
        '#D9D9D9'
    ),
    (
        6,
        'Тротуар',
        'sidewalk',
        '#FCE4D6'
    ),
    (
        7,
        'Разделительная полоса',
        'dividing',
        '#BFBFBF'
    ),
    (
        8,
        'Обочина',
        'shoulder',
        '#D5CAA3'
    ),
    (
        9,
        'Газон',
        'green_zone',
        '#C6E0B4'
    ),
    (
        10,
        'Деревья на тротуаре',
        'tree_zone',
        '#FCE4D6'
    ),
    (
        11,
        'Совмещенный тротуар',
        'sidebikewalk',
        '#FCE4D6'
    );

-- Таблица: link_cross_elements
-- Описание элементов поперечного профиля
CREATE TABLE link_cross_elements (
    id BIGINT PRIMARY KEY,
    link_cross_element_type_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    symbol VARCHAR(255) NOT NULL,
    setting JSON NOT NULL,
    bidirectional BOOLEAN NOT NULL,
    FOREIGN KEY (link_cross_element_type_id) REFERENCES link_cross_element_types (id),
    CONSTRAINT link_cross_elements_symbol_unique UNIQUE (symbol)
);

-- -- Начальное заполнение link_cross_elements
-- INSERT INTO link_cross_elements (id, link_cross_element_type_id, name, symbol, setting, bidirectional) VALUES
-- (1, 1, 'Полоса транспортная до 2,7м', 'л', '{"width": {"min": 1.5, "max": 2.7, "default": 2.7, "accuracy": 2}, "count": {"min": 1, "max": 6}}', NULL),
-- (2, 1, 'Полоса транспортная 2,7-3м', 'Л', '{"width": {"min": 2.71, "max": 3.00, "default": 3.00, "accuracy": 2}, "count": {"min": 1, "max": 6}}', NULL),
-- (3, 1, 'Полоса транспортная 3-3,5 м', 'г', '{"width": {"min": 3.0, "max": 3.5, "default": 3.5, "accuracy": 2}, "count": {"min": 1, "max": 6}}', FALSE),
-- (4, 1, 'Полоса транспортная 3,5-4 м', 'Г', '{"width": {"min": 3.5, "max": 4.0, "default": 4.0, "accuracy": 2}, "count": {"min": 1, "max": 6}}', FALSE),
-- (5, 1, 'Полоса транспортная св.4 м', 'а', '{"width": {"min": 4.0, "max": 10.0, "default": 4.0, "accuracy": 2}, "count": {"min": 1, "max": 6}}', FALSE),
-- (6, 2, 'Выделенная полоса МТС', 'А', '{}', FALSE),
-- (7, 3, 'Велодорожка односторонняя', 'в', '{}', FALSE),
-- (8, 3, 'Велодорожка двухсторонняя', 'В', '{}', TRUE),
-- (9, 4, 'Трамвайный путь односторонний', 'т', '{}', FALSE),
-- (10, 4, 'Трамвайный путь двухсторонний', 'Т', '{}', TRUE),
-- (11, 5, 'Местный проезд односторонний', 'м', '{}', FALSE),
-- (12, 5, 'Местный проезд двухсторонний', 'М', '{}', TRUE),
-- (13, 6, 'Тротуар пешеходный до 2м', 'п', '{}', TRUE),
-- (14, 11, 'Тротуар пешеходный свыше 2м', 'П', '{}', TRUE),
-- (15, 11, 'Тротуар совмещенный до 2м', 'с', '{}', TRUE),
-- (16, 7, 'Тротуар совмещенный свыше 2м', 'С', '{}', FALSE),
-- (17, 7, 'Разделительная разметка до 2м', 'р', '{}', FALSE),
-- (18, 7, 'Разделительная разметка св. 2м', 'Р', '{}', FALSE),
-- (19, 7, 'Разделительная полоса борт до 2м', 'б', '{}', FALSE),
-- (20, 7, 'Разделительная полоса борт св. 2м', 'Б', '{}', FALSE),
-- (21, 7, 'Разделительная полоса турникет до 2м', 'н', '{}', FALSE),
-- (22, 7, 'Разделительная полоса турникет св. 2м', 'Н', '{}', FALSE),
-- (23, 7, 'Разделительная полоса дорожное ограждение до 2м', 'д', '{}', FALSE),
-- (24, 7, 'Разделительная полоса дорожное ограждение св. 2м', 'Д', '{}', FALSE),
-- (25, 8, 'Обочина (автодорога)', 'х', '{}', FALSE),
-- (26, 9, 'Газон', 'ф', '{}', FALSE),
-- (27, 9, 'Газон с деревьями', 'Ф', '{}', FALSE),
-- (28, 10, 'Деревья на тротуаре', 'у', '{}', FALSE);

-- Таблица: link_cross_profiles
-- Описание поперечных профилей связей УДС
CREATE TABLE link_cross_profiles (
    id BIGINT PRIMARY KEY,
    link_id BIGINT NOT NULL,
    distance NUMERIC(6, 3) NOT NULL,
    cross_profile JSONB NOT NULL,
    direction VARCHAR(255) NOT NULL CHECK (direction IN ('ac', 'ca')),
    FOREIGN KEY (link_id) REFERENCES links (id)
);

-- Таблица: link_cross_profile_templates
-- Описание шаблонов поперечных профилей
CREATE TABLE link_cross_profile_templates (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    template JSONB NOT NULL
);

-- Таблица: diagram_types
-- Описание диаграмм для мета-анализа
CREATE TABLE diagram_types (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    icon_id BIGINT,
    FOREIGN KEY (icon_id) REFERENCES icons (id)
);

-- Начальное заполнение diagram_types
INSERT INTO
    diagram_types (id, name, icon_id)
VALUES (
        1,
        'Диаграмма «Корреляция»',
        NULL
    ),
    (2, 'Диаграмма «Тренд»', NULL),
    (
        3,
        'Диаграмма «Рейтинг»',
        NULL
    );

-- Таблица: diagram_type_region_attribute_type
-- Настройка использования характеристик для диаграмм
CREATE TABLE diagram_type_region_attribute_type (
    diagram_type_id BIGINT NOT NULL,
    region_attribute_type_id BIGINT NOT NULL,
    axis VARCHAR(255) NOT NULL CHECK (axis IN ('x', 'y')),
    PRIMARY KEY (
        diagram_type_id,
        region_attribute_type_id
    ),
    FOREIGN KEY (diagram_type_id) REFERENCES diagram_types (id),
    FOREIGN KEY (region_attribute_type_id) REFERENCES region_attribute_types (id)
);