# USEYI Monitor

USEYI Monitor is an Android-first Flutter attendance app for Upshift Youth Empowerment Initiative.

## What is included

- QR-code student attendance scanning.
- Student registration and QR display.
- Daily attendance sheet.
- Manual present/absent correction.
- CSV student import.
- CSV attendance export through the Android share sheet.
- Local offline storage using Hive CE.
- Staff PIN lock.
- Codemagic Android APK workflow.

## Important

The GitHub repository does **not** need a committed `android/` directory. Codemagic creates it using the Flutter SDK during the build. The repository root must contain `pubspec.yaml`, `lib/`, `assets/`, and `codemagic.yaml`.

## GitHub + Codemagic Android build

1. Create a new GitHub repository named `useyi-monitor` (or another name).
2. Upload the **contents of this project folder**, not the outer ZIP folder. `pubspec.yaml` and `codemagic.yaml` must be at the repository root.
3. Commit to the `main` branch.
4. In Codemagic, add the GitHub repository and select Flutter as the project type.
5. Select the `android-apk` workflow from `codemagic.yaml`.
6. Start the build.
7. Download `app-release.apk` from the successful build's Artifacts section.
8. Install that APK on an Android phone.

Codemagic automatically creates the Android project, adds the camera permission, installs the Flutter packages, runs `flutter analyze`, and builds the release APK.

## First app test

The first time the app opens, the default staff PIN is `1234`.

To test scanning:

1. Open **Students**.
2. Add a student, for example ID `3333`.
3. Tap the QR icon next to that student.
4. Display the QR code on another phone or screen.
5. Open **SCAN STUDENT** on the Android phone running USEYI Monitor.
6. Allow camera permission.
7. Scan the QR code.
8. The student should be marked PRESENT.

## Release signing

The first APK workflow is intentionally simple so you can get a working APK before setting up a production keystore. For Google Play or a long-term release process, create/upload an Android keystore in Codemagic and configure `android_signing` in the workflow. Keep the keystore private and keep a backup of it.


## Codemagic Android build
This repository is configured for an Android APK build with Codemagic. The Android platform is generated during the build, the camera permission is added safely to AndroidManifest.xml, Dart analysis is run without treating warnings/info diagnostics as fatal, and the release APK is collected from build/app/outputs/flutter-apk/.


## Codemagic Android build
This repository is configured for an Android release APK using the `android-apk` workflow in `codemagic.yaml`. The `test/` directory is intentionally omitted because the generated starter widget test referenced a non-existent `MyApp` class and is not required for the release APK.

## Accounts and multi-phone cloud data

The account system uses Firebase Authentication (email/password) and is designed for persistent sign-in. Firestore provides the shared cloud database and offline cache. A user can sign in on another phone and access the same cloud-backed USEYI data after synchronization.

### One-time Firebase setup

1. Create a Firebase project and add an Android app with package name `com.upshift.useyi_monitor`.
2. Enable **Authentication > Sign-in method > Email/Password**.
3. Create a **Cloud Firestore** database.
4. Create the first USEYI account from the app's **Create a new account** screen.
5. In Codemagic, add these environment variables to the workflow (do not commit them to GitHub):
   - `FIREBASE_API_KEY`
   - `FIREBASE_APP_ID`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_STORAGE_BUCKET` (optional)
   - `FIREBASE_AUTH_DOMAIN` (optional)
6. The workflow passes them to Flutter using `--dart-define`.

Firebase Auth keeps the signed-in session on the phone, so reopening the app does not require a new login. First-time login on a new phone needs internet. Firestore then caches data locally so the app can continue working offline and synchronize when connectivity returns.

For production, configure Firestore Security Rules so users can only read/write authorized USEYI data. Do not make the Firestore database public.

For the full Firebase account setup, see `FIREBASE_SETUP.md`.

## USEYI Monitor V3 — Monitoring upgrade

This version adds a clearer monitoring workflow:
- Programs screen: create and manage USEYI programs.
- Students remain registered once and can be used across all programs.
- Activities & Outcomes: record activities, outcomes, challenges and notes.
- Reports: choose a From/To date range and export attendance CSV.
- Cloud sync includes students, attendance, programs and activities when a Firebase account is signed in.
- Offline-first behavior remains available through Hive local storage.

### Recommended workflow
1. Create your USEYI programs.
2. Register each student once.
3. Open Attendance and scan the student's QR code.
4. Record program activities/outcomes after sessions.
5. Use Reports for a date range and export when needed.


## Offline Edition

USEYI Monitor Offline Edition is designed to work without internet. Student, attendance, program and activity data is stored locally on the device using Hive.

The drawer includes **App Information**, where staff can read the app description and use **Share App Information** to share the app details with other people.

Default offline staff PIN: **1234**. Change it from the lock icon after opening the app.
