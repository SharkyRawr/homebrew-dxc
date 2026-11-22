class DirectxShaderCompiler < Formula
  desc "DirectX Shader Compiler based on LLVM/Clang"
  homepage "https://github.com/microsoft/DirectXShaderCompiler"
  url "https://github.com/microsoft/DirectXShaderCompiler.git",
      tag:      "v1.9.2609",
      revision: "01b62ad47db7dee3dd33f90e7339cf9e860b3f93"
  license "LLVM"

  bottle do
    root_url "https://github.com/SharkyRawr/homebrew-dxc/releases/download/v1.9.2609"
    sha256 cellar: :any, arm64_tahoe: "db0eac0d9f065a63c11a312bb6c46f05571dd1a56a78b27ebac43892f7ef3638"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "python@3.12" => :build

  # Build fails with Apple clang
  on_macos do
    depends_on "llvm" => :build
  end

  def install
    # Initialize submodules
    system "git", "submodule", "update", "--init", "--recursive"

    # Create build directory
    builddir = "build"

    # Set up CMake arguments
    args = %W[
      -C #{buildpath}/cmake/caches/PredefinedParams.cmake
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DHLSL_DISABLE_SOURCE_GENERATION=ON
      -G Ninja
    ]

    # Use Homebrew's LLVM on macOS
    if OS.mac?
      llvm = Formula["llvm"]
      ENV["CC"] = "#{llvm.opt_bin}/clang"
      ENV["CXX"] = "#{llvm.opt_bin}/clang++"
      ENV.append "CXXFLAGS", "-Wno-invalid-specialization"
      args << "-DLLVM_ENABLE_LLD=ON"
    end

    system "cmake", "-B", builddir, "-S", ".", *args
    system "cmake", "--build", builddir, "--parallel"

    # Install binaries to bin
    bin.install Dir["#{builddir}/bin/dxc*"]
    bin.install Dir["#{builddir}/bin/dxv*"]

    # Install libraries
    lib.install Dir["#{builddir}/lib/libdxcompiler.*"]
    lib.install Dir["#{builddir}/lib/libdxilconv.*"] if File.exist?("#{builddir}/lib/libdxilconv.dylib") || File.exist?("#{builddir}/lib/libdxilconv.so")

    # Install headers
    include.install Dir["include/dxc/*"]

    # Install tools
    if File.directory?("#{builddir}/tools")
      prefix.install Dir["#{builddir}/tools/*"]
    end
  end

  test do
    # Test that dxc can compile a simple HLSL shader
    (testpath/"test.hlsl").write <<~EOS
      float4 main() : SV_Target {
        return float4(1.0, 0.0, 0.0, 1.0);
      }
    EOS

    system bin/"dxc", "-T", "ps_6_0", "-E", "main", "-Fo", "test.dxil", "test.hlsl"
    assert_path_exists testpath/"test.dxil"
  end
end
