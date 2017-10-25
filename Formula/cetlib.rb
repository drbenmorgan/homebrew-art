class Cetlib < Formula
  desc "Mirror of FNAL cetlib C++ library"
  homepage "https://cdcvs.fnal.gov/redmine/projects/cetlib"
  url "https://github.com/drbenmorgan/fnal-cetlib.git", :branch => "feature/alt-cmake"
  version "3.1.0"
  head "https://github.com/drbenmorgan/fnal-cetlib.git", :branch => "feature/alt-cmake"

  depends_on "drbenmorgan/art_suite/cetbuildtools2"
  depends_on "drbenmorgan/art_suite/cetlib_except"
  # This leads to an audit error, so should package own boost!
  depends_on "boost" => "c++11"
  depends_on "sqlite"
  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      # TODO: Current version still has warnings for C-linkage/Boost
      args << "-DCET_COMPILER_WARNINGS_ARE_ERRORS=OFF"
      system "cmake", "..", *args
      system "make"
      # Exclude tests that fail due to SIP for now
      system "ctest", "-E", "PluginFactory_t|LibraryManager_t|regex_t$|regex_standalone_t"
      system "make", "install"
    end
  end

  test do
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
  end
end
