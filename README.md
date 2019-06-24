## etcd

Core concepts of etcd

> The following document is meant to be presented using [mark.show](https://mark.show/#/) - Markdown visualisation tool.

Copy the content of [README.md](https://raw.githubusercontent.com/piotrpersona/etcd-core/master/README.md) and paste it on the [mark.show](https://mark.show/#/) left pane.

---
## agenda

1. Microservices
1. Service discovery
1. etcd overview
1. Raft consensus algorithm
1. etcd API
1. Clustering

---
## Microservices

---
### microservices

* Approach of designing and running software to achieve high availability of an application

* Application is divided into multiple services

* Each service has single responsibility

* Each service should be easily scaled

* Each service should run in a distributed fashion

* Each service should be portable

---
### microservices

![microservices example](https://raw.githubusercontent.com/piotrpersona/etcd-core/master/svg/microservices.svg?sanitize=true)

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
### container

![container example](https://raw.githubusercontent.com/piotrpersona/etcd-core/master/svg/container.svg?sanitize=true)

---
### service

Let's assume the following service definition:

> Service - set of instances responsible for single service.

For instance:
* MongoDB cluster
* Web server cluster
* Auth service cluster

---
## service discovery

![service discrovery](https://raw.githubusercontent.com/piotrpersona/etcd-core/master/svg/service-discovery.svg?sanitize=true)

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

![service discrovery flow](https://raw.githubusercontent.com/piotrpersona/etcd-core/master/svg/service-discovery-flow.svg?sanitize=true)

---
### service discovery registry

Since the discovery is often used in distributed system, registry needs to be scalable, fault tolerant and distributed among all nodes in the cluster.

---
### etcd

is an open-source distributed key value store
that provides shared configuration and service discovery for Container Linux clusters.

---
### etcd

* **etc** - unix directory where configuration files persists, `/etc`

* **d**istributed - shared among cluster of machines

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
* Fast: benchmarked 10,000 writes/sec - [benchmarks](https://etcd.io/docs/v3.3.12/benchmarks/etcd-3-demo-benchmarks/)
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
### architecture

* leader - follower
* leader election using consensus algorithm

---
### etcd HA

Communication between etcd machines is handled via the **Raft consensus algorithm.**

---
### Consensus algorithm

Consensus algorithms allow a collection of machines
to work as a coherent group that can survive the failures of some of its members.

---
### Consensus algorithms

* They ensure safety - they will never return an incorrect result
* They are fully functional (available) as long as majority of the servers are running
* In the common case, a command can complete as soon as a majority of the cluster has responded to a single round of remote procedure calls; a minority of slow servers need not impact overall system performance.

---
### Consensus design

* Replicated state machines are typically implemented using a replicated log.

* Each server stores a log containing a series of commands, which its state machine executes in order.

* Each log contains the same commands in the same order, so each state machine processes the same sequence of commands.

---
### Consensus flow

1. The consensus module on a server receives commands from clients and adds them to its log.
1. It communicates with the consensus modules on other servers to ensure that every log eventually contains the same requests in the same order, even if some servers fail.
1. Once commands are properly replicated, each server’s state machine processes them in log order, and the outputs are returned to clients.

> As a result, the servers appear to form a single, highly reliable state machine.

---
### Raft

![Raft consensus model](https://raw.githubusercontent.com/piotrpersona/etcd-core/master/svg/raft-architecture.svg?sanitize=true)

---
#### Strong leader

Raft uses a stronger form of leadership than other consensus algorithms. For example, log entries only flow from the leader to other servers.
This simplifies the management of the replicated log
and makes Raft easier to understand.

---
#### Leader election

Raft uses randomized timers to elect leaders. This adds only a small amount of mechanism to the heartbeats already required for any consensus algorithm, while resolving conflicts simply and rapidly.

---
#### Membership changes

Raft’s mechanism for changing the set of servers in the cluster uses a new joint consensus approach where the majorities of two different configurations overlap during transitions.
This allows the cluster to continue operating normally during configuration changes.

---
### Terms in Raft

* Raft divides time into **terms** of arbitrary length.
* Terms are numbered with consecutive integers.
* Each term begins with an election, in which one or more candidates attempt to become leader.

---
### Raft flow

1. Elect distinguished leader
1. Give the leader complete responsibility for managing the replicated log.
1. The leader accepts the log entries from the clients. Replicates them on the other servers

---
### Leader election

Each machine can be in one of the following state:

* Leader
* Follower
* Candidate

![etcd leader election machine state](https://raw.githubusercontent.com/piotrpersona/etcd-core/master/svg/raft-machine-state.svg?sanitize=true)

---
### Raft visualisation

https://raft.github.io/

---
## API

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

---
### etcd clustering

*"five" is a typical number of servers, which allows the system to tolerate two failures.*

---
### Configuration

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
### Clustering

1. Start with initial cluster of nodes (minimum 3)
```bash
etcd ... --initial-cluster "instance1PeerURL,instance2PeerURL...instanceNPeerURL"
```

2. Add node

```bash
# on any node in a cluster
etcdctl member add <name> <peerURL>

# e.g.:
ectdctl member add etcd5 http://etcd5:2380
```

3. On new member

```bash
etcd ... (Configuration stuff) --initial-cluster "peersURLs,<new member peer URL>"
```

---
### External links

The following document was made using below resources:

* [etcd.io](https://etcd.io/)
* [Official etcd documentation](https://etcd.io/docs/v3.3.12/)
* [Service discovery in Microservices architecture](https://www.nginx.com/blog/service-discovery-in-a-microservices-architecture/)
* [Service discovery tools](https://technologyconversations.com/2015/09/08/service-discovery-zookeeper-vs-etcd-vs-consul/)
* [Raft consensus algorithm paper](https://raft.github.io/raft.pdf)
* [Failure models](https://etcd.io/docs/v3.3.12/op-guide/failures/)
* [etcd vs other KV-stores](https://etcd.io/docs/v3.3.12/learning/why/)
* [etcd clustering with Rancher](https://rancher.com/blog/2019/2019-01-29-what-is-etcd/)
