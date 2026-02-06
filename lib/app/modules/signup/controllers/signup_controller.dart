import 'package:day_task/app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../signin/controllers/signin_controller.dart';

class SignupController extends GetxController {
  final SupabaseService supabaseService =
      Get.find<SupabaseService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isTermsAccepted = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleTerms() => isTermsAccepted.toggle();

  Future<void> signup() async {
    if (!isTermsAccepted.value) {
      Get.snackbar("Error", "Please accept the Terms & Conditions");
      return;
    }

    try {
      isLoading.value = true;

      final response = await supabaseService.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {
          'full_name': nameController.text.trim(),
        },
        emailRedirectTo: "https://x.devh.in/s/daytaskauthsuccess",
      );

      if (response.user != null) {
        if (response.session == null) {
          Get.snackbar(
            "Success",
            "Please check your email to confirm your account.",
          );
          Get.back(); 
        } else {
          Get.offAllNamed('/home');
        }
      }
    } on AuthException catch (e) {
      Get.snackbar("Signup Failed", e.message);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void googleLogin() {
    Get.find<SigninController>().googleLogin();
  }
}
