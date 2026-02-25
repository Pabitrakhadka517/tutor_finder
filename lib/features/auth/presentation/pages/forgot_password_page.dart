import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import 'reset_password_page.dart';

/// Step 1 of password reset: enter email to request a reset token.
///
/// On success:
/// - **Dev mode** (backend returns token): navigates straight to
///   [ResetPasswordPage] with the token auto-filled.
/// - **Production**: shows a "check your email" confirmation and a
///   button to manually proceed to [ResetPasswordPage].
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

// Backward-compat alias
typedef ForgotPasswordScreen = ForgotPasswordPage;

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.blue.shade700,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                _emailSent ? "Check Your Email" : "Forgot Password",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _emailSent
                    ? "We sent a password reset link to your email."
                    : "Enter your email address and we will send you a link to reset your password.",
                style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 30),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _emailSent
                    ? _buildEmailSentView()
                    : _buildEmailForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Email form ---

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email, color: Colors.blue.shade700),
              filled: true,
              fillColor: Colors.blue.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter your email";
              }
              if (!value.contains("@")) {
                return "Enter a valid email";
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                disabledBackgroundColor: Colors.blue.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Send Reset Link",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- "Email sent" confirmation (shown only in production) ---

  Widget _buildEmailSentView() {
    return Column(
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read, color: Colors.green.shade600, size: 56),
        ),
        const SizedBox(height: 20),

        Text(
          "Reset link sent to:",
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 20),

        // Instructions
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep("1", "Open your email inbox"),
              const SizedBox(height: 8),
              _instructionStep("2", "Click the reset link in the email"),
              const SizedBox(height: 8),
              _instructionStep("3", "Or copy the token and enter it below"),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Expiry warning
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.timer, color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Link expires in 15 minutes.",
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // CTA: go to reset password page
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _navigateToResetPage(null),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "I Have My Token",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Resend
        TextButton(
          onPressed: _isLoading ? null : _sendResetEmail,
          child: Text(
            "Didn't receive the email? Resend",
            style: TextStyle(color: Colors.blue.shade700),
          ),
        ),
      ],
    );
  }

  Widget _instructionStep(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );
  }

  // --- Actions ---

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await ref
        .read(authNotifierProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response != null) {
      // Extract token from dev response if available
      final token = response.resetToken;

      if (token != null && token.isNotEmpty) {
        // Dev mode: backend returned the token -> go straight to reset page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Reset token received. Enter your new password."),
            backgroundColor: Colors.green.shade600,
          ),
        );
        _navigateToResetPage(token);
      } else {
        // Production: show "check your email" screen
        setState(() => _emailSent = true);
      }
    } else {
      final errorMsg =
          ref.read(authNotifierProvider).errorMessage ??
          'Failed to send reset link. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToResetPage(String? token) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(token: token),
        settings: const RouteSettings(name: '/reset-password'),
      ),
    );
  }
}
