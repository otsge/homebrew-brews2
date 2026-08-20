class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.3/forgejo-src-16.0.3.tar.gz"
  sha256 "169df80055a819e3062eab365c384470ad34f71a0b921a58c3dcd1f838c10864"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-16.0.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e25bb3c2b5daabdef3f22a0fa90b8e176a09b6716a93d896c1cbe5026e7848ba"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0b43116a34f89c5e81c783093eae299a437e2a3fef5158c017c7d30fb50063b0"
    sha256 cellar: :any_skip_relocation, sequoia:       "c1f85ee771487567654e35c570daa1be4fb3c3e90bbb29bceb762e34df0be155"
    sha256 cellar: :any,                 arm64_linux:   "155b06e86d3d1d003cb5a8e5b2afd693ad70be31cb4f6414372c1deeef392049"
    sha256 cellar: :any,                 x86_64_linux:  "28ba825d7ebafb050b562f27e548ebbdc91c3aab44d1e68b9e9cd218b0bf112d"
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
