# AI Blog SEO Automation (n8n + OnlineShop API)

Hybrid pipeline: **n8n orchestrates**, your **ASP.NET API** stores blogs as inactive drafts for human review.

No `ContentJob` table — run history lives in n8n Executions; published content lives in `Blogs`.

## Local test (recommended)

### 1) Start stack

```bash
# from repo root — put GROQ_API_KEY in .env (free)
docker compose -f docker-compose.dev.yml up -d
```

Open:

- Site: `http://localhost`
- API: `http://localhost:8080`
- n8n UI: `http://localhost:5678`

### 2) Import workflow

1. Open `http://localhost:5678`
2. **Workflows → Import from File**
3. Select `automation/n8n/ai-blog-seo-daily.workflow.json`

Flow:

`Cron → Login → Slugs → Keywords → Topic → LLM article → Validate → Thumbnail (LLM) → Create Draft Blog`

### 3) Wire LLM credential (free default: Groq)

On **Generate Article (LLM)** and **Suggest Thumbnail (LLM)**:

1. Header Auth credential
2. Name: `Authorization`
3. Value: `Bearer <your-groq-key>`

Free key: https://console.groq.com → API Keys

Defaults in root `.env`:

- `LLM_API_URL=https://api.groq.com/openai/v1/chat/completions`
- `LLM_MODEL=llama-3.3-70b-versatile`

### 4) Manual run

1. Open the workflow → **Test workflow**
2. Draft appears in admin blogs with `IsActive=false`
3. Approve by activating the blog: `PUT /api/Blogs/active` `{ "id": ..., "isActive": true }`

### 5) Backend service account (seeded)

| Field | Default |
|---|---|
| Email | `content-bot@onlineshop.local` |
| Password | `ContentBot@123` |
| Role | `ContentEditor` |

## What you must configure

| # | Item | Required? | Where |
|---|---|---|---|
| 1 | LLM key | Yes | `GROQ_API_KEY` in `.env` + Header Auth in n8n |
| 2 | Import workflow | Yes | n8n UI |
| 3 | Bot account | Auto | `CONTENT_BOT_*` / `ContentAutomation__*` in `.env` |
| 4 | Unsplash | Optional | `UNSPLASH_ACCESS_KEY` in `.env` |
| 5 | Human review | Yes | Admin → blogs → Active switch |

Each service loads root `.env` via compose `env_file`.

## Daily flow

1. Cron 08:00 Asia/Tehran
2. Login as ContentEditor
3. Avoid duplicate slugs
4. Pick topic
5. Generate article (LLM)
6. `POST /api/Blogs/validate-content`
7. Suggest + download thumbnail
8. `POST /api/Blogs` as draft (`IsDraft=true`, `Source=ai-pipeline`)
9. Human activates in admin

## Quality gates

- Unique slug
- Min intro/content/conclusion length
- FAQ heading
- Meta description 70–160
- Internal link to `/products/`, `/categories/`, or `/blog/`

## FAQ HTML contract

```html
<h2>سوالات متداول</h2>
<h3>سوال اول؟</h3>
<p>پاسخ اول</p>
```

## Human-like writing

Prompt reduces robotic tone. Still review every draft before publish.
