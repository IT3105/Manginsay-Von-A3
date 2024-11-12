import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExpenseListPage(),
    );
  }
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String date;

  Expense({required this.id, required this.description, required this.amount, required this.date});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      date: json['date'],
    );
  }

  String get formattedDate {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final DateFormat formatter = DateFormat('MM/dd/yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  List<Expense> expenses = [];

  Future<void> fetchExpenses() async {
    final response = await http.get(Uri.parse('http://localhost:3001/expenses'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        expenses = data.map((expense) => Expense.fromJson(expense)).toList();
      });
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<void> deleteExpense(String id) async {
    final response = await http.delete(Uri.parse('http://localhost:3001/expenses/$id'));

    if (response.statusCode == 200) {
      fetchExpenses();
    } else {
      throw Exception('Failed to delete expense');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExpensePage(onExpenseAdded: fetchExpenses)),
                );
              },
              child: const Text('Add Expense'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(expense.description),
                          const SizedBox(height: 4),
                          Text('\$${expense.amount.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(expense.formattedDate),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddExpensePage(
                                    expense: expense,
                                    onExpenseAdded: fetchExpenses,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteExpense(expense.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddExpensePage extends StatefulWidget {
  final Function onExpenseAdded;
  final Expense? expense;

  const AddExpensePage({super.key, required this.onExpenseAdded, this.expense});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _dateController.text = widget.expense!.date;
    }
  }

  Future<void> submitExpense() async {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final date = _dateController.text;

    if (description.isEmpty || amount <= 0 || date.isEmpty) {
      return;
    }

    final body = json.encode({
      'description': description,
      'amount': amount,
      'date': date,
    });

    if (widget.expense == null) {
      // Add new expense
      final response = await http.post(
        Uri.parse('http://localhost:3001/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        widget.onExpenseAdded();
        Navigator.pop(context);
      } else {
        throw Exception('Failed to add expense');
      }
    } else {
      // Update existing expense
      final response = await http.put(
        Uri.parse('http://localhost:3001/expenses/${widget.expense!.id}'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        widget.onExpenseAdded();
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update expense');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date',
                hintText: 'Select Date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context), // Open date picker
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitExpense,
              child: Text(widget.expense == null ? 'Add Expense' : 'Update Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
