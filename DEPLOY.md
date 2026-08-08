# Deploy guide

Two repositories:

| Repo | Role | Local path |
|---|---|---|
| [candyRose](https://github.com/hamidrezafallahi/candyRose) | Infra on VPS (`compose`, nginx, `deploy.sh`) | this repo |
| [OnlineShop-Compose](https://github.com/hamidrezafallahi/OnlineShop-Compose) | App source (`FrontEnd`, `BackEnd`) + **build/push images** | `C:\fallahi\onlineShop-Complex` |

## Happy path (production)

1. Push to `OnlineShop-Compose` `master` → GitHub Actions builds:
   - `hamidrezafalahi/shop-frontend:<git-sha>`
   - `hamidrezafalahi/shop-backend:<git-sha>`
2. Same workflow SSHs to the VPS and runs `/opt/shop/deploy.sh … <sha>`
3. Push to `candyRose` `master` (nginx/compose/…) → candyRose **Deploy to VPS** does `git pull` + `./deploy.sh nginx`

## On the VPS

Path: `/opt/shop` = clone of **candyRose** + `.env`

```bash
cd /opt/shop
./deploy.sh frontend <git-sha-from-OnlineShop-Compose>
./deploy.sh backend <git-sha-from-OnlineShop-Compose>
./deploy.sh all <git-sha-from-OnlineShop-Compose>
./deploy.sh nginx
./deploy.sh automation
```

## Secrets

### OnlineShop-Compose (app CI — primary)

| Secret | Purpose |
|---|---|
| `DOCKER_USERNAME` | Docker Hub |
| `DOCKERHUB_TOKEN` | Docker Hub |
| `VPS_HOST` | SSH deploy |
| `VPS_USER` | SSH deploy |
| `VPS_PORT` | SSH deploy |
| `SSH_PRIVATE_KEY` | SSH deploy |

### candyRose (infra CI)

| Secret | Purpose |
|---|---|
| `VPS_HOST` / `VPS_USER` / `VPS_PORT` / `SSH_PRIVATE_KEY` | Sync infra + nginx / manual image deploy |
| `DOCKER_USERNAME` / `DOCKERHUB_TOKEN` / `APP_REPO_TOKEN` | Only if you use optional `build-images.yml` |

### candyRose variable (optional build)

| Variable | Value |
|---|---|
| `APP_REPO` | `hamidrezafallahi/OnlineShop-Compose` |

## Workflows in candyRose

1. **Deploy to VPS** — infra sync / manual deploy by image tag / `repository_dispatch`
2. **Build images and request deploy** — optional; checks out `OnlineShop-Compose` and builds `FrontEnd` + `BackEnd` (same monorepo SHA)
