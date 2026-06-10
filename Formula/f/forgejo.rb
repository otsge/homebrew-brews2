class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.3/forgejo-src-15.0.3.tar.gz"
  sha256 "39ac3023d1d6165a87d89bb44402ec4567327d952900d5522b92a3951b45db45"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-15.0.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "df388fe1a5059057a2463fb1c2561ed984e0d0235c0461b6a085d0bfb8f20d91"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "50406190a7b2277c5248a5994659ed175c92def8efa98250b4c78f1b0a90c5b5"
    sha256 cellar: :any_skip_relocation, tahoe:         "4f4c95880a14f3d78ad378c78e0eea93e8fbb7a81031ba60c0e9347ba7f9e774"
    sha256 cellar: :any_skip_relocation, sequoia:       "0bb057e867ec503943928f789a43521cb057f1bd9f2f95c2e1a3389421a610c1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9adcf111d6f360aad3704ee249150780a2dcc828ea3e6f19ef3df5c1595c1e17"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "30b8618f090e5ac18311035038f83e4129e83f3fdc24b5ae8ab97465c47115ff"
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
