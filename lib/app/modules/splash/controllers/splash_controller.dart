import 'package:get/get.dart';
import '../../../services/supabase_service.dart';
import '../../../services/storage_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  final _isButtonEnabled = false.obs;
  bool get isButtonEnabled => _isButtonEnabled.value;

  final _initializationError = Rx<String?>(null);
  String? get initializationError => _initializationError.value;

  late final StorageService _storageService;
  late final SupabaseService _supabaseService;

  bool _isFirstTime = true;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _storageService = await Get.putAsync(() => StorageService().init());

      _supabaseService = await Get.putAsync(() => SupabaseService().init());

      _isFirstTime = _storageService.isFirstTime;

      _isLoading.value = false;

      if (_isFirstTime) {
        _isButtonEnabled.value = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
        _navigateBasedOnAuth();
      }
    } catch (e) {
      _isLoading.value = false;
      _initializationError.value = 'Initialization failed: ${e.toString()}';
      _isButtonEnabled.value = true;
    }
  }

  void onLetsStartPressed() {
    if (_isFirstTime) {
      _storageService.setNotFirstTime();
    }
    _navigateBasedOnAuth();
  }

  void _navigateBasedOnAuth() {
    if (_supabaseService.isAuthenticated) {
      Get.offNamed(Routes.HOME);
    } else {
      Get.offNamed(Routes.SIGNIN);
    }
  }
}
