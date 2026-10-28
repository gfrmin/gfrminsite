# Site context: gfrm.in

## Run

- **Working directory**: repo root
- **Command**: `hugo server -p 1313 --disableLiveReload` (published pages only; add `-D` to include drafts)
- **Port / health**: 1313; `curl -sf http://localhost:1313/ -o /dev/null`
- **Env / fixtures**: none. Static site; no secrets are needed to build.
- **Local data**: none needed. All content is in `content/`, and chart data is in each post bundle (`night.json`, `charts.json`).
- **Prod fallback**: https://gfrm.in, read-only GETs. Use it when checking that a deploy matches, or the Cloudflare cache. Purge after any deploy.
- **Never run**: `git push` to master (the branch is protected; go through a PR); anything that edits or deletes the `velotix-*` posts.

## Base URLs and locales

| locale | path prefix | lang / dir | notes |
|---|---|---|---|
| en | `/` | `en` / `ltr` | default |
| he | `/he/` | `he` / `rtl` | RTL is scoped to `.rtl-content`, never `<html dir>`; nav and footer get `direction: rtl` from `html:lang(he)` |

## Routes to sample

- **How to get real ids**: `ls content/posts/`; for a Hebrew route, the slug must have an `index.he.md`
- **Routes** (this round: the election posts):
  `/posts/election-2026-polling-place-by-polling-place/`, `/he/posts/election-2026-polling-place-by-polling-place/`,
  `/posts/election-night-station-by-station/`, `/he/posts/election-night-station-by-station/`,
  `/posts/` and `/he/posts/` (listings), `/posts/no-such-post/` (must 404; check with curl)
- **Dated routes**: none in the URL sense. Both election posts describe a count that was still running, so their numbers change only by a new commit.

## Route enumeration (journey traceability)

`hugo list all | cut -d, -f1,9` (path and permalink). Blind spot: taxonomy and term pages are not listed.

## UX paths

- **DESIGN.md**: none yet. Use the CLAUDE.md sections "The design system: Ink & ochre" and "Templates & styling" meanwhile.
- **Ledger**: `.claude/ux/findings.yaml`
- **Journeys**: `.claude/ux/journeys/`; this site's `surface` value is `gfrm.in`
- **Gate test**: none yet. A static site with no test suite, so the gate would be a CI step.
- **Committed crops**: none (public repo; crops stay in the scratchpad)
- **Signals reader**: `scripts/posthog-report.sh`, PostHog project **320861** (not the keyring's `POSTHOG_PROJECT_ID`). Events: `post_progress {depth, slug}`, `outbound_click {href}`, `lang_switch`, `share_click`, with `site_lang` on every event.

## Tests

- **Command**: `hugo --minify` (what CI runs; pinned to Hugo 0.165.0)
- **Skip ceiling**: n/a

## Constraints

- Public repo. Never quote or crop the Velotix posts, and never touch `velotix-the-letter` (draft, legal).
- Analytics carry no free text; session replay and surveys are off.

## Lenses

- **Two posts, two audiences**: `election-2026-polling-place-by-polling-place` is the results post for a general reader (what changed, where); `election-night-station-by-station` is the modelling post (why the live projection failed). Each journey names its post in a top-level `post:` key; judge each page only against its own post's journeys, plus `wrong-door`, which checks that each post sends the other's reader across. The titles are close in both languages, so wayfinding between them is in scope.
- **Stack**: Hugo templates, one stylesheet (`assets/css/main.css`), no JS framework. The only JS is search, dark mode, analytics and the read-depth listener. Charts are HTML and CSS (`stat-chart`, `election-night-table` shortcodes) with no SVG library. Math is MathML.
- **Direction / locales**: EN and HE must give the same answer. Every number, table and chart in the Hebrew post must match the English. Check bidi on ranges ("24–30"), arrows (→ / ←), minus signs and bloc triples ("54 / 47 / 19"); read `textContent` before calling anything reversed.
- **Dataviz**: blocs are always Netanyahu / change / Arab in that order. The threshold is 3.25%. 120 seats, majority 61. Projections are labelled as projections, and their 90% ranges as too narrow. A "counted so far" figure is never a projection.
- **Data correctness**: all times are Israel time (UTC+2 in late October 2026). The posts' data is preliminary (election-night files and the 10:02 file of 28 Oct); every first screen must say so.

## Live controls

| finding id | check | route | viewport | fixed by |
|---|---|---|---|---|
| 16a9ae00d2 | first-screen | /posts/election-night-station-by-station/ | 360 | PR 1 top signpost (must go silent only once it lands) |
