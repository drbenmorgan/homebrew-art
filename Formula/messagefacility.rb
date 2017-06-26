class Messagefacility < Formula
  desc "FNAL messagefacility C++ library"
  homepage "https://github.com/drbenmorgan/fnal-messagefacility"
  url "https://github.com/drbenmorgan/fnal-messagefacility.git", :branch => "feature/alt-cmake"
  version "2.0.2"

  depends_on "cmake" => :build
  depends_on "cetbuildtools2"
  depends_on "cetlib"
  depends_on "cetlib_except"
  depends_on "fhicl-cpp"
  #depends_on "boost" => "c++11"
  depends_on "sqlite"
  depends_on "tbb" => ["--c++11"]
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
