class Krokiet < Formula
  desc "Duplicate file utility"
  homepage "https://github.com/qarmin/czkawka"
  url "https://github.com/qarmin/czkawka/archive/refs/tags/12.0.0.tar.gz"
  sha256 "cc5183c2ad251bc83d67dc6b12205a0d3d41a568ef89f16db27eb81f15c20e02"
  license all_of: ["MIT", "CC-BY-4.0"]
  head "https://github.com/qarmin/czkawka.git", branch: "master"

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
