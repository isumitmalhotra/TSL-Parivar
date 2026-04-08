# Release Readiness Report

Date: 2026-03-31
Workspace: `C:\Projects\tsl`

## 1) QA smoke execution status

Checklist file updated: `PRE_RELEASE_SMOKE_CHECKLIST.md`

- Global redirect scenarios (`G-01`..`G-06`) are marked **Pass** from automated unit tests in `test/navigation/app_router_guard_test.dart`.
- Cross-role guard scenarios are marked **Pass** for `D-04`, `D-05`, `M-05`, `M-06`, `A-04`, `A-05` from the same test file.
- Login/home/feature/shared-route runtime rows remain **Fail** (not executed on physical/emulator app session in this Windows validation run).

### Final patch batch applied (2026-04-01)
- Profile screen contrast cleanup completed in `lib/screens/shared/profile_screen.dart` (theme-based card/text/dialog surfaces).
- Biometric UX polish completed in `lib/screens/shared/profile_screen.dart` (enable/disable feedback messages + safe fallback when unavailable or auth fails).
- Mistri order request submit path switched from mock delay to Firestore write in `lib/screens/mistri/mistri_request_order_screen.dart`.
- Backend auth loop hardening and index-pressure reductions are in place across providers/services for runtime stability.

Pending for final sign-off:
- Execute manual runtime smoke rows (including `G-07`, `G-08`) and attach device evidence.

## 2) iOS readiness status (main unverified area)

### Verified from repository
- Firebase iOS config file exists: `ios/Runner/GoogleService-Info.plist`.
- iOS Firebase options are present in `lib/firebase_options.dart` with project `tsl-parivar`.
- Push registration logic is present in `ios/Runner/AppDelegate.swift` (`FirebaseApp.configure`, APNs token handoff to FCM).
- Required privacy strings and background modes exist in `ios/Runner/Info.plist`.

### Not yet verified / blockers
- No iOS build validation was run here (Windows environment).
- Apple signing team/provisioning is not confirmed in `ios/Runner.xcodeproj/project.pbxproj` (no explicit `DEVELOPMENT_TEAM` found).
- Push capability entitlement file not present in repo (`ios/Runner/*.entitlements` not found).
- APNs key upload linkage in Firebase console cannot be validated from repo.

### Required manual completion on macOS
1. Open `ios/Runner.xcworkspace` in Xcode and set `Runner` signing team + provisioning profile.
2. Enable Push Notifications capability and Background Modes (remote notifications).
3. Confirm APNs Auth Key in Apple Developer and linked in Firebase project settings.
4. Run and archive iOS build:
   - `flutter build ios --simulator --debug`
   - `flutter build ios --release --no-codesign`
   - Xcode Archive -> TestFlight upload.

## 3) Release evidence pack

Evidence directory: `release_evidence/2026-03-31`

- `01_pub_get.log`
- `02_analyze.log`
- `03_test.log`
- `04_build_apk.log`
- `05_build_aab.log`
- `06_router_guard_test.log`
- `07_full_test_after_guard_update.log`
- `RELEASE_READINESS_REPORT.md`

Core outcomes captured:
- `flutter analyze --no-fatal-infos`: completes with 524 issues (mostly style/info + some warnings), no compile-stopper captured.
- `flutter test`: passes (`All tests passed!` in `03_test.log`).
- `flutter build apk --release`: artifact built (`build/app/outputs/flutter-apk/app-release.apk`).
- `flutter build appbundle`: artifact built (`build/app/outputs/bundle/release/app-release.aab`).

## 4) Config sanity check (Firebase/prod target)

### Consistency checks passed in repo
- `firebase.json` points to:
  - Firestore rules: `firestore.rules`
  - Firestore indexes: `firestore.indexes.json`
  - Storage rules: `storage.rules`
- Firebase project identifiers are consistent across:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `lib/firebase_options.dart`
- Project id observed: `tsl-parivar`
- Storage bucket observed: `tsl-parivar.firebasestorage.app`

### External checks still required
- Active Firebase CLI target project at deploy time (`firebase use ...`) not verifiable from repo (`.firebaserc` absent).
- Production deploy confirmation for rules/indexes requires console/CLI verification.

## 5) Lint debt decision

Current state from `02_analyze.log`:
- 524 analyzer issues.
- Predominantly info/style diagnostics.
- Some warnings are present (for example unused fields/elements).

Recommended release policy for this cut:
- Gate on: `0` errors, tests passing, release artifacts building.
- Allow: info-level style debt.
- Time-box warning cleanup post-release by severity:
  - P1 before release: warnings affecting behavior/security (none identified in this run).
  - P2 after release: unused fields/imports, constructor ordering, const/decorated-box refactors.

## Final Go/No-Go status (as of this report)

- Android build/test gates: **GO (technical)**
- QA full manual smoke: **NO-GO until remaining Fail rows are executed and converted to Pass (including profile contrast + biometric UX rows)**
- iOS release gate: **NO-GO until macOS signing/APNs/TestFlight validation completes**


