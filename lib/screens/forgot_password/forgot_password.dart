import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _textEmailController = TextEditingController();
  String? _errorEmail;
  bool _isLoading = false;

  @override
  void dispose() {
    _textEmailController.dispose();
    super.dispose();
  }

  Future<void> _forgotPassword() async {
    final email = _textEmailController.text.trim();
    setState(() {
      _errorEmail = email.isEmpty ? "Email is required" : null;
      _isLoading = _errorEmail == null;
    });

    if (_errorEmail == null) {
      try {
        // Make the POST request
        final response = await http.post(
          Uri.parse('https://deeppink-fly-733101.hostingersite.com/wp-login.php?action=lostpassword'),
          body: {'user_login': email},
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200 || response.statusCode == 302) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password reset email sent successfully!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to send reset email. Status Code: ${response.statusCode}")),
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Email',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _textEmailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          errorText: _errorEmail,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (_) => _forgotPassword(),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _forgotPassword,
                        child: Text('Reset Password'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
