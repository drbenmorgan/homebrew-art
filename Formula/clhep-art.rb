class ClhepArt < Formula
  desc "Class Library for High Energy Physics"
  homepage "https://proj-clhep.web.cern.ch/proj-clhep/"
  url "https://proj-clhep.web.cern.ch/proj-clhep/DISTRIBUTION/tarFiles/clhep-2.4.0.1.tgz"
  sha256 "4c7e2c6ac63e0237100e4ddcbfdc3d7e7dc6592f95bdbdcc0e43a6892b9fd6e0"

  conflicts_with "clhep", :because => "we need c++14"

  head do
    url "https://gitlab.cern.ch/CLHEP/CLHEP.git"
  end

  depends_on "cmake" => :build

  def install
    # CLHEP is super fussy and doesn't allow source tree builds
    dir = Dir.mktmpdir
    cd dir do
      args = std_cmake_args
      if build.stable?
        args << buildpath/"CLHEP"
      else
        args << buildpath
      end
      args << "-DCLHEP_BUILD_CXXSTD=-std=c++14"
      system "cmake", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <Vector/ThreeVector.h>

      int main() {
        CLHEP::Hep3Vector aVec(1, 2, 3);
        std::cout << "r: " << aVec.mag();
        std::cout << " phi: " << aVec.phi();
        std::cout << " cos(theta): " << aVec.cosTheta() << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "-L#{lib}", "-lCLHEP", "-I#{include}/CLHEP",
           testpath/"test.cpp", "-o", "test"
    assert_equal "r: 3.74166 phi: 1.10715 cos(theta): 0.801784",
                 shell_output("./test").chomp
  end
end
