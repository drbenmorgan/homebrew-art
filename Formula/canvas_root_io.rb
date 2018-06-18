class CanvasRootIo < Formula
  desc "FNAL C++ library for I/O (ROOT)"
  homepage "https://github.com/drbenmorgan/fnal-canvas_root_io.git"
  url "https://github.com/drbenmorgan/fnal-canvas_root_io.git", :tag => "v1.1.4-altcmake"
  head "https://github.com/drbenmorgan/fnal-canvas_root_io.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
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
  depends_on "python@2"

  def install
    ENV.prepend_path "PATH", Formula["python@2"].libexec/"bin"

    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      system "make"
      system "ctest"
      system "make", "install"
    end
  end

  test do
    # Need a basic exercise...
    false
  end
end
