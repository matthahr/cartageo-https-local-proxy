# mkcert for nginx-proxy
This container is a lightweight companion container for the [nginx-proxy/nginx-proxy].
It's heavily inspired by [nginx-proxy/acme-companion] and it allows the creation/renewal
of self-signed certificate with a root certificate authority.
-> This implementatino is based on [aegypius/mkcert-for-nginx-proxy] work.

### Features
- Automatic creation/renewal of Self-Signed Certificates using original nginx-proxy container
- Support creation of Multi-Domain ([SAN](https://www.digicert.com/subject-alternative-name.htm])) certificates
- Work with all versions of docker
```

You need to ***set a CA_STORE environment variable***  according to your distribution :

#### For Ubuntu / Debian:

```shell
make up
sudo update-ca-certificates
```

#### For Arch / Manjaro:

```shell
echo 'CA_STORE=/etc/ca-certificates/trust-source/anchors' >> .env
make up
sudo trust extract-compat
```

#### For Fedora / RHEL / CentOS:

```shell
echo 'CA_STORE=/etc/pki/ca-trust/source/anchors' >> .env
make up
sudo update-ca-trust extract
```

##### For Gentoo:

```shell
echo 'CA_STORE=/etc/ssl/certs' >> .env
make up
sudo update-ca-certificates
```

Restart your browsers !

### Related projects

- [FiloSottile/mkcert]
- [nginx-proxy/acme-companion]
- [nginx-proxy/docker-gen]
- [nginx-proxy/nginx-proxy]
- [aegypius/mkcert-for-nginx-proxy]

[FiloSottile/mkcert]: https://github.com/FiloSottile/mkcert
[nginx-proxy/acme-companion]: https://github.com/nginx-proxy/acme-companion
[nginx-proxy/nginx-proxy]: https://github.com/nginx-proxy/nginx-proxy
[nginx-proxy/docker-gen]: https://github.com/nginx-proxy/docker-gen
[aegypius/mkcert-for-nginx-proxy]: https://github.com/aegypius/mkcert-for-nginx-proxy