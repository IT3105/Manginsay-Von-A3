import { Controller, Get, Post, Delete, Put, Body, Param } from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import { Expense } from './expense.model';

@Controller('expenses')
export class ExpensesController {
  constructor(private readonly expensesService: ExpensesService) {}

  @Get()
  async getAllExpenses(): Promise<Expense[]> {
    return this.expensesService.findAll();
  }

  @Post()
  async createExpense(@Body() expenseData: Expense): Promise<Expense> {
    return this.expensesService.create(expenseData);
  }

  @Delete(':id')
  async removeExpense(@Param('id') id: string): Promise<void> {
    return this.expensesService.remove(id);
  }

  @Put(':id')
  async updateExpense(@Param('id') id: string, @Body() expenseData: Expense): Promise<Expense> {
    return this.expensesService.update(id, expenseData);
  }
}
