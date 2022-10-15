package repo

import (
	"database/sql"
	"drssrdb"
	"log"

	"github.com/pressly/goose/v3"
	"github.com/sirupsen/logrus"
)

type Config struct {
	Postgres string `mapstructure:"postgres"`
	Env      string `mapstructure:"env"`
}

type db struct {
	DB     sql.DB
	Logger logrus.Logger
}

func NewDatabase(logger logrus.Logger, config Config) *db {
	sql, err := sql.Open("postgres", config.Postgres)
	if err != nil {
		panic(err)
	}

	if err := sql.Ping(); err != nil {
		log.Panicf("POSTGRES FAILED, err: %v", err)
		return nil
	}

	return &db{
		DB:     *sql,
		Logger: logger,
	}
}

func ApplyMigrations(db *db) error {
	goose.SetBaseFS(drssrdb.Migrations)
	// goose.SetLogger(&gooseLogger{
	// 	Logger: db.logger,
	// })
	err := goose.Up(&db.DB, "migrations")
	if err != nil {
		db.Logger.Error(err)
	}
	return err
}
