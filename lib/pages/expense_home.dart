import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naukolatek/state/user_goals.dart';
import 'package:naukolatek/styles/style.dart';
import 'package:naukolatek/widgets/carousel.dart';
import 'package:naukolatek/widgets/home/expense_list.dart';
import 'package:naukolatek/widgets/home/home_slider.dart';

class ExpenseHomePage extends ConsumerStatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends ConsumerState<ExpenseHomePage> {
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> mapData = {};
    var test = ref.watch(userGoalsProvider);
    test.when(
      data: (data) {
        print(data.data());

        mapData = data.data()!;
      },
      error: (error, stackTrace) => print(error.toString()),
      loading: () => print('loading...'),
    );

    var goals = FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc('userData')
        .get();
    final vh = MediaQuery.of(context).size.height;

    Widget _buildBudgetItemNew(String category, String amount, Color color,
        [bool isHeader = false]) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                category,
                style: TextStyle(
                  fontSize: isHeader ? 16 : 15,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                  color: Colors.white.withOpacity(isHeader ? 1.0 : 0.85),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isHeader
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
              ),
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: isHeader ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: isHeader ? Colors.blue[200] : Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 0, 34),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          FirebaseAuth.instance.currentUser!.photoURL != null
                              ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!)
                              : null,
                      child: FirebaseAuth.instance.currentUser!.photoURL == null
                          ? Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10),
                    child: IconButton(
                      alignment: Alignment.topCenter,
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ), // FirebaseAuth.instance.signOut();
                      // context.go('/');

                      onPressed: () async {
                        var documentSnapshot = await goals;
                        Map<String, double> userData = {};
                        if (documentSnapshot.exists) {
                          var data =
                              documentSnapshot.data() as Map<String, dynamic>;
                          for (var entry in data.entries) {
                            if (entry.value is double) {
                              var doubleVal = (entry.value);
                              userData[entry.key] = doubleVal;
                            }
                          }
                        }
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final size = MediaQuery.of(context).size;

                            return BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Dialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                insetPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 24),
                                child: Container(
                                  width: size.width * 0.9,
                                  constraints: BoxConstraints(
                                      maxHeight: size.height * 0.8),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 12, 0, 34)
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Header z gradientem
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.purple.withOpacity(0.7),
                                              Colors.deepPurple
                                                  .withOpacity(0.7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Profil użytkownika',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close,
                                                  color: Colors.white),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Zawartość profilu
                                      Expanded(
                                        child: SingleChildScrollView(
                                          physics: BouncingScrollPhysics(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24.0,
                                                vertical: 16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Avatar użytkownika z efektem glare
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      width: 110,
                                                      height: 110,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Colors.blue
                                                                .withOpacity(
                                                                    0.5),
                                                            Colors.purple
                                                                .withOpacity(
                                                                    0.5),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    CircleAvatar(
                                                      radius: 50,
                                                      backgroundColor: Colors
                                                          .white
                                                          .withOpacity(0.15),
                                                      backgroundImage: FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .photoURL !=
                                                              null
                                                          ? NetworkImage(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .photoURL!)
                                                          : null,
                                                      child: FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .photoURL ==
                                                              null
                                                          ? Icon(Icons.person,
                                                              size: 50,
                                                              color:
                                                                  Colors.white)
                                                          : null,
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 20),

                                                // Dane użytkownika
                                                Text(
                                                  FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .displayName ??
                                                      'Brak nazwy',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                SizedBox(height: 8),

                                                Text(
                                                  FirebaseAuth.instance
                                                          .currentUser!.email ??
                                                      'Brak adresu email',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  ),
                                                ),

                                                SizedBox(height: 30),

                                                // Tytuł sekcji celów
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    'Przewidywane cele',
                                                    style: h2.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),

                                                SizedBox(height: 16),

                                                // Lista budżetów
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    color: Colors.white
                                                        .withOpacity(0.05),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      _buildBudgetItemNew(
                                                        'Budżet całkowity',
                                                        "${userData['budget']}zł"
                                                            .toString(),
                                                        Colors.blue[400]!,
                                                        true,
                                                      ),
                                                      Divider(
                                                        height: 1,
                                                        thickness: 1,
                                                        color: Colors.white
                                                            .withOpacity(0.1),
                                                        indent: 16,
                                                        endIndent: 16,
                                                      ),
                                                      _buildBudgetItemNew(
                                                        'Jedzenie',
                                                        "${userData['food']}zł"
                                                            .toString(),
                                                        Colors.green[400]!,
                                                      ),
                                                      _buildBudgetItemNew(
                                                        'Zdrowie',
                                                        "${userData['health']}zł"
                                                            .toString(),
                                                        Colors.red[400]!,
                                                      ),
                                                      _buildBudgetItemNew(
                                                        'Zainteresowania',
                                                        "${userData['hobby']}zł"
                                                            .toString(),
                                                        Colors.purple[400]!,
                                                      ),
                                                      _buildBudgetItemNew(
                                                        'Edukacja',
                                                        "${userData['education']}zł"
                                                            .toString(),
                                                        Colors.amber[400]!,
                                                      ),
                                                      _buildBudgetItemNew(
                                                        'Inne',
                                                        "${userData['other']}zł"
                                                            .toString(),
                                                        Colors.grey[400]!,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      FirebaseAuth.instance
                                                          .signOut();
                                                    },
                                                    child: Text(
                                                      'Wyloguj się',
                                                      style: h3.copyWith(
                                                          color: Colors.white),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 16),
                                                      minimumSize: Size(
                                                          double.infinity, 50),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Przycisk zamykający
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Zamknij',
                                            style: h3.copyWith(
                                                color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            minimumSize:
                                                Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      color: const Color.fromARGB(195, 66, 66, 66),
                    ),
                  )
                ],
                flexibleSpace: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection(FirebaseAuth.instance.currentUser!.uid)
                      .doc('userData')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return HomeSlider(0, 0);
                    }

                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    double budget = (userData['budget'] ?? 0).toDouble();

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('expenses')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('user_expenses')
                          .snapshots(),
                      builder: (context, expensesSnapshot) {
                        double totalExpenses = 0.0;
                        if (expensesSnapshot.hasData) {
                          for (var doc in expensesSnapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            totalExpenses += (data['amount'] as num).toDouble();
                          }
                        }
                        return HomeSlider(budget, totalExpenses);
                      },
                    );
                  },
                ),
                expandedHeight: vh * 0.7,
                stretch: true,
                collapsedHeight: vh * 0.38,
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: const Color.fromARGB(255, 12, 0, 34),
                  height: 224,
                  width: 200,
                  child: SnapCarousel(mapData),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: const Color.fromARGB(255, 12, 0, 34),
                  padding: EdgeInsets.only(left: 20, bottom: 10),
                  child: Text(
                    'Twoje wydatki',
                    style: h1.copyWith(color: Colors.white),
                  ),
                ),
              ),
              ExpensesList(),
              SliverToBoxAdapter(
                child: Container(
                  height: 20,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
