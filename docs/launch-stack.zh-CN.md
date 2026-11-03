# 上线配套（Launch stack）

[English](./launch-stack.md) ・ [简体中文](./launch-stack.zh-CN.md)

本文说明 agent 如何根据一份清单（manifest），为新产品建好周边的一整套服务：网站、搜索、统计、应用商店、广告和归因，以及以后如何安全地重跑同样的步骤。负责执行的 skills 是 `launch-manifest`、`launch-google-stack` 和 `launch-analytics`（第一批），其余见 [Skill 一览](#skill-一览)。

## 终点状态

从“产品上线当天必须具备什么”倒推：

| 方面 | 上线当天的状态 |
| --- | --- |
| 网站 | SEO 和 GEO 基础（sitemap、robots、hreflang、JSON-LD、`llms.txt`），带 Consent Mode v2 的同意横幅，装好 GTM，已发布 `app-ads.txt` |
| 搜索 | Google Search Console 网站已验证，sitemap 已提交 |
| 统计 | 一个 GA4 媒体资源，下面三个数据流（网页、iOS、Android）；已关联 Firebase；已标记关键事件；已开启 BigQuery 每日导出 |
| 商店 | App Store Connect 和 Google Play：内购商品、多语言商店信息、隐私申报 |
| 变现 | 购买页、权益和广告都已写好，但由开关**关闭**；买了 Pro 自动去广告 |
| 归因 | 带金额和币种的转化已导入 Google Ads；iOS 有 SKAdNetwork 和 Apple Search Ads；Android 有 Play 安装来源（Install Referrer） |
| 监控 | 开发时用实时报表和 DebugView；每日 SEO/GEO/GA4 报表；漏斗看板 |

## 领域模型：`launch.yaml`

每个产品仓库的根目录放一份清单 [`launch.yaml`](../templates/launch.yaml)。产品的身份和所有外部资源的 ID，都以它为唯一来源。

- **产品（Product）**：名称、域名、语言。
- **平台（Surfaces）**：`web`、`ios`、`android`（有 Windows 时再加 `windows`），各自记录平台身份（Bundle ID、包名、商店 ID）。
- **绑定（Bindings）**：每个外部服务一块，记录 skills 建出来的 ID（GCP 项目、GA4 媒体资源和数据流、Firebase 应用、GTM 容器、GSC 网站、AdMob 应用和广告单元、商店商品）。
- **转化（Conversions）**：产品的标准漏斗事件、哪些带金额、哪些导入广告平台。

规则：

- skills 读取清单，只创建缺少的东西，再把新 ID 写回。重复运行不会产生任何变化（幂等）。
- ID 不是机密，要提交进仓库。凭据绝不放进清单或仓库（见[上线凭据](./launch-credentials.zh-CN.md)）。
- agent 无法自动填写的字段，写成 `TODO(owner): …` 并附上控制台路径，这样剩下的手动工作始终一目了然。

## 哪些可以自动化

| 服务 | API 自动（agent） | 手动（负责人，通常每个账号只做一次） |
| --- | --- | --- |
| Google Cloud | 启用 API、项目内的 IAM | 服务账号建项目需要组织或文件夹；没有的话由负责人建项目 |
| Firebase | 把项目加入 Firebase、添加 iOS 和 Android 应用、下载配置、关联 GA4 | — |
| GA4 | 媒体资源、网页数据流、关键事件、自定义维度、Google Ads 和 BigQuery 关联、Measurement Protocol 密钥 | 新账号首次接受数据共享条款 |
| GTM（网页） | 容器、代码、触发器、变量、版本、发布 | — |
| Search Console | 添加网站、验证（DNS TXT 或 HTML 文件）、提交 sitemap | — |
| App Store Connect | 内购和订阅、价格、多语言信息、构建版本、提交审核 | 创建 App 记录、App 隐私问卷、协议、税务和银行 |
| Google Play | 内购商品和订阅、商店信息、数据安全表、发布版本 | 创建应用、广告 ID 声明 |
| AdMob | 报表 | 应用、广告单元、隐私权和消息（GDPR 及美国各州同意提示） |
| Google Ads | 转化操作、从 GA4 导入、广告系列 | 开户和付款 |
| Apple Search Ads | 广告系列和关键词 | 开户和付款 |
| DNS（如 Cloudflare） | 验证记录 | — |

## 标准转化与金额

事件名和参数在 `launch-analytics` skill 里定义。每个产品都遵守以下转化规则：

- `purchase` 带 `value`（金额）和 `currency`（用户实际付款的币种），排除 sandbox 和测试购买。移动端由 Firebase 自动记录 StoreKit 和 Play Billing 的 `in_app_purchase`，不要再手动记一次。
- 广告收入来自 AdMob 关联 Firebase 后的 `ad_impression`（带金额），不要手动记。
- 只把三个转化导入广告平台：`first_open`、产品的**激活**事件（第一个有价值的操作）、`purchase`。导入太多会干扰出价。
- SKAdNetwork 转化值（0–63）所有产品用同一套方案：最低位表示是否激活，高位表示收入区间。

## 第一个产品（都播）的教训

以下是规则，不是建议：

- 不要用 Google Indexing API 推送普通网页，也不要批量发布几千个几乎相同的生成页面。都播的 Google 曝光一夜之间少了约 95%，这两点是最可能的原因。
- 先发布 `app-ads.txt`，再去 AdMob 关联应用，否则第一次验证会失败，只能重来。
- Android 上广告 SDK 会自动加广告 ID 权限。广告未开启时要移除它，让 Play 上的申报保持真实，并用测试保证清单和开关一致。
- 欧盟、英国和瑞士默认不同意统计和广告。
- iOS 不请求 IDFA（不弹 App Tracking Transparency）。
- 免费额度从付费上线当天开始计算，不计免费版期间的使用。
- 私有仓库的 CI 不用 macOS 机器（10 倍费用）。Android CI 的时间上限要给正式版构建留够余量。

## Skill 一览

| Skill | 状态 | 作用 |
| --- | --- | --- |
| `launch-manifest` | 第一批 | 建立并校验 `launch.yaml`，输出每个产品的完成清单 |
| `launch-google-stack` | 第一批 | GCP、Firebase、GA4 数据流、BigQuery 导出、GTM 网页容器、GSC |
| `launch-analytics` | 第一批 | 标准事件、各平台的统计接口层、用户同意、金额规则 |
| `launch-web-seo` | 下一批 | 网站 SEO/GEO 基础和索引防护 |
| `launch-store-apple` | 下一批 | App Store Connect 商品、多语言信息、隐私清单 |
| `launch-store-play` | 下一批 | Play 商品、商店信息、数据安全表、广告 ID |
| `launch-monetization` | 下一批 | 默认关闭的购买页、权益和广告；买 Pro 去广告 |
| `launch-attribution` | 下一批 | 广告转化导入、SKAdNetwork、Apple Search Ads、Install Referrer |
| `growth-daily-report` | 下一批 | 每日 SEO/GEO/GA4 报表，从 `launch.yaml` 读配置 |

## 推进顺序

1. 负责人一次性建好增长运营身份（见[上线凭据](./launch-credentials.zh-CN.md)）。
2. 在一个现有产品上试点第一批 skills，修掉跑不通的地方。
3. 从这个产品已经能用的代码里提炼其余 skills。
4. 在下一个新产品上从头到尾跑一遍。
