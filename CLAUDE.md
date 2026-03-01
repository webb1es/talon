# Talon™ POS — Build Rules

**Project spec, features, brand identity, and architecture are in `PROMPT.md`. Read it before building anything. This file governs HOW you write code.**

## Stack

Flutter 3.x | Dart 3.x | Supabase | Bloc/Cubit | Drift (SQLite) | get_it + injectable

## Architecture

Clean Architecture — 3 layers. Dependency flows inward.

```
Presentation → Domain ← Data
```

- **Presentation**: widgets, screens, Blocs/Cubits. Depends on Domain only.
- **Domain**: entities, repository contracts (abstract), use cases. Pure Dart — ZERO external dependencies.
- **Data**: repository implementations, DTOs, Supabase calls, Drift DAOs. Implements Domain contracts.

Rules:
- No business logic in widgets or build methods
- No Supabase imports in Presentation or Domain layers
- No Flutter imports in Domain layer
- UI talks to Blocs → Blocs call use cases/repositories → repositories are injected via get_it
- To swap backends, change one DI registration per repository. Nothing else changes.

## State Management

Bloc/Cubit only. No Provider, no setState for anything beyond trivial local widget state.

- One Cubit/Bloc per feature or screen
- UI events → Bloc → state emission → UI rebuild
- No business logic in Blocs — delegate to use cases or repositories
- Use StreamSubscription for Supabase Realtime, dispose in `close()`

## Data & Models

- `freezed` for immutable domain entities
- `json_serializable` for DTOs
- Separate DTOs (data layer) from entities (domain layer)
- Local DB: Drift (SQLite) — mirrors Supabase schema
- Offline queue: Drift `sync_queue` table (see PROMPT.md for schema)

## Multi-Tenancy

- All tables use `store_id` (UUID, indexed) — not tenant_id
- Supabase RLS policies filter by store_id automatically
- App sets store context via Supabase session
- Cross-store operations use service role (admin only)
- NEVER pass store_id manually in queries — RLS handles it

## Multi-Currency

- Store amounts in base currency with exchange rate
- Convert to display currency at render time, not storage time
- Always persist: amount (decimal), currency_code, exchange_rate
- Cache exchange rates with timestamp
- Handle rate lookup failure gracefully

## Offline-First

- App works 100% without internet
- UI reads from local Drift DB only
- Writes go to local DB + sync_queue
- Sync engine drains queue when online (FIFO, exponential backoff)
- Sync priority: transactions > inventory > products
- Visual sync status indicator in UI
- Manual retry option for failed items
- Conflict resolution per entity type (see PROMPT.md)

## Realtime

- Supabase Realtime subscriptions for live data
- Always dispose subscriptions in Bloc `close()` or State `dispose()`
- Batch rapid updates to prevent UI thrashing
- Offline queue handles missed updates on reconnection

## Navigation

- GoRouter for declarative routing
- ShellRoute for authenticated sections
- Branch per major feature (pos, inventory, reports, settings)
- Always use named routes
- Pass typed arguments, not raw Strings
- Deep linking support for web
- Handle unauthorized routes gracefully

## Responsiveness

One codebase — mobile, tablet, desktop, web. Every screen must work on all.

- Breakpoints: mobile <600px, tablet 600-1024px, desktop >1024px
- Use LayoutBuilder or MediaQuery — never hardcode widths
- Navigation: bottom nav (mobile), rail (tablet), side drawer (desktop)
- Data tables: card/list view (mobile), full table (tablet/desktop)
- Dialogs: fullscreen (mobile), centered modal (tablet/desktop)
- Touch targets: minimum 48x48px everywhere
- Test at 360px, 768px, 1440px

## Accessibility

WCAG 2.1 AA minimum. Built in, not bolted on.

- Semantics labels on all interactive elements
- Contrast ratio: 4.5:1 for text, 3:1 for large text — verify in ALL 6 theme variations
- Form fields need real labels, not just placeholders
- Error messages announced to screen readers
- Keyboard navigation on web and desktop
- No information conveyed by color alone (use icons + text)
- Test with system font scaling up to 200%

## Branding

All brand values (colors, typography, component specs, voice) are in `PROMPT.md` under `brand_identity`. That is the single source of truth.

Visual language: macOS/Apple — smooth radii (6-16px), subtle shadows, frosted glass accents, compact density, hover states. Material widgets styled to look macOS-native (not Cupertino, not `macos_ui` package).

- Implement all 6 theme variations (3 themes x light/dark) with exact hex codes from PROMPT.md
- ThemeCubit handles switching. Theme selector in settings.
- ALL UI copy must match the active theme's brand voice (app_strings.dart)
- "Talon™" — use ™ on first mention per screen
- Use google_fonts package — do NOT bundle font files
- Never hardcode colors outside the theme system
- Never hardcode user-facing strings — use app_strings.dart

## Forms & Validation

- Use Flutter's built-in Form + TextFormField (no extra form libraries unless justified)
- Real-time validation feedback
- Error messages match brand voice per active theme
- Submit button disabled until form is valid
- Loading state on submission

## Error Handling

- Result pattern (sealed class: Success/Failure) for repository returns
- User-facing errors: match brand voice per active theme
- Technical errors: log to console/crashlytics
- Retry mechanism for transient failures (network, sync)
- Graceful degradation when offline — never crash, always inform

## Platform-Specific

**Web**: responsive layout, PWA with offline, deep linking
**Mobile**: bottom navigation, pull to refresh, hardware back button
**Desktop**: keyboard shortcuts for POS (F1-F12), window management, right-click context menus

## Security

- Supabase Auth with email/password
- Biometric option for cashier quick-login
- Session timeout configurable per store
- Never store sensitive data locally unencrypted
- Use flutter_secure_storage for tokens
- Clear sensitive data on logout
- All input validated client-side AND server-side
- RLS enforces row-level security

## Performance

- const constructors everywhere possible
- ListView.builder for any list that could grow
- RepaintBoundary to isolate expensive rebuilds
- cached_network_image for remote images
- Lazy load heavy features
- Keep build methods pure — no side effects
- Profile before optimizing — no premature optimization

## Code Quality

**Philosophy: simplicity over sophistication. Minimal LOC, but production-ready. Code must be simple enough for a junior to read, robust enough to serve millions of users.**

**Write every line as if a strict senior reviewer will challenge it. Every line must be defensible.**

Principles:
- SOLID, KISS, DRY — mandatory
- Minimal code is better code — fewest lines that solve the problem correctly
- Delete unused code aggressively
- Leverage Dart 3 features (records, patterns, sealed classes)
- Prefer Flutter/Dart SDK over external dependencies
- Simple and readable > clever and concise
- Before adding code: "Is there a simpler way?"
- Before keeping code: "Can this be deleted?"

Style:
- Follow effective_dart
- Classes: PascalCase | methods: camelCase | constants: lowerCamelCase
- Widgets under 200 lines. One widget does one thing.
- const constructors where possible
- Comments: concise, objective, useful. WHY, not WHAT.
- Never bake conversation context, prompts, or AI reasoning into code comments
- No AI waffle — no "this is a great approach", no "as discussed", no filler
- Dartdoc only for public APIs or complex algorithms
- No TODOs on main branch

## Testing

Useful tests only. Every test must answer: "what breaks if this fails?"

Test:
- Business logic (tax calculation, discounts, inventory deltas, payment splitting)
- Complex Bloc flows (checkout, sync, cart operations)
- Sync engine (queue processing, retry, conflict resolution)
- Offline → online transitions
- Theme switching (all 6 variations render without errors)
- Multi-currency conversion

Do NOT test:
- Simple UI rendering (Flutter tests its own widgets)
- Trivial Bloc emissions (emitting a state emits a state — no value)
- DTOs with no logic
- Getters, constructors, pass-through methods

Start lean. Add tests as features stabilize and bugs appear.

## Build Verification

Before every commit:
1. `flutter analyze` — 0 issues
2. `flutter test` — all pass
3. `flutter build` for target platform — succeeds

NEVER commit if any of these fail. Fix first, then commit.

Regression check:
- Before making a change, identify what existing functionality it could affect
- If a change is breaking: STOP and inform the user what will break and why, then wait for approval before proceeding
- Never silently break existing functionality — breaking changes may be acceptable, but only with explicit user consent
- If docs or READMEs are impacted by a change, update them in the same commit

## Commit Messages

Conventional Commits. Format: `<type>(<scope>): <description>`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Rules:
- Scope is optional — use it when the change is clearly scoped to a feature/module, omit when it spans multiple areas or is general
- Subject line 50-72 characters
- Describe WHAT changed, not why
- Be factual — no subjective words ("improve", "better", "clean up")
- No commit body unless essential
- No filler, repetition, or vague language

```
# Good
feat(pos): add split tender payment flow
fix(sync): prevent duplicate queue entries on reconnect
chore: add project spec and build rules
docs: update README with setup instructions

# Bad
feat(pos): improve payment handling with better split support
fix(sync): make queue more robust and reliable
chore(project): add project spec and build rules   ← forced scope
```

## Reject List

Reject any code that contains:
- Hardcoded colors outside the theme system
- Hardcoded user-facing strings outside app_strings.dart
- Business logic in widgets or build methods
- Direct Supabase imports in Presentation or Domain
- Widgets over 200 lines
- setState for complex state
- Missing Semantics labels on interactive elements
- Unused imports or variables
- print/debugPrint in production code
- Missing offline handling
- Missing error states
