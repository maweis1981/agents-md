# Promotion (for spec projects)

> How an open-source spec project — yours or someone else's — gets
> read, adopted, and starred. Generic playbook, not specific to
> `agents-md`. (Repo-specific announce materials live under `announce/`.)
> 中文：[`promotion.zh-CN.md`](./promotion.zh-CN.md)

A "spec project" is a repo whose deliverable is words, not a binary
— this includes methodology docs, conventions, schemas, glossaries,
and educational resources. Spec projects rank differently from
tools: they survive on **discoverability** + **credibility**, not
download counts.

This chapter is the playbook the repo's maintainers used (or, if
you're looking at it before launch, the playbook they intend to
follow). Copy and adapt for your own project.

## What "success" looks like for a spec

| Bad metric | Better metric |
| --- | --- |
| Stars | Adoptions you can name |
| HN front page | Times it's cited in someone else's docs |
| Trending tab | Long-tail referrer search terms |
| Twitter likes | Translations contributed by strangers |

Stars correlate with reach, but they aren't the goal. Aim for the
right side; stars often follow.

## The four levers

### 1. Naming + Topics (free, do this on day 1)

- **Repo name** should contain the keyword people would search for.
  Spec project: the *concept* you're standardizing.
- **Repo description** should pitch in one sentence — what + who for.
- **GitHub Topics** (15 max) is GitHub's own search index. Fill all
  15 with terms people search. Topic value > description value for
  GitHub-internal search.
- **README's first 200 words** is the only part 90% of visitors
  read. Make them say "this is for me".

### 2. Distribution (the launch window)

Three channels, in order of impact:

1. **Hacker News "Show HN"** — single biggest spike (200–5000 stars
   if it lands on the front page). Choose Tue–Thu morning EST,
   avoid Mondays and weekends.
2. **Twitter / X long thread**, tagged to relevant vendors (the
   tools you support) and 2–3 influencers in the niche. Visuals
   matter; embed a screenshot of the spec doing something useful.
3. **Newsletter pitches** — `swyx`'s AINews, Last Week in AI, The
   Sequence, GitHub Trends, and language-specific equivalents.
   One line of intro + the URL is enough; editors will judge the
   repo.

Optional but cumulative:

- **dev.to / Hashnode / Medium long-form** — the "story version" of
  your spec. Frame it as "here's the pain we hit, here's what we
  built". Cross-post to platform-specific places (掘金 / 公众号 for
  Chinese, Qiita for Japanese).
- **Reddit** is high-effort, low-yield, and hostile to promotion.
  Only attempt in r/programming / r/devops / r/MachineLearning if
  you can frame as discussion.
- **LinkedIn** is surprisingly effective for platform-engineering
  audiences. Less effective for general-developer audiences.

### 3. Compounding (months 1–6)

- **Awesome lists** are the long-tail traffic engine. PR a
  one-line entry into 5–10 `awesome-*` lists in your niche.
  Each accepted PR yields ~50–500 stars/year, indefinitely.
- **Translations** unlock entire new audiences with very little
  effort. JP and KR communities especially reward early translation
  with disproportionate engagement.
- **Conference talks / podcast appearances** — pitch one talk per
  quarter. Each gives 200–2000 stars and, more importantly,
  cite-ability.
- **Cross-link** from related projects you maintain. A small inbound
  link from a high-traffic project (5k+ stars) outperforms most
  marketing.

### 4. Defensibility (months 6+)

- **Become the canonical answer for one keyword**. People
  searching that keyword should find you in the first 3 results.
  Pick the keyword carefully — too broad = unwinnable; too narrow =
  no traffic.
- **Get cited by a tool or vendor**. One mention in Anthropic /
  Cursor / Vercel / your-vendor's docs is worth a thousand tweets.
  Open polite issues offering the spec as a reference.
- **Build a tiny tool around the spec** that's easier to adopt than
  the spec itself. Tools attract 5–10× the stars docs do. The tool
  drags people into the docs.

## What doesn't work (don't waste time)

- Posting on forums you don't participate in. Communities sniff out
  drive-by promotion.
- Buying ads for a spec project. Spec projects are bought by trust,
  not impression count.
- "Hey check out my project" tweets without a hook (visual, number,
  or quote).
- Tagging celebrities to "ask for a retweet" cold. Tag them only
  if the spec is genuinely relevant to their work.
- Releasing 3 versions in one week to seem active. People notice;
  consistency over months wins.

## The launch-week checklist

Day before launch:

- [ ] Repo description filled in.
- [ ] All 15 GitHub Topics filled.
- [ ] README first-200-words says what + who for.
- [ ] One hero image / GIF visible at the top.
- [ ] `CHANGELOG.md` and `VERSION` updated.
- [ ] Latest commit is the release tag, not a typo-fix.
- [ ] LICENSE is one of MIT / Apache-2.0 / CC-BY-4.0 (anything
      exotic kills adoption).

Day of launch:

- [ ] Show HN post drafted and reviewed by one other person.
- [ ] Twitter thread drafted, screenshots embedded.
- [ ] 3 newsletter pitch emails drafted.
- [ ] Awesome-list PR markdown lines drafted.

Launch + 24 hours:

- [ ] Show HN posted Tue/Wed/Thu 9–10am EST.
- [ ] Twitter thread posted ~2 hours after Show HN (catch HN
      traffic spillover).
- [ ] Newsletter pitches sent.
- [ ] Awesome-list PRs opened.
- [ ] Monitor HN comments for the first 4 hours; reply thoughtfully.

Launch + 1 week:

- [ ] Write the "what we learned from launch" follow-up.
- [ ] Note which channels actually delivered (data, not vibes).
- [ ] Plan the next promotion cycle for the next release.

## Reference

- The `agents-md` repo's own launch materials are in
  [`../announce/`](../announce/) — show-hn draft, blog post (EN +
  zh-CN), Twitter thread, awesome-list PR lines, GitHub Topics list.
- Patrick McKenzie's *On a Vague Plan to Get Famous* — the canonical
  essay on promotion as a long compound, not a single event.
- [`outlook.md`](./outlook.md) — once the spec is established, you're
  effectively negotiating with the future of the tooling.
