---
title: "Session 05: Contributing to Unikraft"
linkTitle: "05. Contributing to Unikraft"
---

The focus of this session will be on porting new libraries to Unikraft and preparing them for upstreaming to the [main organization's github](https://github.com/unikraft).
Being a library operating system, the unikernels created using Unikraft represents a collection of internal and external libraries and the ported application. 
As a consequence, a large library pool is mandatory in order to make this project compatible with as many applications as possible.

## Reminders

From earlier sessions we saw that we can add an external library as dependency for an application by appending it to the LIBS variable of the application's Makefile:
````
LIBS := $(UK_LIBS)/my_lib

````
Having done that, we can then select it in the menuconfig interface in order to be included in the build process.

Also, in seesion 02 we saw that there are two types of libraries:
- internal: which define parts of the kernel(schedulers, file systems, etc.);
- external: which define user-space level functionalities.

## Git structure

The [organiation's github](https://github.com/unikraft) contains [the main Unikraft repository](https://github.com/unikraft/unikraft) and separate repositories for external libraries, as well as already ported apps.
In the previous sessions we saw that the Unikraft repository consists of internal libraries, platform code and architecture code. It doesn't have any external dependencies, in contrast to the external libraries, which can have external dependencies.
External libraries can have more specific purposes. So, we can port a library even just for a single application
The process of adding new internal libraries is almost the same as for external ones, so further we will focus on porting an external library.

## Example of external library

Let's focus for now on a already ported library: [lib-libhogweed](https://github.com/unikraft/lib-libhogweed).
Let's examine its core components. Open the sources and follow the bookmars marked with `USOC_X`.

### glue code
In some cases, not all the dependencies of an external library are already present in the Unikraft project, so the solution is to add them manually, as glue code, to the library's sources.
Another situation when we need glue code is when the ported library comes with test modules, used for testing the library's functionalities. The goal in this case is to wrap all the test modules into one single function. In this way, we can check the library integrity if we want so by just a single function call. Moreover, we can create a test framework which can periodically check all of the ported libraries, useful especially for detecting if a new library will interfer with an already ported one.

Moving back to our example, a practical example of the second case is the `run_all_libhogweed_tests(int v)` function from `testutils_glue.c`, line #674, which calls every selected(we will see later how we can make selectable variables) test module and exits with `EXIT_SUCCESS` only if it passes over all the tests.
For exposing this API, we should also make a header file with all the test modules, as well as our wrapper function.
*check include/testutils_glue.h*

### Config.uk
Here are defined the config variables, which will be visible from `menuconfig`. Also, these variables can be accesed using the prefix `CONFIG_` from `Makefile.uk` or even from c sources, by including `"uk/config.h"`.
- USOC_1: the main variable of the library which acts like an identifier for it:
```
config LIBHOGWEED
	bool "libhogweed - Public-key algorithms"
	default n
```
- USOC_2: we can also set another library's main variable, which involves using it in the build process:
````
select LIBNEWLIBC

````
- USOC_3: we can create auxiliary menus, in this case containing all the test cases. Each test case have its own variable in order to allow testing just some tests from the whole suite:
````
menuconfig TESTSUITE
		bool "testsuite - tests for libhogweed"
		default n
		if TESTSUITE
			config TEST_X
				bool "test x functionality"
				default y
		endif
````

### Makefile.uk
- USOC_1: register the library to Unikraft's build system:
````
$(eval $(call addlib_s,libhogweed,$(CONFIG_LIBHOGWEED)))
````
As you can see, we are registering the library to Unikraft's build system only if the main library's config variable is set.
- USOC_2: set the URL from where the library will be automatically downloaded at build time:
````
LIBHOGWEED_VERSION=3.6
LIBHOGWEED_URL=https://ftp.gnu.org/gnu/nettle/nettle-$(LIBHOGWEED_VERSION).tar.gz
````
- USOC_3: declare helper variables corresponding to most used paths:
````
LIBHOGWEED_SUBDIR=nettle-$(LIBHOGWEED_VERSION)
LIBHOGWEED_EXTRACTED = $(LIBHOGWEED_ORIGIN)/nettle-$(LIBHOGWEED_VERSION)
````
There are some default variables:
- `$LIB_ORIGIN`: represents the path where is downloaded and extracted the original library during the build process;
- `$LIB_BASE`: represents the path of the ported library sources(the path appended to the `$LIBS` variable).
- USOC_4: set the locations where the headers are searched. You should include the directories with the library's headers as well as the directories with the glue headers created by you:
````
// including the path of the glue header added by us
LIBHOGWEED_COMMON_INCLUDES-y += -I$(LIBHOGWEED_BASE)/include
````
- USOC_5: add compile flags, used in general for suppresing some warnings and making the build proces neater:
````
LIBHOGWEED_SUPPRESS_FLAGS += -Wno-unused-parameter \
        -Wno-unused-variable -Wno-unused-value -Wno-unused-function \
        -Wno-missing-field-initializers -Wno-implicit-fallthrough \
        -Wno-sign-compare
LIBHOGWEED_CFLAGS-y   += $(LIBHOGWEED_SUPPRESS_FLAGS) \
        -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast
LIBHOGWEED_CXXFLAGS-y += $(LIBHOGWEED_SUPPRESS_FLAGS)
````
- USOC_6: register the library's sources:
````
LIBHOGWEED_SRCS-y += $(LIBHOGWEED_EXTRACTED)/bignum.c
````
- USOC_7: register the library's tests:
````
ifeq ($(CONFIG_RSA_COMPUTE_ROOT_TEST),y)
LIBHOGWEED_SRCS-y += $(LIBHOGWEED_EXTRACTED)/testsuite/rsa-compute-root-test.c
LIBHOGWEED_RSA-COMPUTE-ROOT-TEST_FLAGS-y += -Dtest_main=rsa_compute_root_test
endif
````
There are situations when the test cases have each the `main()` function. In order to wrap all the tests into one single main function, we have to modify them by using preprocessing symbols.
*A good practice is to include a test only if the config variable corresponding to that test is set*
- USOC_8: this step is very customizabile, being like a script executed before compiling the library. In general, the libraries build their own config file through a provided executable, `configure`. We can also do things like generating headers using the original building system:
````
$(LIBHOGWEED_EXTRACTED)/config.h: $(LIBHOGWEED_BUILD)/.origin
	$(call verbose_cmd,CONFIG,libhogweed: $(notdir $@), \
        cd $(LIBHOGWEED_EXTRACTED) && ./configure --enable-mini-gmp \
    )
LIBHOGWEED_PREPARED_DEPS = $(LIBHOGWEED_EXTRACTED)/config.h 

$(LIBHOGWEED_BUILD)/.prepared: $(LIBHOGWEED_PREPARED_DEPS)

UK_PREPARE += $(LIBHOGWEED_BUILD)/.prepared  
````

### WARMUP

## Summary



## Practical Work

Moving to a more hands on experience, let's port a new library!
Let's suppose that we need kd tree support and that we found a C library that does what we need: http://nuclear.mutantstargoat.com/sw/kdtree/.
Inspecting this library, we can see that it also have a set of examples, which can be used by us to test that we ported this library properly.

Follow the TODO's and complete the porting!

### 01. Work Item 1

Let's start declaring a new variable in the `Config.uk` file.

### 02. Work Item 2

Now let's use it, in the `Makefile.uk` file.
*Register the library to the build system, only if the variable declared previously is set!*

### 03. Work Item 3

Having it registered, set the URL from where it will be automatically downloaded at build time and fetch it.

### 04. Work Item 4

Add the directory which contain the library's header

### 05. Work Item 5

Add the source of the library

### 06. Work Item 6

Check the original README to see if the library needs to be configured first, and add the proper rule in that case.
Until now, we have registered the library's sources, and should compile an unikernel with it.
Go to the provided application and try to build it with our ported library as dependency!

*HINTS!
- You can leave the application's main empty.
- You can readme, but the solution is hidden*

### 07. Work Item 7

Now let's make a wrapper for the test cases.

## Further Reading

Add links and references for more information about the topic of the session.
