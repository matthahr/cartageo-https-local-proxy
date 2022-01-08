# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Setup variables
#
# -> Project variables
PROJECT_NAME?=$(shell cat .env | grep -v ^\# | grep COMPOSE_PROJECT_NAME | sed 's/.*=//')
PROXY_DOMAIN?=$(shell echo ${PROJECT_NAME}.docker)
APPS_NETWORK?=$(shell cat .env | grep -v ^\# | grep APPS_NETWORK | sed 's/.*=//')
ADMIN_NETWORK?=$(shell cat .env | grep -v ^\# | grep ADMIN_NETWORK | sed 's/.*=//')

# -> App variables
APP_BASEURL?=$(shell cat .env | grep PORTAINER_VHOST | sed 's/.*=//')
DNSMASQ_CONFIG?=$(shell docker volume inspect --format '{{ .Mountpoint }}' ${PROJECT_NAME}_config)

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=================================================================================="
	@echo " Automated HTTPS proxy for local devs with docker  "
	@echo "  https://github.com/elasticlabs/elabs-https-local-proxy"
	@echo " "
	@echo " Few hints:"
	@echo "  make build            # Checks that everythings's OK then builds the stack"
	@echo "  make up               # With working proxy, brings up the software stack"
	@echo "  make set-hosts        # Replaces your hosts file with the generated one"
	@echo "  make update           # Update the whole stack"
	@echo "  make hard-cleanup     # /!\ Remove images, containers, networks, volumes & data"
	@echo "=================================================================================="

.PHONY: build
build:
	# Network creation if not done yet
	@bash ./.utils/message.sh info "[INFO] Create ${APPS_NETWORK} and ${ADMIN_NETWORK} networks if they don't already exist"
	docker network inspect ${APPS_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${APPS_NETWORK}
	docker network inspect ${ADMIN_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${ADMIN_NETWORK}
	# Handle preservation of original hosts content and build hosts template
	@bash ./.utils/message.sh info "[INFO] Include original hosts in hosts file template"
	if [ ! -f /etc/hosts.orig ]; then sudo cp /etc/hosts /etc/hosts.orig; fi
	grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /etc/hosts.orig > dns-gen/dnsmasq.hosts.tmpl
	more dns-gen/dnsmasq.hosts >> dns-gen/dnsmasq.hosts.tmpl
	@bash ./.utils/message.sh info "[INFO] setting proxy FQDN for proper hosts templating."
	sed -i "s/changeme/${PROXY_DOMAIN}/" ./dns-gen/dnsmasq.makefile
	# Build the stack
	@bash ./.utils/message.sh info "[INFO] Building the application"
	docker-compose -f docker-compose.yml build
	@bash ./.utils/message.sh info "[INFO] Build OK. Use make up to activate the local HTTPS proxy."

.PHONY: up
up: build
	@bash ./.utils/message.sh info "[INFO] Bringing up the HTTPS automated proxy"
	docker-compose up -d --remove-orphans
	@make urls

.PHONY: set-hosts
set-hosts:
	@bash ./.utils/message.sh info "[INFO] Updating system hosts file (sudo mode)"
	sudo cp ${DNSMASQ_CONFIG}/hosts.dnsmasq /etc/hosts 

.PHONY: hard-cleanup
hard-cleanup:
	@bash ./.utils/message.sh info "[INFO] Bringing done the HTTPS automated proxy"
	docker-compose -f docker-compose.yml down --remove-orphans
	# Delete all hosted persistent data available in volumes
	@bash ./.utils/message.sh info "[INFO] Cleaning up static volumes"
	docker volume rm -f $(PROJECT_NAME)_ssl-certs
	docker volume rm -f $(PROJECT_NAME)_portainer-data
	@bash ./.utils/message.sh info "[INFO] Cleaning up containers & images"
	docker system prune -a
	@bash ./.utils/message.sh info "[INFO] Cleaning up portainer static volume and data (/opt/portainer/data)."
	rm -rf /opt/portainer/data
	@bash ./.utils/message.sh info "[INFO] Reverting system hosts file to original state"
	sudo cp /etc/hosts.orig /etc/hosts

.PHONY: urls
urls:
	@bash ./.utils/message.sh warning "[WARNING] You should now activate projet host file with # make set-hosts"
	@bash ./.utils/message.sh headline "[INFO] You may then access your project at the following URL:"
	@bash ./.utils/message.sh link "Portainer docker admin GUI:  https://${APP_BASEURL}/"
	@echo ""

.PHONY: pull
pull: 
	docker-compose pull

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5
