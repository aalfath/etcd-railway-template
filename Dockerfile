# etcd v3.7.2 single node with authentication bootstrapped from environment variables.
FROM gcr.io/etcd-development/etcd:v3.7.2@sha256:7c6c239825d00e3f6328a69caafd54be92063acf0c2ce78b8394699f52b75dc3 AS etcd

FROM alpine:3.24.2
RUN apk add --no-cache tini
COPY --from=etcd /usr/local/bin/etcd /usr/local/bin/etcdctl /usr/local/bin/etcdutl /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
EXPOSE 2379
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
