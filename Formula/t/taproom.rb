class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "80609d839488c34c8bf870b70430955fa600266fda16298c79a6c48c529404f0"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/taproom-0.6.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "893b6f719bb4daadaea1a4527fdd392ba43183fe4671f0f47718f74bfa35f67f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b4eaba2b2b5e1f9a4a075555cf87708e7eb32c49cf27dbec03172e770c4a3f02"
    sha256 cellar: :any_skip_relocation, tahoe:         "3048f7428a061aead97da65df8732700b85ef481ba40c73782c75afc344e82c3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0e465c878845e3e00dab2f9e165ab77d846e92c3d6a212e482c42ff95d884d28"
    sha256 cellar: :any,                 x86_64_linux:  "8734a9ce7923d7bfc4c7be9b66afa2a609498276d8ee27d664c0d02b337af3a0"
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", *std_go_args(ldflags: "-s -w")
  end

  test do
    require "pty"
    require "expect"
    require "io/console"
    timeout = 30

    PTY.spawn("#{bin}/taproom --hide-columns Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Casks", timeout), "Expected cask loading message"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
