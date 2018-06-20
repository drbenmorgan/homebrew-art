class CetlibExcept < Formula
  desc "Cet C++ exception classes"
  homepage "https://github.com/drbenmorgan/fnal-cetlib_except"
  # NB: Use cross-package tag for consistency with upstream, though
  # in practice this really acts like version+revision in Formulae terms
  url "https://github.com/drbenmorgan/fnal-cetlib_except.git", :tag => "ART_SUITE_v2_11_02-altcmake"
  version "1.2.1"
  head "https://github.com/drbenmorgan/fnal-cetlib_except.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :recommended]
  depends_on "cetbuildtools2" => :build

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
