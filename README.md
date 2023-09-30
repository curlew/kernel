# kernel

A small x86-64 kernel using GRUB.

## Building (Debian)
```console
$ sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo xorriso qemu-system-x86
$ ./toolchain/toolchain.sh # this will take a while 
$ make qemu
```
