class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.1.tar.gz"
  sha256 "aa0470151fe2e33d6bb96657892dfc4d56f92472a2dedebdda4ff296e87b79dc"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/rclone-1.74.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f2a40a24e7032bdd3bdd164c4d64379fd5630574b11d54473ae70efc7aa78c5d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0741d251648878d0f74806dd9c4700d9961b59b71875896f58103acbb17bf720"
    sha256 cellar: :any_skip_relocation, tahoe:         "e54ea790aa798be26c9760afb59bb4282bf07d4468c8650428fc7af789a9c3b6"
    sha256 cellar: :any_skip_relocation, sequoia:       "e6269f48494544aad4f03eb1dd4ca4fa3b898e7a4c51110a39862121e81997d7"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "052ffb086ef8fb097266c9b9870755a1653e73e413ed7ea2b41361de8632489b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3e48dac9b077d762898e51dde0cf5071bb572b68084a588eb9fb9616869128cc"
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
