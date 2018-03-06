class HepConcurrency < Formula
  desc "FNAL C++ Concurrency Library for HEP"
  homepage "https://github.com/drbenmorgan/fnal-hep_concurrency"
  url "https://github.com/drbenmorgan/fnal-hep_concurrency.git", :branch => "feature/alt-cmake"
  version "0.1.0"
  head "https://github.com/drbenmorgan/fnal-hep_concurrency.git", :branch => "feature/alt-cmake"

  depends_on "drbenmorgan/art_suite/cetbuildtools2"
  depends_on "cmake" => :build
  depends_on "art-tbb"

  needs :cxx14

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      # Stress test fails on Mac (possibly due to core limit)
      # system "make"
      # system "ctest"
      system "make", "install"
    end
  end

  test do
    # Check Linkage
    (testpath/"test.cpp").write <<~EOS
      #include "hep_concurrency/ThreadSafeOutputFileStream.h"
      int main() {
        hep::concurrency::ThreadSafeOutputFileStream ofs("./test.txt");
        ofs.write(std::string {"hello world"});
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lhep_concurrency", "-o", "test"
    system "./test"
  end
end
