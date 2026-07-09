class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.4/forgejo-src-15.0.4.tar.gz"
  sha256 "2edac43d70380587dde35d8d8a80fe5791909b9d79d1a564a4d1056bc5261dda"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-15.0.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "39ee1ecf4481922ec1c0193d678e05ff4d78b1dec93eea399ea7e5208c124dc4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e3d4facfca7a9d43b490c9e33d5c47e4e1e57a39218b10ad34282bf567ba8719"
    sha256 cellar: :any_skip_relocation, sequoia:       "78d87466598e7bf3f629ea8d55964babc4cee6055ac0b4398b8b7aaa98077233"
    sha256 cellar: :any,                 arm64_linux:   "2d47a5397f057c67b2a92b6b6b8daec33bf00445904861e88c2af5c234a1f175"
    sha256 cellar: :any,                 x86_64_linux:  "11b4badb9d73d595cd800e36de9d7012e766970327b9776d46df727c60eb31f4"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea" => "forgejo"
    bin.install "environment-to-ini"
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path var/"log/forgejo.log"
    error_log_path var/"log/forgejo.log"
  end

  test do
    ENV["FORGEJO_WORK_DIR"] = testpath
    port = free_port

    pid = spawn bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s

    output = shell_output("curl --silent --retry 5 --retry-connrefused http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl --silent http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
