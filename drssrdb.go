package drssrdb

import "embed"

//go:embed forwards/*.sql
var Migrations embed.FS
