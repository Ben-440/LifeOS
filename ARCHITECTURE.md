# Finance Tracker - Architecture Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     iOS App (SwiftUI)                        │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Dashboard   │  │ Transactions │  │   Budgets    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│           │               │                   │              │
│           └───────────────┴───────────────────┘              │
│                           │                                   │
│                    FinanceManager                            │
│                    (ObservableObject)                        │
│                           │                                   │
└───────────────────────────┼───────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
      ┌───▼────┐       ┌────▼────┐      ┌───▼────────┐
      │APIClient│       │APIClient│      │APIClient   │
      │(iOS)   │       │(macOS)   │      │(Shared)    │
      └────────┘       └──────────┘      └────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
    ┌───▼──────────┐   ┌────▼────┐   ┌────────▼────┐
    │Local Storage │   │  REST   │   │LocalDataStore│
    │(JSON Files)  │   │   API   │   │  (Fallback) │
    └───────────────┘   └────────┘   └─────────────┘
                            │
                    ┌───────▼────────┐
                    │   Backend      │
                    │  (Node.js/     │
                    │  Express/      │
                    │  TypeScript)   │
                    └────────────────┘
                            │
                    ┌───────▼────────┐
                    │  SQLite DB     │
                    │   Database     │
                    └────────────────┘
```

## Component Responsibilities

### iOS & macOS Apps
- **UI Layer**: SwiftUI views for iOS and macOS
- **State Management**: FinanceManager using @StateObject/@EnvironmentObject
- **Local Storage**: JSONEncoder/Decoder for offline access
- **Sync**: Automatic background sync with backend

### Shared Swift Code (`Sources/`)
- **Models**: Transaction, MonthlyBudget, TransactionCategory
- **FinanceManager**: Core business logic for finance operations
- **APIClient**: RESTful API communication (async/await)
- **LocalDataStore**: Offline data persistence

### Backend (Node.js/Express)
- **HTTP Server**: RESTful API endpoints
- **Database**: SQLite for persistent data storage
- **Sync Handler**: Merges data from multiple clients
- **Analytics**: Monthly spending calculations

## Data Flow

### Adding a Transaction (iOS)

```
User Input Form
        │
        ▼
Create Transaction object
        │
        ▼
FinanceManager.addTransaction()
        │
        ├─→ Update @Published transactions array
        │
        ├─→ Save locally (LocalDataStore)
        │
        └─→ Sync with backend (APIClient.postTransactions)
                   │
                   ▼
            Backend receives POST
                   │
                   ├─→ Save to SQLite
                   │
                   └─→ Return confirmation
```

### Fetching Data on App Launch

```
App Launch
   │
   ▼
FinanceManager.loadData()
   │
   ├─→ Try: Sync from backend (GET /api/transactions, /api/budgets)
   │          │
   │          └─→ Update @Published properties
   │
   └─→ Fallback: Load from local storage if offline
```

## Data Persistence Strategy

### Three-Tier Approach

1. **In-Memory** (FinanceManager @Published properties)
   - Fast UI updates
   - Real-time reactivity

2. **Local Storage** (JSON files)
   - Offline access
   - Fallback when API unavailable
   - Data available on all platforms

3. **Backend Database** (SQLite)
   - Source of truth
   - Cloud synchronization
   - Cross-device sync
   - Data backup

## Concurrency Model

### Swift (iOS/macOS)
- Uses `@MainActor` for FinanceManager
- Async/await for all network calls
- Actors (Database) for thread-safe operations

### Backend
- Express middleware for request handling
- Promise-based async operations
- SQLite wrapped in Promises

## API Contract

### Request Format
```json
{
  "id": "UUID",
  "title": "Coffee",
  "amount": "5.50",
  "category": "Food & Dining",
  "date": "2024-03-23T10:00:00.000Z",
  "notes": "Morning coffee",
  "isExpense": true
}
```

### Response Format
```json
{
  "success": true,
  "count": 1
}
```

## Error Handling

### Network Failures
- Graceful degradation to local storage
- Automatic retry on restore
- Toast notifications for user feedback

### Validation
- Client-side validation in SwiftUI forms
- Server-side validation in Express routes
- Decimal precision for currency

## Security Considerations

### Current Implementation
- Local storage in app's Application Support directory
- SQLite with basic file permissions
- CORS enabled for all origins (development only)

### Production Recommendations
- Implement user authentication (JWT/OAuth)
- Add HTTPS/TLS encryption
- Restrict CORS to specific domains
- Implement rate limiting
- Add request validation middleware
- Use environment-specific configuration
- Enable database encryption

## Performance Optimizations

### Already Implemented
- Database indices on commonly queried fields
- In-memory caching of transactions
- Batch sync operations
- Lazy loading of data

### Potential Improvements
- Pagination for large transaction lists
- Caching layer (Redis)
- GraphQL for flexible queries
- Background sync queue
- Image optimization for receipts

## Testing Strategy

### Unit Tests
- Test FinanceManager logic
- Test data models serialization
- Test API client requests

### Integration Tests
- Full sync workflow
- Offline to online transition
- Conflict resolution

### UI Tests
- SwiftUI view interactions
- Form validation
- Navigation flow

## Deployment

### Development
```bash
# Backend
cd backend
npm run dev

# iOS
Open in Xcode and run on simulator
```

### Production
```bash
# Build backend
npm run build

# Run production
npm start

# Database
Ensure DB_PATH points to persistent location
```

## Future Scalability

### Multi-User Support
- Add user authentication
- User isolation in queries
- Cloud storage (S3/Azure)

### Mobile Sync Framework
- Replace custom sync with CloudKit/Firebase
- Real-time updates with WebSocket
- Offline queuing system

### Analytics
- Dashboard metrics
- Spending trends
- Budget recommendations

## Monitoring & Logging

### Backend Logging
- Request/response logging
- Error tracking
- Performance metrics

### Client Logging
- Sync status
- Error events
- User actions (optional)

### Database Monitoring
- Query performance
- Storage usage
- Backup validation
