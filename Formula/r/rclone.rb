class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.2.tar.gz"
  sha256 "2373a74751cfd2034cc6b792a9a15d119087cb77975f3c9fcd7a4503c15102b0"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/rclone-1.74.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "88eb6f40cc12d701e8dc6c8eda71297a089f4454ea0e80a07fb58b7f020da7c8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8bc4ee41991f7c62e8cfcd57be551d3f8aef1a94995e8c48e9c8c03bb6bab096"
    sha256 cellar: :any_skip_relocation, tahoe:         "3fc5a6692802c05d402762d80450632c6abfe23ae98927032c5ea692aa925b70"
    sha256 cellar: :any_skip_relocation, sequoia:       "ce96d87395bfca2bc38a0871d95e220c3f53676ab0e8a226b3c8de2a21aea7ca"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "cbbf0eeaa5cfdbce112543813bb7973bca40abcdef9698ba176b16e60e40e443"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b1f5d1086603837ee074d0b896935937ef7ca00626f34025ad14b5fbee899393"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = "#{HOMEBREW_CACHE}/go_mod_cache/pkg/mod"

    if OS.mac? && Hardware::CPU.arm?
      ENV.append "CGO_FLAGS", "-I/usr/local/include"
      ENV.append "CGO_LDFLAGS", "-L/usr/local/lib"
    end

    args = ["GOTAGS=cmount"]
    system "make", *args
    man1.install "rclone.1"
    system bin/"rclone", "genautocomplete", "bash", "rclone.bash"
    system bin/"rclone", "genautocomplete", "zsh", "_rclone"
    system bin/"rclone", "genautocomplete", "fish", "rclone.fish"
    bash_completion.install "rclone.bash" => "rclone"
    zsh_completion.install "_rclone"
    fish_completion.install "rclone.fish"
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
