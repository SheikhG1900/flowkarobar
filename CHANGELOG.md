# Changelog

All notable changes to the FlowPaisa project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - Phase 2 Repositories (2026-01-04)
- **ReceivablesRepository**: Complete CRUD operations with contact joins
  - Auto-income creation on settlement
  - External link ID support for shared transactions
  - Contact statistics and usage tracking
- **PayablesRepository**: Complete CRUD operations with contact joins
  - Auto-expense creation on settlement
  - External link ID support for shared transactions
  - Contact statistics and usage tracking
- **CategoriesRepository**: Smart category management
  - Usage tracking with CategoryUsageStats
  - Most used and recently used queries
  - Automatic usage count increment
- **ContactsRepository**: Comprehensive contact management
  - Usage tracking with ContactUsageStats
  - Contact statistics (transactions, receivables, payables)
  - Net balance calculation
  - Search functionality
- **FirebaseService**: Language request management
  - Submit language requests to Firestore
  - Get language request counts
  - Availability check
- **Firebase Riverpod Provider**: Global Firebase service provider

### Changed - Package Upgrades (2026-01-04)

#### Major Version Upgrades ⚠️
- `flutter_riverpod`: 2.4.0 → 3.1.0
  - Migration notes: All existing providers are backward compatible
  - Consider using `@riverpod` annotations for future code
- `firebase_core`: 2.24.0 → 4.3.0
  - Firebase initialization updated in main.dart
  - Added graceful error handling for unconfigured Firebase
- `cloud_firestore`: 4.14.0 → 6.1.1
  - Used for language request tracking
- `googleapis`: 11.4.0 → 15.0.0
  - For future Google Drive sync feature
- `googleapis_auth`: 1.4.1 → 2.0.0
- `google_sign_in`: 6.1.0 → 7.2.0
- `fl_chart`: 0.65.0 → 1.1.1
  - For future analytics charts
- `flutter_lints`: 2.0.0 → 6.0.0
  - Applied new linting rules
  - Fixed deprecated `withOpacity` → `withValues`
  - Fixed `prefer_final_fields` warnings

#### Minor/Patch Upgrades
- `google_fonts`: → 6.3.0
- `flutter_secure_storage`: 9.0.0 → 10.0.0
- `flutter_local_notifications`: 17.0.0 → 19.5.0
- `workmanager`: 0.5.2 → 0.9.0+3
- `timezone`: 0.9.2 → 0.10.1
- `google_mlkit_text_recognition`: 0.11.0 → 0.15.0
- `share_plus`: 7.2.0 → 12.0.1
- `riverpod_generator`: 2.2.0 → 4.0.0+1
- `riverpod_lint`: 2.2.0 → 3.1.0
- `riverpod_annotation`: 2.2.0 → 4.0.0
- `extension_google_sign_in_as_googleapis_auth`: 2.0.11 → 3.0.0

### Fixed (2026-01-04)
- **Drift Value Types**: Fixed incorrect use of `copyWith` in repository methods
  - Used `Value<T>` wrapper for nullable fields in Receivables/Payables
  - Fixed `DateTime` and `int` assignment errors
- **Deprecated APIs**: Replaced `withOpacity` with `withValues` for color transparency
- **Code Quality**: Applied flutter_lints 6.0 rules
  - Made `_currentLocale` final in FlowPaisaApp
  - Improved type safety across repositories

### Technical Notes

#### Riverpod 3.x Migration Path
Current code uses manual provider definitions which are fully compatible with Riverpod 3.x. For future code, consider:
```dart
// Old style (still works)
final myProvider = Provider<MyService>((ref) => MyService());

// New style (recommended for new code)
@riverpod
MyService myService(MyServiceRef ref) => MyService();
```

#### Firebase Integration
Firebase is now initialized in `main.dart` with graceful fallback:
```dart
try {
  await Firebase.initializeApp();
} catch (e) {
  // App works without Firebase if not configured
  debugPrint('Firebase initialization skipped: $e');
}
```

#### Drift Repository Patterns
All repositories follow consistent patterns:
- `watch*()` methods return `Stream<T>` for reactive UI
- `get*()` methods return `Future<T?>` for one-time queries
- `create*()` methods return `Future<int>` (ID)
- `update*()` methods return `Future<bool>`
- `delete*()` methods return `Future<int>` (rows affected)

## [1.0.0] - 2026-01-03

### Added - Phase 1 Foundation
- Flutter project initialization with Clean Architecture
- Riverpod 2.4.0 state management setup
- Drift database with 11 tables
- Internationalization (English, Hindi, Urdu)
- Google Fonts integration with script-specific styling
- Material Design 3 theme with light/dark mode
- Transaction CRUD MVP (add/view)
- Transaction list screen with empty states
- Add transaction form
- Database provider with Riverpod
- Default categories auto-population (13 categories)
- README documentation
- Widget tests

### Database Schema (v1)
- `Transactions` - Expenses and incomes with linked transaction support
- `Receivables` - Money owed to user
- `Payables` - Money user owes
- `Categories` - Transaction categories with usage stats
- `Contacts` - People/businesses
- `Reminders` - Due date notifications
- `WhatsAppQueue` - Message queue for notifications
- `CategoryUsageStats` - Smart suggestion data
- `ContactUsageStats` - Smart suggestion data
- `UserPreferences` - App settings
- `SyncLog` - Backup/restore tracking

### Localization
- ARB files for 3 languages
- Proper font rendering:
  - Inter for Latin script
  - Noto Sans Devanagari for Hindi
  - Noto Nastaliq Urdu for Urdu (with increased line height for readability)
- RTL layout support for Urdu

---

## Future Versions

### [1.1.0] - Planned
- Enhanced transaction entry UI
- Linked transactions (Paid FOR/BY)
- Receivables and Payables UI
- Contacts management UI

### [1.2.0] - Planned
- Receipt scanning (ML Kit OCR)
- WhatsApp integration
- Smart reminders

### [1.3.0] - Planned
- Dashboard with charts
- Analytics screens
- CSV export

### [2.0.0] - Planned (Premium)
- Google Sign-In
- Google Drive encrypted backup
- PDF reports
- In-app purchases

---

**Legend:**
- 🔥 Breaking change
- ⚠️ Deprecation warning
- ✨ New feature
- 🐛 Bug fix
- 📝 Documentation
- 🔧 Internal/Technical change


