class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.2/forgejo-src-15.0.2.tar.gz"
  sha256 "c52a7df751de7426657bc06df336248e05fb663bcc9205e870557ce6a020a199"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/forgejo-15.0.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "40229f04c7a23f2927132701d39765fc9d45191ccc65a1e0eca1c0b39268a85b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "919d8c7b5340678af1e4bab623abf0c4926d6da2989f9dec9373b140b0644869"
    sha256 cellar: :any_skip_relocation, tahoe:         "dcb3441aace5425884ea2d5b4bfe1f6c1ce79d944582e5644c65f09092bb6e84"
    sha256 cellar: :any_skip_relocation, sequoia:       "38e6c343687e53ef156b7dfca92f8a20bae65b8548e088cc9f2a78ca6d3b1d2c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fa30a892fa435c2a68f3a6f41f33ab45952af0b63f1a208cded57faaa1c168ff"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "606223c55bf6f0153045216dc02cb7a79c49da8e063c4dee2f14dc104961f66d"
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
