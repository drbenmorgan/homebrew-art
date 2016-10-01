class FhiclCpp < Formula
  desc "FNAL fhicl-cpp C++ library"
  homepage "https://github.com/drbenmorgan/fnal-fhicl-cpp"
  url "https://github.com/drbenmorgan/fnal-fhicl-cpp.git", :branch => "feature/alt-cmake-macos", :revision => "f1597c4"
  version "4.1.0"

  depends_on "cmake" => :build
  depends_on "cetbuildtools2"
  depends_on "cetlib"
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
