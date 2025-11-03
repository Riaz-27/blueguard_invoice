import 'package:get/get.dart';
import 'package:invoice/modules/login/login_controller.dart';
import 'package:invoice/modules/register/register_controller.dart';
import 'package:invoice/modules/home/home_controller.dart';

import '../modules/login/login_view.dart';
import '../modules/order_details/order_details_controller.dart';
import '../modules/order_details/order_details_view.dart';
import '../modules/register/register_view.dart';
import '../modules/home/home_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.put(RegisterController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrderDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(OrderDetailsController());
      }),
    ),
  ];
}
