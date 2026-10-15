import 'package:form_field_validator/form_field_validator.dart';

/// รวม Validator ทั้งหมดของแอป (ใช้ทั้งหน้า Form, Edit และ Login)
class AppValidators {
  static final chargerId = MultiValidator([
    RequiredValidator(errorText: 'กรุณากรอกรหัสสถานีและหัวจ่าย'),
    MinLengthValidator(4, errorText: 'รหัสต้องยาวอย่างน้อย 4 ตัวอักษร'),
  ]);

  static final location =
      RequiredValidator(errorText: 'กรุณากรอกตำแหน่งพิกัดสถานี');

  static final email = MultiValidator([
    RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
    EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
  ]);

  static final password = MultiValidator([
    RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
    MinLengthValidator(6, errorText: 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'),
  ]);

  /// กำลังไฟฟ้า kW : ห้ามว่าง, ตัวเลข, > 0 และ <= 1000
  static String? power(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกกำลังไฟฟ้า (kW)';
    final n = double.tryParse(v.trim());
    if (n == null) return 'กรอกได้เฉพาะตัวเลข';
    if (n <= 0) return 'กำลังไฟต้องมากกว่า 0';
    if (n > 1000) return 'กำลังไฟสูงสุดไม่เกิน 1,000 kW';
    return null;
  }

  /// อัตราค่าบริการ THB/kWh : ห้ามว่าง, ตัวเลข, 0-100
  static String? tariff(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกอัตราค่าบริการ';
    final n = double.tryParse(v.trim());
    if (n == null) return 'กรอกได้เฉพาะตัวเลข';
    if (n < 0) return 'ต้องไม่ติดลบ';
    if (n > 100) return 'อัตราค่าบริการไม่ควรเกิน 100 THB/kWh';
    return null;
  }

  /// On-Peak / Off-Peak : เว้นว่างได้ แต่ถ้ากรอกต้องเป็นตัวเลขที่ถูกต้อง
  static String? optionalRate(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return tariff(v);
  }
}
