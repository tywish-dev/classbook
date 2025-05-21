import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_list_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/teacher_home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize book list provider with the current user ID
    final authProvider = Provider.of<AuthProvider>(context);
    final bookListProvider = Provider.of<BookListProvider>(
      context,
      listen: false,
    );
    bookListProvider.initialize(authProvider.currentUser?.id);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading indicator while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If logged in, show HomeScreen, otherwise show LoginScreen
    if (authProvider.isLoggedIn) {
      final user = authProvider.currentUser;
      if (user != null && user.role == 'teacher') {
        return const TeacherHomeScreen();
      } else {
        return const HomeScreen();
      }
    } else {
      return const LoginScreen();
    }
  }
}
