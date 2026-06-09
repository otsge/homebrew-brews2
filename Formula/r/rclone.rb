class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.3.tar.gz"
  sha256 "3ba8bc7fb216f8f0307357ac67842467f453050468d5751e9269954819148568"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/rclone-1.74.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "49a0b7ae1de77243adfa18914ec08189ada8e62f5c32ad4d38f91df761e3ea68"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4fed751f0e1e01d2dccc41da20560690114bf8bd8a7610b43fe9c27cb9bbfff8"
    sha256 cellar: :any_skip_relocation, tahoe:         "0e7045f7be9881d26ecc130a429c2e8e9a44d3e796b2517a9fece7d826e2e7d4"
    sha256 cellar: :any_skip_relocation, sequoia:       "cad20508d5a331eeae94f6c6c97f85402a77d0d0d84a77f82fc0206dfaae4301"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a64228aca51a868cf0032cc745c6990c7a957467b50bd7f9a0d7a01712c52603"
    sha256 cellar: :any,                 x86_64_linux:  "c151c6b2d1505dc2933dda890149e2a26a7ff348037c8ba7650a3ac974d33bce"
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
