# OTP + Notification Real-Device Validation

## Preconditions
- Android phone connected with USB debugging enabled.
- Firebase project configured for the app package and SHA fingerprints.
- App built from latest code (this branch includes structured trace logs).

## 1) Find connected device
```powershell
Set-Location "C:\Projects\tsl"
flutter devices
```

## 2) Run app on device with verbose app logs
```powershell
Set-Location "C:\Projects\tsl"
flutter run -d <deviceId>
```

## 3) Collect Android system logs in separate terminal
```powershell
adb logcat -v time | findstr /R "OTP:UI OTP: AUTH NOTIF"
```

## OTP Validation Checklist
- Open login and submit real phone number.
- Confirm logs appear in sequence:
  - `🧪[OTP:UI] submit phone=...`
  - `🧪[OTP:otp_<id>] codeSent phone=...`
- Enter OTP and confirm:
  - `🧪[OTP:UI] verify tapped phone=...`
  - `🧪[OTP:otp_<id>] verifyOtp started`
  - `✅[OTP:otp_<id>] verified uid=...`
- Test resend and confirm:
  - `🧪[OTP:UI] resend tapped phone=...`
  - `🧪[OTP:otp_<id>] codeSent phone=...`

## Notification/Auth Lifecycle Checklist
- Right after successful login:
  - `🧪[NOTIF] syncAuthState auth=true uid=...`
  - `🧪[NOTIF] subscribed topics for uid=...`
  - `✅ Loaded <n> notifications from Firestore for uid=...`
- Logout and confirm:
  - `🧪[AUTH] logout started uid=...`
  - `✅[AUTH] logout completed`
  - `🧪[NOTIF] syncAuthState auth=false uid=null current=...`
  - `🧪[NOTIF] cleared state for logged-out user`

## Pass Criteria
- OTP can be sent, verified, and resent on real number.
- Notification provider subscribes on login and clears/unsubscribes on logout.
- Notifications shown belong only to current logged-in `uid`.

