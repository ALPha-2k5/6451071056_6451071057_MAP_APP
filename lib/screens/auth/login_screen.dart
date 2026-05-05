import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/primary_button.dart';
import '../../common/widgets/social_login_button.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../utils/preferences_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  bool isPasswordHidden = true;
  bool rememberMe = false;
  // Hiệu ứng cho các phần tử xuất hiện
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberMe() async {
    final bool savedRememberMe = await PreferencesHelper.getRememberMe();
    final String? savedEmail = await PreferencesHelper.getSavedEmail();
    setState(() {
      rememberMe = savedRememberMe;
      if (savedEmail != null) {
        emailController.text = savedEmail;
      }
    });
  }

  Future<void> _handleLogin() async {
    final bool isValid = formKey.currentState!.validate();
    if (!isValid) return;
    try {
      await authController.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      await PreferencesHelper.saveRememberMe(rememberMe, emailController.text);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('Email not verified')) {
        message = 'Vui lòng xác thực email trước khi đăng nhập';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Hiệu ứng Gradient cho nền
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Biểu tượng Logo sinh động
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.lock_person_rounded,
                            size: 80,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'Chào mừng trở lại!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Vui lòng đăng nhập để tiếp tục',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Input Email
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@gmail.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.blue.shade100),
                          ),
                        ),
                        validator: (value) =>
                            Validators.validateEmail(value ?? ''),
                      ),
                      const SizedBox(height: 20),
                      // Input Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: isPasswordHidden,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.blue.shade100),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () => setState(
                              () => isPasswordHidden = !isPasswordHidden,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            Validators.validatePassword(value ?? ''),
                      ),
                      const SizedBox(height: 12),
                      // Ghi nhớ & Quên mật khẩu
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: rememberMe,
                              activeColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (value) =>
                                  setState(() => rememberMe = value ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ghi nhớ',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.forgetPassword,
                            ),
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Nút Đăng nhập
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          title: 'Đăng nhập',
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Phân tách OR sinh động hơn
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade400,
                              thickness: 1,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Hoặc đăng nhập với',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade400,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Social Login
                      SocialLoginButton(
                        icon: Icons.facebook,
                        title: 'Facebook',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        icon: Icons.g_mobiledata,
                        title: 'Google',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 32), // Footer
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Bạn chưa có tài khoản? "),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                              child: const Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
