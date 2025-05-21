// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_wrapper.dart';
import 'constants.dart';
import 'providers/auth_provider.dart';
import 'providers/book_list_provider.dart';
import 'providers/points_provider.dart';
import 'providers/student_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BookNexusApp());
}

class BookNexusApp extends StatelessWidget {
  const BookNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookListProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: MaterialApp(
        title: 'Book Nexus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryGreen,
            brightness: Brightness.dark,
            background: AppColors.background,
          ),
          textTheme: GoogleFonts.nunitoTextTheme(
            Theme.of(context).textTheme.apply(
              bodyColor: AppColors.textWhite,
              displayColor: AppColors.textWhite,
            ),
          ),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
