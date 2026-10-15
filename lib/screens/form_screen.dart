import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/charger_controller.dart';
import '../models/charger_model.dart';
import '../models/user_model.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';

/// แท็บ 1 : ฟอร์มลงทะเบียนหัวชาร์จ (ทั้ง Admin และ Operator บันทึกได้)
class FormScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback? onSaved;
  const FormScreen({super.key, required this.user, this.onSaved});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _chargerId = TextEditingController();
  final _location = TextEditingController();
  final _email = TextEditingController();
  final _power = TextEditingController();
  final _tariff = TextEditingController();
  final _controller = ChargerController();
  bool _saving = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _chargerId.dispose();
    _location.dispose();
    _email.dispose();
    _power.dispose();
    _tariff.dispose();
    super.dispose();
  }

  final _decimalOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

  Future<void> _save() async {
    // ต้อง Validate ทุกครั้งก่อนบันทึก
    if (!_formKey.currentState!.validate()) {
      showSnack(context, 'กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await _controller.addCharger(
        Charger(
          chargerId: _chargerId.text.trim().toUpperCase(),
          location: _location.text.trim(),
          engineerEmail: _email.text.trim(),
          powerKw: double.parse(_power.text.trim()),
          tariff: double.parse(_tariff.text.trim()),
        ),
        widget.user,
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      for (final c in [_chargerId, _location, _email, _power, _tariff]) {
        c.clear();
      }
      showSnack(context, 'บันทึกหัวชาร์จสำเร็จ');
      widget.onSaved?.call();
    } catch (e) {
      if (mounted) showSnack(context, 'บันทึกไม่สำเร็จ: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ลงทะเบียนหัวชาร์จ / เซสชัน',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('ผู้บันทึก: ${widget.user.email}',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            TextFormField(
              controller: _chargerId,
              textCapitalization: TextCapitalization.characters,
              decoration: fieldDeco(
                  label: 'รหัสสถานีและหัวจ่าย (Charger ID)',
                  icon: Icons.qr_code_2_rounded,
                  hint: 'EVSE-BKK-09'),
              validator: AppValidators.chargerId,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _location,
              decoration: fieldDeco(
                  label: 'ตำแหน่งพิกัดสถานี (Station Location)',
                  icon: Icons.location_on_outlined,
                  hint: 'เช่น 13.7563, 100.5018 หรือ ชื่อสถานที่'),
              validator: AppValidators.location,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: fieldDeco(
                  label: 'อีเมลวิศวกรผู้ดูแลสถานี',
                  icon: Icons.alternate_email_rounded,
                  hint: 'engineer@company.com'),
              validator: AppValidators.email,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _power,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _decimalOnly,
              decoration: fieldDeco(
                  label: 'กำลังไฟฟ้าสูงสุด (Charging Power)',
                  icon: Icons.bolt_rounded,
                  suffix: 'kW'),
              validator: AppValidators.power,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in ['50', '120', '360'])
                  ActionChip(
                    avatar: const Icon(Icons.flash_on, size: 16),
                    label: Text('$p kW'),
                    onPressed: () => setState(() => _power.text = p),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _tariff,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _decimalOnly,
              decoration: fieldDeco(
                  label: 'อัตราค่าบริการต่อหน่วย (Tariff Rate)',
                  icon: Icons.payments_outlined,
                  suffix: 'THB/kWh'),
              validator: AppValidators.tariff,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
              label: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
