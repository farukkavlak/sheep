# 0001 — Go for the control plane and agent

## Context

sheep needs one language for the API and one for the node agent. The agent
makes syscalls: netlink for networking, KVM and libvirt for virtual machines,
tap devices, filesystem I/O. It is deployed to every node in the cluster.

The candidates were Go and TypeScript on Node.

## Decision

Go, for both the control plane and the agent.

TypeScript stays for the console.

## Reasons

The agent needs mature bindings for libvirt, netlink and nftables. Go has them;
Node reaches the same places through native addons or by shelling out.

The agent ships as a single static binary with no runtime to install. Deploying
it is a file copy. A Node agent needs Node on every node.

Go is the language of the ecosystem sheep imitates: Kubernetes, Docker,
Terraform, etcd. Reading their source is part of the work.

## Consequences

Two languages instead of one. Types are defined in Go and generated for
TypeScript from `contract/`, which is a build step we now have to maintain.

Go is unfamiliar to the author. Early pull requests will be slower, and some
early code will be rewritten once the idioms are clear.

Go has no generics-heavy abstractions and no exceptions. Error handling is
explicit and verbose. This is a cost on every function and a benefit at every
call site.
