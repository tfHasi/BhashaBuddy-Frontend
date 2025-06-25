import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = await _auth.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (user != null) {
        final bool isAdmin = user['type'] == 'admin';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isAdmin
                ? DashboardScreen(user: user)
                : HomeScreen(user: user),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _styledTextField({
    required TextEditingController ctrl,
    required String label,
    required String? Function(String?) validator,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
  }) {
    const borderColor = Color.fromARGB(255, 42, 177, 234);

    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.9),
        ),
        child: TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: inputType,
          validator: validator,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: const Color.fromARGB(255, 20, 21, 21),
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
        ),
      ),
    );
  }

  Widget _styledButton(String label, VoidCallback? onPressed,
      {bool isOutline = false}) {
    final image = isOutline
        ? 'assets/images/homescreen/red_button_border_depth.png'
        : 'assets/images/homescreen/red_button_depth_gradient.png';
    final textColor = isOutline ? const Color(0xFF949494) : Colors.white;

    return InkWell(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(image, height: 50, width: 150, fit: BoxFit.fill),
          _loading && !isOutline
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/homescreen/background_image.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(color: Colors.black.withOpacity(0.3)),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sign in to your account',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 40),

                      _styledTextField(
                        ctrl: _emailCtrl,
                        label: 'Email',
                        inputType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter email' : null,
                      ),
                      SizedBox(height: 12),

                      _styledTextField(
                        ctrl: _passCtrl,
                        label: 'Password',
                        obscure: true,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter password' : null,
                      ),
                      SizedBox(height: 32),

                      _styledButton('Login', _loading ? null : _login),
                      SizedBox(height: 16),

                      _styledButton('Sign Up', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen()),
                        );
                      }, isOutline: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}