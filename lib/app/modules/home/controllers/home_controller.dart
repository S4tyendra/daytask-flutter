import 'package:get/get.dart';
import 'package:day_task/app/services/supabase_service.dart';
import 'package:day_task/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> signOut() async {
    await Get.find<SupabaseService>().signOut();
    Get.offAllNamed(Routes.SIGNIN);
  }
}
