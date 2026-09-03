# 0002 — Vertical slices over layers

## Context

sheep will hold many services and many actions per service. The code has to be
organized so that adding an action is a local change.

The common alternative is layers: `handlers/`, `services/`, `repositories/`,
`models/`. Adding one action then touches four directories, and each directory
grows into a shared surface that every feature depends on.

## Decision

Organize by vertical slice.

A service is a bounded context. A slice is one API action, and owns its input
type, validation, handler, state change and event.

```
internal/services/iam/features/createuser/
```

## Reasons

Things that change together live together. A change to `CreateUser` is one
directory, and the diff shows the whole feature.

Slices do not share types with each other, so one slice cannot break another by
changing a struct.

Deleting a feature is deleting a directory.

## Consequences

Slices repeat code. Two slices will write similar validation and similar
mapping. This is accepted; the duplicated code is short and each copy is free
to change on its own.

There is a constant temptation to promote repeated code into a shared package.
Code moves into `internal/platform` only when it is a platform concern, never
because it appeared twice.

Cross-slice reads need an explicit contract instead of a shared repository. A
slice that needs another context's data calls it through `contract/`.
