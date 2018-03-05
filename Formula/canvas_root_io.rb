class CanvasRootIo < Formula
  desc "FNAL C++ library for I/O (ROOT)"
  homepage "https://github.com/drbenmorgan/fnal-canvas_root_io.git"
  url "https://github.com/drbenmorgan/fnal-canvas_root_io.git", :branch => "feature/alt-cmake"
  version "1.4.2"
  head "https://github.com/drbenmorgan/fnal-canvas_root_io.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "drbenmorgan/art_suite/cetbuildtools2"
  depends_on "drbenmorgan/art_suite/cetlib_except"
  depends_on "drbenmorgan/art_suite/cetlib"
  depends_on "drbenmorgan/art_suite/fhicl-cpp"
  depends_on "drbenmorgan/art_suite/messagefacility"
  depends_on "drbenmorgan/art_suite/canvas"
  depends_on "art-clhep"
  depends_on "art-root6"
  # This leads to an audit error, so should package own boost!
  depends_on "boost" => "c++11"
  depends_on "tbb" => "c++11"

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      # Temp workaround for checkClassVersion needing ROOT's python module
      system "PYTHONPATH=$(root-config --libdir) make"
      system "ctest"
      system "make", "install"
    end
  end

  test do
    # Need a basic exercise...
    false
  end
end
