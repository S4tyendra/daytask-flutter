import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../../signup/views/signup_view.dart';

class SigninController extends GetxController {
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  static const String _webClientId =
      '758011317685-7kl34vmlpdfa6kpq2nh8fk209f571n7n.apps.googleusercontent.com';

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
    // Validation
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
        "Please enter your password",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await supabaseService.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
        // Check if email is verified
        if (response.user!.emailConfirmedAt == null) {
          Get.snackbar(
            "Email Not Verified",
            "Please verify your email before signing in. Check your inbox for the verification link.",
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
          // Sign out the user
          await supabaseService.client.auth.signOut();
          return;
        }

        Get.snackbar(
          "Success",
          "Welcome back!",
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/home');
      }
    } on AuthException catch (e) {
      String errorMessage = "Login failed";

      if (e.message.contains('Invalid login credentials')) {
        errorMessage = "Invalid email or password. Please try again.";
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = "Please verify your email before signing in.";
      } else if (e.message.contains('User not found')) {
        errorMessage = "No account found with this email.";
      } else {
        errorMessage = e.message;
      }

      Get.snackbar(
        "Login Failed",
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      log("Login Failed: ${e.message}");
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Login Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleLogin() async {
    try {
      isLoading.value = true;

      final bool isDesktop =
          !kIsWeb &&
          (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

      if (isDesktop || kIsWeb) {
        await supabaseService.client.auth.signInWithOAuth(
          OAuthProvider.google,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      } else {
        await _nativeGoogleSignIn();
      }

      Get.snackbar(
        "Success",
        "Signed in with Google successfully!",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      log("Google Login Error: $e");
      Get.snackbar(
        "Google Login Error",
        "Failed to sign in with Google. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _nativeGoogleSignIn() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw AuthException('Google Sign-In was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw AuthException('No ID Token found.');
    }

    log("Google Sign-In successful, signing into Supabase...");

    await supabaseService.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    log("Supabase sign-in complete");
  }

  Future<void> resetPassword() async {
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

    try {
      isLoading.value = true;
      await supabaseService.client.auth.resetPasswordForEmail(
        emailController.text.trim(),
      );

      Get.snackbar(
        "Success",
        "Password reset link sent to your email",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send password reset email",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Reset Password Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignup() {
    Get.to(() => const SignupView());
  }
}
