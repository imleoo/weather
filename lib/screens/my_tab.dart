import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class MyTab extends StatefulWidget {
  const MyTab({super.key});

  @override
  State<MyTab> createState() => _MyTabState();
}

class _MyTabState extends State<MyTab> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      // 用户未登录或token过期
      setState(() {
        _currentUser = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.my,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser != null
              ? _buildUserProfile()
              : _buildLoginPrompt(),
    );
  }

  Widget _buildUserProfile() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 用户信息卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.purple,
                  backgroundImage: _currentUser!.avatarUrl != null
                      ? NetworkImage(_currentUser!.avatarUrl!)
                      : null,
                  child: _currentUser!.avatarUrl == null
                      ? Text(
                          _currentUser!.nickname.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser!.nickname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentUser!.email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                if (_currentUser!.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _currentUser!.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 功能菜单
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.purple),
                title: Text(AppLocalizations.editProfile),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: _currentUser!),
                    ),
                  );
                  
                  if (updatedUser != null) {
                    setState(() {
                      _currentUser = updatedUser;
                    });
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue),
                title: Text(AppLocalizations.myFishCatches),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: 显示我的鱼获
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('我的鱼获功能待实现')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.place, color: Colors.green),
                title: Text(AppLocalizations.myFishingSpots),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: 显示我的钓点
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('我的钓点功能待实现')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(AppLocalizations.likedShares),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: 显示点赞的分享
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('点赞分享功能待实现')),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 设置菜单
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: Text(AppLocalizations.settings),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: 打开设置页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('设置功能待实现')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.orange),
                title: Text(AppLocalizations.help),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: 显示帮助页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('帮助功能待实现')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: Text(AppLocalizations.about),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // 退出登录按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              AppLocalizations.logout,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.pleaseLogin,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.loginToAccessFeatures,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  AppLocalizations.loginRegister,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToLogin() async {
    final user = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
    
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.confirmLogout),
        content: Text(AppLocalizations.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await AuthService.logout();
                setState(() {
                  _currentUser = null;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.logoutSuccess)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${AppLocalizations.logoutFailed}: $e')),
                );
              }
            },
            child: Text(
              AppLocalizations.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppLocalizations.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.wb_sunny, size: 48, color: Colors.blue),
      children: [
        const SizedBox(height: 16),
        Text(AppLocalizations.aboutDescription),
      ],
    );
  }
}