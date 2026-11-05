import 'dart:typed_data';

import 'package:flutter/material.dart';

/// 图形验证码图片视图：加载中 / 失败 / 正常三种形态，点击刷新。
class CaptchaImageView extends StatelessWidget {
  const CaptchaImageView({
    super.key,
    required this.loading,
    this.bytes,
    required this.onRefresh,
    this.width = 120,
    this.height = 48,
  });

  /// 是否处于加载中。
  final bool loading;

  /// 验证码图片字节；null 时展示占位刷新图标。
  final Uint8List? bytes;

  final VoidCallback onRefresh;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '图形验证码，点击刷新',
      child: GestureDetector(
        onTap: loading ? null : onRefresh,
        child: Container(
          width: width,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (loading)
                const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (bytes != null)
                Image.memory(
                  bytes!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                )
              else
                Center(
                  child: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
