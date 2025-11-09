/// Feature Limits Constants
/// Single source of truth for free and pro tier feature limits
/// Use these constants across the app for both UI display and enforcement
class FeatureLimits {
  FeatureLimits._();

  // ============================================================
  // FREE TIER LIMITS
  // ============================================================
  
  /// Maximum number of poems a free user can generate per day
  static const int freePoemsPerDay = 5;
  
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
  static String get annualSavingsText => 'SAVE ${annualSavingsPercentage}%';
}
