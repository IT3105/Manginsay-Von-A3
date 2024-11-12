import { Schema, Document, model } from 'mongoose';

export interface Expense extends Document {
  description: string;
  amount: number;
  date: Date; 
}

export const ExpenseSchema = new Schema<Expense>({
  description: { type: String, required: true },
  amount: { type: Number, required: true },
  date: { type: Date, required: true },
});

export const ExpenseModel = model<Expense>('Expense', ExpenseSchema);
