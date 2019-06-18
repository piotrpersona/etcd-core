## etcd

Core concepts of etcd

> The following document is meant to be presented using [mark.show](https://mark.show/#/) - Markdown visualisation tool.

---
## agenda

1. Microservices
2. Service discovery
3. etcd architecture
4. Leader election
5. etcd API

---
## Microservices

---
### microservices

* Approach of designing and running software to achieve high availability of a service

* Each service has single responsibility

* Each service should be easily scaled

* Each service should run in a distributed fashion

* Each service should be portable

---
### scalability

* database scalability - data flow synchronization
* server scalability - 12 factor applications pricinples

---
### container

* A standardized unit of software

* It contains only required dependencies

* More lightweight than a Virtual Machine

* Portable

* Backed by container engine such as: docker, rkt

* Managed by orchestration tools such as kubernetes

---
### service

Set of instances serving single resource.

For instance:
* MongoDB cluster
* Web server cluster

---
## Service discovery

---
### service discovery

Discovering service facts such as: IP Address, port required to communicate with a service.

The basic idea behind service discovery is for each new instance of a service (or an application) to be able to identify its current environment and store that information.

---
### service discovery flow

Provider - consumer example

1. Deploy provider - store it's environment in registry.
1. Consumer requests registry to *discover* a provider.
1. Proxy service will expose a provider with fixed address and redirect all requests from consumer.

---
### service discovery registry

Since the discovery is often used in distributed system, registry needs to be scalable, fault tolerant and distributed among all nodes in the cluster.

---
### etcd

is an open-source distributed key value store
that provides shared configuration and service discovery for Container Linux clusters.

---
### etcd

runs on each machine in a cluster and gracefully handles leader election
during network partitions and the loss of the current leader.

---
### According to Github

etcd is a distributed reliable key-value store for the most critical data of a distributed system,
with a focus on being:

* Simple: well-defined, user-facing API (gRPC)
* Secure: automatic TLS with optional client cert authentication
* Fast: benchmarked 10,000 writes/sec
* Reliable: properly distributed using Raft algorithm

---
### Use cases

* service discovery
* storing dbs connections
* cache settings
* feature flags

---
### Present in

* kubernetes
* treafik
* CoreDNS
* openstack
* skydive

---
## Architecture

---
### architecture

* leader - follower
* leader election using consensus algorithm

---
### Raft consensus algorithm

Visualisation: https://raft.github.io/

---
### Configure etcd

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
### etcd write

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
### etcd read

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
### etcd delete

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
### TTL

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

### Sources

* [Service discovery in Microservices architecture](https://www.nginx.com/blog/service-discovery-in-a-microservices-architecture/)
* [Service discovery tools](https://technologyconversations.com/2015/09/08/service-discovery-zookeeper-vs-etcd-vs-consul/)
