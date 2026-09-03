# Contributing

## Workflow

Every change starts as an issue and lands as a pull request. `main` is protected: no direct pushes, no merge without green CI.

Issues are tracked on the project board. `area/*` and `type/*` labels classify them; milestones group them by release.

## Branches

```
<type>/<issue>-<slug>
```

`feat/12-outbox-relay`, `fix/31-tenant-scope-leak`, `docs/3-adr-vertical-slice`

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`. Slug is two to four words, lowercase, hyphenated. One issue per branch.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>
```

```
feat(platform/events): add transactional outbox relay
fix(iam): scope policy lookup to the requesting tenant
docs(adr): record the explicit DI decision
```

Scope is the package or service the change belongs to — `platform/store`, `iam`, `s3`, `ci`. Omit it when the change is repo-wide.

Subject is imperative, lowercase, no trailing period, 72 characters or fewer. Write what the commit does, not what you did: `add outbox relay`, not `added outbox relay`.

Body is optional and explains *why*, not *what*. The diff already says what.

## Pull requests

**The PR title is the commit message.** We squash-merge, so the title becomes the single commit on `main` and must follow the commit format exactly.

The body covers four things:

- **Summary** — one or two sentences.
- **Why** — the problem, or a link to the issue that states it.
- **What I learned** — the mechanism this PR taught. Required; it is half the point of this project.
- **Verification** — how you proved it works.

Close the issue from the body: `Closes #12`.

One logical change per PR. If the title needs an "and", split it.

## Merging

Squash only. Branches are deleted on merge. History on `main` stays linear, one commit per PR, each traceable to an issue.

## Architecture decisions

Anything that constrains future code gets an ADR before the code lands:

```
docs/adr/0007-transactional-outbox.md
```

Numbers are sequential and never reused. An ADR states the context, the decision, the reasons, and the consequences — including the ones we dislike. Only decisions we took are written down, so there is no status field. Superseding an ADR means writing a new one and adding one line to the old: `Superseded by 0012.`

## Learning notes

Each milestone closes with a note in `docs/learning/`, named `m02-object-storage.md`. It records the mechanism, not the code: how multipart upload actually works, why the outbox needs a relay, what a tap device is. These are written for a reader who has not seen the codebase.

## Code

Go, latest stable. Standard library `net/http` for routing; no web framework.

Interfaces are declared by the consumer and kept narrow — one or two methods. A slice that needs to write a user declares `userWriter`, not a shared `UserRepository`.

Wrap errors with context: `fmt.Errorf("load tenant %s: %w", id, err)`. Panic only on programmer error.

Log with `log/slog`, structured, request ID on every line.

Tests are table-driven. New behavior ships with tests.

Comments explain why, not what. If a comment restates the line below it, delete it.
