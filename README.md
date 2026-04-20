# StatusPage

A lightweight, single-page status dashboard for tracking short-duration migration events. Built with [Astro](https://astro.build/) and driven entirely by a single YAML configuration file.

Edit `src/data/migrations.yaml`, rebuild, and deploy — no database or backend required.

## Screenshots

### Light Mode

![Light mode screenshot](assets/image-light.png)

### Dark Mode

![Dark mode screenshot](assets/image-dark.png)

## Features

- Single YAML file drives all content — no database or backend
- Branded header with logo, company name, and configurable colors
- Top-of-page health banner (auto-computed or manually overridden)
- Summary metrics (activities, tasks, completion %, blocked count)
- Expandable activity cards with progress bars and task checklists
- Collapsible **Known Issues** section with severity pills, optional images, auto-linked URLs, and a count badge
- Timeline of updates in reverse-chronological order
- Configurable **support / help card** with email, phone, and arbitrary links
- Configurable footer text
- Light and dark mode support
- Fully static output — deploy anywhere

## Prerequisites

- **Node.js** 18.17.1 or later (Node 20+ recommended)
- **npm** (included with Node.js)

## Quick Start

```bash
# Install dependencies
npm install

# Start the dev server (http://localhost:4321)
npm run dev
```

The dev server hot-reloads changes to `src/data/migrations.yaml`.

## Building & Deploying

### Static Export (default)

By default the site builds to a static `dist/` folder that can be served by any web server or CDN.

```bash
# Build static files
npm run build

# Preview the build locally
npm run preview
```

The output in `dist/` is plain HTML, CSS, and JS — upload it to any static host:

| Host | Deploy method |
|---|---|
| **Nginx / Apache** | Copy `dist/` contents to the web root |
| **GitHub Pages** | Push `dist/` to the `gh-pages` branch or configure Actions |
| **Netlify / Vercel** | Set build command to `npm run build` and publish directory to `dist` |
| **S3 + CloudFront** | Use the [Terraform module](scripts/s3/terraform/) or [shell scripts](scripts/s3/) |

### S3 + CloudFront (Terraform)

A Terraform module under [`scripts/s3/terraform/`](scripts/s3/terraform/) provisions the full AWS stack:

- S3 bucket (public access blocked, served via CloudFront OAC)
- CloudFront distribution with HTTPS redirect
- Optional custom domain (ACM certificate with DNS validation)
- Optional AWS WAF with managed rule groups and CloudWatch logging
- Configurable geographic restrictions (defaults to US-only whitelist)

```bash
cd scripts/s3/terraform
terraform init
terraform apply -var="bucket_name=my-statuspage-bucket"
```

For quick manual deploys to an existing bucket, shell scripts are also available — see [`scripts/s3/`](scripts/s3/).

### Node.js Server (SSR)

To run as a Node.js server instead of a static site:

1. Install the Node adapter:

```bash
npm install @astrojs/node
```

2. Update `astro.config.mjs`:

```js
import { defineConfig } from 'astro/config';
import yaml from '@modyfi/vite-plugin-yaml';
import node from '@astrojs/node';

export default defineConfig({
  output: 'server',
  adapter: node({
    mode: 'standalone',
  }),
  vite: {
    plugins: [yaml()],
  },
});
```

3. Build and run:

```bash
npm run build
node dist/server/entry.mjs
```

The server starts on `http://localhost:4321` by default. Set the `PORT` and `HOST` environment variables to customize.

## Configuring `migrations.yaml`

All content is driven by a single file: **`src/data/migrations.yaml`**. After making changes, rebuild (or let the dev server hot-reload) to see updates.

### Full Schema

```yaml
# ── Branding ──────────────────────────────────────────────
branding:
  companyName: "Acme Corp"          # Displayed in the site header (leave "" to hide)
  logoUrl: /logo.png                # Path to logo in the public/ folder
  primaryColor: "#2563eb"           # Primary brand color (banner, accents)
  secondaryColor: "#fafafa"         # Secondary/background color

# ── Site Metadata ─────────────────────────────────────────
siteTitle: Migration Status
siteDescription: Track the progress of our platform migration activities.

# ── Banner override (optional) ────────────────────────────
# Any field you omit falls back to the auto-computed value derived
# from activity statuses. Remove the whole block to fully auto-compute.
banner:
  label: "Migrations In Progress"
  description: "Activities are actively being worked on."
  level: blue                       # green | blue | red | gray

# ── Known Issues (optional) ───────────────────────────────
knownIssuesHeading: "Known Issues"  # Optional custom heading
knownIssues:
  - title: "Holosuite 3 crashes mid-program"
    description: "Intermittent crashes during peak hours. See https://example.com for details."
    severity: major                 # critical | major | minor
    since: "2026-02-20"             # ISO date (optional)
    link: "https://example.com/ticket/42"
    linkLabel: "View Ticket"
    image: "/screenshots/crash.png"
    imageAlt: "Screenshot of crash dialog"

# ── Activities ────────────────────────────────────────────
activities:
  - id: unique-slug                 # Unique identifier for the activity
    name: Email Migration           # Display name
    description: Short summary of what this activity covers.
    status: in-progress             # not-started | in-progress | completed
    tasks:
      - name: Backup email systems  # Task display name
        status: completed           # not-started | in-progress | completed

# ── Updates (timeline) ───────────────────────────────────
updates:
  - date: "2026-02-20T14:30:00Z"   # ISO 8601 timestamp
    message: Description of what happened.

# ── Support / Help Card (optional) ────────────────────────
support:
  heading: "Need Help?"
  description: "Reach out to the team or check our docs."
  email: "ops@example.com"
  phone: "+1 555-0134"
  links:
    - label: "Runbook"
      url: "https://example.com/runbook"

# ── Footer (optional) ─────────────────────────────────────
footer: "© Acme Corp — Internal Use Only"
```

### Section Reference

#### `branding`

| Field | Type | Description |
|---|---|---|
| `companyName` | string | Company name shown in the header. Leave empty (`""`) to hide. |
| `logoUrl` | string | Path to a logo image placed in the `public/` directory. |
| `primaryColor` | string | Hex color used for the banner and accents. |
| `secondaryColor` | string | Hex color used for backgrounds. |

#### `siteTitle` / `siteDescription`

Top-level strings used for the page heading and the HTML `<meta>` description.

#### `banner` (optional)

Overrides the auto-computed health banner at the top of the page. Any field you omit falls back to the computed value (derived from activity statuses). Remove the block entirely to use full auto-compute.

| Field | Type | Description |
|---|---|---|
| `label` | string | Banner title text (e.g. "All Systems Operational"). |
| `description` | string | Sub-text shown next to the label. |
| `level` | string | One of: `green`, `blue`, `red`, `gray`. Controls the banner color. |

**Example:**

```yaml
banner:
  label: "Maintenance Window Tonight"
  description: "Expect brief outages between 10pm–12am UTC."
  level: red
```

#### `knownIssuesHeading` (optional)

String. Overrides the "Known Issues" section heading. Omit to use the default.

```yaml
knownIssuesHeading: "Open Incidents"
```

#### `knownIssues` (optional)

A list of current problems rendered as a collapsible section. The section auto-hides when the list is missing or empty. A red count badge on the collapsed header shows how many issues are open.

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | string | yes | Short issue summary shown on the card header. |
| `description` | string | no | Long-form description. URLs (`http://` / `https://`) are auto-linked. |
| `severity` | string | no | One of: `critical` (red), `major` (yellow), `minor` (gray). Controls the pill and left-border color. |
| `since` | string | no | ISO date (e.g. `"2026-02-20"`). Rendered as "Since Feb 20, 2026". |
| `link` | string | no | URL for a "More info" link shown below the description. |
| `linkLabel` | string | no | Label for the link. Defaults to "More info". |
| `image` | string | no | Root-relative path to an image in `public/` (e.g. `/screenshots/foo.png`). Rendered below the description. |
| `imageAlt` | string | no | Alt text for the image. |

**Example:**

```yaml
knownIssues:
  - title: "Payment gateway latency spikes"
    description: >-
      Intermittent 5–10s response times observed.
      See https://example.com/incident/42 for timeline.
    severity: critical
    since: "2026-04-15"
    link: "https://example.com/incident/42"
    linkLabel: "Incident Report"
    image: "/screenshots/latency-graph.png"
    imageAlt: "Graph showing latency spikes over the past 24 hours"
```

#### `activities`

Each activity represents a major workstream with its own progress bar and task checklist.

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Unique slug for the activity. |
| `name` | string | yes | Display name shown on the card. |
| `description` | string | yes | Short summary shown below the name. |
| `status` | string | yes | One of: `not-started`, `in-progress`, `completed`. |
| `tasks` | list | yes | Sub-tasks displayed as a checklist (see below). |

#### `tasks` (nested under each activity)

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | yes | Task display name. |
| `status` | string | yes | One of: `not-started`, `in-progress`, `completed`. |

The progress bar on each activity card is calculated automatically from the ratio of `completed` tasks to total tasks.

#### `updates`

A flat list of timeline entries displayed in reverse-chronological order.

| Field | Type | Required | Description |
|---|---|---|---|
| `date` | string | yes | ISO 8601 datetime string (e.g. `"2026-02-20T14:30:00Z"`). |
| `message` | string | yes | Free-text description of the update. |

#### `support` (optional)

Renders a "Need Help?" card after the timeline. Every field is optional — include only what you want to show. The card auto-hides if the entire block is omitted or empty.

| Field | Type | Description |
|---|---|---|
| `heading` | string | Card title. Defaults to "Need Help?". |
| `description` | string | Short intro paragraph. |
| `email` | string | Renders as a `mailto:` link. |
| `phone` | string | Renders as a `tel:` link. Non-digit characters are stripped from the link target. |
| `links` | list | List of `{ label, url }` objects rendered as a separate link row. |

**Example:**

```yaml
support:
  heading: "Need Help?"
  description: "Contact the migration team or check our docs."
  email: "ops@example.com"
  phone: "+1 555-0134"
  links:
    - label: "Runbook (PDF)"
      url: "/docs/runbook.pdf"
    - label: "Status History"
      url: "https://example.com/history"
```

#### `footer` (optional)

String. Renders a centered line of text at the bottom of the page. Omit the field (or leave it empty) to hide the footer entirely.

```yaml
footer: "© Acme Corp — Internal Use Only"
```

### Status Values

The following statuses are supported for activities and tasks. Each renders with a distinct color badge:

- **`not-started`** — work has not begun
- **`in-progress`** — actively being worked on
- **`completed`** — finished

### Severity Values (Known Issues)

- **`critical`** — red pill, red left border
- **`major`** — yellow pill, yellow left border
- **`minor`** — gray pill, gray left border

### Serving Static Assets (Images, PDFs, Logos)

Any file placed in the `public/` directory is copied verbatim into the root of `dist/` at build time. Reference these assets with **root-relative paths** (starting with `/`).

```
public/
  logo.png              → referenced as "/logo.png"
  screenshots/
    crash.png           → referenced as "/screenshots/crash.png"
  docs/
    runbook.pdf         → referenced as "/docs/runbook.pdf"
```

This works seamlessly with the S3 deploy script, which uses `aws s3 sync dist/ s3://bucket --delete` — all files end up in the bucket automatically.

> **Note:** the `--delete` flag means files in the bucket that aren't in `dist/` will be removed on deploy. Keep assets in `public/` (source-controlled) rather than uploading them directly to S3.

### YAML Gotchas

- **URLs with colons must be quoted.** YAML treats unquoted `:` as a key-value separator:
  ```yaml
  # ✗ breaks
  link: https://example.com

  # ✓ works
  link: "https://example.com"
  ```
- **Strings that mix single and double quotes** should use a block scalar (`>-` folds into one line, strips the trailing newline):
  ```yaml
  description: >-
    Homepage changed to 'https://default.com' — please update.
  ```
- The top-level keys `banner`, `knownIssues`, `knownIssuesHeading`, `support`, and `footer` are all **optional**. Omit any you don't use.

## Project Structure

```
src/
  components/
    ActivityCard.astro      # Expandable card per activity
    ActivityList.astro      # Container for all activity cards
    Banner.astro            # Top-of-page status banner (auto or override)
    HelpSection.astro       # Support / help card
    KnownIssues.astro       # Collapsible known-issues section
    ProgressBar.astro       # Visual progress indicator
    SiteHeader.astro        # Logo + company name header
    StatusBadge.astro       # Colored status pill
    SubTaskRow.astro        # Single task checklist row
    SummaryMetrics.astro    # High-level metrics section
    Timeline.astro          # Updates timeline container
    TimelineEvent.astro     # Single timeline entry
  data/
    migrations.yaml         # All configuration lives here
  layouts/
    BaseLayout.astro        # HTML shell, global styles
  pages/
    index.astro             # Main page (wires data to components)
  styles/
    global.css              # Theme variables (light/dark mode)
public/                     # Static assets served at site root (logos, PDFs, screenshots)
assets/                     # Repository assets (README screenshots)
scripts/
  s3/
    deploy.sh               # Bash deploy script
    deploy.ps1              # PowerShell deploy script
    terraform/              # Terraform module (S3 + CloudFront)
```

## License

Private — internal use only.
