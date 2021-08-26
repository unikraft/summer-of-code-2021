---
title: "Session 04: Complex Applications"
linkTitle: "04. Complex Applications"
---

In this session, we are going to run some real-world applications on top of Unikraft. 

## 00. Qemu wrapper - [qemu_guest.sh](https://github.com/unikraft/kraft/blob/staging/scripts/qemu-guest)

`qemu-guest.sh` is a wrapper over the qemu executable, to make the use of qemu binary less painful.
In the following session, it will be very handy to use it.
To see the options for this wrapper you can use ```qemu_guest.sh -h```.

It is possible to run a lot of complex applications on Unikraft, but in this session, we will analyze only 3 of them: 

* Sqlite

* Redis

* Nginx

## 01. Sqlite - Set up and run SQLite (Tutorial)

[SQLite](https://www.sqlite.org/index.html) is a C library that implements an encapsulated SQL database engine that does not require any setting or administration.
It is the most popular in the world and is different from other SQL database engines because it is simple to administer, use, maintain, and test.
Thanks to these features, SQLite is a fast, secure, and most crucial simple application.

The SQLite application is represented by a ported external library that depends on two other libraries that are also ported for Unikraft ([pthread-embedded](https://github.com/unikraft/lib-pthread-embedded) and [newlib](https://github.com/unikraft/lib-newlib)).
To successfully compile and run the SQLite application for the KVM platform and x86-64 architecture, the following steps should be performed:

1. `download` the [lib-sqlite](https://github.com/unikraft/lib-sqlite) library from the Unikraft project repository directly to the libs folder.
The libraries on which lib-sqlite depends (pthread-embedded and newlib) should also be downloaded to the libs folder.

2. `create` in the apps folder, a directory for the SQLite application.
In this directory, we need to create two files:
    * Makefile containing rules for building the application as well as specifying the libraries that the application needs
    * Makefile.uk used to define variables needed to compile the application or to add application-specific flags.
    
    Also, in the Makefile, the order in which the libraries are mentioned in the LIBS variable is important to avoid the occurrence of compilation errors.

```
UK_ROOT ?= $(PWD)/../../unikraft
UK_LIBS ?= $(PWD)/../../libs
LIBS := $(UK_LIBS)/lib-pthread-embedded:$(UK_LIBS)/lib-newlib:$(UK_LIBS)/lib-sqlite

all:
    @$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS)

$(MAKECMDGOALS):
    @$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) $(MAKECMDGOALS)
```

3. `select` the SQLite library from the configuration menu, `Library Configuration` section.
Initially, we can select the option to generate the main source file used to run the application.

4. to import or export databases or csv/sql files, the SQLite application needs to configure a filesystem. Thus, the filesystem we use is 9pfs.
Hence, in the Library Configuration section, the 9pfs filesystem within the vfscore library should be selected.
Make sure, that both options `Virtio PCI device support` and `Virtio 9P device` are selected.
Those can be found in: `Platform Configuration` -> `KVM guest` -> `Virtio`.

![9pfs options](/docs/sessions/04-complex-applications/images/9pfs_options.png)

For testing we can use the following SQLite script, which inserts ten values into a table:

```
CREATE TABLE tab (d1 int, d2 text);
INSERT INTO tab VALUES (random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text)),
(random(), cast(random() as text));
```

Up next, create a folder in the application folder called `sqlite_files` and write the above script into a file.
When you run the application, you can specify the path of the newly created folder to the qemu_guest.sh as following:

```
./qemu_guest.sh -k ./build/app-sqlite_kvm-x86_64 \
                -e ./sqlite_files \
                -m 500
```

The SQLite start command has several parameters:

• `k` indicates the executable resulting from the build of the entire system together with the `SQLite application`

• `e` indicates the path to the shared directory where the Unikraft filesystem will be mounted

• `m` indicates the memory allocated to the application

To load the SQLite script you can use the following command `.read <sqlite_script_name.sql>`.
And in the end, you can run `select * from tab` to see the contents of the table.

If everything runs as expected, then you'll see the following output:

```
SeaBIOS (version 1.10.2-1ubuntu1)
Booting from ROM...
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                   Tethys 0.5.0~825b115
SQLite version 3.30.1 2019-10-10 20:19:45
Enter ".help" for usage hints.
sqlite> .read script.sql
sqlite> select * from tab;
-4482895989777805454|-110319092326802521
1731384004930241734|4521105937488475129
394829130239418471|-5931220326625632549
4715172377251814631|3421393665393635031
2633802986882468389|174376437407985264
-1691186051150364618|3056262814461654943
-4054754806183404125|-2391909815601847844
-4437812378917371546|-6267837926735068846
8830824471222267926|7672933566995619644
4185269687730257244|-3477150175417807640
sqlite> 
```

## 02. Sqlite - Change the filesystem (Tutorial)

In the previous exercise, we have chosen to use 9pfs as filesystem.
For this exercise, you'll have to change the filesystem to RamFS and load the SQLlite script as we have done in the previous exercise.

First, we need to change the filesystem to InitRD.
We can obtain that by using the command `make menuconfig` and from the vfscore option, we select the default root filesystem as InitRD.

![filesystems menu](/docs/sessions/04-complex-applications/images/filesystems.png)

The InitRD filesystem can load only [cpio archives](https://www.ibm.com/docs/en/zos/2.2.0?topic=formats-cpio-format-cpio-archives), so to load our SQLite script into RamFS filesystem, we need to create a cpio out of it.
This can be achieved the following way: Create a folder, move the SQLite script in it, and cd in it.
After that can simply run the following command: `find -depth -print | tac | bsdcpio -o --format newc > ../archive.cpio` and you'll obtain an cpio archive called `archive.cpio` in the parent directory.

Further, you need to run the following qemu command to run the instance:
```
./qemu_guest.sh -k build/app-sqlite_kvm-x86_64 -m 100 -i archive.cpio
```

If everything runs as expected, then you'll see the following output:

```
SeaBIOS (version 1.10.2-1ubuntu1)
Booting from ROM...
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                   Tethys 0.5.0~825b115
SQLite version 3.30.1 2019-10-10 20:19:45
Enter ".help" for usage hints.
sqlite> .read script.sql
sqlite> select * from tab;
-4482895989777805454|-110319092326802521
1731384004930241734|4521105937488475129
394829130239418471|-5931220326625632549
4715172377251814631|3421393665393635031
2633802986882468389|174376437407985264
-1691186051150364618|3056262814461654943
-4054754806183404125|-2391909815601847844
-4437812378917371546|-6267837926735068846
8830824471222267926|7672933566995619644
4185269687730257244|-3477150175417807640
sqlite> 
```

## 03. Redis - Setup up and run Redis (Tutorial)

[Redis](https://redis.io/topics/introduction) is one of the most popular key-value databases, with a design that facilitates the fast  writing  and  reading  of  data  from  memory  as  well  as  the  storage  of  data  on  disk  to  be able to reconstruct the state of data in memory in case of a system restart.
Unlike other data storage systems, Redis supports different types of data structures such as lists, maps, strings, sets, bitmaps, streams.

The Redis application is represented by a ported external library that depends on other ported libraries for Unikraft ([pthread-embedded](https://github.com/unikraft/lib-pthread-embedded), [newlib](https://github.com/unikraft/lib-newlib), [lwip-network](https://github.com/unikraft/lib-lwip) library).
To successfully compile and run the Redis application for the KVM platform and x86-64 architecture, the following steps should be performed:

1. `download` the [lib-redis](https://github.com/unikraft/lib-redis) library from the Unikraft project repository directly to the libs folder.
Also, the libraries on which [lib-redis](https://github.com/unikraft/lib-redis) depends ([pthread-embedded]([pthread-embedded](https://github.com/unikraft/lib-pthread-embedded), [newlib](https://github.com/unikraft/lib-newlib) and [lwip](https://github.com/unikraft/lib-lwip)) should be downloaded to the libs folder.

2. `create` in  the apps folder described in the previous sessions, a directory for the Redis application.
In this directory, we should create two files:
* Makefile (Listing  5.5) which contains rules for building the application as well as specifying the libraries that the application needs
* Makefile.uk used to define variables needed to compile the application or to add application-specific flags
    Also, in the Makefile, the order in which the libraries are mentioned in the LIBS variable is essential to avoid the occurrence of compilation errors.

```
UK_ROOT ?= $(PWD)/../../unikraft
UK_LIBS ?= $(PWD)/../../libs
LIBS := $(UK_LIBS)/lib-pthread-embedded:$(UK_LIBS)/lib-newlib:$(UK_LIBS)/lib-lwip:$(UK_LIBS)/lib-redis

all:
    @$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS)

$(MAKECMDGOALS):
    @$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) $(MAKECMDGOALS)
```

3. `select` the Redis library from the configuration menu, `Library Configuration` section.
Initially, we can select the option to generate the main source file used to run the application.

![redis selection menu](/docs/sessions/04-complex-applications/images/redis_menu.png)

4. to connect to the Redis server, the network features should be configured.
Hence, in the configuration menu in the `Library Configuration` section, within the `lwip library` the following options should be selected:

    • `IPv4`

    • `UDP support`

    • `TCP support`

    • `ICMP support`

    • `DHCP support`

    • `Socket API`

![lwip selection menu](/docs/sessions/04-complex-applications/images/lwip_redis_menu.png)

2. the Redis application needs a configuration file to start.
Thus, a filesystem should be selected in Unikraft.
The filesystem we used was 9pfs.
So, in the Library Configuration section of the configuration menu, the following selection chain should be made in the vfscore library: `VFSCore  Interface → vfscore Configuration → Automatically mount a root filesystem → Default root filesystem → 9PFS.

Therefore, following the steps above, the build of the entire system, together with the Redis application will be successful.
We used a script to run the application in which a bridge and a network interface (kraft0) are created.
The network interface has an IP associated with it used by clients to connect to the Redis server.
Also, the script takes care of starting the Redis server, but also of stopping it, deleting the settings created for the network.

```
brctl addbr kraft0
ifconfig kraft0 172.44.0.1
ifconfig kraft0 up

dnsmasq -d \
        --log-queries \
        --bind-dynamic \
        --interface=kraft0 \
        --listen-addr=172.44.0.1 \
        --dhcp-range=172.44.0.2,172.44.0.254,255.255.255.0,12h &> $WORKDIR/dnsmasq.log &

./qemu_guest.sh -k ./build/redis_kvm-x86_64 \
                -a "/redis.conf" \
                -b kraft0 \ 
                -e ./redis_files
                -m 100
```

The Redis server start command has several parameters:

• `k` indicates the executable resulting from the build of the entire system together with the `Redis` application

• `e` indicates the path to the shared directory where the Unikraft filesystem will be mounted

• `b` indicates the network interface used for external communication

• `m` indicates the memory allocated to the application

• `a` allows the addition of parameters specific to running the application

The following image is presenting an overview of our setup:

![lwip selection menu](/docs/sessions/04-complex-applications/images/redis_setup.png)

Consequently, after running the script the Redis server will start and dnsmasq will dynamically assign an IP address.
The IP can be seen in the output of qemu as bellow:

![redis ip](/docs/sessions/04-complex-applications/images/redis_ip.png)

Using the received IP, it will be possible to connect clients to it using redis-cli (the binary redis-cli is the folder for this exercise):

```
./redis-cli -h 172.88.0.76 -p 6379
172.88.0.2:6379> PING
PONG
172.88.0.2:6379> 
```

## 04. Redis - Obtain the ip statically (Exercise)

As you have seen already in exercise 03, we have dynamically assigned an IP to the network interface used by Unikraft using the `dnsmasq` utility.
Modify the launching script and run the application with a static IP. 
Beware that the assigned IP address must differ from the one assigned on the bridge.

You can use redis-cli, found in the exercise directory to test your changes.
If everything runs as expected you should see the following output:

```
./redis-cli -h 172.88.0.76 -p 6379
172.88.0.2:6379> PING
PONG
172.88.0.2:6379> 
```

## 05. Redis - Benchmark Redis (Tutorial)

For this exercise, we will run some benchmarking for the `redis app` running on `Unikraft` and for the `redis app` running on Linux.
In the directory of this exercise, you'll find 3 binaries: `redis-cli`, `redis-benchmark`, and `redis`.

First, we will start by benchmarking `redis app`, running on Unikraft.
Start the `redis app` on the top of Unikraft as we have already done at exercise 3 and in another terminal run the following command:

```
./redis-benchmark --csv -q -r 100 -n 10000 -c 1 -h 172.44.0.76 -p 6379 -P 8 -t set,get
```

The description of the used option can be seen here:
Usage: redis-benchmark [-h <host>] [-p <port>] [-c <clients>] [-n <requests>] [-k <boolean>]
```
 -h <hostname>      Server hostname (default 127.0.0.1)
 -p <port>          Server port (default 6379)
 -c <clients>       Number of parallel connections (default 50)
 -n <requests>      Total number of requests (default 100000)
 -P <numreq>        Pipeline <numreq> requests. Default 1 (no pipeline).
 -q                 Quiet. Just show query/sec values
 --csv              Output in CSV format
 -t <tests>         Only run the comma separated list of tests. The test
                    names are the same as the ones produced as output.
 ```

If everything runs as expected, you'll see the following output:

```
"SET","147058.81"
"GET","153846.16"
```
The printed values represent `requests/second` for the operation `set` and `get`.

Further, we will run the executable `redis-server` (`./redis-server`), which can be found in the exercise directory, and the following command (Only the IP address of the redis server was changed):

```
./redis-benchmark --csv -q -r 100 -n 10000 -c 1 -h 127.0.0.1 -p 6379 -P 8 -t set,get
```
After that you'll obtain something like this:

```
"SET","285714.28"
"GET","294117.62"
```

## 06. Nginx - Set up and run Nginx (Exercise)

In this exercise, we will set up and run nginx.
From the point of view of the library dependencies, the nginx app has the same dependencies as the redis app.
It's your choice how you assign the IP to the VM.
In the directory of this exercise, you'll find another directory, called `nginx` with the following structure:
```
nginx_files
└── nginx
    ├── conf
    │   ├── fastcgi.conf
    │   ├── fastcgi_params
    │   ├── koi-utf
    │   ├── koi-win
    │   ├── mime.types
    │   ├── nginx.conf
    │   ├── nginx.conf.default
    │   ├── scgi_params
    │   ├── uwsgi_params
    │   └── win-utf
    ├── data
    │   └── images
    │       └── small-img100.png
    ├── dev
    ├── html
    │   ├── 50x.html
    │   └── index.html
    ├── logs
    │   ├── error.log
    │   └── nginx.pid
    └── nginx.conf
```

The path to nginx_files folder should be given as a parameter to the `-e option` of the qemu_guest.
In the html folder will be added the files of the website you want to be run.

If everything works as expected, you should see the following html page in the browser.

![nginx output](/docs/sessions/04-complex-applications/images/nginx_output.png)

## 07. Nginx - Benchmark Nginx (Tutorial)

Benchmarking Nginx running on the top of Unikraft can be achieved with a utility called `iperf`.
The package can be easily installed using the command `sudo apt-get install -y iperf`.
Further, we will start the nginx app as we have done at the previous exercise and then we will open another two terminals.
We'll start an iperf server in the first one with the command `iperf -s` and in the second one, we'll start an iperf client with the command `iperf -c 172.44.0.76 -p 80`.

If everything runs as expected, then we will see the following output:

```
------------------------------------------------------------
Client connecting to 172.44.0.76, TCP port 80
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 172.44.0.1 port 33262 connected with 172.44.0.76 port 80
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.28 GBytes  1.10 Gbits/sec
```
