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
      client.auth.onAuthStateChange.listen(
        (data) {
          log("Auth Event: ${data.toString()}");
          final AuthChangeEvent event = data.event;
          final Session? session = data.session;

          log("Auth Event: ${event.name}");

          switch (event) {
            case AuthChangeEvent.signedIn:
            case AuthChangeEvent.initialSession:
              if (session != null && !_isSessionExpired(session)) {
                log("User logged in: ${session.user.email}");
                if (Get.currentRoute != '/home') {
                  Get.offAllNamed('/home');
                }
              } else if (session == null || _isSessionExpired(session)) {
                log("Session expired or null on initial check");
                _handleExpiredSession();
              }
              break;

            case AuthChangeEvent.signedOut:
              log("User logged out");
              _navigateToSignIn();
              break;

            case AuthChangeEvent.tokenRefreshed:
              log("Token refreshed successfully");
              break;

            case AuthChangeEvent.userUpdated:
              log("User updated");
              break;

            case AuthChangeEvent.passwordRecovery:
              log("Password recovery");
              break;

            case AuthChangeEvent.mfaChallengeVerified:
              log("MFA verified");
              break;

            case AuthChangeEvent.userDeleted:
              log("User deleted");
              _navigateToSignIn();
              break;
          }
        },
        onError: (error) {
          log("Auth stream error: $error");
          _handleExpiredSession();
        },
      );

      // Check session validity on init
      await _validateCurrentSession();
    } catch (e) {
      log("Supabase Init Error: ${e.toString()}");
      _isOnline.value = false;
      _isInitialized.value = false;
    }

    return this;
  }

  /// Check if session is expired
  bool _isSessionExpired(Session session) {
    if (session.expiresAt == null) return false;
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(
      session.expiresAt! * 1000,
    );
    return DateTime.now().isAfter(expiryTime);
  }

  /// Validate current session and try to refresh if needed
  Future<void> _validateCurrentSession() async {
    try {
      final session = client.auth.currentSession;

      if (session == null) {
        log("No session found");
        return;
      }

      if (_isSessionExpired(session)) {
        log("Session expired, attempting refresh...");
        try {
          final response = await client.auth.refreshSession();
          if (response.session != null) {
            log("Session refreshed successfully");
          } else {
            log("Session refresh returned null");
            _handleExpiredSession();
          }
        } catch (e) {
          log("Session refresh failed: $e");
          _handleExpiredSession();
        }
      } else {
        log(
          "Session valid, expires at: ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)}",
        );
      }
    } catch (e) {
      log("Session validation error: $e");
      _handleExpiredSession();
    }
  }

  /// Handle expired/invalid session
  void _handleExpiredSession() {
    log("Handling expired session...");
    try {
      client.auth.signOut();
    } catch (_) {}
    _navigateToSignIn();
  }

  /// Navigate to sign in page
  void _navigateToSignIn() {
    if (Get.currentRoute != '/signin' &&
        Get.currentRoute != '/signup' &&
        Get.currentRoute != '/splash') {
      Get.offAllNamed('/signin');
    }
  }

  bool get isAuthenticated {
    if (!_isInitialized.value) return false;
    try {
      final session = client.auth.currentSession;
      if (session == null) return false;
      return !_isSessionExpired(session);
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

  /// Refresh session manually (call before making API requests if needed)
  Future<bool> ensureValidSession() async {
    try {
      final session = client.auth.currentSession;
      if (session == null) {
        _handleExpiredSession();
        return false;
      }

      // If expires within 5 minutes, refresh
      if (session.expiresAt != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(
          session.expiresAt! * 1000,
        );
        final fiveMinutesFromNow = DateTime.now().add(
          const Duration(minutes: 5),
        );

        if (expiryTime.isBefore(fiveMinutesFromNow)) {
          log("Session expiring soon, refreshing...");
          final response = await client.auth.refreshSession();
          return response.session != null;
        }
      }
      return true;
    } catch (e) {
      log("ensureValidSession error: $e");
      _handleExpiredSession();
      return false;
    }
  }

  Future<bool> signOut() async {
    if (!_isInitialized.value) {
      return true;
    }
    try {
      await client.auth.signOut();
      log("Signed out");
      return true;
    } catch (e) {
      log("SignOut Error: ${e.toString()}");
      return false;
    }
  }
}
