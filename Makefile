

docker-dev:
	docker build -t ssh-manager . && docker run --rm -it -v ssh_data:/app/data -p 9000:9000 ssh-manager

compose:
	docker compose up --build