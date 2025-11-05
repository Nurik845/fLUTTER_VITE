import 'dart:async';
import 'package:flutter/foundation.dart' as f;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart' as fcore;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _initialized = false;
  bool _demoMode = false;
  final _guestController = StreamController<String?>.broadcast();
  String? _guestId;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (f.kIsWeb) {
        if (fcore.Firebase.apps.isEmpty) {
          const apiKey = String.fromEnvironment('FB_API_KEY');
          const appId = String.fromEnvironment('FB_APP_ID');
          const projectId = String.fromEnvironment('FB_PROJECT_ID');
          const messagingSenderId = String.fromEnvironment(
            'FB_MESSAGING_SENDER_ID',
          );
          const authDomain = String.fromEnvironment('FB_AUTH_DOMAIN');
          const storageBucket = String.fromEnvironment('FB_STORAGE_BUCKET');
          if (apiKey.isNotEmpty &&
              appId.isNotEmpty &&
              projectId.isNotEmpty &&
              messagingSenderId.isNotEmpty) {
            await fcore.Firebase.initializeApp(
              options: fcore.FirebaseOptions(
                apiKey: apiKey,
                appId: appId,
                projectId: projectId,
                messagingSenderId: messagingSenderId,
                authDomain: authDomain.isEmpty ? null : authDomain,
                storageBucket: storageBucket.isEmpty ? null : storageBucket,
              ),
            );
          } else {
            // Try default (in case web config injected via index.html by hosting)
            await fcore.Firebase.initializeApp();
          }
        }
      } else {
        await fcore.Firebase.initializeApp();
      }
      _initialized = true;
    } catch (e) {
      // Если Firebase не сконфигурирован (web или mobile) — не падаем,
      // запускаем приложение в демо‑режиме и логируем причину.
      // Чтобы включить реальный вход на Web — передай dart-define (см. README/инструкции).
      // На Mobile — проверь google-services.json/GoogleService-Info.plist.
      // ignore: avoid_print
      print('[Auth] Firebase init failed → DEMO mode. Reason: ${e.toString()}');
      _demoMode = true;
      _initialized = true;
    }
  }

  bool get demoMode => _demoMode;

  Stream<String?> get userIdStream => _demoMode
      ? _guestController.stream
      : fb.FirebaseAuth.instance.authStateChanges().map((u) => u?.uid);

  String? get currentUserId =>
      _demoMode ? _guestId : fb.FirebaseAuth.instance.currentUser?.uid;

  Future<void> continueAsGuest({String? label}) async {
    _guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    _guestController.add(_guestId);
  }

  Future<void> signOut() async {
    if (_demoMode) {
      _guestId = null;
      _guestController.add(null);
    } else {
      await fb.FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (_demoMode) {
      await continueAsGuest(label: email);
      return;
    }
    await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    if (_demoMode) {
      await continueAsGuest(label: email);
      return;
    }
    final cred = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final name = email.split('@').first;
    try {
      await cred.user?.updateDisplayName(name);
    } catch (_) {}
  }

  Future<void> resetPassword(String email) async {
    if (_demoMode) return; // no-op in demo
    await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signInWithGoogle() async {
    if (_demoMode) {
      await continueAsGuest(label: 'google');
      return;
    }
    if (f.kIsWeb) {
      final provider = fb.GoogleAuthProvider();
      final result = await fb.FirebaseAuth.instance.signInWithPopup(provider);
      if ((result.user?.displayName ?? '').isEmpty) {
        try {
          await result.user?.updateDisplayName(
            result.user?.email?.split('@').first ?? 'Friend',
          );
        } catch (_) {}
      }
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // cancelled
      final auth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final result = await fb.FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if ((result.user?.displayName ?? '').isEmpty) {
        try {
          await result.user?.updateDisplayName(
            result.user?.email?.split('@').first ?? 'Friend',
          );
        } catch (_) {}
      }
    }
  }
}
