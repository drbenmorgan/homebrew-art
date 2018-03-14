# homebrew-art_suite

Experimental Homebrew tap for [FNAL Art Software Suite](https://art.fnal.gov). Builds and
install de-UPSified versions of the ART Suite for macOS and Linux (linuxbrew/ubuntu) to
demonstrate the use of the native compiler and without the need to setup the environment
to workaround macOS SIP issues.

As a prototype, it provides only a native build-from-source, rolling release install of
a single Art version.

# Getting Started
## macOS
Install [Homebrew](https://brew.sh) either in `/usr/local` or a location of your choice (you can also use an existing install if you have one). Make sure to run `brew doctor` and resolve any issues before proceeding

## Linux
Due to the relatively fragmented nature of Linux toolchains (GCC etc), only Ubuntu 16.04 LTS is currently
confirmed to work. Even in this case, you will need to add:

1. The [Ubuntu Toolchain PPA](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test).
   - Follow the instructions on the above page, and then do `sudo apt-get install gcc-6`
2. Graphics libraries for [ROOT](https://root.cern.ch)
   - `sudo apt-get install libglu1-mesa-dev libx11-dev libxext-dev libxft-dev libxpm-dev`

Install [Linuxbrew](https://brew.sh) either in the recommended `/home/linuxbrew/.linuxbrew`  or in a location
of your choice. However, the latter will require more builds from source. Make sure to run `brew doctor` and resolve any issues before proceeding.

If you're just interested in trying things out and have Docker available, images are available for the base linux
system without art:

``` console
$ docker run --rm -it benmorgan/artbase
```

or with a full art install on top of that

```console
$ docker run --rm -it benmorgan/art
```

# Installing art
Once you have Home/linuxbrew installed, simply do

```console
$ brew tap drbenmorgan/art_suite
$ brew install art
...
$ brew test art
```

As binary bottles are not yet prepared, all art packages will be built from source and consequently take some time (especially for Root) to complete. Brew will autoparallize the build as far as it can though.

This tap installs vendored versions of [Boost](https://boost.org), [CLHEP](https://cern.ch/clhep), [ROOT](https://root.cern.ch), and [TBB](https://www.threadingbuildingblocks.org) to ensure a consistent C++14 binary interface.
If you are using an existing install of brew and have installed any of the `boost`, `clhep`, `root` or `tbb` formulae from
the core tap, then `brew` will warn you about conflicts and refuse to install. If you don't require these formulae for other work, they can be removed. Otherwise, you can create a separate install of homebrew (e.g. in `/home/you/art_suite`) to hold only the art installs.

The current packages and stable versions installed are:
- `Boost` 1.66.0
- `CLHEP` 2.4.0.1
- `ROOT` 6.12.04
- `TBB` 2018_U2
- [`cetbuildtools2`](https://github.com/drbenmorgan/cetbuildtools2) 0.6.0
- [`cetlib_except`](https://cdcvs.fnal.gov/redmine/projects/cetlib_except) 1.1.6
- [`cetlib`](https://cdcvs.fnal.gov/redmine/projects/cetlib) 3.2.0
- [`fhicl-cpp`](https://cdcvs.fnal.gov/redmine/projects/fhicl-cpp) 4.6.5
- [`messagefacility`](https://cdcvs.fnal.gov/redmine/projects/messagefacility) 2.1.6
- [`canvas`](https://cdcvs.fnal.gov/redmine/projects/canvas) 3.2.1
- [`canvas_root_io`](https://cdcvs.fnal.gov/redmine/projects/canvas_root_io) 1.0.1
- [`art`](https://cdcvs.fnal.gov/redmine/projects/art) 2.10.1
- *Still have toyExperiment, gallery, others to add*

plus their dependencies from [homebrew-core](https://github.com/linuxbrew/homebrew-core) and the system.

# Using Art
## Runtime
Assuming that you have your environment configured as recommended by Brew, you can run `art` directly:

``` console
$ art --help
```

Due to art's reliance on the system dynamic loader path (`LD_LIBRARY_PATH` on Linux, `DYLD_LIBRARY_PATH` on macOS) to locate
all plugins and dictionaries, including its own, you will also need to set these in your shell before running art:

```console
$ brew info art
...
==> Caveats
Because Art uses the environment variable DYLD_LIBRARY_PATH
to locate both internal and user plugins, you should add the
following to your shell environment before using Art:

For sh/bash/zsh:
  export DYLD_LIBRARY_PATH=$(brew --prefix)/lib:${DYLD_LIBRARY_PATH}
For csh/tsch:
  setenv DYLD_LIBRARY_PATH=$(brew --prefix)/lib:${DYLD_LIBRARY_PATH}

You should then extend these variables as needed with
paths holding the Art plugins you wish to use.
$
```

Even on SIP enabled macOS systems, you should then be able to extend and use `DYLD_LIBRARY_PATH`
if `art` is *not* installed in a SIP protected location (which should be the case for most
Homebrew installs). If this does not work, try:

``` console
$ DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH art <args>
```

Failing that, you can also try the `art-brew` wrapper script, which forwards on the needed environment
to `art` via a separate environment variable `ART_PLUGIN_PATH`. This can be used as:

``` console
$ export ART_PLUGIN_PATH=$DYLD_LIBRARY_PATH
$ art-brew <normalartargs>
```

As a prototype, these are likely many further gotchas down the road, so reports are welcome.


## Development
TBD via the `toyExperiment` project.



