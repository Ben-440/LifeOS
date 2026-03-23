# 🚀 Building Finance Tracker as Native Applications

Everything is ready to build! Follow these steps to convert the source files into fully functional apps.

## ⚡ 5-Minute Setup

### iOS App (iPhone)

**Step 1: Create iOS Project in Xcode**
```
1. Open Xcode
2. File → New → Project...
3. Select iOS → App
4. Name: FinanceTracker
5. Organization ID: com.ben.financetracker
6. Interface: SwiftUI
7. Language: Swift
8. Click Create
```

**Step 2: Add App Source**
```
1. Delete the default FinanceTrackerApp.swift created by Xcode
2. Drag ios/FinanceTrackerApp.swift into the project
3. Check "Copy items if needed"
```

**Step 3: Add Shared Code**
```
1. Right-click project folder → Add Files to FinanceTracker
2. Select Sources/ folder
3. Check "Copy items if needed"
4. Select the iOS target
5. Click Add
```

**Step 4: Set iOS Deployment**
```
1. Select project in Xcode
2. Build Settings → iOS Deployment Target: 16.0
```

**Step 5: Build**
```
Press Cmd+R
Or select iPhone 15 simulator and press Cmd+R
```

### macOS App (Mac)

**Step 1: Create macOS Project in Xcode**
```
1. Open Xcode
2. File → New → Project...
3. Select macOS → App
4. Name: FinanceTracker
5. Organization ID: com.ben.financetrackermac
6. Interface: SwiftUI
7. Language: Swift
8. Click Create
```

**Step 2: Add App Source**
```
1. Delete the default main file created by Xcode
2. Drag macos/FinanceTrackerMacApp.swift into the project
3. Rename it to: FinanceTrackerApp.swift
4. Check "Copy items if needed"
```

**Step 3: Add Shared Code**
```
1. Right-click project folder → Add Files to FinanceTracker
2. Select Sources/ folder
3. Check "Copy items if needed"
4. Select the macOS target
5. Click Add
```

**Step 4: Set macOS Deployment**
```
1. Select project in Xcode
2. Build Settings → macOS Deployment Target: 13.0
```

**Step 5: Build**
```
Press Cmd+R
App should launch on your Mac
```

---

## 📁 Project Structure Generated

After setup, your projects will look like:

```
FinanceTracker.xcodeproj (iOS)
├── Build/
├── Products/
├── Project.pbxproj
└── project.xcworkspace/

FinanceTracker.xcodeproj (macOS)
├── Build/
├── Products/
├── Project.pbxproj
└── project.xcworkspace/

Sources/
├── Models/
├── Managers/
└── Networking/
```

---

## 🔧 Backend Setup (Required for Sync)

Before testing the apps, start the backend:

```bash
cd backend
npm install
npm run build
npm start
```

The backend will run at `http://localhost:3000`

---

## ✅ Testing the App

### iOS App
1. Open iOS project in Xcode
2. Try adding a transaction
3. Check that it appears in the transaction list
4. Switch to macOS and verify sync

### macOS App
1. Open macOS project in Xcode
2. Add a budget
3. Check the dashboard updates
4. Switch to iOS and verify it appears

### Test Sync
```bash
# In terminal:
curl http://localhost:3000/api/transactions | jq
curl http://localhost:3000/api/budgets | jq
```

---

## 🎨 Customization

### Change App Name
```
Xcode → Project → Build Settings → Product Name
```

### Change Bundle ID
```
Xcode → Project → General → Bundle Identifier
```

### Change App Icon
```
Xcode → Assets → AppIcon
Drag your icon images here
```

### Change Team
```
Xcode → Project → General → Team
```

---

## ⚠️ Troubleshooting

### "Cannot find 'FinanceManager' in scope"
→ Make sure you added the Sources/ folder to the target

### "Module not found"
→ Build again: Cmd+B

### App crashes on launch
→ Check if backend is running
→ Check console: Cmd+Shift+C

### Preview not showing
→ Editor → Canvas (Cmd+Option+P)

---

## 📦 Distribution

Once the app is working locally, you can:

### For iOS
- Build for physical device in Xcode
- Submit to App Store
- Or distribute via TestFlight

### For macOS
- Build as DMG or archive
- Notarize with Apple
- Or distribute directly

---

## 🎉 You're Done!

Your Finance Tracker is now a fully functional native app! 

**Next steps:**
1. ✅ Create iOS and macOS projects
2. ✅ Add source files
3. ✅ Start backend server
4. 🎮 Test adding transactions
5. 📊 Test budget tracking  
6. 🔄 Test cross-device sync
7. 🚀 Distribute!

---

For more details, see:
- [XCODE_SETUP.md](XCODE_SETUP.md) - Detailed setup guide
- [SETUP.md](SETUP.md) - Full project setup
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [README.md](README.md) - Project overview
