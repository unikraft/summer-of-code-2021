---
title: "Session 01: Baby Steps"
linkTitle: "01. Baby Steps"
date: 2021-07-22
---
In this session we are going to understand the basic layout of the Unikraft working directory, its environment variables, as well as what the most common Unikraft specific files mean.
We are also going to take a look at how we can build basic applications and how we can extend their functionality and support by adding ported external libraries.

## 00. Manual kraft installation
First of all, make sure you have all the dependencies installed:
```
apt-get install -y --no-install-recommends build-essential libncurses-dev libyaml-dev flex git wget socat bison unzip uuid-runtime;
```

We begin by cloning the kraft repository on our  machine:
```
git clone https://github.com/unikraft/kraft.git
```

Now, all we have to do is enter this directory and run the setup installer:
```
cd kraft
python3 setup.py install
```

Since this is the first time we get kraft in our system, we need to run ```kraft list update``` which will download Unikraft core source code and additional library pool sources.
By default, these are saved to ```~/.unikraft```, which is also the value of the ```UK_WORKDIR``` environment variable.
This represents the working directory for all Unikraft source code.

This is the usual layout of the Unikraft directory:
```
├── apps - This is where you would normally place existing app build
├── archs - Here we place our custom arch’s files
├── libs - This is where the build system looks for external library pool sources
├── plats - The files for our custom plats are placed here
└── unikraft - The core source code of the Unikraft Unikernel
```

There are also environment variables available for each of the above subdirectories:
```
UK_ROOT - The directory for Unikraft's core source code [default: $UK_WORKDIR/unikraft]
UK_LIBS - The directory of all the external Unikraft libraries [default: $UK_WORKDIR/libs]
UK_APPS - The directory of all the template applications [default: $UK_WORKDIR/apps]
```

After successfully running the above commands, you now have kraft installed on your system and we are ready to build some unikernels!

## 01. Building the Helloworld Application
### Automatic build through ```kraft```
This is where the fun part begins - we get to build our first unikernel!
We will start by using ```kraft``` so that it can automatically do the heavy lifting for us.

First, go into first demo's directory
```
cd demo/01-hello-world
```

Now, we initialize the build by using the already existing template for the helloworld app.
```
kraft init -t helloworld
```

If you were to inspect the current directory you would see that some new interesting files appeared.
These are very important for the build system and have the following meanings:
```
kraft.yaml – This file holds information about which version of the Unikraft core, additional libraries, which architectures and platforms to target and which network bridges and volumes to mount durirng runtime.

Makefile.uk – A Kconfig target file you can use to create compile-time toggles for your application.

build/ – All build artifacts are placed in this directory including intermediate object files and unikernel images.

.config – The selection of options for architecture, platform, libraries and your application (specified in Makefile.uk) to use with Unikraft.
```

Next, we tell kraft which platform and architecture we desire our unikernel to be built for.
```
kraft configure -p PLAT -m ARCH
```

For this example, we are going to build this application for the ```Linuxu``` (Linux Userspace) and ```KVM``` (Kernel Virtual Machine) platforms and the ```x86_64``` architecture.
Let's begin with the ```linuxu``` platform.
```
kraft configure -p linuxu -m x86_64
```

Everything is set up now, all we have left to do is tell the build system to do its magic.
```
kraft build
```

Note that this builds the final unikernel image through the stable branch of the unikraft core source code.
If you desire to build it on another branch you should use the ```-Xv``` additional option.

And that’s it! Our final unikernel binary is ready to be launched from the ```build/``` directory.
We could simply tell kraft to run it for us through the following command:
```
kraft run -p linuxu -m x86_64
```

In order to build this for the ```KVM``` platform, all we have to do is simply replace ```linuxu``` with ```kvm```.
```
kraft configure -p kvm -m x86_64
kraft build
kraft run -p kvm -m x86_64
```

Of course, this is the most basic way you can use ```kraft```, but there are many other options.
To see every option ```kraft``` has to offer, you can simply type ```kraft -h```.
If you want to know about a certain command, just follow it with the ```-h``` option.
For example, if I wanted to know more about the configure command, I would type ```kraft configure -h```.

### Manually building the ```helloworld``` application
Let’s now learn how to build the app manually, without ```kraft```!

First, get out of the current build’s directory and make a new one:
```
cd ../ && mkdir 01-hello-world-manual && cd 01-hello-world-manual
```

Now, clone the remote git repository:
```
git clone https://github.com/unikraft/app-helloworld.git .
```

In order to tell the build system how we want our final unikernel image to be built we can use the built-in ```ncurses menu```:
```
make menuconfig
```

Looks like we are met with an error!
```
$ make menuconfig
Makefile:9: recipe for target 'menuconfig' failed
make: *** [menuconfig] Error 2
```

The reason this happens is because the build system assumes we are inside ```~/.unikraft/apps/app-helloworld-manual```, which is not the case.
If you remember correctly, the build system makes use of some important environment variables, namely ```UK_WORKDIR```, ```UK_ROOT``` and ```UK_LIBS```.
In order to properly inform the build system of our current location we will have to manually set these by prefixing whatever build command we send with the hardcoded values of where our ```Unikraft``` work directory is.
```
$ UK_WORKDIR=~/.unikraft UK_ROOT=~/.unikraft/unikraft UK_LIBS=~/.unikraft/libs  make menuconfig
```
Note: This menu is also available through the ```kraft menuconfig``` command, which rids you of the hassle of manually setting the environment variables.

We are met with the following configuration menu. Let's pick the architecture:

![arch selection menu](/docs/sessions/01-baby-steps/images/menuconfig_select_arch.png)

![arch selection menu2](/docs/sessions/01-baby-steps/images/menuconfig_select_arch2.png)

![arch selection menu3](/docs/sessions/01-baby-steps/images/menuconfig_select_arch3.png)

Now, press ```Exit``` until you return to the initial menu.

We have now set our desired architecture, let's now proceed with the platform. We will choose both ```linuxu``` and ```kvm```:

![plat selection menu](/docs/sessions/01-baby-steps/images/menuconfig_select_plat.png)

![plat selection menu2](/docs/sessions/01-baby-steps/images/menuconfig_select_plat2.png)

That's all for now! Just ```Save``` and exit the configuration menu by repeatedly selecting ```Exit```.

Now let's build the final image! (Don't forget the environment variables!)
```
$ UK_WORKDIR=~/.unikraft UK_ROOT=~/.unikraft/unikraft UK_LIBS=~/.unikraft/libs  make
```

Done! Our final binaries are located inside ```build/```. Let's run both and see the output!
```
$ ./build/01-hello-world-manual_linuxu-x86_64  # The linuxu image
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                   Tethys 0.5.0~b8be82b
Hello world!
```

```
$ qemu-guest -k build/01-hello-world-manual_kvm-x86_64  # The kvm image
SeaBIOS (version rel-1.14.0-0-g155821a1990b-prebuilt.qemu.org)
Booting from ROM...
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                   Tethys 0.5.0~825b115
Hello world!
```


## 02. Building the ```httpreply``` application
This is where we will take a look at how to build a basic ```HTTP Server``` both through ```kraft``` and manually.
The latter involves understanding how to integrate ported external libraries, such as ```lwip```.

### Building through kraft
Just like before, we begin by switching to the correct directory.
```
cd ../02-httpreply
```

Then, by using ```kraft``` we retrieve the already existing template for ```httpreply```.
```
kraft init -t httpreply
```

Then the process is exactly the same as before:
```
kraft configure -p PLAT -m ARCH 
kraft build
kraft run -p PLAT -m ARCH
```

```kraft``` takes care of everything for us!

### Manually building ```httpreply``` application
First, move into a new directory and clone the ```httpreply``` repo there.
```
cd .. && mkdir 02-httpreply-manual && cd 02-httpreply-manual
git clone https://github.com/unikraft/app-httpreply .
```

Unlike before, you can notice that this time we are missing the regular ```Makefile``` - instead we only have ```Makefile.uk```, which is used by ```kraft```.
Open your favorite code editor, create a new ```Makefile``` and paste there the following:
```
UK_ROOT ?= $(PWD)/../../unikraft
UK_LIBS ?= $(PWD)/../../libs
LIBS :=

all:
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS)

$(MAKECMDGOALS):
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) $(MAKECMDGOALS)
```

This is how our ```Makefile``` usually looks. As you can see, the previously presented environment values make the same wrong assumption.
Previously, we fixed this by preceding the ```make``` command with the updated values for the environment variables, but we could have also simply modified them from within the ```Makefile```, like so:
```
UK_ROOT ?= $(HOME)/.unikraft/unikraft
UK_LIBS ?= $(HOME)/.unikraft/libs
LIBS :=

all:
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS)

$(MAKECMDGOALS):
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) $(MAKECMDGOALS)
```

Now, we just have to invoke ```make``` (it will also automatically call ```make menuconfig``` if we do not have a previous configuration).
The configuration steps are the same as in our previous manual ```helloworld``` application build.

We are, however, met with an error:
```
main.c:38:10: fatal error: sys/socket.h: No such file or directory
 #include <sys/socket.h>
          ^~~~~~~~~~~~~~
compilation terminated.
```

This is caused by the fact that we are missing the networking library, ```lwip```.
We add it by first downloading it on our system in ```$(UK_WORKDIR)/libs/```, or ```~/.unikraft/libs```.
```
$ git clone https://github.com/unikraft/lib-lwip ~/.unikraft/libs/lwip
fatal: destination path '~/.unikraft/libs/lwip' already exists and is not an empty directory.
```
Looks like it is already there! That is because ```kraft``` took care of it for us behind the scenes in our previous automatic build.

Next step is to add this library in the ```Makefile```:
```
UK_ROOT ?= $(HOME)/.unikraft/unikraft
UK_LIBS ?= $(HOME)/.unikraft/libs
LIBS := $(UK_LIBS)/lwip

all:
        @$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS)

$(MAKECMDGOALS):
        @$(MAKE) -C $(UK_ROOT) A=$(PWD) L=$(LIBS) $(MAKECMDGOALS)
```

Now, we configure it through ```make menuconfig```.

![lwip selection menu](/docs/sessions/01-baby-steps/images/menuconfig_select_lwip.png)

![lwip2 selection menu](/docs/sessions/01-baby-steps/images/menuconfig_select_lwip2.png)

If you noticed, the menu also automatically selected some other internal components that would be required by ```lwip```.
Now ```Save``` and ```Exit``` the configuration and run ```make```!

## Summary
```kraft``` is an extremely useful tool for quickly deploying unikernel images.
It abstracts away many factors that would normally increase the difficulty of such tasks.
Through just a simple set of a few commands we can build and run a set of fast and secure unikernel images with low memory footprint.

## Practical Work

## 01. Echo-back Server
You will have to implement a simple ```Echo-back Server``` in ```C``` for the ```KVM``` platofrm by using the given ```main.c``` skeleton.
The application will have to be able to open a socket on ```172.44.0.2:1234``` and send back to the client whatever the client sends to the server.
If the client closes the connection, the server will automatically close.

You will need:
```
- Some network client utility like netcat (you can also build your own!).
- The Light Weight TCP/IP stack library (lwip): https://github.com/unikraft/lib-lwip						
- The work/01-echo-back/ directory includes everything you need, but you will have to bring the required modifications on your own
- If you want to run the application without kraft, the KVM launch script and network setup is already included inside /work/01-echo-back/launch.sh
```

To test if your application works you can try sending it messages like so:
```
nc 172.44.0.2 1234
```

Now, after connecting to the server, whatever you enter in standard input, should be echoed back to you.


## 02. ROT-13
Update the previously built application, to echo back a ```rot-13``` encoded message.
To do this, you will have to create custom function inside ```lwip``` (~/.unikraft/libs/lwip/```) that you application (from the new directory work/02-rot13) can call in order to encode the string.
For example, you could implement the function ```void rot13(char *msg);``` inside ```~/.unikraft/libs/lwip/sockets.c``` and add its header inside ```~/.unikraft/libs/lwip/include/sys/socket.h```.

The required resources are the exact same as in the previous exercise, you will just have to update ```lwip```!
To test if this works, use the same methodology as before, but ensure that the echoed back string is encoded!

## 03. Tutorial: Mount 9pfs
In this tutorial we will see what we would need to do if we wanted to have a filesystem available.
To make it easy, we will use the ```9pfs``` filesystem, as well as ```newlib``` as a lightweight library.
The latter is used so that we have available an ```API``` that would enable us to interact with this filesystem (functions such as ```lseek```, ```open```).

We will need to download ```newlib```:
```
git clone https://github.com/unikraft/lib-newlib.git ~/.unikraft/libs/newlib
```

Next, we include it in our ```Makefile```:
```
LIBS := $(UK_LIBS)/lwip:$(UK_LIBS)/newlib
```

And now, for the final step, through ```make menuconfig``` make sure you have selected ```libnewlib``` as well as ```9pfs: 9p filesystem``` inside the ```Library Configuration``` menu. We will also check these options inside ```Library Configuration``` -> ```vfscore: Configuration```:

![fs selection menu](/docs/sessions/01-baby-steps/images/menuconfig_select_fs.png)

![fs2 selection menu](/docs/sessions/01-baby-steps/images/menuconfig_select_fs2.png)

![fs3 selection menu](/docs/sessions/01-baby-steps/images/menuconfig_select_fs3.png)

What is more, you should also have present in the current directory an additional directory called ```fs0```:
```
mkdir fs0
```
And so, ```fs0``` will contain whatever files you create, read from or write to from within your unikernel.

For now, just make sure it successfully builds. If it does, move on to the next work item.

## 04. Store Strings
For the final work item, you will have to update the source code from the second work item, so that it stores in a file the received string before sending the encoded one back to the client.
In order to achieve this, you must have the previous work item completed

The available resources are the exact same, you will simply have to modify ```main.c```.

To test if your application ran successfully, check to see whether the original strings you sent through the client are present in that file or not.


## Further Reading

Unikraft Documentation: http://docs.unikraft.org/index.html

