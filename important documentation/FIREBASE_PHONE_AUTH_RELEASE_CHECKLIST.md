# Firebase Phone Auth Release Checklist (10-15 min)

Use this checklist before every Android release to prevent OTP failures like:
- `missing-client-identifier`
- `Invalid PlayIntegrity token; app not Recognized by Play Store`
- forced reCAPTCHA loops

Project: `tsl-parivar`  
Android package: `com.tslsteel.parivar`

---

## 0) Quick Gate (Pass/Fail)

- [ ] Play app ID and package name are correct and unchanged.
- [ ] Firebase Android app package is `com.tslsteel.parivar`.
- [ ] Firebase has all required SHA fingerprints (debug + upload/release + Play App Signing).
- [ ] Phone sign-in is enabled in Firebase Authentication.
- [ ] One Play-installed test run sends OTP successfully.
- [ ] No `missing-client-identifier` or `Invalid PlayIntegrity token` in app log window during run.

If any item fails, do **not** ship.

---

## 1) Play Console (3-4 min)

Path: `Play Console -> App -> Test and release -> App integrity`

- [ ] Confirm **App signing key certificate** SHA-1 and SHA-256 are present.
- [ ] Confirm **Upload key certificate** SHA-1 and SHA-256 are present.
- [ ] Copy both SHA sets for comparison with Firebase.

Pass condition:
- All expected Play SHA fingerprints are visible and current.

---

## 2) Firebase Console (3-4 min)

Path: `Firebase Console -> Project settings -> Your apps -> Android app (com.tslsteel.parivar)`

- [ ] Verify package is exactly `com.tslsteel.parivar`.
- [ ] Verify SHA list includes:
  - debug SHA-1 + SHA-256 (for local QA only)
  - upload/release SHA-1 + SHA-256
  - Play App Signing SHA-1 + SHA-256
- [ ] Authentication -> Sign-in method -> `Phone` is enabled.

Pass condition:
- SHA coverage complete for your active build channel.

---

## 3) One Device Run (4-6 min)

Use a **Play-installed build** (Internal/Closed/Production track), not an adb sideload, for release sign-off.

```powershell
Set-Location "C:\Projects\tsl"
flutter devices
flutter run -d "<DEVICE_ID>" --no-resident
```

In app:
1. Open login.
2. Enter phone number.
3. Request OTP.
4. Complete verification.

Expected:
- OTP is sent.
- Login succeeds.
- No blocking verification errors.

Optional quick log check (if needed):

```powershell
& "C:\Users\ASUS\AppData\Local\Android\sdk\platform-tools\adb.exe" -s "<DEVICE_ID>" logcat -d -v time | findstr /I "missing-client-identifier PlayIntegrity Recaptcha FirebaseAuth OTP"
```

Pass condition:
- No `missing-client-identifier`.
- No `app not Recognized by Play Store`.
- OTP flow completes end-to-end.

---

## 4) Fast Triage Map (When It Fails)

### A) `missing-client-identifier`
Likely cause:
- App verification failed (identity/signing mismatch).

Check:
- Firebase app package name
- SHA coverage in Firebase
- install source (Play vs sideload)

Action:
1. Add missing SHA in Firebase.
2. Rebuild and install from correct channel.
3. Retry OTP.

### B) `Invalid PlayIntegrity token; app not Recognized by Play Store`
Likely cause:
- Build not recognized as Play-distributed trusted install.

Check:
- Build installed from Play Internal/Closed/Production
- Play App Signing SHA in Firebase

Action:
1. Publish/refresh test track build.
2. Install from Play Store listing for that track.
3. Retry OTP.

### C) reCAPTCHA appears every time
Likely cause:
- Automatic app verification not succeeding consistently.

Check:
- Same as A/B plus network stability

Action:
1. Fix SHA/channel mismatch first.
2. Validate again on Play-installed build.

---

## 5) Release Evidence (1 min)

Store in release notes/evidence:
- [ ] Screenshot: Play Console SHA section
- [ ] Screenshot: Firebase Android app SHA section
- [ ] Screenshot/video: OTP success on one real device
- [ ] Short text note: date, build version, tester, result

---

## 6) Team Rule (Permanent)

- Dev QA may use debug/sideload + test numbers.
- Release sign-off must use **Play-installed build** + real OTP smoke once.
- Any signing key rotation requires Firebase SHA update before QA starts.

