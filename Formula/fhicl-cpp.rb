class FhiclCpp < Formula
  desc "FNAL Hierarchical Configuration Language C++ Library"
  homepage "https://github.com/drbenmorgan/fnal-fhicl-cpp.git"
  url "https://github.com/drbenmorgan/fnal-fhicl-cpp.git", :branch => "feature/alt-cmake"
  version "4.6.1"
  revision 2
  head "https://github.com/drbenmorgan/fnal-fhicl-cpp.git", :branch => "feature/alt-cmake"

  depends_on "drbenmorgan/art_suite/cetbuildtools2"
  depends_on "drbenmorgan/art_suite/cetlib_except"
  depends_on "drbenmorgan/art_suite/cetlib"
  # This leads to an audit error, so should package own boost!
  depends_on "boost" => "c++11"
  depends_on "sqlite"
  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "cmake" => :build

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "..", *args
      system "make"
      system "ctest"
      system "make", "install"
    end

    if OS.mac?
      MachO::Tools.change_install_name("#{bin}/fhicl-dump",
                                      "@rpath/libfhiclcpp.dylib",
                                      "#{lib}/libfhiclcpp.dylib")
      MachO::Tools.change_install_name("#{bin}/fhicl-write-db",
                                      "@rpath/libfhiclcpp.dylib",
                                      "#{lib}/libfhiclcpp.dylib")
      MachO::Tools.change_install_name("#{lib}/fhicl.so",
                                       "@rpath/libfhiclcpp.dylib",
                                       "#{lib}/libfhiclcpp.dylib")
    end
  end

  test do
    # Check Linkage
    (testpath/"test.cpp").write <<~EOS
      #include <fhiclcpp/ParameterSet.h>
      #include <fhiclcpp/make_ParameterSet.h>
      #include <iostream>
      std::string mydoc() {
        return "myatom: 42";
      }
      int main() {
        fhicl::ParameterSet pset;
        fhicl::make_ParameterSet(mydoc(), pset);
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++1y", "test.cpp", "-L#{lib}", "-lfhiclcpp", "-o", "test"
    system "./test"
    # Test programs
    (testpath/"test.fcl").write <<~EOS
      myatom: 42
      foo : {
        bar : "baz"
      }
    EOS
    system "#{bin}/fhicl-dump", "-l0", "test.fcl"
    system "#{bin}/fhicl-write-db", "test.fcl", "test.sqlite"
  end
end
