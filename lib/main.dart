import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(const MyApp());
}

class AppColors {
  static const Color primaryYellow = Color(0xFFFED36A);
  static const Color darkBackground = Color(0xFF212832);
  static const Color darkSurface = Color(0xFF263238);
  static const Color lightText = Colors.white;
  static const Color darkText = Color(0xFF191D21);
  static const Color greyText = Color(0xFF8CAAB9);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Day Task",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppColors.primaryYellow,

        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(
              bodyColor: AppColors.darkText,
              displayColor: AppColors.darkText,
            ),

        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryYellow,
          secondary: AppColors.darkBackground,
          surface: Colors.white,
          onPrimary: AppColors.darkText,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryYellow,
            foregroundColor: AppColors.darkText,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.primaryYellow,

        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(
              bodyColor: AppColors.lightText,
              displayColor: AppColors.lightText,
            ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryYellow,
          surface: AppColors.darkSurface,
          onPrimary: AppColors.darkText,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          hintStyle: const TextStyle(color: AppColors.greyText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          suffixIconColor: AppColors.greyText,
          prefixIconColor: AppColors.primaryYellow,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryYellow,
            foregroundColor: AppColors.darkText,
            minimumSize: const Size(double.infinity, 56),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),

      themeMode: ThemeMode.system,
    );
  }
}
