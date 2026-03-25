# Firebase Production Deployment Verification

This checklist verifies production deployment for Firestore rules, indexes, and Storage rules.

## 1) Install Firebase CLI (if missing)
```powershell
npm install -g firebase-tools
firebase --version
```

## 2) Login and select target project
```powershell
firebase login
Set-Location "C:\Projects\tsl"
firebase use <your-project-id>
```

## 3) Deploy backend config from repo
```powershell
Set-Location "C:\Projects\tsl"
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## 4) Validate rules and indexes in console
- Firestore Rules: confirm latest `firestore.rules` content deployed.
- Firestore Indexes: confirm composite indexes include:
  - `notifications`: `userId` + `timestamp desc`
  - `chats`: `participantIds array_contains` + `lastMessageAt desc`
- Storage Rules: confirm `storage.rules` deployment timestamp is current.

## 5) Runtime verification in app
- Login as user A and user B on separate devices.
- Verify:
  - user A cannot read user B profile/notifications/chats unless participant.
  - chat appears only for participants.
  - notification queries for current `uid` succeed without index errors.

## 6) Required deploy artifacts in repo
- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`
- `storage.rules`

