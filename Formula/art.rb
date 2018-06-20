class Art < Formula
  desc "FNAL Art event processing framework for particle physics experiments"
  homepage "https://github.com/drbenmorgan/fnal-art.git"
  url "https://github.com/drbenmorgan/fnal-art.git", :tag => "ART_SUITE_v2_11_02-altcmake"
  version "2.11.2"
  head "https://github.com/drbenmorgan/fnal-art.git", :branch => "feature/new-alt-cmake"

  depends_on "cmake" => :build
  depends_on "cppunit" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "python@2" => :build # for dictionaries
  depends_on "art-boost"
  depends_on "art-clhep"
  depends_on "art-root6"
  depends_on "art-tbb"
  depends_on "cetbuildtools2"
  depends_on "cetlib_except"
  depends_on "cetlib"
  depends_on "fhicl-cpp"
  depends_on "messagefacility"
  depends_on "canvas"
  depends_on "canvas_root_io"
  depends_on "sqlite"

  needs :cxx14

  def install
    ENV.prepend_path "PATH", Formula["python@2"].libexec/"bin"

    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      args << "-DCET_COMPILER_WARNINGS_ARE_ERRORS=OFF" unless OS.mac?
      # To find root at runtime on linux, because it subdirs its libs
      args << "-DCMAKE_INSTALL_RPATH=#{Formula["art-root6"].lib/"root"}"
      system "cmake", "..", *args
      system "make"
      #system "ctest", "-j#{ENV.make_jobs}"
      system "make", "install/fast"

      # Temp fix for executable rpaths on mac
      # Todo: should be appropriately set by build system, as ROOT does.
      Dir["#{bin}/*"].each do |art_exe|
        MachO::Tools.add_rpath(art_exe, "@executable_path/../lib") if OS.mac?
      end
    end

    # Create a shim so that art can be run without needing (DY)LD_LIBRARY_PATH
    # set to its own location(s). We only APPEND the known internal path
    # because we don't want to override an existing setting. There's
    # also no passthrough variable to allow extension.
    (buildpath/"art-brew").write <<~EOS
    #!/usr/bin/env bash
    # Find ourselves, hence actual art command to run
    function realdir() {
      local dir="${1:-.}"
      ( cd "$dir" && pwd -P )
    }
    #-----------------------------------------------------------------------
    # - BEGIN SHIM
    # Shim around art program to use dynamic loader path without requiring
    # direct setting by the user. This also works around stripping of
    # DYLD_LIBRARY_PATH in SIP enabled environments, at least for art's own
    # plugins. A passthrough path "ART_PLUGIN_PATH" is prepended to the
    # dynamic loader path if present to allow usage in a SIP enabled environment
    __CET_LIBRARY_PATH_NAME="LD_LIBRARY_PATH"
    if [[ $(uname) == 'Darwin' ]]; then
      __CET_LIBRARY_PATH_NAME="DYLD_LIBRARY_PATH"
    fi
    # Add passthrough path, if set
    export ${__CET_LIBRARY_PATH_NAME}=${ART_PLUGIN_PATH:+${ART_PLUGIN_PATH}:}${!__CET_LIBRARY_PATH_NAME}
    # Get the path to this install's libs
    artLibDir=$(realdir $(dirname ${0})/../lib)
    export ${__CET_LIBRARY_PATH_NAME}=${!__CET_LIBRARY_PATH_NAME}:${artLibDir}
    # Append Homebrew lib so dependent libs picked up (messagefacility
    # and canvas_root_io) if we are run from the Cellar rather than from prefix.
    brewCMD=$(which brew)
    if [[ ! -z $brewCMD ]] ; then
      export ${__CET_LIBRARY_PATH_NAME}=${!__CET_LIBRARY_PATH_NAME}:$(brew --prefix)/lib
    fi
    # - END SHIM
    #-----------------------------------------------------------------------
    # Append our directory to PATH so that subscripts can source cet_test_functions
    # directly.
    artExec=$(realdir $(dirname ${0}))/art
    # Execute command in shimmed environment.
    $artExec "$@"
    EOS
    bin.install "art-brew"
  end

  def caveats; <<~EOS
    Because Art uses the environment variable #{OS.mac? ? "DYLD_LIBRARY_PATH" : "LD_LIBRARY_PATH"}
    to locate both internal and user plugins, you should add the
    following to your shell environment before using Art:

    For sh/bash/zsh:
      export #{OS.mac? ? "DYLD_LIBRARY_PATH" : "LD_LIBRARY_PATH"}=$(brew --prefix)/lib:${#{OS.mac? ? "DYLD_LIBRARY_PATH" : "LD_LIBRARY_PATH"}}
    For csh/tsch:
      setenv #{OS.mac? ? "DYLD_LIBRARY_PATH" : "LD_LIBRARY_PATH"}=$(brew --prefix)/lib:${#{OS.mac? ? "DYLD_LIBRARY_PATH" : "LD_LIBRARY_PATH"}}

    You should then extend these variables as needed with
    paths holding the Art plugins you wish to use.
    EOS
  end

  test do
    # Bare art should run ok, except that help exits with error....
    # Should be fixed from https://cdcvs.fnal.gov/redmine/projects/art/repository/revisions/d2f0f99b03f9925545ea7c7cad4fce45ce7a4b5d
    # system "#{bin}/art", "--help"

    # Just a sanity test of running art with an simple fcl file
    # Use wrapper script to check environment
    (testpath/"test.fcl").write <<~EOS
      process_name: OptSimpleOut
      physics: {
        ep: [ o1 ]
        end_paths: [ ep ]
      }
      outputs: {
        o1: {
          module_type: RootOutput
          fileName: "junk.out"
        }
      }
    EOS
    system "#{bin}/art-brew", "-c", "test.fcl"
  end
end
