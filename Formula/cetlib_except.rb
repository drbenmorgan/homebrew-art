class CetlibExcept < Formula
  desc "Cet C++ exception classes"
  homepage "https://github.com/drbenmorgan/fnal-cetlib_except"
  url "https://github.com/drbenmorgan/fnal-cetlib_except.git", :tag => "v1.1.3-altcmake"
  head "https://github.com/drbenmorgan/fnal-cetlib_except.git", :branch => "feature/alt-cmake"
  devel do
    url "https://github.com/drbenmorgan/fnal-cetlib_except.git", :tag => "v1.1.6-altcmake"
  end

  depends_on "drbenmorgan/art_suite/cetbuildtools2" => :build
  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :recommended]

  needs :cxx14

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
      #include <cetlib_except/exception.h>
      int main() {
        try {
          throw cet::exception("HomebreTestException");
        }
        catch (cet::exception& e) {
        }
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lcetlib_except", "-o", "test"
    system "./test"
  end
end
