# serpent-support

Work in progress tree that will eventually be refactored as part of a
larger (more standard) build system to bootstrap runtime requirements
for the [Serpent Game Framework](https://github.com/lispysnake/serpent).

Right now, it's a growing collection of ugly scripts that will simply
build the relevant runtime requirements, like bgfx.

**Note**: Due to my current internet limitations we fetch GitHub generated
`zip` files instead of using submodules like we should. Once my internet
behaves we'll fix it.

Additionally the scripts are severely context limited in believing you
only want to build for 64-bit Linux with GCC.

## Scripts

As and when new scripts are added (which ofc will be replaced in future..)
we'll document them here.

### bgfx

Builds the main release library, along with the `shaderc`, `texturec` and `texturev`
CLI tools.

Build dependencies:

If you're running Solus, this one liner will fetch all build dependencies
needed for serpent-support (and most for `serpent`)

        sudo eopkg it -c system.devel sdl2-image-devel sdl2-devel mesalib-devel libpng-devel


## License

Copyright © 2019 Lispy Snake, Ltd.

`serpent-runtime` is available under the terms of the MIT license.
