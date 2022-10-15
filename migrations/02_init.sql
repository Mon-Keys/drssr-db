-- +goose Up
-- +goose StatementBegin
CREATE EXTENSION citext;
CREATE EXTENSION hstore;
CREATE TYPE sex_enum AS ENUM ('male', 'female', 'unisex');

CREATE TABLE users
(
    user_id     bigserial primary key,
    nickname    varchar(32) NOT NULL UNIQUE,
    email       citext      NOT NULL UNIQUE,
    name        varchar(64) NOT NULL DEFAULT '',
    stylist     bool        NOT NULL DEFAULT false,
    birthday    date        NOT NULL,
    description varchar(64) NOT NULL DEFAULT '',
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE clothes
(
    clothe_id  bigserial primary key,
    type       varchar(32) NOT NULL,
    color      varchar(32) NOT NULL DEFAULT '',
    img        varchar(32) NOT NULL,
    brand      varchar(32) NOT NULL DEFAULT '',
    sex        sex_enum    NOT NULL DEFAULT 'unisex',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE looks
(
    look_id     bigserial primary key,
    pre_path    varchar(32) NOT NULL,
    path        varchar(32) NOT NULL,
    description varchar(64) NOT NULL DEFAULT '',
    creator_id  bigint      NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT FK_looks_user FOREIGN KEY (creator_id)
        REFERENCES users (user_id)
);

CREATE TABLE tags
(
    tag_id bigserial primary key,
    title  varchar(32) NOT NULL
);

CREATE TABLE similarity
(
    similarity_id bigserial primary key,
    percent       int         NOT NULL,
    clothe1_id    bigint      NOT NULL,
    clothe2_id    bigint      NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT FK_clothe1_clothes FOREIGN KEY (clothe1_id)
        REFERENCES clothes (clothe_id),
    CONSTRAINT FK_clothe2_clothes FOREIGN KEY (clothe2_id)
        REFERENCES clothes (clothe_id)
);

CREATE TABLE clothes_users
(
    clothes_users_id bigserial primary key,
    clothe_id        bigint      NOT NULL,
    user_id          bigint      NOT NULL,
    created_at       timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT FK_cu_clothes FOREIGN KEY (clothe_id)
        REFERENCES clothes (clothe_id),
    CONSTRAINT FK_cu_users FOREIGN KEY (user_id)
        REFERENCES users (user_id)
);

CREATE TABLE links
(
    link_id    bigserial primary key,
    name       citext      NOT NULL UNIQUE,
    price      citext      NOT NULL DEFAULT 0,
    sizes      hstore,
    clothe_id  bigint      NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT FK_links_clothes FOREIGN KEY (clothe_id)
        REFERENCES clothes (clothe_id)
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