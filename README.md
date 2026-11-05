# DKMP

[Document knowledge management platform 文档知识管理平台](https://github.com/RodeyManager/DKMP)

## DKMP App（Flutter）

移动端（Android / iOS，后续适配 OpenHarmony）当前包含注册流程：手机号 + 图形验证码 + 短信验证码。

```bash
flutter pub get
flutter run          # 运行到调试设备
flutter analyze      # 静态检查
flutter test         # 单元 / 组件测试
```

### 目录结构

- `lib/core/` — 网络层（Dio 封装、统一响应/异常）、主题、表单校验器
- `lib/features/auth/` — 注册 / 认证模块（page + cubit + repository + models）
- `lib/routing/` — go_router 路由表
- `docs/api-contract.md` — 注册相关后端接口约定草案（含待确认项）

