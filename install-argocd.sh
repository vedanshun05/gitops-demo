#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  install-argocd.sh  –  Install Argo CD with all required CRDs
# ─────────────────────────────────────────────────────────────
set -euo pipefail

ARGOCD_VERSION="stable"
NAMESPACE="argocd"

echo "→ Creating namespace: $NAMESPACE"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "→ Installing Argo CD $ARGOCD_VERSION ..."
kubectl apply -n "$NAMESPACE" \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml"

echo "→ Applying ApplicationSet CRD (server-side to avoid annotation size limit) ..."
curl -sL "https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/crds/applicationset-crd.yaml" \
  | kubectl apply --server-side -f -

echo "→ Waiting for all Argo CD pods to be Ready (up to 5 min) ..."
kubectl wait --for=condition=Ready pod \
  --all -n "$NAMESPACE" \
  --timeout=300s

echo ""
echo "✅  Argo CD is ready!"
echo ""
echo "Get admin password:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret \\"
echo "    -o jsonpath='{.data.password}' | base64 -d && echo"
echo ""
echo "Port-forward UI (keep terminal open):"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then open: https://localhost:8080  (username: admin)"
