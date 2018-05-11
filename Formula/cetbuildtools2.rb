class Cetbuildtools2 < Formula
  desc "Custom CMake functionality for building Art Software Suite"
  homepage "https://github.com/drbenmorgan/cetbuildtools2"
  url "https://github.com/drbenmorgan/cetbuildtools2.git", :tag => "v0.6.0"
  head "https://github.com/drbenmorgan/cetbuildtools2.git", :branch => "develop"

  depends_on "cmake"
  depends_on "sphinx-doc" => [:recommended, :build]

  # Sphinx rtd_theme foir docs
  resource "sphinx_rtd_theme" do
    url "https://files.pythonhosted.org/packages/8b/e5/b1933472424b30affb0a8cea8f0ef052a31ada96e5d1823911d7f4bfdf8e/sphinx_rtd_theme-0.2.4.tar.gz"
    sha256 "2df74b8ff6fae6965c527e97cca6c6c944886aae474b490e17f92adfbe843417"
  end

  def install
    if build.with? "sphinx-doc"
      # sphinx-doc needs "python" in the path as sphinx-build uses
      # "usr/bin/env python" to locate it. So need to put python@2's
      # libexec in the path
      ENV.prepend_path "PATH", Formula["python@2"].libexec/"bin"

      # Stage theme resource
      (buildpath/"documentation").install resource("sphinx_rtd_theme")
    end

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
