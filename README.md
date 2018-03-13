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
Due to the more fragmented nature of Linux systems, it's currently recommended to use [linuxbrew's](https://linuxbrew.sh) 
Docker container to provide a consistent environment and system (modern glibc, binutils and gcc).


# Installing art
Once you have brew installed, simply do

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
all plugins and dictionaries, including its own, the Brew install of art supplies a wrapper script `art-brew`. This simply appends the path to art's own plugins to the system dynamic path so that you do not need to set these yourself. Otherwise, it can be run exactly like art:

``` console
$ art-brew --help
...
$ art-brew -c myconfig.fcl
...
```

On Linux systems, you can extend `LD_LIBRARY_PATH` as required to point to your own plugins and dictionaries. 

On macOS, System Integrity Protection (SIP) will empty `DYLD_LIBRARY_PATH` in processes that are started from programs in SIP-enabled areas. As this includes usual system shells, extensions of `DYLD_LIBRARY_PATH` are not passed through to `art` via `art-brew` yet. This is a work in progress.

## Development
TBD via the `toyExperiment` project.



