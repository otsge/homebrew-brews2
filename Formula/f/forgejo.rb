class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.3/forgejo-src-15.0.3.tar.gz"
  sha256 "39ac3023d1d6165a87d89bb44402ec4567327d952900d5522b92a3951b45db45"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-15.0.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8622cd012bf66605e59d67ec6f25ff233208c66886ad9aa2dcb0912e31c59018"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "db9ba1866f94685e0b5fc12f7c7700b9f221a4065e1ada2508d2fbd25e05b24b"
    sha256 cellar: :any_skip_relocation, tahoe:         "d1b6bd88e0bcfa6200979920e346baeaee560e2f65da1201572f2681b00483b1"
    sha256 cellar: :any_skip_relocation, sequoia:       "329c69eefa91733073856881231a8babba49b95e05f3751a02664a7803843819"
    sha256 cellar: :any,                 arm64_linux:   "e8d925f91c90cfc980d4489e6743cd1372e28b63957fd3fea3f688ef43e6af5d"
    sha256 cellar: :any,                 x86_64_linux:  "38e59a3a58cf985894a9b73ae4178bc69fbed4cc24cedc57ea034db58993fded"
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
