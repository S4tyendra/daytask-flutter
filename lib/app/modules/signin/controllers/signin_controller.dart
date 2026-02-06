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

  // Google OAuth Web Client ID from Google Cloud Console
  // This is used for server-side verification
  static const String _webClientId =
      '758011317685-7kl34vmlpdfa6kpq2nh8fk209f571n7n.apps.googleusercontent.com';

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      isLoading.value = true;
      final response = await supabaseService.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
        Get.offAllNamed('/home');
      }
    } on AuthException catch (e) {
      Get.snackbar("Login Failed", e.message);
      log("Login Failed: ${e.message}");
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleLogin() async {
    try {
      isLoading.value = true;

      // Desktop platforms use browser OAuth flow
      final bool isDesktop =
          !kIsWeb &&
          (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

      if (isDesktop || kIsWeb) {
        // For desktop/web: use browser OAuth flow
        await supabaseService.client.auth.signInWithOAuth(
          OAuthProvider.google,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      } else {
        // For mobile (Android/iOS): use native Google Sign-In
        await _nativeGoogleSignIn();
      }
    } catch (e) {
      log("Google Login Error: $e");
      Get.snackbar("Google Login Error", e.toString());
      log("Google Login Error: ${e.toString()}");
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

  void goToSignup() {
    Get.to(() => const SignupView());
  }
}
