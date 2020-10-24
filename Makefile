include .env
include repos
.DEFAULT_GOAL= help
.PHONY: help watch test docker-install install-%

BASH=docker exec -it docker-dev_tools_1 bash -c

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-10s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

docker-install: /usr/bin/docker /usr/bin/docker-compose ##installation de docker et docker compose

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
	docker-compose up -d

.env: .env.dist
	cp .env.dist .env

repos: repos.dist
	cp repos.dist repos

hosts: hosts.dist
	cp hosts.dist hosts

${DOCKER_VOLUME_PATH}%:
	git clone ${${shell basename $@}} $@

install-%: ${DOCKER_VOLUME_PATH}%
	$(BASH) "cd /var/www/$(shell basename $^); make install"


install: .env repos hosts watch
#	make install-...

