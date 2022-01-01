# HTTPS Let's encrypt based Nginx reverse proxy
Automated nginx-proxy &amp; let's encrypt HTTPS reverse proxy for your dockerized applications
Based on Jason Wilder's Nginx HTTP Proxy (https://github.com/nginx-proxy/nginx-proxy) 
and Aegypius Mkcert for nginx-proxy (https://github.com/aegypius/mkcert-for-nginx-proxy)

* Automation of DNS and Hosts naming + SSL certificates using [docker-gen](https://github.com/nginx-proxy/docker-gen) templates
* [mkcert](https://github.com/FiloSottile/mkcert) certificates + CA preconfigured for Mozilla Firefox Web browser
* [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) working server (port 53) and on-demand (`make set-hosts`) system `/etc/hosts` file with the following pattern : 
  * For every container exposing ports : `docker-compose.service`.`docker-compose.project`.docker record
  * For proxied services only : entries matching `VIRTUAL_HOST` resolve the nginx-proxy IP address
* Management of all your stacks and containers using (Portainer CE)[https://hub.docker.com/r/portainer/portainer-ce]

<p>
  <img src="https://raw.githubusercontent.com/elasticlabs/elabs-https-local-proxy/main/stack.png" alt="Automated HTTPS proxy architecture" width="350px">
</p>

**Table Of Contents:**
  - [Docker environment preparation](#docker-environment-preparation)
  - [Nginx HTTPS Proxy preparation](#nginx-https-proxy-preparation)
  - [Stack deployment](#stack-deployment)

----

## Docker environment preparation 
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Verify that you properly followed all [Docker post-installation steps](https://docs.docker.com/engine/install/linux-postinstall)
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)

## Nginx HTTPS Proxy preparation
* Create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* Choose & configure a selected DNS name (e.g. `*.myapp.docker`). Make sure it properly resolves from your server using `nslookup`commands
* GIT clone this repository `git clone https://github.com/elasticlabs/elabs-https-local-proxy.git`

## Stack deployment
**Configuration**
* **Rename `.env-changeme` file into `.env`** to prepare `docker-compose` environment.
* Modify the following variables in `.env` file :
  * `PORTAINER_VHOST=` : replace `portainer.myapp.docker` with your choosen subdomain for portainer and by extension, your local dockerized apps.
  
**Deployment**
* Get help : `make build`
* Bring up the whole stack : `make build && sudo make up`
* Once complet, setup the system `hosts` file : `make set-hosts`

**Useful management commands**
* Go inside a container : `docker-compose exec <service-id> /bin/sh`
* See service logs of a service : `sudo docker-compose logs <service-id>`
* Monitor containers : `docker stats` or... use portainer!
