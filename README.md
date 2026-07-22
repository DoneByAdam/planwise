# Planwize — Smart Retirement Planning

A mobile-first web app that turns a salary and pay schedule into a full-year 401(k) plan: paycheck-by-paycheck contributions auto-capped at the IRS limit, employer match and automatic contributions (including match lost to front-loading), federal plus approximate state/local tax, side-by-side strategy simulations, compounding projections, PDF reports, and named/dated plans for what-ifs, multiple jobs, and year-over-year history.

Live stack: static frontend (GitHub Pages) + Supabase (auth, Postgres with Row Level Security, feedback inbox).

## Verifying what's deployed

The footer of every page shows the running version (e.g. "Planwize v9.3"). If the live site doesn't match the version you pushed: check that GitHub Pages serves the branch you pushed to (Settings → Pages), that you're visiting the current URL (renaming the repo changes the Pages address), and hard-refresh / clear site data to defeat mobile caching.

## Files

| File | Purpose |
|---|---|
| `index.html` | App shell, views, modals, PNG favicons |
| `styles.css` | Dark fintech design system |
| `app.js` | Engine + UI + plans + auth + encryption + PDF + feedback (Supabase config at top) |
| `irs-limits.json` | Annual IRS/SSA figures — update each November |
| `state-taxes.json` | Approximate state income tax data (50 states + DC) — verify and update annually |
| `schema.sql` | Supabase schema: plans (multi-plan, RLS) + feedback (insert-only). Safe to re-run. |
| `logo-*.png`, `favicon*.png`, `apple-touch-icon.png` | Planwize brand assets |

## Deploying

Push everything to the repo root and enable GitHub Pages. The Supabase URL and anon public key live at the top of `app.js` (the anon key is designed to ship in frontend code; RLS protects all data — never expose the `service_role` key). Database setup or upgrades: paste `schema.sql` into the Supabase SQL Editor and Run; the script is idempotent.

## How the data is protected

TLS in transit; AES-256 at rest; Row Level Security so users can only ever read/write their own plans; and an optional zero-knowledge passphrase that encrypts plan data in the browser (AES-256-GCM, PBKDF2 210k iterations) before upload — a lost passphrase means unrecoverable data, and the UI says so.

## Annual maintenance checklist (each November–January)

1. `irs-limits.json`: add the new year block — 402(g), catch-ups, 415(c), comp limit, SS wage base, standard deductions, federal brackets. Sources: irs.gov COLA news release, the annual Revenue Procedure, ssa.gov.
2. `state-taxes.json`: refresh rates/brackets against state revenue departments. All state figures are approximations by design (no credits/exemptions modeled).
3. Commit — the app fetches both files fresh on every load, so one push updates every user.

## Feedback inbox

The in-app contact form writes to the `feedback` table (insert-only through the public API). Read messages in Supabase → Table Editor → feedback. Fallback when the backend is unreachable: the app links to https://github.com/DoneByAdam/Planwize/issues.

## Notes on coaching content

Insights are rules-of-thumb from widely published guidance (Fidelity 15% savings-rate guideline and age milestones, match-first ordering, marginal-bracket Roth framing, mega-backdoor mechanics, SECURE 2.0 Roth catch-up mandate, the Pennsylvania 401(k) quirk). Sources are named rather than deep-linked — verify exact URLs before adding links, and keep the "guidance, not advice" disclaimers visible.

## Testing

The calculation engine and UI flows are covered by automated tests (Node + jsdom): pay frequencies, IRS capping, bonus target/actual precedence, employer contributions, state tax hand-checks (CA/PA/NJ/TX), plan migration and CRUD, validation, gating, chart-failure fallbacks, the deliberate-save flow, and password reset.

## Changelog

### v12
- **Fixed: a new plan appeared on every login.** Root cause: the app always guaranteed *some* plan existed by silently creating one (named from "current year + 1", hence "2027 plan"), and signing in pushed that phantom plan to the cloud. Persistence is now split between an in-progress **draft** (device-only, never synced, never listed) and a **saved plan** (named, dated, appears in My Plans, synced when signed in). Nothing is saved or named unless the person deliberately chooses to.
- **Deliberate save flow**: the button is now **Generate my plan** (was Calculate). Generating computes and shows results but saves nothing. A dismissible banner then offers **Save my plan** — naming happens at that moment, never before.
- **"Plans" renamed to "My Plans"** everywhere, so it reads as personal simulations, not a purchasable package.
- **My Plans moved to the end of the navigation** (after Grow) on both desktop and mobile.
- **Header plan control is now a real dropdown** listing every saved plan for one-tap switching, plus a separate "My Plans" button for full management.
- **Fixed the floating Generate button** — it used `position:sticky`, which on some layouts rendered as an overlay on top of not-yet-completed form fields. It's now a static block at the true end of the form, visible only once someone has scrolled through everything.
- **Password reset added** (previously missing entirely): a "Forgot password?" link on the sign-in tab triggers Supabase's reset email; the returning link is detected via a `PASSWORD_RECOVERY` auth event and prompts for a new password.

### v11
- **Complete rename to Planwize**, including internal storage keys this time (`planwise.plans` → `planwize.plans`, etc.), now that the tool is pre-launch. A one-time migration moves any existing local data across automatically; nothing is lost.
- **Live domain wired in**: canonical URL, Open Graph, and Twitter Card meta tags point to `https://myplanwize.com/`. GitHub issues link updated to the renamed `planwize` repo.
- **Launch-readiness files**: `robots.txt` and a minimal `sitemap.xml`.
- No Supabase schema changes were needed for this rename — table names never contained the brand name.

### v10
- **Renamed Planwise → Planwize** across all user-facing text, titles, PDF filenames, and UI strings. The home hero's wordmark became live text instead of a raster image (the old logo file had "PLANWISE" baked into its pixels), so the brand name can never drift from the code again.
- **New About & Security page** — differentiators, the full security architecture (TLS, at-rest encryption, RLS, optional zero-knowledge encryption), who's behind the tool, and the disclaimer.
- **Data export & delete-all** added to the About/Security page: a plain-JSON export of every saved plan, and a delete-all-plans control.

### v9 and earlier
Renamed from MaxOut to Planwise; fixed a CSS class collision that broke the Coaching Corner layout; added flexible bonus handling (target % or $, plus an actual-bonus override); added automatic (non-elective) employer contributions; added state + local income tax (all 50 states + DC, approximate); added multiple named/dated plans with cloud sync; added a feedback/contact form; fixed a `[hidden]` CSS override bug that kept the try-it banner visible after sign-in.
