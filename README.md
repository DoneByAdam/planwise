# Planwise — Smart Retirement Planning

A mobile-first web app that turns a salary and pay schedule into a full-year 401(k) plan: paycheck-by-paycheck contributions auto-capped at the IRS limit, employer match and automatic contributions (including match lost to front-loading), federal plus approximate state/local tax, side-by-side strategy simulations, compounding projections, PDF reports, and named/dated plans for what-ifs, multiple jobs, and year-over-year history.

Live stack: static frontend (GitHub Pages) + Supabase (auth, Postgres with Row Level Security, feedback inbox).

## Verifying what's deployed

The footer of every page shows the running version (e.g. "Planwise v9.3"). If the live site doesn't match the version you pushed: check that GitHub Pages serves the branch you pushed to (Settings → Pages), that you're visiting the current URL (renaming the repo changes the Pages address), and hard-refresh / clear site data to defeat mobile caching.

## Files

| File | Purpose |
|---|---|
| `index.html` | App shell, views, modals, PNG favicons |
| `styles.css` | Dark fintech design system |
| `app.js` | Engine + UI + plans + auth + encryption + PDF + feedback (Supabase config at top) |
| `irs-limits.json` | Annual IRS/SSA figures — update each November |
| `state-taxes.json` | Approximate state income tax data (50 states + DC) — verify and update annually |
| `schema.sql` | Supabase schema: plans (multi-plan, RLS) + feedback (insert-only). Safe to re-run. |
| `logo-*.png`, `favicon*.png`, `apple-touch-icon.png` | Planwise brand assets |

## Deploying

Push everything to the repo root and enable GitHub Pages. The Supabase URL and anon public key live at the top of `app.js` (the anon key is designed to ship in frontend code; RLS protects all data — never expose the `service_role` key). Database setup or upgrades: paste `schema.sql` into the Supabase SQL Editor and Run; the script is idempotent.

## How the data is protected

TLS in transit; AES-256 at rest; Row Level Security so users can only ever read/write their own plans; and an optional zero-knowledge passphrase that encrypts plan data in the browser (AES-256-GCM, PBKDF2 210k iterations) before upload — a lost passphrase means unrecoverable data, and the UI says so.

## Annual maintenance checklist (each November–January)

1. `irs-limits.json`: add the new year block — 402(g), catch-ups, 415(c), comp limit, SS wage base, standard deductions, federal brackets. Sources: irs.gov COLA news release, the annual Revenue Procedure, ssa.gov.
2. `state-taxes.json`: refresh rates/brackets against state revenue departments. All state figures are approximations by design (no credits/exemptions modeled).
3. Commit — the app fetches both files fresh on every load, so one push updates every user.

## Feedback inbox

The in-app contact form writes to the `feedback` table (insert-only through the public API). Read messages in Supabase → Table Editor → feedback. Fallback when the backend is unreachable: the app links to https://github.com/DoneByAdam/Planwise/issues.

## Notes on coaching content

Insights are rules-of-thumb from widely published guidance (Fidelity 15% savings-rate guideline and age milestones, match-first ordering, marginal-bracket Roth framing, mega-backdoor mechanics, SECURE 2.0 Roth catch-up mandate, the Pennsylvania 401(k) quirk). Sources are named rather than deep-linked — verify exact URLs before adding links, and keep the "guidance, not advice" disclaimers visible.

## Testing

The calculation engine and UI flows are covered by automated tests (Node + jsdom): pay frequencies, IRS capping, bonus target/actual precedence, employer contributions, state tax hand-checks (CA/PA/NJ/TX), plan migration and CRUD, validation, gating, and chart-failure fallbacks.
