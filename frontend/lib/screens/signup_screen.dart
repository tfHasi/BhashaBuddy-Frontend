import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Student'),
                      value: true,
                      groupValue: _isStudent,
                      onChanged: (value) => setState(() => _isStudent = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Admin'),
                      value: false,
                      groupValue: _isStudent,
                      onChanged: (value) => setState(() => _isStudent = value!),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter email';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter password';
                  if (value!.length < 6) return 'Password must be 6+ characters';
                  return null;
                },
              ),
              if (_isStudent) ...[
                SizedBox(height: 16),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(labelText: 'Nickname'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Enter nickname';
                    return null;
                  },
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}