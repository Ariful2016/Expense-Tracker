import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/bindings/app_bindings.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/models/expense_model.dart';
import 'app/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});
  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'Expense Tracker',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    initialBinding: AppBindings(),
    home: const HomeScreen(),
    defaultTransition: Transition.cupertino,
  );
}
