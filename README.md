# DirectXShaderCompiler Homebrew Tap

A Homebrew tap for installing the [DirectX Shader Compiler (DXC)](https://github.com/microsoft/DirectXShaderCompiler) on macOS.

## Installation

```bash
# Add this tap
brew tap SharkyRawr/dxc

# Install DXC
brew install directx-shader-compiler
```

Or install directly without adding the tap:

```bash
brew install SharkyRawr/dxc/directx-shader-compiler
```

## Usage

After installation, you can use the `dxc` command:

```bash
# Compile a pixel shader
dxc -T ps_6_0 -E main -Fo output.dxil input.hlsl

# Show help
dxc --help
```

## What is DirectX Shader Compiler?

The DirectX Shader Compiler is a compiler and related tools used to compile High-Level Shader Language (HLSL) programs into DirectX Intermediate Language (DXIL) representation. It's based on LLVM/Clang and supports:

- Compiling HLSL to DXIL (Shader Model 6.0+)
- SPIR-V code generation
- Shader validation and disassembly
- Cross-platform shader compilation

## Uninstallation

```bash
brew uninstall directx-shader-compiler
brew untap SharkyRawr/dxc
```

## License

The DirectX Shader Compiler is distributed under the University of Illinois Open Source License (LLVM License).
