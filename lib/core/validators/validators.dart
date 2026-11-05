import '../constants/app_constants.dart';

/// 表单校验器：返回 null 表示通过，返回字符串为错误提示。
class Validators {
  Validators._();

  /// 手机号（中国大陆 11 位）。
  static String? phone(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) {
      return '请输入手机号';
    }
    if (!AppConstants.phoneRegExp.hasMatch(v)) {
      return '手机号格式不正确';
    }
    return null;
  }

  /// 图形验证码：非空、4~8 位（具体位数 TODO(backend): 待后端确认）。
  static String? captchaCode(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) {
      return '请输入图形验证码';
    }
    if (v.length < 4 || v.length > 8) {
      return '图形验证码为 4~8 位字符';
    }
    return null;
  }

  /// 短信验证码：6 位数字（位数 TODO(backend): 待后端确认）。
  static String? smsCode(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) {
      return '请输入短信验证码';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(v)) {
      return '短信验证码为 6 位数字';
    }
    return null;
  }

  /// 密码：6~20 位（规则 TODO(product): 待产品确认是否必填及复杂度要求）。
  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) {
      return '请设置密码';
    }
    if (v.length < 6 || v.length > 20) {
      return '密码长度为 6~20 位';
    }
    return null;
  }

  /// 确认密码：与 [password] 保持一致。
  static String? confirmPassword(String? value, String? password) {
    final String v = value ?? '';
    if (v.isEmpty) {
      return '请再次输入密码';
    }
    if (v != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }
}
