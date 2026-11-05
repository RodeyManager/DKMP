import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/auth_models.dart';
import 'models/image_captcha.dart';

/// 认证域数据仓库：图形验证码 / 短信验证码 / 注册。
///
/// 接口字段为前端约定草案（详见 docs/api-contract.md），联调时以后端为准。
class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// 获取图形验证码。
  Future<ImageCaptcha> fetchImageCaptcha() async {
    final ApiResponse<ImageCaptcha> response =
        await _client.get<ImageCaptcha>(
      AppConstants.imageCaptchaPath,
      parse: (Object? raw) => ImageCaptcha.fromJson(
        (raw ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
    );
    return response.data!;
  }

  /// 发送短信验证码，返回重发间隔秒数（后端未返回时使用默认值）。
  Future<int> sendSmsCaptcha({
    required String mobile,
    required String captchaKey,
    required String captchaCode,
  }) async {
    final ApiResponse<num?> response = await _client.post<num?>(
      AppConstants.smsCaptchaPath,
      data: SendSmsRequest(
        mobile: mobile,
        captchaKey: captchaKey,
        captchaCode: captchaCode,
      ).toJson(),
      parse: (Object? raw) =>
          (raw as Map<String, dynamic>?)?['intervalSeconds'] as num?,
    );
    return response.data?.toInt() ?? AppConstants.defaultSmsCountdownSeconds;
  }

  /// 注册。
  Future<RegisterResult> register({
    required String mobile,
    required String smsCode,
    String? password,
  }) async {
    final ApiResponse<RegisterResult> response =
        await _client.post<RegisterResult>(
      AppConstants.registerPath,
      data: RegisterRequest(
        mobile: mobile,
        smsCode: smsCode,
        password: password,
      ).toJson(),
      parse: (Object? raw) => RegisterResult.fromJson(
        (raw ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
    );
    return response.data!;
  }
}
