---
title: "Session 04: Complex Applications"
linkTitle: "04. Complex Applications"
---

In this session, we are going to run some real-world applications on top of Unikraft. 

## 00. Qemu wrapper - [qemu_guest.sh](https://github.com/unikraft/kraft/blob/staging/scripts/qemu-guest)

Qemu-guest.sh is a wrapper over the qemu executable, to make the use of qemu binary less painful. In the following session, it will be very handy to use it.
To see the options for this wrapper you can use ```qemu_guest.sh -h```.

It is possible to run a lot of complex applications on Unikraft, but in this session, we will analyze only 3 of them: Sqlite, Redis, and Nginx.

## 01. Sqlite - Set up and run SQLite

[SQLite](https://www.sqlite.org/index.html) is a C library that implements an encapsulated SQL database engine that does not require any setting or administration.
It is the most popular in the world and is different from other SQL database engines because it is simple to administer, use, maintain, and test.
Thanks to these features, SQLite is a fast, secure, and most crucial simple application.

The SQLite application is represented by a ported external library that depends on two other libraries that are also ported for Unikraft (pthread-embedded and newlib).
To successfully compile and run the SQLite application for the KVM platform and x86-64 architecture, the following steps should be performed:

1. downloading the lib-sqlite library from the Unikraft project repository directly to the libs folder.
The libraries on which lib-sqlite depends (pthread-embedded and newlib) should also be downloaded to the libs folder.

1. creating in the apps folder, a directory for the SQLite application.
In this directory, we need to create two files a Makefile containing rules for building the application as well as specifying the libraries that the application needs and a Makefile.uk used to define variables needed to compile the application or to add application-specific flags.
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

1. selecting the SQLite library from the configuration menu, Library Configuration section.
Initially, we can select the option to generate the main source file used to run the application.

1. to import or export databases or csv/sql files, the SQLite application needs to configure a filesystem.  Thus, the filesystem we use is 9pfs.
Hence, in the Library Configuration section, the 9pfs filesystem within the vfscore library should be selected.

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

Further, create a folder in the application folder called sqlite_files and write the above script into a file.
When you run the application, you can specify the path of the newly created folder to the qemu_guest.sh as following:

```
./qemu_guest.sh -k ./build/app-sqlite_kvm-x86_64 \
                -e ./sqlite_files \
                -m 500
```

The Sqlite start command has several parameters:

• `k` indicates the executable resulting from the build of the entire system together withtheRedisapplication

• `e` indicates the path to the shared directory where the Unikraft filesystem will be mounted

• `m` indicates the memory allocated to the application

Once the application start, you'll see an SQLite terminal looking the following way:
![sqlite terminal](/docs/sessions/04-complex-applications/images/sqlite_terminal.png)

To load the SQLite script you can use the following command `.read <sqlite_script_name.sql>`. And in the end, you can run `select * from tab` to see the contents of the table.

## 02. Sqlite - Change the filesystem

In the previous exercise, we have chosen to use as filesystem 9pfs. For this exercise, you'll have to change the filesystem to RamFS and load the SQLlite script as we have done in the previous exercise.

First, we need to change the filesystem to InitRD. We can obtain that by using the command `make menuconfig` and from the vfscore option, we select the default root filesystem as InitRD.

![filesystems menu](/docs/sessions/04-complex-applications/images/filesystems.png)

The InitRD filesystem can load only [cpio archives](https://www.ibm.com/docs/en/zos/2.2.0?topic=formats-cpio-format-cpio-archives), so to load our SQLite script into RamFS filesystem, 
we need to create a cpio out of it.
This can be achieved the following way: Create a folder, move the SQLite script in it, and cd in it. After that can simply run the following command: `find -depth -print | tac | bsdcpio -o --format newc > ../archive.cpio` and you'll obtain an cpio archive called `archive.cpio` in the parent directory.

Further, you need to run the following qemu command:
```
./qemu_guest.sh -k build/app-sqlite_kvm-x86_64 -m 100 -i archive.cpio
```

## 03. Redis app - Setup up and run Redis

[Redis](https://redis.io/topics/introduction) is one of the most popular key-value databases, with a design that facilitates the fast  writing  and  reading  of  data  from  memory  as  well  as  the  storage  of  data  on  disk  to  be able to reconstruct the state of data in memory in case of a system restart.
Unlike other data storage systems, Redis supports different types of data structures such as lists, maps, strings, sets, bitmaps, streams.

The Redis application is represented by a ported external library that depends on other ported libraries for Unikraft (pthread-embedded, newlib, lwip-network library).
To successfully compile  and  run  the  Redis  application  for  the KVM platform and x86-64 architecture, the following steps should be performed:

1. downloading the lib-redis library from the Unikraft project repository directly to the libs folder.
Also, the libraries on which lib-redis depends (pthread-embedded, newlib and lwip) should be downloaded to the libs folder.

1. creating in  the apps folder described in the previous sessions, a directory for the Redis application. In this directory, we should create two files a Makefile (Listing  5.5) which contains rules for building the application as well as specifying the libraries that the application needs, and a Makefile.uk used to define variables needed to compile the application or to add application-specific flags.
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

1. selecting the Redis library from the configuration menu, Library Configuration section.
Initially, we can select the option to generate the main source file used to run the application.

![redis selection menu](/docs/sessions/04-complex-applications/images/redis_menu.png)

1. to connect to the Redis server, the network features should be configured. Hence, in the configuration menu in the Library Configuration section, within the lwip library the following options should be selected:
    • `IPv4`

    • `UDP support`

    • `TCP support`

    • `ICMP support`

    • `DHCP support`

    • `Socket API`

![lwip selection menu](/docs/sessions/04-complex-applications/images/lwip_redis_menu.png)

2. the Redis application needs a configuration file to start. Thus, a filesystem should be selected in Unikraft.
The filesystem we used was 9pfs. So, in the Library Configuration section of the configuration menu, the following selection chain should be made in the vfscore library: `VFSCore  Interface → vfscore: Configuration → Automatically mount a root filesystem → Default root filesystem → 9PFS.

Therefore, following the steps above, the build of the entire system, together with the Redis application will be successful.
We used a script to run the application in which a bridge and a network interface (uk0) are created. The network interface has an IP associated with it used by clients to connect to the Redis server.
Also, the script takes care of starting the Redis server, but also of stopping it, deleting the settings created for the network.

```
brctl addbr kraft0
ifconfig kraft0 172.88.0.1
ifconfig kraft0 up

./qemu_guest.sh -k ./build/redis_kvm-x86_64 \
                -a "netdev.ipv4_addr=172.88.0.2 netdev.ipv4_gw_addr=172.88.0.1 netdev.ipv4_subnet_mask=255.255.255.0 -- /redis.conf" \
                -b kraft0 \ 
                -e ./redis_files
                -m 100
```

The Redis server start command has several parameters:
• `k` indicates the executable resulting from the build of the entire system together withtheRedisapplication

• `e` indicates the path to the shared directory where the Unikraft filesystem will be mounted

• `b` indicates the network interface used for external communication

• `m` indicates the memory allocated to the application

• `a` allows the addition of parameters specific to running the application

Consequently, after running the script the Redis server will start and it will be possible to connect clients to it using redis-cli.

![lwip selection menu](/docs/sessions/04-complex-applications/images/redis_setup.png)

## 04. Redis - Create the Redis client

For this exercise, you have to make the necessary changes using the `make menuconfig` command to build the redis client.
In the end, you should test the connectivity between the redis server and the redis-cli.

## 05. Redis - Obtain the ip dynamically

As you have seen already in the exercise 03, we have statically assigned an IP to the network interface used by Unikraft.
In this exercise, you'll have to run a dhcp server, to dynamically assing an ip on the network interface used by Unikraft. (Hint: dnsmasq)

## 06. Nginx - Set up and run Nginx

In this exercise, we will set up and run nginx.
From the point of view of the library dependencies, the nginx app has the same dependencies as the redis app.