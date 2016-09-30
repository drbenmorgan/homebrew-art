class Cetlib < Formula
  desc "FNAL cetlib C++ library"
  homepage "https://github.com/drbenmorgan/fnal-cetlib"
  url "https://github.com/drbenmorgan/fnal-cetlib.git", :branch => "feature/alt-cmake-macos", :revision => "69219b6"
  version "1.20.0"

  depends_on "cmake" => :build
  depends_on "cetbuildtools2"
  #depends_on "boost" => "c++11"
  depends_on "sqlite"
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
