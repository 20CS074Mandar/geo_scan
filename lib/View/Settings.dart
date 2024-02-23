import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: _buildPasswordForm(),
    );
  }

  Widget _buildPasswordForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkPassword(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkPassword(BuildContext context) {
    String enteredPassword = _passwordController.text;
    String savedPassword = "Rocking@Infopercept";
    if (enteredPassword.toLowerCase() == savedPassword.toLowerCase()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => _buildSettingsPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password. Please try again.'),
        ),
      );
    }
  }

  Widget _buildSettingsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
        ],
      ),
    );
  }
}
