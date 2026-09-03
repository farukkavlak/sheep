# CLAUDE.md

Binding rules for anyone working in this repository, human or AI.

## Project

`sheep` is a multi-tenant cloud provider running on homelab hardware — IAM, object storage, compute, networking. Two goals carry equal weight: learning the mechanisms in depth, and architecture worth showing.

## Rules

**Git belongs to the owner.** Committing, branching, opening pull requests and merging them are the owner's actions alone. The assistant writes files and stops there. It never runs `git commit`, `git push`, `gh pr create`, or `gh pr merge`.

**Nothing is implemented before it is understood.** Explain the mechanism first: how it works, what the alternatives were, why this one. Libraries are not magic boxes — say what is underneath. Do not dump large blocks of code at once.

**Approve one step at a time.** GitHub settings, new dependencies, structural changes: each is proposed and confirmed separately, never in a batch.

## Architecture invariants

**Control plane and data plane are separate.** The control plane validates, authorizes, records desired state, and emits an event. It never touches hardware synchronously. The data plane — `sheep-agent` — converges reality toward that state in a reconciliation loop.

**Vertical slices.** A service is a bounded context (`iam`, `s3`, `compute`); a slice is one API action (`CreateUser`, `PutObject`). Things that change together live together.

**A shared kernel is legitimate.** Primitives under `internal/platform` — auth, store, event bus, gateway — are shared. Duplication between slices is acceptable; coupling between them is not. No slice reimplements a platform primitive.

**Dependency injection is explicit.** All wiring lives in `internal/app/app.go`, written by hand. No container. Interfaces are declared by the consumer and kept as narrow as the caller's actual need.

**Services declare themselves.** Each service exposes a `ServiceDescriptor` listing the actions it serves, the IAM permissions it defines, and the events it consumes. The gateway and IAM read that; neither keeps a central list.

**State changes and events are atomic.** Both are written in the same transaction, through the outbox.

**The line on events:** reads and validation are synchronous, state changes are asynchronous.

**The shell is dumb; modules declare themselves.** This extends *Services declare themselves* to every layer. The gateway holds no list of actions; the console shell holds no list of pages. Each unit — a backend service, a frontend feature module — exposes a descriptor (actions, permissions, events; or nav entries, routes, required permissions) and the shell composes what it is given. Adding a module touches the module and the composition root, nothing else.

**The frontend mirrors backend bounded contexts.** The first cut is the domain (`iam`, `s3`), never `frontend/` vs `backend/`. Frontend and backend live in separate trees for tooling reasons, but both are organized by context and named alike. A module is extractable when three rules hold: sibling contexts never import each other's internals — only `contract/` and `internal/platform`; the contract is an explicit versioned artifact; each context owns its own storage.

## Language

All code, comments, documentation, commit messages and issues are written in English. Prose is short and technical. No filler, no hedging, no restating the obvious.

## Conventions

Branch names, commit format, PR structure, ADRs and learning notes: [`CONTRIBUTING.md`](CONTRIBUTING.md).

Architecture lives in `docs/architecture.md`, decisions in `docs/adr/`, milestone write-ups in `docs/learning/`. When an architectural decision changes, the ADR is written before the code.
