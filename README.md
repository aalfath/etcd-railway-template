# Deploy and Host etcd on Railway

etcd is the strongly consistent, distributed key-value store behind Kubernetes. Applications use it for configuration, service discovery, leader election and distributed locks, reading and writing keys through a gRPC API with watches, leases and transactions. Client libraries exist for Go, Python, Java, Node.js, Rust and more.

## About Hosting etcd

This template deploys etcd v3.7.2 as a single node from a small public wrapper image that builds on the official release, pinned by digest. On first boot the wrapper creates the `root` user with a generated password and enables authentication, so the server is never open. Data is stored on a Railway volume with hourly auto-compaction and a 2 GB backend quota. Services connect over the private network on port 2379, and external clients use the Railway TCP proxy. A single node gives no fault tolerance, but it suits development and small production setups on the Hobby plan.

## Common Use Cases

- Configuration and feature switches watched by several services
- Distributed locks and leader election for workers
- Service discovery and coordination for self-hosted platforms

## Dependencies for etcd Hosting

- `aalfath/etcd-railway-template` (public wrapper around `gcr.io/etcd-development/etcd:v3.7.2`)
- A Railway volume at `/etcd-data`
- A Railway TCP proxy for external clients

### Deployment Dependencies

- [etcd documentation](https://etcd.io/docs/v3.7/)
- [etcd v3.7.2 release](https://github.com/etcd-io/etcd/releases/tag/v3.7.2)
- [Wrapper repository](https://github.com/aalfath/etcd-railway-template)
- [Railway TCP proxy](https://docs.railway.com/reference/tcp-proxy)

### Implementation Details

| Service | Source | Networking | Storage |
| --- | --- | --- | --- |
| etcd | `aalfath/etcd-railway-template` | private 2379; TCP proxy to 2379 | volume at `/etcd-data` |

```bash
etcdctl --endpoints "$ETCD_PUBLIC_ENDPOINT" --user "root:$ETCD_ROOT_PASSWORD" put /config/mode blue
etcdctl --endpoints "$ETCD_PUBLIC_ENDPOINT" --user "root:$ETCD_ROOT_PASSWORD" watch /config --prefix
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `ETCD_ROOT_PASSWORD` | generated | Password for the `root` user, set on first boot |
| `ETCD_ENDPOINT` / `ETCD_PUBLIC_ENDPOINT` | private / TCP proxy | Client endpoints |
| Any `ETCD_*` | wrapper defaults | Standard etcd settings override the defaults |

Notes:

- Changing `ETCD_ROOT_PASSWORD` after the first boot does not change the password; use `etcdctl user passwd root`.
- Traffic is plain HTTP without TLS; prefer the private network.

This is a community-maintained deployment package and does not imply affiliation with or endorsement by the etcd project or its maintainers.

## Why Deploy etcd on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying etcd on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
