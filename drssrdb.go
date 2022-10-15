package drssrdb

import "embed"

const ApplicationName = "auth"

//go:embed migrations/*.sql
var Migrations embed.FS
