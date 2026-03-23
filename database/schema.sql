-- Finance Tracker Database Schema

-- Transactions table
CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  amount TEXT NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  notes TEXT,
  isExpense INTEGER NOT NULL,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Index for common queries
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category);

-- Budgets table
CREATE TABLE IF NOT EXISTS budgets (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  "limit" TEXT NOT NULL,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(category, month, year)
);

-- Index for budget queries
CREATE INDEX IF NOT EXISTS idx_budgets_month_year ON budgets(month, year);
