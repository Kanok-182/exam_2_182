import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signIn(_email.text, _password.text);
    } catch (e) {
      if (mounted) showSnack(context, AuthController.thaiError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seed() async {
    setState(() => _loading = true);
    try {
      await _auth.seedTestAccounts();
      if (mounted) {
        showSnack(context,
            'สร้างบัญชีทดสอบสำเร็จ: admin@test.com / operator@test.com (รหัส 123456)');
      }
    } catch (e) {
      if (mounted) showSnack(context, AuthController.thaiError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(String email) {
    _email.text = email;
    _password.text = '123456';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.ev_station_rounded,
                        size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  const Text('EVFleet',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1)),
                  const Text('Smart EV Charging Fleet Management',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 24,
                            offset: Offset(0, 10))
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('เข้าสู่ระบบ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: fieldDeco(
                                label: 'อีเมล',
                                icon: Icons.email_outlined,
                                hint: 'admin@test.com'),
                            validator: AppValidators.email,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: fieldDeco(
                                    label: 'รหัสผ่าน',
                                    icon: Icons.lock_outline_rounded)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: AppValidators.password,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _loading ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.login_rounded),
                            label: const Text('เข้าสู่ระบบ',
                                style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 14),
                          const Divider(),
                          const Text('บัญชีทดสอบ (แตะเพื่อกรอกอัตโนมัติ)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _fill('admin@test.com'),
                                  icon: const Icon(
                                      Icons.admin_panel_settings_outlined),
                                  label: const Text('Admin'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _fill('operator@test.com'),
                                  icon: const Icon(Icons.engineering_outlined),
                                  label: const Text('Operator'),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _loading ? null : _seed,
                            child: const Text(
                                'สร้างบัญชีทดสอบ 2 บัญชี (ทำครั้งแรกครั้งเดียว)'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
