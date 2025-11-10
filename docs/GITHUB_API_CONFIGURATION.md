# GitHub API Configuration Guide

## Overview

This document explains configurable GitHub API parameters and their implications for performance, user experience, and API rate limits.

---

## Recursion Depth Limit

### Location
**Constant:** `FeatureLimits.githubMaxRecursionDepth`  
**File:** `lib/core/constants/feature_limits.dart`  
**Default Value:** `3`

### Purpose

Controls how deep the app will traverse into a repository's directory structure when fetching files. This prevents:
- Excessive API calls to GitHub
- Performance degradation from deep traversals
- Unintentional rate limit exhaustion
- Infinite recursion on symbolic links or unusual structures

---

## Understanding Depth Levels

### Visual Example

```
Repository Root (Depth 0)
├── src/ (Depth 1)
│   ├── components/ (Depth 2)
│   │   ├── common/ (Depth 3) ← Default max depth
│   │   │   ├── Button.tsx (Depth 4) ← Not reached with depth 3
│   │   │   └── Input.tsx
│   │   └── auth/
│   │       └── LoginForm.tsx
│   └── utils/ (Depth 2)
│       └── helpers.ts
└── tests/
    └── unit/
        └── components.test.ts
```

With `maxDepth = 3`:
- ✅ Will fetch: `src/components/common/` directory listing
- ❌ Won't fetch: Files inside `src/components/common/` (Button.tsx, Input.tsx)

---

## API Call Calculation

### Best Case (Linear Structure)
Each directory has only 1 subdirectory:
```
API Calls = Depth
Example: Depth 3 = 3 API calls
```

### Worst Case (Exponential Growth)
Each directory has N subdirectories:
```
API Calls = Sum of N^i for i=0 to depth
Example: 10 subdirs per level, depth 3 = 1 + 10 + 100 + 1000 = 1,111 calls
```

### Typical Case (Real Repositories)
Most projects have 3-5 subdirectories per level:
```
Depth 3 with 4 subdirs per level ≈ 1 + 4 + 16 + 64 = 85 calls
```

---

## GitHub API Rate Limits

### Authenticated Requests
- **Limit:** 5,000 requests per hour
- **Reset:** Every hour (rolling window)
- **Per User:** Based on OAuth token

### Example Scenarios

| Depth | Subdirs/Level | API Calls | % of Rate Limit |
|-------|---------------|-----------|-----------------|
| 2     | 5             | ~31       | 0.6%           |
| 3     | 5             | ~156      | 3.1%           |
| 4     | 5             | ~781      | 15.6%          |
| 5     | 5             | ~3,906    | 78.1%          |
| 3     | 10            | ~1,111    | 22.2%          |

**Recommendation:** Keep depth at 3-4 for safety margin.

---

## Choosing the Right Depth

### Depth 1-2: Shallow Projects
**Use Cases:**
- Single-level projects
- Flat repository structures
- Quick file browsing
- Prototypes and small codebases

**Pros:**
- ✅ Very fast
- ✅ Minimal API calls
- ✅ No rate limit concerns

**Cons:**
- ❌ Won't work for most real projects
- ❌ Misses nested source files

---

### Depth 3: Balanced (RECOMMENDED)
**Use Cases:**
- Standard web projects (React, Vue, Angular)
- Mobile apps (Flutter, React Native)
- Most modern frameworks
- Default for all users

**Example Structures Covered:**
```
✅ src/components/Button.tsx
✅ lib/features/auth/login_screen.dart
✅ app/services/api/client.js
✅ packages/core/utils/helpers.ts
```

**Pros:**
- ✅ Covers 80% of typical project structures
- ✅ Reasonable API usage (50-200 calls typically)
- ✅ Good balance of speed vs completeness
- ✅ Safe from rate limiting

**Cons:**
- ⚠️ May miss very deeply nested files
- ⚠️ Some monorepos might be incomplete

---

### Depth 4-5: Deep Projects
**Use Cases:**
- Monorepos
- Enterprise applications
- Java/Maven projects (deep package structures)
- Legacy codebases with deep nesting

**Example Structures Covered:**
```
✅ src/main/java/com/company/app/service/impl/UserServiceImpl.java
✅ lib/src/features/auth/data/repositories/impl/auth_repository_impl.dart
```

**Pros:**
- ✅ Handles most complex structures
- ✅ Suitable for enterprise projects
- ✅ Comprehensive file discovery

**Cons:**
- ⚠️ Higher API usage (200-1000+ calls)
- ⚠️ Slower initial load
- ⚠️ Risk of rate limiting with multiple repos
- ⚠️ May timeout on very large repos

---

### Depth 6+: Extreme Cases (NOT RECOMMENDED)
**Use Cases:**
- Only for specific known deep structures
- Testing purposes

**Risks:**
- ❌ Very high API usage (1000+ calls)
- ❌ Likely to hit rate limits
- ❌ Slow and poor UX
- ❌ May cause timeouts
- ❌ Exponential growth of calls

**When to Use:** Never as default. Only for specific edge cases with manual override.

---

## How to Change the Depth

### Option 1: Global Change (Affects All Users)

**File:** `lib/core/constants/feature_limits.dart`

```dart
// Current
static const int githubMaxRecursionDepth = 3;

// Change to
static const int githubMaxRecursionDepth = 4; // For deeper projects
```

**Impact:**
- Changes default for all repository browsing
- Affects all users of the app
- Requires app rebuild/redeploy

---

### Option 2: Dynamic Override (Per-Call)

**File:** Where you call `getFilesRecursively()`

```dart
// Use custom depth for specific repository
final files = await GitHubService().getFilesRecursively(
  owner: owner,
  repo: repo,
  maxDepth: 5, // Override default
);
```

**Use Cases:**
- Known deep repositories
- User preference settings
- Pro feature (allow pro users deeper scanning)
- Testing different depths

---

## Performance Optimization Tips

### 1. Progressive Loading
Instead of fetching everything at once:
```dart
// Start shallow
List<GitHubContent> files = await getFilesRecursively(
  owner: owner,
  repo: repo,
  maxDepth: 2,
);

// Allow user to "go deeper" on demand
if (userWantsMore) {
  files.addAll(await getFilesRecursively(
    owner: owner,
    repo: repo,
    path: specificDirectory,
    maxDepth: 5,
  ));
}
```

### 2. Caching Results
```dart
// Cache file listings to avoid repeat API calls
final cachedFiles = await cacheService.get('repo_$owner_$repo');
if (cachedFiles != null) return cachedFiles;
```

### 3. User Settings
```dart
// Let power users configure their own depth
final userDepth = await settingsService.getPreferredDepth();
final files = await getFilesRecursively(
  owner: owner,
  repo: repo,
  maxDepth: userDepth ?? FeatureLimits.githubMaxRecursionDepth,
);
```

---

## Monitoring and Debugging

### Check API Usage
```dart
// Add logging to track API calls
debugPrint('Fetching repo contents at depth $currentDepth');
debugPrint('Total API calls so far: $callCount');
```

### Rate Limit Headers
GitHub returns rate limit info in response headers:
```
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 4999
X-RateLimit-Reset: 1372700873
```

Consider implementing rate limit monitoring:
```dart
Future<void> checkRateLimit() async {
  final response = await _client.get(
    Uri.parse('https://api.github.com/rate_limit'),
    headers: {'Authorization': 'Bearer $token'},
  );
  // Parse and display remaining quota
}
```

---

## Testing Recommendations

### Test Cases
1. **Shallow Repo (depth 1-2):** Should load quickly
2. **Normal Repo (depth 3-4):** Should complete in reasonable time
3. **Deep Monorepo (depth 5+):** Should handle gracefully or warn user
4. **Empty Repo:** Should return empty list without errors
5. **Large Repo (1000+ files):** Should not timeout

### Performance Benchmarks
- Depth 2: < 1 second
- Depth 3: 1-3 seconds
- Depth 4: 3-10 seconds
- Depth 5: 10-30 seconds (depending on structure)

---

## Future Enhancements

### Possible Improvements
1. **Adaptive Depth:** Start shallow, automatically go deeper if needed
2. **Smart Filtering:** Skip common directories (node_modules, .git, build)
3. **Parallel Fetching:** Fetch multiple directories concurrently
4. **Lazy Loading:** Load on-demand as user expands directories
5. **Repository Analysis:** Detect optimal depth based on repo structure
6. **Depth Presets:** "Quick", "Normal", "Complete" scanning modes

---

## Summary

| Aspect | Recommendation |
|--------|---------------|
| **Default Depth** | 3 |
| **Minimum Depth** | 2 (for flat projects) |
| **Maximum Safe Depth** | 5 (with monitoring) |
| **API Calls per Depth 3** | 50-200 typically |
| **Rate Limit Buffer** | Keep under 1000 calls per operation |

**Best Practice:** Keep default at 3, allow power users to customize via settings, implement progressive loading for better UX.

---

## Related Documentation
- [Security Verification](SECURITY_VERIFICATION.md)
- GitHub API Documentation: https://docs.github.com/en/rest
- Rate Limiting: https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting
