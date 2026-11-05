# 注册相关接口约定（草案 v0.1）

> 状态：**草案**。后端接口尚未提供，本文档为前端先行约定；联调时以后端实际实现为准。
> 所有标注 ⚠️ 的条目为**待确认项**，请后端 / 产品在联调前回复确认。

## 通用约定

- Base URL：⚠️ 待后端提供（当前前端占位 `http://localhost:8080`，见 `lib/core/constants/app_constants.dart`）
- 鉴权方式：⚠️ 注册接口预计无需鉴权，token 方案待登录模块统一定义
- 请求 / 响应编码：UTF-8，请求体 `application/json`
- 统一响应信封：

```json
{ "code": 0, "message": "ok", "data": { } }
```

- ⚠️ 成功码：当前前端按 `code == 0` 判定，若后端用 200 请告知
- ⚠️ 错误码表：待后端提供（尤其图形验证码失效 / 短信频控两类错误的专属错误码，前端可用它做精细化提示，如自动刷新图形验证码）

---

## 1. 获取图形验证码

`GET /api/v1/captcha/image`

### 响应 `data`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `captchaKey` | string | 验证码标识，下发短信时回传 |
| `imageBase64` | string | 图片 base64，**不带** `data:` 前缀（前端已兼容带前缀的情况） |
| `expireSeconds` | int | 有效期（秒）⚠️ 默认 300，超时前端提示刷新 |

### 响应示例

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "captchaKey": "c7f2...",
    "imageBase64": "iVBORw0KGgo...",
    "expireSeconds": 300
  }
}
```

---

## 2. 发送短信验证码

`POST /api/v1/captcha/sms`

⚠️ 场景字段：当前未拆分注册 / 找回密码等场景；若后端要求 `scene` 参数（如 `"register"`），请告知取值约定。

### 请求体

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `mobile` | string | 11 位手机号，前端已按 `^1[3-9]\d{9}$` 校验 |
| `captchaKey` | string | 图形验证码标识 |
| `captchaCode` | string | 用户输入的图形验证码 |

### 响应 `data`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `intervalSeconds` | int | ⚠️ 重发间隔秒数，可不返回；缺省时前端按 60 秒倒计时 |

### 响应示例

```json
{ "code": 0, "message": "ok", "data": { "intervalSeconds": 60 } }
```

### 错误场景（前端行为）

- 图形验证码错误 / 过期 → 返回业务错误码 + message；前端展示提示并**自动刷新**图形验证码
- 短信发送频控 → 返回业务错误码 + message +（建议）`data.intervalSeconds`，前端按剩余时间恢复倒计时 ⚠️

---

## 3. 注册

`POST /api/v1/auth/register`

### 请求体

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `mobile` | string | 是 | 手机号 |
| `smsCode` | string | 是 | 短信验证码，前端按 6 位数字校验 ⚠️ 位数待确认 |
| `password` | string | ⚠️ | 是否必填**待产品/后端确认**；当前前端按「注册即设置密码」实现，6~20 位 |

### 响应 `data`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `userId` | string ⚠️ | 用户 ID，类型待确认 |
| `token` | string ⚠️ | 注册后是否直接登录返回 token？当前前端未处理 token |
| `userInfo` | object ⚠️ | 是否返回用户信息，待确认 |

### 响应示例

```json
{ "code": 0, "message": "ok", "data": { "userId": "10001" } }
```

---

## 待确认项汇总

1. Base URL 与网关前缀
2. 统一成功码取值（0 / 200）与错误码表
3. 短信发送是否需要 `scene` 场景字段
4. `intervalSeconds` 是否返回（短信重发间隔）
5. 短信验证码位数（前端当前按 6 位校验）
6. 图形验证码位数与有效期（前端当前按 4~8 位校验、默认 300s）
7. 注册是否强制设置密码，及密码复杂度规则
8. 注册成功是否直接返回 token / 用户信息（决定前端是否跳过登录）
9. 注册成功后的跳转目标（登录页 or 直接进首页）
10. 用户协议 / 隐私政策的链接地址
