# 上线凭据

[English](./launch-credentials.md) ・ [简体中文](./launch-credentials.zh-CN.md)

一次性配置。配好后，agent 就能为每个产品运行[上线配套](./launch-stack.zh-CN.md)的 skills，不用每个产品重新授权一遍。负责人只做一次；以后每个新产品只需把自己加到这个身份已能访问的资源里。

## 身份

负责人名下建一个只用于运营的 Google Cloud 项目：`growth-ops`（ID 随意）。在里面建一个服务账号：`launch-agent@growth-ops.iam.gserviceaccount.com`。agent 调用所有 Google API 都用这个账号。这个项目里不放任何其他东西。

Apple 和各广告平台不接受 Google 身份，各自用单独的密钥（见下表）。

## 授权

| 位置 | 授权 | 原因 |
| --- | --- | --- |
| Google Cloud | 在 `growth-ops` 启用：Cloud Resource Manager、Service Usage、Firebase Management、Google Analytics Admin、Tag Manager、Search Console、Site Verification、Google Play Android Developer、BigQuery | 服务账号从自己的项目调用这些 API |
| Google Cloud，每个产品 | 在每个产品的 GCP 项目上给 `Owner`（或 `Firebase Admin` + `Service Usage Admin` + `BigQuery Admin`） | 添加 Firebase、应用、BigQuery 导出 |
| Google Cloud，建项目 | 有 Cloud 组织或文件夹：在上面给 `Project Creator`。**没有的话**（个人 Google 账号），服务账号建不了项目：由负责人在控制台为每个产品建项目（点一下就好），再给这个账号 `Owner` | 服务账号建项目需要有上级组织 |
| GA4 | 在**账号**的访问权限管理里，把这个账号加为每个产品所在 GA4 账号的`管理员`（Firebase 的“用户和权限”和 Cloud IAM **都不能**授予 GA4 权限） | 媒体资源、数据流、关键事件、关联 |
| GTM | 账号 → 用户管理 → 添加这个账号，所有容器给`发布`权限 | 创建并发布网页容器 |
| Search Console | agent 用这个账号验证网站后，它自动成为所有者；再把负责人自己的 Google 账号也加为所有者 | sitemap 和报表 |
| Google Play | Play Console → 用户和权限 → 邀请这个账号，账号级权限：管理商店信息、管理商品、发布应用、查看财务数据 | 商品、商店信息、数据安全表、发布 |
| App Store Connect | 用户和访问 → 集成 → **团队密钥**，角色 `App Manager`；保存 Issuer ID、Key ID 和 `.p8` 文件 | 商品、价格、多语言信息、构建版本 |
| Google Ads | 一个经理账号（MCC）、开发者令牌，以及负责人的 OAuth 客户端和刷新令牌 | 转化操作和 GA4 导入；Google Ads 不直接接受服务账号 |
| Apple Search Ads | 账号设置 → API → 添加一个 `API Account Manager` 用户，上传公钥 | 广告系列和归因报告 |

## 机密放在哪里

- **云端会话**：放在云端环境的 secrets 里，一个值一个变量：`LAUNCH_GCP_SA_JSON_B64`、`ASC_ISSUER_ID`、`ASC_KEY_ID`、`ASC_KEY_P8_B64`、`GOOGLE_ADS_DEVELOPER_TOKEN`、`GOOGLE_ADS_REFRESH_TOKEN`、`GOOGLE_ADS_CLIENT_ID`、`GOOGLE_ADS_CLIENT_SECRET`、`ASA_*`。
- **本地会话**：放在负责人的钥匙串或密码管理器里，只在当次会话导出到 shell。
- 绝不放进仓库、清单、Issue、PR 或日志。skills 只打印账号邮箱，从不打印密钥内容。

## 允许 agent 使用

Claude Code 的自动模式权限检查会拒绝 agent 读取未明确允许的凭据（“Credential Exploration”）。在用户或项目设置（`.claude/settings.json` → `permissions.allow`）里只允许以下这些，不要更宽：

- 读取 `LAUNCH_*`、`ASC_*`、`GOOGLE_ADS_*` 和 `ASA_*` 变量；
- 对外访问 `*.googleapis.com`、`oauth2.googleapis.com`、`api.appstoreconnect.apple.com`、`googleads.googleapis.com` 和 `api.searchads.apple.com`。

付费或不可撤销的操作仍然需要有人在场确认：创建广告系列、设置预算、提交构建版本审核、修改已上线商品的价格。

## 轮换

- 服务账号密钥和 App Store Connect 密钥每 90 天轮换一次；只要被贴到不该出现的地方，立即轮换。
- 产品下线时，把这个账号从该产品的 GA4 账号、GTM 容器和 Play 应用里移除。
