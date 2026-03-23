# Finance Tracker - Quick Start (5 Minutes)

## 🚀 Get Running in 5 Minutes

### Prerequisites
- Node.js 18+ installed
- Xcode with iOS/macOS development tools
- Terminal access

### Step 1: Start Backend (1 minute)

```bash
cd backend
npm install
npm run dev
```

✅ Backend running at `http://localhost:3000`

### Step 2: Launch iOS App (2 minutes)

```bash
# In a new terminal
open ios/FinanceTrackerApp.swift
```

In Xcode:
1. Select iPhone simulator (or device)
2. Press Cmd+R to run

✅ iOS app syncs automatically

### Step 3: Launch macOS App (2 minutes)

```bash
# In a new terminal
open macos/FinanceTrackerMacApp.swift
```

In Xcode:
1. Select "Any Mac" from scheme
2. Press Cmd+R to run

✅ macOS app syncs automatically

---

## 📱 Try It Out

### Add First Transaction (iOS)
1. Tap "Transactions" tab
2. Tap "+" to add transaction
3. Fill in: Title, Amount, Category
4. Tap "Save"
5. Watch the Dashboard update! ✨

### Check Sync (Backend)
Open terminal and run:
```bash
curl http://localhost:3000/api/transactions | jq
```

This shows all transactions synced to backend!

### Switch to macOS
Transactions appear automatically in macOS app too! 🎉

---

## 🎯 Next: Customize the App

### Change Categories
Edit `Sources/Models/Transaction.swift` - modify `TransactionCategory` enum

### Add Features
Edit `Sources/Managers/FinanceManager.swift` - add new methods

### Adjust UI
- iOS: Edit `ios/FinanceTrackerApp.swift`
- macOS: Edit `macos/FinanceTrackerMacApp.swift`

---

## 📚 Learn More

- **Architecture**: See `ARCHITECTURE.md`
- **Full Setup**: See `SETUP.md`
- **Code Details**: See `README.md`

---

## ✅ Checklist

- [ ] Backend running (`npm run dev`)
- [ ] iOS app opened in Xcode
- [ ] macOS app opened in Xcode
- [ ] Added test transaction
- [ ] Verified sync in both apps
- [ ] Checked backend with curl

Great! You're all set! 🚀

---

## 🆘 Quick Troubleshooting

### Backend won't start?
```bash
# Clear and reinstall
rm -rf backend/node_modules
npm install
npm run dev
```

### Can't connect to backend?
```bash
# Check if running
curl http://localhost:3000/api/health
```

### App crashes?
1. Check Xcode console for errors
2. Verify backend is running
3. Check `API_BASE_URL` in code

Need more help? Check SETUP.md!
