class Cetbuildtools2 < Formula
  desc "Custom CMake functionality for building Art Software Stack"
  homepage "https://github.com/drbenmorgan/cetbuildtools2"
  url "https://github.com/drbenmorgan/cetbuildtools2.git", :branch => "develop", :revision => "9b4993b"
  version "0.2.0"

  depends_on "cmake"
  depends_on "sphinx-doc" => :recommended

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DSPHINX_BUILD_HTML=ON" if build.with? "sphinx-doc"
      system "cmake", "../", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(cetbuildtools2)")
    system "cmake", "."
  end
end
