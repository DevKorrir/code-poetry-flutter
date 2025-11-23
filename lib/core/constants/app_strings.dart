/// App String Constants
/// All user-facing text in one place for easy editing and future i18n
class AppStrings {
  AppStrings._();

  // ============================================================
  // APP INFO
  // ============================================================
  static const String appName = 'Code Poetry';
  static const String appTagline = 'Where Logic Meets Emotion';
  static const String appDescription =
      'Transform your code into beautiful poetry with AI';

  // ============================================================
  // ONBOARDING
  // ============================================================
  static const String onboardingTitle1 = 'Your Code Has Feelings';
  static const String onboardingDesc1 =
      'Every line of code tells a story. Let\'s turn your logic into poetry.';

  static const String onboardingTitle2 = 'Choose Your Style';
  static const String onboardingDesc2 =
      'From Haiku to Cyberpunk, express your code in different poetic forms.';

  static const String onboardingTitle3 = 'Share Your Art';
  static const String onboardingDesc3 =
      'Turn your commits into Instagram-worthy content. Make coding fun again.';

  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get Started';

  // ============================================================
  // AUTHENTICATION
  // ============================================================
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to save your poems';
  static const String loginEmail = 'Email';
  static const String loginPassword = 'Password';
  static const String loginButton = 'Sign In';
  static const String loginForgotPassword = 'Forgot Password?';
  static const String loginNoAccount = 'Don\'t have an account?';
  static const String loginSignUp = 'Sign Up';
  static const String loginWithGoogle = 'Continue with Google';
  static const String loginWithGitHub = 'Continue with GitHub';
  static const String loginAsGuest = 'Continue as Guest';
  static const String loginHaveAccount = 'Already have an account?';
  static const String loginSignIn = 'Sign In';

  static const String signupTitle = 'Create Account';
  static const String signupSubtitle = 'Join the poetry revolution';
  static const String signupName = 'Name';
  static const String signupEmail = 'Email';
  static const String signupPassword = 'Password';
  static const String signupConfirmPassword = 'Confirm Password';
  static const String signupButton = 'Create Account';
  static const String signupHaveAccount = 'Already have an account?';
  static const String signupSignIn = 'Sign In';

  static const String guestModeTitle = 'Try It Without Signing Up';
  static const String guestModeDesc =
      'Generate 3 poems for free. Sign up to save unlimited poems.';
  static const String guestModeContinue = 'Continue as Guest';
  static const String guestModeSignUp = 'Create Account Instead';

  // ============================================================
  // HOME SCREEN
  // ============================================================
  static const String homeWelcome = 'Welcome to Code Poetry';
  static const String homeWelcomeBack = 'Welcome back';
  static const String homeSubtitle = 'What would you like to turn into poetry today?';
  static const String homeNewPoem = 'Create New Poem';
  static const String homeGallery = 'My Gallery';
  static const String homeRecentPoems = 'Recent Poems';
  static const String homeEmptyState = 'No poems yet. Create your first one!';

  // ============================================================
  // CODE INPUT
  // ============================================================
  static const String codeInputTitle = 'Paste Your Code';
  static const String codeInputHint = 'Paste your code here...';
  static const String codeInputLanguageLabel = 'Language';
  static const String codeInputSelectLanguage = 'Select Language';
  static const String codeInputNext = 'Choose Style';
  static const String codeInputError = 'Please paste some code';
  static const String codeInputTooLong = 'Code is too long (max 500 lines)';

  // ============================================================
  // STYLE SELECTOR
  // ============================================================
  static const String styleSelectorTitle = 'Choose Poetry Style';
  static const String styleSelectorSubtitle = 'How should your code sound?';
  static const String styleGenerate = 'Generate Poem';

  // Poetry Styles
  static const String styleHaikuName = 'Haiku';
  static const String styleHaikuDesc =
      'Minimalist, 5-7-5 syllables. Calm and zen.';

  static const String styleSonnetName = 'Sonnet';
  static const String styleSonnetDesc =
      'Classical, 14 lines. Elegant and structured.';

  static const String styleFreeVerseName = 'Free Verse';
  static const String styleFreeVerseDesc =
      'No rules. Creative and flowing.';

  static const String styleCyberpunkName = 'Cyberpunk';
  static const String styleCyberpunkDesc =
      'Futuristic, edgy. Tech noir vibes.';

  // ============================================================
  // POEM DISPLAY
  // ============================================================
  static const String poemDisplayTitle = 'Your Code Poetry';
  static const String poemGenerating = 'Crafting your poem...';
  static const String poemSave = 'Save Poem';
  static const String poemShare = 'Share';
  static const String poemRegenerate = 'Try Again';
  static const String poemExplain = 'Explain';
  static const String poemReadAloud = 'Read Aloud';
  static const String poemSaved = 'Poem saved to gallery';
  static const String poemShared = 'Poem shared';
  static const String successMessage = 'Poem generated successfully';

  // ============================================================
  // GALLERY
  // ============================================================
  static const String galleryTitle = 'My Gallery';
  static const String galleryEmptyTitle = 'No Poems Yet';
  static const String galleryEmptyDesc =
      'Your saved poems will appear here. Create your first masterpiece!';
  static const String galleryFilter = 'Filter by Style';
  static const String gallerySort = 'Sort by Date';
  static const String galleryDelete = 'Delete';
  static const String galleryDeleteConfirm =
      'Are you sure you want to delete this poem?';
  static const String galleryDeleted = 'Poem deleted';

  // ============================================================
  // PROFILE
  // ============================================================
  static const String profileTitle = 'Profile';
  static const String profileEdit = 'Edit Profile';
  static const String profileStats = 'Your Stats';
  static const String profilePoemsCreated = 'Poems Created';
  static const String profileFavoriteStyle = 'Favorite Style';
  static const String profileMemberSince = 'Member Since';
  static const String profileLogout = 'Logout';
  static const String profileUpgradeToPro = 'Upgrade to Pro';

  // ============================================================
  // SETTINGS
  // ============================================================
  static const String settingsTitle = 'Settings';
  static const String settingsTheme = 'Theme';
  static const String settingsThemeLight = 'Light Mode';
  static const String settingsThemeDark = 'Dark Mode';
  static const String settingsThemeSystem = 'System Default';
  static const String settingsNotifications = 'Notifications';
  static const String settingsLanguage = 'Language';
  static const String settingsAbout = 'About';
  static const String settingsPrivacy = 'Privacy Policy';
  static const String settingsTerms = 'Terms of Service';
  static const String settingsVersion = 'Version';

  // ============================================================
  // PRO/SUBSCRIPTION
  // ============================================================
  static const String proTitle = 'Upgrade to Pro';
  static const String proSubtitle = 'Unlock unlimited poetry';
  static const String proPrice = '\$4.99/month';
  static const String proFeature1 = 'Unlimited poem generation';
  static const String proFeature2 = 'All poetry styles';
  static const String proFeature3 = 'Audio poem readings';
  static const String proFeature4 = 'No watermarks';
  static const String proFeature5 = 'Priority support';
  static const String proButton = 'Subscribe Now';
  static const String proRestore = 'Restore Purchase';

  static const String guestLimitTitle = 'Daily Limit Reached';
  static const String guestLimitDesc =
      'You\'ve used all 3 free poems. Sign up to get 5 poems per day!';
  static const String freeLimitTitle = '5 Poems Used Today';
  static const String freeLimitDesc =
      'You\'ve reached your daily limit. Upgrade to Pro for unlimited poems!';

  // ============================================================
  // ERRORS
  // ============================================================
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection';
  static const String errorAuth = 'Authentication failed';
  static const String errorInvalidEmail = 'Invalid email address';
  static const String errorWeakPassword = 'Password too weak (min 6 characters)';
  static const String errorPasswordMismatch = 'Passwords don\'t match';
  static const String errorEmptyField = 'This field cannot be empty';
  static const String errorGenerationFailed = 'Failed to generate poem. Try again.';

  // ============================================================
  // SUCCESS MESSAGES
  // ============================================================
  static const String successLogin = 'Welcome back!';
  static const String successSignup = 'Account created successfully';
  static const String successLogout = 'Logged out successfully';
  static const String successSaved = 'Saved successfully';
  static const String successUpdated = 'Updated successfully';

  // ============================================================
  // BUTTONS
  // ============================================================
  static const String buttonCancel = 'Cancel';
  static const String buttonConfirm = 'Confirm';
  static const String buttonDelete = 'Delete';
  static const String buttonSave = 'Save';
  static const String buttonEdit = 'Edit';
  static const String buttonClose = 'Close';
  static const String buttonRetry = 'Retry';
  static const String buttonContinue = 'Continue';
  static const String buttonBack = 'Back';

  // ============================================================
  // LOADING MESSAGES
  // ============================================================
  static const String loadingGeneric = 'Loading...';
  static const String loadingPoem = 'Analyzing your code...';
  static const String loadingAuth = 'Signing you in...';
  static const String loadingSave = 'Saving...';

  // ============================================================
  // TIPS & HINTS
  // ============================================================
  static const String tipCodeInput =
      'Tip: Paste clean, well-formatted code for best results';
  static const String tipStyleSelect =
      'Tip: Different styles work better with different code types';
  static const String tipShare =
      'Tip: Share your poems on social media with #CodePoetry';
}