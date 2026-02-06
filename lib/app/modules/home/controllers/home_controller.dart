import 'package:get/get.dart';
import 'package:day_task/app/services/supabase_service.dart';
import 'package:day_task/app/routes/app_pages.dart';
import 'package:day_task/app/modules/dashboard/controllers/dashboard_controller.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  /// Navigate to dashboard tab and refresh data
  void goToDashboardAndRefresh() {
    selectedIndex.value = 0;
    // Refresh dashboard if it exists
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshTasks();
    }
  }

  Future<void> signOut() async {
    await Get.find<SupabaseService>().signOut();
    Get.offAllNamed(Routes.SIGNIN);
  }
}
