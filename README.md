# FlowPaisa - Personal Finance & Cash Flow Manager

**Track every paisa** - A comprehensive Flutter mobile application for managing expenses, incomes, receivables, and payables.

## 🎯 Project Status

### ✅ Completed (Phase 1 - MVP)

1. **Project Setup & Architecture**
   - Flutter project initialized with Clean Architecture
   - Riverpod 2.x for state management
   - Drift (SQLite) for local database
   - Feature-first folder structure

2. **Internationalization (i18n)**
   - English, Hindi (हिन्दी), and Urdu (اردو) support
   - Google Fonts integration for proper script rendering
   - RTL support for Urdu
   - ARB files created for all three languages

3. **Database Schema**
   - Complete Drift database with 11 tables:
     - Transactions (with linked transaction support)
     - Receivables & Payables (with external link IDs)
     - Categories (with default presets)
     - Contacts
     - Reminders
     - WhatsApp Queue
     - Usage Stats (for smart suggestions)
     - User Preferences
     - Sync Log
   - Default categories auto-populated (Food, Transport, Shopping, Bills, etc.)
   - Migration system in place

4. **Transaction Management (MVP)**
   - Add transactions (Expense/Income)
   - View all transactions in a list
   - Basic transaction form with:
     - Amount input
     - Type selection (Expense/Income)
     - Description
     - Date picker
   - Repository pattern with Riverpod providers
   - Reactive UI updates via Drift streams

5. **Core UI**
   - Bottom navigation with 4 tabs (Dashboard, Transactions, Analytics, Settings)
   - Material Design 3 theme with light/dark mode
   - Responsive layouts
   - Multilingual font support (Inter, Noto Sans Devanagari, Noto Nastaliq Urdu)

### 🚧 Pending (Phases 2-11)

1. **Enhanced Transaction Features**
   - Amount-first progressive disclosure UI
   - Paid FOR / Paid BY relationship logic
   - Linked transactions (Expense-Receivable, Income-Payable)
   - Auto-create matching entries on settlement
   - Category selection
   - Contact selection

2. **Receivables & Payables**
   - Full CRUD operations
   - Due date tracking
   - Reminder system
   - Auto-income creation when receivable is settled
   - Auto-expense creation when payable is paid (optional)

3. **Contacts Management**
   - Add/Edit/Delete contacts
   - Phone contacts import
   - Google Contacts import (Premium)
   - Usage statistics for smart suggestions

4. **WhatsApp Integration**
   - Deep link generation for shared transactions
   - Message templates
   - Offline transaction sharing
   - Viral marketing links
   - Queue management

5. **Receipt Scanning**
   - Google ML Kit Text Recognition (FREE, offline)
   - Camera/gallery access
   - Automatic amount extraction
   - Date and merchant extraction
   - Pre-fill transaction form

6. **Reminders & Notifications**
   - Local notifications
   - Background jobs with WorkManager
   - Smart reminder suggestions
   - Due date alerts

7. **Dashboard & Analytics**
   - Overview cards (Net Balance, Receivables, Payables)
   - 5 basic charts (FREE):
     - Expense by Category (Pie Chart)
     - Income vs Expense (Bar Chart)
     - Cash Flow Trend (Line Chart)
     - Receivables vs Payables
     - Top Contacts
   - Smart insights
   - CSV export (FREE)

8. **Premium Features**
   - Google Sign-In
   - Google Drive encrypted backup
   - PDF reports with charts
   - Advanced analytics
   - Budget tracking
   - Excel export
   - Scheduled reports

9. **Cross-Platform**
   - Web responsiveness
   - Windows desktop adaptation

## 🏗️ Architecture

### Tech Stack
- **Framework:** Flutter 3.13.9
- **Language:** Dart 3.1.5
- **State Management:** Riverpod 2.4.x
- **Database:** Drift 2.14.0 (SQLite wrapper)
- **Architecture:** Clean Architecture with feature-first structure

### Project Structure
```
lib/
├── core/
│   ├── database/          # Drift database setup
│   ├── theme/             # App theme & fonts
│   ├── constants/         # App constants
│   └── utils/             # Helper functions
├── features/
│   ├── transactions/      # Transaction CRUD
│   ├── receivables/       # Receivables management
│   ├── payables/          # Payables management
│   ├── contacts/          # Contact management
│   ├── categories/        # Category management
│   ├── dashboard/         # Dashboard & analytics
│   ├── auth/              # Google Sign-In
│   ├── premium/           # Premium features
│   ├── reminders/         # Reminder system
│   ├── whatsapp/          # WhatsApp integration
│   └── receipt_scan/      # Receipt scanning
├── shared/
│   ├── widgets/           # Reusable widgets
│   └── providers/         # Global providers
├── l10n/                  # Localization files
│   ├── app_en.arb         # English
│   ├── app_hi.arb         # Hindi
│   └── app_ur.arb         # Urdu
└── main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.13.9 or higher
- Dart SDK 3.1.5 or higher
- Android Studio / VS Code
- Android SDK (for Android development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd cashbook
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Generate Drift database code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
flutter run
```

## 📱 Features Overview

### Current (MVP)
- ✅ Add Expense/Income transactions
- ✅ View transaction list
- ✅ Multi-language support (EN, HI, UR)
- ✅ Dark/Light theme
- ✅ Local SQLite database

### Planned
- 🚧 Linked transactions (Paid FOR/BY)
- 🚧 Receivables & Payables tracking
- 🚧 WhatsApp notifications
- 🚧 Receipt scanning (OCR)
- 🚧 Dashboard with charts
- 🚧 CSV/PDF export
- 🚧 Google Drive backup
- 🚧 Smart reminders

## 📦 Dependencies

### Core
- `flutter_riverpod: ^2.4.0` - State management
- `drift: ^2.14.0` - SQLite wrapper
- `google_fonts: ^6.1.0` - Multilingual fonts
- `intl: any` - Internationalization

### Features
- `firebase_core: ^2.24.0` - Firebase integration
- `cloud_firestore: ^4.14.0` - Language requests storage
- `google_mlkit_text_recognition: ^0.11.0` - Receipt OCR
- `image_picker: ^1.0.7` - Camera access
- `fl_chart: ^0.65.0` - Charts & visualizations
- `csv: ^6.0.0` - CSV export
- `pdf: ^3.10.0` - PDF generation
- `google_sign_in: ^6.1.0` - Google authentication
- `googleapis: ^11.4.0` - Google Drive API

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run analysis:
```bash
flutter analyze
```

## 📄 License

This project is private and not licensed for public use.

## 🤝 Contributing

This is a private project. Contributions are not accepted at this time.

## 📞 Contact

For questions or issues, please contact the project maintainer.

---

**FlowPaisa** - Track every paisa 💰
