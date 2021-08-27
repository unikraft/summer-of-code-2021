---
title: "Session 10: High Performance"
linkTitle: "10. High Performance"
---

## Required Tools and Resources

For this session, you need `kraft` and the following extra tools:
 `qemu-kvm`, `qemu-system-x86_64`, `bridge-utils`, `ifupdown`, `tshark`, `tcpdump`.
To install on Debian/Ubuntu use the following command:

```
$ sudo apt-get -y install qemu-kvm qemu-system-x86 sgabios socat bridge-utils ifupdown tshark tcpdump
```

## Overview

Welcome to the last session of our Hackathon. Here, we will introduce you on how
to develop highly specialized and performance-optimized unikernels with
Unikraft.
So far, we focused on application and POSIX compatibility, where it is important
to provide the same set of APIs and system calls that your application uses on
its original  environment (e.g., Linux). We achieve this by stacking multiple
micro-libraries that assemble these "higher-level" APIs. Imagine we speak about
network, we would typically develop network functionality based on Sockets. This
requires the following library stack being available in Unikraft for going from
Sockets down to the virtual network card:

```
 ---------------------------
( Socket application        )
 ---------------------------
              |
              V
+---------------------------+
| libvfscore                |
|                           |
|                           |
+---------------------------+
+---------------------------+
| lwip                      |
|                           |
|                           |
+---------------------------+
+---------------------------+
| libuknetdev               |
+---------------------------+
+---------------------------+
| libkvmplat                |
+---------------------------+
              |
              V
 ---------------------------
( Virtual network interface )
 ---------------------------
```

Especially the VFS layer (`libvfscore`) and the TCP/IP network stack (`liblwip`)
are complex subsystems that are potentially .

For high-performance network functions (NF) you often want to by-pass any OS
component and want to interact with the driver or hardware as direct as possible.
A known framework in the NFV area is [Intel DPDK](https://www.dpdk.org/) that
does operate network card drivers in Linux-userspace in order to avoid as much
as kernel interactions as possible. Nevertheless, you still have to maintain and
operate a complete Linux environment in production deployments.
In our case with Unikraft, we can configure the libraries to be minimal and can,
similar to Intel DPDK, directly develop our network function on top of network
drivers. In this scenario, our library stack does look like the following:

```
 ---------------------------
( High-perf NF              )
 ---------------------------
              |
              V
+---------------------------+
| libuknetdev               |
+---------------------------+
+---------------------------+
| libkvmplat                |
+---------------------------+
              |
              V
 ---------------------------
( Virtual network interface )
 ---------------------------
```

In the following you will develop a simple, high performance network packet
generator. We will guide you through various options and possibilities that can
help you developing more complex NFs with Unikraft.

## Work Items

### Support Files

Session support files are available [in the repository](https://github.com/unikraft/summer-of-code-2021).
If you already cloned the repository, update it and enter the session directory:

```
$ cd path/to/repository/clone

$ git pull --rebase

$ cd content/en/docs/sessions/10-high-performance/

$ ls
index.md  sol/
```

If you haven't cloned the repository yet, clone it and enter the session directory:

```
$ git clone https://github.com/unikraft/summer-of-code-2021

$ cd summer-of-code-2021/content/en/docs/sessions/10-high-performance/

$ ls
index.md  sol/
```

