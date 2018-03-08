class Messagefacility < Formula
  desc "FNAL C++ library for message logging"
  homepage "https://github.com/drbenmorgan/fnal-messagefacility.git"
  url "https://github.com/drbenmorgan/fnal-messagefacility.git", :branch => "feature/alt-cmake"
  version "2.1.1"
  head "https://github.com/drbenmorgan/fnal-messagefacility.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "art-tbb"
  depends_on "art-boost"
  depends_on "cetbuildtools2"
  depends_on "cetlib_except"
  depends_on "cetlib"
  depends_on "fhicl-cpp"
  depends_on "sqlite"

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      system "make"
      system "ctest"
      system "make", "install"
    end

    # Update linkage (TBDE in CMake, or via args above)
    if OS.mac?
      MachO::Tools.change_install_name("#{lib}/libMF_MessageLogger.dylib",
                                      "@rpath/libMF_Utilities.dylib",
                                      "#{lib}/libMF_Utilities.dylib")
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
