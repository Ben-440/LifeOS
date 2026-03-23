# Finance Tracker - Setup Guide

## Prerequisites

### macOS Development
- **macOS 13.0+** (for macOS app)
- **Xcode 14.3+** with Command Line Tools
- **Swift 5.8+**
- **Node.js 18+** (for backend)
- **npm or yarn** (for backend dependencies)

## Step 1: Backend Setup

### 1.1 Install Backend Dependencies

```bash
cd backend
npm install
```

### 1.2 Configure Environment

```bash
cp .env.example .env
```

Edit `.env` to configure:
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - development or production
- `DB_PATH` - Database location

### 1.3 Start Backend Server

**Development Mode (with auto-reload)**
```bash
npm run dev
```

**Production Mode**
```bash
npm run build
npm start
```

The server will start at `http://localhost:3000`

Verify it's running:
```bash
curl http://localhost:3000/api/health
```

## Step 2: iOS App Setup

### 2.1 Prerequisites
- Xcode 14.3 or later
- iOS 16.0+ target device/simulator

### 2.2 Open Project

```bash
# Open the iOS project in Xcode
open ios/FinanceTrackerApp.swift
```

### 2.3 Configure Backend URL

In `FinanceTrackerApp.swift`, the app uses:
```swift
let baseURL = URL(string: ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:3000")!
```

**For Simulator** (localhost works):
- Keep default: `http://localhost:3000`

**For Physical Device**:
- Find your Mac's IP: `ifconfig | grep "inet " | grep -v 127.0.0.1`
- Set environment variable or modify APIClient.swift

### 2.4 Build and Run

1. Select your target device/simulator from Xcode
2. Press Cmd+R or Product → Run
3. App will launch and auto-sync with backend

### 2.5 Testing the App

#### Create a Transaction
1. Tap "Transactions" tab
2. Tap "+" button
3. Fill in transaction details
4. Tap "Save"

#### Check Backend Sync
```bash
curl http://localhost:3000/api/transactions
```

## Step 3: macOS App Setup

### 3.1 Prerequisites
- Xcode 14.3 or later
- macOS 13.0+

### 3.2 Open Project

```bash
# Open the macOS project in Xcode
open macos/FinanceTrackerMacApp.swift
```

### 3.3 Build and Run

1. Select "Any Mac" or specific Mac from Xcode scheme
2. Press Cmd+R or Product → Run
3. App will launch with native macOS UI

### 3.4 Features Specific to macOS
- Split view navigation
- Native menu bar integration
- Keyboard shortcuts (Cmd+, for preferences)
- Drag-and-drop support

## Step 4: Full Development Workflow

### Terminal 1: Backend Server
```bash
cd backend
npm run dev
```

### Terminal 2: iOS Development
```bash
cd ios
# Use Xcode (Product → Run)
```

### Terminal 3: macOS Development
```bash
cd macos
# Use Xcode (Product → Run)
```

## Debugging

### Backend Debugging

View server logs:
```bash
# The server outputs logs to console
# Look for entries like:
# GET /api/transactions
# POST /api/transactions/sync
```

Debug database:
```bash
# View SQLite database
sqlite3 backend/finance_tracker.db

# List all transactions
SELECT * FROM transactions;

# List all budgets
SELECT * FROM budgets;
```

### iOS Debugging

1. Open Debug Navigator in Xcode (Cmd+7)
2. View memory, CPU, network usage
3. Use Debugger to set breakpoints
4. Check Console (Cmd+Shift+C) for print statements

### macOS Debugging

1. Same as iOS - use Xcode debug tools
2. Console output shows app logs
3. Breakpoints work in SwiftUI code

## Common Issues

### Issue: "Cannot connect to backend"

**Solution:**
1. Verify backend is running: `npm run dev`
2. Check backend listening on correct port: `lsof -i :3000`
3. For iOS on device: use actual Mac IP instead of localhost
4. Check firewall: Allow port 3000

### Issue: "Database locked"

**Solution:**
```bash
# Stop backend server
# Remove old database
rm backend/finance_tracker.db
# Restart backend
npm run dev
```

### Issue: "CORS errors in console"

**Solution:**
- Currently CORS allows all origins ('*')
- For production, update `.env` with specific domain

### Issue: "npm install fails"

**Solution:**
```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules
rm -rf backend/node_modules

# Reinstall
npm install
```

## Code Organization

### Key Files to Know

**Backend**
- `backend/src/index.ts` - Main Express server
- `backend/src/database.ts` - Database operations
- `backend/.env` - Configuration

**iOS**
- `ios/FinanceTrackerApp.swift` - Main iOS app & UI
- `Sources/Managers/FinanceManager.swift` - Business logic
- `Sources/Networking/APIClient.swift` - API communication

**macOS**
- `macos/FinanceTrackerMacApp.swift` - Main macOS app
- Uses same FinanceManager and APIClient from Sources/

**Shared**
- `Sources/Models/Transaction.swift` - Data models
- `Sources/Managers/FinanceManager.swift` - Business logic
- `Sources/Networking/APIClient.swift` - Network & storage

## Making Changes

### Adding a New Category

1. Edit `Sources/Models/Transaction.swift`
2. Add case to `TransactionCategory` enum
3. Add emoji in `icon` property
4. Update backend if needed

### Adding a New Feature

1. Update data model in `Sources/Models/`
2. Update FinanceManager in `Sources/Managers/`
3. Update API client in `Sources/Networking/`
4. Update backend endpoints in `backend/src/index.ts`
5. Update database schema in `backend/src/database.ts`
6. Update UI in `ios/` and `macos/`

### Database Changes

1. Update schema in `database/schema.sql`
2. Update database.ts to handle new schema
3. Migrations (manual for now)

## Building for Distribution

### iOS App
```bash
# In Xcode
# Scheme: FinanceTrackerApp -> Any iOS Device (arm64)
# Product → Archive
# Organizer → Distribute App
```

### macOS App
```bash
# In Xcode
# Scheme: FinanceTrackerMacApp -> Any Mac
# Product → Archive
# Organizer → Export Notarized App
```

## Next Steps

1. ✅ Backend running on http://localhost:3000
2. ✅ iOS app syncing with backend
3. ✅ macOS app syncing with backend
4. 📝 Add authentication (see ARCHITECTURE.md)
5. 🚀 Deploy backend to production
6. 📦 Submit apps to App Store/Mac App Store

## Support

For questions or issues:
1. Check error messages in Xcode console
2. Review ARCHITECTURE.md for design decisions
3. Check backend logs in terminal
4. Verify database state with sqlite3

Happy coding! 🎉
