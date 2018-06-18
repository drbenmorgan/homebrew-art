class Canvas < Formula
  desc "FNAL C++ library for I/O"
  homepage "https://github.com/drbenmorgan/fnal-canvas.git"
  url "https://github.com/drbenmorgan/fnal-canvas.git", :tag => "v3.3.0-altcmake"
  head "https://github.com/drbenmorgan/fnal-canvas.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "cppunit" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "art-boost"
  depends_on "art-clhep"
  depends_on "art-root6" if OS.mac?
  depends_on "art-tbb"
  depends_on "cetbuildtools2"
  depends_on "cetlib_except"
  depends_on "cetlib"
  depends_on "fhicl-cpp"
  depends_on "messagefacility"
  depends_on "range-v3"

  def install
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
    (testpath/"test.cpp").write <<~EOS
      #include "canvas/Version/GetReleaseVersion.h"
      #include <iostream>
      int main() {
        std::cout << art::getCanvasReleaseVersion() << std::endl;;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lcanvas", "-o", "test"
    # messagefacility now always requires plugin path
    ENV["MF_PLUGIN_PATH"] = "#{lib}"
    system "./test"
  end
end
