import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dkmp/core/network/api_exception.dart';
import 'package:dkmp/features/auth/data/auth_repository.dart';
import 'package:dkmp/features/auth/data/models/auth_models.dart';
import 'package:dkmp/features/auth/data/models/image_captcha.dart';
import 'package:dkmp/features/auth/presentation/cubit/register_cubit.dart';
import 'package:dkmp/features/auth/presentation/pages/register_page.dart';

/// 不触网、不产生 Timer 的假仓库，用于组件测试。
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ImageCaptcha> fetchImageCaptcha() async {
    throw ApiException('测试环境不加载图形验证码');
  }

  @override
  Future<int> sendSmsCaptcha({
    required String mobile,
    required String captchaKey,
    required String captchaCode,
  }) async {
    throw ApiException('测试环境不发送短信');
  }

  @override
  Future<RegisterResult> register({
    required String mobile,
    required String smsCode,
    String? password,
  }) async {
    throw ApiException('测试环境不执行注册');
  }
}

RegisterPage _buildPage() {
  return RegisterPage(cubit: RegisterCubit(_FakeAuthRepository()));
}

void main() {
  testWidgets('注册页渲染手机号 / 图形验证码 / 短信验证码 / 提交按钮',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _buildPage()));
    await tester.pump();
    await tester.pump();

    expect(find.text('注册'), findsOneWidget);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('图形验证码'), findsOneWidget);
    expect(find.text('短信验证码'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
    expect(find.text('设置密码'), findsOneWidget);
    expect(find.text('确认密码'), findsOneWidget);
    expect(find.text('注 册'), findsOneWidget);
  });

  testWidgets('未勾选协议时提交弹出提示，不触发注册', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _buildPage()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('注 册'));
    await tester.pump();

    expect(find.text('请先阅读并同意《用户协议》和《隐私政策》'), findsOneWidget);
  });
}
