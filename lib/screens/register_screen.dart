import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

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
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) _showSuccess('Compte créé avec succès !');
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      if (mounted) _showError(e.message, field: e.field);
    } catch (e) {
      if (mounted) _showError('Une erreur est survenue. Réessaie.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg, {String? field}) {
    IconData icon = Icons.error_outline_rounded;
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

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: kCream, size: 18),
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
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
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
                // ── Header vert ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  color: kGreen,
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Retour + Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: kCream.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: kCream,
                                size: 20,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: kYellow,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(
                                  Icons.egg_alt_rounded,
                                  color: kDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'KIWO',
                                style: TextStyle(
                                  color: kCream,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Créer un Compte.',
                        style: TextStyle(
                          color: kCream,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rejoins la plateforme Kiwo.',
                        style: TextStyle(
                          color: kCream.withOpacity(0.65),
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bande déco ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(child: Container(height: 6, color: kYellow)),
                    Expanded(child: Container(height: 6, color: kOrange)),
                    Expanded(child: Container(height: 6, color: kPink)),
                  ],
                ),

                // ── Contenu scrollable ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chips features

                        // Formulaire
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VOS INFORMATIONS',
                                style: TextStyle(
                                  color: kMuted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.5,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _field(
                                label: 'NOM',
                                controller: _lastNameController,
                                hint: 'Ton nom',
                                validator: (v) => v!.isEmpty ? 'Requis' : null,
                              ),
                              const SizedBox(height: 16),

                              _field(
                                label: 'PRÉNOM',
                                controller: _firstNameController,
                                hint: 'Ton prénom',
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
                                obscure: _obscurePass,
                                suffix: GestureDetector(
                                  onTap: () => setState(
                                    () => _obscurePass = !_obscurePass,
                                  ),
                                  child: Icon(
                                    _obscurePass
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
                              const SizedBox(height: 16),

                              _field(
                                label: 'CONFIRMER LE MOT DE PASSE',
                                controller: _confirmController,
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
                                    color: kMuted,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v!.isEmpty) return 'Requis';
                                  if (v != _passwordController.text)
                                    return 'Ne correspond pas';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),

                              // ── Bouton ──────────────────────────────
                              GestureDetector(
                                onTap: _isLoading ? null : _register,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: kOrange,
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
                                                'CRÉER MON COMPTE',
                                                style: TextStyle(
                                                  color: kCream,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 2,
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
                              const SizedBox(height: 18),

                              // ── Lien connexion ───────────────────────
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: kMuted,
                                      ),
                                      children: [
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
                      ],
                    ),
                  ),
                ),

                // ── Footer bandes ────────────────────────────────────
                Row(
                  children: [
                    Expanded(child: Container(height: 6, color: kGreen)),
                    Expanded(child: Container(height: 6, color: kYellow)),
                    Expanded(child: Container(height: 6, color: kOrange)),
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

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
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
              borderSide: const BorderSide(color: kGreen, width: 2),
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
