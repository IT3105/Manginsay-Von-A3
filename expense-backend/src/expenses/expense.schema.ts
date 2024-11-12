import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class Expense extends Document {
  @Prop()
  description: string;

  @Prop()
  amount: number;

  @Prop()
  date: string;
}

export const ExpenseSchema = SchemaFactory.createForClass(Expense);
