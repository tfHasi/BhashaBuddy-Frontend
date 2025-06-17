import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false, _isStudent = true;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = _isStudent
          ? await _auth.studentSignup(_emailCtrl.text.trim(), _passCtrl.text, _nickCtrl.text.trim())
          : await _auth.adminSignup(_emailCtrl.text.trim(), _passCtrl.text);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created!')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _styledField({
    required TextEditingController ctrl,
    required String label,
    String? Function(String?)? validator,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _radioTile(String title, bool value) {
    return SizedBox(
      height: 50,
      child: RadioListTile<bool>(
        value: value,
        groupValue: _isStudent,
        onChanged: (v) => setState(() => _isStudent = v!),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        activeColor: Colors.redAccent,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        tileColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _styledButton(String label, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/homescreen/red_button_depth_gradient.png', height: 50, width: 200, fit: BoxFit.fill),
          _loading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : Text(label, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
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
            Positioned.fill(child: Image.asset('assets/images/homescreen/background_image.png', fit: BoxFit.fill)),
            Container(color: Colors.black.withOpacity(0.3)),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('Join us today', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      SizedBox(height: 30),

                      // Radio Selection
                      Row(
                        children: [
                          Expanded(child: _radioTile('Student', true)),
                          SizedBox(width: 8),
                          Expanded(child: _radioTile('Admin', false)),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Fields
                      _styledField(
                        ctrl: _emailCtrl,
                        label: 'Email',
                        inputType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
                      ),
                      SizedBox(height: 16),
                      _styledField(
                        ctrl: _passCtrl,
                        label: 'Password',
                        obscure: true,
                        validator: (v) => v == null || v.length < 6 ? 'Password must be 6+ chars' : null,
                      ),
                      if (_isStudent) ...[
                        SizedBox(height: 16),
                        _styledField(
                          ctrl: _nickCtrl,
                          label: 'Nickname',
                          validator: (v) => v == null || v.isEmpty ? 'Enter nickname' : null,
                        ),
                      ],
                      SizedBox(height: 32),

                      // Button
                      _styledButton('Sign Up', _loading ? null : _signup),
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