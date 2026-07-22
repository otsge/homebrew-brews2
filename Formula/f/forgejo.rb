class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.1/forgejo-src-16.0.1.tar.gz"
  sha256 "3699caf038f097cf01c1633d64df966e27916bcb5c46fcd0a5130c9debb858b2"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-16.0.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "76577e2707f84eb14352fd738d152d6e7f7c74d7e62d193566c160e0eae81a46"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3bf2890bdff7aaa344d424c0c3668e68112d1b1eafa843861d089d9261202c46"
    sha256 cellar: :any_skip_relocation, sequoia:       "222244e179bf3608eb1fe3e6f0c302c05860289a0a74802a66aa0da3c61f031f"
    sha256 cellar: :any,                 arm64_linux:   "9dea9c74d4b3743d684212472b0fea5c15e7ea7801146aff25874dd06425c295"
    sha256 cellar: :any,                 x86_64_linux:  "3abd5681cb1b6048ac1aad128aa5beae8117c50f19c16e91e6c0ac677dccda26"
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
