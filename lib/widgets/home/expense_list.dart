import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:naukolatek/functions/decideLogo.dart';
import 'package:naukolatek/models/expense.dart';
import 'package:naukolatek/state/expenses.dart';
import 'package:naukolatek/state/sum.dart';
import 'package:naukolatek/styles/style.dart';

class ExpensesList extends ConsumerStatefulWidget {
  const ExpensesList({super.key});

  @override
  ConsumerState<ExpensesList> createState() => _ExpensesListState();
}

class _ExpensesListState extends ConsumerState<ExpensesList> {
  String formatTimestamp(Timestamp timestamp) {
    var format = DateFormat('d MMM y');
    return format.format(timestamp.toDate());
  }

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    var expenses = ref.watch(expensesProvider);
    var sum = ref.watch(totalExpensesProvider);
    ScrollController? _controller;
    return expenses.when(
      data: (data) {
        if (data.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Nie dodano żadnych wydatków",
                    style: h2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Dodaj swój pierwszy wydatek, aby śledzić swoje finansowe cele",
                    style: h4.copyWith(color: Colors.white.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else {
          final int pageCount = 2;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final expense = data[index];
                Color categoryColor = _getCategoryColor(expense.category);
                return Container(
                  color: const Color.fromARGB(255, 12, 0, 34),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color.fromARGB(255, 12, 0, 34).withOpacity(0.9),
                          categoryColor.withOpacity(0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        splashColor: categoryColor.withOpacity(0.1),
                        highlightColor: categoryColor.withOpacity(0.05),
                        onLongPress: () =>
                            _showEditBottomSheet(context, expense),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    categoryColor.withOpacity(0.8),
                                    categoryColor.withOpacity(0.4),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: decideLogo(expense.category),
                              ),
                            ),
                            title: Text(
                              expense.title.isNotEmpty
                                  ? '${expense.title}'
                                  : 'No title specified',
                              style: h2.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  expense.timestamp != null
                                      ? formatTimestamp(expense.timestamp!)
                                      : '',
                                  style: h4.copyWith(
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Text(
                                (expense.amount != null && expense.amount > 0)
                                    ? '${expense.amount.toStringAsFixed(2)}zł'
                                    : '',
                                style: h3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: data.length,
            ),
          );
        }
      },
      error: (e, s) => SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 40),
              SizedBox(height: 16),
              Text(
                'Wystąpił błąd podczas ładowania wydatków',
                style: h3.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "${e.toString()}",
                style: h4.copyWith(color: Colors.white.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      loading: () => SliverToBoxAdapter(
        child: Container(
          height: 100,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
      ),
    );
  }

  // Metoda określająca kolor dla kategorii
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'jedzenie':
        return Colors.green[600]!;
      case 'zdrowie':
        return Colors.red[400]!;
      case 'edukacja':
        return Colors.amber[600]!;
      case 'zainteresowania':
        return Colors.purple[400]!;
      case 'inne':
      default:
        return Colors.grey[500]!;
    }
  }

  // Metoda wyświetlająca bottom sheet do edycji wydatku
  void _showEditBottomSheet(BuildContext context, Expense expense) {
    var vw = MediaQuery.of(context).size.width;
    var titleController = TextEditingController();
    var priceController = TextEditingController();

    var categoryController = TextEditingController();

    final List<String> categories = [
      'Jedzenie',
      'Zdrowie',
      'Edukacja',
      'Zainteresowania',
      'Inne'
    ];

    String selectedCategory = expense.category;
    String id = expense.id ?? '132';
    Timestamp timestamp = expense.timestamp!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 12, 0, 34),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Uchwyt do przeciągania
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(height: 16),

                // Nagłówek
                Text(
                  'Edytuj wydatek',
                  style: h1.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 20),

                // Formularz edycji
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pole tytułu
                      Text(
                        'Tytuł',
                        style: h3.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: titleController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: expense.title,
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Pole kwoty
                      Text(
                        'Kwota (zł)',
                        style: h3.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: priceController,
                          style: TextStyle(color: Colors.white),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: expense.amount.toString(),
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Kategoria',
                        style: h3.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: categories.map((category) {
                            bool isSelected = selectedCategory == category;
                            Color catColor = _getCategoryColor(category);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                  categoryController.text = category;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            catColor.withOpacity(0.7),
                                            catColor.withOpacity(0.4),
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.white.withOpacity(0.05),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    decideLogo(category),
                                    SizedBox(width: 8),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.7),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('expenses')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('user_expenses')
                                  .doc(id)
                                  .delete();
                              Navigator.pop(context);
                            },
                            label: Text(
                              "Usuń",
                              style: h3,
                            ),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          // Przycisk anulowania
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Anuluj',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.withOpacity(0.3),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),

                          // Przycisk zapisywania
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                var changes = Expense(
                                    category: selectedCategory,
                                    amount:
                                        double.tryParse(priceController.text) ??
                                            expense.amount,
                                    title: titleController.text.isNotEmpty
                                        ? titleController.text
                                        : expense.title,
                                    id: id,
                                    timestamp: timestamp);
                                FirebaseFirestore.instance
                                    .collection('expenses')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('user_expenses')
                                    .doc(id)
                                    .update(changes.toJson());

                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Zapisz',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
