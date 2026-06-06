# Secrets 与凭据

> AI Agent 如何处理 `.env`、token 和云凭据。
> English: [`secrets.md`](./secrets.md)

AI Agent 同时碰 shell、Git 和云 API，秘密泄露面比正常团队大得多。
绝大多数"AI 事故"都可以追溯到下面三类原因之一。

## 硬性规则

1. **CI / Agent 禁止使用 long-lived PAT。**
   用 OpenID Connect (OIDC) 签发的短期 token —— GitHub Actions、AWS、
   GCP、Azure、Vercel 全部支持。
2. **`.env` 永不入库**：放进 `.gitignore`，提交一份占位用的 `.env.example`。
3. **Secret 不写日志**：禁止 `console.log(process.env)`、
   `printenv | tee debug.log`。打印前 mask。
4. **一个 secret 一个用途**：DB 密码别复用成 API key。
5. **凭据怀疑泄露立即轮换**，不要讨论先后。
6. **Agent 不应有打印 / 拷贝 / 上传 secret 的能力**：在 agent 的工具列表
   里就把这个能力剥掉。

## 用 OIDC 拿短期云凭据

长期 AWS access key / GCP service-account JSON / Vercel deploy token
存在仓库 Secret 里，是 AI Agent 泄露后第 1 个要轮换的对象。
**直接换掉它。**

### GitHub Actions → AWS

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123:role/gh-deploy
      aws-region: us-east-1
```

IAM role 信任 GitHub OIDC provider，且 scope 到具体仓库 + 分支。
不需要任何长期凭据。

### GitHub Actions → GCP

`google-github-actions/auth@v2` 配合 `workload_identity_provider`。

### Vercel / Cloudflare / Netlify

都暴露按部署签发的项目级 deploy token。当平台 CI 集成已经处理认证时，
不要再硬塞到仓库 Secret 里。

## `.env` 纪律

```
.env             # 本地，不入库
.env.local       # 本地，不入库
.env.example     # 占位符，入库
.env.production  # 仅当值非敏感时入库；否则用平台 secret 机制
```

`.gitignore` 至少包含：

```
.env
.env.local
.env.*.local
```

Agent 可以**读** `.env.example` 了解需要哪些变量，但**绝不读** `.env`，
更不能 echo 出来。

## Pre-commit Secret 扫描

把 `gitleaks` 或 `trufflehog` 加为 pre-commit hook：

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

GitHub 自身的 Secret Scanning **Push Protection** 也要打开 ——
它会直接拒绝包含已知 secret 模式的 push。

## 生产 secret 放在 environment scope 里

GitHub Actions 按 [`github-settings.zh-CN.md`](./github-settings.zh-CN.md)：

- 生产 secret 放进受保护的 `production` environment 的 environment
  secrets。
- `production` environment 必须人工审批才能部署。
- Preview / staging 用单独的、权限更低的 secret。

**绝不**把生产 DB 密码挂在仓库级 Actions secret 上。

## Agent 禁止行为

- 把 `process.env` / `os.environ` 打印到 console "debug"。
- 把 `.env` 内容塞进对话 prompt "了解环境"。
- 因 auto-commit 开着而"误"提交 `.env.local`。
- 在 `.env.example` 里填真值"让它能跑"。
- 把 `.env` 作为附件 / 粘贴发送到任何外部服务（包括 agent 自己的 API）。

## 真发生泄露怎么办

1. **立刻轮换**，先轮换再调查。
2. **审计**碰过这个凭据的 agent session。
3. **关闭受影响 agent 的工具权限**直到轮换完成。
4. **扫历史**：`git log -p -- .env*` 和
   `git log -p -G '<已知泄露前缀>'`。
5. 如果 secret 进了公开仓库 / 粘贴板，**即使轮换也按已 compromise 处理** ——
   各类服务可能已经缓存。

## 参考

- [GitHub OIDC 文档](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [OWASP Secret Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [`github-settings.zh-CN.md`](./github-settings.zh-CN.md)：本章规则
  在仓库级的配置面。
