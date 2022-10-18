-- +goose Up
-- +goose StatementBegin
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
    img        VARCHAR(32) NOT NULL,
    brand      VARCHAR(32) NOT NULL DEFAULT '',
    sex        sex_enum    NOT NULL DEFAULT 'unisex',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE looks
(
    id          BIGSERIAL PRIMARY KEY,
    preview     VARCHAR(32) NOT NULL,
    path        VARCHAR(32) NOT NULL,
    description VARCHAR(64) NOT NULL DEFAULT '',
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
    id         BIGSERIAL PRIMARY KEY,
    percent    int         NOT NULL,
    clothe1_id BIGINT      NOT NULL,
    clothe2_id BIGINT      NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT FK_clothe1_clothes FOREIGN KEY (clothe1_id)
        REFERENCES clothes (id),
    CONSTRAINT FK_clothe2_clothes FOREIGN KEY (clothe2_id)
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
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP EXTENSION citext CASCADE;
DROP EXTENSION hstore CASCADE;

DROP TYPE sex_enum CASCADE;

DROP TABLE users CASCADE;
DROP TABLE clothes CASCADE;
DROP TABLE looks CASCADE;
DROP TABLE tags CASCADE;
DROP TABLE similarity CASCADE;
DROP TABLE clothes_users CASCADE;
DROP TABLE links CASCADE;
-- +goose StatementEnd