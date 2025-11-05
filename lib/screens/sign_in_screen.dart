import 'package:flutter/material.dart';
import '../l10n/localization.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../lumi/lumi_brain.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  String? _error;

  Future<void> _wrap(Future<void> Function() f) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await f();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001923), Color(0xFF053040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 12,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        l.appName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pass,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: _busy
                                  ? null
                                  : () => _wrap(() async {
                                        final email = _email.text.trim();
                                        if (_isSignUp) {
                                          await AuthService.instance.signUpWithEmail(email, _pass.text.trim());
                                        } else {
                                          await AuthService.instance.signInWithEmail(email, _pass.text.trim());
                                        }
                                        final name = ProfileService.deriveNameFromEmail(email);
                                        await ProfileService.setName(name);
                                        LumiBrain.I.setName(name);
                                        LumiBrain.I.onLoginSuccess();
                                      }),
                              child: Text(_isSignUp ? 'Sign up' : 'Sign in'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _wrap(
                                    () => AuthService.instance.resetPassword(
                                      _email.text.trim(),
                                    ),
                                  ),
                            child: const Text('Forgot password?'),
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => setState(() => _isSignUp = !_isSignUp),
                            child: Text(
                              _isSignUp
                                  ? 'I have an account'
                                  : 'Create account',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _wrap(() async {
                                        await AuthService.instance.signInWithGoogle();
                                        LumiBrain.I.onLoginSuccess();
                                      }),
                              icon: const Icon(Icons.g_mobiledata),
                              label: const Text('Continue with Google'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => _wrap(() async {
                                  await AuthService.instance.continueAsGuest();
                                  LumiBrain.I.onLoginSuccess();
                                }),
                        child: const Text('Continue as guest'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
