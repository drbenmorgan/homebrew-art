 class RangeV3 < Formula
  desc "Experimental range library for C++11/14/17"
  homepage "https://github.com/ericniebler/range-v3"
  head "https://github.com/ericniebler/range-v3.git"
  url "https://github.com/ericniebler/range-v3/archive/0.3.0.tar.gz"
  sha256 "cc29fbed5b06b11e7f9a732f7e1211483ebbd3cfe29d86e40c93209014790d74"
  depends_on "cmake" => :build

  needs :cxx14

  def install
    system "cmake", ".", *std_cmake_args
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test range-v`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
