class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.75.0.tar.gz"
  sha256 "1292c5fae9d10d6df3ea0c2ba96de42336e96e2e878729af1f02f86900434ee0"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/rclone-1.75.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "ea6113533fba04106b01ce90f0a48da2fcf1af532f142fcb9a7d4e6485acc06f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ac02c8dd106a18429dec2f4b49da87d5a14ebbb82743760ed15a57ef5d22ae5a"
    sha256 cellar: :any_skip_relocation, sequoia:       "25d0da428a15c88c5784d255bf333c18807d3d4f9fb354350c781155bb105e06"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "8a97ddb79fe7f796c22c7247c05479a202229247d6ddfc6b050098486750119f"
    sha256 cellar: :any,                 x86_64_linux:  "060d73cee461d54583e9bca6ed7d2113c07afe457e541de3572f4a772ab7d3d1"
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
