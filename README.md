# Crypto Wallet App

A beautiful and robust cryptocurrency tracking application built with Flutter and Riverpod, featuring real-time price updates, detailed coin information, interactive charts, and offline support.

### Core Features
- Browse 100+ cryptocurrencies with real-time prices
- Instantly search coins by name or symbol
- Save your favorite coins for quick access
- Interactive 7-day price history with zoom and pan
- Live price updates every 60 seconds
- Optimized for all screen sizes
- Access cached data when offline
- Reduced API calls with intelligent caching
- Manually refresh data anytime
- Visual indicators for 24h price changes
- Supports system theme preferences
- Graceful error states with retry options
- Real-time connection status
- SQLite database for offline access
- Automatic retry with exponential backoff
- Optimized for slow networks


## Setting Up Locally

### Prerequisites
- Flutter SDK (3.24.0 or higher)
- Dart SDK (3.5.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/crypto_wallet_app.git
cd crypto_wallet_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# Run on connected device/emulator
flutter run

# Run in release mode for better performance
flutter run --release
```

4. **Build APK**

# Build release APK
flutter build apk --release


The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### API Configuration
The app uses the **CoinGecko API** (no API key required for basic tier):
- Base URL: `https://api.coingecko.com/api/v3`
- Rate Limit: 10-50 calls/minute (Free tier)
- Documentation: [CoinGecko API Docs](https://docs.coingecko.com)


### DELIVERABLES
- GITHUB LINK: 
- APK:
- DEMO VIDEO: 

