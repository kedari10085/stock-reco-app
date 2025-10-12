# 📈 StockReco Pro - Professional Stock Recommendation App

A complete Flutter application with Firebase Authentication, real-time stock recommendations, live price updates, and admin panel.

## ✨ Features

### 🔐 Authentication & User Management
- **Firebase Email/Password Auth** - Secure user authentication
- **Email Verification** - Verify user emails before access
- **Role-Based Access** - Admin and User roles with different permissions
- **Subscription System** - Free Forever (first 1000 users), Trial, Premium tiers
- **User Registration Counter** - Atomic Firestore counter for user numbering
- **SharedPreferences Caching** - Offline user data caching

### 👨‍💼 Admin Panel
- **Stock Recommendation Form** - Add ticker, buy/target prices, rationale
- **Exchange Selection** - NSE (.NS) or BSE (.BO) support
- **Firestore Integration** - Auto-save to `recommendations` collection
- **FCM Notifications** - Push notifications to all users (prepared)
- **Admin Drawer Menu** - Exclusive admin navigation

### 📊 Stock Recommendations
- **Real-Time Updates** - StreamBuilder with Firestore live sync
- **Live Stock Prices** - Alpha Vantage API integration
- **60-Second Auto-Refresh** - Timer.periodic price updates
- **Return Calculation** - Automatic profit/loss percentage
- **Offline Mode** - Hive caching for offline access
- **Pull-to-Refresh** - Manual price refresh
- **Detailed View** - Bottom sheet with full recommendation info

### 💰 Subscription Management
- **Free Forever** - First 1000 users get lifetime access
- **7-Day Trial** - Users 1001+ get trial period
- **Premium Upgrade** - RevenueCat integration (placeholder)
- **Status Display** - Visual subscription badges
- **Upgrade Prompts** - For trial/expired users

### 🎨 UI/UX
- **Material 3 Design** - Modern, beautiful interface
- **Dark/Light Mode** - Full theme support
- **Persistent Bottom Nav** - Smooth navigation
- **Color-Coded Returns** - Green for profit, red for loss
- **Responsive Cards** - Beautiful stock recommendation cards
- **Empty States** - Helpful messages when no data
- **Loading States** - Smooth loading indicators

### 💾 Offline Support
- **Hive Caching** - Local storage for recommendations and prices
- **5-Minute Cache** - Smart cache expiry
- **Offline Banner** - Visual indicator when offline
- **Seamless Sync** - Auto-sync when connection restored

## Tech Stack

### Core
- Flutter 3.24+
- Material 3 Design System
- Google Fonts (Roboto)

### Navigation
- Persistent Bottom Navigation Bar

### Backend & Services
- Firebase Core
- Cloud Firestore
- Firebase Auth
- Firebase Cloud Messaging

### UI & Charts
- Syncfusion Flutter Charts (Professional stock charts)
- Custom Material 3 components

### State Management
- Provider

### Storage
- Shared Preferences (settings)
- Hive Flutter (offline cache)

### Payments
- RevenueCat Purchases Flutter

### Networking
- HTTP package

### Configuration
- Flutter DotEnv (API keys management)

## Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── screens/                  # All screen widgets
│   ├── home_screen.dart      # Main navigation with persistent tabs
│   ├── dashboard_screen.dart # Overview and quick stats
│   ├── recommendations_screen.dart # Stock recommendations list
│   ├── performance_screen.dart # Analytics and charts
│   └── account_screen.dart   # User profile and settings
├── services/                 # Business logic services
│   ├── theme_service.dart    # Theme management
│   └── notification_service.dart # Push notifications
├── models/                   # Data models
│   ├── stock_recommendation.dart # Recommendation model
│   └── user_model.dart       # User model
└── widgets/                  # Reusable widgets
    ├── custom_card.dart      # Custom card component
    └── loading_indicator.dart # Loading widget

assets/
├── images/                   # App images and logo
└── .env                      # Environment variables (API keys)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.24 or higher
- Dart SDK 3.4 or higher
- Firebase project setup
- RevenueCat account (for subscriptions)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd stock_reco_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. Configure environment variables:
   - Edit `assets/.env` with your API keys
   - Add Firebase configuration
   - Add RevenueCat API key

5. Run the app:
```bash
flutter run
```

## Configuration

### Firebase Setup

1. Enable Authentication in Firebase Console
2. Enable Cloud Firestore
3. Enable Cloud Messaging
4. Add your app's package name

### RevenueCat Setup

1. Create a RevenueCat account
2. Configure products and subscriptions
3. Add API key to `.env` file

### Environment Variables

Edit `assets/.env`:
```env
FIREBASE_API_KEY=your_key_here
FIREBASE_APP_ID=your_app_id_here
REVENUECAT_API_KEY=your_revenuecat_key_here
```

## Features Overview

### Dashboard
- Welcome card with market status
- Quick stats (active recommendations, average return)
- Recent recommendations list
- Performance summary

### Recommendations
- Tabbed interface (All, Active, Completed)
- Detailed recommendation cards
- Buy/Sell indicators
- Real-time return calculations
- Target and stop-loss tracking

### Performance
- Period selector (1W, 1M, 3M, 6M, 1Y, ALL)
- Overall performance metrics
- Professional Syncfusion charts
- Success rate distribution
- Top performers leaderboard

### Account
- User profile management
- Subscription status
- Theme toggle (Dark/Light)
- Notification preferences
- Security and privacy settings
- Help and support

## Theme

### Colors
- **Primary**: Deep Purple 700 (#512DA8)
- **Secondary**: Green (for profits)
- **Accent**: Red (for losses)
- **Background**: Adaptive (light/dark)

### Typography
- **Font Family**: Roboto (Google Fonts)
- **Headings**: Bold, 18-24px
- **Body**: Regular, 14-16px
- **Captions**: 12px

## Build & Deploy

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Dependencies

See `pubspec.yaml` for complete list of dependencies and versions.

## License

This project is licensed under the MIT License.

## Support

For support, email support@stockrecopro.com or open an issue in the repository.

## Roadmap

- [ ] Real-time stock price integration
- [ ] Advanced filtering and sorting
- [ ] Portfolio tracking
- [ ] Watchlist feature
- [ ] Price alerts
- [ ] Social sharing
- [ ] Multi-language support
- [ ] Desktop app (Windows, macOS, Linux)

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## Acknowledgments

- Flutter team for the amazing framework
- Syncfusion for professional charts
- Firebase for backend services
- RevenueCat for subscription management
