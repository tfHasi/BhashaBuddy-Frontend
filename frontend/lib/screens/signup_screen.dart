import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import './widgets/back_button.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isStudent = true;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = _isStudent
          ? await _authService.studentSignup(
              _emailController.text.trim(),
              _passwordController.text,
              _nicknameController.text.trim(),
            )
          : await _authService.adminSignup(
              _emailController.text.trim(),
              _passwordController.text,
            );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _styledButton({
    required String label,
    required VoidCallback? onPressed,
    required String imagePath,
    bool isLoading = false,
  }) =>
      InkWell(
        onTap: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(imagePath, height: 50, width: 150, fit: BoxFit.fill),
            isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(label,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
          ],
        ),
      );

  Widget _styledTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );

  Widget _styledRadioTile({
    required String title,
    required bool value,
  }) =>
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: RadioListTile<bool>(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
            value: value,
            groupValue: _isStudent,
            onChanged: (val) => setState(() => _isStudent = val!),
            activeColor: Colors.redAccent,
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      );

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
            Container(color: const Color.fromARGB(59, 0, 0, 0)),
            /// Back Button aligned to top-left
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AnimatedBackButton(onTap: () => Navigator.pop(context)),
                ],
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Join us today',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            _styledRadioTile(title: 'Student', value: true),
                            SizedBox(width: 8),
                            _styledRadioTile(title: 'Admin', value: false),
                          ],
                        ),
                        SizedBox(height: 16),
                        _styledTextField(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Enter email' : null,
                        ),
                        SizedBox(height: 16),
                        _styledTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Enter password';
                            if (v!.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                        if (_isStudent) ...[
                          SizedBox(height: 16),
                          _styledTextField(
                            controller: _nicknameController,
                            label: 'Nickname',
                            validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Enter nickname' : null,
                          ),
                        ],
                        SizedBox(height: 32),
                        _styledButton(
                          label: 'Sign Up',
                          onPressed: _isLoading ? null : _signup,
                          imagePath:
                              'assets/images/homescreen/red_button_depth_gradient.png',
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
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