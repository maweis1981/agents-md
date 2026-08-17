# GitHub Issues and Projects Workflow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a public, bilingual, platform-neutral standard that tells AI agents and human teams how to manage development work with GitHub Issues and Projects.

**Architecture:** Keep `STANDARDS.md` and `STANDARDS.zh-CN.md` canonical, publish the same guidance as a standalone bilingual chapter under `docs/`, and add concise enforcement pointers to agent entry templates. Update navigation and changelog metadata without introducing runtime tooling.

**Tech Stack:** Markdown, shell-based bilingual symmetry check, shell-based internal-link check, Git.

---

### Task 1: Add the standalone English workflow chapter

**Files:**
- Create: `docs/github-issues-projects.md`

**Step 1: Draft the normative structure**

Create sections for scope, system of record, repository ownership, cross-repository work, fields, lifecycle, Definition of Ready, Definition of Done, WIP, iterations, automation, agent authority, and checklists.

Use RFC-style language consistently:

```markdown
An agent MUST find or create a tracking issue before material implementation work.
An agent MUST NOT change Priority, Iteration, Target date, acceptance criteria, or scope when that would create a new product commitment without human authority.
```

**Step 2: Add neutral examples**

Use only generic repositories:

```text
Parent feature
├── service-api: contract and persistence
├── web-client: browser experience
├── ios-client: iOS experience
└── android-client: Android experience
```

**Step 3: Review for duplication and conflicts**

Confirm the PR rules reference the existing pull-request standard instead of redefining branching, commit, or merge policy.

**Step 4: Commit**

```bash
git add docs/github-issues-projects.md
git commit -m "docs: add GitHub Issues and Projects workflow"
```

### Task 2: Add the Chinese counterpart

**Files:**
- Create: `docs/github-issues-projects.zh-CN.md`

**Step 1: Translate the complete chapter**

Preserve section order, examples, tables, MUST/MUST NOT strength, and links. Translate prose naturally rather than mechanically.

**Step 2: Compare semantic symmetry**

Check that both documents contain equivalent lifecycle, authority-boundary, and checklist rules.

**Step 3: Run bilingual validation**

Run:

```bash
./scripts/check-bilingual.sh
```

Expected: the new English/Chinese pair is accepted and no existing pair fails.

**Step 4: Commit**

```bash
git add docs/github-issues-projects.zh-CN.md
git commit -m "docs(zh-CN): add GitHub Issues and Projects workflow"
```

### Task 3: Integrate the canonical single-file standards

**Files:**
- Modify: `STANDARDS.md`
- Modify: `STANDARDS.zh-CN.md`

**Step 1: Add the English canonical chapter**

Append the normative chapter using the next section number. Keep all mandatory lifecycle and agent-authority rules in the canonical file; link to `docs/github-issues-projects.md` for expanded operational examples.

**Step 2: Add the Chinese canonical chapter**

Mirror the English section in `STANDARDS.zh-CN.md` with equivalent strength and structure.

**Step 3: Check numbering and cross-references**

Search:

```bash
rg -n '^## |^### ' STANDARDS.md STANDARDS.zh-CN.md
```

Expected: sequential top-level sections and corresponding bilingual content.

**Step 4: Commit**

```bash
git add STANDARDS.md STANDARDS.zh-CN.md
git commit -m "docs: standardize issue and project tracking"
```

### Task 4: Add agent entry-point enforcement

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `templates/AGENTS.md`
- Modify: `templates/CLAUDE.md`

**Step 1: Add concise mandatory rules**

Add a short tracking section that requires an issue before material work, repository ownership, cross-repository sub-issues, linked PRs, accurate status updates, and human approval for new planning commitments.

**Step 2: Link to canonical guidance**

Root files link to `STANDARDS.md` and `docs/github-issues-projects.md`. Templates link to the vendored standard path they already expect; do not copy the full chapter.

**Step 3: Compare agent entry points**

Run:

```bash
diff -u <(sed 's/CLAUDE.md/AGENTS.md/g' CLAUDE.md) AGENTS.md || true
```

Expected: only intentional agent-specific wording differs.

**Step 4: Commit**

```bash
git add AGENTS.md CLAUDE.md templates/AGENTS.md templates/CLAUDE.md
git commit -m "docs: enforce issue tracking in agent entry points"
```

### Task 5: Update discovery and release notes

**Files:**
- Modify: `docs/README.md`
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `CHANGELOG.md`

**Step 1: Add chapter navigation**

Add the new bilingual chapter to `docs/README.md` in the workflow or collaboration section.

**Step 2: Update bilingual repository overviews**

Mention GitHub Issues and Projects workflow coverage in the feature summary without expanding the README into a duplicate specification.

**Step 3: Add an Unreleased changelog entry**

Document the bilingual workflow chapter, canonical rules, and agent-entry enforcement.

**Step 4: Commit**

```bash
git add docs/README.md README.md README.zh-CN.md CHANGELOG.md
git commit -m "docs: link issue and project workflow guidance"
```

### Task 6: Validate the complete documentation set

**Files:**
- Review: all modified Markdown files

**Step 1: Run bilingual checks**

Run:

```bash
./scripts/check-bilingual.sh
```

Expected: PASS.

**Step 2: Run internal-link checks**

Run:

```bash
./scripts/check-links.sh
```

Expected: PASS.

**Step 3: Check for product-specific identifiers**

Run:

```bash
rg -ni 'hanakoi|mira-gift-hq|maweis1981' \
  docs/github-issues-projects.md \
  docs/github-issues-projects.zh-CN.md \
  STANDARDS.md STANDARDS.zh-CN.md \
  AGENTS.md CLAUDE.md templates/AGENTS.md templates/CLAUDE.md
```

Expected: no matches in newly added normative content. Existing repository metadata outside the new content is not in scope.

**Step 4: Inspect the final diff**

Run:

```bash
git diff main...HEAD --check
git diff main...HEAD --stat
```

Expected: no whitespace errors; only documentation, plans, and navigation files changed.

**Step 5: Commit any validation fixes**

```bash
git add <fixed-files>
git commit -m "docs: fix workflow documentation validation"
```

Skip the commit when validation required no fixes.

### Task 7: Publish for review

**Files:**
- Review: branch history and working tree

**Step 1: Confirm repository state**

Run:

```bash
git status --short
git log --oneline main..HEAD
```

Expected: clean tree and logical documentation commits.

**Step 2: Push the feature branch**

```bash
git push -u origin ai/github-projects-workflow
```

Expected: branch published without modifying `main`.

**Step 3: Open a draft pull request**

Create a draft PR that summarizes the public workflow standard, lists bilingual validation results, and notes that examples are platform-neutral.
