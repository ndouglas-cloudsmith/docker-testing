#!/bin/bash
set -euo pipefail

ORG="acme-corporation"
REPO="acme-repo-one"
PKG_NAME="osv-policy-test"
POLICY_NAME="OSV Diagnostic"

if [[ -z "${CLOUDSMITH_API_KEY:-}" ]]; then
  echo "❌ CLOUDSMITH_API_KEY is not set. Please export it first."
  exit 1
fi

# 1. Get policy slug (v2 API)
echo "🔍 Fetching policy list..."
POLICY_RESPONSE=$(curl -s -X GET \
  "https://api.cloudsmith.io/v2/workspaces/$ORG/policies/" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY")

echo "Raw policy response:"
echo "$POLICY_RESPONSE" | jq '.' || echo "Invalid JSON received for policies."

POLICY_SLUG=$(echo "$POLICY_RESPONSE" | jq -r --arg NAME "$POLICY_NAME" '
  .results[]? | select(.name == $NAME) | .slug_perm // empty')

if [[ -z "$POLICY_SLUG" ]]; then
  echo "❌ Policy not found: $POLICY_NAME in workspace $ORG"
  exit 1
fi
echo "✅ Found policy slug: $POLICY_SLUG"

# 2. Get package slug (v1 API)
echo "🔍 Fetching package list..."
PKG_RESPONSE=$(curl -s -X GET \
  "https://api.cloudsmith.io/v1/packages/$ORG/$REPO/" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY")

echo "Raw package response:"
echo "$PKG_RESPONSE" | jq '.' || echo "Invalid JSON received for packages."

PKG_SLUG=$(echo "$PKG_RESPONSE" | jq -r --arg NAME "$PKG_NAME" '
  .[]? | select(.name == $NAME) | .slug_perm // empty' | head -n 1)

if [[ -z "$PKG_SLUG" ]]; then
  echo "❌ Package not found: $PKG_NAME in $ORG/$REPO"
  exit 1
fi
echo "✅ Found package slug: $PKG_SLUG"

# 3. Run simulation (v2 API)
echo "🔍 Simulating policy '$POLICY_NAME' on package '$PKG_NAME'..."
SIM_RESPONSE=$(curl -s -X GET \
  "https://api.cloudsmith.io/v2/workspaces/$ORG/policies/$POLICY_SLUG/simulate/?package=$PKG_SLUG" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY")

echo "Simulation result:"
echo "$SIM_RESPONSE" | jq '.' || echo "Invalid JSON received from simulation."

exit 0
