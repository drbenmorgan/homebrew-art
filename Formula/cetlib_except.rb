class CetlibExcept < Formula
  desc "FNAL cetlib_except C++ library"
  homepage "https://github.com/drbenmorgan/fnal-cetlib_except"
  url "https://github.com/drbenmorgan/fnal-cetlib_except.git", :branch => "feature/alt-cmake"
  version "1.1.0"

  depends_on "cmake" => :build
  depends_on "cetbuildtools2"
  depends_on "doxygen" => :optional

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DALT_CMAKE=ON"
      system "cmake", "../", *args
      system "make", "install"
    end
  end

  test do
    false
  end
end
