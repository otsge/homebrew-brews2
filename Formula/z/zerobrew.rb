class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "e35b4f20a04866e67c553e2467f9f57e254b67ada1a2e53c74aa9fbf174f5a3d"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/zerobrew-0.3.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fdd86477c40dee2f9cbe87f9d09581214664c65bb05edd8e480b196630e062c9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4cf4c5ef404b5e8bff50b93ec303b3eecfc66d4fb0cfad49cbac20fc83662b13"
    sha256 cellar: :any_skip_relocation, tahoe:         "4f7a52e28628621d68fe5b6744aa64693d81eca87121ac13297da60427874bba"
    sha256 cellar: :any_skip_relocation, sequoia:       "9bb732b45fd2f6899039fa044e348cb0cde60dcdc2f0f3194f6d8a4cc8cee77a"
    sha256 cellar: :any,                 arm64_linux:   "e772b8831e0421b3b3fc0340e9261f2350e0d779d9e45a6dddcb39629ea5b8d5"
    sha256 cellar: :any,                 x86_64_linux:  "5228ff2ca41c5143bea780dc295e6332b5be2f1c1bcd8e14df95d775facef250"
  end

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
