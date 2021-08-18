---
title: "Session 07: Syscall Shim"
linkTitle: "07. Syscall Shim"
---

In this session we are going to understand how we can run applications using the binary compatibility
layer as well as the inner workings of the system call shim layer.

One of the obstacles when trying to use Unikraft could be the porting effort of your application. One
way we can avoid this is through binary compatibility. Binary compatibility is the posibility to take
already compiled binaries and run them on top of Unikraft without porting effort and at the same time
keeping the benefits of unikernels. In our case, we support binaries compiled for the Linux kernel.

In order to achieve binary compatibility with the Linux kernel, we had to find a way to have support
for system calls, for this, the system call shim layer was created. The system call shim layer provides
Linux-style mappings of system call numbers to actual system call handler functions.

## Reminders

/* TODO */ - see what other sessions offer - maybe some debug information and also some build info

## 01. The process of loading and running an application with binary compatibility

For Unikraft to achieve binary compatibility there are two main objectives that need to be met:

1. The ability to pass the binary to Unikraft
2. The ability to load the binary into memory and jump to its entry point.

For the first point we decided to use the initial ramdisk in order to pass the binary to the unikernel.
With qemu, in order to pass an initial ramdisk to a virtual machine you have to use the `-initrd` option.
As an example, if we have an helloworld binary, we can pass it to the unikernel with the following command:

```
sudo qemu-guest -kernel build/unikernel_image -initrd helloworld_binary
```

After the unikernel gets the binary the next step is to load it into memory. The dominant format for
executables is the Executable and Linkable File Format or ELF, so, in order to run executables we need
an ELF loader. The job of the Loader is to load the executable into the main memory. It does so by reading the program headers located in the ELF formatted executable and acting accordingly. For example, you can see
the program headers of a program by running `readelf -l binary`:

```
$ readelf -l helloworld_binary

Elf file type is DYN (Shared object file)
Entry point 0x8940
There are 8 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x00000000000c013e 0x00000000000c013e  R E    0x200000
  LOAD           0x00000000000c0e40 0x00000000002c0e40 0x00000000002c0e40
                 0x00000000000053b8 0x0000000000006aa0  RW     0x200000
  DYNAMIC        0x00000000000c3c18 0x00000000002c3c18 0x00000000002c3c18
                 0x00000000000001b0 0x00000000000001b0  RW     0x8
  NOTE           0x0000000000000200 0x0000000000000200 0x0000000000000200
                 0x0000000000000044 0x0000000000000044  R      0x4
  TLS            0x00000000000c0e40 0x00000000002c0e40 0x00000000002c0e40
                 0x0000000000000020 0x0000000000000060  R      0x8
  GNU_EH_FRAME   0x00000000000b3d00 0x00000000000b3d00 0x00000000000b3d00
                 0x0000000000001afc 0x0000000000001afc  R      0x4
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
  GNU_RELRO      0x00000000000c0e40 0x00000000002c0e40 0x00000000002c0e40
                 0x00000000000031c0 0x00000000000031c0  R      0x1

 Section to Segment mapping:
  Segment Sections...
   00     .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .rela.dyn .rela.plt .init .plt .plt.got .text __libc_freeres_fn __libc_thread_freeres_fn .fini .rodata .stapsdt.base .eh_frame_hdr .eh_frame .gcc_except_table
   01     .tdata .init_array .fini_array .data.rel.ro .dynamic .got .data __libc_subfreeres __libc_IO_vtables __libc_atexit __libc_thread_subfreeres .bss __libc_freeres_ptrs
   02     .dynamic
   03     .note.ABI-tag .note.gnu.build-id
   04     .tdata .tbss
   05     .eh_frame_hdr
   06
   07     .tdata .init_array .fini_array .data.rel.ro .dynamic .got
```

As an overview of the whole process, when we want to run an application on Unikraft using binary
compatibility, the first step is to pass the application to the unikernel as an initial ram disk. Once
the unikernel gets the application, the loader reads the executable segments and loads them accordingly.
After the program is loaded, the last step is to jump to its entry point and start executing.

The loader that we currently have implemented in Unikraft only supports executables that are static
(so all the libraries are part of the executables) and also position-independent. A position independent
binary is a binary that can run correctly independent of the address at which it was loaded.

## 02. Syscall shim

As stated previously the system call shim layer is the layer that we use in order to achieve the same
system call behaviour as the Linux kernel.

Let's take a code snippet that does a system call from a binary:

```
mov	edx,4		; message length
mov	ecx,msg		; message to write
mov	ebx,1		; file descriptor (stdout)
mov	eax,4		; system call number (sys_write)
syscall		    ; call kernel
```

In this case, when the `syscall` instruction gets executed, we have to reach the write function inside
our unikernel. In our case, when the `syscall` instruction gets called there are a few steps taken until
we reach the ***system call*** inside Unikraft:

1. After the `syscall` instruction gets executed we reach the `ukplat_syscall_handler`. This function
has an intermediate role, printing some debug messages and passing the correct parameters further down.
The next function that gets called is the `uk_syscall6_r` function.

```
void ukplat_syscall_handler(struct __regs *r)
{
	UK_ASSERT(r);

	uk_pr_debug("Binary system call request \"%s\" (%lu) at ip:%p (arg0=0x%lx, arg1=0x%lx, ...)\n",
		    uk_syscall_name(r->rsyscall), r->rsyscall,
		    (void *) r->rip, r->rarg0, r->rarg1);
	r->rret0 = uk_syscall6_r(r->rsyscall,
				 r->rarg0, r->rarg1, r->rarg2,
				 r->rarg3, r->rarg4, r->rarg5);
}
```

2. The `uk_syscall6_r` is the function that redirects the flow of the program to the actual ***system call***
function inside the kernel.

```
switch (nr) {
	case SYS_brk:
		return uk_syscall_r_brk(arg1);
	case SYS_arch_prctl:
		return uk_syscall_r_arch_prctl(arg1, arg2, arg3);
	case SYS_exit:
		return uk_syscall_r_exit(arg1);
    ...
```

All the above functions are generated, so the only thing that we have to do when we want to register
a system call to the system call shim layer is to use the correct macros.

There are two definition macros that we can use in order to add a system call to the system call shim
layer: `UK_SYSCALL_DEFINE` and `UK_SYSCALL_R_DEFINE`. Apart from using the macro to define the function
we also have to register the system call by adding it to `UK_PROVIDED_SYSCALLS-y` withing the corresponding
`Makefile.uk` file. Let's see how this is done with an example for the write system call:

We have the following deffinition of the write system call:

```
ssize_t write(int fd, const void * buf, size_t count)
{
    ssize_t ret;

    ret = vfs_do_write(fd, buf, count);
    if (ret < 0) {
        errno = EFAULT;
        return -1;
    }
    return ret;
}
```

The next step is to define the function using the corect macro:

```
#include <uk/syscall.h>

UK_SYSCALL_DEFINE(ssize_t, write, int, fd, const void *, buf, size_t, count)
{
    ssize_t ret;

    ret = vfs_do_write(fd, buf, count);
    if (ret < 0) {
        errno = EFAULT;
        return -1;
    }
    return ret;
}
```

The last step is to add the system call to `UK_PROVIDED_SYSCALLS-y` in the `Makefile.uk` file. The format
is:

`UK_PROVIDED_SYSCALLS-$(CONFIG_<YOURLIB>) += <syscall_name>-<number_of_arguments>`

So, in our case:

`UK_PROVIDED_SYSCALLS-$(CONFIG_LIBWRITESYS) += write-3`

## Summary

The binary compatibility layer is a very important part of the Unikraft unikernel because it helps us
run applications that were not build for Unikraft but in the same time keeps the classic benefits
of Unikraft: speed, security and small memory footprint.

## Practical Work

For the practical work we will need the following prerequisites:

* **gcc version at least 8.4.0**

* **the elfloader application** - this is the implementation of our loader which is build like a normal
Unikraft application. You can clone the loader [here](https://github.com/skuenzer/app-elfloader/tree/usoc21). This cloned repo should go into the `apps` folder in your Unikraft directory structure.

* **the configuration file** - you can find the config files in the `demo/01` and `demo/03` folder of
this session.

* **lwip, zydis, libelf libs** - we have to clone all the repos coresponding to the previously mentioned
libraries into the libs folder. All of them have to be on the `staging` branch.
    * [lwip](https://github.com/unikraft/lwip.git)
    * [zydis](https://github.com/unikraft/lib-zydis.git)
    * [libelf](https://github.com/unikraft/lib-libelf.git)

* **unikraft** - for Unikraft we also have to be on the `usoc21` branch.

So, the final directory structure for this session should look like this:

```
|── apps
|   |── app-elfloader[usoc21]
|── libs
|   |── lwip[staging]
|   |── libelf[staging]
|   |── zydis[staging]
└── unikraft[usoc21]
```

### 01. Compiling the elfloader application

The goal of this task is to make sure that our setup is correct. The first step is to copy the
correct config file into our application.

```
student:~/apps/app-elfloader$ cp demo/01/config .config
```

To check that the config file is the correct one, run `make menuconfig`, then select `library configuration`
and it should look like this:

![Libraries configuration](images/config-image)

If everything is correct, we can run `make` and the image for our unikernel should be compiled. In the
`build` folder you should have the `elfloader_kvm-x86_64` binary.

To also test if it runs correctly:

```
student:~/apps/app-elfloader$ qemu-guest -k build/elfloader_kvm-x86_64

SeaBIOS (version 1.10.2-1ubuntu1)
Booting from ROM...
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Tethys 0.5.0~825b1150
[    0.105192] ERR:  <0x3f20000> [appelfloader] No image found (initrd parameter missing?)
```

Because we did not pass an initial ramdisk, the loader does not have anything to load, so that's where
the error comes from.

### 02. Compile a static-pie executable and run it on top of Unikraft

The next step to our purpose of running an executable on top of Unikraft is to get an executable
with the correct format, that is, a static executable that also contains position independent code.

We can now go to the `apps/app-elfloader/example/helloworld` directory. We can see that the directory
has a `helloworld.c` (a simple helloworld program) and a `Makefile`. If we inspect the `Makefile` we
can notice that the program will be compiled as a static-pie executable:

``` Makefile
RM = rm -f
CC = gcc
CFLAGS += -O2 -g -fpie # fpie generates position independet code in the object file
LDFLAGS += -static-pie # static-pie makes the final linking generate a static and a pie executable
LDLIBS +=

all: helloworld

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%: %.o
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

helloworld: helloworld.o

clean:
	$(RM) *.o *~ core helloworld
```

We can now run `make` so we can get the `helloworld` executable.

```
student:~/apps/app-elfloader/example/helloworld$ make
gcc -O2 -g -fpie -c helloworld.c -o helloworld.o
gcc -static-pie helloworld.o  -o helloworld

student:~/apps/app-elfloader/example/helloworld$ ldd helloworld
	statically linked

student:~/apps/app-elfloader/example/helloworld$ checksec helloworld
[*] '/home/daniel/Faculty/BachelorThesis/apps/app-elfloader/example/helloworld/helloworld'
    Arch:     amd64-64-little
    RELRO:    Full RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      PIE enabled

```

We can see that the `helloworld` executable is a static-pie executable.

Now, the last part is to pass this executable to our unikernel. We can use the `-i` option to pass
the initial ramdisk to the virtual machine.

```
student:~/apps/app-elfloader$ qemu-guest -k build/elfloader_kvm-x86_64 -i example/helloworld/helloworld

SeaBIOS (version 1.10.2-1ubuntu1)
Booting from ROM...
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Tethys 0.5.0~825b1150
Hello world!
```

We can see that the binary is succesfully loaded and executed.

### 03. Let's dive deeper.

Now that we saw how we can run an executable on top of Unikraft though binary compatibility, let's take
a look at what happens behind the scenes. For this we have to compile the unikernel with the debug
printing.

Copy the config_debug file to our application folder:

```
student:~/apps/app-elfloader$ cp demo/03/config_debug unikraft_root/apps/app-elfloader/.config
```
Now, recompile the unikernel:

```
student:~/apps/app-elfloader$ make clean
...
student:~/apps/app-elfloader$ make
```

Now, let's rerun the previously compiled executable on top of Unikraft:

```
student:~/apps/app-elfloader$ qemu-guest -k build/elfloader_kvm-x86_64 -i example/helloworld/helloworld

SeaBIOS (version 1.10.2-1ubuntu1)
Booting from ROM...
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Tethys 0.5.0~825b1150
[    0.153848] dbg:  <0x3f20000> [libukboot] Call constructor: 0x10b810()...
[    0.156271] dbg:  <0x3f20000> [appelfloader] Searching for image...
[    0.159115] dbg:  <0x3f20000> [appelfloader] Load image...
[    0.161569] dbg:  <0x3f20000> [appelfloader] build/elfloader_kvm-x86_64: ELF machine type: 62
[    0.164844] dbg:  <0x3f20000> [appelfloader] build/elfloader_kvm-x86_64: ELF OS ABI: 3
[    0.167843] dbg:  <0x3f20000> [appelfloader] build/elfloader_kvm-x86_64: ELF object type: 3
.....
```
We now have a more detailed output to see exactly what happens. The debug output is divided as follows:

1. Debug information that comes from when the unikernel is executing.
2. Debug information that comes from when the binary is executing.

When the unikernel is executing (so our loader application) there are two phases:

1. The loading phase - copies the contents of the binary at certain memory zones, as specified by the
ELF header. You can see the loading phase in the debug output:

```
[appelfloader] Load image...
....
[appelfloader] build/elfloader_kvm-x86_64: Program/Library memory region: 0x3801000-0x3ac88e0 <- this is the memory zone where our binary will be mapped
[appelfloader] build/elfloader_kvm-x86_64: Copying 0x171000 - 0x23113e -> 0x3801000 - 0x38c113e <- actual copying of the binary
[appelfloader] build/elfloader_kvm-x86_64: Zeroing 0x38c113e - 0x38c113e <- zeroing out zones of the binary, like the bss
...
```

2. The execution phase - sets the correct information on the stack (for example environment variables) and jumps to the program entry point.

```
[appelfloader] Execute image...
[appelfloader] build/elfloader_kvm-x86_64: image:          0x3801000 - 0x3ac88e0
[appelfloader] build/elfloader_kvm-x86_64: start:          0x3801000
[appelfloader] build/elfloader_kvm-x86_64: entry:          0x3809940
[appelfloader] build/elfloader_kvm-x86_64: ehdr_phoff:     0x40
[appelfloader] build/elfloader_kvm-x86_64: ehdr_phnum:     8
[appelfloader] build/elfloader_kvm-x86_64: ehdr_phentsize: 0x38
[appelfloader] build/elfloader_kvm-x86_64: rnd16 at 0x3f1ff20
[appelfloader] Jump to program entry point at 0x3809940...
```

From this point forward, the binary that we passed in the initial ramdisk starts executing. Now all the
debug messages come from an operation that happened in the binary. We can also now see the syscall shim
layer in action:

```
[libsyscall_shim] Binary system call request "write" (1) at ip:0x3851c21 (arg0=0x1, arg1=0x3c01640, ...)
Hello world!
```

In the above case, the binary made a `write` system call in order to write ***Hello world!*** to our
`stdin`.

### 04. Solve the missing syscall

For the last part of today's session we will try to run another binary on top of Unikraft. You can find
the C program in the `04-missing-syscall` directory. Try compiling it as static-pie and then run it
on top of Unikraft.

```
[libsyscall_shim] Binary system call request "getcpu" (309) at ip:0x3851926 (arg0=0x3f1fc14, arg1=0x0, ...)
[libsyscall_shim] syscall "getcpu" is not available
[libsyscall_shim] Binary system call request "write" (1) at ip:0x3851cb1 (arg0=0x1, arg1=0x3c01640, ...)
Here we are in the binary, calling getcpu
Getcpu returned: -1
```

Your task is to print a debug message betweem `Here we are in the binary` and `Getcpu returned` and
also make the `sched_getcpu()` return 0.

Hint 1: http://docs.unikraft.org/developers-app.html#syscall-shim-layer

Hint 2: check the `brk.c`, `Makefile.uk` and `exportsyms.uk` file in the app-elfloader directory. You
do not have to use `UK_LLSYSCALL_R_DEFINE`, instead, use the two other macros previously described
in the session (eg. `UK_SYSCALL_DEFINE` and `UK_SYSCALL_R_DEFINE`).

## Further Reading

https://dtrugman.medium.com/elf-loaders-libraries-and-executables-on-linux-e5cfce318f94
>>>>>>> Add session content for 07:Binary compatibility and syscall shim
