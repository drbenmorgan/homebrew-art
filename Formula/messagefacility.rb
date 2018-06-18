class Messagefacility < Formula
  desc "FNAL C++ library for message logging"
  homepage "https://github.com/drbenmorgan/fnal-messagefacility.git"
  url "https://github.com/drbenmorgan/fnal-messagefacility.git", :tag => "v2.2.0-altcmake"
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
      # On linuxbrew (gcc5/6), get warning, hence error:
      # MessageLoggerImpl.cc:20:47: error: typedef 'using modules_t = class std::vector<std::__cxx11::basic_string<char> >' locally defined but not used [-Werror=unused-local-typedefs]
      # using modules_t = std::vector<std::string>;
      #                                           ^
      args << "-DCET_COMPILER_WARNINGS_ARE_ERRORS=OFF" unless OS.mac?
      system "cmake", "..", *args
      system "make"
      system "ctest"
      system "make", "install"
    end

    # Update linkage (TBDE in CMake, or via args above)
    if OS.mac?
      if build.stable?
        MachO::Tools.change_install_name("#{bin}/ELdestinationTester",
                                        "@rpath/libMF_MessageLogger.dylib",
                                        "#{lib}/libMF_MessageLogger.dylib")
      end
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
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lMF_MessageLogger", "-o", "test"
    ENV["MF_PLUGIN_PATH"] = "#{lib}"
    system "./test"
  end
end
