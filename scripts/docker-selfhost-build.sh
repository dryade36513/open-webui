#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"
IMAGE_NAME="${OPEN_WEBUI_IMAGE_NAME:-open-web-ui}"
IMAGE_TAG="${OPEN_WEBUI_IMAGE_TAG:-local}"

if [[ ! -f .env ]] && [[ -z "${WEBUI_SECRET_KEY:-}" ]]; then
  echo "缺少 .env 或未設定 WEBUI_SECRET_KEY。請: cp deployment/compose.env.example .env 並編輯，或匯出 WEBUI_SECRET_KEY。" >&2
  exit 1
fi

echo "Building with $COMPOSE_FILE -> ${IMAGE_NAME}:${IMAGE_TAG}"
docker compose -f "$COMPOSE_FILE" build

echo "Done. 啟動: docker compose -f $COMPOSE_FILE up -d"
echo "若要推送: docker push ${IMAGE_NAME}:${IMAGE_TAG}"
