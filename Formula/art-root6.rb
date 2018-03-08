class ArtRoot6 < Formula
  desc "CERN C++ Data Analysis and Persistency Libraries (Art Suite)"
  homepage "http://root.cern.ch"
  url "http://root.cern.ch/download/root_v6.12.04.source.tar.gz"
  mirror "https://fossies.org/linux/misc/root_v6.12.04.source.tar.gz"
  version "6.12.04"
  sha256 "f438f2ae6e25496fa81df525935fb0bf2a403855d95c40b3e0f3a3e1e861a085"

  head "http://root.cern.ch/git/root.git"

  depends_on "cmake" => :build
  depends_on "art-tbb"
  depends_on "xz" # For LZMA
  depends_on "libxml2" unless OS.mac? # For XML on Linux
  depends_on "openssl"
  depends_on "sqlite"
  depends_on "gsl"
  depends_on "python" => :recommended
  depends_on "python@2" => :optional

  conflicts_with "root", :because => "Art suite needs c++14"

  needs :cxx14

  def cmake_opt(opt, pkg = opt)
    "-D#{opt}=#{build.with? pkg ? "ON" : "OFF"}"
  end

  def install
    # Work around "error: no member named 'signbit' in the global namespace"
    ENV.delete("SDKROOT") if DevelopmentTools.clang_build_version >= 900

    # brew audit doesn't like non-executables in bin
    # so we will move {thisroot,setxrd}.{c,}sh to libexec
    # (and change any references to them)
    #inreplace Dir["config/roots.in", "config/thisroot.*sh",
    #              "etc/proof/utils/pq2/setup-pq2",
    #              "man/man1/setup-pq2.1", "README/INSTALL", "README/README"],
    #  /bin.thisroot/, "libexec/thisroot"

    args = *std_cmake_args
    args << "-DCMAKE_ELISPDIR=#{elisp}"

    # Disable everything that might be ON by default
    args = args + %W[
      -Dalien=OFF
      -Dasimage=OFF
      -Dastiff=OFF
      -Dbonjour=OFF
      -Dcastor=OFF
      -Dchirp=OFF
      -Ddavix=OFF
      -Ddcache=OFF
      -Dfitsio=OFF
      -Dfortran=OFF
      -Dgfal=OFF
      -Dglite=OFF
      -Dgviz=OFF
      -Dhdfs=OFF
      -Dkrb5=OFF
      -Dldap=OFF
      -Dmonalisa=OFF
      -Dmysql=OFF
      -Dodbc=OFF
      -Doracle=OFF
      -Dpgsql=OFF
      -Dpythia6=OFF
      -Dpythia8=OFF
      -Dqt=OFF
      -Drfio=OFF
      -Dsapdb=OFF
      -Dsrp=OFF
      -Dunuran=OFF
    ]

    # Now the core/builtin things we want
    args = args + %W[
      -Dcxx14=ON
      -Dfail-on-missing=ON
      -Dgnuinstall=ON
      -Dexplicitlink=ON
      -Drpath=ON
      -Dsoversion=ON
      -Dbuiltin_asimage=ON
      -Dasimage=ON
      -Dbuiltin_fftw3=ON
      -Dbuiltin_freetype=ON
      -Droofit=ON
      -Dgdml=ON
      -Dminuit2=ON
    ]

    # Options that require an external
    args = args + %W[
      -Dsqlite=ON
      -Dssl=ON
      -Dmathmore=ON
      -Dxrootd=OFF
    ]

    # Python requires a bit of finessing
    if build.with?("python") && build.with?("python@2")
       odie "Root: Does not support building both python 2 and 3 wrappers"
    elsif build.with?("python") || build.with?("python@2")
      if build.with? "python@2"
        ENV.prepend_path "PATH", Formula["python@2"].opt_libexec/"bin"
        python_executable = Utils.popen_read("which python").strip
        python_version = Language::Python.major_minor_version("python")
      elsif build.with? "python"
        python_executable = Utils.popen_read("which python3").strip
        python_version = Language::Python.major_minor_version("python3")
      end

      python_prefix = Utils.popen_read("#{python_executable} -c 'import sys;print(sys.prefix)'").chomp
      python_include = Utils.popen_read("#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'").chomp
      args << "-Dpython=ON"

      # cmake picks up the system's python dylib, even if we have a brewed one
      if File.exist? "#{python_prefix}/Python"
        python_library = "#{python_prefix}/Python"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
        python_library = "#{python_prefix}/lib/lib#{python_version}.a"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.dylib"
        python_library = "#{python_prefix}/lib/lib#{python_version}.dylib"
      else
        odie "No libpythonX.Y.{a,dylib} file found!"
      end
      args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
      args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"
      args << "-DPYTHON_LIBRARY='#{python_library}'"
    else
      args << "-Dpython=OFF"
    end

    mkdir "cmake-build" do
      system "cmake", "..", *args

      # Follow upstream homebrew
      # Work around superenv stripping out isysroot leading to errors with
      # libsystem_symptoms.dylib (only available on >= 10.12) and
      # libsystem_darwin.dylib (only available on >= 10.13)
      if OS.mac? && MacOS.version < :high_sierra
        system "xcrun", "make", "install"
      else
        system "make", "install"
      end

      chmod 0755, Dir[bin/"*.*sh"]
    end
  end

  def caveats; <<~EOS
    Because ROOT depends on several installation-dependent
    environment variables to function properly, you should
    add the following commands to your shell initialization
    script (.bashrc/.profile/etc.), or call them directly
    before using ROOT.

    For bash users:
      . #{HOMEBREW_PREFIX}/bin/thisroot.sh
    For zsh users:
      pushd #{HOMEBREW_PREFIX} >/dev/null; . bin/thisroot.sh; popd >/dev/null
    For csh/tcsh users:
      source #{HOMEBREW_PREFIX}/bin/thisroot.csh
    EOS
  end

  test do
    (testpath/"test.C").write <<~EOS
      #include <iostream>
      void test() {
        std::cout << "Hello, world!" << std::endl;
      }
    EOS
    (testpath/"test.bash").write <<~EOS
      . #{bin}/thisroot.sh
      root -l -b -n -q test.C
    EOS
    assert_equal "\nProcessing test.C...\nHello, world!\n",
                 shell_output("/bin/bash test.bash")

    if build.with? "python"
      ENV["PYTHONPATH"] = lib/"root"
      system "python3", "-c", "import ROOT"
    end
  end
end
