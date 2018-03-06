class Art < Formula
  desc "FNAL Art event processing framework for particle physics experiments"
  homepage "https://github.com/drbenmorgan/fnal-art.git"
  url "https://github.com/drbenmorgan/fnal-art.git", :branch => "feature/new-alt-cmake"
  version "2.10.1"
  head "https://github.com/drbenmorgan/fnal-art.git", :branch => "feature/new-alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "cppunit" => :build
  depends_on "drbenmorgan/art_suite/cetbuildtools2"
  depends_on "drbenmorgan/art_suite/cetlib_except"
  depends_on "drbenmorgan/art_suite/cetlib"
  depends_on "drbenmorgan/art_suite/fhicl-cpp"
  depends_on "drbenmorgan/art_suite/messagefacility"
  depends_on "drbenmorgan/art_suite/canvas"
  depends_on "drbenmorgan/art_suite/canvas_root_io"
  depends_on "art-clhep"
  depends_on "art-root6"
  depends_on "art-tbb"
  depends_on "boost"
  depends_on "sqlite"

  needs :cxx14

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      # Temp workaround for checkClassVersion needing ROOT's python module
      system "PYTHONPATH=$(root-config --libdir) make"
      system "ctest", "-j#{ENV.make_jobs}"
      system "make", "install/fast"

      # Temp fix for executable rpaths on mac
      # Todo: should be appropriately set by build system, as ROOT does.
      Dir["#{bin}/*"].each do |art_exe|
          MachO::Tools.add_rpath(art_exe, "@executable_path/../lib") if OS.mac?
      end
    end
  end

  test do
    # Need a basic exercise...
    false
  end
end
