# csound-externals

This repo is for testing certain common and build-related improvements to my forks of two [csound](https://csound.com) externals for Max/MSP. Work is done on the individual fork-level with the aim of contributing changes to the parent projects and then common features are tested here:

1. [csound_tilde](https://github.com/shakfu/csound_tilde), the official csound external, which was originally created by Matt Ingalls and maintained by Davis Pyon and Steven Yi. The changes to this external were, to some extent, inspired by Volker Boehm's release in his awesome ([Downloads](https://vboehm.net/downloads/)) page and also his efforts to modernize the code and convert it into a proper Max Package in his [fork](https://github.com/v7b1/csound_tilde).

2. Iain Duncan's [csound6~](https://github.com/shakfu/csound_max) Max External, a minimal variant itself based on [csound_pd](https://github.com/csound/csound_pd) a pure-data csound external by Victor Lazarinni. Iinitial experiements to produce relocatable builds were tested in this external

The initial work on both externals is to create a relocatable 'release' build that os statically compiled with libcsound which can be included in Max packages and standalones (currently for macOS only).

There's some work done to be done with the `csound_tilde` external to eventually provide a streamlined Windows build.


## Key Differences

- Changes are currently only tested on macOS.

- So far, only tested on `x86_64` but no reason why it shoudn't work for `arm64`

- Structured as as Max Package with each external project as a subproject and `max-sdk-base` as a git submodule

- The original project README is now in the subproject folder. This README is now in the root of the project.

- A `Makefile` 'frontend' has been added to sequence top-level steps.

- A `source/scripts` folder has been added with the a number of build-related bash and cmake scripts.


## Usage

Clone the project as follows to also download the `max-sdk-base` submodule:

```bash

git clone --recurse-submodules https://github.com/shakfu/csound-externals

```

Build both externals for local use (assumes `brew install libsndfile boost`)

```bash

make

```

Build both externals with the hybrid relocatable option (i.e. uses csound static library for packages and standalones and includes dependent dylibs in bundle) also (assumes `brew install libsndfile boost`):


```bash

make hybrid # also 'make release'

```

Finally, this option provides completely static build without any dependent dylibs:

```bash

make release

```


Have a look at the `Makefile` for further options

## Todo

- [ ] bundle using cmake's bundleutilities if possible

- [ ] add sign and notarize step

- [ ] Fix windows build!
