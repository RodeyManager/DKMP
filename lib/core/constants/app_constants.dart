/// 应用全局常量。
///
/// 标注 `TODO(backend)` 的均为【待确认项】，接口联调时以后端实际约定为准。
class AppConstants {
  AppConstants._();

  /// 服务端基地址。TODO(backend): 待后端提供环境地址与网关前缀。
  static const String apiBaseUrl = 'http://localhost:8080';

  /// 连接超时（秒）。
  static const int connectTimeoutSeconds = 10;

  /// 接收超时（秒）。
  static const int receiveTimeoutSeconds = 15;

  /// 统一响应成功码。TODO(backend): 待后端确认（常见为 0 或 200）。
  static const int successCode = 0;

  // ---------------------------------------------------------------------------
  // 接口路径（前端约定草案，详见 docs/api-contract.md）
  // ---------------------------------------------------------------------------

  /// 获取图形验证码。
  static const String imageCaptchaPath = '/api/v1/captcha/image';

  /// 发送短信验证码。
  static const String smsCaptchaPath = '/api/v1/captcha/sms';

  /// 注册。
  static const String registerPath = '/api/v1/auth/register';

  /// 短信验证码默认重发间隔（秒），后端未返回间隔时兜底使用。
  static const int defaultSmsCountdownSeconds = 60;

  /// 手机号格式（中国大陆 11 位）。
  static final RegExp phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
}
