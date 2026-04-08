# Final Release Phased Implementation Plan (Android + iOS)

Use this as the single source of truth to execute all pending fixes before final release testing.

## Execution Checklist

- [ ] Phase 0: Data contract lock (dealer-mistri-order schema)
- [ ] Phase 1: Dealer add mistri end-to-end
- [ ] Phase 2: Notification workflow (dealer linked you)
- [ ] Phase 3: Order lifecycle completion (mistri -> dealer -> decision)
- [ ] Phase 4: Dark mode removal (as requested)
- [ ] Phase 5: UX and navigation completeness
- [ ] Phase 6: New-user zero-state integrity
- [ ] Phase 7: OTP/reCAPTCHA stabilization
- [ ] Final smoke and sign-off

---

## Phase 0 - Data Contract Lock (Must Start Here)

### Goal
Create one consistent Firestore schema used across all roles and screens.

### Scope
- Canonical fields for linkage and ownership:
  - `dealerId`
  - `mistriId`
  - `assignedDealer` (if needed as denormalized map)
  - `status`
  - `createdAt`, `updatedAt`
- Align all reads/writes in:
  - `lib/services/firestore_service.dart`
  - `lib/providers/dealer_data_provider.dart`
  - `lib/providers/user_provider.dart`
  - `lib/providers/delivery_provider.dart`

### Deliverables
- One finalized field contract documented in code comments and used consistently.
- Backfill/migration strategy for old docs missing required fields.

### Acceptance Criteria
- A linked mistri appears correctly in dealer data and mistri profile/home using the same source fields.

---

## Phase 1 - Dealer Add Mistri End-to-End

### Goal
Make dealer-side mistri onboarding fully functional with Firestore persistence.

### Scope
- Implement real submit flow in dealer portal:
  - Validate phone
  - Create/attach user record
  - Persist linkage to dealer
- Idempotent behavior:
  - If user exists, attach link instead of duplicate account creation
- Wire UI refresh from stream/provider after add

### Likely Files
- `lib/screens/dealer/dealer_mistris_screen.dart`
- `lib/screens/dealer/dealer_home_screen.dart`
- `lib/providers/dealer_data_provider.dart`
- `lib/services/firestore_service.dart`

### Acceptance Criteria
- Dealer can add mistri by number.
- Firestore entry/link is created.
- Added mistri is visible immediately in dealer list.

---

## Phase 2 - Notification Workflow (Dealer Linked You)

### Goal
Notify linked mistri and display assigned dealer context on login.

### Scope
- Trigger notification when dealer-mistri link is created.
- Preferred architecture: backend trigger (Cloud Function) to avoid client-side trust issues.
- Fallback (if SMS not ready): FCM notification.
- Message should include dealer name/details.

### Outputs
- Notification payload contract
- Delivery path (SMS provider or FCM)

### Acceptance Criteria
- Linked mistri receives message/notification.
- On mistri login, dealer info is visible and accurate.

---

## Phase 3 - Order Lifecycle Completion

### Goal
Complete mistri -> dealer order path and dealer approvals.

### Scope
- Ensure mistri order create always includes correct `dealerId`.
- Dealer queue queries must return assigned orders only.
- Dealer approve/reject updates persist with audit fields.
- Mistri sees updated status after decision.

### Likely Files
- `lib/screens/mistri/mistri_request_order_screen.dart`
- `lib/screens/dealer/dealer_orders_screen.dart`
- `lib/screens/dealer/dealer_pending_approvals_screen.dart`
- `lib/services/firestore_service.dart`
- `lib/providers/dealer_data_provider.dart`

### Acceptance Criteria
- Mistri can place order successfully.
- Dealer sees order and can approve/reject.
- Mistri sees final status update.

---

## Phase 4 - Dark Mode Removal (Requested Direction)

### Goal
Remove unstable partial dark mode and keep consistent light UI for release.

### Scope
- Remove dark mode toggle from profile/settings UI.
- Force app theme to light mode.
- Keep settings model stable (do not break other settings fields).
- Remove dead references causing visual inconsistencies.

### Likely Files
- `lib/app.dart`
- `lib/providers/app_settings_provider.dart`
- `lib/screens/shared/profile_screen.dart`

### Acceptance Criteria
- No dark mode option visible.
- App appears consistent across all screens.
- No dark/light mismatch glitches.

---

## Phase 5 - UX and Navigation Completeness

### Goal
Resolve non-functional UI actions, overflow defects, and OTP success animation placement.

### Scope
- Fix overflow issues across impacted screens.
- Move OTP success tick animation to proper position between heading and phone text.
- Wire currently non-working actions in profile:
  - Privacy Policy
  - Terms of Service
  - Help & Support
  - Contact Support
  - Share App
- Fix no-op dashboard actions (build guide and similar cards).

### Likely Files
- `lib/screens/auth/otp_verification_screen.dart`
- `lib/screens/shared/profile_screen.dart`
- `lib/screens/mistri/mistri_home_screen.dart`
- `lib/screens/architect/architect_home_screen.dart`
- `lib/services/url_launcher_service.dart`

### Acceptance Criteria
- No critical overflow in tested flows.
- OTP success animation no longer overlays input area.
- All listed profile/support/share actions perform expected behavior.

---

## Phase 6 - New-User Zero-State Integrity

### Goal
Remove fake/hardcoded metrics for new users.

### Scope
- Replace static values with provider-driven live values.
- Show `0`/empty state for new users until real activity exists.
- Apply same logic across mistri, dealer, and architect dashboards/profile.

### Likely Files
- `lib/screens/shared/profile_screen.dart`
- `lib/screens/mistri/mistri_home_screen.dart`
- `lib/screens/dealer/dealer_home_screen.dart`
- `lib/screens/architect/architect_home_screen.dart`

### Acceptance Criteria
- New user accounts show realistic empty values, not fabricated stats.

---

## Phase 7 - OTP/reCAPTCHA Stabilization

### Goal
Improve OTP reliability and reduce friction while respecting Firebase verification rules.

### Scope
- Improve retry/cooldown UX.
- Improve error messages for verify-send-resend paths.
- Validate that SHA setup and app IDs remain aligned.
- Confirm OTP behavior on Android and iOS physical devices.

### Likely Files
- `lib/providers/auth_provider.dart`
- `lib/services/auth_service.dart`
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/otp_verification_screen.dart`

### Acceptance Criteria
- OTP send/verify/resend works reliably in normal network conditions.
- Human-check prompts are handled gracefully and do not dead-end user flow.

---

## Architect Parity Requirement (Apply During Phases 3/5/6)

### Goal
Any workflow completed for dealer/mistri must have architect parity where applicable.

### Scope
- Validate architect navigation and data-backed actions.
- Remove placeholder/no-op actions in architect dashboards.

### Likely Files
- `lib/screens/architect/architect_home_screen.dart`
- `lib/screens/architect/architect_projects_screen.dart`
- `lib/screens/architect/architect_shell_screen.dart`

---

## Cross-Platform Rule

All feature fixes above must be implemented in shared Flutter code unless explicitly platform-specific.

Platform-specific checks still required:
- Android: OTP and biometric behavior on real device
- iOS: signing, APNs, biometric prompt behavior, TestFlight validation

---

## Final Smoke and Release Sign-Off

### Runbook
Execute role-wise full smoke in `PRE_RELEASE_SMOKE_CHECKLIST.md` after all phases complete.

### Release Gate
Mark release as GO only when:
- All blocker rows are Pass
- Dealer-mistri-order lifecycle is fully working
- OTP and biometric critical paths are validated on physical devices
- iOS release prerequisites are validated (if iOS launch is included)

### Evidence
Store logs/screenshots/notes in:
- `release_evidence/2026-03-31/`

---

## Recommended Execution Order (Fastest Path)

1. Phase 0
2. Phase 1
3. Phase 3
4. Phase 2
5. Phase 4
6. Phase 5
7. Phase 6
8. Phase 7
9. Final smoke + sign-off

This order unblocks business flows first, then stabilizes UX and release confidence.

