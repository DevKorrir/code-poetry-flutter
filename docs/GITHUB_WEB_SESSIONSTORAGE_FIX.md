# GitHub OAuth sessionStorage Error on Web - Complete Fix

## The Error (On Web Browsers)

```
Unable to process request due to missing initial state. This may happen if browser 
sessionStorage is inaccessible or accidentally cleared. Some specific scenarios are - 
1) Using IDP-Initiated SAML SSO. 
2) Using signInWithRedirect in a storage-partitioned browser environment.
```

**Platform:** Web browsers (Chrome, Firefox, Safari, Edge)  
**When:** After clicking "Continue with GitHub" and authorizing

---

## Current Implementation (Correct)

The code IS using `signInWithPopup()` for web:

```dart
if (kIsWeb) {
  userCredential = await _auth.signInWithPopup(githubProvider);
}
```

**So why is it still failing?** → Firebase Console configuration issues!

---

## Root Cause Analysis

### Why signInWithPopup Can Still Fail

Even though popup avoids the redirect sessionStorage issue, it can still fail if:

1. ❌ **Firebase authorized domains not configured**
2. ❌ **GitHub OAuth callback URL mismatch**
3. ❌ **Third-party cookies blocked** (even popups need cookies)
4. ❌ **Browser extensions blocking** (uBlock, Privacy Badger, etc.)
5. ❌ **CORS issues** (cross-origin restrictions)

---

## Step-by-Step Fix

### Step 1: Configure Firebase Authorized Domains

**Location:** Firebase Console → Authentication → Settings → Authorized domains

**Add these domains:**
```
localhost
127.0.0.1
*.firebaseapp.com (if using Firebase Hosting)
your-custom-domain.com (if deployed elsewhere)
```

**How to add:**
1. Click "Add domain"
2. Type `localhost`
3. Click "Add"
4. Repeat for other domains

**Why this matters:** Firebase blocks OAuth popups from unauthorized domains for security.

---

### Step 2: Verify GitHub OAuth Provider

**Location:** Firebase Console → Authentication → Sign-in method → GitHub

**Check configuration:**
- ✅ Status: **Enabled**
- ✅ Client ID: (from GitHub OAuth App)
- ✅ Client Secret: (from GitHub OAuth App)
- ✅ **Copy the callback URL shown** (you'll need it next)

**Example callback URL:**
```
https://your-project-12345.firebaseapp.com/__/auth/handler
```

---

### Step 3: Configure GitHub OAuth App

**Location:** GitHub.com → Settings → Developer settings → OAuth Apps → [Your App]

**Critical Settings:**

1. **Application name:** CodePoetry (or your app name)

2. **Homepage URL:**
   ```
   http://localhost:5000
   ```
   (Or your production URL if deployed)

3. **Authorization callback URL:** **MUST MATCH Firebase callback URL exactly!**
   ```
   https://your-project-12345.firebaseapp.com/__/auth/handler
   ```

**Common mistake:** Callback URL doesn't match → OAuth fails!

---

### Step 4: Browser Configuration

#### Allow Third-Party Cookies (Temporarily for Testing)

**Chrome:**
1. Settings → Privacy and security → Cookies and other site data
2. Select "Allow all cookies" (temporarily)
3. Test GitHub sign-in
4. If it works, configure exceptions instead of allowing all

**Firefox:**
1. Settings → Privacy & Security
2. Set "Standard" or "Custom" tracking protection
3. Uncheck "Cookies" under Custom
4. Test GitHub sign-in

**Safari:**
1. Preferences → Privacy
2. Uncheck "Prevent cross-site tracking" (temporarily)
3. Test GitHub sign-in

#### Allow Popups

Make sure your browser allows popups from `localhost` or your domain.

**Chrome:**
1. Address bar → Click icon to right
2. "Always allow popups from localhost"

---

### Step 5: Test in Different Browsers

Try in this order:
1. ✅ **Chrome (regular mode)** - Start here
2. ✅ **Chrome (Incognito)** - Tests without extensions
3. ✅ **Firefox** - Different engine
4. ✅ **Edge** - Chromium-based

If it works in one but not others → Browser-specific settings issue

---

## Verification Checklist

Before testing, verify ALL of these:

### Firebase Console
- [ ] GitHub provider is **Enabled**
- [ ] Client ID is entered correctly
- [ ] Client Secret is entered correctly
- [ ] `localhost` is in Authorized domains
- [ ] Your domain (if deployed) is in Authorized domains

### GitHub OAuth App
- [ ] Callback URL matches Firebase **exactly**
- [ ] Homepage URL is set
- [ ] App is not suspended/disabled

### Browser
- [ ] Cookies enabled (at least for testing)
- [ ] Popups allowed
- [ ] No blocking extensions (temporarily disable)
- [ ] Browser cache cleared

### Code
- [ ] Using `signInWithPopup()` for web (already correct ✅)
- [ ] Error handling in place (already correct ✅)

---

## Testing Procedure

### Run Web Version

```bash
flutter run -d chrome --web-port=5000
```

**Why port 5000?** Matches the GitHub OAuth homepage URL

### Test Sign-In

1. Click "Continue with GitHub"
2. **Expected:** Popup window opens
3. Login to GitHub (if not already)
4. Click "Authorize [Your App]"
5. **Expected:** Popup closes, you're signed in
6. **Actual:** ???

### Check Browser Console

Open DevTools (F12) → Console tab

**Look for errors:**
```javascript
// Bad - Configuration issue
Failed to get redirect result: FirebaseError: 
  [auth/unauthorized-domain] This domain is not authorized

// Bad - GitHub OAuth mismatch
OAuth redirect URI mismatch

// Good - No errors
Firebase Auth: User signed in
```

---

## Common Errors & Solutions

### Error: "This domain is not authorized"

**Cause:** Domain not in Firebase Authorized domains  
**Fix:** Add `localhost` and your domain to Authorized domains in Firebase Console

### Error: "redirect_uri_mismatch"

**Cause:** GitHub OAuth callback URL doesn't match Firebase  
**Fix:** Copy callback URL from Firebase Console → Paste in GitHub OAuth App settings

### Error: "Popup closed by user"

**Cause:** User closed popup or popup was blocked  
**Fix:** 
- Allow popups in browser
- Don't close popup manually
- Check popup blocker settings

### Error: "Network error" / "Failed to fetch"

**Cause:** CORS or network connectivity  
**Fix:**
- Check internet connection
- Disable VPN temporarily
- Check firewall settings

### Error: Still showing sessionStorage error

**Cause:** Browser still using redirect instead of popup  
**Fix:**
- Clear browser cache completely
- Hard refresh (Ctrl+Shift+R)
- Try different browser

---

## Alternative: Test with Firebase Hosting

If localhost is causing issues, deploy to Firebase Hosting for testing:

```bash
# Build web app
flutter build web

# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

**Benefits:**
- ✅ Uses Firebase domain (automatically authorized)
- ✅ Eliminates localhost configuration issues
- ✅ Tests production-like environment

---

## Debug Mode

Add debug logging to see what's happening:

```dart
Future<UserModel> signInWithGitHub() async {
  try {
    final githubProvider = GithubAuthProvider();
    githubProvider.addScope('repo');
    githubProvider.addScope('read:user');

    if (kIsWeb) {
      print('🌐 Web: Attempting signInWithPopup...');
      githubProvider.setCustomParameters({'allow_signup': 'true'});
      
      try {
        final userCredential = await _auth.signInWithPopup(githubProvider);
        print('✅ Popup successful!');
        // ... rest of code
      } catch (popupError) {
        print('❌ Popup failed: $popupError');
        rethrow;
      }
    }
    // ... rest
  }
}
```

**Check console for:**
- 🌐 = Popup attempt started
- ✅ = Success
- ❌ = Shows exact error

---

## Still Not Working? Try This

### Nuclear Option: Use Google Sign-In Instead

If GitHub OAuth continues to fail, Google Sign-In is more reliable:

```dart
// Google is already working in your app
await authViewModel.signInWithGoogle();
```

**Why Google is easier:**
- More permissive CORS policies
- Better browser support
- Fewer configuration gotchas
- Google Sign-In package handles complexities

### Temporary Workaround: Email/Password

While debugging GitHub, users can use:
- Email/Password registration
- Google Sign-In
- Guest mode

Then connect GitHub later from settings.

---

## Production Checklist

Before deploying to production:

### Firebase
- [ ] Production domain added to Authorized domains
- [ ] GitHub OAuth configured with production callback URL
- [ ] All secrets stored securely (not in code)

### GitHub OAuth App
- [ ] Production callback URL configured
- [ ] Production homepage URL set
- [ ] App is public/approved for users

### Testing
- [ ] Tested on multiple browsers
- [ ] Tested on mobile browsers (Chrome, Safari)
- [ ] Tested with third-party cookie blocking
- [ ] Tested in incognito/private mode

---

## Technical Deep Dive

### Why sessionStorage Fails

**The Problem:**
```javascript
// Firebase does this internally:
sessionStorage.setItem('firebase:pending_redirect', state);
// Later, after GitHub redirect:
const state = sessionStorage.getItem('firebase:pending_redirect');
// → Can be null if:
//   - Browser blocks sessionStorage
//   - Storage cleared
//   - Cross-origin isolation
```

**With Popup:**
```javascript
// Popup stays on same origin
// No sessionStorage needed
// State maintained in JavaScript memory
// → More reliable!
```

### Browser Compatibility

| Browser | signInWithPopup | Notes |
|---------|-----------------|-------|
| **Chrome** | ✅ Excellent | Best support |
| **Firefox** | ✅ Excellent | Good privacy controls |
| **Safari** | ⚠️ Good | Can block third-party cookies |
| **Edge** | ✅ Excellent | Chromium-based |
| **Brave** | ⚠️ Fair | Aggressive privacy blocking |

---

## Summary

### The Real Fix (Not Just Code)

The code is correct. The issue is **configuration**:

1. ✅ **Code:** Using `signInWithPopup()` on web
2. ❌ **Config:** Firebase/GitHub OAuth not configured correctly

### What to Check RIGHT NOW

1. **Firebase Console:** Authorized domains includes `localhost`
2. **GitHub OAuth App:** Callback URL matches Firebase exactly
3. **Browser:** Allows popups and cookies (at least for testing)

### Quick Test

```bash
# 1. Run web app
flutter run -d chrome --web-port=5000

# 2. Open browser DevTools (F12)
# 3. Go to Console tab
# 4. Click "Continue with GitHub"
# 5. Check console for errors
```

**If you see specific errors, share them** - I can help debug further!

---

**Last Updated:** November 10, 2025  
**Status:** Configuration Required  
**Next Step:** Verify Firebase Console settings
