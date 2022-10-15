package main

import (
	"drssrdb/repo"
	"flag"
	"fmt"
	"log"
	"os"
	"runtime/debug"

	"git.gotbit.io/gotbit/vipe"
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
	ROOT_DIR    = "./forwards/"
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
	if len(configFile) == 0 {
		flag.StringVar(&configFile, ConfigFlagName, "", "full path to a json config file")
		flag.Parse()
	}
	configuration, err := vipe.NewConfiguration(DefaultConfig)
	if err != nil {
		logger.Error("new configuration", "error", err)
		return
	}
	if len(configFile) > 0 {
		configuration.SetConfigFile(configFile)
		err := configuration.SafeWriteConfigAs(configFile)
		if err != nil {
			logger.Warn(err)
		}
	}

	if err := configuration.ReadInConfig(); err != nil {
		logger.Warn(err)
	}

	config := configuration.GetValue()
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
