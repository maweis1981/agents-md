# Announce — repo-specific launch materials

> Drafts of the launch posts, threads, and PR snippets for promoting
> **this repo** (`agents-md`). For the *generic* playbook, see
> [`../docs/promotion.md`](../docs/promotion.md).

These files are not part of the spec. They're working materials for
the maintainers — copy into the actual destination (HN, Twitter,
dev.to, GitHub awesome-lists) and tweak as needed.

## Contents

| File | Where it goes | When |
| --- | --- | --- |
| [`show-hn.md`](./show-hn.md) | https://news.ycombinator.com/submit | Tue/Wed/Thu 9–10am EST |
| [`twitter-thread.md`](./twitter-thread.md) | Twitter / X | ~2 hours after HN posts |
| [`blog-post.md`](./blog-post.md) | dev.to / Hashnode / Medium / your blog | Same day, English audiences |
| [`blog-post.zh-CN.md`](./blog-post.zh-CN.md) | 掘金 / InfoQ / 公众号 / 知乎 | Same day, Chinese audiences |
| [`awesome-lists.md`](./awesome-lists.md) | PRs to `awesome-*` repos | Within a week |
| [`github-topics.md`](./github-topics.md) | Repo settings → Topics | Before launch |

## Order of operations on launch day

```
T-1 day:
  fill GitHub Topics from github-topics.md
  tag v0.2.0 (done via Release UI)

T+0:
  09:30 EST  post Show HN (show-hn.md)
  11:30 EST  post Twitter thread (twitter-thread.md)
  13:00 EST  publish dev.to / Medium (blog-post.md)
  13:30 EST  publish 掘金 / 公众号 (blog-post.zh-CN.md)

T+1 to T+5:
  open one awesome-list PR per day (awesome-lists.md)
```

## After launch

- Watch HN comments for the first 4 hours. Reply to every top-level
  comment. Don't argue; thank, agree where you can, explain where
  you can't.
- Note which referrers in GitHub Insights actually delivered traffic.
- One week after launch, write the "what worked" recap — it becomes
  useful material for the *next* launch.

## Notes

These drafts are written for the **v0.2.0** moment. Reuse the
structure for v0.3.0+ by swapping the version, the new chapters
list, and any new numbers from the case study.
