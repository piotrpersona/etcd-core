# etcd-core
Core concepts of etcd

---
# etcd

is an open-source distributed key value store
that provides shared configuration and service discovery for Container Linux clusters.

---
# etcd

runs on each machine in a cluster and gracefully handles leader election
during network partitions and the loss of the current leader.

---
# According to Github

etcd is a distributed reliable key-value store for the most critical data of a distributed system,
with a focus on being:

* Simple: well-defined, user-facing API (gRPC)
* Secure: automatic TLS with optional client cert authentication
* Fast: benchmarked 10,000 writes/sec
* Reliable: properly distributed using Raft algorithm

---
# Container Linux

redefines the operating system as a smaller, more compact Linux distribution.
Traditional distros package unused software that leads to dependency conflicts and needlessly increases the attack surface.

Container Linux provides three essential tools:
* container management
* process management
* service discovery (done with **etcd**)

---
# Use case

Store:
* dbs connections
* cache settings
* feature flags

---
# Used by

* kubernetes
* OpenTable
* Huawei
* locksmith
* vulcand

---
# Raft consensus algorithm

Visualisation: https://raft.github.io/

---
# Configure etcd

```yaml
# This config is meant to be consumed by the config transpiler, which will
# generate the corresponding Ignition config. Do not pass this config directly
# to instances of Container Linux.

etcd:
  name:                        my-etcd-1
  listen_client_urls:          https://10.240.0.1:2379
  advertise_client_urls:       https://10.240.0.1:2379
  listen_peer_urls:            https://10.240.0.1:2380
  initial_advertise_peer_urls: https://10.240.0.1:2380
  initial_cluster:             my-etcd-1=https://10.240.0.1:2380,my-etcd-2=https://10.240.0.2:2380,my-etcd-3=https://10.240.0.3:2380
  initial_cluster_token:       my-etcd-token
  initial_cluster_state:       new
```

---
# API

* HTTP-based
* etcdctl
* http client (curl, wget, postman...)

---
# etcd write

Set a key `message` with value `Hello` can be done as:

```bash
$ etcdctl set /message Hello
Hello
```

or

```json
$ curl -X PUT http://127.0.0.1:2379/v2/keys/message -d value="Hello"
{
  "action": "set",
  "node": {
    "key": "/message",
    "value": "Hello",
    "modifiedIndex": 4,
    "createdIndex": 4
  }
}
```

---
# etcd read

Read the value of message back:

```bash
$ etcdctl get /message
Hello
```

or 

```json
$ curl http://127.0.0.1:2379/v2/keys/message
{
  "action": "get",
  "node": {
    "key": "/message",
    "value": "Hello",
    "modifiedIndex": 4,
    "createdIndex": 4
  }
}
```

---
# etcd delete

```bash
$ etcdctl rm /message
```

or

```json
$ curl -X DELETE http://127.0.0.1:2379/v2/keys/message
{
  "action": "delete",
  "node": {
    "key": "/message",
    "modifiedIndex": 19,
    "createdIndex": 4
  }
}
```

---
# TTL

```json
$ curl -X PUT http://127.0.0.1:2379/v2/keys/foo?ttl=20 -d value=bar
{
  "action": "set",
  "node": {
    "key": "/foo",
    "value": "bar",
    "expiration": "2014-02-10T19:54:49.357382223Z",
    "ttl": 20,
    "modifiedIndex": 31,
    "createdIndex" :31
  }
}
```

```json
$ curl http://127.0.0.1:2379/v2/keys/foo
{
  "errorCode": 100,
  "message": "Key not found",
  "cause": "/foo",
  "index": 32
}
```
