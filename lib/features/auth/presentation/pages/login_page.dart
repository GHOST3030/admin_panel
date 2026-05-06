import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../states/auth_state.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signIn(
        email: _emailCtrl.text.trim(), password: _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider) is AsyncLoading;

    ref.listen(authNotifierProvider, (_, next) {
      final v = next.valueOrNull;
      if (v is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(v.message),
          backgroundColor: context.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.hPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(context.isMobile ? 24 : 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Brand ───────────────────────────────
                      Center(
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: context.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: context.onPrimary,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Welcome back',
                          style: context.headlineSmall
                              .copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text('Sign in to your admin account',
                          style: context.bodyMedium
                              .copyWith(color: context.mutedText),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 32),

                      // ── Fields ──────────────────────────────
                      AuthTextField(
                        controller: _emailCtrl,
                        label: 'Email address',
                        hint: 'admin@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        obscureText: _obscure,
                        validator: Validators.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.mutedText,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Submit ──────────────────────────────
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.onPrimary))
                              : Text('Sign In',
                                  style: context.labelLarge.copyWith(
                                      color: context.onPrimary,
                                      fontWeight: FontWeight.w600)),
                        ),
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
