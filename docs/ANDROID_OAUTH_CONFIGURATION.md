# Android OAuth Configuration with Manifest Placeholders

## Overview

This document explains how the Android OAuth deep link configuration uses build-time manifest placeholders to eliminate hardcoded values and make the configuration portable across different Firebase projects and environments.

## How It Works

### 1. Build Configuration (`android/app/build.gradle.kts`)

The build configuration automatically:
- Extracts the Firebase project ID from `google-services.json`
- Injects values into `AndroidManifest.xml` at build time using manifest placeholders
- Uses the `applicationId` for the custom URL scheme

### 2. Manifest Placeholders

Three placeholders are configured:

| Placeholder | Description | Source |
|------------|-------------|--------|
| `firebaseAuthHost` | Firebase Auth callback host (e.g., `codepoetry-80a07.firebaseapp.com`) | Extracted from `google-services.json` |
| `firebaseDynamicLinkHost` | Firebase Dynamic Links host (e.g., `codepoetry-80a07.page.link`) | Derived from Firebase project ID |
| `appAuthScheme` | Custom URL scheme for OAuth callbacks | Uses `applicationId` from `build.gradle.kts` |

### 3. AndroidManifest.xml

The manifest uses placeholder syntax `${placeholderName}` which gets replaced at build time:

```xml
<data android:host="${firebaseAuthHost}"/>
<data android:scheme="${appAuthScheme}"/>
```

## Benefits

### ✅ Portability
- No hardcoded values in the manifest
- Works automatically with different Firebase projects
- Easy to share across development teams

### ✅ Maintainability
- Single source of truth (`google-services.json` and `build.gradle.kts`)
- Changes to Firebase project automatically reflected
- No manual manifest editing required

### ✅ Build-time Configuration
- Values are injected during the build process
- No runtime configuration needed
- Type-safe and validated at build time

## Setup for New Projects

### Step 1: Add google-services.json

Place your `google-services.json` file in `android/app/` directory. The build script will automatically extract the project ID from it.

### Step 2: Update applicationId (if needed)

If your package name differs from `com.example.codepoetry`, update it in `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.yourcompany.yourapp"
    // ... other configuration
}
```

The custom URL scheme will automatically use this `applicationId`.

### Step 3: Customize Dynamic Links Host (optional)

If you've configured a custom domain for Firebase Dynamic Links, update the placeholder in `build.gradle.kts`:

```kotlin
manifestPlaceholders["firebaseDynamicLinkHost"] = "your-custom-domain.com"
```

## How Values Are Resolved

### Firebase Project ID

The build script reads `google-services.json` and extracts the `project_id`:

```json
{
  "project_info": {
    "project_id": "codepoetry-80a07"
  }
}
```

This is used to construct:
- `firebaseAuthHost`: `{projectId}.firebaseapp.com`
- `firebaseDynamicLinkHost`: `{projectId}.page.link`

### Application ID

The `applicationId` from `build.gradle.kts` is used directly as `appAuthScheme`. This ensures the custom URL scheme matches your package name.

## Fallback Behavior

If `google-services.json` is missing or cannot be read:
- The build script falls back to `codepoetry-80a07` as the default project ID
- You should update this fallback value for your project if needed

## Verification

After building, you can verify the values were injected correctly by checking the merged manifest:

```bash
# Build the app
flutter build apk --debug

# Check the merged manifest (Android Studio)
# Build → Analyze APK → AndroidManifest.xml
```

The placeholders should be replaced with actual values in the merged manifest.

## Troubleshooting

### Issue: OAuth redirects not working

1. **Verify google-services.json exists**: Check that `android/app/google-services.json` is present
2. **Check project ID**: Verify the project ID in `google-services.json` matches your Firebase project
3. **Verify applicationId**: Ensure `applicationId` in `build.gradle.kts` matches your package name
4. **Check Firebase Console**: Verify OAuth is configured in Firebase Console → Authentication → Sign-in method

### Issue: Build errors with placeholders

1. **Check syntax**: Ensure placeholder syntax is correct: `${placeholderName}`
2. **Verify build.gradle.kts**: Check that `manifestPlaceholders` are defined in `defaultConfig`
3. **Clean build**: Try `flutter clean && flutter build apk`

## Migration from Hardcoded Values

If you're migrating from hardcoded values:

1. **Remove hardcoded values** from `AndroidManifest.xml`
2. **Add placeholders** using `${placeholderName}` syntax
3. **Configure placeholders** in `build.gradle.kts`
4. **Test the build** to ensure values are injected correctly

## Related Files

- `android/app/build.gradle.kts` - Build configuration with placeholder definitions
- `android/app/src/main/AndroidManifest.xml` - Manifest using placeholders
- `android/app/google-services.json` - Firebase configuration (source of project ID)
- `docs/ANDROID_OAUTH_SETUP.md` - Original setup documentation (now obsolete)

## References

- [Android Manifest Placeholders](https://developer.android.com/studio/build/manifest-build-variables)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Android App Links](https://developer.android.com/training/app-links)

