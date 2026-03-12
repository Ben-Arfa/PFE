import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/auth_exception.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _emailSent = false;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // Palette Heyday — identique à LoginScreen
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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordReset(email: _emailController.text.trim());
      if (mounted) setState(() => _emailSent = true);
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
                      // Logo + bouton retour
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: kCream.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: kCream,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                        'Mot de passe\noublié ?',
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
                        'On t\'envoie un lien de réinitialisation.',
                        style: TextStyle(
                          color: kCream.withOpacity(0.7),
                          fontSize: 13,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bande jaune déco ─────────────────────────────────
                Container(height: 6, color: kYellow),

                // ── Contenu ───────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    child: _emailSent ? _buildSuccess() : _buildForm(),
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

  // ── Formulaire ────────────────────────────────────────────────────
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RÉINITIALISATION',
            style: TextStyle(
              color: kMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 20),

          // Champ email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EMAIL',
                style: TextStyle(
                  color: kMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 7),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: kDark,
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
                    color: kMuted.withOpacity(0.5),
                    fontSize: 14,
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
          ),

          const SizedBox(height: 32),

          // ── Bouton ENVOYER ───────────────────────────────────────
          GestureDetector(
            onTap: _isLoading ? null : _sendReset,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ENVOYER LE LIEN',
                            style: TextStyle(
                              color: kCream,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.send_rounded, color: kYellow, size: 20),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Lien retour connexion ────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: kMuted),
                  children: [
                    TextSpan(text: 'Tu t\'en souviens ? '),
                    TextSpan(
                      text: 'Se connecter →',
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
    );
  }

  // ── État succès ───────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icône succès
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: kGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: kCream,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'EMAIL ENVOYÉ !',
          style: TextStyle(
            color: kMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          'Vérifie ta boîte mail.',
          style: TextStyle(
            color: kDark,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          'Un lien de réinitialisation a été envoyé à l\'adresse indiquée. '
          'Pense à vérifier tes spams si tu ne le trouves pas.',
          style: TextStyle(color: kMuted, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 32),

        // ── Bouton retour connexion ──────────────────────────────
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: kDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'RETOUR À LA CONNEXION',
                    style: TextStyle(
                      color: kCream,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, color: kYellow, size: 20),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Renvoyer le lien ─────────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _emailSent = false),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: kMuted),
                children: [
                  TextSpan(text: 'Mauvais email ? '),
                  TextSpan(
                    text: 'Réessayer →',
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
    );
  }
}
