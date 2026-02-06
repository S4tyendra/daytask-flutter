import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../../signup/views/signup_view.dart';

class SigninController extends GetxController {
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

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
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleLogin() async {
    try {
      isLoading.value = true;

      await supabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'https://x.devh.in/s/daytaskauthsuccess',
      );
    } catch (e) {
      Get.snackbar("Google Login Error", e.toString());
      isLoading.value = false;
    }
  }

  void goToSignup() {
    Get.to(() => const SignupView());
  }
}
