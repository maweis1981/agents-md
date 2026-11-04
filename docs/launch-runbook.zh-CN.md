# 上线配套操作手册

[English](./launch-runbook.md) ・ [简体中文](./launch-runbook.zh-CN.md)

照着做一遍，就能让 agent 接手[上线配套](./launch-stack.zh-CN.md)的全部工作。**A 部分只做一次**（约 30 分钟），**B 部分每个新产品做一次**（约 10 分钟）。脚本在 [`scripts/launch/`](../scripts/launch/)，用你本人的 Google 身份在 Cloud Shell 里运行。个人账号没有 Cloud 组织也能建项目，所以不受“服务账号建不了项目”的限制。

下面以都播为例，换成新产品时只改参数。

## 准备

1. 用**能管理 GA4 的那个 Google 账号**登录（都播就是能打开 GA4 媒体资源 558471154 的账号）。
2. 打开 <https://console.firebase.google.com>，第一次使用时接受服务条款。不接受的话，脚本添加 Firebase 时会报 403。
3. 打开 Cloud Shell：<https://shell.cloud.google.com>，取得脚本：

   ```bash
   git clone https://github.com/maweis1981/agents-md && cd agents-md/scripts/launch
   ```

   PR #9 合并前，在 `git clone` 后面加 `-b claude/blissful-planck-pdki67`。

## A. 一次性：建立增长运营身份

### A1. 运行 setup 脚本

```bash
bash setup-growth-ops.sh --key
```

脚本会建 `growth-ops-xxxx` 项目，启用所需的 API，再建服务账号 `launch-agent@growth-ops-xxxx.iam.gserviceaccount.com`，并生成密钥文件 `~/launch-agent.json.b64`。记下输出里的**项目 ID** 和**服务账号邮箱**，后面都要用。

### A2. GA4

不用手动操作：B 部分的脚本会自动把服务账号加为 GA4 账号的管理员。如果脚本提示失败，再手动加：GA4 → 管理 → **账号**访问权限管理 → 添加服务账号邮箱，角色选“管理员”。

### A3. GTM

打开 <https://tagmanager.google.com>，进入都播容器（`GTM-NDPJBD6N`）所在的账号 → 管理 → **用户管理** → 添加服务账号邮箱。账号权限选“用户”，所有容器的权限选“**发布**”。

### A4. Google Play

打开 Play Console → **用户和权限** → 邀请新用户 → 填服务账号邮箱，勾选以下**账号级**权限：

- 查看应用信息
- 管理商店信息
- 管理订单和订阅
- 查看财务数据
- 发布到测试轨道
- 发布到正式版

### A5. App Store Connect

App Store Connect → **用户和访问** → **集成** → App Store Connect API → **团队密钥** → 生成，角色选 **App Manager**。

- 记下 **Issuer ID** 和 **Key ID**。
- 下载 `AuthKey_XXXX.p8`。只能下载一次。

### A6. 把凭据存进 Claude 云端环境

在 Claude 会话标题栏打开云端环境菜单 → **编辑** → 环境变量（有“Network secrets”一栏的话放在那里）。添加以下变量：

| 变量 | 值 |
| --- | --- |
| `LAUNCH_GCP_SA_JSON_B64` | 在 Cloud Shell 里执行 `cat ~/launch-agent.json.b64`，复制输出 |
| `ASC_ISSUER_ID` | A5 的 Issuer ID |
| `ASC_KEY_ID` | A5 的 Key ID |
| `ASC_KEY_P8_B64` | `base64 -w0 AuthKey_XXXX.p8` 的输出 |

存好后**删掉本地文件**：执行 `rm ~/launch-agent.json.b64`，删掉下载的 `.p8`。新开的会话才会读到这些变量。

**不要把这些值贴进聊天、Issue 或仓库。**

### A7. 允许 agent 使用这些凭据

Claude Code 的自动权限检查会拦下读取凭据的操作（今天就碰到了）。两种做法，选一种：

- **每次会话开头说一句**：“这个会话可以用 `LAUNCH_*` 和 `ASC_*` 凭据做 launch 相关的操作。”
- **长期生效**：在产品仓库的 `.claude/settings.json` 里，把 launch 用到的命令加进 `permissions.allow`，然后提交。注意，只有会话里只挂了一个仓库时，才会读取这个文件。

付费或不可撤销的操作（建广告系列、改价格、提交审核），agent 仍然会先问你。

## B. 每个产品：一键建好 Google 这一套

### B1. 运行 bootstrap 脚本（都播参数）

```bash
bash bootstrap-product.sh \
  --slug doubo --name "Doubo" --project doubo-prod \
  --sa launch-agent@growth-ops-xxxx.iam.gserviceaccount.com \
  --ga4-property 558471154 --domain doubo.tv \
  --bundle-id com.maweis1981.streamline --app-store-id 6821588266 \
  --package tv.doubo.streamline --activation-event playback_start
```

第一次运行会提示还需要 GA4 授权，并打印两条命令：先执行 `gcloud auth application-default login …`（浏览器里点同意），再执行 `set-quota-project`，然后重跑上面的 bootstrap 命令。

脚本会依次完成：

1. 建 `doubo-prod` 项目；
2. 把服务账号设为这个项目的 Owner；
3. 采用现有的 GA4 媒体资源 558471154，并把服务账号加为 GA4 管理员；
4. 在项目上开通 Firebase，**关联到这个 GA4 媒体资源**，不会另建新的媒体资源；
5. 添加 iOS 和 Android 应用，GA4 里会自动多出两个 App 数据流；
6. 确认网页数据流存在，设置 14 个月的数据保留；
7. 标记关键事件 `first_open`、`purchase`、`playback_start`；
8. 注册自定义维度。

最后它会打印一段 `launch.yaml` 内容，并把两个配置文件放在 `~/launch-out/`。

**新产品还没有 GA4 媒体资源时**，把 `--ga4-property` 换成 `--ga4-account <GA4 账号数字 ID>`，脚本会新建一个媒体资源，时区和币种用 `--timezone`、`--currency` 指定。

### B2. 剩下的三个手动步骤

1. **AdMob 关联 Firebase**：AdMob → 应用 → 每个应用 → 应用设置 → 关联到 Firebase 项目 `doubo-prod`。iOS 和 Android 各做一次。关联后广告收入会自动进 GA4。
2. **BigQuery 导出**：GA4 → 管理 → 产品关联 → BigQuery 关联 → 选 `doubo-prod`，勾选“每日”。
3. **告诉 agent 完成了**：把脚本打印的 `launch.yaml` 那段贴给它。这段只有 ID，不是机密。配置文件不用下载，agent 会用服务账号自己从 Firebase 取。

接着 agent 会：
- 写入并校验 `launch.yaml`；
- 把配置文件放进 iOS 和 Android 工程；
- 按 `launch-analytics` 接好三端统计（统计默认关闭，等你确认再开）；
- 用 `launch-google-stack` 建好 GTM 容器和 Search Console 这部分。

## 验证

- [ ] Firebase 控制台 → 项目设置 → 集成 → Google Analytics，显示的是媒体资源 558471154。
- [ ] GA4 → 管理 → 数据流，有网页、iOS、Android 三个。
- [ ] GA4 → 管理 → 关键事件，有 `first_open`、`purchase`、`playback_start`。
- [ ] GA4 账号访问权限管理里，能看到服务账号是管理员。
- [ ] 重跑一遍 bootstrap 脚本，输出只有 “exists” 或 “already” 之类的提示，没有新建任何东西。

## 常见报错

| 报错 | 原因与处理 |
| --- | --- |
| `addFirebase` 403 | 没在 Firebase 控制台接受条款（见准备第 2 步），或当前登录的账号不是项目 Owner |
| `addGoogleAnalytics` 403 | 当前登录的账号对这个 GA4 账号没有编辑权限，或这个媒体资源已经关联到别的 Firebase 项目 |
| “Firebase is linked to …, not …” | 这个项目已经关联了另一个媒体资源。一个产品只能有一个媒体资源，请在 Firebase 控制台解除关联，再重跑 |
| `accessBindings` 失败 | 登录的账号不是 GA4 账号管理员，或 ADC 登录时少了 `analytics.manage.users` 授权。按 A2 手动添加 |
| 建密钥报 `disableServiceAccountKeyCreation` | 你的账号属于启用了这条组织策略的组织。在组织策略里为 `growth-ops` 项目关闭它，或改用工作负载身份联合 |
| 等待操作超过 10 次仍未完成 | 稍后重跑脚本，已完成的步骤会自动跳过 |
