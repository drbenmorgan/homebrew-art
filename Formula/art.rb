class Art < Formula
  desc "FNAL Art event processing framework for particle physics experiments"
  homepage "https://github.com/drbenmorgan/fnal-art.git"
  url "https://github.com/drbenmorgan/fnal-art.git", :branch => "feature/new-alt-cmake"
  version "2.10.1"
  head "https://github.com/drbenmorgan/fnal-art.git", :branch => "feature/new-alt-cmake"

  depends_on "cmake" => :build
  depends_on "cppunit" => :build
  depends_on "doxygen" => [:recommended, :build]
  depends_on "python@2" => :build # for dictionaries
  depends_on "art-boost"
  depends_on "art-clhep"
  depends_on "art-root6"
  depends_on "art-tbb"
  depends_on "cetbuildtools2"
  depends_on "cetlib_except"
  depends_on "cetlib"
  depends_on "fhicl-cpp"
  depends_on "messagefacility"
  depends_on "canvas"
  depends_on "canvas_root_io"
  depends_on "sqlite"

  needs :cxx14

  def install
    ENV.prepend_path "PATH", Formula["python@2"].libexec/"bin"

    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      args << "-DCET_COMPILER_WARNINGS_ARE_ERRORS=OFF" if !OS.mac?
      # To find root at runtime on linux, because it subdirs its libs
      args << "-DCMAKE_INSTALL_RPATH=#{Formula["art-root6"].lib/"root"}"
      # Testing only strictly needed at bottling time
      args << "-DBUILD_TESTING=OFF" unless build.bottle?
      system "cmake", "..", *args
      system "make"
      system "ctest", "-j#{ENV.make_jobs}"
      system "make", "install/fast"

      # Temp fix for executable rpaths on mac
      # Todo: should be appropriately set by build system, as ROOT does.
      Dir["#{bin}/*"].each do |art_exe|
          MachO::Tools.add_rpath(art_exe, "@executable_path/../lib") if OS.mac?
      end
    end
  end

  test do
    # Need a basic exercise...
    false
  end
end
