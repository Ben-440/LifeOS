# Finance Tracker - Native macOS & iOS

A beautifully designed, native finance tracker application for macOS and iOS with cloud synchronization. Built with SwiftUI for the frontend and Node.js/Express for the backend.

## Features

✨ **Native Experience**
- SwiftUI-based iOS app with full iPhone compatibility
- SwiftUI-based macOS app with native design patterns
- Seamless cloud synchronization across devices

💰 **Core Features**
- Expense and income tracking
- 10+ spending categories with emoji icons
- Monthly budgets with visual progress indicators
- Detailed analytics and spending reports
- Local-first architecture with cloud sync

🔒 **Data Management**
- Local storage for offline access
- Cloud sync via REST API
- Automatic synchronization
- Database-backed backend

## Project Structure

```
LifeOS/
├── Sources/                      # Shared Swift code
│   ├── Models/
│   │   └── Transaction.swift     # Core data models
│   ├── Managers/
│   │   └── FinanceManager.swift  # Business logic
│   └── Networking/
│       └── APIClient.swift       # API & local storage
├── ios/                          # iOS app
│   └── FinanceTrackerApp.swift   # iOS UI with SwiftUI
├── macos/                        # macOS app
│   └── FinanceTrackerMacApp.swift # macOS UI with SwiftUI
├── backend/                      # Node.js/Express API
│   ├── src/
│   │   ├── index.ts             # Express server
│   │   └── database.ts          # SQLite management
│   ├── package.json
│   └── tsconfig.json
└── database/
    └── schema.sql               # Database schema
```

## Quick Start

### Backend Setup

1. **Install dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. **Start the server**
   ```bash
   npm run dev
   ```
   Server runs at `http://localhost:3000`

### iOS App Setup

1. Open Xcode
2. Select iOS project
3. Build and run on simulator or device
4. The app will automatically sync with your backend

### macOS App Setup

1. Open Xcode
2. Select macOS project
3. Build and run
4. The app will automatically sync with your backend

## API Endpoints

### Transactions

- `GET /api/transactions` - Fetch all transactions
- `POST /api/transactions` - Create transaction
- `POST /api/transactions/sync` - Sync multiple transactions
- `DELETE /api/transactions/:id` - Delete transaction

### Budgets

- `GET /api/budgets` - Fetch all budgets
- `POST /api/budgets` - Create budget
- `POST /api/budgets/sync` - Sync multiple budgets

### Health

- `GET /api/health` - Server status check

## Data Models

### Transaction
- `id` (UUID)
- `title` (String)
- `amount` (Decimal)
- `category` (Enum: Food, Transportation, Shopping, Entertainment, Utilities, Healthcare, Education, Salary, Investment, Other)
- `date` (DateTime)
- `notes` (Optional String)
- `isExpense` (Boolean)

### MonthlyBudget
- `id` (UUID)
- `category` (Enum)
- `limit` (Decimal)
- `month` (Int: 1-12)
- `year` (Int)

## Configuration

### API Base URL
Update the API base URL in the iOS/macOS apps by setting the environment variable:
```
API_BASE_URL=http://your-api-url:3000
```

Or modify `APIClient.swift` to change the default localhost address.

## Developer Notes

### Shared Code
The `Sources/` directory contains shared Swift code used by both iOS and macOS apps:
- Core data models (Transaction, Budget)
- Business logic (FinanceManager)
- Networking (APIClient, LocalDataStore)

### Database
The backend uses SQLite for data persistence. The database file is created automatically on first run.

### Offline Support
The app has full offline support. Changes are saved locally and automatically synced to the backend when connectivity is restored.

## Technologies Used

**Frontend:**
- SwiftUI (iOS 16.0+, macOS 13.0+)
- Swift Concurrency (async/await)
- Combine framework

**Backend:**
- Node.js 18+
- Express.js
- TypeScript
- SQLite

**Data:**
- JSON for API communication
- Decimal numbers for currency (prevents floating-point errors)

## Future Enhancements

- [ ] User authentication and multi-user support
- [ ] CSV/PDF export
- [ ] Advanced analytics and charts
- [ ] Recurring transactions
- [ ] Receipt photos
- [ ] iCloud Keychain integration
- [ ] Siri Shortcuts support
- [ ] Apple Watch app
- [ ] Dark mode improvements
- [ ] Multi-currency support

## License

MIT License - Feel free to use this project for personal or commercial use.

## Support

For issues or questions, please open an issue on GitHub or contact the development team.