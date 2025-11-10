# Android OAuth Deep Link Setup

## Find Your Firebase Project ID

### Method 1: Firebase Console
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Click the gear icon → Project settings
4. Your Project ID is shown (e.g., `codepoetry-12345`)

### Method 2: google-services.json
1. Open `android/app/google-services.json`
2. Find `"project_id": "YOUR_PROJECT_ID"`

---

## Update AndroidManifest.xml

Replace `codepoetry.firebaseapp.com` with your actual Firebase project host:

**File:** `android/app/src/main/AndroidManifest.xml`

**Find this line (around line 43):**
```xml
<data
    android:scheme="https"
    android:host="codepoetry.firebaseapp.com"
    android:path="/__/auth/handler"/>
```

**Replace with your project:**
```xml
<data
    android:scheme="https"
    android:host="YOUR-PROJECT-ID.firebaseapp.com"
    android:path="/__/auth/handler"/>
```

**Example:**
If your project ID is `my-app-12345`, use:
```xml
android:host="my-app-12345.firebaseapp.com"
```

---

## Update Package Name (if needed)

**Find this line (around line 52):**
```xml
<data android:scheme="com.example.codepoetry"/>
```

**If your package name is different**, check:
1. Open `android/app/build.gradle`
2. Find `applicationId` (e.g., `com.mycompany.codepoetry`)
3. Update the scheme to match

---

## Rebuild the App

After updating the manifest:

```bash
# Clean build
flutter clean

# Rebuild
flutter run

# Or if that doesn't work, uninstall first
flutter run --uninstall-only
flutter run
```

---

## Test GitHub OAuth

1. Tap "Continue with GitHub"
2. **Expected:** Chrome Custom Tab opens
3. Login to GitHub
4. Authorize app
5. **Expected:** Chrome Custom Tab closes, app reopens
6. You should be signed in!

---

## If Chrome Custom Tab Still Doesn't Open

### Check these:

1. **Internet Permission** ✅ (already added)
2. **Intent Filters** ✅ (already added)
3. **Firebase Project ID** ⚠️ (you need to update)
4. **Package Name** ⚠️ (verify it matches)

### Debug Steps:

**Check Logcat for errors:**
```bash
adb logcat | grep -i firebase
```

**Look for:**
- `FirebaseAuth: Signing in with redirect`
- `GenericIdpActivity: Opening IDP Sign In link`
- Any error messages

---

## Common Errors

### Error: "Activity not found"
**Fix:** Intent filter package name doesn't match app package name

### Error: "Redirect failed"
**Fix:** Firebase host in intent filter doesn't match actual project

### Error: Chrome Custom Tab doesn't open
**Fix:** 
1. Verify internet permission
2. Check if Chrome is installed
3. Try uninstalling and reinstalling app

---

## Alternative: Check Your Current Package Name

Run this command:
```bash
grep "applicationId" android/app/build.gradle
```

Output will show your package name (e.g., `com.example.codepoetry`)

---

## Quick Fix Script

I'll create a script to help you find and replace automatically...
