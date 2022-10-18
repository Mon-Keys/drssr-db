docker:
	service postgresql stop
	sudo docker compose up

local:
	service postgresql start
	go run cmd/main.go