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

## Install OPA Gatekeeper

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.13/deploy/gatekeeper.yaml
```

```
kubectl get pods -n gatekeeper-system
```

## Install OPA Gatekeeper

This defines the Rego logic. Here’s one that blocks images not from cloudsmith.io:
```
kubectl apply -f
```

<img width="993" alt="Screenshot 2025-04-25 at 13 09 19" src="https://github.com/user-attachments/assets/dfeebacc-fd15-40ec-a337-aa5fdefa380d" />




