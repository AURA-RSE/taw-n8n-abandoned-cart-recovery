#!/usr/bin/env bash
# Fire fake Shopify webhooks at the n8n workflow.
# Usage: N8N_BASE_URL=https://your-instance.app.n8n.cloud ./scripts/send-test-events.sh <checkout|order|no-consent|no-contact> [--test]
#   --test  uses /webhook-test/ (n8n editor "Listen for test event") instead of /webhook/
set -euo pipefail

: "${N8N_BASE_URL:?Set N8N_BASE_URL, e.g. https://your-instance.app.n8n.cloud}"
EVENT="${1:-checkout}"
PREFIX="webhook"
[[ "${2:-}" == "--test" ]] && PREFIX="webhook-test"

DIR="$(cd "$(dirname "$0")/.." && pwd)/sample-data"

case "$EVENT" in
  checkout)    PATH_PART="shopify/checkout-created"; FILE="checkout-created.json" ;;
  order)       PATH_PART="shopify/order-created";    FILE="order-created.json" ;;
  no-consent)  PATH_PART="shopify/checkout-created"; FILE="checkout-no-consent.json" ;;
  no-contact)  PATH_PART="shopify/checkout-created"; FILE="checkout-no-contact.json" ;;
  *) echo "Unknown event: $EVENT (use checkout|order|no-consent|no-contact)"; exit 1 ;;
esac

URL="${N8N_BASE_URL%/}/${PREFIX}/${PATH_PART}"
echo "POST $URL  <-  sample-data/$FILE"
curl -sS -X POST "$URL" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Topic: ${PATH_PART#shopify/}" \
  --data @"$DIR/$FILE"
echo
