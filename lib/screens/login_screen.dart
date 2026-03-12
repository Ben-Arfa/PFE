import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // Palette Heyday
  static const kCream = Color(0xFFFFF8ED);
  static const kOrange = Color(0xFFFF5B05);
  static const kYellow = Color(0xFFFFF24D);
  static const kGreen = Color(0xFF4B7B28);
  static const kPink = Color(0xFFF4B8C0);
  static const kBeetRed = Color(0xFFAB1717);
  static const kDark = Color(0xFF1C1C1A);
  static const kMuted = Color(0xFF7A7060);

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
  }

  @override
  void dispose() {
    _anim.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on AuthException catch (e) {
      if (mounted) _showError(e.message, field: e.field);
    } catch (e) {
      if (mounted) _showError(_parseFirebaseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseFirebaseError(String raw) {
    if (raw.contains('user-not-found') ||
        raw.contains('invalid-email') ||
        raw.contains('invalid-credential')) {
      return 'Aucun compte trouvé pour cet email.';
    }
    if (raw.contains('wrong-password') || raw.contains('invalid-password')) {
      return 'Mot de passe incorrect.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Trop de tentatives. Réessaie dans quelques minutes.';
    }
    if (raw.contains('network-request-failed')) {
      return 'Pas de connexion réseau. Vérifie ta connexion.';
    }
    if (raw.contains('user-disabled')) {
      return 'Ce compte a été désactivé.';
    }
    return 'Une erreur est survenue. Réessaie.';
  }

  void _showError(String msg, {String? field}) {
    IconData icon = Icons.error_outline_rounded;
    if (field == 'name') icon = Icons.badge_outlined;
    if (field == 'email') icon = Icons.email_outlined;
    if (field == 'password') icon = Icons.lock_outline_rounded;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: kCream, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: kCream,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
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
    return Scaffold(
      backgroundColor: kCream,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  color: kOrange,
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: kYellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.egg_alt_rounded,
                              color: kDark,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'KIWO',
                            style: TextStyle(
                              color: kCream,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Bienvenue sur Kiwo.',
                        style: TextStyle(
                          color: kCream,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "L'élévage modernisé pour tous.",
                        style: TextStyle(
                          color: kCream.withOpacity(0.7),
                          fontSize: 13,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bande jaune déco ─────────────────────────────────
                Container(height: 6, color: kYellow),

                // ── Formulaire (scrollable) ───────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'IDENTIFIEZ-VOUS',
                            style: TextStyle(
                              color: kMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _field(
                            label: 'NOM',
                            hint: 'Ton nom',
                            controller: _lastNameController,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                          const SizedBox(height: 16),
                          _field(
                            label: 'PRÉNOM',
                            hint: 'Ton prénom',
                            controller: _firstNameController,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                          const SizedBox(height: 16),

                          _field(
                            label: 'EMAIL',
                            controller: _emailController,
                            hint: 'ton@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v!.isEmpty) return 'Requis';
                              if (!v.contains('@')) return 'Email invalide';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _field(
                            label: 'MOT DE PASSE',
                            controller: _passwordController,
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
                                color: kMuted,
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

                          // ── Lien mot de passe oublié ─────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              ),
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  color: kOrange,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Bouton SE CONNECTER ──────────────────────
                          GestureDetector(
                            onTap: _isLoading ? null : _signIn,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: kDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: kCream,
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
                                              color: kCream,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2.5,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: kYellow,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Lien inscription ─────────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 13, color: kMuted),
                                  children: [
                                    TextSpan(text: "Pas de compte ? "),
                                    TextSpan(
                                      text: "S'inscrire →",
                                      style: TextStyle(
                                        color: kOrange,
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

                // ── Footer bandes colorées ───────────────────────────
                Row(
                  children: [
                    Expanded(child: Container(height: 6, color: kOrange)),
                    Expanded(child: Container(height: 6, color: kYellow)),
                    Expanded(child: Container(height: 6, color: kGreen)),
                    Expanded(child: Container(height: 6, color: kPink)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: kDark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kMuted.withOpacity(0.5), fontSize: 14),
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
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: kDark.withOpacity(0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: kDark.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kOrange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBeetRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBeetRed, width: 2),
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
