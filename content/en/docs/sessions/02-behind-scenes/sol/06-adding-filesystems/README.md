Update the `Makefile` to point to the correct location for the Unikraft (`UK_ROOT`) and libraries folders (`UK_LIBS`, `LIBS`).

Configure the application via the configuration screen:

```
$ make menuconfig
```

The basic configuration is loaded from the `Config.uk` file.
Then add support for 9pfs, by selecting `Library Configuration` -> `vfscore: VFS Core Interface` -> `vfscore: VFS Configuration`.
The select `Automatically mount a root filesystem (/)` and select `9pfs`.
For the `Default root device` option fill `fs0`.
Save the configuration and exit.
