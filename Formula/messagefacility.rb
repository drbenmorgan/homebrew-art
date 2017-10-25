class Messagefacility < Formula
  desc "FNAL C++ library for message logging"
  homepage "https://github.com/drbenmorgan/fnal-messagefacility.git"
  url "https://github.com/drbenmorgan/fnal-messagefacility.git", :branch => "feature/alt-cmake"
  version "2.1.1"
  head "https://github.com/drbenmorgan/fnal-messagefacility.git", :branch => "feature/alt-cmake"

  depends_on "drbenmorgan/art_suite/cetbuildtools2"
  depends_on "drbenmorgan/art_suite/cetlib_except"
  depends_on "drbenmorgan/art_suite/cetlib"
  depends_on "drbenmorgan/art_suite/fhicl-cpp"
  # This leads to an audit error, so should package own boost!
  depends_on "boost" => "c++11"
  depends_on "sqlite"
  depends_on "tbb" => "c++11"
  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "cmake" => :build

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      # TODO: MF isn't SIP compatible yet, so most tests fail
      # system "make"
      # system "ctest"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "messagefacility/MessageLogger/MessageLogger.h"
      #include <iostream>
      int main() {
        mf::SetApplicationName(std::string {"foobar"});
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lMF_MessageLogger", "-lMF_Utilities", "-o", "test"
    system "./test"
  end
end
