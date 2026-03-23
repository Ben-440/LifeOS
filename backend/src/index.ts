import express, { Request, Response } from 'express';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';
import dotenv from 'dotenv';
import { Database } from './database';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const db = new Database();

// Middleware
app.use(cors());
app.use(express.json());

// Request logging
app.use((req: Request, res: Response, next: Function) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// MARK: - Transactions Endpoints
app.get('/api/transactions', async (req: Request, res: Response) => {
  try {
    const transactions = await db.getTransactions();
    res.json(transactions);
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

app.post('/api/transactions/sync', async (req: Request, res: Response) => {
  try {
    const transactions = req.body;
    
    if (!Array.isArray(transactions)) {
      return res.status(400).json({ error: 'Expected array of transactions' });
    }

    for (const transaction of transactions) {
      await db.saveTransaction(transaction);
    }

    res.json({ success: true, count: transactions.length });
  } catch (error) {
    console.error('Error syncing transactions:', error);
    res.status(500).json({ error: 'Failed to sync transactions' });
  }
});

app.post('/api/transactions', async (req: Request, res: Response) => {
  try {
    const transaction = req.body;
    const saved = await db.saveTransaction(transaction);
    res.status(201).json(saved);
  } catch (error) {
    console.error('Error creating transaction:', error);
    res.status(500).json({ error: 'Failed to create transaction' });
  }
});

app.delete('/api/transactions/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await db.deleteTransaction(id);
    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting transaction:', error);
    res.status(500).json({ error: 'Failed to delete transaction' });
  }
});

// MARK: - Budgets Endpoints
app.get('/api/budgets', async (req: Request, res: Response) => {
  try {
    const budgets = await db.getBudgets();
    res.json(budgets);
  } catch (error) {
    console.error('Error fetching budgets:', error);
    res.status(500).json({ error: 'Failed to fetch budgets' });
  }
});

app.post('/api/budgets/sync', async (req: Request, res: Response) => {
  try {
    const budgets = req.body;
    
    if (!Array.isArray(budgets)) {
      return res.status(400).json({ error: 'Expected array of budgets' });
    }

    for (const budget of budgets) {
      await db.saveBudget(budget);
    }

    res.json({ success: true, count: budgets.length });
  } catch (error) {
    console.error('Error syncing budgets:', error);
    res.status(500).json({ error: 'Failed to sync budgets' });
  }
});

app.post('/api/budgets', async (req: Request, res: Response) => {
  try {
    const budget = req.body;
    const saved = await db.saveBudget(budget);
    res.status(201).json(saved);
  } catch (error) {
    console.error('Error creating budget:', error);
    res.status(500).json({ error: 'Failed to create budget' });
  }
});

// MARK: - Health Check
app.get('/api/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(port, () => {
  console.log(`Finance Tracker API running at http://localhost:${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
