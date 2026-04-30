# TSL Codebase Sitemap

Last updated: 2026-04-20 (Windows local audit)

## 1) High-level architecture

- **App type:** Flutter app (`provider` + `go_router`) with role-based flows (`mistri`, `dealer`, `architect`).
- **Entry point:** `lib/main.dart`
- **App shell:** `lib/app.dart`
- **Routing + auth guards:** `lib/navigation/app_router.dart`
- **State layer:** `lib/providers/`
- **Data/services layer:** `lib/services/`
- **UI layer:** `lib/screens/` + `lib/widgets/` + `lib/design_system/`
- **Domain models:** `lib/models/`
- **Localization:** `lib/l10n/`

## 2) Source tree map (where to edit what)

```text
lib/
  main.dart                     -> bootstraps Firebase, messaging, providers
  app.dart                      -> MaterialApp.router, theme, localization
  firebase_options.dart         -> generated Firebase options

  navigation/
    app_router.dart             -> all route constants + redirect rules + route graph

  providers/
    auth_provider.dart          -> auth/session/onboarding state
    user_provider.dart          -> profile data loading + completeness state
    dealer_data_provider.dart   -> dealer/mistri linking + dealer-specific runtime data
    delivery_provider.dart      -> delivery list/detail/POD state
    rewards_provider.dart       -> rewards data/state
    notification_provider.dart  -> notifications + auth sync
    app_settings_provider.dart  -> app settings (biometric/theme preferences)
    language_provider.dart      -> EN/HI locale persistence

  services/
    firebase_service.dart       -> Firebase initialization wrapper
    auth_service.dart           -> phone/email auth operations
    firestore_service.dart      -> Firestore reads/writes (core backend path)
    storage_service.dart        -> Firebase Storage uploads
    messaging_service.dart      -> FCM token + notification handlers
    image_picker_service.dart   -> camera/gallery access
    location_service.dart       -> GPS + geocoding helpers
    url_launcher_service.dart   -> tel/sms/maps/web intent launch
    cache_service.dart          -> in-memory + disk cache utility

  screens/
    auth/                       -> splash/onboarding/role/login/otp/profile-completion
    mistri/                     -> mistri home, deliveries, POD, rewards, request-order
    dealer/                     -> dealer home, mistris, orders, approvals, rewards
    architect/                  -> architect home, projects, create-spec, rewards
    shared/                     -> profile, notifications, chat, legal, catalog/detail

  models/
    shared_models.dart          -> app user, notifications, chat, settings
    mistri_models.dart          -> mistri domain + mock data
    dealer_models.dart          -> dealer domain + mock data
    architect_models.dart       -> architect domain + mock data
    product_models.dart         -> product catalog domain

  widgets/                      -> reusable UI components
  design_system/                -> tokens/theme/typography/spacing/accessibility
  l10n/                         -> app_en.arb, app_hi.arb, generated localization files
```

## 3) Non-code infra and platform files

- **Firebase deploy config:** `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `storage.rules`, `.firebaserc`
- **Android build:** `android/app/build.gradle.kts`, `android/build.gradle.kts`, `android/app/src/`
- **iOS build:** `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `ios/Runner.xcodeproj/project.pbxproj`
- **Windows desktop runner:** `windows/`
- **Assets:** `assets/images/`

## 4) Test map

```text
test/
  navigation/                   -> router guard and navigation behavior tests
  services/                     -> service-level tests
  services_test.dart            -> grouped service tests
  unit_test.dart                -> core model/provider unit tests
  widget_test.dart              -> baseline widget tests
```

## 5) Documentation map (single-source navigation)

### Release control docs
- `FINAL_RELEASE_BLOCKERS_TRACKER.md` (priority source: P0/P1/P2 blockers)
- `PRE_RELEASE_SMOKE_CHECKLIST.md` (manual + automated smoke gate)
- `release_evidence/2026-03-31/RELEASE_READINESS_REPORT.md` (evidence log)

### Firebase docs
- `FIREBASE_PRODUCTION_VERIFICATION.md` (CLI deploy/verify checklist)
- `FIREBASE_SETUP.md` (project config status + troubleshooting)
- `important documentation/FIREBASE_PHONE_AUTH_RELEASE_CHECKLIST.md` (OTP release path)

### Program tracking docs
- `TASK_TRACKER.md`
- `PENDING_TASKS.md`
- `FINAL_RELEASE_PHASED_IMPLEMENTATION_PLAN.md`
- `SUBTASKS_SUMMARY.md`

### Audit/QA docs
- `PRODUCTION_AUDIT_REPORT.md`
- `COMPLETE_AUDIT_REPORT.md`
- `QA_TEST_REPORT.md`
- `QA_OTP_NOTIFICATION_VALIDATION.md`
- `important documentation/DEALER_MISTRI_LOCATION_RELEASE_PLAN.md`

## 6) Current operational status from this audit

- Firebase CLI installed: `firebase-tools 15.15.0`
- Firebase login status: authenticated account present
- Active Firebase project in repo: `tsl-parivar` (`.firebaserc` alias `default`)
- Firebase backend config deploy run completed:
  - `firestore.rules` deployed (compiler warning: unused helper function)
  - `firestore.indexes.json` deployed
  - `storage.rules` deployed
- Local toolchain status on this machine:
  - `node` and `npm` available
  - `flutter` and `dart` were **not found in PATH** during this run

## 7) Priority completion focus (from blockers/smoke docs)

1. P0 OTP production reliability proof on **Play-installed build** + evidence capture.
2. P0 Dealer -> Mistri add/link runtime failure closure.
3. P0 remove no-op/simulated critical action paths (especially architect + delivery flows).
4. P1 unresolved manual smoke failures in `PRE_RELEASE_SMOKE_CHECKLIST.md`.
5. Platform release gate closure (iOS/TestFlight only if in scope).

## 8) Reusable commands (PowerShell)

```powershell
Set-Location "D:\Zyphex Projects"

firebase login:list
firebase use tsl-parivar
firebase deploy --only firestore:rules,firestore:indexes,storage
firebase projects:list
```

If Flutter is added to PATH on this machine:

```powershell
Set-Location "D:\Zyphex Projects"
flutter pub get
flutter analyze
flutter test
```

