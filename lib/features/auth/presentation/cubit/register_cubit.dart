import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/auth_repository.dart';
import '../../data/models/image_captcha.dart';
import 'register_state.dart';

/// 注册页状态管理：图形验证码获取、短信验证码下发（含倒计时）、注册提交。
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState());

  final AuthRepository _repository;
  Timer? _countdownTimer;

  /// 获取 / 刷新图形验证码。
  Future<void> refreshCaptcha() async {
    if (state.captchaStatus == CaptchaStatus.loading) {
      return;
    }
    emit(state.copyWith(
      captchaStatus: CaptchaStatus.loading,
      clearErrorMessage: true,
    ));
    try {
      final ImageCaptcha captcha = await _repository.fetchImageCaptcha();
      emit(state.copyWith(
        captchaStatus: CaptchaStatus.loaded,
        captcha: captcha,
        clearErrorMessage: true,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        captchaStatus: CaptchaStatus.failure,
        clearCaptcha: true,
        errorMessage: e.message,
      ));
    }
  }

  /// 发送短信验证码。
  Future<void> sendSmsCode({
    required String mobile,
    required String captchaKey,
    required String captchaCode,
  }) async {
    if (!state.canSendSms) {
      return;
    }
    emit(state.copyWith(
      smsStatus: SmsStatus.sending,
      clearErrorMessage: true,
    ));
    try {
      final int interval = await _repository.sendSmsCaptcha(
        mobile: mobile,
        captchaKey: captchaKey,
        captchaCode: captchaCode,
      );
      emit(state.copyWith(
        smsStatus: SmsStatus.sent,
        smsCountdown: interval,
      ));
      _startCountdown(interval);
    } on ApiException catch (e) {
      emit(state.copyWith(
        smsStatus: SmsStatus.idle,
        errorMessage: e.message,
      ));
      // 图形验证码错误是下发短信的高频失败原因，失败后统一刷新图形验证码。
      await refreshCaptcha();
    }
  }

  /// 提交注册。
  Future<void> submit({
    required String mobile,
    required String smsCode,
    String? password,
  }) async {
    if (state.isSubmitting) {
      return;
    }
    emit(state.copyWith(
      submitStatus: SubmitStatus.submitting,
      clearErrorMessage: true,
    ));
    try {
      await _repository.register(
        mobile: mobile,
        smsCode: smsCode,
        password: password,
      );
      // 成功后回到全新状态，页面据此清空表单并重新加载图形验证码。
      emit(const RegisterState(submitStatus: SubmitStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final int remaining = state.smsCountdown - 1;
      if (remaining <= 0) {
        timer.cancel();
        emit(state.copyWith(smsCountdown: 0));
      } else {
        emit(state.copyWith(smsCountdown: remaining));
      }
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
