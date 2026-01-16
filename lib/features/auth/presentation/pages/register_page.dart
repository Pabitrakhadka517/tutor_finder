import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String role;
  const RegisterPage({super.key, required this.role});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _extraController1 = TextEditingController();
  final _extraController2 = TextEditingController();
  final _extraController3 = TextEditingController();

  bool _obscureText = true;

  String get role => widget.role;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _extraController1.dispose();
    _extraController2.dispose();
    _extraController3.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Call role-specific registration method
      switch (role) {
        case "Tutor":
          ref
              .read(authNotifierProvider.notifier)
              .registerTutor(email: email, password: password);
          break;
        case "Admin":
          ref
              .read(authNotifierProvider.notifier)
              .registerAdmin(email: email, password: password);
          break;
        case "Student":
        default:
          ref
              .read(authNotifierProvider.notifier)
              .register(email: email, password: password);
          break;
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  List<Widget> _roleSpecificFields() {
    if (role == "Tutor") {
      return [
        _buildField(_extraController1, "Subjects / Expertise", Icons.book),
        const SizedBox(height: 16),
        _buildField(_extraController2, "Qualification", Icons.school),
        const SizedBox(height: 16),
        _buildField(
          _extraController3,
          "Experience (Years)",
          Icons.timelapse,
          keyboardType: TextInputType.number,
        ),
      ];
    } else if (role == "Student") {
      return [
        _buildField(_extraController1, "Grade / Class", Icons.class_),
        const SizedBox(height: 16),
        _buildField(_extraController2, "Subjects Interested", Icons.bookmark),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.status == AuthStatus.registrationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage(role: role)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                color: Colors.blue.shade900,
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              // Header
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up as $role',
                style: TextStyle(fontSize: 18, color: Colors.blue.shade700),
              ),

              const SizedBox(height: 32),

              // Floating Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        _emailController,
                        "Email",
                        Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      _buildPasswordField(),
                      const SizedBox(height: 16),

                      // Role-specific fields
                      ..._roleSpecificFields(),
                      const SizedBox(height: 24),

                      // Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            disabledBackgroundColor: Colors.blue.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          child: authState.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(role: role),
                            ),
                          );
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom input field (same style as login page)
  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade700),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      validator: _validatePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(Icons.lock, color: Colors.blueGrey.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.blueGrey.shade700,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
    );
  }
}
