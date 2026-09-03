# sheep

A multi-tenant cloud provider for homelab hardware.

Cloud is someone else's computer. What makes it a cloud is the layer above it — the software that turns bare machines into rentable, isolated, accountable resources. sheep builds that layer from scratch: IAM, object storage, compute, networking, on hardware you own.

**Status:** early. M0, laying foundations. Nothing runs yet.

## Architecture

Two planes.

The **control plane** serves the API. It validates a request, authorizes it against IAM, records the desired state, and emits an event. It never touches hardware synchronously — it answers `pending`.

The **data plane** is `sheep-agent`, one per node. It reads desired state and converges reality toward it: boots the VM, opens the tap device, writes the object to disk.

Code is organized as vertical slices. A service is a bounded context (`iam`, `s3`); a slice is one API action (`CreateUser`, `PutObject`). Shared primitives — auth, store, event bus, gateway — live in `internal/platform`. Dependencies are wired by hand in a single composition root. There is no DI container.

See [`docs/architecture.md`](docs/architecture.md) for the full picture and [`docs/adr/`](docs/adr/) for the decisions behind it.

## Stack

Go for the control plane and agent. PostgreSQL for state and the transactional outbox. KVM/libvirt for compute. TypeScript and React for the console.

## Current milestone

**M0 — Foundation.** The platform skeleton every service will sit on: configuration, structured logging, the Postgres store, a transactional outbox, the service registry, and the HTTP gateway. It ends when `/healthz` is served by a real service module and an integration test proves that a state change and its event are written atomically.

The milestone after this one is planned when this one lands. The horizon it aims at is a thin vertical slice — authenticate against sheep and store a file on your own hardware, with authorization actually enforced — but nothing beyond M0 is committed to yet.

## Contributing

Conventions and workflow: [`CONTRIBUTING.md`](CONTRIBUTING.md).
