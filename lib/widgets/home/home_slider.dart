import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naukolatek/functions/analyzeProduct.dart';
import 'package:naukolatek/styles/style.dart';
import 'package:naukolatek/widgets/pie_chart.dart';
import 'package:naukolatek/widgets/spendingChart.dart';

class HomeSlider extends ConsumerWidget {
  const HomeSlider(this.budget, this.expenses, {super.key});
  final double budget;
  final double expenses;

  // Constants for better maintainability
  static const _minOpacity = 0.05;
  static const _cornerRadius = 16.0;
  static const _borderWidth = 1.0;
  static const _animationDuration = Duration(milliseconds: 150);
  static const _fasterAnimationDuration = Duration(milliseconds: 300);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final backgroundBubbles = Positioned.fill(
      child: Opacity(
        opacity: 0.08,
        // RepaintBoundary zapobiega odmalowywaniu tego elementu podczas scrollowania
        child: RepaintBoundary(
          child: CustomPaint(
            // Używamy stałej referencji do paintera
            painter: BubblePainter(),
            // Określamy rozmiar, by uniknąć dynamicznego dopasowywania
            size: Size(screenSize.width, height),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedHeight = height * 0.7;
        final minHeight = height * 0.5;
        final maxExtent = constraints.maxHeight;

        // Calculate animation percentage based on scroll position
        final percentage =
            ((maxExtent - minHeight) / (expandedHeight - minHeight))
                .clamp(0.0, 1.0);

        final actionButtonsOpacity = percentage < 0.4 ? percentage * 2.5 : 1.0;
        final otherDataOpacity = percentage;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2E0063),
                Color(0xFF0C0022),
              ],
              stops: [0.2, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000), // Using hex for opacity
                offset: Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Stack(
            children: [
              backgroundBubbles,
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: PageView.builder(
                        itemCount: 2, // Dodaj określoną liczbę stron
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return topAndChart(
                                context, height, percentage, otherDataOpacity);
                          } else if (index == 1) {
                            return spendingChartPage(context, height,
                                percentage, actionButtonsOpacity);
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AnimatedOpacity(
                        duration: _animationDuration,
                        opacity: actionButtonsOpacity,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildActionButtons(context),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget topAndChart(BuildContext context, double height, double percentage,
      otherDataOpacity) {
    return Expanded(
      flex: 7, // Allocate more space for the chart area
      child: Column(
        children: [
          Expanded(
              child:
                  _buildFinancialSummary(context, height * 0.55, percentage)),
          AnimatedContainer(
            duration: _animationDuration,
            height: otherDataOpacity * 120, // Smooth height animation
            child: AnimatedOpacity(
              opacity: otherDataOpacity,
              duration: _animationDuration,
              child: _buildRemainingBudgetInfo(budget, expenses),
            ),
          ),
        ],
      ),
    );
  }

  Widget spendingChartPage(
      BuildContext context, double height, double percentage, double opacity) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            'Oszczędzanie',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xF2FFFFFF), // Better than opacity for text
              letterSpacing: 0.5,
            ),
          ),
          AnimatedOpacity(
            duration: _fasterAnimationDuration,
            opacity: opacity,
            child: Transform.scale(
              scale: 0.9 + (percentage * 0.1),
              child: buildSpendingChart(
                  MediaQuery.of(context).size.height * 0.001),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(
      BuildContext context, double height, double percentage) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text(
          'Zaloguj się, aby zobaczyć swoje dane finansowe',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final baseSize = height * 0.4;
    final sizeVariation = height * 0.1;
    final chartSize =
        baseSize + (sizeVariation * percentage * 0.9).clamp(0.0, sizeVariation);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(userId)
          .doc('userData')
          .snapshots(),
      builder: (context, userDataSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('expenses')
              .doc(userId)
              .collection('user_expenses')
              .snapshots(),
          builder: (context, expensesSnapshot) {
            if (!userDataSnapshot.hasData || !expensesSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              );
            }

            final userData =
                userDataSnapshot.data?.data() as Map<String, dynamic>? ?? {};
            final budget = userData['budget'] as double? ?? 200.0;
            final income = userData['income'] as double? ?? 300.0;

            double totalExpenses = 0.0;
            for (var doc in expensesSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              totalExpenses += (data['amount'] as num).toDouble();
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Financial info header
                _buildFinancialInfoHeader(income, budget, totalExpenses),

                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: _animationDuration,
                      height: chartSize,
                      width: chartSize,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: chartSize * 0.8,
                            height: chartSize * 0.8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.2),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          // Pie chart
                          Pie(chartSize,
                              totalExpenses: totalExpenses, budget: budget),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFinancialInfoHeader(
      double income, double budget, double expenses) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Text(
            'Przegląd budżetu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xF2FFFFFF), // Better than opacity for text
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFinancialInfoItem('Przychód', income, Icons.arrow_downward,
                  Colors.green.shade300),
              _buildFinancialInfoItem('Budżet', budget,
                  Icons.account_balance_wallet, Colors.blue.shade300),
              _buildFinancialInfoItem(
                  'Wydatki', expenses, Icons.arrow_upward, Colors.red.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInfoItem(
      String label, double value, IconData icon, Color accentColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_cornerRadius - 4),
            border: Border.all(
              color: Colors.white.withOpacity(_minOpacity),
              width: _borderWidth,
            ),
          ),
          child: Icon(icon, color: accentColor, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} zł',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingBudgetInfo(double budget, double expenses) {
    final remaining = budget - expenses;
    final isOverBudget = remaining < 0;
    final statusColor =
        isOverBudget ? Colors.red.shade300 : Colors.green.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_minOpacity),
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: _borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Ensure this takes minimum space needed
        children: [
          Text(
            isOverBudget ? 'Przekroczono budżet o:' : 'Pozostało z budżetu:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOverBudget
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: statusColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                '${isOverBudget ? '-' : ''}${remaining.abs().toStringAsFixed(2)} zł',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple.withOpacity(0.8), Colors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showResultEditingDialog(
      BuildContext context, Map<String, dynamic> resultData) {
    final TextEditingController nameController =
        TextEditingController(text: resultData['title'] ?? '');
    final TextEditingController priceController = TextEditingController(
      text: resultData['price'] != null ? resultData['price'].toString() : '',
    );

    String selectedCategory = resultData['category'] ?? 'Inne';
    final List<String> categories = [
      'Jedzenie',
      'Zdrowie',
      'Edukacja',
      'Zainteresowania',
      'Praca',
      'Inne'
    ];

    // Make sure the category is one of our valid options
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Inne';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 12, 0, 34).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.withOpacity(0.9),
                              Colors.deepPurple.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Edytuj pozycję',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      // Form fields
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field
                            Text(
                              'Nazwa',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: nameController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: InputBorder.none,
                                  hintText: 'Wpisz nazwę',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4)),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Category dropdown
                            Text(
                              'Kategoria',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  dropdownColor:
                                      const Color.fromARGB(255, 25, 10, 60),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.white.withOpacity(0.7)),
                                  style: TextStyle(color: Colors.white),
                                  items: categories.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedCategory = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Price field
                            Text(
                              'Kwota (zł)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: priceController,
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4)),
                                  suffixText: 'zł',
                                  suffixStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text('Anuluj'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  var docRef = FirebaseFirestore.instance
                                      .collection('expenses')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('user_expenses')
                                      .doc();

                                  var docId = docRef.id;

                                  final updatedData = {
                                    'id':
                                        docId, // Przechowujemy ID dokumentu wewnątrz danych
                                    'title': nameController.text,
                                    'category': selectedCategory,
                                    'amount':
                                        double.tryParse(priceController.text) ??
                                            0.0,
                                    'timestamp': DateTime.now(),
                                  };

                                  await docRef.set(updatedData);
                                  Navigator.of(context).pop();

                                  // Show confirmation
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Wydatek został dodany'),
                                      backgroundColor: Colors.green.shade800,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text('Zapisz'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

// Update your analyzeProduct function to show the dialog when data is returned
  Future<void> analyzeProductAndShowDialog(BuildContext context) async {
    // Call your existing analyzeProduct function
    final productData = await analyzeProduct(context);

    // If data was returned, show the editing dialog
    if (productData != null) {
      _showResultEditingDialog(context, productData);
    }
  }

  Future<void> analyzeReceiptAndShowDialog(BuildContext context) async {
    final receiptData = await analyzeReceipt(context);

    if (receiptData != null) {
      _showResultEditingDialog(context, receiptData);
    }
  }

// Add this method to handle manual entry
  void _showManualEntryDialog(BuildContext context) {
    // Create empty data to initialize the form
    final emptyData = {
      'title': '',
      'category': 'Inne',
      'price': 0.0,
    };

    _showResultEditingDialog(context, emptyData);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_minOpacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(_minOpacity),
          width: _borderWidth,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Skanuj produkt',
            onPressed: () => analyzeProductAndShowDialog(context),
          ),
          _buildActionButton(
            icon: Icons.document_scanner,
            label: 'Skanuj paragon',
            onPressed: () => analyzeReceiptAndShowDialog(context),
          ),
          _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Dodaj ręcznie',
            onPressed: () => _showManualEntryDialog(context),
          ),
        ],
      ),
    );
  }

  // MODAL DIALOGS
  // (The rest of the code remains the same)

  // HELPER METHODS
}

// This painter was referenced but not implemented in the code
class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent bubbles
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Create multiple bubbles
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
