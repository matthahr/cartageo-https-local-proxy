# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/sh
.SHELLFLAGS   = -o pipefail -c

# Setup variables
#
# -> Project variables
PROXY_IP?=$(shell grep -m 1 nginx-proxy /etc/hosts.dnsmasq | awk '{print $$1}')

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "===================================================================================="
	@echo " Automated HTTPS local reverse proxy -> Proxy IP Address fixer" 
	@echo " "
	@echo " Hints for developers:"
	@echo "  make set-dnsmasq      # Set the NginX proxy IP as default target for VIRTUAL_HOST"
	@echo "===================================================================================="

.PHONY: set-dnsmasq
set-dnsmasq:
	sed -i -e "/PROXY_BEGIN/,/PROXY_END/s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${PROXY_IP}/g" /etc/hosts.dnsmasq
	sed -i -e "/PROXY_BEGIN/,/PROXY_END/s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${PROXY_IP}/g" /etc/dnsmasq.conf
