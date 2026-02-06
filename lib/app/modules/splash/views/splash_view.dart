import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryYellow = Color(0xFFFED36A);
    const Color kDarkBackground = Color(0xFF212832);

    return Obx(
      () => Scaffold(
        backgroundColor: kDarkBackground,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: kPrimaryYellow,
                              size: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DayTask',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.2, end: 0),

                    const Spacer(),
                    Center(
                          child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: SvgPicture.asset(
                              'assets/images/splash_ill.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.8, 0.8)),

                    const Spacer(),

                    RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 50,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(text: 'Manage\nyour\nTask with\n'),
                              TextSpan(
                                text: 'DayTask',
                                style: TextStyle(color: kPrimaryYellow),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 40),

                    SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: controller.isButtonEnabled
                                ? controller.onLetsStartPressed
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryYellow,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: kPrimaryYellow
                                  .withOpacity(0.5),
                              disabledForegroundColor: Colors.black.withOpacity(
                                0.5,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Let's Start",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 600.ms)
                        .slideY(begin: 0.3, end: 0)
                        .shimmer(delay: 1200.ms, duration: 1500.ms),
                  ],
                ),
              ),
            ),

            if (controller.isLoading)
              Container(
                color: kDarkBackground.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryYellow),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
