# Architecture

## Two planes

The **control plane** serves the API. It authenticates the request, authorizes
it, validates the input, writes the desired state, and emits an event. It never
touches hardware. A request to run a virtual machine returns `pending`.

The **data plane** is `sheep-agent`, one process per node. It reads desired
state and converges reality toward it: boots the VM, opens the tap device,
writes the object to disk. It runs in a loop, retries on failure, and reports
what it observed.

They are separated because they have different failure models. The control
plane is a database application: transactional and fast. The data plane is a
control loop over hardware: slow and unreliable. Mixed together, the API blocks
on kernel calls and the loop cannot retry, because it also owns the HTTP
response.

## Contexts and slices

A **service** is a bounded context: `iam`, `storage`, `compute`, `vpc`. The
test is whether it could be a separate product, with its own users and its own
reason to change.

A **slice** is one API action: `CreateUser`, `PutObject`. A slice owns its input
type, validation, handler, state change and event. Adding an action touches one
directory.

Sibling contexts never import each other's internals. They share two things:
`contract/` and the platform.

## The platform

`internal/platform` holds what every context needs and none should own:
configuration, telemetry, the store, the outbox, the registry, the gateway.

Duplication between slices is accepted. Coupling is not. Code is not moved into
the platform because it repeats, only because it is a platform concern.

## The wire

Control plane actions are addressed by name:

```http
POST / HTTP/1.1
X-Sheep-Target: iam.CreateUser
Content-Type: application/json

{"userName": "faruk"}
```

HTTP is the transport. The method and path carry no meaning; the action name
carries all of it.

This follows from self-declaration. A service declares one name per action, and
routing, the IAM permission and the event type derive from it. REST would need
three names — method and path, permission, handler — kept in step by hand.

The protocol is chosen per service, as at AWS: DynamoDB addresses actions by
name, S3 is REST. A service carrying byte streams will be REST, decided in its
own ADR. The registry contract must not assume the shape of HTTP, so a second
protocol is an addition and not a rewrite.

## A request, end to end

Every abstraction in the platform must map to a step below. One that maps to
nothing is a guess.

1. **Middleware.** Generate a request ID, put it on the context. Logging, panic
   recovery and a timeout wrap everything below.
2. **Routing.** The gateway maps the action name to a handler. The table is
   built at startup from service descriptors. The gateway imports no service.
3. **Authentication.** Verify the request signature, produce a principal.
4. **Decoding.** Decode the body into the slice's input type and validate it. A
   malformed request ends here, before the database.
5. **Authorization.** Evaluate `(principal, action, resource, context)` against
   the applicable policies. Pure function, no I/O.
6. **Transaction.** One transaction: check invariants, write the `users` row,
   append a row to `outbox`.
7. **Response.** Commit, then return a result or a typed error.
8. **Relay.** A goroutine drains `outbox`, hands each event to the dispatcher
   and marks the row done. Outside the request path, at-least-once.

Steps 3 and 5 arrive with IAM. The rest is M0.

## What the trace does not produce

Recorded so they are not added by habit:

- **No authorization interface yet.** Step 5 has no caller until IAM exists.
  The signature would be a guess.
- **No generic repository.** A slice that writes a user declares `userWriter`
  with one method, not a shared `UserRepository` with twelve.
- **No topics or subscriptions.** The trace asks for two things: write the
  event, move the event.

## Wiring

Dependencies are constructed by hand in `internal/app/app.go`. No container, no
reflection, no struct tags. One file knows the whole graph and can be read top
to bottom.

Constructors take what they need as arguments and return concrete types.
Interfaces are declared where they are consumed.
