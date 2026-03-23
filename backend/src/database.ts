import sqlite3 from 'sqlite3';
import path from 'path';
import { promisify } from 'util';

// Use process.cwd() for database path to avoid __dirname issues
const DB_PATH = process.env.DB_PATH || path.resolve(process.cwd(), 'finance_tracker.db');

export interface Transaction {
  id: string;
  title: string;
  amount: string;
  category: string;
  date: string;
  notes?: string;
  isExpense: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface Budget {
  id: string;
  category: string;
  limit: string;
  month: number;
  year: number;
  createdAt?: string;
  updatedAt?: string;
}

export class Database {
  private db: sqlite3.Database;

  constructor() {
    this.db = new sqlite3.Database(DB_PATH, (err: Error | null) => {
      if (err) {
        console.error('Error opening database:', err);
      } else {
        console.log('Connected to SQLite database');
        this.initializeTables();
      }
    });
  }

  private initializeTables() {
    this.db.serialize(() => {
      // Transactions table
      this.db.run(`
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
        )
      `);

      // Budgets table
      this.db.run(`
        CREATE TABLE IF NOT EXISTS budgets (
          id TEXT PRIMARY KEY,
          category TEXT NOT NULL,
          "limit" TEXT NOT NULL,
          month INTEGER NOT NULL,
          year INTEGER NOT NULL,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(category, month, year)
        )
      `);

      // Create indices for common queries
      this.db.run(`
        CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)
      `);

      this.db.run(`
        CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category)
      `);

      this.db.run(`
        CREATE INDEX IF NOT EXISTS idx_budgets_month_year ON budgets(month, year)
      `);
    });
  }

  // MARK: - Transaction Methods
  async getTransactions(): Promise<Transaction[]> {
    return new Promise((resolve, reject) => {
      this.db.all(
        'SELECT * FROM transactions ORDER BY date DESC',
        (err: Error | null, rows: Transaction[]) => {
          if (err) reject(err);
          else resolve(rows || []);
        }
      );
    });
  }

  async saveTransaction(transaction: Transaction): Promise<Transaction> {
    return new Promise((resolve, reject) => {
      const now = new Date().toISOString();
      
      this.db.run(
        `INSERT OR REPLACE INTO transactions (id, title, amount, category, date, notes, isExpense, updatedAt)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          transaction.id,
          transaction.title,
          transaction.amount,
          transaction.category,
          transaction.date,
          transaction.notes || null,
          transaction.isExpense ? 1 : 0,
          now
        ],
        (err: Error | null) => {
          if (err) reject(err);
          else resolve({ ...transaction, updatedAt: now });
        }
      );
    });
  }

  async deleteTransaction(id: string): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.run(
        'DELETE FROM transactions WHERE id = ?',
        [id],
        (err: Error | null) => {
          if (err) reject(err);
          else resolve();
        }
      );
    });
  }

  // MARK: - Budget Methods
  async getBudgets(): Promise<Budget[]> {
    return new Promise((resolve, reject) => {
      this.db.all(
        'SELECT * FROM budgets ORDER BY year DESC, month DESC',
        (err: Error | null, rows: Budget[]) => {
          if (err) reject(err);
          else resolve(rows || []);
        }
      );
    });
  }

  async saveBudget(budget: Budget): Promise<Budget> {
    return new Promise((resolve, reject) => {
      const now = new Date().toISOString();
      
      this.db.run(
        `INSERT OR REPLACE INTO budgets (id, category, "limit", month, year, updatedAt)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          budget.id,
          budget.category,
          budget.limit,
          budget.month,
          budget.year,
          now
        ],
        (err: Error | null) => {
          if (err) reject(err);
          else resolve({ ...budget, updatedAt: now });
        }
      );
    });
  }

  // MARK: - Analytics Methods
  async getMonthlySpending(month: number, year: number): Promise<any[]> {
    return new Promise((resolve, reject) => {
      this.db.all(
        `SELECT category, SUM(amount) as total FROM transactions
         WHERE isExpense = 1
         AND strftime('%m', date) = ? 
         AND strftime('%Y', date) = ?
         GROUP BY category`,
        [String(month).padStart(2, '0'), String(year)],
        (err: Error | null, rows: any[]) => {
          if (err) reject(err);
          else resolve(rows || []);
        }
      );
    });
  }

  close(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.close((err: Error | null) => {
        if (err) reject(err);
        else resolve();
      });
    });
  }
}
