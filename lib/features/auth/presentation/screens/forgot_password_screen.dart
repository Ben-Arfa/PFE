// lib/features/auth/presentation/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwo/app/di/service_locator.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';
import 'package:kiwo/shared/presentation/theme/kiwo_theme.dart';
import '../../domain/exceptions/auth_exception.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _authUseCases = ServiceLocator.instance.authUseCases;
  bool _isLoading = false;
  bool _emailSent = false;

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
    _emailCtrl.dispose();
    ThemeProvider.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authUseCases.sendPasswordReset(email: _emailCtrl.text.trim());
      if (mounted) setState(() => _emailSent = true);
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
                          color: kGreen.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
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
                          'Mot de passe oublié ?',
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
                          "On t'envoie un lien de réinitialisation.",
                          style: TextStyle(color: t.mutedColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                      child: _emailSent ? _buildSuccess(t) : _buildForm(t),
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

  Widget _buildForm(ThemeProvider t) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RÉINITIALISATION',
            style: TextStyle(
              color: t.mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'EMAIL',
            style: TextStyle(
              color: t.mutedColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: t.textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requis';
              if (!v.contains('@')) return 'Email invalide';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'ton@email.com',
              hintStyle: TextStyle(
                color: t.mutedColor.withValues(alpha: 0.5),
                fontSize: 14,
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
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _isLoading ? null : _sendReset,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ENVOYER LE LIEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.send_rounded,
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
              onTap: () => Navigator.pop(context),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: t.mutedColor),
                  children: const [
                    TextSpan(text: "Tu t'en souviens ? "),
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
    );
  }

  Widget _buildSuccess(ThemeProvider t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: kGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'EMAIL ENVOYÉ !',
          style: TextStyle(
            color: t.mutedColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Vérifie ta boîte mail.',
          style: TextStyle(
            color: t.textColor,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Un lien de réinitialisation a été envoyé. Pense à vérifier tes spams.",
          style: TextStyle(color: t.mutedColor, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: kGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'RETOUR À LA CONNEXION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _emailSent = false),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: t.mutedColor),
                children: const [
                  TextSpan(text: 'Mauvais email ? '),
                  TextSpan(
                    text: 'Réessayer →',
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
    );
  }
}
