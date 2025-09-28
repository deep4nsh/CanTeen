import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  const OTPScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('OTP sent to ${widget.email}'),
            TextField(controller: _otpController, decoration: InputDecoration(labelText: 'Enter OTP'), keyboardType: TextInputType.number),
            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Set Password')),
            Consumer<AuthProvider>(
              builder: (context, auth, child) => ElevatedButton(
                onPressed: auth.isLoading ? null : () => _verifyOtp(context),
                child: auth.isLoading ? CircularProgressIndicator() : Text('Verify & Login'),
              ),
            ),
            if (auth.error != null) Text(auth.error!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Future<void> _verify() async {
    try {
      final data = await AuthService.verifyOtpAndLogin(
        email: widget.email,
        otp: _otpController.text,
        password: _passwordController.text,
      );
      // Navigate to role-based home (e.g., using GoRouter)
      final role = data['user']['role'];
      if (role == 'user') context.go('/user/browse');
      // Handle owner/admin similarly
    } catch (e) {
      // Show error
    }
  }
}