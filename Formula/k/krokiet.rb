class Krokiet < Formula
  desc "Duplicate file utility"
  homepage "https://github.com/qarmin/czkawka"
  url "https://github.com/qarmin/czkawka/archive/refs/tags/12.0.1.tar.gz"
  sha256 "0503f6969a2184fbe2b6b6d786a4ae1b50779f4ce62b57223d1407c70f500587"
  license all_of: ["MIT", "CC-BY-4.0"]
  head "https://github.com/qarmin/czkawka.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/krokiet-12.0.1"
    sha256 cellar: :any, arm64_tahoe:   "a88adb6bf9ed59726220e0136e9c852c7299fee74812ae56c289864cc33b267b"
    sha256 cellar: :any, arm64_sequoia: "84cffc309b33dec136a7ffa916451be16ba4b55e4afecef21c4320caad1c85e5"
    sha256 cellar: :any, sequoia:       "b7996cc02f697f45c7d2c5113ec00921e0db703df356b833f2eee0b7a0cad329"
    sha256 cellar: :any, arm64_linux:   "4cf5741722825a4b425154aee50ab47aacb9d6ad0c50fd3dbbddc81c20a4b4d9"
    sha256 cellar: :any, x86_64_linux:  "392eafe10bf70fa82e64d5ae4594c8518f1f01adf11d999722cf0f21fca6c5dd"
  end

  depends_on "rust" => :build
  depends_on "dav1d"
  depends_on "ffmpeg"
  depends_on "libavif"
  depends_on "libheif"
  depends_on "libraw"
  depends_on "pkgconf"

  uses_from_macos "bzip2"

  on_linux do
    depends_on "fontconfig"
    depends_on "freetype"
  end

  def install
    inreplace "Cargo.toml", "#codegen-units ", "codegen-units "

    arg_cli = %w[heif libraw libavif]
    arg_gui = %w[winit_femtovg winit_skia_opengl winit_software femtovg_wgpu]

    if OS.mac?
      inreplace "Cargo.toml", '#lto = "fat"', 'lto = "thin"'
    else
      inreplace "Cargo.toml", "#lto = ", "lto = "
      arg_gui << "winit_skia_vulkan"
    end

    system "cargo", "install", *std_cargo_args(path: "czkawka_cli", features: arg_cli)
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "krokiet", features: arg_cli + arg_gui)
  end

  test do
    system bin/"czkawka_cli", "dup", "--directories", testpath, "--file-to-save", "results.txt"
    assert_match "Not found any duplicates", File.read("results.txt")

    assert_match version.to_s, shell_output("#{bin}/czkawka_cli --version")
  end
end
