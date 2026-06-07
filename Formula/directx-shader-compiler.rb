class DirectxShaderCompiler < Formula
  desc "DirectX Shader Compiler based on LLVM/Clang"
  homepage "https://github.com/microsoft/DirectXShaderCompiler"
  url "https://github.com/microsoft/DirectXShaderCompiler.git",
      tag:      "v1.10.2605.24",
      revision: "c1e1fc784b0fb40e333c809b8206fe576ea89be8"
  license "LLVM"

  bottle do
    root_url "https://github.com/SharkyRawr/homebrew-dxc/releases/download/v1.10.2605.24"
    rebuild 2
    sha256 cellar: :any, arm64_tahoe: "e39e7bd6018d683bd49047c72be0d80fae93ff94c825aa59650d6225f0cde8c1"
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
