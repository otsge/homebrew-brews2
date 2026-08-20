class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.3/forgejo-src-16.0.3.tar.gz"
  sha256 "169df80055a819e3062eab365c384470ad34f71a0b921a58c3dcd1f838c10864"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-16.0.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "df841cacbdaae7acb1c5cb2d5559d56df601c5f3aa217d3f8ae7ed04e3f00c75"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cfbeb5f2983e700380fc7452dc28071401850d853dc8ce3da142971f0b1fdc0b"
    sha256 cellar: :any_skip_relocation, sequoia:       "957e9c628cbbb047dc8aba37cc6564fc3f7702530c2f4eb07bc60d321e36601a"
    sha256 cellar: :any,                 arm64_linux:   "efba83d5027ede90f546c4d7613b92ed097e1e242f4b99572644b7b53066557e"
    sha256 cellar: :any,                 x86_64_linux:  "5f79ef094617bb2c2b476dc7b48a77791d2685bc0b0f284de57505611da76bf8"
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
