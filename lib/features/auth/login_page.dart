import 'package:flutter/material.dart';

import '../../core/localization/locale_controller.dart';
import '../../core/theme/theme_controller.dart';
import '../dashboard/dashboard_home_page.dart';
import '../dashboard/sales_models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  SalesRole _selectedRole = SalesRole.admin;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final signedInUser = DemoSalesData.resolveUserForLogin(
      email: _emailController.text,
      role: _selectedRole,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DashboardHomePage(
          themeController: widget.themeController,
          localeController: widget.localeController,
          signedInUser: signedInUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE5ECF4)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enterprise Dashboard',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Login with your level access',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Enter email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Enter password';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<SalesRole>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Level',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: SalesRole.admin, child: Text('Admin')),
                            DropdownMenuItem(value: SalesRole.supervisor, child: Text('Supervisor')),
                            DropdownMenuItem(value: SalesRole.salesManager, child: Text('SalesManager')),
                          ],
                          onChanged: (role) {
                            if (role == null) return;
                            setState(() => _selectedRole = role);
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
