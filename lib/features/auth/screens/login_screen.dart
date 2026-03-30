// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme_provider.dart';
import '../../../core/kiwo_theme.dart';
import '../services/auth_service.dart';
import '../services/auth_exception.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const kGreen = Color(0xFF4B7B28);
  static const kBeetRed = Color(0xFFAB1717);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
    ThemeProvider.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailController.dispose();
    _passController.dispose();
    ThemeProvider.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Une erreur est survenue. Réessaie.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: kBeetRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;
    return KiwoThemeWrapper(
      child: Scaffold(
        backgroundColor: t.bgColor,
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: t.headerColor,
                      border: Border(
                        bottom: BorderSide(
                          color: kGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: kGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'KIWO',
                              style: TextStyle(
                                color: t.textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bienvenue sur Kiwo.',
                          style: TextStyle(
                            color: t.textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "L'élevage modernisé pour tous.",
                          style: TextStyle(
                            color: t.mutedColor,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Formulaire
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IDENTIFIEZ-VOUS',
                              style: TextStyle(
                                color: t.mutedColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _field(
                              label: 'EMAIL',
                              ctrl: _emailController,
                              hint: 'ton@email.com',
                              keyboard: TextInputType.emailAddress,
                              validator: (v) {
                                if (v!.isEmpty) return 'Requis';
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _field(
                              label: 'MOT DE PASSE',
                              ctrl: _passController,
                              hint: '••••••••',
                              obscure: _obscurePassword,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: t.mutedColor,
                                  size: 20,
                                ),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Requis';
                                if (v.length < 6) return 'Min. 6 caractères';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    color: kGreen,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _isLoading ? null : _signIn,
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: kGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'SE CONNECTER',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 2.5,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: t.mutedColor,
                                    ),
                                    children: const [
                                      TextSpan(text: "Pas de compte ? "),
                                      TextSpan(
                                        text: "S'inscrire →",
                                        style: TextStyle(
                                          color: kGreen,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final t = ThemeProvider.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: t.mutedColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboard,
          validator: validator,
          style: TextStyle(
            color: t.textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: t.mutedColor.withOpacity(0.5),
              fontSize: 14,
            ),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: t.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.borderColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: kGreen, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: kBeetRed, width: 1.5),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: kBeetRed, width: 2),
            ),
            errorStyle: const TextStyle(color: kBeetRed, fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
