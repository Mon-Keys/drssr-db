UNAME_S := $(shell uname -s)

POSTGRES_STOP =
POSTGRES_START =
ifeq ($(UNAME_S),Linux)
	POSTGRES_STOP = service postgresql stop
	POSTGRES_START = service postgresql start
endif

mac-docker:
	sudo docker compose up

docker:
	$(POSTGRES_STOP)
	sudo docker compose up

local:
	$(POSTGRES_START)
	go run cmd/main.go
