// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme_provider.dart';
import '../../../core/kiwo_theme.dart';
import '../services/auth_service.dart';
import '../services/auth_exception.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

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
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmCtrl,
    ])
      c.dispose();
    ThemeProvider.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Compte créé !',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: kGreen,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
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
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: kGreen.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: kGreen.withOpacity(0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: kGreen,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Créer un compte.',
                          style: TextStyle(
                            color: t.textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rejoins la plateforme Kiwo.',
                          style: TextStyle(
                            color: t.mutedColor,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOS INFORMATIONS',
                              style: TextStyle(
                                color: t.mutedColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _field(
                              label: 'NOM',
                              ctrl: _lastNameCtrl,
                              hint: 'Ton nom',
                              validator: (v) => v!.isEmpty ? 'Requis' : null,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              label: 'PRÉNOM',
                              ctrl: _firstNameCtrl,
                              hint: 'Ton prénom',
                              validator: (v) => v!.isEmpty ? 'Requis' : null,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              label: 'EMAIL',
                              ctrl: _emailCtrl,
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
                              ctrl: _passwordCtrl,
                              hint: '••••••••',
                              obscure: _obscurePass,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePass = !_obscurePass,
                                ),
                                child: Icon(
                                  _obscurePass
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
                            const SizedBox(height: 16),
                            _field(
                              label: 'CONFIRMER LE MOT DE PASSE',
                              ctrl: _confirmCtrl,
                              hint: '••••••••',
                              obscure: _obscureConfirm,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                child: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: t.mutedColor,
                                  size: 20,
                                ),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Requis';
                                if (v != _passwordCtrl.text)
                                  return 'Ne correspond pas';
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            GestureDetector(
                              onTap: _isLoading ? null : _register,
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
                                              'CRÉER MON COMPTE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 2,
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
                            const SizedBox(height: 18),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: t.mutedColor,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Déjà un compte ? '),
                                      TextSpan(
                                        text: 'Se connecter →',
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
