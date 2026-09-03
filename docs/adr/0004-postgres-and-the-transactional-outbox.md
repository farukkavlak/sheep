# 0004 — Postgres and the transactional outbox

## Context

The control plane writes state and emits an event about it. These are two
systems: a database and a message bus. Writing to both is a dual write, and a
crash between them either loses the event or publishes one for a state change
that rolled back.

## Decision

PostgreSQL for state, and the transactional outbox pattern for events.

The event is written as a row in an `outbox` table inside the same transaction
as the state change. A relay reads that table, hands events to the dispatcher,
and marks rows done.

## Reasons

One transaction covers both writes, so the state change and its event cannot
disagree.

There is no separate broker to run. The relay is a goroutine, and the
dispatcher is in-process for now. Both can be replaced with a real broker
without changing how slices publish.

Postgres also carries the rest of what the control plane needs: relational
tenant isolation, and JSONB for IAM policy documents.

## Consequences

Delivery is at-least-once. The relay can crash after dispatching and before
marking the row, so an event can be delivered twice. Every consumer must be
idempotent.

Events are ordered per transaction, not globally.

The relay is a moving part that has to be operated: it can fall behind, and it
needs a way to handle rows that repeatedly fail.

Polling adds latency between commit and dispatch. Postgres `LISTEN`/`NOTIFY`
can reduce it later; it is not needed to be correct.
