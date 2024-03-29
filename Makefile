include .env
include repos
.DEFAULT_GOAL= help
.PHONY: help watch test docker-install install-% docker-reset

BASH=docker exec -it docker-dev_tools_1 bash -c

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

docker-install: /usr/bin/docker /usr/bin/docker-compose ## installation de docker et docker compose

/usr/bin/docker: ## installation de docker
	sudo apt-get update
	sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
	sudo apt-key fingerprint 0EBFCD88
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io

/usr/bin/docker-compose:  ## installation de docker compose
	sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

watch: /usr/bin/docker-compose /usr/bin/docker ## lancement des contenainer
	docker-compose up -d --scale redis-replicat=2 --scale redis-sentinel=3

docker-stop:
	docker-compose stop

docker-down:
	docker-compose down --remove-orphans

.env: .env.dist
	cp .env.dist .env

repos: repos.dist
	cp repos.dist repos

hosts: hosts.dist
	cp hosts.dist hosts

${DOCKER_VOLUME_PATH}%:
	git clone ${${shell basename $@}} $@

install-%: ${DOCKER_VOLUME_PATH}% watch
	$(BASH) "cd /var/www/$(shell basename $^); make install"


install: .env repos hosts mkcert watch

docker-reset: docker-down watch ## remove and pull

docker-restart: docker-stop watch ## restart docker

nginx-%: ## nginx-(start/stop/reload)
	docker-compose exec nginx nginx -s $(shell echo $@ | cut -c7-)

mkcert:
	sudo apt-get update
	sudo apt install libnss3-tools wget -y
	wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.2/mkcert-v1.4.2-linux-amd64
	chmod +x mkcert
	./mkcert -install
	./mkcert *.localhost
	./mkcert -CAROOT