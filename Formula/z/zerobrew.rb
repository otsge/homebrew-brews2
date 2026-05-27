class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "47e325a8de0b104fd9ee4a12062ba60b7edd225c951b3bea047603750dd760f1"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  depends_on "rust" => :build

  def install
    ENV["LZMA_API_STATIC"] = "1"

    system "cargo", "install", *std_cargo_args(path: "zb_cli")

    generate_completions_from_executable(bin/"zb", "completion",
                                         shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    system bin/"zb", "--version"
  end
end
