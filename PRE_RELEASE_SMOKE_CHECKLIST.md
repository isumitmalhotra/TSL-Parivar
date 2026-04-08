# Pre-Release Smoke Checklist (Role-Wise)

Use this checklist for final pre-release validation and QA sign-off.

## Build and Environment

- [x] Build type verified: `Release Candidate` (2026-03-31 validation run)
- [x] App version / build number verified: `1.0.0+1` (from `pubspec.yaml`)
- [x] Backend target verified (Firebase project/env): `tsl-parivar` (Android/iOS Firebase config + `lib/firebase_options.dart`)
- [ ] Test accounts available for all roles (`mistri`, `dealer`, `architect`)
- [ ] Network and push permission state noted

## Pass/Fail Legend

- **Pass**: Actual behavior matches expected behavior exactly.
- **Fail**: Any mismatch, crash, freeze, or wrong redirect.
- **Blocker**: Fail that prevents release.

## Global Smoke (All Roles)

| ID | Scenario | Steps | Expected Result | Actual Result | Status (Pass/Fail) | Evidence / Notes |
|---|---|---|---|---|---|---|
| G-01 | Unauthenticated access to protected route | Launch fresh app (logged out) and open `/dealer` or `/mistri` deep link | Redirects to `/role-selection` | Redirect rule returns `/role-selection` for protected routes | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`unauthenticated user is redirected from protected route`) |
| G-02 | Authenticated user hits public auth route | Log in as any role, then open `/login` | Redirects to role home (`/mistri`, `/dealer`, or `/architect`) | Redirect rule returns role home from public auth route | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated user is redirected away from public auth route`) |
| G-03 | Authenticated user with missing role state | Simulate authenticated session with null role and open a protected route | Redirects to `/role-selection` | Redirect rule returns `/role-selection` when role is null | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated user without role is redirected to role selection`) |
| G-04 | Shared protected route access | Log in and open `/products` | Route is allowed (no redirect loop) | Redirect rule allows shared protected path | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`shared protected route is allowed for authenticated user`) |
| G-05 | Profile role param mismatch correction | Log in as dealer and open `/profile/mistri` | Redirects to `/profile/dealer` | Redirect rule corrects profile path to authenticated role | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`profile role mismatch is corrected to authenticated role`) |
| G-06 | Unknown protected route fallback | Log in as architect and open unsupported path (example: `/unsupported/route`) | Redirects to `/architect` | Redirect rule falls back to role home | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated unknown protected route falls back to role home`) |
| G-07 | Profile dark-mode contrast | Log in as each role -> open profile -> toggle dark mode | All profile text/cards/dialogs remain readable in dark mode | Patched in code; device verification pending | Fail | Manual smoke pending on Android+iOS |
| G-08 | Biometric toggle UX | Open profile settings -> enable/disable biometric | Enable/disable shows success/failure message and safe fallback | Patched in code; device verification pending | Fail | Manual smoke pending on biometric-capable device |

## Dealer Role Smoke

| ID | Scenario | Steps | Expected Result | Actual Result | Status (Pass/Fail) | Evidence / Notes |
|---|---|---|---|---|---|---|
| D-01 | Dealer login happy path | Role select `dealer` -> login -> OTP verify | Lands on `/dealer` | Not executed on device in this run | Fail | Manual smoke pending (requires test account + OTP flow evidence) |
| D-02 | Dealer home loads | Open dealer home | Shell renders without crash; default tab visible | Not executed on device in this run | Fail | Manual smoke pending |
| D-03 | Dealer can access dealer features | Navigate to `/dealer/orders`, `/dealer/mistris`, `/dealer/pending-approvals`, `/dealer/rewards` | All dealer routes open correctly | Not executed on device in this run | Fail | Manual smoke pending |
| D-04 | Dealer blocked from Mistri area | Open `/mistri` while logged in as dealer | Redirects to `/dealer` | Redirect rule returns `/dealer` | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated dealer cannot access mistri routes`) |
| D-05 | Dealer blocked from Architect area | Open `/architect` while logged in as dealer | Redirects to `/dealer` | Redirect rule returns `/dealer` | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated dealer cannot access architect routes`) |
| D-06 | Dealer shared routes | Open `/notifications`, `/products`, `/profile/dealer`, `/chat/<id>` | All allowed and usable | Not executed on device in this run | Fail | Manual smoke pending |

## Mistri Role Smoke

| ID | Scenario | Steps | Expected Result | Actual Result | Status (Pass/Fail) | Evidence / Notes |
|---|---|---|---|---|---|---|
| M-01 | Mistri login happy path | Role select `mistri` -> login -> OTP verify | Lands on `/mistri` | Not executed on device in this run | Fail | Manual smoke pending |
| M-02 | Mistri home loads | Open mistri home | Shell renders without crash; default tab visible | Not executed on device in this run | Fail | Manual smoke pending |
| M-03 | Mistri can access mistri features | Navigate to `/mistri/deliveries`, `/mistri/rewards`, `/mistri/request-order` | All mistri routes open correctly | Not executed on device in this run | Fail | Manual smoke pending |
| M-04 | Mistri delivery detail and POD | Open `/mistri/deliveries/:id` then `/mistri/deliveries/:id/pod` | Detail and POD screens load | Not executed on device in this run | Fail | Manual smoke pending (real delivery data required) |
| M-05 | Mistri blocked from Dealer area | Open `/dealer` while logged in as mistri | Redirects to `/mistri` | Redirect rule returns `/mistri` | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated mistri cannot access dealer routes`) |
| M-06 | Mistri blocked from Architect area | Open `/architect` while logged in as mistri | Redirects to `/mistri` | Redirect rule returns `/mistri` | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated mistri cannot access architect routes`) |
| M-07 | Mistri shared routes | Open `/notifications`, `/products`, `/profile/mistri`, `/chat/<id>` | All allowed and usable | Not executed on device in this run | Fail | Manual smoke pending |

## Architect Role Smoke

| ID | Scenario | Steps | Expected Result | Actual Result | Status (Pass/Fail) | Evidence / Notes |
|---|---|---|---|---|---|---|
| A-01 | Architect login happy path | Role select `architect` -> login -> OTP verify | Lands on `/architect` | Not executed on device in this run | Fail | Manual smoke pending |
| A-02 | Architect home loads | Open architect home | Shell renders without crash; default tab visible | Not executed on device in this run | Fail | Manual smoke pending |
| A-03 | Architect can access architect features | Navigate to `/architect/projects`, `/architect/create-spec`, `/architect/rewards` | All architect routes open correctly | Not executed on device in this run | Fail | Manual smoke pending |
| A-04 | Architect blocked from Dealer area | Open `/dealer` while logged in as architect | Redirects to `/architect` | Redirect rule returns `/architect` | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated architect cannot access dealer routes`) |
| A-05 | Architect blocked from Mistri area | Open `/mistri` while logged in as architect | Redirects to `/architect` | Redirect rule returns `/architect` | Pass | Automated: `test/navigation/app_router_guard_test.dart` (`authenticated architect cannot access mistri routes`) |
| A-06 | Architect shared routes | Open `/notifications`, `/products`, `/profile/architect`, `/chat/<id>` | All allowed and usable | Not executed on device in this run | Fail | Manual smoke pending |

## Exit Criteria

- [ ] No blocker failures in global + role-wise smoke checks
- [ ] Login/OTP and role-based redirect paths validated
- [ ] Shared routes validated for each role
- [ ] Profile dark-mode contrast + biometric UX rows (`G-07`, `G-08`) validated on device
- [x] Any non-blocker issues logged with severity and owner (see `release_evidence/2026-03-31/RELEASE_READINESS_REPORT.md`)

## Release Sign-Off

| Role | Name | Date | Decision (Go/No-Go) | Notes |
|---|---|---|---|---|
| QA Owner |  |  |  |  |
| Engineering Owner |  |  |  |  |
| Product Owner (optional) |  |  |  |  |
