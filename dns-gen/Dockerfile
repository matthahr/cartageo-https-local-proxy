FROM alpine:edge
LABEL maintainer="Patrice MAUNY <https://github.com/elasticlabs>"

# docker-gen release
ENV DOCKER_GEN_VERSION=0.8.0 \
    DOCKER_HOST=unix:///var/run/docker.sock

# Fetch dnsmasq binaries
RUN apk update && apk add --no-cache \
	curl \
	dnsmasq \
	make \
	supervisor \
	openssl

# Install docker-gen
WORKDIR /usr/local/bin
RUN curl -L https://github.com/nginx-proxy/docker-gen/releases/download/${DOCKER_GEN_VERSION}/docker-gen-linux-amd64-${DOCKER_GEN_VERSION}.tar.gz | tar -C . -xz
RUN chmod +x /usr/local/bin/docker-gen

# Copy files
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor.d/docker-gen.ini
COPY dnsmasq.tmpl /etc/dnsmasq.tmpl
COPY dnsmasq.hosts.tmpl /etc/dnsmasq.hosts.tmpl
COPY dnsmasq.makefile /root/makefile
COPY docker-gen.cfg /root/docker-gen.cfg
COPY .hosts.dnsmasq /etc/hosts.dnsmasq

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-n"]
