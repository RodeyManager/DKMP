/// 发送短信验证码请求体。
///
/// 字段命名 TODO(backend): 待后端确认，当前按 camelCase 约定。
class SendSmsRequest {
  const SendSmsRequest({
    required this.mobile,
    required this.captchaKey,
    required this.captchaCode,
  });

  final String mobile;
  final String captchaKey;
  final String captchaCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mobile': mobile,
        'captchaKey': captchaKey,
        'captchaCode': captchaCode,
      };
}

/// 注册请求体。
///
/// password 是否必填 TODO(product/backend): 待确认。
/// 当前按「注册时设置密码」实现，规则详见 Validators.password。
class RegisterRequest {
  const RegisterRequest({
    required this.mobile,
    required this.smsCode,
    this.password,
  });

  final String mobile;
  final String smsCode;
  final String? password;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mobile': mobile,
        'smsCode': smsCode,
        if (password != null && password!.isNotEmpty) 'password': password,
      };
}

/// 注册结果。
class RegisterResult {
  const RegisterResult({required this.userId});

  /// 用户 ID。TODO(backend): 字段类型（int/string）待确认，暂按字符串兼容。
  final String userId;

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(userId: json['userId']?.toString() ?? '');
  }
}
