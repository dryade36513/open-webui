#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$ComposeFile = if ($env:COMPOSE_FILE) { $env:COMPOSE_FILE } else { "docker-compose.yml" }
$ImageName = if ($env:OPEN_WEBUI_IMAGE_NAME) { $env:OPEN_WEBUI_IMAGE_NAME } else { "open-web-ui" }
$ImageTag = if ($env:OPEN_WEBUI_IMAGE_TAG) { $env:OPEN_WEBUI_IMAGE_TAG } else { "local" }

if (-not (Test-Path -LiteralPath ".env") -and [string]::IsNullOrEmpty($env:WEBUI_SECRET_KEY)) {
    Write-Error "缺少 .env 或未設定環境變數 WEBUI_SECRET_KEY。請複製 deployment/compose.env.example 為 .env 並編輯，或先設定 WEBUI_SECRET_KEY。"
}

Write-Host "Building with $ComposeFile -> ${ImageName}:${ImageTag}"
docker compose -f $ComposeFile build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Done. 啟動: docker compose -f $ComposeFile up -d"
Write-Host "若要推送: docker push ${ImageName}:${ImageTag}"
