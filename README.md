# Focus Group Simulator

A Rails 8 application that simulates focus group research using LLMs (Anthropic Claude, OpenAI GPT and others via `ruby_llm`). Bachelor's thesis project.

## Requirements

- Docker Desktop (tested on Windows 11)
- Git
- API key for at least one LLM provider (Anthropic / OpenAI / ...)

You do not need to install Ruby or Postgres locally — everything runs in containers.

## First-time setup

```powershell
git clone <repo>
cd symulator-grup-fokusowych

copy .env.example .env
# Open .env and fill in at least ANTHROPIC_API_KEY

docker compose up -d --build
docker compose exec web bundle exec rails db:create db:migrate db:seed
```

The app is available at **http://localhost:3000**. Seeded account: `dev@example.com` / `password`.

## Day-to-day usage

```powershell
docker compose up -d        # start (web + sidekiq + db + redis + tailwind watcher)
docker compose ps           # container status
docker compose logs -f web  # server logs
docker compose down         # stop (volume data is preserved)
```

Hot reload works — host files are mounted as a volume at `/rails`.

## Common commands

> **Note:** `bin/rails` has a `#!/usr/bin/env ruby.exe` shebang (Windows) that will not work inside the Linux container. Inside the container always use **`bundle exec rails ...`**, not `bin/rails ...`.

```powershell
# Migrations
docker compose exec web bundle exec rails db:migrate

# Rollback
docker compose exec web bundle exec rails db:rollback

# Reset the database (WARNING: wipes data)
docker compose exec web bundle exec rails db:drop db:create db:migrate db:seed

# Rails console
docker compose exec web bundle exec rails console

# Ad-hoc runner (e.g. a spike script)
docker compose exec web bundle exec rails runner tmp/script.rb

# Generator (model / migration / ...)
docker compose exec web bundle exec rails g model Foo bar:string
```

## Tests

```powershell
# Full suite
docker compose exec -e RAILS_ENV=test web bundle exec rspec

# Specific file
docker compose exec -e RAILS_ENV=test web bundle exec rspec spec/models/persona_spec.rb

# Specific example
docker compose exec -e RAILS_ENV=test web bundle exec rspec spec/models/persona_spec.rb:42
```

`RAILS_ENV=test` is required — without it the container defaults to `RAILS_ENV=development` (set in `Dockerfile.dev`) and RSpec ends up running against the development database.

Test convention: `describe`, `context`, `it`, `let` in English; Polish only for test data (prompt content, persona names, etc.).

## Sidekiq (background jobs)

Sidekiq runs as a separate `sidekiq` container. Logs:

```powershell
docker compose logs -f sidekiq
```

Jobs (including `GeneratePersonasJob`, `RoundDeliberationJob`, `ChairmanSynthesisJob`) are enqueued on the default queue.

## Troubleshooting

**`docker compose up` fails to build after `Gemfile` changes:**

```powershell
docker compose build --no-cache web
docker compose up -d
```

**Postgres "database does not exist":**

```powershell
docker compose exec web bundle exec rails db:create db:migrate
```

**Port 3000 / 5432 / 6379 already in use:** stop local instances (Rails / Postgres / Redis) or change the port mappings in `docker-compose.yml`.

**API key rejected by provider:** check `docker compose exec web env | grep API_KEY`. `.env` is loaded at `up` time — if you added the key after the stack was started, run `docker compose restart web sidekiq`.

## Project structure

- `app/services/llm_client.rb` — thin wrapper over `ruby_llm` (model -> provider mapping)
- `app/services/persona_generators/` — persona generation strategies (two-pass refine with few-shot examples)
- `app/jobs/` — pipeline: personas -> round deliberation -> chairman synthesis
- `app/llm_schemas/` — JSON schemas for structured LLM output
- `docs/` — UML diagrams, notes

## Production

A separate production `Dockerfile` (distinct from `Dockerfile.dev`) is prepared for Kamal deployments. Deployment is out of scope for this document.
