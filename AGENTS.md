# AGENTS.md

A shared reservation calendar (Spanish UI, Liquid Glass aesthetic) for a family apartment in Chillán, Chile. Five families, each a fixed color.

## Stack (intentional, do not change)

- Vanilla JS, **no build step, no package.json, no bundler, no test runner, no linter**.
- Three files do everything: `index.html`, `styles.css`, `app.js`.
- One static asset: `assets/chillan-bg.jpg` (must ship with deploys).

Do not add a framework, bundler, or test framework. The "no build" property is deliberate — adding one would be wrong.

## Run / verify

```bash
cd "PLATAFORMAS CHILLAN"
python3 -m http.server 8000   # then open http://localhost:8000
```

**`file://` is broken** — the dynamic ES-module Supabase import and relative paths require http. There is no test/lint/typecheck command; "does it still work in the browser" is the only verification.

## Cache busting — bump both

When you change `app.js` or `styles.css`, bump **both**:
- `const VERSION` at the top of `app.js` (drives the badge in the footer).
- The `?v=N` query string in `index.html` on the matching `<link>` / `<script>` tag (forces browser refetch).

If you only bump one, the badge and the served asset disagree and users see stale code.

## Storage backend is chosen at runtime, not at build time

`CONFIG.supabaseUrl` and `CONFIG.supabaseAnonKey` at the top of `app.js`:
- **Both empty** → local mode (localStorage, this device only).
- **Both filled** → live mode (Supabase, realtime across devices).

`initStore()` builds `state.store` with the same `all() / add() / remove() / onChange()` interface in either mode. Everything else in the app calls only `state.store` and never knows which backend is active. **If you need a new persistence layer, add one branch in `initStore()` — nothing else needs to change.**

Live mode loads the Supabase client lazily via `await import("https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm")`, so local mode stays dependency-free. If CDN is blocked, the badge says "⚠ Modo local (no se pudo conectar a Supabase)" and the app keeps working on localStorage.

The anon key is **public by design** (RLS is wide-open in `schema.sql`). Privacy is the Supabase URL itself staying within the family — do not "fix" RLS without a replacement auth plan.

## Data model and how reservations are written

- One `reservations` table; see `schema.sql` for the canonical schema and RLS policies.
- A user can select **multiple families** for a single date range. `saveReservation()` inserts **one row per family** sharing the same dates + note — not one row with an array. The `family_id` column is a single text id, not an array.
- `end_date >= start_date` is enforced by a CHECK constraint.

## Render model

`render()` fully rebuilds `#grid` on every data or view change. It is cheap (one month). Do not try to do incremental DOM diffs.

Per cell, reservations overlapping that day are sorted by `CONFIG.families` index for stable lane order, drawn as `.seg` bars with `.start` / `.end` / `.pill` classes based on whether the day is the segment's first / last / both. `CONFIG.maxLanes` caps visible bars per cell, then shows `+N`.

## Configuration lives in `app.js`, not CSS

- `CONFIG.families` — ids, names, **colors**. Colors are applied inline from JS (`seg.style.background`, legend dots, swatches). Changing a family's color is a one-line edit in `CONFIG.families`, not a CSS edit.
- `CONFIG.weekStart` (1 = Mon), `yearMin` / `yearMax`, `maxLanes`, `airbnbMarginDays`.

CSS design tokens are custom properties under `:root` in `styles.css` (`--glass-bg`, `--round`, `--text`, …). The `.glass` / `.glass-soft` utilities carry the Liquid Glass look via `backdrop-filter`. The single responsive cutoff is `@media (max-width:560px)` that collapses segment labels.

UI strings are Spanish (`lang="es"`); `MONTHS`, `MON_SHORT`, `WD` arrays in `app.js` are the Spanish names — keep new strings Spanish too.

## Files that look load-bearing but aren't

- `ruvector.db` — unreferenced artifact, ignored. Do not wire it in.
- `oficial-nevados_…copy.jpg` — 17 MB source photo for editing. The background actually used is `assets/chillan-bg.jpg` (1.3 MB).
- `calendario.html` — gitignored local debug build. The canonical app is `index.html`. Do not edit it.

## Deploy

`README.md` documents the Cloudflare Pages + Cloudflare Access path (recommended) and the Netlify Drop shortcut (no auth). `npx vercel` also works. Make sure `assets/chillan-bg.jpg` ships with whichever output you use.
