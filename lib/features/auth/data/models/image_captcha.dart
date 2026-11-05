import 'dart:convert';
import 'dart:typed_data';

/// 图形验证码。
class ImageCaptcha {
  const ImageCaptcha({
    required this.captchaKey,
    required this.imageBase64,
    this.expireSeconds = 300,
  });

  /// 验证码标识：下发短信验证码时需与图形验证码一起回传给后端。
  final String captchaKey;

  /// 图片内容（base64，可能带 `data:image/png;base64,` 前缀，已做兼容）。
  final String imageBase64;

  /// 有效期（秒），过期后需刷新。TODO(backend): 默认值待后端确认。
  final int expireSeconds;

  /// 解码后的图片字节，供 `Image.memory` 直接展示。
  Uint8List get imageBytes {
    String raw = imageBase64.trim();
    final int commaIndex = raw.indexOf(',');
    if (raw.startsWith('data:') && commaIndex != -1) {
      raw = raw.substring(commaIndex + 1);
    }
    return base64Decode(raw);
  }

  factory ImageCaptcha.fromJson(Map<String, dynamic> json) {
    return ImageCaptcha(
      captchaKey: json['captchaKey'] as String? ?? '',
      imageBase64: json['imageBase64'] as String? ?? '',
      expireSeconds: (json['expireSeconds'] as num?)?.toInt() ?? 300,
    );
  }
}
