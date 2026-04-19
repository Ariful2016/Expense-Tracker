import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
class AppBindings extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ExpenseController>(() => ExpenseController(), fenix: true);
}
