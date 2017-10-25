# homebrew-art_suite

Experimental Homebrew tap for FNAL Art Software Suite. Uses
de-UPSified versions of the ART Suite:

- `cetlib_except`
- `cetlib`
- `fhicl-cpp`
- `messagefacility`
- ... TBD ...


## A note on RPATHs

The `cetlib`, `fhicl-cpp` and `messagefacility` packages consist of a library(ies)
plus 1-N helper programs that use this(ese) library(ies). The build systems at present
do not set the installation RPATHs on the programs/libraries and so run/link time errors
may result.

This is prebably best dealt with in the buildsystems of the packages, where `@<thing>` (macOS)
or `$ORIGIN` (Linux) can be used in RPATH. These allow binary relocatability due to these
constructs being derived/expanded at runtime to the runtime locations of the binaries.

Consistent policy on these not quite clear yet, so work around this on macOS/Homebrew
by rewriting the install names for internal libraries. Needs checking on Linux, though
Linuxbrew should handle this transparently.

