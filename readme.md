# Laravel Settler

The scripts that build the Laravel Homestead development environment.

# Building

These build scripts use [Packer](https://packer.io) to create identical Vagrant boxes for Virtualbox and VMWare.

```
$ ./build.sh
```

Once the build script finishes you will have two boxes in the `builds` directory. Build logs will be in `build-output.log`
