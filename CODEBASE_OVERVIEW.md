# Code Poetry - Codebase Overview

## What This Codebase Does

**Code Poetry** is a Flutter mobile application that transforms source code into beautiful, artistic poetry using AI. It analyzes code snippets and generates poetry in various styles (Haiku, Sonnet, Free Verse, Cyberpunk) powered by Google's Gemini AI.

### Core Functionality

1. **Code Analysis & Poetry Generation**: Takes code as input, analyzes it, and generates themed poetry
2. **Multi-Style Support**: Offers 4 distinct poetry styles with unique aesthetics
3. **User Authentication**: Supports email/password, Google Sign-In, and guest mode
4. **Poem Management**: Save, favorite, filter, and share generated poems
5. **Usage Tiers**: Guest (3 poems), Free (5 per day), Pro (unlimited)
6. **Cross-Platform Sync**: Local storage with cloud backup for authenticated users

---

## Technical Architecture

### Design Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────┐
│          Views (UI Layer)           │
│    - Screens                        │
│    - Widgets                        │
└──────────────┬──────────────────────┘
               │ observes & triggers actions
┌──────────────▼──────────────────────┐
│     ViewModels (Business Logic)     │
│    - AuthViewModel                  │
│    - PoemGeneratorViewModel         │
│    - GalleryViewModel               │
│    - HomeViewModel                  │
│    - SettingsViewModel              │
└──────────────┬──────────────────────┘
               │ coordinates data
┌──────────────▼──────────────────────┐
│    Repositories (Data Layer)        │
│    - PoemRepository                 │
│    - AuthRepository                 │
│    - UserRepository                 │
└─────┬────────────────────┬──────────┘
      │                    │
┌─────▼────────┐   ┌──────▼──────────┐
│   Services   │   │  Local Storage  │
│  - API       │   │  - Hive         │
│  - Auth      │   │  - Firestore    │
│  - Storage   │   │  - SharedPrefs  │
│  - Network   │   │                 │
└──────────────┘   └─────────────────┘
```

### State Management

The app uses **Provider** for state management:

- **Services** are provided as singletons (`Provider`)
- **ViewModels** extend `ChangeNotifier` (`ChangeNotifierProvider`)
- UI widgets consume state via `context.watch<T>()` or `context.read<T>()`
- State changes automatically trigger UI rebuilds

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, provider setup
│
├── core/                              # Core infrastructure
│   ├── constants/                     # App-wide constants
│   │   ├── app_colors.dart           # Color palette & gradients
│   │   ├── app_strings.dart          # UI text & messages
│   │   └── feature_limits.dart       # Usage limits per tier
│   │
│   ├── theme/                         # Theme configuration
│   │   ├── app_theme.dart            # Light/Dark themes
│   │   └── text_styles.dart          # Typography system
│   │
│   └── services/                      # Core services
│       ├── api_service.dart          # Gemini AI API client
│       ├── auth_service.dart         # Firebase Auth wrapper
│       ├── storage_service.dart      # Hive + Firestore manager
│       └── connectivity_service.dart # Network status monitor
│
├── models/                            # Data models
│   ├── poem_model.dart               # Poem entity (id, code, style, poem, etc.)
│   ├── user_model.dart               # User profile (id, email, tier, usage)
│   ├── poetry_style_model.dart       # Style metadata (name, example, gradient)
│   └── code_analysis_model.dart      # Code analysis result
│
├── repositories/                      # Data coordination
│   ├── poem_repository.dart          # CRUD for poems + AI generation
│   ├── auth_repository.dart          # Auth operations + user state
│   └── user_repository.dart          # User profile management
│
├── viewmodels/                        # Business logic & state
│   ├── auth_viewmodel.dart           # Login, signup, guest mode, logout
│   ├── poem_generator_viewmodel.dart # Poem generation flow
│   ├── gallery_viewmodel.dart        # Poem list, filtering, favorites
│   ├── home_viewmodel.dart           # Dashboard stats, recent poems
│   └── settings_viewmodel.dart       # Theme, preferences
│
└── views/                             # UI layer
    ├── screens/                       # Full-page screens
    │   ├── splash_screen.dart        # Initial loading screen
    │   ├── onboarding_screen.dart    # First-time user intro
    │   ├── auth/                      # Authentication screens
    │   │   ├── login_screen.dart
    │   │   ├── signup_screen.dart
    │   │   └── guest_mode_prompt.dart
    │   ├── home/                      # Dashboard
    │   │   └── home_screen.dart
    │   ├── code_input/                # Code entry
    │   │   └── code_input_screen.dart
    │   ├── style_selector/            # Poetry style picker
    │   │   └── style_selector_screen.dart
    │   ├── poem_display/              # Poem viewing
    │   │   ├── poem_display_screen.dart
    │   │   └── saved_poem_detail_screen.dart
    │   ├── gallery/                   # Poem collection
    │   │   └── gallery_screen.dart
    │   ├── profile/                   # User profile
    │   │   └── profile_screen.dart
    │   ├── settings/                  # App settings
    │   │   └── settings_screen.dart
    │   └── pro_upgrade/               # Monetization
    │       └── pro_upgrade_screen.dart
    │
    └── widgets/                       # Reusable components
        ├── common/                    # Generic widgets
        │   ├── custom_button.dart
        │   ├── custom_text_field.dart
        │   ├── loading_indicator.dart
        │   ├── error_view.dart
        │   └── empty_state.dart
        └── animations/                # Visual effects
            ├── confetti_animation.dart
            ├── floating_code_symbols.dart
            ├── theme_toggle_animation.dart
            └── export_image_widget.dart
```

---

## Key Components Breakdown

### 1. Services Layer (`core/services/`)

#### ApiService
- **Purpose**: Communicates with Google Gemini AI API
- **Key Methods**:
  - `generatePoem(code, language, style)`: Sends code to AI, receives poem
  - `_buildPrompt()`: Constructs AI prompt with context
  - `_extractPoemFromResponse()`: Parses AI response
- **Configuration**: API key loaded from `.env` file

#### AuthService
- **Purpose**: Wraps Firebase Authentication
- **Key Methods**:
  - `signInWithEmail()`, `signUpWithEmail()`
  - `signInWithGoogle()`: OAuth flow
  - `signInAnonymously()`: Guest mode
  - `convertGuestToUser()`: Upgrade guest account
  - `signOut()`, `deleteAccount()`
- **State**: Exposes `authStateChanges` stream

#### StorageService
- **Purpose**: Manages local (Hive) and cloud (Firestore) storage
- **Key Methods**:
  - `savePoem()`, `getPoems()`, `deletePoem()`
  - `syncToFirestore()`: Cloud backup for authenticated users
  - `getUserPreferences()`, `saveUserPreferences()`
- **Strategy**: 
  - Guest mode: Hive only
  - Authenticated: Hive + Firestore sync

#### ConnectivityService
- **Purpose**: Monitors network status
- **Key Methods**:
  - `initialize()`: Starts listening to connectivity changes
  - `isConnected`: Boolean property
- **Usage**: Enables offline mode, sync notifications

### 2. Models Layer (`models/`)

#### PoemModel
```dart
{
  id: String,           // UUID
  code: String,         // Original code snippet
  language: String,     // e.g., "python", "dart"
  style: String,        // e.g., "haiku", "sonnet"
  poem: String,         // Generated poetry
  createdAt: DateTime,
  isFavorite: bool
}
```

#### UserModel
```dart
{
  id: String,
  email: String?,
  displayName: String?,
  photoUrl: String?,
  tier: String,         // "guest", "free", "pro"
  poemsCreatedToday: int,
  totalPoemsCreated: int,
  createdAt: DateTime
}
```

#### PoetryStyleModel
```dart
{
  name: String,         // "Haiku", "Sonnet", etc.
  description: String,
  example: String,      // Sample poem
  gradient: List<Color>, // Visual styling
  characteristics: String
}
```

### 3. Repositories Layer (`repositories/`)

#### PoemRepository
- **Purpose**: Orchestrates poem generation and storage
- **Dependencies**: ApiService, StorageService, ConnectivityService
- **Key Methods**:
  - `generatePoem(code, language, style)`: 
    1. Validates input
    2. Checks usage limits
    3. Calls ApiService
    4. Saves via StorageService
    5. Returns PoemModel
  - `getAllPoems()`: Retrieves from storage
  - `getPoemsByStyle(style)`: Filtered retrieval
  - `toggleFavorite(poemId)`: Updates favorite status
  - `deletePoem(poemId)`: Removes from storage

#### AuthRepository
- **Purpose**: Manages authentication flows and user state
- **Dependencies**: AuthService, StorageService
- **Key Methods**:
  - `signIn(email, password)`: Email/password login
  - `signUp(email, password, displayName)`: Registration
  - `signInWithGoogle()`: Google OAuth
  - `startGuestMode()`: Anonymous auth
  - `upgradeGuestAccount(email, password)`: Convert anonymous to permanent
  - `getCurrentUser()`: Returns UserModel
  - `updateUserProfile()`: Modifies user data

#### UserRepository
- **Purpose**: User profile CRUD operations
- **Key Methods**:
  - `getUserData()`: Fetch user profile
  - `updateUserTier()`: Change subscription level
  - `incrementPoemCount()`: Usage tracking
  - `resetDailyCount()`: Daily limit reset

### 4. ViewModels Layer (`viewmodels/`)

All ViewModels extend `ChangeNotifier` and follow this pattern:

```dart
class ExampleViewModel extends ChangeNotifier {
  // Dependencies (repositories)
  final Repository _repository;
  
  // State variables
  bool _isLoading = false;
  String? _error;
  
  // Getters (expose state)
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Business logic methods
  Future<void> someAction() async {
    _isLoading = true;
    _error = null;
    notifyListeners();  // Triggers UI rebuild
    
    try {
      await _repository.doSomething();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### AuthViewModel
- **State**: Current user, auth status, loading, errors
- **Actions**: 
  - `signIn()`, `signUp()`, `signOut()`
  - `signInWithGoogle()`, `continueAsGuest()`
  - `upgradeAccount()`

#### PoemGeneratorViewModel
- **State**: Code input, language, style, generated poem, loading, errors
- **Actions**:
  - `updateCode(code)`, `updateLanguage(lang)`, `updateStyle(style)`
  - `generatePoem()`: Main generation flow
  - `savePoem()`, `sharePoem()`, `regeneratePoem()`

#### GalleryViewModel
- **State**: Poems list, filter, sort order, loading
- **Actions**:
  - `loadPoems()`, `filterByStyle(style)`, `sortBy(criteria)`
  - `toggleFavorite(id)`, `deletePoem(id)`
  - `searchPoems(query)`

#### HomeViewModel
- **State**: Stats (total poems, favorites, daily usage), recent poems
- **Actions**:
  - `initialize()`: Load dashboard data
  - `refreshStats()`: Update counters

#### SettingsViewModel
- **State**: Theme mode, preferences, user settings
- **Actions**:
  - `toggleTheme()`, `updatePreference(key, value)`
  - `clearCache()`, `exportData()`

### 5. Views Layer (`views/`)

#### Screen Navigation Flow

```
SplashScreen
    ↓
OnboardingScreen (first-time only)
    ↓
AuthScreen (Login/SignUp/Guest)
    ↓
HomeScreen
    ↓
    ├─→ CodeInputScreen
    │       ↓
    │   StyleSelectorScreen
    │       ↓
    │   PoemDisplayScreen
    │
    ├─→ GalleryScreen
    │       ↓
    │   SavedPoemDetailScreen
    │
    ├─→ ProfileScreen
    ├─→ SettingsScreen
    └─→ ProUpgradeScreen
```

#### Key Screens

**HomeScreen**: 
- Dashboard with stats cards
- Recent poems list
- Quick actions (Create, Gallery, Profile)

**CodeInputScreen**:
- Multi-line text input with syntax highlighting
- Language selector dropdown
- Code validation
- "Next" button → StyleSelectorScreen

**StyleSelectorScreen**:
- Swipeable cards for each style
- Visual preview (gradient + example)
- Style descriptions
- "Generate" button → calls `PoemGeneratorViewModel.generatePoem()`

**PoemDisplayScreen**:
- Typewriter animation for poem reveal
- Gradient background matching style
- Action buttons (Save, Share, Regenerate)
- Confetti animation on first view

**GalleryScreen**:
- Grid/List view toggle
- Filter chips (All, Haiku, Sonnet, etc.)
- Search bar
- Pull-to-refresh
- Item cards → SavedPoemDetailScreen

**ProfileScreen**:
- User info (name, email, photo)
- Statistics (poems created, favorites)
- Usage meter (daily limit visualization)
- Tier badge (Guest/Free/Pro)
- Upgrade button for non-Pro users

**SettingsScreen**:
- Theme toggle (Light/Dark)
- Preferences (animations, haptics)
- Account management (logout, delete)
- About/Legal links

---

## Data Flow Example: Generating a Poem

1. **User Input** (CodeInputScreen):
   ```
   User types code → CodeInputScreen updates state
   ```

2. **Style Selection** (StyleSelectorScreen):
   ```
   User selects "Haiku" → StyleSelectorScreen passes to ViewModel
   ```

3. **ViewModel Processing** (PoemGeneratorViewModel):
   ```dart
   generatePoem() {
     1. Set isLoading = true → notifyListeners()
     2. Call PoemRepository.generatePoem(code, language, style)
     3. PoemRepository validates usage limits
     4. PoemRepository calls ApiService.generatePoem()
     5. ApiService sends HTTP request to Gemini AI
     6. Response parsed, PoemModel created
     7. StorageService saves poem (Hive + Firestore if online)
     8. ViewModel updates generatedPoem, isLoading = false
     9. notifyListeners() → UI rebuilds
   }
   ```

4. **UI Update** (PoemDisplayScreen):
   ```
   Watches PoemGeneratorViewModel.generatedPoem
   → Displays poem with typewriter animation
   → Shows save/share buttons
   ```

5. **Persistence**:
   ```
   User clicks "Save" → StorageService.savePoem()
   → Saved to Hive (local)
   → Synced to Firestore (if authenticated + online)
   ```

---

## Tech Stack Deep Dive

### Core Framework
- **Flutter 3.0+**: UI framework (Dart-based, cross-platform)
- **Dart 3.0+**: Programming language (null-safe, strongly typed)

### State Management
- **Provider 6.1.1**: Dependency injection + state propagation
  - Lightweight, official Flutter recommendation
  - `ChangeNotifier` pattern for reactive updates

### Backend Services
- **Firebase Core 4.2.1**: Firebase SDK initialization
- **Firebase Auth 6.1.2**: Authentication (email, Google, anonymous)
- **Cloud Firestore 6.1.0**: NoSQL cloud database (poems, user data)
- **Google Sign-In 7.2.0**: OAuth integration

### AI/API
- **HTTP 1.1.0**: REST client for Gemini AI API
- **Dio 5.4.0**: Advanced HTTP client (interceptors, retries)
- **Google Gemini AI API**: Poem generation (v1beta endpoint)

### Local Storage
- **Hive 2.2.3**: Fast, key-value NoSQL database (offline poems)
- **Hive Flutter 1.1.0**: Flutter integration
- **SharedPreferences 2.2.2**: Simple key-value storage (settings)

### UI/UX Libraries
- **flutter_animate 4.3.0**: Declarative animations
- **lottie 3.0.0**: JSON-based animations (splash, loading)
- **shimmer 3.0.0**: Loading skeleton screens
- **flutter_highlight 0.7.0**: Syntax highlighting for code

### Utilities
- **flutter_dotenv 6.0.0**: Environment variable management
- **uuid 4.3.3**: Unique ID generation
- **intl 0.20.2**: Internationalization (date formatting)
- **connectivity_plus 7.0.0**: Network status monitoring
- **share_plus 12.0.1**: Native share sheet integration

### Dev Tools
- **flutter_lints 6.0.0**: Dart/Flutter code analysis
- **build_runner 2.4.13**: Code generation
- **hive_generator 2.0.1**: Generates Hive type adapters
- **flutter_launcher_icons 0.14.1**: App icon generation

---

## Configuration & Setup

### Environment Variables (`.env`)
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Firebase Setup
1. **Authentication Methods Enabled**:
   - Email/Password
   - Google Sign-In
   - Anonymous (Guest mode)

2. **Firestore Structure**:
   ```
   /users/{userId}
     - email, displayName, tier, usage stats
     /poems/{poemId}
       - code, language, style, poem, createdAt, isFavorite
   ```

3. **Security Rules**:
   ```javascript
   match /users/{userId} {
     allow read, write: if request.auth.uid == userId;
     match /poems/{poemId} {
       allow read, write: if request.auth.uid == userId;
     }
   }
   ```

### Assets
- **Fonts**: JetBrains Mono (code), Spectral (poetry)
- **Animations**: Lottie JSON files
- **Images**: Onboarding graphics, banner, app icon

---

## Feature Limits & Monetization

### Usage Tiers (defined in `core/constants/feature_limits.dart`)

| Tier | Daily Limit | Total Limit | Cost |
|------|-------------|-------------|------|
| **Guest** | - | 3 poems total | Free |
| **Free** | 5 poems | Unlimited | Free |
| **Pro** | Unlimited | Unlimited | Paid |

### Enforcement Logic
- Tracked in `UserModel.poemsCreatedToday`
- Reset daily via scheduled task (or on first access each day)
- `PoemRepository.generatePoem()` checks limits before API call
- Exceeding limit → prompt for upgrade (ProUpgradeScreen)

---

## Testing Strategy

### Current Test Coverage
- **Unit Tests**: `test/widget_test.dart` (basic smoke test)
- **Widget Tests**: TBD (common widgets)
- **Integration Tests**: TBD (full flows)

### Recommended Tests
1. **Unit Tests**:
   - Models: JSON serialization/deserialization
   - Services: API calls, storage operations (mocked)
   - ViewModels: State changes, business logic

2. **Widget Tests**:
   - CustomButton, CustomTextField behavior
   - LoadingIndicator, ErrorView rendering
   - Screen layout components

3. **Integration Tests**:
   - Complete poem generation flow
   - Authentication flows (login, signup, guest)
   - Offline mode functionality

---

## Build & Deployment

### Development
```bash
flutter run              # Debug mode with hot reload
flutter run --profile    # Performance profiling
flutter run -d chrome    # Web debugging
```

### Production Builds
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
open ios/Runner.xcworkspace  # Xcode for signing

# Web
flutter build web --release
```

### Deployment Targets
- **Android**: Google Play Store (minSdk 21)
- **iOS**: App Store (iOS 12.0+)
- **Web**: Firebase Hosting / Vercel / Netlify

---

## Code Quality & Best Practices

### Dart/Flutter Guidelines
- **Effective Dart**: Follow official style guide
- **Linting**: `flutter_lints` package enforced
- **Formatting**: `dart format` before commits
- **Null Safety**: Full null-safety enabled (Dart 3.0+)

### Architecture Patterns
- **Separation of Concerns**: Clear MVVM layers
- **Dependency Injection**: Via Provider
- **Single Responsibility**: Each class has one job
- **Immutability**: Models use `copyWith()` for updates

### Error Handling
- Try-catch in all async operations
- User-friendly error messages (no stack traces in UI)
- Logging for debugging (debug mode only)
- Graceful degradation (offline mode)

### Performance Optimizations
- Lazy loading for long lists (ListView.builder)
- Image caching (CachedNetworkImage implied)
- Debounced search input
- Efficient state updates (notifyListeners only when needed)
- Code splitting for web builds

---

## Security Considerations

### API Keys
- ✅ Stored in `.env` file
- ✅ `.env` in `.gitignore`
- ✅ Not committed to version control

### Authentication
- ✅ Firebase handles password hashing
- ✅ OAuth 2.0 for Google Sign-In
- ✅ Secure token storage

### Data Privacy
- ✅ Firestore rules restrict user data access
- ✅ Local data encrypted by Hive
- ✅ HTTPS for all API calls

### Input Validation
- ✅ Code input sanitized before API call
- ✅ Form validation for auth screens
- ✅ Rate limiting implied by usage tiers

---

## Known Limitations & Future Work

### Current Limitations
1. **Offline Poem Generation**: Not possible (requires AI API)
2. **Code Language Detection**: Manual selection (no auto-detect)
3. **Poem Editing**: Can't modify generated poems
4. **Payment Integration**: Pro tier not yet monetized

### Roadmap Opportunities
1. **Additional Poetry Styles**: Limerick, Ballad, Epic
2. **Code Analysis Enhancements**: AST parsing, complexity metrics
3. **Social Features**: Public gallery, sharing, comments
4. **Export Options**: PDF, Image, Audio narration
5. **VS Code Extension**: Generate poems from IDE
6. **AI Model Fine-Tuning**: Custom poetry models

---

## Getting Started (Developer)

### Prerequisites
1. Install Flutter SDK 3.0+
2. Install Dart SDK 3.0+
3. Install IDE (VS Code / Android Studio)
4. Set up Firebase project
5. Obtain Gemini API key

### Quick Start
```bash
# 1. Clone repository
git clone https://github.com/DevKorrir/code-poetry-flutter.git
cd code-poetry-flutter

# 2. Install dependencies
flutter pub get

# 3. Create .env file
echo "GEMINI_API_KEY=your_key_here" > .env

# 4. Configure Firebase
flutterfire configure  # or manual setup

# 5. Run app
flutter run
```

### Project Commands
```bash
flutter pub get              # Install dependencies
flutter pub upgrade          # Update packages
flutter clean                # Clean build cache
flutter analyze              # Static analysis
flutter test                 # Run tests
dart format lib/             # Format code
flutter build apk            # Build Android APK
```

---

## Key Files to Start With

For new developers exploring the codebase:

1. **`lib/main.dart`**: App entry point, provider setup
2. **`lib/core/constants/app_strings.dart`**: All UI text
3. **`lib/models/poem_model.dart`**: Core data structure
4. **`lib/viewmodels/poem_generator_viewmodel.dart`**: Main feature logic
5. **`lib/views/screens/home/home_screen.dart`**: Main UI entry
6. **`lib/core/services/api_service.dart`**: AI integration
7. **`pubspec.yaml`**: Dependencies and configuration

---

## Statistics

- **Total Dart Files**: 45
- **Total Lines of Code**: ~11,716
- **Main Components**:
  - 5 ViewModels
  - 4 Models
  - 3 Repositories
  - 4 Services
  - 13 Screens
  - 8+ Widgets

---

## Summary

**Code Poetry** is a well-architected Flutter application demonstrating:
- ✅ Clean MVVM architecture
- ✅ Modern Flutter best practices
- ✅ Firebase backend integration
- ✅ AI-powered feature implementation
- ✅ Comprehensive state management
- ✅ Cross-platform support (mobile & web)
- ✅ Offline-first with cloud sync
- ✅ Monetization-ready structure

The codebase is modular, testable, and maintainable, making it suitable for both learning and production use.

---

**For more information, see the main [README.md](README.md) for user-facing documentation.**
