# Code Poetry

<div align="center">

![Code Poetry Banner](assets/banner.png)

**Transform your code into beautiful poetry with AI** ✨

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![Gemini AI](https://img.shields.io/badge/Gemini-AI-4285F4?logo=google)](https://ai.google.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Demo](#-demo) • [Installation](#-installation) • [Architecture](#-architecture) • [Tech Stack](#-tech-stack)

</div>

---

## 📖 About

**Code Poetry** is a mobile application that transforms your code into beautiful, artistic poetry using AI. Whether you're a developer looking to celebrate your craft or someone who wants to see code from a different perspective, Code Poetry bridges the gap between logic and emotion.

### 🎯 The Problem

Developers spend thousands of hours writing elegant code, but it's often:
- Treated as purely functional, not artistic
- Never celebrated beyond "it works"
- Disconnected from emotional expression

### 💡 The Solution

Code Poetry analyzes your code and generates beautiful poetry in multiple styles:
- **Haiku** - Minimalist 5-7-5 syllable poems
- **Sonnet** - Classical 14-line structured verses
- **Free Verse** - Creative, flowing expressions
- **Cyberpunk** - Futuristic, edgy tech-noir poetry

---

## ✨ Features

### 🤖 AI-Powered Generation
- Powered by Google's Gemini AI
- Context-aware poem generation
- Multiple programming languages supported
- Smart code analysis before generation

### 🎨 Multiple Poetry Styles
- 4 distinct poetry styles with unique aesthetics
- Swipeable style selector with live previews
- Custom gradients for each style
- Example poems to guide selection

### 🔐 Flexible Authentication
- Email/Password authentication
- Google Sign-In integration
- Guest mode for quick access
- Seamless guest-to-user conversion

### 💾 Smart Storage
- Local storage with Hive for offline access
- Cloud sync with Firestore for logged-in users
- Automatic backup and restore
- Cross-device synchronization

### 🎭 Beautiful Animations
- Typewriter effect for poem reveal
- Smooth page transitions
- Gradient background animations
- Haptic feedback throughout

### 📊 Usage Tiers
- **Guest Mode**: 3 poems total
- **Free Tier**: 5 poems per day
- **Pro Tier**: Unlimited poems (ready for monetization)

### 🎯 Additional Features
- Share poems via system share sheet
- Save favorites to gallery
- Filter poems by style
- Dark/Light theme support
- Responsive design (mobile & web)

---

## 🎬 Demo

### App Flow

```
Launch → Onboarding → Auth → Home → Create Poem
                                      ↓
                              Code Input
                                      ↓
                              Style Selection
                                      ↓
                              Poem Display
                                      ↓
                          Share / Save / Regenerate
```

### Screenshots

<div align="center">

| Onboarding | Style Selector | Poem Display |
|:---:|:---:|:---:|
| ![Onboarding](https://github.com/DevKorrir/code-poetry-flutter/blob/main/screenshots/code_imput.png) | ![Styles](https://via.placeholder.com/250x500/4facfe/ffffff?text=Style+Selector) | ![Poem](https://github.com/DevKorrir/code-poetry-flutter/blob/main/screenshots/poem_display.png) |

| Home Dashboard | Code Input | Gallery |
|:---:|:---:|:---:|
| ![Home](https://github.com/DevKorrir/code-poetry-flutter/blob/main/screenshots/home.png) | ![Input](https://github.com/DevKorrir/code-poetry-flutter/blob/main/screenshots/code_imput.png) | ![Gallery](https://github.com/DevKorrir/code-poetry-flutter/blob/main/screenshots/gallery.png) |

</div>

### Demo Video

[![Watch Demo](https://via.placeholder.com/800x450/667eea/ffffff?text=▶+Watch+Demo+Video)](https://your-demo-link.com)

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase account
- Google Cloud account (for Gemini API)

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/code-poetry.git
cd code-poetry
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Setup Environment Variables

Create a `.env` file in the project root:

```env
# Gemini AI API Key
GEMINI_API_KEY=your_gemini_api_key_here

# Firebase Configuration (optional for additional configs)
FIREBASE_API_KEY=your_firebase_key_here
```

**Get Gemini API Key:**
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click "Create API Key"
3. Copy key to `.env` file

### Step 4: Firebase Setup

#### 4.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Follow the setup wizard

#### 4.2 Add Flutter App to Firebase

**For Android:**
```bash
flutterfire configure
```

**Manual Setup:**
1. Download `google-services.json`
2. Place in `android/app/`

**For iOS:**
1. Download `GoogleService-Info.plist`
2. Place in `ios/Runner/`

#### 4.3 Enable Firebase Services

In Firebase Console:
1. **Authentication**
   - Enable Email/Password
   - Enable Google Sign-In
   - Enable Anonymous (for Guest mode)

2. **Firestore Database**
   - Create database in test mode (for development)
   - Set up security rules (see [Security Rules](#security-rules))

### Step 5: Run the App

```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run on Chrome (web)
flutter run -d chrome

# Run with hot reload
flutter run --hot
```

---

## 🏗️ Architecture

### Design Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────┐
│              USER INTERFACE                 │
│         (Views & Widgets)                   │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│            VIEW MODELS                      │
│    (Business Logic & State Management)     │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│            REPOSITORIES                     │
│      (Data Coordination Layer)             │
└─────┬──────────────────────┬────────────────┘
      │                      │
┌─────▼─────────┐   ┌────────▼──────────────┐
│   SERVICES    │   │   LOCAL STORAGE       │
│  - API        │   │  - Hive               │
│  - Auth       │   │  - SharedPreferences  │
│  - Storage    │   │  - Firestore          │
└───────────────┘   └───────────────────────┘
```

### Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── core/                              # Core app configurations
│   ├── constants/
│   │   ├── app_colors.dart           # Color system
│   │   ├── app_strings.dart          # All UI text
│   │   └── api_constants.dart        # API endpoints
│   │
│   ├── theme/
│   │   ├── app_theme.dart            # Theme configuration
│   │   └── text_styles.dart          # Typography system
│   │
│   └── services/
│       ├── api_service.dart          # Gemini AI integration
│       ├── auth_service.dart         # Firebase Auth wrapper
│       ├── storage_service.dart      # Hive + Firestore
│       └── connectivity_service.dart # Network monitoring
│
├── models/                            # Data models
│   ├── poem_model.dart
│   ├── user_model.dart
│   └── poetry_style_model.dart
│
├── repositories/                      # Data layer
│   ├── poem_repository.dart
│   └── auth_repository.dart
│
├── viewmodels/                        # Business logic
│   ├── auth_viewmodel.dart
│   ├── poem_generator_viewmodel.dart
│   ├── gallery_viewmodel.dart
│   ├── home_viewmodel.dart
│   └── settings_viewmodel.dart
│
└── views/                             # UI layer
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── onboarding/
    │   ├── auth/
    │   ├── home/
    │   ├── code_input/
    │   ├── style_selector/
    │   ├── poem_display/
    │   ├── gallery/
    │   ├── profile/
    │   └── settings/
    │
    └── widgets/
        ├── common/                    # Reusable widgets
        │   ├── custom_button.dart
        │   ├── custom_text_field.dart
        │   ├── loading_indicator.dart
        │   ├── error_view.dart
        │   └── empty_state.dart
        │
        └── [feature-specific widgets]
```

### State Management

**Provider** is used for state management with the following structure:

```dart
MultiProvider(
  providers: [
    // Services (singleton)
    Provider<ApiService>(...),
    Provider<StorageService>(...),
    
    // ViewModels (state notifiers)
    ChangeNotifierProvider<AuthViewModel>(...),
    ChangeNotifierProvider<PoemGeneratorViewModel>(...),
    // ... other ViewModels
  ],
  child: MyApp(),
)
```

---

## 🛠️ Tech Stack

### Frontend Framework
- **Flutter 3.0+** - Cross-platform UI framework
- **Dart 3.0+** - Programming language

### State Management
- **Provider** - Lightweight state management solution

### Backend Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL cloud database
- **Google Gemini AI** - AI-powered poetry generation

### Local Storage
- **Hive** - Fast, lightweight NoSQL database
- **SharedPreferences** - Key-value storage

### UI/UX Libraries
```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  provider: ^6.1.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.2.1
  
  # Networking
  http: ^1.1.0
  dio: ^5.4.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # UI/Animations
  flutter_animate: ^4.3.0
  lottie: ^3.0.0
  shimmer: ^3.0.0
  
  # Utilities
  flutter_dotenv: ^5.1.0
  connectivity_plus: ^5.0.2
  share_plus: ^7.2.1
  uuid: ^4.3.3
  intl: ^0.19.0
  
  # Code Display
  flutter_highlight: ^0.7.0
```

---

## 🔧 Configuration

### Firebase Security Rules

**Firestore Rules** (`firestore.rules`):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's poems subcollection
      match /poems/{poemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**Authentication Rules:**
- Email/Password: Enabled
- Google Sign-In: Enabled
- Anonymous: Enabled

### Environment Configuration

The app uses different configurations for development and production:

**Development:**
```dart
// Uses test Firebase project
// Gemini API with rate limiting
// Debug mode enabled
```

**Production:**
```dart
// Uses production Firebase project
// Full Gemini API access
// Release mode optimizations
```

---

## 🎨 Design System

### Color Palette

**Primary Colors:**
```dart
Primary Gradient: #667EEA → #764BA2 (Purple-Blue)
Secondary Gradient: #4FACFE → #00F2FE (Cyan)
Accent Gradient: #F093FB → #F5576C (Pink-Orange)
Success Gradient: #43E97B → #38F9D7 (Green)
```

**Semantic Colors:**
```dart
Success: #43E97B
Error: #FF6A88
Warning: #FEE140
Info: #4FACFE
```

**Dark Theme:**
```dart
Background: #0A0E27
Surface: #1A1F3A
Text Primary: #FFFFFF
Text Secondary: #B8B8D1
```

### Typography

**Font Families:**
- **UI Text**: System Default (San Francisco / Roboto)
- **Code**: JetBrains Mono (Monospace)
- **Poetry**: Spectral (Serif, Italic)

**Type Scale:**
```
H1: 32px, Bold
H2: 28px, Bold
H3: 24px, Semibold
H4: 20px, Semibold
Body Large: 16px, Regular
Body Medium: 14px, Regular
Body Small: 12px, Regular
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/viewmodels/poem_generator_viewmodel_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure

```
test/
├── unit/
│   ├── models/
│   ├── repositories/
│   └── services/
├── widget/
│   └── common/
└── integration/
    └── poem_generation_flow_test.dart
```

### Testing Strategy

- **Unit Tests**: ViewModels, Repositories, Services
- **Widget Tests**: Common widgets, Custom components
- **Integration Tests**: Full user flows

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | Minimum SDK: 21 (Android 5.0) |
| iOS | ✅ Full Support | Minimum: iOS 12.0 |
| Web | ✅ Full Support | Chrome, Safari, Firefox, Edge |
| macOS | 🔄 Experimental | Desktop support via Flutter |
| Windows | 🔄 Experimental | Desktop support via Flutter |
| Linux | 🔄 Experimental | Desktop support via Flutter |

---

## 🚢 Deployment

### Android (Google Play Store)

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended)
flutter build appbundle --release
```

**Location:** `build/app/outputs/bundle/release/app-release.aab`

### iOS (Apple App Store)

```bash
# Build for iOS
flutter build ios --release

# Create archive in Xcode
open ios/Runner.xcworkspace
# Product → Archive → Distribute
```

### Web Hosting

```bash
# Build web version
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

**Web Build Location:** `build/web/`

---

## 🔐 Security

### API Key Protection
- ✅ Environment variables (`.env`)
- ✅ Never committed to version control
- ✅ `.gitignore` configured properly

### Authentication
- ✅ Firebase Auth with secure tokens
- ✅ Password hashing handled by Firebase
- ✅ OAuth 2.0 for Google Sign-In

### Data Privacy
- ✅ User data isolated by Firebase rules
- ✅ Local encryption with Hive
- ✅ HTTPS for all network requests

### Best Practices
- ✅ Input validation on all forms
- ✅ Rate limiting for API calls
- ✅ Error messages don't expose sensitive info
- ✅ Secure storage for user credentials

---

## 📈 Performance

### Optimizations
- Lazy loading for poems list
- Image caching
- Debounced search
- Efficient state management
- Code splitting for web

### Benchmarks
- App startup: < 2 seconds
- Poem generation: 3-5 seconds (AI dependent)
- Screen transitions: 60 FPS
- Memory usage: < 150 MB

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

### Getting Started
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` before committing
- Write meaningful commit messages
- Add tests for new features

### Pull Request Process
1. Update README if needed
2. Add/update tests
3. Ensure all tests pass
4. Update documentation
5. Request review from maintainers

---

## 🐛 Known Issues

- [ ] Occasional timeout on slow networks (AI generation)
- [ ] Theme transition animation needs smoothing
- [ ] iOS keyboard overlap on small devices (rare)

See [Issues](https://github.com/DevKorrir/code-poetry/issues) for full list.

---

## 🗺️ Roadmap

### Version 1.1 (Next Release)
- [ ] More poetry styles (Limerick, Ballad)
- [ ] Voice narration of poems
- [ ] Export poems as images
- [ ] Social features (share to feed)

### Version 2.0 (Future)
- [ ] Payment integration (Pro tier)
- [ ] Custom AI model fine-tuning
- [ ] Collaborative poems
- [ ] Code review poetry integration
- [ ] VS Code extension

### Version 3.0 (Vision)
- [ ] Community gallery
- [ ] Poetry competitions
- [ ] NFT minting of poems
- [ ] Multi-language UI support

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Code Poetry

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👨‍💻 Author

**Your Name**
- GitHub: [DevKorrir](https://github.com/DevKorrir)
- LinkedIn: [Aldo Kipyegon](https://www.linkedin.com/in/aldo-korir-kipyegon/)
- Twitter: [@AldoKipyegon](https://x.com/AldoKipyegon)
- Email: kipyegonaldo@gmail.com

---

## 🙏 Acknowledgments

- **Google Gemini AI** - For powerful AI capabilities
- **Firebase** - For backend infrastructure
- **Flutter Team** - For amazing framework
- **Font Awesome** - For icons
- **Unsplash** - For sample images
- **Open Source Community** - For inspiration and support

---

## 📞 Support

Need help? Here's how to get support:

- 📧 Email: kipyegonaldo@gmail.com
- 🐛 Bug Reports: [GitHub Issues](https://github.com/DevKorrir/code-poetry/issues)
- 💡 Feature Requests: [GitHub Discussions](https://github.com/DevKorrir/code-poetry/discussions)

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=DevKorrir/code-poetry&type=Date)](https://star-history.com/#DevKorrir/code-poetry&Date)

---

<div align="center">

### Made with ❤️ and Flutter

**If you found this project helpful, please consider giving it a ⭐!**

[⬆ Back to Top](#-code-poetry)

</div>
