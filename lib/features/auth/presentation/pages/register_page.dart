import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/validators/validators.dart';
import '../../data/auth_repository.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import '../widgets/captcha_image_view.dart';

/// 注册页：手机号 + 图形验证码 + 短信验证码。
///
/// 额外包含「设置密码」与「协议勾选」两块【待确认】内容：
/// - 密码是否必填待产品/后端确认（见 RegisterRequest 注释）；
/// - 协议链接地址待产品提供。
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, this.cubit});

  /// 外部注入的 Cubit，用于测试时替换真实网络仓库；生产环境留空。
  final RegisterCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) {
        final RegisterCubit effectiveCubit =
            cubit ?? RegisterCubit(AuthRepository(ApiClient.instance));
        return effectiveCubit..refreshCaptcha();
      },
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _phoneFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _captchaFieldKey =
      GlobalKey<FormFieldState<String>>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreed = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _captchaController.dispose();
    _smsController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// 发送短信验证码：只需先校验手机号与图形验证码两个字段。
  void _onSendSms() {
    final bool phoneOk =
        _phoneFieldKey.currentState?.validate() ?? false;
    final bool captchaOk =
        _captchaFieldKey.currentState?.validate() ?? false;
    if (!phoneOk || !captchaOk) {
      return;
    }
    final RegisterCubit cubit = context.read<RegisterCubit>();
    final String captchaKey = cubit.state.captcha?.captchaKey ?? '';
    if (captchaKey.isEmpty) {
      cubit.refreshCaptcha();
      _showSnackBar('图形验证码未就绪，已自动刷新，请稍后重试');
      return;
    }
    cubit.sendSmsCode(
      mobile: _phoneController.text.trim(),
      captchaKey: captchaKey,
      captchaCode: _captchaController.text.trim(),
    );
  }

  void _onSubmit() {
    if (!_agreed) {
      _showSnackBar('请先阅读并同意《用户协议》和《隐私政策》');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<RegisterCubit>().submit(
          mobile: _phoneController.text.trim(),
          smsCode: _smsController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _resetForm() {
    _phoneController.clear();
    _captchaController.clear();
    _smsController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _agreed = false);
    context.read<RegisterCubit>().refreshCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (BuildContext context, RegisterState state) {
          final String? message = state.errorMessage;
          if (message != null) {
            _showSnackBar(message);
          }
          if (state.submitStatus == SubmitStatus.success) {
            _showSnackBar('注册成功');
            // TODO: 注册成功后的跳转目标（登录页 / 直接登录）待产品确认，当前先清空表单。
            _resetForm();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildPhoneField(),
                  const SizedBox(height: 16),
                  _buildCaptchaRow(),
                  const SizedBox(height: 16),
                  _buildSmsRow(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 8),
                  _buildAgreementRow(),
                  const SizedBox(height: 16),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      key: _phoneFieldKey,
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 11,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: '手机号',
        hintText: '请输入 11 位手机号',
        prefixIcon: Icon(Icons.phone_iphone_outlined),
        counterText: '',
      ),
      validator: Validators.phone,
    );
  }

  Widget _buildCaptchaRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            key: _captchaFieldKey,
            controller: _captchaController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '图形验证码',
              hintText: '请输入图中字符',
              prefixIcon: Icon(Icons.image_outlined),
            ),
            validator: Validators.captchaCode,
          ),
        ),
        const SizedBox(width: 12),
        BlocBuilder<RegisterCubit, RegisterState>(
          buildWhen: (RegisterState p, RegisterState c) =>
              p.captchaStatus != c.captchaStatus || p.captcha != c.captcha,
          builder: (BuildContext context, RegisterState state) {
            return Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CaptchaImageView(
                loading: state.captchaStatus == CaptchaStatus.loading,
                bytes: state.captcha?.imageBytes,
                onRefresh: () =>
                    context.read<RegisterCubit>().refreshCaptcha(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSmsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _smsController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '短信验证码',
              hintText: '请输入 6 位验证码',
              prefixIcon: Icon(Icons.sms_outlined),
              counterText: '',
            ),
            validator: Validators.smsCode,
          ),
        ),
        const SizedBox(width: 12),
        BlocBuilder<RegisterCubit, RegisterState>(
          buildWhen: (RegisterState p, RegisterState c) =>
              p.smsCountdown != c.smsCountdown || p.smsStatus != c.smsStatus,
          builder: (BuildContext context, RegisterState state) {
            final bool canSend = state.canSendSms;
            final String label = state.smsCountdown > 0
                ? '${state.smsCountdown}s 后重发'
                : (state.smsStatus == SmsStatus.sending ? '发送中…' : '获取验证码');
            return Padding(
              padding: const EdgeInsets.only(top: 2),
              child: OutlinedButton(
                onPressed: canSend ? _onSendSms : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(108, 48),
                ),
                child: Text(label, textAlign: TextAlign.center),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: '设置密码',
        hintText: '6~20 位',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: Validators.password,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: '确认密码',
        hintText: '请再次输入密码',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
      validator: (String? value) =>
          Validators.confirmPassword(value, _passwordController.text),
    );
  }

  Widget _buildAgreementRow() {
    // TODO(product): 协议链接待提供，先按纯文本占位。
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          value: _agreed,
          onChanged: (bool? value) => setState(() => _agreed = value ?? false),
        ),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: '我已阅读并同意',
              children: <TextSpan>[
                TextSpan(
                  text: '《用户协议》',
                  style: TextStyle(
                    color: Color(0xFF1E6FFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: '和'),
                TextSpan(
                  text: '《隐私政策》',
                  style: TextStyle(
                    color: Color(0xFF1E6FFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (RegisterState p, RegisterState c) =>
          p.isSubmitting != c.isSubmitting,
      builder: (BuildContext context, RegisterState state) {
        return FilledButton(
          onPressed: state.isSubmitting ? null : _onSubmit,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: state.isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('注 册'),
        );
      },
    );
  }
}
