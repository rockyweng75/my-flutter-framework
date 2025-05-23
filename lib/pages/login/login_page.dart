import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_framework/api/login/i_login_service.dart';
import 'package:my_flutter_framework/database/user_repository.dart';
import 'package:my_flutter_framework/models/user.dart';
import 'package:my_flutter_framework/pages/login/login_bottom_app_bar.dart';
import 'package:my_flutter_framework/pages/register/register_page.dart';
import 'package:my_flutter_framework/shared/biometric_auth.dart';
import 'package:my_flutter_framework/shared/components/reusable_notification.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';
import 'package:my_flutter_framework/shared/utils/transaction_manager.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final ILoginService _loginService;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    _loginService = ref.read(loginServiceProvider);
    _initializeDefaultCredentials();
  }

  void _initializeDefaultCredentials() {
    _usernameController.text = 'test'; // Default username
    _passwordController.text = '1qaz@WSX'; // Default password
  }

  void _handleLogin() async {
    try {
      if (!mounted) return; // Ensure the widget is still in the widget tree
      TransactionManager transactionManager = TransactionManager(context);
      await transactionManager.execute(() async {
        User user = await _loginService.login(
          _usernameController.text,
          _passwordController.text,
        );
        await UserRepository.saveUser(user);
      });
      _navigateToDashboard();
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still in the widget tree
      _showLoginError(e);
    }
  }

  void _navigateToDashboard() {
    context.go('/dashboard');

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const DashboardPage()),
    // );
  }

  void _showLoginError(Object e) {
    ReusableNotification(context).show(e.toString(), type: PrintType.danger);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Login failed: $e')),
    // );
  }

  void _handleBiometricLogin() async {
    final BiometricAuth biometricAuth = BiometricAuth();
    final bool isAuthenticated = await biometricAuth.authenticate();

    if (isAuthenticated) {
      _navigateToDashboard();
    } else {
      _showBiometricError();
    }
  }

  void _showBiometricError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biometric authentication failed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _buildLoginBody(constraints);
        },
      ),
      bottomNavigationBar: LoginBottomAppBar(
        onLeftAction: () {},
        onBiometricLogin: _handleBiometricLogin,
        onRightAction: () {},
      ),
    );
  }

  Widget _buildLoginBody(BoxConstraints constraints) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      height: constraints.maxHeight,
      width: constraints.maxWidth,
      constraints: const BoxConstraints(minWidth: 320, minHeight: 480),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 設定最大、最小寬高
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        double logoHeight = (maxHeight * 0.18).clamp(
          48.0,
          120.0,
        ); // 最小48, 最大120
        double logoWidth = (logoHeight * 1.5).clamp(72.0, 180.0); // 最小72, 最大180
        // 若寬度超過父層最大寬度，則等比例縮小
        if (logoWidth > maxWidth) {
          logoWidth = maxWidth;
          logoHeight = logoWidth / 1.5;
        }
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: logoWidth,
              height: logoHeight,
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            _buildUsernameField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildLoginButton(),
            const SizedBox(height: 16),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _isPasswordObscured,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  Widget _buildLoginButton() {
    return ElevatedButton(onPressed: _handleLogin, child: const Text('Login'));
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: _navigateToRegisterPage,
      child: const Text('Don\'t have an account? Register here'),
    );
  }

  void _navigateToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
}
