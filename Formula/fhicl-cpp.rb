class FhiclCpp < Formula
  desc "FNAL Hierarchical Configuration Language C++ Library"
  homepage "https://github.com/drbenmorgan/fnal-fhicl-cpp.git"
  url "https://github.com/drbenmorgan/fnal-fhicl-cpp.git", :tag => "ART_SUITE_v2_11_02-altcmake"
  version "4.6.8"
  head "https://github.com/drbenmorgan/fnal-fhicl-cpp.git", :branch => "feature/alt-cmake"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "art-boost"
  depends_on "cetbuildtools2"
  depends_on "cetlib_except"
  depends_on "cetlib"
  depends_on "python@2"
  depends_on "sqlite"

  def install
    args = std_cmake_args
    args << "-DALT_CMAKE=ON"

    # When building with Python, make sure we used brewed python@2
    ENV.prepend_path "PATH", Formula["python@2"].opt_libexec/"bin"
    python_executable = Utils.popen_read("which python").strip
    python_version = Language::Python.major_minor_version("python")
    python_prefix = Utils.popen_read("#{python_executable} -c 'import sys;print(sys.prefix)'").chomp
    python_include = Utils.popen_read("#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'").chomp

    # cmake picks up the system's python dylib, even if we have a brewed one
    dylib = OS.mac? ? "dylib" : "so"
    if File.exist? "#{python_prefix}/Python"
      python_library = "#{python_prefix}/Python"
    elsif File.exist? "#{python_prefix}/lib/libpython#{python_version}.a"
      python_library = "#{python_prefix}/lib/libpython#{python_version}.a"
    elsif File.exist? "#{python_prefix}/lib/libpython#{python_version}.#{dylib}"
      python_library = "#{python_prefix}/lib/libpython#{python_version}.#{dylib}"
    else
      odie "No libpythonX.Y.{a,dylib} file found!"
    end

    args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
    args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"
    args << "-DPYTHON_LIBRARY='#{python_library}'"
    mkdir "build" do
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
