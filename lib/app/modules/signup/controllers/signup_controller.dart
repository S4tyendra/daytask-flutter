import 'dart:developer';
import 'package:day_task/app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../signin/views/signin_view.dart';

class SignupController extends GetxController {
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isTermsAccepted = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();
  void toggleTerms() => isTermsAccepted.toggle();

  Future<void> signup() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your full name",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your email address",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email address",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter a password",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        "Validation Error",
        "Password must be at least 6 characters long",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please confirm your password",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Validation Error",
        "Passwords do not match",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isTermsAccepted.value) {
      Get.snackbar(
        "Validation Error",
        "Please accept the Terms & Conditions",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await supabaseService.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {'full_name': nameController.text.trim()},
        emailRedirectTo: "daytask://auth-callback",
      );

      if (response.user != null) {
        // Show success dialog
        await Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF2C3E50),
            title: const Row(
              children: [
                Icon(Icons.email, color: Color(0xFFFFC107), size: 28),
                SizedBox(width: 12),
                Text(
                  'Verify Your Email',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A verification email has been sent to:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  emailController.text.trim(),
                  style: const TextStyle(
                    color: Color(0xFFFFC107),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please check your inbox and click the verification link to activate your account.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                const Text(
                  'After verification, you can sign in with your credentials.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.off(() => const SigninView()); // Go to signin
                },
                child: const Text(
                  'Go to Sign In',
                  style: TextStyle(color: Color(0xFFFFC107)),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    } on AuthException catch (e) {
      String errorMessage = "Signup failed";

      if (e.message.contains('already registered')) {
        errorMessage = "This email is already registered. Please sign in.";
      } else if (e.message.contains('Invalid email')) {
        errorMessage = "Please enter a valid email address.";
      } else if (e.message.contains('Password')) {
        errorMessage = "Password must be at least 6 characters long.";
      } else {
        errorMessage = e.message;
      }

      Get.snackbar(
        "Signup Failed",
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      log("Signup Failed: ${e.message}");
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Signup Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignin() {
    Get.back();
  }
}
