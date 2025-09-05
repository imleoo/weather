import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 登录表单
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // 注册表单
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerNicknameController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showLoginPassword = false;
  bool _showRegisterPassword = false;
  bool _showConfirmPassword = false;
  VoidCallback? _onSuccess;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 获取传递的参数
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _onSuccess = args['onSuccess'] as VoidCallback?;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerNicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.loginRegister,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.login),
            Tab(text: AppLocalizations.register),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // 标题
            Text(
              AppLocalizations.welcomeBack,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.loginToContinue,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // 邮箱输入
            TextFormField(
              controller: _loginEmailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.email,
                hintText: AppLocalizations.enterEmail,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.emailRequired;
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return AppLocalizations.emailInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // 密码输入
            TextFormField(
              controller: _loginPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.password,
                hintText: AppLocalizations.enterPassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showLoginPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showLoginPassword = !_showLoginPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: !_showLoginPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.passwordRequired;
                }
                if (value.length < 6) {
                  return AppLocalizations.passwordTooShort;
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // 登录按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        AppLocalizations.login,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // 忘记密码链接
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: 实现忘记密码功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('忘记密码功能待实现')),
                  );
                },
                child: Text(AppLocalizations.forgotPassword),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // 标题
            Text(
              AppLocalizations.createAccount,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.joinOurCommunity,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // 昵称输入
            TextFormField(
              controller: _registerNicknameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.nickname,
                hintText: AppLocalizations.enterNickname,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.nicknameRequired;
                }
                if (value.length < 2) {
                  return AppLocalizations.nicknameTooShort;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // 邮箱输入
            TextFormField(
              controller: _registerEmailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.email,
                hintText: AppLocalizations.enterEmail,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.emailRequired;
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return AppLocalizations.emailInvalid;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // 密码输入
            TextFormField(
              controller: _registerPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.password,
                hintText: AppLocalizations.enterPassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showRegisterPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showRegisterPassword = !_showRegisterPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: !_showRegisterPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.passwordRequired;
                }
                if (value.length < 6) {
                  return AppLocalizations.passwordTooShort;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // 确认密码输入
            TextFormField(
              controller: _registerConfirmPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.confirmPassword,
                hintText: AppLocalizations.enterPasswordAgain,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: !_showConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.confirmPasswordRequired;
                }
                if (value != _registerPasswordController.text) {
                  return AppLocalizations.passwordsDoNotMatch;
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // 注册按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        AppLocalizations.register,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // 服务条款提示
            Text(
              AppLocalizations.termsAgreement,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );

      if (mounted) {
        Navigator.pop(context, user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${AppLocalizations.loginSuccess}, ${user.nickname}!')),
        );

        // 执行成功回调
        _onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.loginFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.register(
        _registerEmailController.text.trim(),
        _registerPasswordController.text,
        _registerNicknameController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.registerSuccess}, ${user.nickname}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${AppLocalizations.registerFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
