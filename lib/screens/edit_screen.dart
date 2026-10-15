import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/charger_controller.dart';
import '../models/charger_model.dart';
import '../models/user_model.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';

/// แก้ไขหัวชาร์จ (เฉพาะ Admin) รวมถึงตั้งอัตรา On-Peak / Off-Peak
class EditScreen extends StatefulWidget {
  final Charger charger;
  final AppUser user;
  const EditScreen({super.key, required this.charger, required this.user});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ChargerController();
  late final TextEditingController _chargerId;
  late final TextEditingController _location;
  late final TextEditingController _email;
  late final TextEditingController _power;
  late final TextEditingController _tariff;
  late final TextEditingController _onPeak;
  late final TextEditingController _offPeak;
  bool _saving = false;

  final _decimalOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

  @override
  void initState() {
    super.initState();
    final c = widget.charger;
    _chargerId = TextEditingController(text: c.chargerId);
    _location = TextEditingController(text: c.location);
    _email = TextEditingController(text: c.engineerEmail);
    _power = TextEditingController(text: formatNum(c.powerKw));
    _tariff = TextEditingController(text: formatNum(c.tariff));
    _onPeak = TextEditingController(
        text: c.onPeakRate == null ? '' : formatNum(c.onPeakRate!));
    _offPeak = TextEditingController(
        text: c.offPeakRate == null ? '' : formatNum(c.offPeakRate!));
  }

  @override
  void dispose() {
    for (final c in [_chargerId, _location, _email, _power, _tariff, _onPeak, _offPeak]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) {
      showSnack(context, 'กรุณาแก้ไขข้อมูลที่ไม่ถูกต้อง', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await _controller.updateCharger(
        widget.charger.id,
        Charger(
          chargerId: _chargerId.text.trim().toUpperCase(),
          location: _location.text.trim(),
          engineerEmail: _email.text.trim(),
          powerKw: double.parse(_power.text.trim()),
          tariff: double.parse(_tariff.text.trim()),
          onPeakRate: _onPeak.text.trim().isEmpty
              ? null
              : double.parse(_onPeak.text.trim()),
          offPeakRate: _offPeak.text.trim().isEmpty
              ? null
              : double.parse(_offPeak.text.trim()),
        ),
        widget.user,
      );
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, 'อัปเดตข้อมูลสำเร็จ');
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไข ${widget.charger.chargerId}'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace:
            Container(decoration: const BoxDecoration(gradient: appGradient)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _chargerId,
                textCapitalization: TextCapitalization.characters,
                decoration: fieldDeco(
                    label: 'รหัสสถานีและหัวจ่าย', icon: Icons.qr_code_2_rounded),
                validator: AppValidators.chargerId,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _location,
                decoration: fieldDeco(
                    label: 'ตำแหน่งพิกัดสถานี',
                    icon: Icons.location_on_outlined),
                validator: AppValidators.location,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: fieldDeco(
                    label: 'อีเมลวิศวกรผู้ดูแลสถานี',
                    icon: Icons.alternate_email_rounded),
                validator: AppValidators.email,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _power,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalOnly,
                decoration: fieldDeco(
                    label: 'กำลังไฟฟ้าสูงสุด',
                    icon: Icons.bolt_rounded,
                    suffix: 'kW'),
                validator: AppValidators.power,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _tariff,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalOnly,
                decoration: fieldDeco(
                    label: 'อัตราค่าบริการปกติ',
                    icon: Icons.payments_outlined,
                    suffix: 'THB/kWh'),
                validator: AppValidators.tariff,
              ),
              const SizedBox(height: 22),
              const Text('อัตราค่าบริการตามช่วงเวลา (ไม่บังคับ)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _onPeak,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalOnly,
                decoration: fieldDeco(
                    label: 'On-Peak (เช่น 09:00–22:00)',
                    icon: Icons.wb_sunny_outlined,
                    suffix: 'THB/kWh'),
                validator: AppValidators.optionalRate,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _offPeak,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalOnly,
                decoration: fieldDeco(
                    label: 'Off-Peak (เช่น 22:00–09:00)',
                    icon: Icons.nightlight_outlined,
                    suffix: 'THB/kWh'),
                validator: AppValidators.optionalRate,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _update,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
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
                    : const Icon(Icons.check_rounded),
                label: const Text('บันทึกการแก้ไข',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
