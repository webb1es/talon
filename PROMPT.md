# Talon™ POS — Project Spec

> Single source of truth for building Talon™. Coding rules are in `CLAUDE.md`.
> Mark tasks `[x]` when complete.

Talon™ is an offline-first, multi-store POS system. Flutter + Supabase. One codebase for mobile, web, and desktop. Backend-agnostic — designed to swap Supabase for Go/Java/anything without touching UI or business logic.

**Tagline:** "Strike fast. Track everything."

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (mobile, web, desktop) |
| Backend | Supabase (PostgreSQL + Realtime + Auth + RLS + Edge Functions) |
| Local DB | Drift (SQLite) — type-safe, mirrors Postgres schema |
| State | flutter_bloc / Cubit |
| DI | get_it + injectable |
| Models | freezed + json_serializable |
| Fonts | google_fonts (Montserrat, Inter, JetBrains Mono) |
| Routing | GoRouter |
| Testing | bloc_test, mocktail, integration_test |

## Architecture

Clean Architecture (3-layer). Dependency flows inward: `Presentation → Domain ← Data`

| Layer | Responsibility | Depends on |
|-------|---------------|-----------|
| Presentation | Widgets, screens, Blocs/Cubits | Domain only |
| Domain | Entities, repository contracts (abstract), use cases | Nothing — pure Dart |
| Data | Repository impls, DTOs, Supabase, Drift DAOs | Domain contracts |

**Backend swap:** Domain defines abstract repos. Data implements them. DI wires them. Change one registration to swap backends. UI and business logic untouched.

## Data Architecture

### Storage

| Layer | Tech | Role |
|-------|------|------|
| Cloud | Supabase PostgreSQL | Source of truth, multi-store sync, RLS |
| Local | Drift (SQLite) | Offline-first, local queries, cache |
| Queue | Drift table `sync_queue` | Pending mutations when offline |

### Sync Strategy

- **Online write:** Local DB + sync_queue → push to Supabase → confirm → dequeue
- **Online read:** Supabase Realtime → update local DB → UI refreshes
- **Offline write:** Local DB + sync_queue (pending)
- **Offline read:** Local DB only
- **Reconnection:** Drain queue FIFO → pull server state → reconcile

### Sync Queue Schema

| Field | Type |
|-------|------|
| id | auto-increment PK |
| entity_type | string (product, transaction, inventory) |
| entity_id | UUID |
| action | enum: create, update, delete |
| payload | JSON (full entity snapshot) |
| created_at | timestamp (FIFO ordering) |
| retry_count | int (default 0) |
| status | enum: pending, processing, failed |

Processing: FIFO by created_at. Exponential backoff (2s, 4s, 8s, 16s, max 60s). Max 5 retries, then mark failed for admin review.

### Conflict Resolution

| Data Type | Strategy | Reason |
|-----------|----------|--------|
| Sales/transactions | Append-only, no conflict | A sale is a fact. Never overwritten. |
| Inventory quantities | Server-reconciled deltas | Both stores' sales apply. Manual adjustments use last-write-wins. |
| Product catalog | Last-write-wins (timestamp) | Low contention. |
| Settings | Last-write-wins (timestamp) | Admin authority. |

### Database Tables

`stores, users, roles, permissions` · `products, product_variants, categories` · `inventory (store_id, product_id, qty)` · `transactions, transaction_items (immutable)` · `sync_queue`

All tables include `store_id` for multi-tenancy. Supabase RLS enforces store-level access. Local Drift DB mirrors this schema.

## Project Structure

```
lib/
├── core/
│   ├── di/                     # get_it + injectable setup
│   ├── theme/                  # app_theme.dart, theme_cubit.dart, extensions
│   ├── constants/              # app_spacing.dart, app_strings.dart
│   ├── network/                # sync_engine.dart
│   └── error/                  # failures.dart
├── domain/
│   ├── entities/               # Pure Dart models
│   ├── repositories/           # Abstract contracts
│   └── usecases/               # Business logic
├── data/
│   ├── datasources/remote/     # Supabase implementations
│   ├── datasources/local/      # Drift implementations
│   ├── repositories/           # Implements domain contracts
│   ├── models/                 # DTOs
│   └── drift/                  # DB definition, DAOs
├── presentation/
│   ├── common/                 # Shared widgets (buttons, cards, inputs, alerts)
│   ├── pos/                    # POS terminal (bloc/, screens/, widgets/)
│   ├── inventory/
│   ├── reports/
│   ├── customers/
│   ├── settings/
│   ├── auth/
│   └── landing/                # Marketing landing page + one-pager
└── main.dart
```

## Responsiveness

Breakpoints: **mobile** <600px · **tablet** 600–1024px · **desktop** >1024px

| Element | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| Navigation | Bottom nav | Rail | Side drawer |
| POS terminal | Single column | Split panel | Split panel |
| Data tables | Card/list view | Full table | Full table |
| Dialogs | Fullscreen | Centered modal | Centered modal |
| Typography | Mobile scale | Desktop scale | Desktop scale |

- Use LayoutBuilder/MediaQuery — never hardcode widths
- Touch targets: 48×48px minimum on all platforms
- Test at 360px, 768px, 1440px

## Accessibility

WCAG 2.1 AA minimum. All 6 theme variations must independently pass.

- Semantics labels on all interactive elements
- Contrast: 4.5:1 text, 3:1 large text — per theme variation
- Form fields need labels, not just placeholders
- No info conveyed by color alone (icons + text alongside)
- Keyboard navigation on web/desktop
- Support system font scaling to 200%

---

## Brand Identity

> Single source of truth. Implement directly from these values.

### Core

**Name:** Talon™ (™ on first mention per screen, omit after)
**Tagline:** "Strike fast. Track everything."
**Personality:** Sharp, Confident, Streamlined, Trustworthy, Fast, In Control

### Theme Colors (3 themes × light/dark = 6 variations)

**Predator (Default)**

| Token | Light | Dark |
|-------|-------|------|
| Primary | `#E67E22` | `#F39C12` |
| Background | `#FFFFFF` | `#1A1A1A` |
| Surface | `#F8F9FA` | `#2D2D2D` |
| Text Primary | `#212529` | `#FFFFFF` |
| Text Secondary | `#6C757D` | `#ADB5BD` |
| Border | `#DEE2E6` | `#404040` |

**Precision**

| Token | Light | Dark |
|-------|-------|------|
| Primary | `#0A5C5C` | `#14B8A6` |
| Background | `#FFFFFF` | `#0F172A` |
| Surface | `#F8FAFC` | `#1E293B` |
| Text Primary | `#0F172A` | `#F8FAFC` |
| Text Secondary | `#475569` | `#94A3B8` |
| Border | `#E2E8F0` | `#334155` |

**Strike**

| Token | Light | Dark |
|-------|-------|------|
| Primary | `#C2410C` | `#F97316` |
| Background | `#FFFFFF` | `#030712` |
| Surface | `#F9FAFB` | `#111827` |
| Text Primary | `#030712` | `#F9FAFB` |
| Text Secondary | `#4B5563` | `#9CA3AF` |
| Border | `#E5E7EB` | `#1F2937` |

**Semantic Colors (all themes)**

| Type | Light | Dark |
|------|-------|------|
| Success | `#2E7D32` | `#4CAF50` |
| Warning | `#ED6C02` | `#FF9800` |
| Error | `#D32F2F` | `#F44336` |
| Info | `#0288D1` | `#29B6F6` |

### Typography

**Fonts:** Headlines = Montserrat (700, 600) · Body = Inter (400, 500, 600) · Monospace = JetBrains Mono (400, 500) for SKUs, barcodes, inventory numbers

**Desktop sizes:**
H1: 48px/700 · H2: 32px/700 · H3: 24px/600 · H4: 20px/600 · Body Large: 18px/400 · Body: 16px/400 · Body Small: 14px/400 · Caption: 12px/500/UPPERCASE · Button: 16px/600

**Mobile sizes:**
H1: 32px · H2: 24px · H3: 20px · Body: 16px · Small: 14px

### Brand Voice

| Event | Predator (Serious) | Precision (Calm) | Strike (Energetic) |
|-------|-------------------|------------------|-------------------|
| Sale complete | "Secured." | "Verified." | "Done." |
| Error | "Halt. [reason]" | "Exception: [reason]" | "Miss. Try again." |
| Low stock | "Grip low: [x] left" | "Threshold reached: [x]" | "Running low: [x]" |
| Welcome | "Ready. Set. Strike." | "System ready." | "Let's go." |
| Loading | "Gripping data..." | "Calibrating..." | "Loading fast..." |

### Components

**Buttons:** Standard 48px height, 24px 32px padding, 4px radius. Small 36px height, 16px 24px padding.
- Primary: bg = theme primary, text = white
- Secondary: 1px border theme primary, text = theme primary
- Tertiary: text = theme text_primary, underline on hover

**Cards:** 24px padding, surface bg, 1px solid border, 8px radius, no shadow

**Inputs:** 48px height, 16px padding, 1px solid border, 2px solid primary on focus, 4px radius, caption label above

**Tables:** Caption header on surface bg, 16px 24px cell padding, 1px solid border bottom, 5% primary opacity on hover

**Alerts:** 10% semantic color bg, 4px left border solid semantic color
- Success ✓ · Warning ⚠ · Error ✗ · Info ℹ

### Layout Principles

- Sharp corners: 4px max radius (8px for cards only)
- Whitespace: 16px/24px base increments
- Data-forward: tables and numbers prominent
- Flat design with intentional contrast

### Logo

- **Logo only:** app icon, favicon, square spaces
- **Wordmark only:** "Talon™" in headers, loading screens
- **Logo + wordmark:** login, website, marketing
- Files provided separately

### Marketing Voice

**Key messages:** "Complete control. Complete confidence." · "Fast. Sharp. Easy." (cashier-facing) · "The POS system built for businesses that mean business."

**Do not use:** stock photos, cartoons, overly bright imagery, cluttered layouts

---

## Feature Roadmap

Tags: `[MVP]` = golden path · `[CORE]` = required for phase · `[FUTURE]` = on roadmap, not now

### MVP — The Golden Path

> Login → Select store → Add to cart → Pay → Receipt → Report. Build FIRST.

- [ ] App shell with theme system (3 themes × light/dark) `MVP`
- [ ] Auth — login/logout with role selection `MVP`
- [ ] Store selector `MVP`
- [ ] Product list for active store `MVP`
- [ ] Cart — add/remove items, adjust quantity `MVP`
- [ ] Checkout — cash payment with tax calculation `MVP`
- [ ] Receipt — generate and display as PDF `MVP`
- [ ] Sales report — list today's transactions `MVP`
- [ ] Local DB setup (Drift) — offline storage `MVP`
- [ ] Supabase connection — cloud sync `MVP`
- [ ] Landing page — hero, features, theme showcase, CTAs `MVP`
- [ ] Marketing one-pager — product summary, key benefits, pricing/contact CTA `MVP`

### Phase 1: Core Foundation

> Depends on: MVP complete

**User Management**
- [ ] Role-based access control (Admin, Manager, Cashier) `CORE`
- [ ] Store-level permissions `CORE`
- [ ] Audit logs (who did what, when) `CORE`

**Multi-Store**
- [ ] Store creation and settings `CORE`
- [ ] Store-specific tax rates `CORE`
- [ ] Store-specific currency `CORE`
- [ ] Store-specific receipt headers `CORE`
- [ ] Central management dashboard `CORE`

**Product & Inventory**
- [ ] Product catalog (SKU, name, price, description) `CORE`
- [ ] Product variants (size, color) `CORE`
- [ ] Categories and subcategories `CORE`
- [ ] Bulk import/export (CSV) `CORE`
- [ ] Inventory per store (stock counts per location) `CORE`
- [ ] Real-time stock updates on sale `CORE`

**Technical Foundation**
- [ ] Offline-first architecture `CORE`
- [ ] Auto-sync when online (sync engine + queue) `CORE`
- [ ] Supabase Realtime subscriptions `CORE`
- [ ] Automated backups strategy `CORE`

### Phase 2: Core Business Operations

> Depends on: Phase 1 complete

**POS Terminal**
- [ ] Product search by name and SKU `CORE`
- [ ] Barcode scan (camera-based) `CORE`
- [ ] Item-level discounts `CORE`
- [ ] Cart-level discounts `CORE`
- [ ] Card payment processing `CORE`
- [ ] Mobile money payment `CORE`
- [ ] Split tender (multiple payment methods) `CORE`
- [ ] Multi-currency support `CORE`
- [ ] Tax calculation (auto per product + store) `CORE`
- [ ] Email receipt `CORE`
- [ ] SMS receipt `CORE`

**Transaction Management**
- [ ] Returns and refunds (original transaction lookup) `CORE`
- [ ] End-of-day reconciliation `CORE`

**Cash Management**
- [ ] Cash drawer open/close tracking `CORE`
- [ ] Cash counting and discrepancy alerts `CORE`

**Reports**
- [ ] Sales by store `CORE`
- [ ] Sales by cashier `CORE`
- [ ] Sales by time period `CORE`
- [ ] Export to CSV/Excel `CORE`

**Hardware Integration**
- [ ] Barcode scanner (physical device via platform channel) `CORE`
- [ ] Receipt printer integration `CORE`
- [ ] Cash drawer integration `CORE`

### Phase 3: Intelligence & Growth

> Depends on: Phase 2 complete

**Advanced Inventory**
- [ ] Stock transfers between stores `CORE`
- [ ] Purchase orders (create and receive) `CORE`
- [ ] Supplier management `CORE`
- [ ] Stocktaking with variance reporting `CORE`
- [ ] Expiry date tracking `CORE`
- [ ] Low stock alerts (configurable thresholds) `CORE`
- [ ] Reorder suggestions (sales velocity) `CORE`

**Advanced Reports**
- [ ] Profit and loss (Revenue - COGS) `CORE`
- [ ] Tax reports by jurisdiction `CORE`
- [ ] Best/worst sellers `CORE`
- [ ] Inventory valuation `CORE`
- [ ] Margin analysis (by product/category) `CORE`
- [ ] Store performance comparison `CORE`
- [ ] Custom date comparisons (YoY, WoW) `CORE`

**CRM**
- [ ] Customer profiles (contact info + purchase history) `CORE`
- [ ] Customer groups (wholesale, VIP) with tiered pricing `CORE`
- [ ] Loyalty program (points, redeemable) `CORE`
- [ ] Store credit management `CORE`

**Alerts & Notifications**
- [ ] Low stock alerts `CORE`
- [ ] Daily sales summary `CORE`
- [ ] Price change alerts `CORE`
- [ ] System health (offline stores) `CORE`
- [ ] In-app notification center `CORE`
- [ ] Email notifications `CORE`
- [ ] SMS notifications `CORE`

### Phase 4: Ecosystem & Integration

> Depends on: Phase 3 complete

**Integrations**
- [ ] E-commerce sync — Shopify `FUTURE`
- [ ] E-commerce sync — WooCommerce `FUTURE`
- [ ] Accounting — QuickBooks `FUTURE`
- [ ] Accounting — Xero `FUTURE`
- [ ] Public REST API `FUTURE`

**Hardware**
- [ ] Customer-facing display `FUTURE`
- [ ] Kitchen display system `FUTURE`

**Features**
- [ ] Gift card management `FUTURE`
- [ ] Booking/appointment module `FUTURE`
- [ ] Delivery management `FUTURE`
- [ ] Employee time clock `FUTURE`
- [ ] QR code menus `FUTURE`
- [ ] Self-service kiosk mode `FUTURE`

**Analytics**
- [ ] Demand forecasting `FUTURE`

**Marketing**
- [ ] App store screenshots with theme options `FUTURE`

---

## Non-Functional Requirements

| Category | Target |
|----------|--------|
| Checkout flow | < 2 seconds |
| Product search | < 500ms |
| App launch | < 3 seconds to usable |
| Queue drain | < 30s for 100 items on reconnect |
| Offline | Full POS functionality without internet |
| Data retention | 30+ days transaction history locally |
| Queue capacity | 1000+ pending mutations |
| Products | 10,000+ per store |
| Stores | 50+ per organization |
| Transactions | 500+ per store per day |

## Quality Checklist (per screen)

- [ ] Colors match active theme
- [ ] Typography follows hierarchy (Montserrat/Inter/JetBrains Mono)
- [ ] Spacing uses 16px/24px increments
- [ ] Alerts use left border + 10% bg
- [ ] UI copy matches active theme's brand voice
- [ ] ™ on first Talon mention
- [ ] Theme selector works in settings
- [ ] Light/dark toggle works
- [ ] Renders at 360px, 768px, 1440px without overflow
- [ ] Navigation adapts per breakpoint
- [ ] Touch targets 48×48px minimum
- [ ] Semantics labels on interactive elements
- [ ] Contrast 4.5:1 in all 6 theme variations
- [ ] Works with 200% font scaling
- [ ] No info by color alone
- [ ] Works offline or degrades gracefully
- [ ] No Supabase imports in presentation/domain
