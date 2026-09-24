# etcd on Railway

etcd v3.7.2 packaged for Railway: the official binaries on Alpine with an entrypoint that runs a single node, and on first start creates the `root` user from `ETCD_ROOT_PASSWORD` and enables authentication. Any `ETCD_*` variable overrides the defaults.

The full template overview is published on the Railway marketplace.
