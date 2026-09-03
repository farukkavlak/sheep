# 0003 — Explicit composition root over a DI container

## Context

Every service, handler and platform primitive has to be constructed and
connected. Three options were considered: writing the wiring by hand,
`uber-go/fx` (runtime container, reflection), and `google/wire` (code
generator).

## Decision

Write the wiring by hand in `internal/app/app.go`.

## Reasons

The dependency graph is readable as ordinary code. There is no framework to
learn before understanding how the program starts.

Errors appear at compile time. A missing dependency is a build failure, not a
panic during startup.

The decision is reversible. Hand-written wiring is the shape `wire` generates,
so moving to `wire` later is mechanical. Moving away from `fx` is not: once
components take container-managed lifecycles, the container is load-bearing.

## Consequences

`app.go` grows with the system. It will be long, and every new dependency is a
manual edit.

Constructor order is our problem. Changing it is a compile error rather than a
runtime one, but it is still ours to maintain.

If `app.go` becomes unreadable, that is the signal to reconsider `wire` — not a
reason to hide the graph behind reflection.
