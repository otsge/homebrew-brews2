class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "696fb9028a4b553fe87eb58af81f44f0676312e07ed89be78fc0886f1f3127a5"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/zerobrew-0.3.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9855f3de1afd2df28b6e5131d212c39ec153298bacb4e12deea0daa62e8546be"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4a5c625aa4580ab9dd6e9b253e6d825f156f1a40d2fb048eaea07bf83c469e55"
    sha256 cellar: :any_skip_relocation, tahoe:         "5925d2846b62ced7125e01396550bf68f684c0ec0843fad1172dedcb2f79f841"
    sha256 cellar: :any_skip_relocation, sequoia:       "cd7a6e55574bc328fef92a76ecb6cf8daa7313b2c0dd41f055576d56d52e17f1"
    sha256 cellar: :any,                 arm64_linux:   "862b9bf9c874a625d2ef5d77dc2a46ded2cbd11fb38674d3032045d964b4d724"
    sha256 cellar: :any,                 x86_64_linux:  "e8359027fe09395c51fa2a79e8a8dda83e8f6de9e38c3d8c07fdaced66f3db27"
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
