import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:thuc_hanh/controller/settings_controller.dart';
import 'package:thuc_hanh/routes/app_routes.dart';
import 'package:thuc_hanh/screens/shipping_address/my_shipping_address_screen.dart';
import '../../common/styles/app_colors.dart';
import '../../common/styles/app_text_styles.dart';
import '../../common/widgets/profile_menu_item.dart';
import '../bank_account/my_bank_account_screen.dart';
import '../notifications/my_notifications.dart';
import '../order/my_order_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final bool loggedIn = authController.currentUser != null;
        
        // Nếu chưa đăng nhập, hiển thị giao diện khách
        if (!loggedIn) {
          return _buildGuestProfile(context);
        }
        
        // Nếu đã đăng nhập, hiển thị giao diện người dùng
        return _buildUserProfile(context, authController);
      },
    );
  }

  /// --- GIAO DIỆN NGƯỜI DÙNG ĐÃ ĐĂNG NHẬP ---
  Widget _buildUserProfile(BuildContext context, AuthController authController) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, authController),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0), // Tạo hiệu ứng đè nhẹ lên header
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountSetting(context),
                    const SizedBox(height: 32),
                    _buildAppSettingLabel(),
                    const SizedBox(height: 16),
                    _buildAppSettings(),
                    const SizedBox(height: 32),
                    _buildLogoutButton(context, authController),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --- HEADER (Ảnh đại diện & Thông tin) ---
  Widget _buildHeader(BuildContext context, AuthController authController) {
    final user = authController.currentUser;
    final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'User Name';
    final String email = user?.email ?? 'user@email.com';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.blue.shade400],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: AppTextStyle.whiteTitle.copyWith(fontSize: 20)),
                const SizedBox(height: 4),
                Text(email, style: AppTextStyle.whiteSubtitle.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.updateAccount),
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  /// --- CÀI ĐẶT TÀI KHOẢN ---
  Widget _buildAccountSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cài đặt tài khoản', style: AppTextStyle.title),
        const SizedBox(height: 12),
        _buildMenuTile(Icons.location_on_rounded, 'Địa chỉ của tôi', 'Quản lý địa chỉ giao hàng', () => Get.to(() => MyShippingAddressScreen())),
        _buildMenuTile(Icons.shopping_bag_rounded, 'Giỏ hàng của tôi', 'Xem các mặt hàng đã chọn', () => Get.toNamed(AppRoutes.cartOverview)),
        _buildMenuTile(Icons.receipt_long_rounded, 'Đơn hàng của tôi', 'Theo dõi đơn hàng của bạn', () => Get.to(() => const MyOrderScreen())),
        _buildMenuTile(Icons.account_balance_wallet_rounded, 'Ví & Ngân hàng', 'Quản lý phương thức thanh toán', () => Get.to(() => MyBankAccountScreen())),
        _buildMenuTile(Icons.notifications_active_rounded, 'Thông báo', 'Cài đặt thông báo ứng dụng', () => Get.to(() => MyNotificationScreen())),
      ],
    );
  }

  /// --- CÀI ĐẶT ỨNG DỤNG ---
  Widget _buildAppSettingLabel() => Text('Cài đặt ứng dụng', style: AppTextStyle.title);

  Widget _buildAppSettings() {
    final controller = Get.find<SettingsController>();
    return Obx(() => Column(
          children: [
            _buildMenuTile(Icons.dark_mode_rounded, 'Giao diện', 'Chế độ: ${controller.themeMode.value.name.capitalizeFirst}', () => _showThemeDialog(controller)),
            _buildMenuTile(Icons.text_fields_rounded, 'Cỡ chữ', 'Hiện tại: ${controller.fontSize.value.capitalizeFirst}', () => _showFontDialog(controller)),
            _buildMenuTile(Icons.language_rounded, 'Ngôn ngữ', 'Ngôn ngữ: ${controller.locale.value.languageCode.toUpperCase()}', () => _showLanguageDialog(controller)),
          ],
        ));
  }

  /// --- NÚT ĐĂNG XUẤT ---
  Widget _buildLogoutButton(BuildContext context, AuthController authController) {
    return InkWell(
      onTap: () => _confirmLogout(context, authController),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: const Center(
          child: Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  /// --- GIAO DIỆN KHÁCH (GUEST) ---
  Widget _buildGuestProfile(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
            decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
            child: Column(
              children: [
                CircleAvatar(radius: 45, backgroundColor: Colors.white.withOpacity(0.2), child: const Icon(Icons.person_outline, size: 50, color: Colors.white)),
                const SizedBox(height: 20),
                const Text('Chào mừng khách!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Đăng nhập để trải nghiệm đầy đủ tính năng', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue.shade700, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), shape: BorderRadius.circular(12)),
                  child: const Text('Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --- HELPER: MENU ITEM ---
  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ProfileMenuItem(icon: icon, title: title, subtitle: subtitle, onTap: onTap);
  }

  /// --- LOGIC ĐĂNG XUẤT ---
  void _confirmLogout(BuildContext context, AuthController authController) {
    Get.defaultDialog(
      title: "Đăng xuất",
      middleText: "Bạn có chắc chắn muốn thoát khỏi tài khoản không?",
      textConfirm: "Đăng xuất",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await authController.logout();
        Get.offAllNamed(AppRoutes.home);
      },
    );
  }

  /// --- DIALOGS (Theme, Font, Language) ---
  void _showThemeDialog(SettingsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Chọn Giao diện", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(leading: const Icon(Icons.light_mode), title: const Text("Sáng"), onTap: () { controller.changeTheme('light'); Get.back(); }),
            ListTile(leading: const Icon(Icons.dark_mode), title: const Text("Tối"), onTap: () { controller.changeTheme('dark'); Get.back(); }),
            ListTile(leading: const Icon(Icons.settings_suggest), title: const Text("Theo hệ thống"), onTap: () { controller.changeTheme('system'); Get.back(); }),
          ],
        ),
      ),
    );
  }

  void _showFontDialog(SettingsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Cỡ chữ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(title: const Text("Nhỏ"), onTap: () { controller.changeFontSize('small'); Get.back(); }),
            ListTile(title: const Text("Vừa"), onTap: () { controller.changeFontSize('medium'); Get.back(); }),
            ListTile(title: const Text("Lớn"), onTap: () { controller.changeFontSize('large'); Get.back(); }),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(SettingsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ngôn ngữ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(leading: const Text("🇻🇳"), title: const Text("Tiếng Việt"), onTap: () { controller.changeLanguage('vi'); Get.back(); }),
            ListTile(leading: const Text("🇺🇸"), title: const Text("English"), onTap: () { controller.changeLanguage('en'); Get.back(); }),
          ],
        ),
      ),
    );
  }
}