# SupperSync

**Cook Together. Waste Less.**

Community supper-club app for iOS, Android, and Web — shared pantries, collaborative meal planning, and zero-waste dining.

Built with **Flutter + Provider (MVVM) + Supabase**.

---

## What's included

| Layer | Status |
| :--- | :--- |
| MVVM + Provider (no `setState()`) | Done |
| Light / dark theming + design tokens | Done |
| Auth, pantry, clubs, events, recipes, profile | Done |
| Supabase schema + RLS | `supabase/schema.sql` |
| Screens (splash → shell → all features) | Done |

---

## Architecture

```
lib/
├── core/                 # theme, router, constants, utils, errors
├── data/
│   ├── models/           # Equatable models mirroring Supabase tables
│   └── repositories/     # Supabase / HTTP only — no UI
└── presentation/
    ├── viewmodels/       # ChangeNotifier — notifyListeners() only
    ├── views/            # StatelessWidget screens
    └── widgets/          # Design-system components
```

**Rule:** never call `setState()`. Local form UI state uses dedicated `ChangeNotifier` form controllers under `presentation/viewmodels/forms/`.

---

## Features

1. **Personal + shared pantry** — quantity, storage, expiry, share toggle  
2. **Supper clubs** — create / join via invite code, member roster, club inventory  
3. **Events** — schedule, RSVP, who's-bringing-what claims  
4. **Recipe matching** — Spoonacular (or built-in mocks) against collective pantry  
5. **Impact stats** — food rescued, money saved, carbon offset  
6. **Theme** — system / light / dark  

### Suggested next features

- Push notifications for expiry + RSVP reminders  
- Barcode scanner wired to Open Food Facts (repo already has lookup)  
- Host rotation calendar + recurring events  
- Fair-share contribution scoreboard  
- Offline-first pantry cache with sync  
- Photo memories per event (Supabase Storage)  

---

## Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3+) — add to PATH  
2. A free [Supabase](https://supabase.com) account  
3. Android Studio / Xcode / Chrome for the platform you want to run  

---

## Connect Supabase (beginner guide)

### 1. Create a project

1. Go to [https://supabase.com](https://supabase.com) → **New project**  
2. Pick org, name (`suppersync`), database password, region  
3. Wait until the project is ready  

### 2. Get API keys

1. Dashboard → **Project Settings** → **API**  
2. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`  

> Use the **anon** key in the Flutter app only. Never put the `service_role` key in the client.

### 3. Run the database schema

1. Dashboard → **SQL Editor** → **New query**  
2. Open `supabase/schema.sql` from this repo  
3. Paste the entire file → **Run**  
4. Confirm tables appear under **Table Editor**:  
   `profiles`, `supper_clubs`, `club_memberships`, `pantry_items`, `supper_events`, `event_attendees`, `ingredient_assignments`, `impact_logs`

### 4. Enable Email Auth

1. Dashboard → **Authentication** → **Providers** → **Email** → enabled  
2. For local testing, turn **off** “Confirm email” (Auth → Providers → Email) so signup works immediately  
3. (Optional later) configure redirect URLs for password reset / magic links  

### 5. Wire the Flutter app

```bash
cp .env.example .env
```

Edit `.env`:

```env
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SPOONACULAR_API_KEY=
```

`main.dart` already loads dotenv and initializes Supabase:

```dart
await dotenv.load(fileName: '.env');
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

### 6. How the app talks to Supabase

| Concern | Where |
| :--- | :--- |
| Auth (sign up / in / out) | `AuthRepository` → `supabase.auth` |
| Profiles | `profiles` table (auto row via trigger on signup) |
| Clubs / pantry / events | Repositories → `.from('table')` |
| Security | Row Level Security in `schema.sql` |
| Theme preference | Local `SharedPreferences` (not Supabase) |

Flow: **View → ViewModel → Repository → Supabase**.

### 7. Optional: Spoonacular recipes

1. Sign up at [spoonacular.com/food-api](https://spoonacular.com/food-api)  
2. Put the key in `.env` as `SPOONACULAR_API_KEY`  
3. Without a key, the app uses mock recipes so you can still demo matching  

---

## Run the app

If this folder was not created with `flutter create`, generate platform folders once:

```bash
flutter create . --project-name suppersync --org com.suppersync
```

Then:

```bash
flutter pub get
flutter run -d chrome      # web
flutter run -d windows     # desktop
flutter run                # connected phone / emulator
```

---

## Design system

- Colors: `lib/core/constants/app_colors.dart` (forest green + amber)  
- Spacing / radius: `app_dimensions.dart`  
- Copy: `app_strings.dart`  
- Typography: Nunito + Inter via `google_fonts`  
- Shared widgets: `AppButton`, `AppTextField`, cards, empty/loading states  

Cursor rule enforcing no-`setState` MVVM: `.cursor/rules/suppersync-mvvm.mdc`

---

## License

MIT — see [LICENSE](LICENSE).
