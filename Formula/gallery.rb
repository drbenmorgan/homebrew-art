class Gallery < Formula
  desc "FNAL C++ library for I/O"
  homepage "https://github.com/drbenmorgan/fnal-gallery.git"
  url "https://github.com/drbenmorgan/fnal-gallery.git", :tag => "v1.8.2-altcmake"
  head "https://github.com/drbenmorgan/fnal-gallery.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "art-root6" if OS.mac?
  depends_on "cetbuildtools2"
  depends_on "cetlib"
  depends_on "canvas"
  depends_on "canvas_root_io"

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
      #include "gallery/Handle.h"
      #include <iostream>
      int main() {
        gallery::Handle<int> h;
        assert(!h.isValid());
        std::cout << "gallery usable" << std::endl;;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lgallery", "-o", "test"
    # messagefacility now always requires plugin path
    ENV["MF_PLUGIN_PATH"] = "#{lib}"
    system "./test"
  end
end
