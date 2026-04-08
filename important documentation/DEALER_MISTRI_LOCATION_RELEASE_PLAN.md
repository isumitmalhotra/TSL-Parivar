# Dealer-Mistri, Profile Completion, and Map Flow - Analysis and Implementation Plan

Date: 2026-04-08
Scope: Android + iOS (shared Flutter codebase)

## 1) Current State Analysis (from codebase)

### A. Dealer -> Add Mistri fails with `permission-denied`

What is already present:
- Add/link flow exists in `lib/providers/dealer_data_provider.dart` (`addMistriForDealer`) and `lib/services/firestore_service.dart` (`addOrLinkMistriToDealer`).
- Firestore rules already allow dealer writes on `mistris` docs in `firestore.rules` under `match /mistris/{mistriId}`.

Likely root causes:
1. Role source mismatch in rules:
   - Rules use `effectiveRole()` and prioritize token role over profile role (`firestore.rules` line area around `effectiveRole`).
   - If token role and `users/{uid}.role` diverge, client-side role check may pass but write is denied by rules.
2. Dealer profile/data readiness race:
   - Write can happen before all dealer identity invariants are stable in runtime state.
3. Non-deterministic identity model for mistri IDs:
   - Linking can target `mistri_<digits>` or `uid`, increasing edge cases when reassignment/upgrade happens.

### B. Mandatory profile completion popup after login is missing

What is already present:
- Profile editing exists in `lib/screens/shared/profile_screen.dart` and `lib/providers/user_provider.dart`.
- Router guard logic exists in `lib/navigation/app_router.dart`.

Gap:
- No hard gate that blocks role-home until required fields are completed.
- No enforced location capture step after first login.

### C. Dealer cannot discover nearby registered mistris

What is already present:
- Dealer list screen and tabs exist in `lib/screens/dealer/dealer_mistris_screen.dart`.
- Dealer-owned mistri streaming exists (`streamDealerMistris`).

Gap:
- No discovery query for nearby unassigned/other mistris.
- No geospatial fields (`GeoPoint`, geohash/radius strategy) currently used in user/mistri docs.

### D. Map pin + exact delivery location flow is incomplete

What is already present:
- Generic location picker component exists (`lib/widgets/tsl_location_picker.dart`).
- Geolocation service exists (`lib/services/location_service.dart`).

Gaps:
- `TslLocationPicker` map is still a placeholder card, not an interactive map.
- Order request uses static location text (`Sector 62, Noida, UP`) in `lib/screens/mistri/mistri_request_order_screen.dart`.
- No required lat/lng + address persistence contract for orders/deliveries.

## 2) Target Functional Requirements

1. Dealer can add/link mistri without permission failures when account role is valid.
2. First login forces user through profile-completion flow before home access.
3. Profile completion must include:
   - name
   - address line
   - city/locality
   - precise GPS capture (lat/lng)
4. Dealer can browse nearby registered mistris and request/link them.
5. Mistri/Dealer/Architect order and delivery flows support map pinning + human-readable address.
6. Works consistently on Android and iOS with shared Dart code (platform differences only in permissions/config).

## 3) Strong Fix Plan (Phased)

## Phase 0 - Safety Baseline and Evidence (must-do first)

Tasks:
- Add structured error logging around add-mistri write path (code + Firebase logs tagging).
- Capture one reproducible scenario for `permission-denied` with:
  - uid
  - users role
  - token role (if available)
  - target mistri document id
- Freeze a small test matrix (dealer fresh login, dealer relogin, dealer after role switch).

Files:
- `lib/providers/dealer_data_provider.dart`
- `lib/services/firestore_service.dart`

Exit criteria:
- One deterministic failing trace captured and documented.

## Phase 1 - Permission-Denied Hard Fix (auth/rules/data contract)

Tasks:
1. Normalize role authority model:
   - Prefer `users/{uid}.role` for client + rules consistency, or ensure token role is always synchronized before protected writes.
2. Make add-mistri path atomic and deterministic:
   - Validate dealer role once.
   - Resolve canonical mistri identity order: existing uid-linked doc > phone-linked doc > invite doc.
3. Add explicit preflight guard:
   - If dealer role mismatch, fail fast with specific message (not generic permission text).
4. Optional hardening (recommended):
   - Move sensitive link/reassign operation to callable Cloud Function for server-side auth checks and audit log.

Rules and schema checks:
- `firestore.rules`: tighten `mistris` update condition to prevent unauthorized cross-dealer takeover unless allowed by business rules.
- Ensure `users` and `mistris` role/owner fields are not mutable by unintended clients.

Files:
- `firestore.rules`
- `lib/services/firestore_service.dart`
- `lib/providers/dealer_data_provider.dart`

Exit criteria:
- Dealer add mistri succeeds for valid dealer account in 3/3 test scenarios.
- No `permission-denied` for valid path.

## Phase 2 - Mandatory Profile Completion Gate

Tasks:
1. Add profile completeness checker service:
   - required fields + valid location coordinates.
2. Add route guard:
   - After OTP success, redirect incomplete users to completion screen before role-home.
3. Build dedicated `ProfileCompletionScreen` (first-login UX):
   - autofocus mandatory fields
   - block skip
   - explicit save-and-continue

Files:
- `lib/navigation/app_router.dart`
- `lib/providers/user_provider.dart`
- new: `lib/screens/auth/profile_completion_screen.dart`
- optional helper: `lib/services/profile_completeness_service.dart`

Exit criteria:
- New user cannot reach home without completing required profile + location.
- Existing complete users are not blocked.

## Phase 3 - Geo Data Model and Firestore Contract

Tasks:
1. Add canonical fields to `users` and `mistris` docs:
   - `geo: {lat, lng}` or Firestore `GeoPoint`
   - `addressLine`, `city`, `pincode`, `locationUpdatedAt`
2. Add normalized search helpers:
   - city key/lowercase fields for fallback filtering.
3. Add/adjust indexes for nearby and role-filtered queries.

Files:
- `firestore.indexes.json`
- `firestore.rules`
- `lib/models/shared_models.dart`
- `lib/services/firestore_service.dart`

Exit criteria:
- All required fields persist and can be queried without index/runtime failures.

## Phase 4 - Dealer Nearby Mistri Discovery + Attach Flow

Tasks:
1. Add a second tab/section on dealer mistri screen:
   - "Nearby Registered Mistris"
2. Query strategy:
   - Initial: city/locality based + optional distance sort client-side
   - Upgrade: geohash/radius query for true nearby
3. Actions:
   - View profile card
   - Send link request / attach under dealer
   - Prevent duplicate ownership confusion

Files:
- `lib/screens/dealer/dealer_mistris_screen.dart`
- `lib/providers/dealer_data_provider.dart`
- `lib/services/firestore_service.dart`

Exit criteria:
- Dealer can see nearby registered mistris and link from UI.
- Linked mistri appears in dealer-owned stream after action.

## Phase 5 - Real Map Pinning for Order/Delivery

Tasks:
1. Replace placeholder with interactive map picker in `TslLocationPicker`.
2. Integrate map picker into order create and delivery assignment forms.
3. Save both:
   - map coordinates (lat/lng)
   - formatted address (reverse geocoded or manual corrected)
4. Validate at submit:
   - reject empty/invalid location payload.

Files:
- `lib/widgets/tsl_location_picker.dart`
- `lib/screens/mistri/mistri_request_order_screen.dart`
- dealer/architect order or delivery screens (where assignment is created)
- `lib/services/location_service.dart`

Dependencies (likely):
- `google_maps_flutter`
- optional geocoding helper improvements

Exit criteria:
- Orders/deliveries are created with valid coordinates + address.
- Dealer can read destination reliably and navigate.

## Phase 6 - UX/Validation/Regression Hardening

Tasks:
- Overflow cleanup in updated forms/lists.
- Improve user-facing errors (role mismatch vs permission vs network).
- Add tests:
  - router guard test for profile completion gate
  - dealer add mistri provider tests for role mismatch/permission states
  - location validation unit tests

Files:
- `test/navigation/app_router_guard_test.dart` (+ new tests)
- provider/service tests

Exit criteria:
- No critical overflow in target flows.
- Tests cover new guard and add-mistri failures.

## 4) Platform Notes (Android + iOS)

Android:
- Verify location permission prompts and background behavior.
- If maps SDK used, verify API key and manifest config.

iOS:
- Add `NSLocationWhenInUseUsageDescription` (and related keys if needed) in `Info.plist`.
- Verify CocoaPods sync and map API key injection if using native map SDK.

Shared:
- Same Dart business logic for role gating, profile completeness, linking, and payload validation.

## 5) QA Acceptance Matrix (Release Blocking)

1. Dealer add mistri
- Dealer adds new phone -> pending invite created.
- Existing registered mistri phone -> linked successfully.
- No permission denied for valid dealer.

2. Mandatory completion gate
- Fresh login redirects to completion screen.
- Cannot skip required fields.
- Home accessible only after save.

3. Nearby discovery
- Dealer sees nearby list (non-empty when eligible users exist).
- Link action updates both UI and Firestore relation.

4. Map + location
- User can pick pin + edit address.
- Order submit blocked if location invalid.
- Dealer sees correct destination address/coords.

## 6) Execution Order Recommendation

1. Phase 0 -> Phase 1 (stop permission-denied first)
2. Phase 2 -> Phase 3 (enforce complete profile contract)
3. Phase 4 -> Phase 5 (discovery + map-enabled operations)
4. Phase 6 (regression hardening + test locks)

---

If you want, next step I can convert this plan directly into an executable Phase 1 patch set (exact file diffs + rollout checklist) so we start fixing immediately without extra rounds.
