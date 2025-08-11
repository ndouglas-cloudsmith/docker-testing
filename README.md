# Ensuring only Cloudsmith source is allowed in Kubernetes
Docker Login credentials are username: ```Cloudsmith Email``` and password: ```Cloudsmith API Key```

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

<img width="1495" alt="Screenshot 2025-04-25 at 12 43 12" src="https://github.com/user-attachments/assets/19026371-dbc9-4fa4-b480-4005fde2f390" />


## Part 1: Install OPA Gatekeeper

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.13/deploy/gatekeeper.yaml
```

```
kubectl get pods -n gatekeeper-system
```

## Part 2: Create a ConstraintTemplate
This defines the Rego logic. Here’s one that blocks images not from ```cloudsmith.io```:
```
kubectl apply -f https://raw.githubusercontent.com/ndouglas-cloudsmith/docker-testing/refs/heads/main/constrainttemplate.yaml
```

## Part 3: Create a Constraint to enforce the rule
This tells Gatekeeper to apply the template to all pods.
```
kubectl apply -f https://raw.githubusercontent.com/ndouglas-cloudsmith/docker-testing/refs/heads/main/constraint.yaml
```

First, name your repository as a source:
```
helm repo add acme-corporation-acme-repo-one \
  'https://dl.cloudsmith.io/public/acme-corporation/acme-repo-one/helm/charts/'
helm repo update
```
Once the repository setup is complete, you can install this package with the following command:
```
helm install acme-corporation-acme-repo-one/insert-funny-name --version 0.1.0 --generate-name
```

<img width="993" alt="Screenshot 2025-04-25 at 13 09 19" src="https://github.com/user-attachments/assets/dfeebacc-fd15-40ec-a337-aa5fdefa380d" />


## Policy Diagnostics Dump
```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/docker-testing/refs/heads/main/policy-dump.rego
escaped_policy=$(jq -Rs . < policy-dump.rego)
cat <<EOF > payload.json
{
  "name": "OSV Diagnostic",
  "description": "Logs all vulnerabilities from security_scan for debugging.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 1
}
EOF

curl -X POST "https://api.cloudsmith.io/v2/workspaces/acme-corporation/policies/" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
  -d @payload.json | jq .
```

```
export SLUG_PERM=$(curl -s -X GET "https://api.cloudsmith.io/v2/workspaces/acme-corporation/policies/" -H "X-Api-Key: $CLOUDSMITH_API_KEY" | jq -r '.results[0].slug_perm')
curl -X POST "https://api.cloudsmith.io/v2/workspaces/acme-corporation/policies/$SLUG_PERM/actions/" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
  -d '{
    "action_type": "SetPackageState",
    "precedence": 1,
    "package_state": "QUARANTINED"
  }'   | jq .
```

```
curl -X GET \
  "https://api.cloudsmith.io/v2/workspaces/acme-corporation/policies/decision_logs/?policy=$SLUG_PERM" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" | jq .
```

```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/docker-testing/refs/heads/main/script.sh
chmod +x script.sh
bash script.sh
```


Alternatively:

```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/docker-testing/refs/heads/main/osv-dump.rego
escaped_policy=$(jq -Rs . < osv-dump.rego)
cat <<EOF > payload.json
{
  "name": "OSV Dump",
  "description": "Logs output metadata from the OSV fields.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 1
}
EOF

curl -X POST "https://api.cloudsmith.io/v2/workspaces/acme-corporation/policies/" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
  -d @payload.json | jq .
```
