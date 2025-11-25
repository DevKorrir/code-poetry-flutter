/// Feature Limits Constants
/// Single source of truth for free and pro tier feature limits
/// Use these constants across the app for both UI display and enforcement
class FeatureLimits {
  FeatureLimits._();

  // ============================================================
  // FREE TIER LIMITS
  // ============================================================
  
  /// Maximum number of poems a free user can generate per day
  static const int freePoemsPerDay = 3;

  /// Number of poetry styles available to free users
  static const int freePoetryStyles = 4;

  /// Whether free users can save poems
  static const bool freeSavePoems = true;
  
  /// Whether free users can use cloud sync
  static const bool freeCloudSync = true;
  
  /// Whether free users can use voice reading
  static const bool freeVoiceReading = false;
  
  /// Whether free users can export as image
  static const bool freeExportAsImage = false;
  
  /// Whether free users can use custom styles
  static const bool freeCustomStyles = false;
  
  /// Whether free users have watermark
  static const bool freeNoWatermark = false;
  
  /// Whether free users have priority support
  static const bool freePrioritySupport = false;

  // ============================================================
  // PRO TIER LIMITS
  // ============================================================
  
  /// Maximum number of poems a pro user can generate per day (unlimited)
  static const String proPoemsPerDay = 'Unlimited';
  
  /// Number of poetry styles available to pro users
  static const int proPoetryStyles = 4;

  /// Whether pro users can save poems
  static const bool proSavePoems = true;
  
  /// Whether pro users can use cloud sync
  static const bool proCloudSync = true;
  
  /// Whether pro users can use voice reading
  static const bool proVoiceReading = true;
  
  /// Whether pro users can export as image
  static const bool proExportAsImage = true;
  
  /// Whether pro users can use custom styles
  static const bool proCustomStyles = true;
  
  /// Whether pro users have no watermark
  static const bool proNoWatermark = true;
  
  /// Whether pro users have priority support
  static const bool proPrioritySupport = true;

  // ============================================================
  // GUEST USER LIMITS
  // ============================================================
  
  /// Maximum number of poems a guest user can generate per day
  static const int guestPoemsPerDay = 3;

  // ============================================================
  // PRICING
  // ============================================================
  
  /// Monthly subscription price in USD
  static const double monthlyPrice = 4.99;
  
  /// Annual subscription price in USD
  static const double annualPrice = 29.99;

  // ============================================================
  // GITHUB API LIMITS
  // ============================================================
  
  /// Maximum directory depth when recursively fetching files from GitHub
  /// 
  /// **Purpose:** Prevents excessive API calls and protects against:
  /// - Deep directory structures causing performance issues
  /// - Accidental infinite recursion
  /// - GitHub API rate limiting (5000 requests/hour for authenticated users)
  /// 
  /// **Implications:**
  /// - **Too Low (1-2):** Users might not see files in nested project structures
  ///   Example: src/main/java/com/app won't be fully traversed at depth 2
  /// 
  /// - **Optimal (3-5):** Covers most real-world project structures
  ///   Depth 3: Handles typical structures like src/components/common/Button.tsx
  ///   Depth 5: Supports deeper structures like lib/features/auth/data/models/
  /// 
  /// - **Too High (6+):** Risk of performance degradation and API throttling
  ///   Each directory level multiplies API calls exponentially
  ///   Example: 10 subdirs per level = 10^depth API calls in worst case
  /// 
  /// **Default: 3** - Balances usability with performance
  /// **Recommended Range: 2-5** - Adjust based on target repository structures
  static const int githubMaxRecursionDepth = 3;
  
  /// Maximum number of repositories to fetch per page
  /// GitHub API default is 30, max is 100
  static const int githubReposPerPage = 30;

  // ============================================================
  // HELPER METHODS
  // ============================================================
  
  /// Get poems per day as display string for free tier
  static String get freePoemsPerDayDisplay => freePoemsPerDay.toString();
  
  /// Get poetry styles as display string for free tier
  static String get freePoetryStylesDisplay => freePoetryStyles.toString();
  
  /// Get poetry styles as display string for pro tier
  static String get proPoetryStylesDisplay => proPoetryStyles.toString();
  
  /// Check if a user has reached their daily limit
  static bool hasReachedDailyLimit({
    required bool isPro,
    required bool isGuest,
    required int poemsGeneratedToday,
  }) {
    if (isPro) return false; // Pro users have unlimited
    if (isGuest) return poemsGeneratedToday >= guestPoemsPerDay;
    return poemsGeneratedToday >= freePoemsPerDay;
  }
  
  /// Get the daily limit for a user
  static int getDailyLimit({
    required bool isPro,
    required bool isGuest,
  }) {
    if (isPro) return -1; // -1 indicates unlimited
    if (isGuest) return guestPoemsPerDay;
    return freePoemsPerDay;
  }
  
  /// Get formatted monthly price display
  static String get monthlyPriceDisplay => '\$${monthlyPrice.toStringAsFixed(2)}/mo';
  
  /// Get formatted annual price display
  static String get annualPriceDisplay => '\$${annualPrice.toStringAsFixed(2)}/yr';
  
  /// Calculate the savings percentage when choosing annual over monthly
  static int get annualSavingsPercentage {
    final monthlyYearlyCost = monthlyPrice * 12;
    final savings = monthlyYearlyCost - annualPrice;
    final percentage = (savings / monthlyYearlyCost * 100).round();
    return percentage;
  }
  
  /// Get formatted savings text for display
  static String get annualSavingsText => 'SAVE $annualSavingsPercentage%';
}
