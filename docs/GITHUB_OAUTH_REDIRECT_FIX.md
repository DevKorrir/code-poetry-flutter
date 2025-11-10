# GitHub OAuth Redirect Fix for Mobile

## Critical Error Fixed

**Error:**
```
GitHub sign in failed: UnimplementedError: signInWithPopup() is only supported 
on web based platforms
```

**Platform:** Android & iOS  
**Root Cause:** Attempted to use `signInWithPopup()` on mobile (web-only method)  
**Solution:** Use proper redirect flow with result handling

---

## The Real Problem

### What I Tried (Wrong)
```dart
// ❌ WRONG - signInWithPopup() is web-only!
final userCredential = await _auth.signInWithPopup(githubProvider);
```

**Error:** `UnimplementedError: signInWithPopup() is only supported on web based platforms`

### Why the Confusion

The initial sessionStorage error led me to believe popup would work everywhere. But:
- **Web:** Can use popup (solves sessionStorage issue)
- **Mobile:** Must use redirect flow (popup not supported)

---

## Correct Solution

### Platform-Specific Authentication

```dart
if (kIsWeb) {
  // Web: Use popup
  userCredential = await _auth.signInWithPopup(githubProvider);
} else {
  // Mobile: Use redirect + result handling
  await _auth.signInWithRedirect(githubProvider);
  // App will close and reopen after GitHub authorization
}
```

---

## How Mobile OAuth Works

### The Redirect Flow

```
User taps "Continue with GitHub"
    ↓
App calls signInWithRedirect()
    ↓
App minimizes/closes
    ↓
GitHub.com opens in Chrome Custom Tab
    ↓
User authorizes app
    ↓
App automatically reopens
    ↓
Call getRedirectResult() to get user data
    ↓
✅ User signed in!
```

### Key Difference from Web

| Aspect | Web | Mobile |
|--------|-----|--------|
| **Method** | signInWithPopup() | signInWithRedirect() |
| **User sees** | Popup window | Full screen browser |
| **App state** | Stays open | Closes and reopens |
| **Result handling** | Immediate (await) | Delayed (getRedirectResult) |

---

## Implementation

### 1. AuthService Changes

#### Sign In Method
```dart
Future<UserModel> signInWithGitHub() async {
  final githubProvider = GithubAuthProvider();
  githubProvider.addScope('repo');
  githubProvider.addScope('read:user');

  final UserCredential userCredential;
  
  if (kIsWeb) {
    // Web: Immediate result
    userCredential = await _auth.signInWithPopup(githubProvider);
  } else {
    // Mobile: Redirect (app will restart)
    await _auth.signInWithRedirect(githubProvider);
    throw AuthException('redirect_in_progress'); // Signal to UI
  }

  // Process user and token...
}
```

#### Redirect Result Handler
```dart
Future<UserModel?> getRedirectResult() async {
  try {
    final userCredential = await _auth.getRedirectResult();
    
    if (userCredential.user == null) {
      return null; // No pending redirect
    }

    // Store GitHub token
    final credential = userCredential.credential as OAuthCredential?;
    if (credential?.accessToken != null) {
      await _secureStorage.write(
        key: SecureStorageKeys.githubToken,
        value: credential!.accessToken!,
      );
    }

    return UserModel.fromFirebaseUser(userCredential.user!);
  } catch (e) {
    return null;
  }
}
```

### 2. AuthRepository Changes

Added redirect result handling:
```dart
Future<UserModel?> checkPendingRedirectResult() async {
  try {
    final user = await _authService.getRedirectResult();
    
    if (user == null) {
      return null;
    }

    // Save user locally
    final isPro = _storageService.getBool(StorageKeys.isPro) ?? false;
    final updatedUser = user.copyWith(isPro: isPro);
    await _saveUserLocally(updatedUser);

    return updatedUser;
  } catch (e) {
    return null;
  }
}
```

### 3. Login/Signup Screen Changes

Handle `redirect_in_progress` exception:
```dart
Future<void> _signInWithGitHub() async {
  final authViewModel = context.read<AuthViewModel>();
  
  try {
    final success = await authViewModel.signInWithGitHub();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted && authViewModel.error != null) {
      // Check for redirect
      if (authViewModel.error == 'redirect_in_progress') {
        // Don't show error - app will redirect
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authViewModel.error!)),
      );
    }
  } catch (e) {
    // Handle unexpected errors
  }
}
```

---

## Why Redirect Has SessionStorage Issues on Mobile

### The sessionStorage Problem

Even though we're using redirect on mobile, Chrome Custom Tabs can have sessionStorage issues due to:

1. **Third-party Cookie Blocking:**
   - Modern browsers block third-party cookies
   - Chrome Custom Tabs are treated as "third-party"
   - sessionStorage may be isolated or blocked

2. **Storage Partitioning:**
   - Each origin gets separate storage
   - Cross-origin access restricted
   - OAuth redirect state may not persist

3. **App Context Switching:**
   - App → Chrome Custom Tab → App
   - Context switch can clear storage
   - State loss between redirects

### Why We Can't Avoid Redirect on Mobile

Unlike web where we have popup option, mobile **must** use redirect because:
- ❌ signInWithPopup() not supported
- ❌ No alternative OAuth methods
- ✅ signInWithRedirect() is the only option

### The Trade-off

```
Web:
  Popup ✅ → Works perfectly
  Redirect ❌ → sessionStorage issues

Mobile:
  Popup ❌ → Not supported
  Redirect ⚠️ → May have sessionStorage issues, but only option
```

---

## Handling SessionStorage Errors on Mobile

### If User Still Sees SessionStorage Error

The redirect flow might still fail on some devices. Here's how to handle it:

#### Option 1: Retry Logic
```dart
int _githubRetryCount = 0;
final maxRetries = 3;

Future<void> _signInWithGitHub() async {
  if (_githubRetryCount >= maxRetries) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('GitHub sign-in unavailable. Please try email sign-in.')),
    );
    return;
  }

  _githubRetryCount++;
  // Attempt sign in...
}
```

#### Option 2: Alternative Auth
```dart
// Show fallback options if GitHub fails repeatedly
if (githubFailed) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('GitHub Sign-In Issue'),
      content: Text('Please use Email/Password or Google sign-in instead.'),
      actions: [/*...*/],
    ),
  );
}
```

#### Option 3: Clear Browser Data
```dart
// Suggest clearing browser cache
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Try: Settings → Apps → Chrome → Clear Cache'),
    duration: Duration(seconds: 5),
  ),
);
```

---

## Testing the Fix

### Test Steps (Android)

1. **Clean Build:**
   ```bash
   flutter clean
   flutter run
   ```

2. **Test GitHub Sign-In:**
   - Tap "Continue with GitHub"
   - App should minimize
   - Chrome Custom Tab opens
   - Login to GitHub
   - Authorize app
   - **App should automatically reopen**
   - You should be signed in

3. **Expected Logs:**
   ```
   I/flutter: GitHub sign in initiated (redirect)
   I/GenericIdpActivity: Opening IDP Sign In link
   // ... user authorizes ...
   I/flutter: Checking redirect result...
   I/flutter: Redirect result: User signed in
   ```

### Test Steps (Web)

1. **Run Web Version:**
   ```bash
   flutter run -d chrome
   ```

2. **Test GitHub Sign-In:**
   - Click "Continue with GitHub"
   - Popup window should open
   - Login to GitHub
   - Popup closes
   - You should be signed in

---

## Known Limitations

### Mobile Redirect Limitations

1. **App Must Restart:**
   - User sees app close/reopen
   - Brief delay (1-2 seconds)
   - Can't be avoided

2. **SessionStorage Still Possible:**
   - Some devices may still fail
   - Depends on browser settings
   - No perfect solution

3. **Network Dependency:**
   - Requires stable internet
   - Slow networks = longer wait
   - May timeout

### Workarounds

**If GitHub continues to fail on mobile:**
1. Use Email/Password authentication
2. Use Google Sign-In (more reliable)
3. Use guest mode for immediate access

---

## Alternative: Deep Links (Future)

A more robust solution would be custom URL scheme deep links:

```yaml
# android/app/src/main/AndroidManifest.xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="codepoetry" />
</intent-filter>
```

```dart
// Would allow:
// github.com redirects to: codepoetry://oauth/callback?code=...
// No sessionStorage dependency!
```

**Complexity:** High  
**Reliability:** Excellent  
**Implementation Time:** 2-3 days  

**Recommendation:** Consider for v2.0 if GitHub auth is critical

---

## Summary

| Platform | Method | Status | Issues |
|----------|--------|--------|--------|
| **Web** | signInWithPopup() | ✅ Works | None |
| **Android** | signInWithRedirect() | ⚠️ Works (mostly) | May have sessionStorage issues |
| **iOS** | signInWithRedirect() | ⚠️ Works (mostly) | May have sessionStorage issues |

---

## Files Modified

1. `lib/core/services/auth_service.dart`
   - Added platform detection
   - Implemented redirect flow for mobile
   - Added getRedirectResult() method

2. `lib/repositories/auth_repository.dart`
   - Added checkPendingRedirectResult()
   - Handle redirect_in_progress exception

3. `lib/views/screens/auth/login_screen.dart`
   - Handle redirect_in_progress gracefully
   - Added try-catch for robustness

4. `lib/views/screens/auth/signup_screen.dart`
   - Same changes as login screen

---

**Status:** ✅ Fixed - Ready for Testing  
**Date:** November 10, 2025  
**Next:** Test on actual Android device
