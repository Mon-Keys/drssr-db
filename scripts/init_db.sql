CREATE EXTENSION citext;
CREATE EXTENSION hstore;
CREATE TYPE sex_enum AS ENUM ('male', 'female', 'unisex');

CREATE TABLE users
(
    id          BIGSERIAL PRIMARY KEY,
    nickname    VARCHAR(32) NOT NULL UNIQUE,
    email       citext      NOT NULL UNIQUE,
    password    VARCHAR(128) NOT NULL,
    name        VARCHAR(64) NOT NULL DEFAULT '',
    avatar      VARCHAR(64) NOT NULL DEFAULT '',
    stylist     BOOL        NOT NULL DEFAULT false,
    birth_date  DATE        NOT NULL,
    description VARCHAR(64) NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE clothes
(
    id         BIGSERIAL PRIMARY KEY,
    type       VARCHAR(32) NOT NULL,
    color      VARCHAR(32) NOT NULL DEFAULT '',
    img        VARCHAR(256) NOT NULL,
    mask       VARCHAR(256) NOT NULL,
    brand      VARCHAR(32) NOT NULL DEFAULT '',
    sex        sex_enum    NOT NULL DEFAULT 'unisex',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE looks
(
    id          BIGSERIAL PRIMARY KEY,
    preview     VARCHAR(256) NOT NULL DEFAULT '',
    img         VARCHAR(256) NOT NULL,
    description VARCHAR(1024) NOT NULL DEFAULT '',
    creator_id  BIGINT      NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT FK_looks_user FOREIGN KEY (creator_id)
        REFERENCES users (id)
);

CREATE TABLE tags
(
    id    BIGSERIAL PRIMARY KEY,
    title VARCHAR(32) NOT NULL
);

CREATE TABLE similarity
(
    id          BIGSERIAL PRIMARY KEY,
    percent     INT         NOT NULL,
    clothes1_id BIGINT      NOT NULL,
    clothes2_id BIGINT      NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT FK_clothes1_clothes FOREIGN KEY (clothes1_id)
        REFERENCES clothes (id),
    CONSTRAINT FK_clothes2_clothes FOREIGN KEY (clothes2_id)
        REFERENCES clothes (id)
);

CREATE TABLE clothes_users
(
    id         BIGSERIAL PRIMARY KEY,
    clothes_id BIGINT      NOT NULL,
    user_id    BIGINT      NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT FK_cu_clothes FOREIGN KEY (clothes_id)
        REFERENCES clothes (id),
    CONSTRAINT FK_cu_users FOREIGN KEY (user_id)
        REFERENCES users (id)
);

CREATE TABLE clothes_looks
(
    id         BIGSERIAL PRIMARY KEY,
    clothes_id BIGINT      NOT NULL,
    look_id    BIGINT      NOT NULL,
    x          INT         NOT NULL,
    y          INT         NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT FK_cl_clothes FOREIGN KEY (clothes_id)
        REFERENCES clothes (id),
    CONSTRAINT FK_cl_looks FOREIGN KEY (look_id)
        REFERENCES looks (id)
);

CREATE TABLE links
(
    id         BIGSERIAL PRIMARY KEY,
    name       citext      NOT NULL UNIQUE,
    price      citext      NOT NULL DEFAULT 0,
    sizes      hstore,
    clothes_id BIGINT      NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT FK_links_clothes FOREIGN KEY (clothes_id)
        REFERENCES clothes (id)
);