# docker-testing
Just some commands for interacting with Cloudsmith repository

```
docker login docker.cloudsmith.io
```

```
docker pull bitnami/postgresql:15.3.0-debian-11-r0
```

```
docker tag bitnami/postgresql:15.3.0-debian-11-r0 docker.cloudsmith.io/acme-corporation/acme-repo-one/bitnami/postgresql:15.3.0-debian-11-r0
```

```
docker push docker.cloudsmith.io/acme-corporation/acme-repo-one/bitnami/postgresql:15.3.0-debian-11-r0 -k "$API_KEY"
```

<img width="1269" alt="Screenshot 2025-04-25 at 12 27 59" src="https://github.com/user-attachments/assets/410cb609-e061-4f01-b040-68405b115aba" />
