# Final Release Blockers Tracker

Use this file as the single source of truth for closure before final Android/iOS release.

## How to use this tracker

- Work top to bottom: complete all `P0` first, then `P1`, then `P2`.
- Update each item status as you progress: `Open`, `In Progress`, `Blocked`, `Done`.
- Attach evidence for each completed blocker (log, screenshot, test output, console screenshot).
- Do not mark final release `GO` until all `P0` items are `Done`.

## Status legend

- `Open` = not started
- `In Progress` = implementation underway
- `Blocked` = waiting on dependency/console access/device
- `Done` = verified with evidence

---

## P0 - Release stoppers (must close before upload)

### P0-1 OTP production reliability (Play Integrity + Firebase phone auth)
- **Status:** In Progress
- **Issue:** OTP can fail in production path if install/signing/channel config is mismatched.
- **Fix actions:**
  - Verify package IDs match in app, Firebase, and Play listing.
  - Verify SHA-1/SHA-256 in Firebase include Play App Signing keys.
  - Validate OTP on Play Internal-installed build (not sideloaded APK).
  - Confirm no `missing-client-identifier` or `app not Recognized by Play Store` during end-to-end login.
- **Owner area/files:** Firebase Console, Play Console, `important documentation/FIREBASE_PHONE_AUTH_RELEASE_CHECKLIST.md`
- **Exit criteria:**
  - [ ] OTP success on Play-installed build
  - [ ] No critical phone-auth integrity errors in logcat
  - [ ] Evidence captured (video/screenshot + logs)
- **Progress notes (2026-04-05):**
  - Added Firebase SHA via CLI for appId `1:868208183306:android:6c4e7a33bc761d917737f3` in project `tsl-parivar`.
  - Added deployment cert SHA-1: `7f8fa097ce7f5633f1ff15f00eb6a01c9b5a4e99`.
  - Added deployment cert SHA-256: `eee757a9c757ff99a9c62b73b3e3e2c950626b8f84a61c93aff24f92e8586924`.
  - Upload cert SHA already present: SHA-1 `130e0e1b3c400a1241608f2a434e810a0dd6b716`, SHA-256 `5764ffca21b8c3dd5a84c9d417b47fff68e82d8e72378bf9b9678025189e7700`.
  - Remaining: Play-installed OTP run + log evidence + screenshot/video evidence.

### P0-2 Dealer -> Mistri add/link runtime reliability
- **Status:** Open
- **Issue:** User still reports `Failed to add mistri` in runtime.
- **Fix actions:**
  - Validate `firestore.rules` and `firestore.indexes.json` are deployed to target project.
  - Validate add/link path creates/links user consistently and idempotently.
  - Validate linked mistri sees assigned dealer after login with same phone.
  - Validate notification is created for linked mistri.
- **Owner area/files:** `lib/services/firestore_service.dart`, `lib/providers/dealer_data_provider.dart`, `firestore.rules`, `firestore.indexes.json`
- **Exit criteria:**
  - [ ] Dealer can add new phone successfully
  - [ ] Same phone login as mistri shows linked dealer
  - [ ] No permission/index errors in logs
  - [ ] Evidence captured

### P0-3 Critical no-op actions replaced with backend-backed behavior
- **Status:** Open
- **Issue:** Some important CTA handlers are still no-op or local-only.
- **Fix actions:**
  - Replace placeholder handlers with real service/provider calls.
  - Ensure state changes persist to Firestore.
  - Add user feedback and failure recovery path.
- **Owner area/files:** `lib/screens/mistri/mistri_delivery_details_screen.dart`, `lib/screens/dealer/dealer_mistris_screen.dart`, `lib/providers/delivery_provider.dart`
- **Exit criteria:**
  - [ ] All primary action buttons on tested flows execute business action
  - [ ] Data persists after app restart
  - [ ] Failure states show actionable message

### P0-4 Architect flow productionization (remove simulated/mock runtime behavior)
- **Status:** Open
- **Issue:** Architect projects/rewards/spec flows are still partially in-memory/simulated.
- **Fix actions:**
  - Move architect projects and rewards to Firestore-backed loading.
  - Replace simulated create-spec submit with real persisted write flow.
  - Validate role-based visibility for architect data.
- **Owner area/files:** `lib/screens/architect/architect_projects_screen.dart`, `lib/screens/architect/architect_rewards_screen.dart`, `lib/screens/architect/architect_create_spec_screen.dart`
- **Exit criteria:**
  - [ ] Architect sees persisted projects/rewards data
  - [ ] Create spec writes to backend and is visible on reload
  - [ ] No simulated delay-only submit paths remain

---

## P1 - Pre-release quality gates (should close before submission)

### P1-1 Dark mode decision closure (remove or fully implement)
- **Status:** Open
- **Issue:** Current behavior is inconsistent and partially disabled.
- **Fix actions (recommended for current release):**
  - Remove dark mode toggle and keep app consistently light.
  - Remove any misleading persistence/UI states for dark mode.
- **Owner area/files:** `lib/providers/app_settings_provider.dart`, `lib/app.dart`, `lib/screens/shared/profile_screen.dart`
- **Exit criteria:**
  - [ ] No dark-mode toggle exposed to user
  - [ ] No dark-mode-only visual regressions

### P1-2 Overflow/layout regressions across roles
- **Status:** Open
- **Issue:** Runtime `right overflowed by` remains on key pages.
- **Fix actions:**
  - Fix constrained rows/cards with `Expanded/Flexible/Wrap`.
  - Add truncation and responsive spacing where needed.
  - Re-run role-wise manual smoke at smallest supported widths.
- **Owner area/files:** Role dashboard/cards/screens where overflow appears
- **Exit criteria:**
  - [ ] No overflow warnings in tested role flows
  - [ ] QA screenshots captured for fixed screens

### P1-3 Profile legal/support action wiring
- **Status:** Open
- **Issue:** Privacy/Terms/Help/Support/Contact/Share actions not consistently wired.
- **Fix actions:**
  - Ensure legal routes open correctly (`/legal/privacy`, `/legal/terms`).
  - Wire external/support actions with `url_launcher` + fallback message.
- **Owner area/files:** `lib/screens/shared/profile_screen.dart`, `lib/navigation/app_router.dart`
- **Exit criteria:**
  - [ ] All profile legal/support actions are functional
  - [ ] External links open correctly on Android and iOS

---

## P2 - Platform/compliance completion (release process blockers)

### P2-1 iOS release gate (if included in this launch)
- **Status:** Open
- **Issue:** Signing/APNs/TestFlight evidence not fully complete yet.
- **Fix actions:**
  - Configure signing team/profiles in Xcode.
  - Validate APNs + Firebase messaging linkage.
  - Generate one TestFlight build and verify install/login smoke.
- **Owner area/files:** `ios/Runner.xcodeproj/project.pbxproj`, Apple Developer, App Store Connect, Firebase Console
- **Exit criteria:**
  - [ ] TestFlight build installed and smoke-tested
  - [ ] iOS login + core role flow verified

### P2-2 Play listing compliance closure
- **Status:** Open
- **Issue:** Final listing declarations/deletion URL must match app behavior.
- **Fix actions:**
  - Finalize Data Safety form answers based on implemented behavior.
  - Publish and add valid account deletion request URL.
  - Confirm policy links in listing and app are consistent.
- **Owner area/files:** Play Console listing + public policy/deletion page
- **Exit criteria:**
  - [ ] Data Safety submitted accurately
  - [ ] Deletion URL accepted and publicly accessible

### P2-3 Release lint and regression sanity pass
- **Status:** Open
- **Issue:** High analyzer count can hide critical signals.
- **Fix actions:**
  - Fix warnings/errors first; defer low-priority infos after release if needed.
  - Re-run targeted tests for edited modules.
- **Owner area/files:** whole repo (`lib/`, `test/`)
- **Exit criteria:**
  - [ ] No new warnings/errors introduced by release fixes
  - [ ] Targeted test suites pass

---

## Final GO/NO-GO gate

Mark `GO` only when all are true:

- [ ] All `P0` blockers are `Done` with evidence
- [ ] Smoke checklist critical rows are `Pass` in `PRE_RELEASE_SMOKE_CHECKLIST.md`
- [ ] Firebase config/rules/indexes deployed and verified on target project
- [ ] Android Play Internal build validation completed
- [ ] iOS TestFlight validation completed (if iOS release is in scope)

If any above is not complete, release is `NO-GO`.

---

## Evidence links to maintain during closure

- `PRE_RELEASE_SMOKE_CHECKLIST.md`
- `release_evidence/2026-03-31/RELEASE_READINESS_REPORT.md`
- `important documentation/FIREBASE_PHONE_AUTH_RELEASE_CHECKLIST.md`

