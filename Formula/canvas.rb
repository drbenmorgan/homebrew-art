class Canvas < Formula
  desc "FNAL C++ library for I/O"
  homepage "https://github.com/drbenmorgan/fnal-canvas.git"
  url "https://github.com/drbenmorgan/fnal-canvas.git", :branch => "feature/alt-cmake"
  version "3.2.1"
  head "https://github.com/drbenmorgan/fnal-canvas.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "cppunit" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "art-clhep"
  depends_on "art-root6" if OS.mac?
  depends_on "art-tbb"
  depends_on "drbenmorgan/art_suite/cetbuildtools2"
  depends_on "drbenmorgan/art_suite/cetlib_except"
  depends_on "drbenmorgan/art_suite/cetlib"
  depends_on "drbenmorgan/art_suite/fhicl-cpp"
  depends_on "drbenmorgan/art_suite/messagefacility"
  depends_on "boost"
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
    system "./test"
  end
end
