#!/bin/sh
set -eu

: "${ETCD_ROOT_PASSWORD:?set ETCD_ROOT_PASSWORD}"

# Single-node defaults; any ETCD_* variable set on the service wins.
export ETCD_NAME="${ETCD_NAME:-etcd-1}"
export ETCD_DATA_DIR="${ETCD_DATA_DIR:-/etcd-data}"
export ETCD_LISTEN_CLIENT_URLS="${ETCD_LISTEN_CLIENT_URLS:-http://[::]:2379}"
export ETCD_ADVERTISE_CLIENT_URLS="${ETCD_ADVERTISE_CLIENT_URLS:-http://127.0.0.1:2379}"
export ETCD_LISTEN_PEER_URLS="${ETCD_LISTEN_PEER_URLS:-http://127.0.0.1:2380}"
export ETCD_INITIAL_ADVERTISE_PEER_URLS="${ETCD_INITIAL_ADVERTISE_PEER_URLS:-http://127.0.0.1:2380}"
export ETCD_INITIAL_CLUSTER="${ETCD_INITIAL_CLUSTER:-$ETCD_NAME=http://127.0.0.1:2380}"
export ETCD_AUTO_COMPACTION_MODE="${ETCD_AUTO_COMPACTION_MODE:-periodic}"
export ETCD_AUTO_COMPACTION_RETENTION="${ETCD_AUTO_COMPACTION_RETENTION:-1h}"
export ETCD_QUOTA_BACKEND_BYTES="${ETCD_QUOTA_BACKEND_BYTES:-2147483648}"

etcd &
pid=$!
trap 'kill -TERM "$pid"' TERM INT

export ETCDCTL_ENDPOINTS=http://127.0.0.1:2379
until etcdctl endpoint health >/dev/null 2>&1; do
  kill -0 "$pid" 2>/dev/null || exit 1
  sleep 1
done

# First boot: create the root user and turn authentication on.
if ! etcdctl --user "root:$ETCD_ROOT_PASSWORD" auth status 2>/dev/null | grep -q "Authentication Status: true"; then
  if etcdctl user get root >/dev/null 2>&1; then :; else
    etcdctl user add "root:$ETCD_ROOT_PASSWORD" --interactive=false >/dev/null
  fi
  etcdctl user grant-role root root >/dev/null 2>&1 || true
  etcdctl auth enable
fi

wait "$pid"
