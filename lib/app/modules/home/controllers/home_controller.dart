import 'package:get/get.dart';
import 'package:day_task/app/services/supabase_service.dart';
import 'package:day_task/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  Future<void> signOut() async {
    await Get.find<SupabaseService>().signOut();
    Get.offAllNamed(Routes.SIGNIN);
  }
}
