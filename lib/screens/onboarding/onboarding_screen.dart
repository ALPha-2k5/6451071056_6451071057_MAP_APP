import 'package:flutter/material.dart';
import '../../controller/onboarding_controller.dart';
import '../../common/widgets/progress_dots.dart';
import '../../common/widgets/primary_button.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingController controller;
  @override
  void initState() {
    super.initState();
    controller = OnboardingController();
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// SKIP BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToHome,
                child: const Text('Bỏ qua'),
              ),
            ),

            /// PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    controller.onPageChanged(index);
                  });
                },
                itemBuilder: (context, index) {
                  final page = controller.onboardingPages[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            page.imagePath,
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// DOT INDICATOR
            ProgressDots(
              currentIndex: controller.currentPage,
              total: controller.onboardingPages.length,
            ),
            const SizedBox(height: 24),

            /// NEXT / GET STARTED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: controller.isLastPage()
                  ? PrimaryButton(title: 'Bắt đầu', onPressed: _goToHome)
                  : PrimaryButton(
                      title: 'Tiếp theo',
                      onPressed: () {
                        controller.pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
