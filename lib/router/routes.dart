import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naukolatek/pages/expense_home.dart';
import 'package:naukolatek/pages/login.dart';
import 'package:naukolatek/pages/user_data_form.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final bool isLoggedIn = await checkIfUserIsLoggedIn();
    if (isLoggedIn && state.fullPath == '/') {
      return '/home';
    }
    if (!isLoggedIn && state.fullPath != '/') {
      return '/';
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return Login();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (context, state) => ExpenseHomePage(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const UserDataForm(),
        ),
      ],
    ),
  ],
);

Future<bool> checkIfUserIsLoggedIn() async {
  if (await FirebaseAuth.instance.currentUser != null) {
    return true;
  }
  print('usera nie ma');
  return false;
}
