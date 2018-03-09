class Cetbuildtools2 < Formula
  desc "Custom CMake functionality for building Art Software Suite"
  homepage "https://github.com/drbenmorgan/cetbuildtools2"
  url "https://github.com/drbenmorgan/cetbuildtools2.git", :tag => "v0.5.1"
  head "https://github.com/drbenmorgan/cetbuildtools2.git", :branch => "develop"

  depends_on "cmake" => [:build, :run]
  depends_on "sphinx-doc" => [:recommended, :build]

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DSPHINX_BUILD_HTML=ON" if build.with? "sphinx-doc"
      system "cmake", "../", *args
      system "ctest", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(cetbuildtools2 REQUIRED)")
    system "cmake", "."
  end
end
