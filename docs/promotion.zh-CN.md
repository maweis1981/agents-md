# 推广（针对 spec 类项目）

> 一个开源 spec 项目 —— 不管是你的还是别人的 —— 如何被读到、被采用、
> 被 star。通用打法，不针对 `agents-md` 自身。（本仓的发布材料放在
> `announce/`。）
> English: [`promotion.md`](./promotion.md)

"Spec 项目"指交付物是**文字而不是二进制**的仓库 —— 方法论文档、约定、
schema、术语表、教学资源都是。Spec 项目和工具项目的排名机制不同：
**它靠"可发现性"+"可信度"活，不靠下载量**。

## Spec 项目"成功"长啥样

| 差指标 | 好指标 |
| --- | --- |
| Star 数 | 能点名的实际采用 |
| 上 HN 首页 | 被其他项目的文档引用次数 |
| 上 Trending | 长尾 referrer 搜索词 |
| Twitter 点赞 | 陌生人贡献的翻译 |

Star 和触达相关，但**不是目标**。瞄准右边，star 会自己来。

## 四个杠杆

### 1. 命名 + Topics（免费，Day 1 就做）

- **仓库名**包含目标搜索关键词。Spec 项目就用你想标准化的那个**概念**。
- **仓库 description** 一句话讲清"做什么 + 给谁用"。
- **GitHub Topics**（上限 15 个）是 GitHub 自家搜索索引。填满 15 个用户
  会搜的词。Topic 对内搜的权重 > description。
- **README 前 200 字**是 90% 访客唯一会读的部分。让它们看完就觉得"这是给我用的"。

### 2. 分发（发布窗口）

三条渠道，按影响力排：

1. **Hacker News "Show HN"** —— 单次最大流量峰（上首页 200–5000 star）。
   周二–周四美东早上发，**周一和周末别发**。
2. **Twitter / X 长串**，tag 相关工具厂商 + 2-3 个利基领域 influencer。
   配图很重要，截一张 spec 在做事的图。
3. **Newsletter 投稿** —— swyx 的 AINews、Last Week in AI、The Sequence、
   GitHub Trends，以及对应语种的同类。一句介绍 + URL 就够，编辑会自己判断。

可选累加项：

- **dev.to / Hashnode / Medium 长文** —— 你的 spec 的"故事版"。
  套路：先讲痛点，再讲我们做了什么。中文同步发**掘金 / 公众号**，
  日文发 Qiita。
- **Reddit** 投入高、回报低、还反感推广。除非能开成讨论帖，
  否则别去 r/programming / r/devops / r/MachineLearning。
- **LinkedIn** 对平台工程受众出奇地有效，对一般开发者不行。

### 3. 复利（1–6 个月）

- **Awesome lists** 是长尾流量引擎。给 5-10 个细分领域的 `awesome-*` 列表
  提 PR 加一行。每条接受的 PR 持续带来 50-500 star/年。
- **翻译**用很小代价解锁整个新受众。日韩社区尤其喜欢早期翻译，回报特别好。
- **会议演讲 / 播客** —— 每季度投一场。每场带来 200-2000 star，
  更重要的是**可被引用**。
- **从你维护的其他项目交叉引流**。一个 5k+ star 项目的小入链，
  比大多数营销动作都强。

### 4. 防御性（6 个月+）

- **成为某个关键词的标准答案**。用户搜那个词，前 3 个结果有你。
  关键词要挑好 —— 太广打不过，太窄没流量。
- **被工具或厂商引用**。Anthropic / Cursor / Vercel / 你的厂商
  文档里提到你一次，胜过一千条推。礼貌地开 issue 提供 spec 作为参考。
- **围绕 spec 做一个小工具**，比 spec 本身更容易上手。
  **工具的 star 是文档的 5-10 倍**。工具把人拉进文档。

## 不要浪费时间的事

- 去你不参与的论坛发广告。社区一眼看出 drive-by 推广。
- 给 spec 项目买广告。Spec 是靠信任买的，不是靠曝光量。
- "嘿来看我项目"式没有 hook 的推。要有钩子 —— 视觉、数字、或一句金句。
- Cold tag 名人求转发。除非 spec 真和他们的工作相关。
- 一周发 3 个版本装活跃。别人看得出来，**几个月的一致性才赢**。

## 发布周 Checklist

发布前一天：

- [ ] 仓库 description 填好。
- [ ] 15 个 GitHub Topics 填满。
- [ ] README 前 200 字交代清楚"做什么 + 给谁用"。
- [ ] 顶部有一张 hero 图 / GIF。
- [ ] `CHANGELOG.md` 和 `VERSION` 更新到位。
- [ ] 最新一次 commit 是 release tag，不是 typo 修复。
- [ ] LICENSE 是 MIT / Apache-2.0 / CC-BY-4.0 之一（用奇怪的 license 砸自己脚）。

发布日：

- [ ] Show HN 草稿写好，另一个人帮你审过。
- [ ] Twitter 长串写好，截图嵌好。
- [ ] 3 封 newsletter 投稿邮件写好。
- [ ] Awesome-list PR 的 markdown 行写好。

发布 + 24 小时：

- [ ] Show HN 周二/三/四美东 9-10 点发。
- [ ] Twitter 长串在 Show HN 后约 2 小时发（吃 HN 流量外溢）。
- [ ] Newsletter 投稿发出。
- [ ] Awesome-list PR 开了。
- [ ] 监控 HN 评论前 4 小时，认真回复。

发布 + 1 周：

- [ ] 写一篇"发布后总结"复盘。
- [ ] 记录哪个渠道**真的**带量了（用数据，不是感觉）。
- [ ] 规划下一个版本的下一轮推广。

## 参考

- `agents-md` 自己的发布材料在 [`../announce/`](../announce/) ——
  Show HN 草稿、博客（中英）、Twitter 串、Awesome-list PR 行、
  GitHub Topics 列表。
- Patrick McKenzie 的 *On a Vague Plan to Get Famous* ——
  把推广当作长期复利、不是单次事件的经典文章。
- [`outlook.zh-CN.md`](./outlook.zh-CN.md) —— spec 一旦立住，
  你就在和未来工具链谈判。
