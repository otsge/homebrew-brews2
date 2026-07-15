class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.5/forgejo-src-15.0.5.tar.gz"
  sha256 "1005e5c6f7340e0cd86a7b3f4c34ae5c353fc34d012b6c6613eecfeea3ec8f99"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-15.0.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "72d7f4e84beceb18f193a5e60a662de588202fd542c73ab68098ceec3d00bdcf"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "99cbce833fa81d5144aace888188193b77eeea88f6b2bdec31f77155a387f1ab"
    sha256 cellar: :any_skip_relocation, sequoia:       "5d2ae78e216f244e3eea9e53a85660f0d9010723cebe444880e2713512645296"
    sha256 cellar: :any,                 arm64_linux:   "6575597615242a43f2f96b5301e92764ba1bc403155845c3e0f9d1281fb7e1b5"
    sha256 cellar: :any,                 x86_64_linux:  "c5f1fb6cbde9399f790b7d7c14da4b6c42f0944704db5972083c3897abbcbc47"
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
