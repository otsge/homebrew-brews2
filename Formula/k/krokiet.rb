class Krokiet < Formula
  desc "Duplicate file utility"
  homepage "https://github.com/qarmin/czkawka"
  url "https://github.com/qarmin/czkawka/archive/refs/tags/12.0.1.tar.gz"
  sha256 "0503f6969a2184fbe2b6b6d786a4ae1b50779f4ce62b57223d1407c70f500587"
  license all_of: ["MIT", "CC-BY-4.0"]
  head "https://github.com/qarmin/czkawka.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/krokiet-12.0.0"
    sha256 cellar: :any, arm64_tahoe:   "b75272b8532aac889a59ca9546951307f7473fa0c007ac12ecc50fcaf6bf2e47"
    sha256 cellar: :any, arm64_sequoia: "a4d4d37ef96d2ee476be3e0b8bc56072cb769b63e71669e7c7436d238580442a"
    sha256 cellar: :any, sequoia:       "534f3df005ffbed357c6d31a46c440f0b07f2f26ebf4e702bf51d381635cb23d"
    sha256 cellar: :any, arm64_linux:   "33e58fa336ba2a3f02a54f7a3592a919e7955c6a072e80bc5d15f0c28f5b40c5"
    sha256 cellar: :any, x86_64_linux:  "daef47485bc4a0a649d1e807928bc8ac5d190f4a0325521544f9865496d511c5"
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
