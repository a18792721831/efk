[TOC]

项目地址：

https://github.com/a18792721831/efk.git

本文只是简单的快速搭建一个efk系统，不涉及efk理论知识。

如果你不想了解我搭建的过程，只是想直接获取到一个能用的环境，请直接下载项目即可，下载完项目然后在自己的微服务中配置。

即使你不了解我搭建的过程，我也尽可能保证你能得到一个可用的efk环境，并且能快速的使用到项目中。但是了解我是如何搭建的能更好的帮助你解决可能出现的问题。

我所指的efk是elasticsearch+fluentd+kibana.

# 1. elasticsearch

elasticsearch我们选择使用6.8.13版本，使用docker方式部署。（fluentd只支持6.x系列）

首先在[docker-hub](https://hub.docker.com/)上找到官方的镜像

![image-20210225192722855](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225192722855.png)

对于6.x系列，最新的就是6.8.13

![image-20210225192803296](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225192803296.png)

我默认你已经安装好了docker和docker-compose并且可以访问docker-io。

OK，现在镜像找到了，但是如何使用这个镜像呢？

![image-20210225193217411](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225193217411.png)

继续往下拉，能找到`How to use`小节，但是仅仅给出了单机启动的方式。

在`How to
use`中，也直接给出了elasticsearch的文档的地址[elasticsearch-doc](https://www.elastic.co/guide/en/elasticsearch/reference/index.html)

![image-20210225193353342](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225193353342.png)

我们找到6.8版本的文档

![image-20210225193425104](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225193425104.png)

请记住，当我们有不知道的内容的时候，从这里找要比在网上找更快，更准确。

我们打开全部的目录

![image-20210225193930079](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225193930079.png)

然后搜索docker

![image-20210225194006201](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225194006201.png)

就能找到如何docker启动elasticsearch了(这里和在docker-hub中找到的结果相同)

区别在于，在线文档其实还给出了docker-compose的例子，我们要的就是docker-compose文件。

![image-20210225194146888](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225194146888.png)

docker-compose例子中是如何在1台宿主机中启动集群模式的elasticsearch.

在一台机器上启动集群，主要是把数据尽可能的分片。除去这个因素，没有什么时机意义。

## 1.1 单宿主机集群

我们将这个文件拷贝到linux中，并进行一定的修改，主要是设置一些环境变量

```yaml
version: "3.2"
services:
  elasticsearch0:
    image: docker.elastic.co/elasticsearch/elasticsearch:6.8.13
    restart: always
    container_name: elasticsearch0
    hostname: elasticsearch0
    environment:
      - TZ=Asia/Shanghai
      - "ES_JAVA_OPTS=-Xms256m -Xmx256m"
      - cluster.name=elasticsearch-cluster
      - node.name=elasticsearch0
      - http.cors.enabled=true
      - http.cors.allow-origin="*"
    ports:
      - 9200:9200
    volumes:
      - /etc/localtime:/etc/localtime
      - ~/efk/elasticsearch0/data:/usr/share/elasticsearch/data
      - ~/efk/elasticsearch0/logs:/usr/share/elasticsearch/logs
      - ~/efk/elasticsearch0/plugins:/usr/share/elasticsearch/plugins
    networks:
      - outside
  elasticsearch1:
    image: docker.elastic.co/elasticsearch/elasticsearch:6.8.13
    restart: always
    container_name: elasticsearch1
    hostname: elasticsearch1
    environment:
      - TZ=Asia/Shanghai
      - "ES_JAVA_OPTS=-Xms256m -Xmx256m"
      - cluster.name=elasticsearch-cluster
      - node.name=elasticsearch1
      - http.cors.enabled=true
      - http.cors.allow-origin="*"
    volumes:
      - /etc/localtime:/etc/localtime
      - ~/efk/elasticsearch1/data:/usr/share/elasticsearch/data
      - ~/efk/elasticsearch1/logs:/usr/share/elasticsearch/logs
      - ~/efk/elasticsearch1/plugins:/usr/share/elasticsearch/plugins
    networks:
      - outside
networks:
  outside:
    external:
      name: efk
```

或许你很好奇，这些环境变量代表什么含义呢？我又从什么地方看呢？

很简单，在线文档。

当我们写出上面的docker-compose文件，我们就需要明白两个问题：1.环境变量；2.文件挂载。

我们打开在线文档目录直接搜索其中的`cluster-name`环境变量（这个环境变量是示例中的环境变量）

![image-20210225195757916](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225195757916.png)

在线文档中给出的重要的环境变量只有几个，不是完整的。

另外一种搜索方式是使用在线文档的搜索功能搜索

在在线文档的任意一个界面，基本上都有一个放大镜的图标

![image-20210225203523796](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225203523796.png)

点击后输入我们想要搜索的内容即可

![image-20210225203553928](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225203553928.png)

这样你就能搜索到全部的文档了

![image-20210225203629355](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210225203629355.png)

比如找`node.name`这个属性

![202103011505](.image/202103011505.gif)

在文档中，有这几个配置比较重要

![image-20210301150906117](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301150906117.png)

这里的配置基本上就够了。

| 配置名字                             | 配置说明                               | 说明                                                                                                                                                                                                                                                           |
|:-----------------------------------|:--------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| path.data                          | elasticsearch的数据存储目录              |                                                                                                                                                                                                                                                               |
| path.logs                          | elasticsearch的日志存储目录              | 这里的日志主要是dc.log                                                                                                                                                                                                                                           |
| cluster.name                       | elasticsearch的集群的名字               | 同一个集群内节点的集群名字必须相同                                                                                                                                                                                                                                    |
| node.name                          | 本节点在elasticsearch内的名字            | 同一个集群内，避免节点名字相同                                                                                                                                                                                                                                       |
| network.host                       | elasticsearch节点的网络                 | elasticsearch会将这个host进行bind<br />一般这里是0.0.0.0,表示任何网络都能访问本节点.<br />network还有4个特殊值可以配置：[network特殊配置](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/modules-network.html#_ipv4_vs_ipv6)                                     |
| discovery.zen.ping.unicast.hosts   | elasticsearch发现节点的列表              | 这里一般是主节点列表。<br />是一个数组，可以配置很多个。<br />如果不带有端口，则是默认的9300。如果主节点不是9300，那么可以带有端口。<br />可以配置域名。                                                                                                                               |
| discovery.zen.minimum_master_nodes | elasticsearch中选举主节点时最少支持节点数量 | elasticsearch中主节点时选举产生的。<br />elasticsearch中通过`node.master`配置节点是否可以作为主节点参与选举。<br />elasticsearch中通过`node.data`配置节点是否可以存储数据。<br />为了防止脑裂，一方面避免master待选节点数量为偶数，另一边需要满足`半数原则`.（`半数原则`是支持的节点数量必须大于50%） |

如果要配置一个单宿主机集群，其实只需要在宿主机中启动多个实例，只要这些实例的集群名字保持相同即可。

elasticsearch会自己发现本网段中其他的elasticsearch实例，然后会相互通信。只要是同集群的，就会自动加入。

对于最开始的`docker-compose.yaml`，现在还不能运行，因为使用的是外部的网络，还需要手动创建网络。

`docker network remove efk;docker network create efk --subnet
172.254.0.0/16;`

![image-20210301155047564](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301155047564.png)

接着使用`docker-compose up -d`启动即可。

![image-20210301154906704](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301154906704.png)

发现启动失败，使用`docker-compose logs -f elasticsearch0`查看日志

![image-20210301155007183](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301155007183.png)

发现是权限问题使用`chmod -R 777
~/efk/elasticsearch*`给与权限。因为在`docker-compose.yaml`中配置是自动重启的，所以等等就会启动成功了。

![image-20210301155230791](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301155230791.png)

接着我们使用rest-api查看集群状态,发现还是不能访问。等下elasticsearch节点又会重启。

查看日志发现是内存的问题

![image-20210301155735493](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301155735493.png)

使用`sysctl --write vm.max_map_count=262144;`设置，然后等会即可。

查看日志，发现已经启动了

![image-20210301155902633](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301155902633.png)

访问elasticsearch0的9200

![image-20210301155935348](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301155935348.png)

查看集群信息

![image-20210301162045531](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301162045531.png)

## 1.2 elasticsearch 配置

### 1.2.1 基础信息配置

[path.logs和path.data配置](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/path-settings.html)

| 配置名     | 配置值 |
|:----------|:------|
| path.data | 字符串 |
| path.logs | 字符串 |

[cluster.name配置](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/cluster.name.html)

| 配置名        | 配置值 |
|:-------------|:------|
| cluster.name | 字符串 |

[node.name配置](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/node.name.html)

| 配置名     | 配置值 |
|:----------|:------|
| node.name | 字符串 |

[network.host配置](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/network.host.html)

| 配置名        | 配置值                             |
|:-------------|:----------------------------------|
| network.host | ip地址<br />特殊值(一般用0.0.0.0即可) |

### 1.2.2 高级配置--network

[这章节在Modules下的network小节](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/modules-network.html)

#### network.host

network.host为0.0.0.0表示任意的网络

![image-20210301173040730](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301173040730.png)

network.host特殊值

| 特殊值                  | 说明                          |
|:-----------------------|:-----------------------------|
| `_[networkInterface]_` | 指定网卡或网段                  |
| `_local_`              | 本机回环地址，比如`127.0.0.1`    |
| `_site_`               | 内网地址，比如`192.168.0.1`     |
| `_global_`             | 公网地址，比如`114.114.114.114` |

默认支持ipv4和ipv6，如果需要配置指定网段是指定协议，需要增加协议。比如`_en0:ipv4_`

ipv6地址需要用`[]`将地址包起来，然后后面接`:9200`端口。

#### discovery.zen.ping.unicast.hosts

主节点的host列表。当前节点会尝试加入主节点的host列表内的集群。

默认是本机。

配置多个用==逗号==分割。

#### http.port

elasticsearch的http对外端口。也是rest-api的端口。默认9200~9300.选择这个范围内第一个可用的端口。

可以配置为一个范围。

比如`http://127.0.0.1:9200`

#### transport.port

elasticsearch的通信端口。elasticsearch集群内部需要进行通信，这个端口就是elasticsearch自己通信的端口。默认是9300~9400.选择这个范围内第一个可用的端口。

可以配置为一个范围。

#### network.bind_host

将elasticsearch节点绑定到哪个网段。

主要用于节点发现。其他节点如果也在这个网段，这两个节点就会通信。如果属于一个集群，那么就会参与选举。

默认取`network.host`的配置值。

#### network.publish_host

当前节点对外发布信息时，发布的host。用于代表当前节点的访问地址。

默认取`network.host`。

### 1.2.3 高级配置--discovery

#### discovery.zen.ping.unicast.hosts

指定主节点列表。当前节点会尝试加入这些主节点，如果这些主节点无法加入，且当前节点允许成为主节点，而且满足最小选择支持数，那么本节点就会成为主节点。

这里面配置的是可以参与选举的节点。

这个配置含义可以简单这样理解：当前节点在将自己本身作为主节点之前，先尝试找其他主节点。

默认本机回环地址。

#### discovery.zen.ping,unicast,resolve_timeout

尝试发现主节点的ping的超时时间。

默认5s。

在某些网络不好的情况下，可能5s不够。

#### discovery.zen.ping_timeout

节点发现主节点的ping超时时间。

默认3s.

换句话说，从节点加入主节点，会给主节点ping,主节点需要给从节点进行回复。这个timeout就是从节点的一次ping的等待时间。

从节点对主节点列表中的一个主节点会尝试ping三次。

#### discovery,zen,join_timeout

节点加入主节点的超时时间。

默认20倍的ping超时时间。

我们给从节点配置了一个主节点地址列表。但是我们无法保证主节点列表中第一个就是主节点(主节点需要选举)

所以，就需要从节点一个一个的去尝试询问。如果节点不回复，那么一定不是主节点(不考虑网络问题)。

如果节点有回复，那么还需要确认，询问的节点是否是主节点。节点可以参与选举，但是不一定选举成功。

#### discovery.zen.master_election.ignore_no_master_pings

true或者false。

在选举主节点期间，是否忽略从节点的ping。

默认是false。

也就是说，在选举主节点期间，从节点给可以参与选举的主节点候选发送ping，是可以收到回复的。

#### discovery.zen.minimum_master_nodes

成功当选最少同意数量。

为了防止脑裂，至少需要一半以上的节点同意，选举才成功。

### 1.2.4 高级配置--transport

elasticsearch节点之间需要进行通信，使用的就是transport模块。

#### transport.port

当前节点与其他节点通信的端口。

默认9300~9400之间第一个可用端口。

#### transport.publish_port

当前节点对外发布的通信端口。

默认取`transport.port`的值。

#### transport.bind_host

elasticsearch绑定网段。

默认取`transport.host`或者`network.bind_host`的值。

#### transport.publish_host

当前节点对外发布的地址。

默认取`transport.host`或者`network.publish_host`的值。

#### transport.host

当前节点与其他节点通信的地址。

默认取`network.host`的值。

#### transport.connect_timeout

节点之间通信连接的超时时间。

默认30s

#### transport.compress

节点之间通信的数据是否进行压缩。

默认不压缩。

压缩会将节点之间沟通变慢。

### 1.2.5 高级配置--http

和transport类似

[http配置](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/modules-http.html)

| Setting                         | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
|:--------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `http.port`                     | A bind port range. Defaults to `9200-9300`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `http.publish_port`             | The port that HTTP clients should use when communicating with this node. Useful when a cluster node is behind a proxy or firewall and the `http.port` is not directly addressable from the outside. Defaults to the actual port assigned via `http.port`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `http.bind_host`                | The host address to bind the HTTP service to. Defaults to `http.host` (if set) or `network.bind_host`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `http.publish_host`             | The host address to publish for HTTP clients to connect to. Defaults to `http.host` (if set) or `network.publish_host`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `http.host`                     | Used to set the `http.bind_host` and the `http.publish_host` Defaults to `http.host` or `network.host`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `http.max_content_length`       | The max content of an HTTP request. Defaults to `100mb`. If set to greater than `Integer.MAX_VALUE`, it will be reset to 100mb.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `http.max_initial_line_length`  | The max length of an HTTP URL. Defaults to `4kb`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `http.max_header_size`          | The max size of allowed headers. Defaults to `8kB`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `http.compression`              | Support for compression when possible (with Accept-Encoding). Defaults to `true`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `http.compression_level`        | Defines the compression level to use for HTTP responses. Valid values are in the range of 1 (minimum compression) and 9 (maximum compression). Defaults to `3`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `http.cors.enabled`             | Enable or disable cross-origin resource sharing, i.e. whether a browser on another origin can execute requests against Elasticsearch. Set to `true` to enable Elasticsearch to process pre-flight [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) requests. Elasticsearch will respond to those requests with the `Access-Control-Allow-Origin` header if the `Origin` sent in the request is permitted by the `http.cors.allow-origin` list. Set to `false` (the default) to make Elasticsearch ignore the `Origin` request header, effectively disabling CORS requests because Elasticsearch will never respond with the `Access-Control-Allow-Origin` response header. Note that if the client does not send a pre-flight request with an `Origin` header or it does not check the response headers from the server to validate the `Access-Control-Allow-Origin` response header, then cross-origin security is compromised. If CORS is not enabled on Elasticsearch, the only way for the client to know is to send a pre-flight request and realize the required response headers are missing. |
| `http.cors.allow-origin`        | Which origins to allow. Defaults to no origins allowed. If you prepend and append a `/` to the value, this will be treated as a regular expression, allowing you to support HTTP and HTTPs. for example using `/https?:\/\/localhost(:[0-9]+)?/` would return the request header appropriately in both cases. `*` is a valid value but is considered a **security risk** as your Elasticsearch instance is open to cross origin requests from **anywhere**.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `http.cors.max-age`             | Browsers send a "preflight" OPTIONS-request to determine CORS settings. `max-age` defines how long the result should be cached for. Defaults to `1728000` (20 days)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `http.cors.allow-methods`       | Which methods to allow. Defaults to `OPTIONS, HEAD, GET, POST, PUT, DELETE`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `http.cors.allow-headers`       | Which headers to allow. Defaults to `X-Requested-With, Content-Type, Content-Length`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `http.cors.allow-credentials`   | Whether the `Access-Control-Allow-Credentials` header should be returned. Note: This header is only returned, when the setting is set to `true`. Defaults to `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `http.detailed_errors.enabled`  | Enables or disables the output of detailed error messages and stack traces in response output. Note: When set to `false` and the `error_trace` request parameter is specified, an error will be returned; when `error_trace` is not specified, a simple message will be returned. Defaults to `true`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `http.pipelining`               | Enable or disable HTTP pipelining, defaults to `true`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `http.pipelining.max_events`    | The maximum number of events to be queued up in memory before an HTTP connection is closed, defaults to `10000`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `http.max_warning_header_count` | The maximum number of warning headers in client HTTP responses, defaults to unbounded.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `http.max_warning_header_size`  | The maximum total size of warning headers in client HTTP responses, defaults to unbounded.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

## 1.3 elasticsearch节点分类

### 1.3.1 单节点--discovery.type

如果整个集群中只有一个节点，而且没有集群的需求的时候。可以使用单机版。

通过设置`discovery.type=single-node`。

![image-20210301190131769](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301190131769.png)

### 1.3.2 主节点--node.master

一个节点可以参加选举，就需要配置`node.master=true`.这样这个节点就会参与选举。

节点默认是可以参与选举的。也就是说，任何节点都可以成为主节点。

### 1.3.3 数据节点--node.data

如果集群内节点特别多，数据交互非常频繁，而且交互都是通过主节点进行的。此时主节点既要回复从节点的信息，还需要数据的存储。

当主节点即管理数据，又管理节点时，主节点自己就很容易成为性能瓶颈。

所以，当数据交互非常平凡的时候，就可以将主节点和数据节点分离。

如果配置多个主节点，那么这些主节点即不存储数据，也不是主节点。这时候，这些主节点就组成了哨兵模式。当真正的主节点死掉后，待选主节点可以升级为主节点。而真正的主节点回复后，又会成为待选主节点。

因为主节点不存储任何数据，因此换了主节点并不会影响数据。

### 1.3.4 解析节点--node.ingest

elasticsearch是一个分词数据库，当我们将一个字符串交给elasticsearch后，elasticsearch需要进行分词操作。分词也是需要耗费计算资源的。

解析节点就是专门用于解析分词的。

某种意义上来说，即不存储数据，有不是主节点的节点，就是专门的解析节点。

### 1.3.5 连接节点--tribe

当我们有多个集群时，如果这些集群之间需要进行数据通信，那么就需要用到连接节点进行连接。

```yaml
tribe:
    t1: 
        cluster.name:   cluster_one
    t2: 
        cluster.name:   cluster_two
```

通过配置多个集群进行连接。

连接节点将在7.x移除。

### 1.3.6 机器学习节点--node.ml

[机器学习节点配置说明](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/modules-node.html#ml-node)


在实际使用中，可以并不需要明确区分节点的类型。在数据量小的时候，主节点也可以是数据节点，从节点也可以参与选举，任何节点都可以参与解析。

并没有明确的定义。

## 1.4 多宿主机集群

我们首先创建`.env`文件。在`docker-compose.yaml`中可以使用`.env`中的环境变量。这些环境变量也可以设置到操作系统中。
确保`.env`文件和`docker-compose.yaml`在同目录下。

```env
# 本机ip
THIS_IP=
# 本机elasticsearch通信端口
THIS_PORT=
# 本机elasticsearch外部访问端口
THIS_HTTP_PORT=
# 集群主节点的ip
MASTER_IP=
# 集群主节点的端口
MASTER_PORT=
# 本机节点的名字
NODE_NAME=
# 当前节点是否可以成为主节点
IS_MASTER=
```

对应的`docker-compose.yaml`文件：

```yaml
version: "3.2"
services:
  elasticsearch:
    image: 10.0.250.108/library/elasticsearch:6.8.13
    restart: always
    container_name: elasticsearch
    hostname: elasticsearch
    environment:
      - TZ=Asia/Shanghai
      - "ES_JAVA_OPTS=-Xms1024m -Xmx1024m"
      - cluster.name=boss-elasticsearch
      - network.host=0.0.0.0
      - http.cors.enabled=true
      - http.cors.allow-origin='*'
      - node.data=true
      - discovery.zen.ping.unicast.hosts.resolve_timeout=1d
      - discovery.zen.ping.unicast.hosts=${MASTER_IP}:${MASTER_PORT}
      - discovery.zen.minimum_master_nodes=1
      - path.data=/usr/share/elasticsearch/data
      - path.logs=/usr/share/elasticsearch/logs
      - node.name=${NODE_NAME}
      - transport.publish_host=${THIS_IP}
      - transport.publish_port=${THIS_PORT}
      - node.master=${IS_MASTER}
    ports:
      - ${THIS_HTTP_PORT}:9200
      - ${THIS_PORT}:9300
    volumes:
      - /etc/localtime:/etc/localtime
      - ~/bosselastic/elasticsearch/data:/usr/share/elasticsearch/data
      - ~/bosselastic/elasticsearch/logs:/usr/share/elasticsearch/logs
      - ~/bosselastic/elasticsearch/plugins:/usr/share/elasticsearch/plugins
    networks:
      - outside
networks:
  outside:
    external:
      name: efk
```

这是主节点列表中只有一个节点的。

==如果你想给主节点列表中设置多个地址，那么需要使用`-
discovery.zen.ping.unicast.hosts=${MASTER_IP}:${MASTER_PORT},${MASTER_IP1}:${MASTER_PORT1},....`==

在多个宿主机上启动之后，访问主节点集群信息

![image-20210301192922113](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210301192922113.png)

## 1.5 宿主机启动的坑

如果你将elasticsearch的数据和目录挂载出来，那么启动会异常的。

因为在容器内，elasticsearch是以elasticsearch的用户进行运行的。对外部的目录没有权限。

所以第一次启动会失败，日志中是权限不足。我们需要使用`chmod -R 777
xxx`进行权限赋予。赋予权限后不需要重启,我们定义docker-compose的时候，就是自动重启的。

一会之后，查看日志还是权限不足，此时还需要使用`chmod -R 777 xxxx`进行权限赋予。

第一次权限不足是因为elasticsearch需要在指定目录下创建elasticsearch的目录。

第二次权限不足是因为elasticsearch在log目录下创建gc.log，但是elasticsearch又没有gc.log的读写权限。所以需要第二次赋权。第二次赋权实际上修改的是gc.log的权限。

# 2. elasticsearch-head

现在网络上关于elasticsearch的可视化管理系统特别多，安装起来也非常的简单。甚至你熟悉elasticsearch的api接口，你通过http就能管理集群。

为了容易查看和管理，我们安装elasticsearch-head软件。

也是采用docker-compose安装。

因此我们在docker-hub上找到这个镜像。

[docker-hub搜索elasticsearch-head结果](https://hub.docker.com/search?q=elasticsearch-head&type=image)
![image-20210302185457001](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302185457001.png)

需要注意的是，这个镜像没有latest标签，这就意味着，我们必须制定标签下载。

我们使用其中的5这个标签即可

![image-20210302185608022](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302185608022.png)

我们将其作为docker-compose中的服务

```yaml
version: "3.2"
services:
  searchhead:
    image: docker.elastic.co/mobz/elasticsearch-head:5
    restart: always
    container_name: searchhead
    hostname: searchhead
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - /etc/localtime:/etc/localtime
    ports:
      - 9100:9100
    networks:
      - outside
networks:
  outside:
    external:
      name: efk
```

这个端口是怎么来的呢？

我们点击这个5，就能查看这个镜像的dockerfile了

![image-20210302190127046](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302190127046.png)

接着通过`EXPOSE`的关键词就能找到容器内的端口

![image-20210302190211254](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302190211254.png)

当我们启动之后，就可以通过9100访问了

![image-20210302190635147](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302190635147.png)

访问是这样的

![image-20210302190702964](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302190702964.png)

我们填入elasticsearch的地址和端口

![image-20210302191101391](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302191101391.png)

这个监控还可以管理节点。但是因为没有权限管理和角色管理，最好不要让外网可以访问监控。

# 3. kibana

同样的操作，在[docker-hub中搜索kibana](https://hub.docker.com/search?q=kibana&type=image)

![image-20210302191301125](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302191301125.png)

kibana的版本一定要和elasticsearch的版本保持一致

![image-20210302191437024](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302191437024.png)

如何使用kibana

![image-20210302191518051](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302191518051.png)

基于此，我们可以编写出kibana的docker-compose文件

```yaml
version: "3.2"
services:
  kibana:
    image: /kibana:6.8.13
    restart: always
    container_name: kibana
    hostname: kibana
    environment:
      - TZ=Asia/Shanghai
      - elasticsearch.hosts=http://${MASTER_IP}:${MASTER_PORT}
      - elasticsearch.pingTimeout=300000
      - kibana.index=.kibana
      - logging.timezone=UTC+8
      - server.host=0.0.0.0
      - server.name=kibana
      - server.port=5601
      - i18n.locale=zh-CN
      - xpack.monitoring.kibana.collection.enabled=false
      - xpack.monitoring.ui.container.elasticsearch.enabled=true
    volumes:
      - /etc/localtime:/etc/localtime
    ports:
      - 5601:5601
    depends_on:
      - elasticsearch
    networks:
      - outside
networks:
  outside:
    external:
      name: efk
```

其中MASTER_IP是环境变量。

初次之外，还需要配置kibana

kibana也是elastic公司的开源产品，因此，类似与elasticsearch一样，在[elatic官网](https://www.elastic.co/cn/)中直接搜索kibana

就能找到[kibana的文档](https://www.elastic.co/guide/en/kibana/6.8/index.html)

![image-20210302192138391](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302192138391.png)

我们找到`running kibana on
docker`小节，就可以知道配置一个最简单的kibana需要有哪些配置了

![image-20210302192223748](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302192223748.png)

![image-20210302192247402](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302192247402.png)

[kibana完整的配置说明](https://www.elastic.co/guide/en/kibana/6.8/settings.html)

![image-20210302195704953](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302195704953.png)

kibana全部的配置都可以用环境变量传入。也可以用配置文件挂载。

启动后立刻访问会提示kibana还未准备完成

![image-20210302202400211](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302202400211.png)

启动成功后，kibana会将自己的数据交给elasticsearch保存。

kibana在elasticsearch中保存数据的数据库索引是我们指定的`.kibana`开头的

![image-20210302202554538](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210302202554538.png)

此时没有任何数据。

# 4. fluentd

我们在[docker-hub中搜索fluentd](https://hub.docker.com/search?q=fluentd&type=image)

![image-20210303090133956](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303090133956.png)

需要注意的是，这个镜像只是纯镜像，没有任何插件。

我们选择这个版本

![image-20210303090431900](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303090431900.png)

通过查看`how to run
images`我们可以知道fluentd需要对外开放24224端口，并且对tcp和udp协议都开放。

![image-20210303090630659](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303090630659.png)

看到这里，我们已经能够成功的启动一个fluentd的镜像了，但是，还有一个问题需要解决？fluentd如何与elasticsearch集成？

默认镜像只包含fluentd的功能，没有elasticsearch的。

我们通过docker-hub的界面链接到fluentd的github地址

![image-20210303091055008](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303091055008.png)

在github的readme中的第三小节，我们可以找到fluentd的插件市场

![image-20210303091143378](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303091143378.png)

而且给出的例子就是fluentd安装elasticsearch插件

![image-20210303091236906](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303091236906.png)

我们在[fluentd的插件市场](https://www.fluentd.org/plugins)中搜索elasticsearch就可以找到elasticsearch的插件了

![image-20210303091431087](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303091431087.png)

点击就进入[elasticsearch插件的github](https://github.com/uken/fluent-plugin-elasticsearch)中了,在readme中找到安装小节

![image-20210303091828691](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303091828691.png)

通过这里，我们拿到了插件名称和下载方式。

接下来就开始编写我们自己的dockerfile吧

```dockerfile
FROM fluentd:v1.9-1
USER root
WORKDIR /home/fluent
RUN gem install fluent-plugin-elasticsearch
EXPOSE 24224
```

简单粗暴，使用最新的fluentd以及使用root用户，直接切换到fluent目录下，使用命令安装插件，并传递开放24224端口(其实不知道另一个端口是干啥的，所以就没有开放)。

需要注意的是，这样构建镜像，需要构建的宿主机能够访问外网。

在宿主机上使用`docker build -f fluentd-elasticsearch
--tag=fluentd-elasticsearch:latest .`进行构建。(别忘记了`.`)

![image-20210303092433534](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303092433534.png)

查看镜像，会发现多了一个

![image-20210303092513312](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303092513312.png)

如果需要上传私服，需要使用`docker login
http://your-harbor.com`登录docker私服，然后使用`docker commit -m
"message"`提交修改

![image-20210303092709829](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303092709829.png)

最终使用`docker push fluentd-elasticsearch`推送即可

![image-20210303092847235](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303092847235.png)

到了这里就需要编写`docker-compose`文件了

```yaml
version: "3"
services:
  fluentd:
    image: fluentd-elasticsearch
    restart: always
    container_name: fluentd
    hostname: fluentd
    command: "fluentd -c /fluentd/etc/fluent.conf"
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - /etc/localtime:/etc/localtime
      - ~/bosselastic/fluentd/logs:/fluentd/log
      - ~/bosselastic/fluentd/fluent.conf:/fluentd/etc/fluent.conf:rw
    ports:
      - 24224:24224/udp
      - 24224:24224
    extra_hosts:
      - 'elasticsearch: ${MASTER_IP}'
    networks:
      - outside
networks:
  outside:
    external:
      name: efk
```

这个文件，你或许有两个疑问？

1. command是如何得到的？

   在[fluentd的github的readme](https://github.com/fluent/fluentd-docker-image)中有自定义配置小节

   ![image-20210303093658701](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303093658701.png)

   而且，我们在文件挂载中，将配置文件挂载到了`/fluentd/etc/`目录下。

   其实，只要将配置文件挂载到`/fluentd/etc/`目录下，而且文件名字是`fluent.conf`是不需要`-c`参数的。

   因为在官方的镜像中，默认取的就是这个目录下的这个配置文件

   [fluentd最新镜像的dockerfile文件](https://github.com/fluent/fluentd-docker-image/blob/master/v1.10/alpine/Dockerfile)

   ![image-20210303093925344](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303093925344.png)

2. 为什么需要extra_hosts？

   看到这里，就不得不提另一个问题，那就是在上面我们挂载的配置文件。

   ```conf
   # Receive events from 24224/tcp
   # This is used by log forwarding and the fluent-cat command
   <source>
     @type forward
     port 24224
     bind 0.0.0.0
   </source>
   <match *.*>
     @type copy
     <store>
       @id elasticsearch
       @type elasticsearch
       @log_level debug
       host elasticsearch
       port 9200
       request_timeout 30s
       slow_flush_log_threshold 30s
       logstash_format true
       logstash_prefix fluentd
       logstash_dateformat %Y%m%d
       include_tag_key true
       tag_key @log_name
     </store>
   </match>
   ```

   配置文件长这样。里面需要配置elasticsearch的host。

   这个host你可以直接写死，但是这里我使用的是主机名，然后将真实地址通过hosts指定。

   这样做的好处是可以统一配置。

3. 配置文件？

   在[fluentd的github](https://github.com/fluent/fluentd-docker-image)的第二小节

   ![image-20210303101808433](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303101808433.png)

   告诉了我们fluentd的配置文件的文档位置

   我们主要看的是input和output小节。

   ![image-20210303102001026](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303102001026.png)

   ![image-20210303102041829](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303102041829.png)

OK，目前为止，`docker-compose`和`fluentd.conf`都有了，可以启动了。

但是启动之后是没有数据的。

# 5. 微服务集成fluentd

微服务集成fluentd需要引入fluent-logger的依赖以及fluency-core和fluency-fluentd。

如果使用logback配置日志，还需要引入logback的依赖

```gradle
	implementation 'org.fluentd:fluent-logger:0.3.4'
	implementation 'com.sndyuk:logback-more-appenders:1.8.3'
	implementation 'org.komamitsu:fluency-core:2.4.0'
	implementation 'org.komamitsu:fluency-fluentd:2.4.0'
```

比如一个web的全部依赖可以是这样的

```gradle
dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-web'
	implementation 'org.fluentd:fluent-logger:0.3.4'
	implementation 'com.sndyuk:logback-more-appenders:1.8.3'
	implementation 'org.komamitsu:fluency-core:2.4.0'
	implementation 'org.komamitsu:fluency-fluentd:2.4.0'
	compileOnly 'org.projectlombok:lombok'
	annotationProcessor 'org.projectlombok:lombok'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

启动之后微服务会尝试连接fluentd服务。

微服务还需要配置logback.xml文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="30 seconds">
    <springProperty scope="context" name="appName" source="spring.application.name" defaultValue="localhost"/>
    <property name="suffix" value="dev"/>
<!--    环境变量-->
<!--    fluentd的地址-->
<!--    <property name="LOG_FLUENTD_IP" value="10.0.250.106"/>-->
<!--    fluentd的端口-->
<!--    <property name="LOG_FLUENTD_PORT" value="24224"/>-->
    <property name="logName" value="${appName}-${suffix}"/>
    <!-- 日志级别 -->
    <property name="logLevel" value="INFO"></property>
    <!-- 日志地址 -->
    <property name="logPath" value="logs/${appName}"></property>
    <!-- 最大保存时间 -->
    <property name="maxHistory" value="7"/>

    <!-- 控制台打印日志的相关配置 -->
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <!-- 日志格式 -->
        <encoder>
            <pattern>
                <![CDATA[%d{HH:mm:ss.SSS} [%thread][TraceInfo:%X{traceId}:%X{spanId}] %-5level %logger{36} - %msg%n]]>
            </pattern>
        </encoder>
    </appender>

    <!-- 文件保存日志的相关配置，同步 -->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!-- 保存日志文件的路径 -->
        <file>${logPath}/${logName}.log</file>
        <!-- 日志格式 -->
        <encoder>
            <pattern>
                <![CDATA[%d{yyyy-MM-dd HH:mm:ss.SSS}%X{ip}[%thread][TraceInfo:%X{traceId}:%X{spanId}]  %-5level %logger{35} -%msg%n]]>
            </pattern>
        </encoder>
        <!-- 循环政策：基于时间创建日志文件 -->
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!-- 日志文件名格式 -->
            <fileNamePattern>${logPath}/${logName}-%d{yyyy-MM-dd}.log</fileNamePattern>
            <!-- 最大保存时间-->
            <maxHistory>${maxHistory}</maxHistory>
        </rollingPolicy>
    </appender>

    <appender name="FLUENT_SYNC" class="ch.qos.logback.more.appenders.FluencyLogbackAppender">
        <!--fluentd中的tag-->
        <tag>boss.${logName:-UNKOWN}</tag>
        <remoteHost>${LOG_FLUENTD_IP:-10.0.250.106}</remoteHost>
        <port>${LOG_FLUENTD_PORT:-24224}</port>
        <fileBackupDir>/tmp</fileBackupDir>
        <bufferChunkInitialSize>2097152</bufferChunkInitialSize>
        <bufferChunkRetentionSize>16777216</bufferChunkRetentionSize>
        <maxBufferSize>268435456</maxBufferSize>
        <waitUntilBufferFlushed>30</waitUntilBufferFlushed>
        <waitUntilFlusherTerminated>40</waitUntilFlusherTerminated>
        <senderMaxRetryCount>12</senderMaxRetryCount>
        <useEventTime>true</useEventTime>
        <additionalField>
            <key>@log_name</key>
            <value>${logName:-UNKOWN}</value>
        </additionalField>
        <additionalField>
            <key>pod_name</key>
            <value>${POD_NAME:-UNKOWN}</value>
        </additionalField>
        <additionalField>
            <key>host_name</key>
            <value>${hostname:-UNKOWN}</value>
        </additionalField>
    </appender>

    <!--哪些包的日志需要处理-->
    <logger name="com.study" level="INFO" additivity="false">
        <appender-ref ref="STDOUT"/>
        <appender-ref ref="FILE"/>
        <appender-ref ref="FLUENT_SYNC"/>
    </logger>

    <root level="${logLevel}">
        <!-- appender referenced after it is defined -->
        <appender-ref ref="STDOUT"/>
        <appender-ref ref="FILE"/>
        <appender-ref ref="FLUENT_SYNC"/>
    </root>
</configuration>
```

logback中配置的tag需要与fluentd.conf中的match进行匹配。

举个例子：

在logback中配置的tag是study.test，在fluentd.conf中match是study.*。因为在fluentd.conf中match是输出，只有匹配才会到对应的输出。

![image-20210303111103290](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303111103290.png)

这里需要注意。

我们启动微服务后，微服务通过logback进行日志处理，在logback中指定fluentd的服务端的地址和端口。接着fluentd的包会将日志上传给fluentd服务端。

fluentd服务端接受到日志后，进行格式化等处理，然后通过配置文件，匹配到elasticsearch的存储，接着fluentd通过elasticsearch的9200将数据存储到elasticsearch中。(没有指定elasticsearch的数据库索引，会以fluentd-日期创建，每天一个索引)

elasticsearch中存储了数据之后，kibana就能通过9200端口查询数据，并在界面中展示。

elasticsearch中存储了fluentd的数据后

![image-20210303111611834](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303111611834.png)

最后就能在kibana中查看日志了

![image-20210303111823935](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303111823935.png)

第一次进入kibana还不能直接查看日志，需要在Management中创建fluentd的索引模式。

![image-20210303112056856](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303112056856.png)

创建索引模式成功后，就可以在Discover中看到统计图了

![image-20210303112207421](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303112207421.png)

想看到统计图，需要在创建索引模式的第二步中选中时间属性，否则不会出现统计图

![image-20210303112304555](https://gitee.com/jyq_18792721831/blogImages/raw/master/img/image-20210303112304555.png)

