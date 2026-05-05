import 'package:thuc_hanh/screens/auth/forget_password_screen.dart';
import 'package:thuc_hanh/screens/auth/login_screen.dart';
import 'package:thuc_hanh/screens/auth/register_screen.dart';
import 'package:thuc_hanh/screens/auth/register_success_screen.dart';
import 'package:thuc_hanh/screens/auth/reset_email_sent_screen.dart';
import 'package:thuc_hanh/screens/auth/verify_email_screen.dart';
import
'package:thuc_hanh/screens/bank_account/my_bank_account_screen.dart';
import 'package:thuc_hanh/screens/cart/cart_overview_screen.dart';
import 'package:thuc_hanh/screens/onboarding/onboarding_screen.dart';
import 'package:thuc_hanh/screens/order/my_order_screen.dart';
import 'package:thuc_hanh/screens/order/order_overview_screen.dart';
import 'package:thuc_hanh/screens/profile/change_dateofbirth_screen.dart';
import 'package:thuc_hanh/screens/profile/change_email_screen.dart';
import 'package:thuc_hanh/screens/profile/change_gender_screen.dart';
import 'package:thuc_hanh/screens/profile/change_name_screen.dart';
import 'package:thuc_hanh/screens/profile/change_password_screen.dart';
import 'package:thuc_hanh/screens/profile/change_phonenumber_screen.dart';
import 'package:thuc_hanh/screens/profile/change_username_screen.dart';
import 'package:thuc_hanh/screens/profile/update_account_screen.dart';
import
'package:thuc_hanh/screens/shipping_address/my_shipping_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:thuc_hanh/screens/shipping_address/my_shipping_address_screen.dart';
import 'package:thuc_hanh/screens/splash/splash_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/splash/splash_screen.dart';
class AppRoutes {
static const String splash = '/';
static const String onboarding = '/onboarding';
static const String login = '/login';
static const String forgetPassword = '/forget-password';
static const String resetEmailSent = '/reset-email-sent';
static const String register = '/register';
static const String verifyEmail = '/verify-email';
static const String registerSuccess = '/register-success';
static const String home = '/home';
static const String profile = '/profile';
static const String publisher = '/publisher';
static const String updateAccount = '/update-account';
static const String changeName = '/change-name';
static const String changeUsername = '/change-username';
static const String changePassword = '/change-password';
static const String changeEmail = '/change-email';
static const String changePhoneNumber = '/change-phonenumber';
static const String changeGender = '/change-gender';
static const String changeDateofBirth = '/change-datebirth';
static const String cartOverview = '/cart-overview';
static const String orderOverview = '/order-overview';
static const String myOrderview = '/my-order';
static const String myShippingAddressview = '/my_shipping_address';
static const String myBankAccountview = '/my_bank_account';
static Map<String, WidgetBuilder> routes = {
splash: (context) => const SplashScreen(),
onboarding: (context) => const OnboardingScreen(),
register: (context) => const RegisterScreen(),
login: (context) => const LoginScreen(),
forgetPassword: (context) => ForgetPasswordScreen(),
home: (context) => const MainNavigationScreen(),
updateAccount: (context) => const UpdateAccountScreen(),
changeName: (context) => const ChangeNameScreen(),
changeUsername: (context) => const ChangeUsernameScreen(),
changePassword: (context) => const ChangePasswordScreen(),
changeEmail: (context) => const ChangeEmailScreen(),
changePhoneNumber: (context) => const ChangePhoneNumberScreen(),
changeGender: (context) => const ChangeGenderScreen(),
changeDateofBirth: (context) => const ChangeDateOfBirthScreen(),
cartOverview: (context) => const CartOverviewScreen(),
orderOverview: (context) => const OrderReviewScreen(),
myOrderview: (context) => const MyOrderScreen(),
myShippingAddressview: (context) => MyShippingAddressScreen(),
myBankAccountview: (context) => MyBankAccountScreen(),
verifyEmail: (context) {
final String email = ModalRoute.of(context)!.settings.arguments as
String;
return VerifyEmailScreen(email: email);
},
registerSuccess: (context) => const RegisterSuccessScreen(),
resetEmailSent: (context) {
final email = ModalRoute.of(context)!.settings.arguments as String;
return ResetEmailSentScreen(email: email);
},
};
}