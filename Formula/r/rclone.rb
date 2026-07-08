class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.4.tar.gz"
  sha256 "b8279a31a5249e4aecf04acff744ace4a2e3a169e4539a24aa67a9994f645d3b"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/rclone-1.74.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0319347b52032a4dd33f80fccff9c544ddf1a4ce0eb721eac964c4bf974c5644"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "af9f3a66bfae63eb08ee61006301570ce3fb15f360dc41f3e9674e9c462f63bd"
    sha256 cellar: :any_skip_relocation, sequoia:       "c3f5a9d6e48b9f366e78f2ee30a2824a97ee049f12dc9ad241648c0427d0d8d5"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "88253bab74522152431c5ff01971ed21fd8007eea41d8b5e062087c0f9b4c674"
    sha256 cellar: :any,                 x86_64_linux:  "8cd70c763212dc1576bc5db20307dcc403713e1e7fdbfff59626cdc79ade41cd"
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
