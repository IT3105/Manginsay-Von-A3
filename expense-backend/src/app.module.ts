import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ExpensesModule } from './expenses/expenses.module';

@Module({
  imports: [
    MongooseModule.forRoot('mongodb+srv://vonmanginsay:cnXgJmEbLihSbisB@cluster0.0sacu.mongodb.net/expense-tracker'),
    ExpensesModule,
  ],
})
export class AppModule {}
