package main

import (
	"drssrdb/repo"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"runtime/debug"

	_ "github.com/lib/pq"
	"github.com/sirupsen/logrus"
)

const (
	ConfigEnvVariableName = "APPCONFIG"
	ConfigFlagName        = "config"
)

var DefaultConfig = repo.Config{
	Postgres: "host=localhost port=5432 user=admin password=lolkek dbname=drssr sslmode=disable",
}

var (
	DB_USERNAME = os.Getenv("DB_USERNAME")
	DB_PASSWORD = os.Getenv("DB_PASSWORD")
	DB_HOST     = os.Getenv("DB_HOST")
	DB_PORT     = os.Getenv("DB_PORT")
	DB_NAME     = os.Getenv("DB_NAME")
	ROOT_DIR    = "./migrations/"
)

func main() {
	log.Printf("DB_ADDR:            %v", DB_HOST)
	log.Printf("DB_PORT:            %v", DB_PORT)
	log.Printf("DB_NAME:            %v", DB_NAME)
	log.Printf("DB_USERNAME:        %v", DB_USERNAME)

	logger := logrus.New()

	defer func() {
		if r := recover(); r != nil {
			logger.Error("main", fmt.Errorf("panic in main %s\n%#v", string(debug.Stack()), r))
		}
	}()

	configFile := os.Getenv(ConfigEnvVariableName)

	var config repo.Config
	if len(configFile) > 0 {
		config = LoadConfiguration(configFile)
	} else {
		config = DefaultConfig
	}

	if config.Env == "dev" {
		logger.Level = logrus.DebugLevel
	} else {
		logger.Level = logrus.WarnLevel
	}
	defer logger.Exit(0)

	logger.Info("service starting...")
	defer logger.Info("service stopped")

	db := repo.NewDatabase(*logger, config)
	defer db.DB.Close()

	if err := repo.ApplyMigrations(db); err != nil {
		panic(err)
	}
}

func LoadConfiguration(file string) repo.Config {
	var config repo.Config
	configFile, err := os.Open(file)
	if err != nil {
		fmt.Println(err.Error())
	}
	defer configFile.Close()
	jsonParser := json.NewDecoder(configFile)
	jsonParser.Decode(&config)
	return config
}
