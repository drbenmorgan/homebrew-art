class ArtTbb < Formula
  desc "Rich and complete approach to parallelism in C++ (Art Suite)"
  homepage "https://www.threadingbuildingblocks.org/"
  url "https://github.com/01org/tbb/archive/2018_U2.tar.gz"
  version "2018_U2"
  sha256 "78bb9bae474736d213342f01fe1a6d00c6939d5c75b367e2e43e7bf29a6d8eca"

  # requires malloc features first introduced in Lion
  # https://github.com/Homebrew/homebrew/issues/32274
  depends_on :macos => :lion
  depends_on "python@2" if MacOS.version <= :snow_leopard || !OS.mac?
  depends_on "swig" => :build

  conflicts_with "tbb", :because => "Art suite needs builds against C++14"

  needs :cxx14

  def install
    compiler = (ENV.compiler == :clang) ? "clang" : "gcc"
    args = %W[tbb_build_prefix=BUILDPREFIX compiler=#{compiler} stdver=c++14]

    # Fix /usr/bin/ld: cannot find -lirml by building rml
    system "make", "rml", *args unless OS.mac?

    system "make", *args
    if OS.mac?
      lib.install Dir["build/BUILDPREFIX_release/*.dylib"]
    else
      lib.install Dir["build/BUILDPREFIX_release/*.so*"]
    end
    include.install "include/tbb"

    # Note that whilst Python module installs, not clear how it functions
    # as importing/running leads to a "no module named _api" error.
    cd "python" do
      ENV["TBBROOT"] = prefix
      ENV.prepend_path "PATH", Formula["python@2"].libexec/"bin" if !OS.mac?
      system "python", *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <tbb/task_scheduler_init.h>
      #include <iostream>

      int main()
      {
        std::cout << tbb::task_scheduler_init::default_num_threads();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++1y", "-L#{lib}", "-ltbb", "-o", "test"
    system "./test"
  end
end
