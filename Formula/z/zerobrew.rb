class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "47e325a8de0b104fd9ee4a12062ba60b7edd225c951b3bea047603750dd760f1"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/zerobrew-0.2.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "105ef1ba067e3149a9f8b97396c8c8be430b84afb07b8392f3b057beff2dd2b9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "908cece87ef8bc9eaf34bafae55d06492bd3005b9ba3f7367636e7b748c07692"
    sha256 cellar: :any_skip_relocation, tahoe:         "424b223fe98181657fef82f15cdcca7c62a7c86c19d4ca0a1dbd3568c6752ee7"
    sha256 cellar: :any_skip_relocation, sequoia:       "508b7fb4973f8b9be791000ea277d9b278376893fa49aba00894f562e1c7882e"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "8ef487e8fd0f6b7e27a4d2571b8fd0cbbc4c9f4e906782d1ec6669d46cf9ccbd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "be289935b3f822608035a54177ce077192e4714c60efeafaba6f0ec01b7b92ec"
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
