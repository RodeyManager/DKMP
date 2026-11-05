import 'package:equatable/equatable.dart';

import '../../data/models/image_captcha.dart';

/// 图形验证码加载状态。
enum CaptchaStatus { initial, loading, loaded, failure }

/// 短信验证码发送状态。
enum SmsStatus { idle, sending, sent }

/// 注册提交状态。
enum SubmitStatus { idle, submitting, success, failure }

/// 注册页状态。
class RegisterState extends Equatable {
  const RegisterState({
    this.captchaStatus = CaptchaStatus.initial,
    this.captcha,
    this.smsStatus = SmsStatus.idle,
    this.smsCountdown = 0,
    this.submitStatus = SubmitStatus.idle,
    this.errorMessage,
  });

  final CaptchaStatus captchaStatus;
  final ImageCaptcha? captcha;

  final SmsStatus smsStatus;

  /// 短信重发倒计时剩余秒数；0 表示当前可发送。
  final int smsCountdown;

  final SubmitStatus submitStatus;

  /// 最近一次需要展示的错误信息（SnackBar 用），展示后无需主动清除。
  final String? errorMessage;

  bool get canSendSms =>
      smsStatus != SmsStatus.sending && smsCountdown == 0;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  RegisterState copyWith({
    CaptchaStatus? captchaStatus,
    ImageCaptcha? captcha,
    bool clearCaptcha = false,
    SmsStatus? smsStatus,
    int? smsCountdown,
    SubmitStatus? submitStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return RegisterState(
      captchaStatus: captchaStatus ?? this.captchaStatus,
      captcha: clearCaptcha ? null : (captcha ?? this.captcha),
      smsStatus: smsStatus ?? this.smsStatus,
      smsCountdown: smsCountdown ?? this.smsCountdown,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        captchaStatus,
        captcha,
        smsStatus,
        smsCountdown,
        submitStatus,
        errorMessage,
      ];
}
