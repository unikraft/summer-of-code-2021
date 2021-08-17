---
title: "Session 02: Behind the Scenes"
linkTitle: "02. Behind the Scenes"
---

# Reminders
## Kraft

# Session Theory
## 01. Virtualization - high vision
Through virtualization, multiple Operating Systems are able to run on the same
hardware, independently, thinking that each one of them controls the entire system.
This can be done using a hypervisor. There are 2 main virtualized environments:
virtual machines and containers. Unikernels come somewhere between those 2.

### Virtual machines 
Virtual machines represent an abstraction of the hardware, over which an
Operating System can run, thinking that it is alone on the system, and that it
controls the hardware below it. This is done with the aid of hypervisors, special
software components that virtualize the hardware. There are 2 types of hypervisors, Type 1 and Type 2.
We won't go in depth into them, but it is good to know how they are different:
 * The Type 1 hypervisor, also known as as bare-metal hypervisor, has direct access to the hardware,
 and controls all the Operating Systems that are running on the system.
 KVM, despite the appearances, is a Type 1 hypervisor.
 * The Type 2 hypervisor, also known as hosted hypervisor,
 has to go through the host operating system to reach the hardware.
 An example of Type 2 hypervisor is QEMU.

| ![type 1 hypervisor os](/docs/sessions/02-behind-scenes/images/vm1.svg) | ![type 2 hypervisor os](/docs/sessions/02-behind-scenes/images/vm2.svg) |
| :--:									  | :--:								    |
| Operating systems over type 1 hypervisor				  | Operating systems over type 2 hypervisor 				    |

### Containers
Containers are environments designed to contain and run only one application and its dependecies.
This leads to very small sizes. The containers are managed by a Container Management Engine,
like Docker, and are dependent on the Host OS, as they cannot run without it.

| ![containers](/docs/sessions/02-behind-scenes/images/container.svg)	|
| :--: 									|
| Containers								|

### Unikraft
Unikraft has a size comparable with that of a container, while it retains the power of a virtual machine,
meaning it can directly control the hardware components (virtualized, or not, if running bare-metal).
This gives it an advantage over classical OS'es. Being a special type of Operating System,
Unikraft can run bare-metal, or over a hypervisor.

| ![type 1 hypervisor uk](/docs/sessions/02-behind-scenes/images/unikraft1.svg) | ![type 2 hypervisor uk](/docs/sessions/02-behind-scenes/images/unikraft2.svg) |
| :--: | :--: |
| Unikraft over Type 1 hypervisor                                                  | Unikraft over type 2 hypervisor                           		|

## 02. linuxu and kvm
Unikraft can be run in 2 ways: 
 * the virtualized one, using kvm or xen, in which it behaves as an Operating System,
 having the responsibility to configure the hardware components that it needs
 (clocks, additional processors, etc). This mode gives Unikraft direct and total control
 over the hardware components, allowing advanced functionalities.
 * linuxu, in which it behaves as a Linux user-space application.
 This severely limits its performance, as everything Unikraft does must go through the Linux kernel,
 via system calls. This mode should be used only for debugging.

When Unikraft is running using kvm, it can either be run on an emulated system,
or a (para)virtualized one. Emulation is slower, but it allows using architectures
different from the local one (you can run ARM code on a x86 machine).
Using (para)virtualisation, aka hardware acceleration, greater speed is achieved,
and more hardware components are visible to Unikraft.

## 03. Unikraft core - main components
The Unikraft core is comprised of several components:
 * [the architecture code](https://github.com/unikraft/unikraft/tree/staging/arch),
 which defines behaviours and hardware interactions specific to the target architecture (x86_64, ARM, RISC-V).
 For example, for the x86_64 architecture, this component defines the usable registers,
 data types sizes and how Thread-Local Storage should happen.
 * [the platform code](https://github.com/unikraft/unikraft/tree/staging/plat),
 which defines interaction with the underlying hardware, depending on whether a hypervisor is present or not,
 and which hypervisor is present. For example, if the kvm hypervisor is present,
 Unikraft will behave almost as if it runs bare-metal,
 needing to initialize the hardware components according to the manufacturer specifications.
 The difference from bare-metal is made only at the entry, where some information,
 like the memory layout, the available console, are supplied by the bootloader (Multiboot),
 and there’s no need to interact with the BIOS or UEFI.
 In the case of Xen, many of the hardware-related operations must be done through hypercalls,
 thus reducing the direct interaction of Unikraft with the hardware.
 * [internal libraries](https://github.com/unikraft/unikraft/tree/staging/lib),
 which define behaviour independent of the hardware, like scheduling, networking, memory allocation, basic file systems.
 These libraries are the same for every platform or architecture,
 and rely on the platform code and the architecture code to perform the needed actions.
 The internal libraries differ from the external ones in the implemented functionalities.
 The internal ones define parts of the kernel, while the external ones define user-space level functionalities.
 For example, uknetdev and lwip are 2 libraries that define networking components.
 [Uknetdev](https://github.com/unikraft/unikraft/tree/staging/lib/uknetdev) is an
 internal library that interacts with the network card and defines how packages are sent using it.
 [Lwip](https://github.com/unikraft/lib-lwip) is an external library, that defines networking protocols, like IP, TCP, UDP.
 This library knows that the packages are somehow sent over the NIC, but it is not concerned how.
 That is the job of the kernel.

## 04. libc in Unikraft
 * [nolibc](https://github.com/unikraft/unikraft/tree/staging/lib/nolibc) is
 a minimalistic libc, part of the core Unikraft code, that contains only the functionality needed for the core (strings, qsort, etc).
 * [isrlib](https://github.com/unikraft/unikraft/tree/staging/lib/isrlib) is
 the interrupt-context safe variant of nolibc. It is used for interrupt handling code.
 * [newlibc](https://github.com/unikraft/lib-newlib) is the most complete libc currently available for Unikraft,
 but it still lacks some functionalities, like multithreading.
 Newlibc was designed for embedded environments.
 * [musl](https://github.com/unikraft/lib-musl) is, theoretically, the best libc that will be used by Unikraft,
 but it’s currently under testing.

As said before, nolibc and isrlib are part of the Unikraft core.
newlibc and musl are external libraries, from the point of view of Unikraft,
and they must be included to the build, as seen in the previous session.

## 05. Configuring Unikraft - Config.uk
Unikraft is a configurable Operating System, where each component can be modified, configured, according to the user’s needs.
This Configuration is done using a version of Kconfig, through the **Config.uk** files.
In these files, options are added to enable libraries, applications and different components of the Unikraft core.
The user can then apply those configuration options, using `make menuconfig`,
which generates an internal configuration file that can be understood by the build system, **.config**.
Once configured, the Unikraft image can be built, using make, and run, using the appropriate method (Linux ELF loader, qemu-kvm, xen, others).

## 06. The Bulid System - basics
Once the application is configured, in **.config**, symbols are defined(eg. CONFIG_ARCH_X86_64).
Those symbols are usable both in the C code, to include certain functionalities only if they were selected in the configuring process,
and in the actual building process, to include/ exclude source files, or whole libraries.
This last thing is done in **Makefile.uk**, where source code files are added to libraries.
During the build process, all the Makefile.uk files are evaluated, and the selected files are compiled and linked, to form the Unikraft image.

| ![unikraft build](/docs/sessions/02-behind-scenes/images/build_uk.svg) |
| :--: 									 |
| The build process of Unikraft 					 |

# Summary
 * Unikraft is a special type of Operating System, that can be configured to match the needs of a specific application.
 * This configuration is made possible by a system based on Kconfig, that uses **Config.uk** files to add possible configurations,
 and **.config** files to store the configuration for the build.
 * The configuration step creates symbols, taht are visible in both Makefiles and source code.
 * Each component has its own **Makefile.uk**, where source files can be added or removed, and be made dependent on the configuration. 
 * Unikraft has an internal libc, but it can use other, more complex and complete, libcs, like newlib and musl.
 * Being an Operating System, it needs to be run by a hypervisor, like kvm, xen, to work at full capacity.
 It can also be run as an ELF, in Linux, but in this way, the true power of Unikraft is not achieved.

# Work items
## 01. Going through the code
Go through the [Unikraft core repository](https://github.com/unikraft/unikraft).
Look in the platform code for **linuxu** and **kvm**. Spot the differences between what is required for the 2 platforms.
See what components are initialized in **setup.c**, in both cases.

## 02. Reminder: Building and running Unikraft
Build the core Unikraft image for the **linuxu** and **kvm** platforms, and run them.
For the linuxu image, it will be like running a Linux ELF. For the kvm image, use **qemu-system**.

## 03. Different architectures
Build the core Unikraft image for the kvm platform, for the **ARM** and **x86** architectures, and run them.

## 04. Make it speak
Enable the internal debugging library for Unikraft (ukdebug), and make it display messages up to debug level.
Identify which hardware components are initialized for both x86 and ARM, and where.

## 05. Emulation vs Virtualization
Run the Unikraft core image, for kvm platform, x86 architecture, and measure the runtime, first without using kvm hardware acceleration, then while using it.

## 06. Reminder: Using kraft
Run the [helloworld app](https://github.com/unikraft/app-helloworld), using kraft.

## 07. Tutorial: Adding filesystems to an application
Modify the helloworld app, to use the 9pfs filesystem: read something from a file, and display it.
Use kraft, the qemu-guest script, and qemu-system to run the modified application.

Some parts of this tutorial were already discussed last session.

### The code
First of all, we need to write some simple code, to read from a file. We will do this in main.c.
```
	FILE *in = fopen("file", "r");
	char buffer[100];

	fread(buffer, 1, 100, in);
	printf("File contents: %s\n", buffer);
	fclose(in);
```
In the application's folder, we will create a folder, `guest_fs` (or any other name).
In this folder, we will add our file.

### Configuring the application
First, we need to add a more powerfull libc. Newlib will do nicely. For this, in the Makefile file, we add the following line:
```
LIBS := $(UK_LIBS)/newlib
```

Now we need to enable 9pfs and newlib in Unikraft. To do this, we run ```make menuconfig```

We need to select the following options, from the Library Configuration menu:
 * libnewlib
 * vfscore
 * vfscore: Configuration -> Automatically mount a root filesystem
			     Default root filesystem -> 9pfs

These configurations will also mark as required **9pfs** and **uk9p** in the menu.

We want to run Unikraft with qemu-kvm, so we must selevct **KVM guest** in the Platform Configuration menu.

Save, exit, and run ```make```. Building the Unikraft image will take a while.

### Running with qemu-system-x86_64
To run the Unikraft image with qemu-kvm, we use the following command:
```
qemu-system-x86_64 -fsdev local,id=myid,path=guest_fs,security_model=none -device virtio-9p-pci,fsdev=myid,mount_tag=rootfs,disable-modern=on,disable-legacy=off -kernel build/app-helloworld_kvm-x86_64 -serial stdio
```
Lets break it down:
 * ```-serial stdio``` - prints the output of qemu to the stdio
 * ```-kernel build/app-helloworld_kvm-x86_64``` - tells qemu that it will run a kernel;
 if this parameter is omited, qemu will think it runs a raw file
 * ```-fsdev local,id=myid,path=guest_fs,security_model=none``` - assign an id to the guest_fs local folder
 * ```-device virtio-9p-pci,fsdev=myid,mount_tag=rootfs``` - create a device with the 9pfs type,
 link to it the ID from above, and assign it a mount tag.
 Unikraft will look after that mount tag when trying to mount the filesystem,
 so it is important that the mount tag from the configuration is the same as the one given as argument to qemu.

### Runing with qemu-guest
[qemu-guest](https://github.com/unikraft/kraft/blob/staging/scripts/qemu-guest)
is the script used by kraft to run its qemu-kvm images. Before looking at the command,
take some time to look through the script, and maybe figure out the arguments needed for our task.

To run Unikraft using qemu-guest, we use:
```
./qemu-guest -e guest_fs/ -k build/app-helloworld_kvm-x86_64
```

If we add the -D option, we can see the qemu-system command generated.

You may get the following error:
```
[    0.100664] CRIT: [libvfscore] <rootfs.c @  122> Failed to mount /: 22
```
If you do, check that the mount tag in the configuration is the same as the one used by qemu-guest.
qemu-guest will use the tag **fs0**.

### Enter kraft
With kraft, the whole process of configuring, building and running Unikraft can be made easier.
First, we need to modify **kraft.yaml**, to reflect our new configuration, like this:
```
---
specification: '0.5'
name: helloworld
unikraft:
  version: staging
  kconfig:
    - CONFIG_LIBUK9P=y
    - CONFIG_LIB9PFS=y
    - CONFIG_LIBVFSCORE_AUTOMOUNT_ROOTFS=y
    - CONFIG_LIBVFSCORE_ROOTFS_9PFS=y
    - CONFIG_LIBVFSCORE_ROOTDEV="fs0"
targets:
  - architecture: x86_64
    platform: kvm
libraries:
  newlib:
    version: staging
    kconfig:
      - CONFIG_LIBNEWLIBC=y
volumes:
  fs0:
    driver: 9pfs
    source: guest_fs.tgz
```
TODO: the archive - I don't know if it's needed to be an archive; it doesn't run either way

Next, we will make kraft reconfigure our application, using ```kraft configure -y```.
In our case, nothing will be modified in **.config**, as we had the same configuration before.
If you get an error like "missing component: newlib", you need to run ```kraft list update```.

Then, use
```
kraft build
kraft run
```
You should see(about that...) the contents of you file displayed. 

## 08. Give the user a choice
Modify **Config.uk**, for the helloworld app, so that the user can choose if the app will display “Hello world”,
or what it reads from the file from the previous exercise. You will also need to make changes in the source code.

## 09. Arguments from command line
Configure the helloworld app to receive command line arguments and print them.
Send it some arguments.

## 10. Adding a new source file
Create a new source file for your application, and implement a function that sorts a given integer array,
by calling qsort, in turn, from different libc variants, and then prints that array.
For each library, check the size of the Unikraft image. Enable **nolibc**, and then, as a separate config / build, **newlibc**,
both by using **make menuconfig** and modifying **kraft.yaml**. You will have four different configurations and builds:
 * nolibc + kraft
 * nolibc + make
 * newlibc + kraft
 * newlibc + make

## 11. More power to the user
Add the possibility to include the new source file only if a configuration option is selected.
Make sure than after this change, the application can still be built and run.

## 12. Less power to the user
Delete Config.uk and reconfigure/ rebuild the app. What happens when you run the app?
