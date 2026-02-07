import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/signin_controller.dart';

class SigninView extends GetView<SigninController> {
  const SigninView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not already present
    final controller = Get.put(SigninController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: SvgPicture.asset('assets/images/logo.svg', height: 80),
              ),
              const SizedBox(height: 40),

              Text(
                "Welcome Back!",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Email Address",
                style: TextStyle(color: Color(0xFF8CAAB9)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: "email@address.com",
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Password",
                style: TextStyle(color: Color(0xFF8CAAB9)),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: "••••••••",
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF8CAAB9),
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.resetPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFFFED36A)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.login,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Log In"),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFF8CAAB9))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(color: Color(0xFF8CAAB9)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF8CAAB9))),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Get.isDarkMode
                          ? Get.theme.primaryColorLight
                          : Get.theme.primaryColorDark,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    foregroundColor: Get.isDarkMode
                        ? Get.theme.primaryColorLight
                        : Get.theme.primaryColorDark,
                  ),
                  onPressed: controller.googleLogin,
                  icon: Icon(
                    Icons.g_mobiledata,
                    size: 30,
                    color: Get.theme.primaryColorDark,
                  ), // Replace with Google Logo asset if available
                  label: const Text(
                    "Google",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF8CAAB9)),
                    ),
                    GestureDetector(
                      onTap: controller.goToSignup,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFFFED36A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
