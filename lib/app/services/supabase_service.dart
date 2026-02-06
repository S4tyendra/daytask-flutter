import 'dart:developer';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  SupabaseClient get client => Supabase.instance.client;

  final _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  final _isOnline = true.obs;
  bool get isOnline => _isOnline.value;

  Future<SupabaseService> init() async {
    try {
      await Supabase.initialize(
        url: 'https://wvdadaynwwzchwjefvoq.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2ZGFkYXlud3d6Y2h3amVmdm9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyODAwMTksImV4cCI6MjA4NTg1NjAxOX0.wuXRBcXKfN98KYm57Ii2jeSqwfVfa8hbhho8YRcwaL0',
      );

      _isInitialized.value = true;

      // Monitor auth state changes
      client.auth.onAuthStateChange.listen((data) {
        log("Auth Event: ${data.toString()}");
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        log("Auth Event: ${event.name}");

        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.initialSession) {
          if (session != null) {
            log("User logged in: ${session.user.email}");
            if (Get.currentRoute != '/home') {
              Get.offAllNamed('/home');
            }
          }
        } else if (event == AuthChangeEvent.signedOut) {
          log("User logged out");
          // Only navigate to signin if we're not already on an auth/splash page
          if (Get.currentRoute != '/signin' &&
              Get.currentRoute != '/signup' &&
              Get.currentRoute != '/splash') {
            Get.offAllNamed('/signin');
          }
        }
      });
    } catch (e) {
      log("Supabase Init Error: ${e.toString()}");
      _isOnline.value = false;
      _isInitialized.value = false;
    }

    return this;
  }

  bool get isAuthenticated {
    if (!_isInitialized.value) return false;
    try {
      return client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser {
    if (!_isInitialized.value) return null;
    try {
      return client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState>? get authStateChanges {
    if (!_isInitialized.value) return null;
    return client.auth.onAuthStateChange;
  }

  Future<bool> signOut() async {
    if (!_isInitialized.value) {
      return true;
    }
    try {
      await client.auth.signOut();
      log("Signedout");
      return true;
    } catch (e) {
      log("SignOut Error: ${e.toString()}");
      return false;
    }
  }
}
