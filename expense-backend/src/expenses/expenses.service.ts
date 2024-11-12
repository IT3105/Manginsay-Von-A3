import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Expense } from './expense.model';

@Injectable()
export class ExpensesService {
  constructor(
    @InjectModel('Expense') private readonly expenseModel: Model<Expense>,
  ) {}

  async findAll(): Promise<Expense[]> {
    return this.expenseModel.find().exec();
  }

  async create(expenseData: Expense): Promise<Expense> {
    const newExpense = new this.expenseModel(expenseData);
    return newExpense.save();
  }

  async remove(id: string): Promise<void> {
    await this.expenseModel.findByIdAndDelete(id).exec();
  }

  async update(id: string, expenseData: Expense): Promise<Expense> {
    const updatedExpense = await this.expenseModel.findByIdAndUpdate(id, expenseData, { new: true });
    if (!updatedExpense) {
      throw new Error('Expense not found');
    }

    return updatedExpense;
  }
}
