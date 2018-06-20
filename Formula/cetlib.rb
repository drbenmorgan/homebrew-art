class Cetlib < Formula
  desc "Mirror of FNAL cetlib C++ library"
  homepage "https://cdcvs.fnal.gov/redmine/projects/cetlib"
  url "https://github.com/drbenmorgan/fnal-cetlib.git", :tag => "ART_SUITE_v2_11_02-altcmake"
  version "3.3.1"
  head "https://github.com/drbenmorgan/fnal-cetlib.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "art-boost"
  depends_on "cetbuildtools2"
  depends_on "cetlib_except"
  depends_on "openssl" unless OS.mac?
  depends_on "sqlite"

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      system "make"
      # Ignore cpu_timer_t as it seems to have random errors
      system "ctest", "-E", "cpu_timer_test"
      system "make", "install"
    end

    if OS.mac?
      MachO::Tools.change_install_name("#{bin}/inc-expand",
                                      "@rpath/libcetlib.dylib",
                                      "#{lib}/libcetlib.dylib")
    end
  end

  test do
    # Check linkage
    (testpath/"test.cpp").write <<~EOS
      #include <cetlib/search_path.h>
      #include <iostream>
      int main() {
        cet::search_path testpath {"PATH"};
        std::cout << testpath.size() << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lcetlib", "-o", "test"
    system "./test"
    # Check program
    system "#{bin}/inc-expand"
  end
end
