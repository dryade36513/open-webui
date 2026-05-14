# 自架 Docker（含 DigitalOcean Droplet）

建議使用 **Docker Compose v2.24+**（`env_file` 的 `required: false` 需要此版本以上；若版本較舊，請先建立 `.env` 再執行 compose）。

## 1. 本機或 CI 建置

專案根目錄：

```bash
cp deployment/compose.env.example .env
# 編輯 .env：至少設定 WEBUI_SECRET_KEY；若用 HTTPS stack 再設 WEBUI_DOMAIN、WEBUI_URL
```

**直連（對外開 8080）**

```bash
docker compose up -d --build
```

瀏覽器開 `http://<主機 IP>:8080`（或本機 `http://localhost:8080`）。

**HTTPS（Caddy 佔用 80/443，適合正式網域）**

1. 將網域 A 記錄指到 Droplet 公網 IP。
2. `.env` 設定：

   - `WEBUI_DOMAIN=你的網域`
   - `WEBUI_URL=https://你的網域`（須與瀏覽器網址一致）
   - `WEBUI_SECRET_KEY=…`

3. 啟動：

```bash
docker compose -f docker-compose.https.yml up -d --build
```

## 2. 資料保存在哪

SQLite、上傳檔、向量庫快取等皆在 **Docker volume** `open_webui_data`（對應容器內 `/app/backend/data`）。  
重建映像檔或更新版本時，只要沿用同一 volume，設定與對話會保留。

備份：

```bash
docker run --rm -v open_webui_data:/data -v $(pwd):/backup alpine tar cvf /backup/open-webui-data.tar /data
```

（volume 名稱若用 `OPEN_WEBUI_VOLUME_NAME` 自訂，請替換指令中的名稱。）

## 3. 推到 Registry 再在 Droplet 拉取

在開發機建置並標記後 push（需先 `docker login`）：

```bash
# .env 內設定 OPEN_WEBUI_IMAGE_NAME、OPEN_WEBUI_IMAGE_TAG，例如 myuser/open-webui 與 v1
docker compose build
docker push "${OPEN_WEBUI_IMAGE_NAME}:${OPEN_WEBUI_IMAGE_TAG}"
```

Droplet 上只放 `.env`、`docker-compose.yml`（或 `docker-compose.https.yml`）與 `deployment/Caddyfile`（HTTPS 時），將 compose 中的 `build:` 改成純 `image: ...` 或另建 override。較省事的做法：**在 Droplet 上 git clone 同一份 repo**，同樣 `docker compose up -d --build`（由原始碼在伺服器建置）。

## 4. DigitalOcean 防火牆

- 直連模式：開 `TCP 8080`（及 SSH 22）。
- HTTPS 模式：開 `TCP 80`、`TCP 443`（及 SSH 22）。

## 5. 便利腳本

- `scripts/docker-selfhost-build.sh`（Linux / macOS / WSL）
- `scripts/docker-selfhost-build.ps1`（Windows PowerShell）

可選參數：映像名稱、tag、compose 檔。
