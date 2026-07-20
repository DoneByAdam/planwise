# Planwise — Smart Retirement Planning

A mobile-first web app that plans all 26 biweekly paychecks: auto-caps at the IRS limit, tracks employer match (including match lost to front-loading), computes federal tax savings, compares strategies side by side, projects growth to retirement, and exports a PDF report.

**Try-before-signup:** the app is fully functional with no account — data saves to the device (localStorage). Creating an account syncs the plan to the cloud.









## v9 changes

- **Fixed: "try-it mode" banner stayed visible after signing in.** The sign-in code was correctly setting the banner's `hidden` attribute, but the banner's own CSS (`display:flex`) overrode the browser's default `[hidden] {display:none}` rule, so it rendered anyway. Added a global `[hidden]{display:none!important}` kill-switch so the `hidden` attribute always wins, for this and any future element. Present since v2; v8 inherited it — v9 resolves it.

## v8 changes

- **Multiple named, dated plans** — a plan switcher in the header opens "Your plans": create, open, rename, duplicate, and delete plans, each stamped with created/last-saved timestamps (shown on the dashboard and in the PDF header). Use cases: what-if runs, one plan per job, and keeping past years as history. Works signed-out (device storage) and syncs per-plan when signed in; client-side encryption still applies per plan. Existing single plans migrate automatically into the new store.
- **Multiple jobs note** — the plans modal and glossary remind users the 402(g) deferral limit is per person across all employers, not per job.
- **Contact / feedback** — a contact form (footer link + Home) writing to a new Supabase `feedback` table: insert-only for visitors (signed in or not), unreadable through the public API — you read messages in the Supabase dashboard (Table Editor → feedback). Includes a spam honeypot, optional reply email, and graceful fallbacks (GitHub issues link, optional mailto) when the backend isn't configured.
- **Database migration** — `schema.sql` is now fully re-runnable; running it again on an existing project drops the one-plan-per-user constraint and creates the feedback table. **Action needed: re-run schema.sql in the Supabase SQL editor.**

## v7 changes

- **State income tax (approximate)** — a state dropdown (no ZIP code, by design: state determines ~95% of income-tax variance and asks less of the user's privacy). All 50 states + DC live in `state-taxes.json` (flat/progressive/none, MFJ tables or doubled thresholds, standard deductions where notable), fetched fresh like the IRS file and clearly marked APPROXIMATE — verify against your state's revenue department and update annually.
- **Local income tax** — states with notable local taxes (NY, PA, OH, MD, IN, KY, MI, MO, AL, DE, OR) reveal an optional local-rate field with pay-stub guidance, instead of a locality database.
- **Wired everywhere**: state+local tax in take-home (pay schedule and scenarios, with a per-scenario "State + local tax" row), combined federal+state savings on the dashboard and PDF, state summary on the IRS-figures card.
- **State-aware coaching**: the Pennsylvania 401(k) quirk (no state deduction for pre-tax contributions, but withdrawals generally untaxed later), a "no state income tax" note for the nine no-tax states, and combined-savings math elsewhere. Correction from earlier docs: New Jersey *does* exempt 401(k) deferrals — its trap applies to 403(b)/457/IRA contributions.
- Deploy note: add `state-taxes.json` to the repo alongside the other files.

## v6 changes

- **Automatic (non-elective) employer contribution** — for plans that deposit a fixed % of salary regardless of employee contributions (e.g. "the company adds 3%"). Configure the % and which pay period it lands in. It flows through everywhere it should: the pay schedule ("Employer $" column now shows match + automatic), the 415(c) additions check, scenario comparisons, the retirement projection, a dashboard breakdown (match vs automatic), a coaching insight, and the PDF. It correctly does *not* affect taxable income or the employee 402(g) limit, and it's based on the salary in effect at the deposit pay period.

## v5 changes

- **Fixed the jumbled Overview** — a CSS class collision: the "?" glossary buttons use class `.info` (an 18px circle), and coaching insights of severity *info* also received class `info`, collapsing whole insight cards into 18px circles with overlapping overflow text. Insight severity classes are now namespaced (`kind-info` / `kind-good` / `kind-warn`).
- **Disclaimer everywhere** — a site-wide footer on every view, a note on the Home page, and a strengthened PDF footer: Planwise is for guidance and reference only, not tax/legal/investment advice; consult a tax professional or accountant.
- **Flexible bonus** — target bonus as a % of salary *or* a dollar amount (dollar wins if both are set), plus an "Actual bonus received" field that overrides the target once the real number is known. A coaching insight calls out when actual lands above or below target, and the PDF notes whether the bonus figure is target or actual.

## v4 changes

- Rebranded to **Planwise** with the official logo: transparent-background mark in the header, full logo on the home hero, and real PNG favicons (64/256 + Apple touch icon) extracted from the logo artwork.
- Saved plans migrate automatically from the old storage key.
- New asset files: `logo-mark.png`, `logo-full.png`, `favicon.png`, `favicon-256.png`, `apple-touch-icon.png` — deploy them alongside the app files.

## v3 changes

- **Bug fix — "Something went wrong rendering"**: two CDN script URLs pointed at versions that don't exist (verified against the npm registry), so the chart/PDF libraries failed to load and one shared try/catch killed every render. All CDN URLs are now version-and-path-verified on jsDelivr, chart creation degrades gracefully (a note appears instead of a crash if a chart can't load), and rendering is isolated per section so one failure can't take down the rest.
- **New flow**: Home (what the tool is + privacy promise: encrypted, never shared/sold) → Inputs → **Calculate my plan** button → Results. Result tabs show friendly empty states until the user calculates. A "See a sample plan" button gives instant try-before-you-type.
- **Validation**: Calculate checks every input and lists exactly what's missing or off in plain English (clickable — jumps to the field, which is highlighted in red). After the first calculation, edits re-validate live and re-render only when valid.
- Covered by an automated jsdom test suite (29 flow assertions + engine tests across all pay frequencies).

## v2 changes

- **Generic example data** — ships with a simple starter profile ($85,000 salary, 6% pre-tax, 50%-of-6% match, no bonus). No personal numbers anywhere. Existing saved plans migrate automatically.
- **Pay frequency** — weekly (52), every two weeks (26), 1st & 15th (24), or monthly (12). The engine, pay strip, tables, scenarios, and PDF all adapt; annual totals are frequency-independent (verified by tests).
- **Education layer** — a glossary of 18 beginner-friendly explainers opens from "?" buttons next to every stat and input, plus a "Two-minute lessons" card row on the dashboard (match, SS wage-base cutoff, mega backdoor, Roth vs pre-tax, true-up trap, compounding, 4% rule, catch-up).
- **Dark fintech redesign** — deep navy canvas with ambient gradient glows, glass cards, glowing mint data accents, dark-mode charts (donut for limit usage, gradient-filled projection line, rounded scenario bars).

## Files

| File | Purpose |
|---|---|
| `index.html` | App shell, favicon (inline SVG), mobile-first layout |
| `styles.css` | Design system (ink navy / ledger green, Bricolage Grotesque + Inter + IBM Plex Mono) |
| `app.js` | Calculation engine + UI + auth + encryption + PDF |
| `irs-limits.json` | Annual IRS/SSA figures (see "IRS data" below) |
| `schema.sql` | Supabase database schema with Row Level Security |

## Quick start (no backend)

Push the folder to a GitHub repo and enable GitHub Pages — same workflow as ClearDebt. The app runs in device-only mode: everything works, the "Sign in" flow explains that accounts aren't configured yet.

## Enabling accounts + database (Supabase, ~10 minutes, free tier)

1. Create a project at supabase.com (choose a strong database password; region near your users).
2. In the dashboard: **SQL Editor → New query**, paste the contents of `schema.sql`, **Run**. This creates the `plans` table with Row Level Security so each user can only read/write their own row.
3. **Project Settings → API**: copy the **Project URL** and the **anon public** key.
4. Paste both into the `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants at the top of `app.js`.
5. **Authentication → Providers → Email**: enabled by default. For a smoother demo you can turn off "Confirm email" (turn it back on for production).
6. Redeploy. The Sign in / Create account flow is now live.

The anon key is safe to ship in frontend code — it only grants what RLS policies allow.

## How the data is protected

Three layers:

1. **Transport**: all traffic is TLS (GitHub Pages and Supabase are HTTPS-only).
2. **At rest**: Supabase encrypts the Postgres volume with AES-256; Row Level Security means even a bug in the app's queries can't expose another user's rows.
3. **Zero-knowledge option**: if the user sets an encryption passphrase at signup, the plan is encrypted **in the browser** with AES-256-GCM (key derived via PBKDF2, 210,000 iterations of SHA-256, random salt + IV per save) before upload. The server stores only ciphertext. Trade-off: **a lost passphrase means unrecoverable data** — the UI says so explicitly.

Never put the `service_role` key in frontend code.

## IRS data: "automatic" updates, honestly

The IRS has **no official API** for contribution limits or brackets. The pattern that actually works:

- `irs-limits.json` holds every year's figures. The app fetches it fresh on every load (`cache: 'no-store'`), so **you update one file, every user gets it** — no code changes, no redeploy of logic.
- Each November, when the IRS publishes its COLA notice and SSA publishes the wage base, add a new year block to the JSON (copy the previous year and edit ~12 numbers). Sources: irs.gov (news release "401(k) limit increases..."), ssa.gov (contribution & benefit base), and the annual Revenue Procedure for brackets/standard deduction.
- If the fetch fails (offline), the app falls back to figures embedded in `app.js`.

Optional upgrade: point the fetch at `https://raw.githubusercontent.com/<you>/<repo>/main/irs-limits.json` so a single commit updates all deployments, or wire a scheduled GitHub Action that opens a PR reminder each November 1.

## Notes on the coaching content

The "Coaching corner" insights are rules-of-thumb from widely published guidance: Fidelity's 15% savings-rate guideline and age-based milestones (1× salary by 30 → 10× by 67), the universal "capture the full match first" advice, marginal-bracket framing for Roth vs. traditional, mega-backdoor mechanics, and SECURE 2.0's 2026 Roth catch-up mandate for high earners. I can't browse the web, so I've named sources rather than deep-linking — verify the exact Fidelity Viewpoints URLs before publishing, and keep the "education, not advice" disclaimer visible.

## Verification

The JS engine was tested against the Excel model (which was itself verified against an independent calculation): total gross, capped deferrals, match, Social Security cutoff, federal tax, scenario capping periods, front-load match loss, catch-up limits, and true-up behavior all reproduce to the cent.

## Ideas for v2

- Multiple named plans per account (drop the unique index in `schema.sql`)
- Household mode (two earners, MFJ optimization)
- State income tax tables
- HSA module alongside the 401(k)
- Email a PDF report via Supabase Edge Function
