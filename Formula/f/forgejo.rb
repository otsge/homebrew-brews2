class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.4/forgejo-src-16.0.4.tar.gz"
  sha256 "13c5d34ff00cf24e8dc27d9b4df69d1e85263398c56ccab3e944ee8b0bb89ab2"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-16.0.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "43f079a45b067c00197b12763924e6b6525a384c9ec88d7f8ab1f4b2a4b47093"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "00855e06e5d4a9b2db8d989a43b3d6c8dcad1bc278b9024a3728de38cabcd997"
    sha256 cellar: :any,                 arm64_linux:   "915c21a45874e92ca84ba7584d4a474dd910472998344591b555639af71b9f12"
    sha256 cellar: :any,                 x86_64_linux:  "90fad61353ceb917553cf7bcecfc0a0469eb75fe9909622c2dd1dac2e01a7942"
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
