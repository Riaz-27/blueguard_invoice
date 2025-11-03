import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final token = await TokenStorage.getToken();

  final initialRoute = token != null && token.isNotEmpty
      ? AppRoutes.home
      : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        title: "Auth Demo",
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
