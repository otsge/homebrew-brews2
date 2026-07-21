class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.1/forgejo-src-16.0.1.tar.gz"
  sha256 "3699caf038f097cf01c1633d64df966e27916bcb5c46fcd0a5130c9debb858b2"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-16.0.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c21773efe07f4ce151b3948822c1adbb1af3078f84701261e55e8e31ad28e895"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8bf5821847ddaf6eade45cfc14d393aaac5233c9f920017687db6c7ff2b4911d"
    sha256 cellar: :any_skip_relocation, sequoia:       "0350b50fc248bbbe433320259b0f58b4005409db0d0bad3cef2abcc917dbf693"
    sha256 cellar: :any,                 arm64_linux:   "49fe2fcd528976478f996b111bd222dcda41968b43444896f2396cb96d188b49"
    sha256 cellar: :any,                 x86_64_linux:  "359fd8048a88f9dc629338e6d8e00b48440da703e4f31d5459997f977a220329"
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
