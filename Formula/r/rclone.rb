class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.75.1.tar.gz"
  sha256 "fcc9351ab3976c73b4824cf7919f98f911f2442a606e2910fc2bd562111da220"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/rclone-1.75.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d9e61dc6a22f253bc467651966f2666ea292a3767cb83b57d31adeae11b06cec"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bfb1ef707e6a1260d5532878db747c2118e16a6c2716930c2e3b2f92cfbfed49"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "947b7c05b15ecc58ac9d7e5a7b6eeb2286b102d64485296a62b1ef472000a292"
    sha256 cellar: :any,                 x86_64_linux:  "9fc3a2103ed6c88ca0ffd60bd1602157bd84690d4b494864285370b4ac76fac9"
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
