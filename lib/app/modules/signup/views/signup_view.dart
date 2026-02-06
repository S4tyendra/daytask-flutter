import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

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
                "Create your account",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Full Name",
                style: TextStyle(color: Color(0xFF8CAAB9)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: "Full Name",
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Email Address",
                style: TextStyle(color: Color(0xFF8CAAB9)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
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

              const SizedBox(height: 20),

              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: controller.isTermsAccepted.value,
                      onChanged: (val) => controller.toggleTerms(),
                      activeColor: const Color(0xFFFED36A),
                      checkColor: Colors.black,
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text(
                            "I have read & agreed to DayTask ",
                            style: TextStyle(
                              color: Color(0xFF8CAAB9),
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {}, // Link to Privacy Policy
                            child: const Text(
                              "Privacy Policy, ",
                              style: TextStyle(
                                color: Color(0xFFFED36A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {}, // Link to Terms
                            child: const Text(
                              "Terms & Condition",
                              style: TextStyle(
                                color: Color(0xFFFED36A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        : controller.signup,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Sign Up"),
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
                    side: const BorderSide(color: Colors.white),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.googleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 30),
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
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF8CAAB9)),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        "Log In",
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
