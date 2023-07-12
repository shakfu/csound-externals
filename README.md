# csound-externals

Experiments with two [csound](https://csound.com) externals for Max/MSP:

1. [csound_tilde](https://github.com/shakfu/csound_tilde), the official csound external, which was originally created by Matt Ingalls and maintained by Davis Pyon and Steven Yi. The variant in this repo was inspired by Volker Boehm's working release of the external in his awesome [downloads]([Downloads](https://vboehm.net/downloads/)) page and also his efforts to modernize the code and convert it into a proper Max Package in his[fork](https://github.com/v7b1/csound_tilde).

2. Iain Duncan's [csound6~](https://github.com/iainctduncan/csound_max) Max External, a minimal variant itself based on [csound_pd](https://github.com/csound/csound_pd) a pure-data csound external by Victor Lazarinni. 

The initial work on both externals is to create a relocatable 'release' build that os statically compiled with libcsound which can be included in Max packages and standalones (currently for macOS only).

There's some work done to fix some issues with the `csound_tilde` external, which are explaned in more detail in the `DEVNOTES.md` file in the `csound_tile` folder.

The idea is that his repo will serve as the place for experiemnts and propogate useful changes to the repsective projects.


## Key Differences

- Changes are currently only tested on macOS.

- So far, only tested on `x86_64` but no reason why it shoudn't work for `arm64`

- Structured as as Max Package with each external project as a subproject and `max-sdk-base` as a git submodule

- The original project README is now in the subproject folder. This README is now in the root of the project.

- A `Makefile` 'frontend' has been added to sequence top-level steps.

- A `source/scripts` folder has been added with the following bash scripts:

	- `build_dependencies.sh` which downloads and builds: 
		
		- `csound` as static library; and

		- `macdylibbundler`, the bundle fixup tool.

	- `fix_bundle.sh`: Move residual dylib dependencies to the bundle and fix the @rpath references


## Usage

Clone the project as follows to also download the `max-sdk-base` submodule:

```bash

git clone --recurse-submodules https://github.com/shakfu/csound-externals

```

Build both externals for local use:

```bash

make

```

Build both externals with the relocatable option (i.e. uses csound static library for packages and standalones):


```bash

make relocatable # also 'make release'

```

Have a look at the `Makefile` for further options

## Todo

- [ ] bundle using cmake's bundleutilities if possible

- [ ] build libsndfile statically?

- [ ] add sign and notarize step

- [ ] Windows support
