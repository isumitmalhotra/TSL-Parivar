# TSL Parivar - Project Ops Guide

This is the operational README for running, validating, and releasing the TSL Parivar Flutter app.

## 1) What this project is

- **Product:** TSL Parivar role-based app (`mistri`, `dealer`, `architect`)
- **Stack:** Flutter + Provider + GoRouter + Firebase (Auth, Firestore, Storage, FCM)
- **Primary source-code root:** `lib/`
- **Primary release blocker tracker:** `FINAL_RELEASE_BLOCKERS_TRACKER.md`

For full code map, see `CODEBASE_SITEMAP.md`.

## 2) Repository map (quick)

```text
lib/        -> application source (ui + providers + services + models)
test/       -> unit/service/navigation tests
android/    -> Android build + signing
ios/        -> iOS build + native config
assets/     -> app assets
firebase.*  -> firebase deploy manifests/rules/indexes
release_evidence/ -> release validation artifacts
```

## 3) Local setup (Windows PowerShell)

### 3.1 Required tools

- Flutter SDK (with Dart)
- Android Studio / SDK + device or emulator
- Node.js + npm
- Firebase CLI (`firebase-tools`)

### 3.2 Verify toolchain

```powershell
flutter --version
dart --version
node --version
npm --version
firebase --version
```

If Firebase CLI is missing:

```powershell
npm install -g firebase-tools
firebase --version
```

### 3.3 Install dependencies

```powershell
Set-Location "D:\Zyphex Projects"
flutter pub get
```

### 3.4 Run app

```powershell
Set-Location "D:\Zyphex Projects"
flutter run
```

## 4) Firebase operations

### 4.1 Authenticate and select project

```powershell
Set-Location "D:\Zyphex Projects"
firebase login
firebase projects:list
firebase use tsl-parivar
```

Repo alias is tracked in `.firebaserc` (`default` -> `tsl-parivar`).

### 4.2 Deploy rules/indexes/storage

```powershell
Set-Location "D:\Zyphex Projects"
firebase deploy --only firestore:rules,firestore:indexes,storage
```

### 4.3 Validate deployment targets

- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`
- `storage.rules`

See `FIREBASE_PRODUCTION_VERIFICATION.md` for the full checklist.

## 5) Quality gates and testing

### 5.1 Static analysis + tests

```powershell
Set-Location "D:\Zyphex Projects"
flutter analyze
flutter test
```

### 5.2 Smoke checklist

Use `PRE_RELEASE_SMOKE_CHECKLIST.md` and capture evidence under `release_evidence/`.

### 5.3 Release blocker closure order

Always close in this order:
1. `P0` items in `FINAL_RELEASE_BLOCKERS_TRACKER.md`
2. `P1` quality gates
3. `P2` platform/compliance tasks

## 6) Release runbook (Android first)

### 6.1 Pre-release

```powershell
Set-Location "D:\Zyphex Projects"
flutter clean
flutter pub get
flutter analyze
flutter test
```

### 6.2 Build artifacts

```powershell
Set-Location "D:\Zyphex Projects"
flutter build apk --release
flutter build appbundle --release
```

### 6.3 Firebase + backend readiness

```powershell
Set-Location "D:\Zyphex Projects"
firebase use tsl-parivar
firebase deploy --only firestore:rules,firestore:indexes,storage
```

### 6.4 Sign-off checklist

- All `P0` blockers marked `Done` with evidence
- Critical smoke rows passed in `PRE_RELEASE_SMOKE_CHECKLIST.md`
- OTP verified on Play-installed build (not sideload)
- `GO/NO-GO` gate completed in `FINAL_RELEASE_BLOCKERS_TRACKER.md`

## 7) Operations runbook (common incidents)

### 7.1 OTP failures in production

Follow `important documentation/FIREBASE_PHONE_AUTH_RELEASE_CHECKLIST.md`:
- verify SHA-1/SHA-256 in Firebase include Play App Signing certs
- validate on Play Internal build
- collect logcat + screenshot/video evidence

### 7.2 Dealer -> Mistri add/link failure

Primary code path:
- `lib/providers/dealer_data_provider.dart` (`addMistriForDealer`)
- `lib/services/firestore_service.dart` (`addOrLinkMistriToDealer`)

Checks:
- dealer account role (`dealer`) exists and is consistent
- mobile number is valid 10 digits
- Firestore `mistris` write succeeds
- mistri appears linked after login with same phone

### 7.3 Firebase permission/index errors

- Deploy latest rules/indexes (`firebase deploy --only firestore:rules,firestore:indexes`)
- Verify query shape matches existing indexes in `firestore.indexes.json`

## 8) Documentation index

### Core release docs
- `FINAL_RELEASE_BLOCKERS_TRACKER.md`
- `PRE_RELEASE_SMOKE_CHECKLIST.md`
- `release_evidence/2026-03-31/RELEASE_READINESS_REPORT.md`

### Firebase docs
- `FIREBASE_SETUP.md`
- `FIREBASE_PRODUCTION_VERIFICATION.md`
- `important documentation/FIREBASE_PHONE_AUTH_RELEASE_CHECKLIST.md`

### Audit and planning docs
- `PRODUCTION_AUDIT_REPORT.md`
- `COMPLETE_AUDIT_REPORT.md`
- `FINAL_RELEASE_PHASED_IMPLEMENTATION_PLAN.md`
- `TASK_TRACKER.md`

## 9) Maintain the sitemap

Refresh quick tree snapshot:

```powershell
Set-Location "D:\Zyphex Projects"
.\scripts\refresh_sitemap.ps1
```

Outputs:
- `CODEBASE_SITEMAP.md`
- `CODEBASE_SITEMAP_TREE.txt`
