class AppConstants {
  // Cache durations
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration chartCacheDuration = Duration(minutes: 15);

  // Auto-refresh intervals
  static const Duration autoRefreshInterval = Duration(seconds: 60);

  // Database
  static const String databaseName = 'crypto_wallet.db';
  static const int databaseVersion = 1;

  // Tables
  static const String coinsTable = 'coins';
  static const String favoritesTable = 'favorites';
  static const String chartDataTable = 'chart_data';

  // Shared Preferences Keys
  static const String keyFavorites = 'favorites';
  static const String keyLastUpdate = 'last_update';
  static const String keyThemeMode = 'theme_mode';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double chartHeight = 200.0;

  // Search
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Error messages
  static const String networkErrorMessage = 'No internet connection. Showing cached data.';
  static const String apiErrorMessage = 'Failed to load data. Please try again.';
  static const String noCachedDataMessage = 'No cached data available. Connect to the internet to fetch data.';
  static const String emptyFavoritesMessage = 'No favorites yet. Tap the star icon to add coins to favorites.';
  static const String searchEmptyMessage = 'No coins found matching your search.';
}