import 'package:flutter/material.dart';
import '../data/models/onboarding_model.dart';

class OnboardingController extends ChangeNotifier {
  int currentPage = 0;
  final PageController pageController = PageController();
  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'Mua sắm dễ dàng',
      description: 'Tìm kiếm và mua sản phẩm chỉ với vài thao tác.',
      imagePath: 'assets/images/on_boarding_images/sammy-line-delivery.gif',
    ),
    OnboardingModel(
      title: 'Thanh toán an toàn',
      description: 'Hỗ trợ nhiều phương thức thanh toán bảo mật.',
      imagePath: 'assets/images/on_boarding_images/sammy-line-searching.gif',
    ),
    OnboardingModel(
      title: 'Giao hàng nhanh chóng',
      description: 'Đơn hàng được giao đến tận tay bạn.',
      imagePath: 'assets/images/on_boarding_images/sammy-line-shopping.gif',
    ),
  ];
  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  bool isLastPage() {
    return currentPage == onboardingPages.length - 1;
  }
}
