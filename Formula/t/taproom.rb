class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "85ee7660bb76ed9277573d2c856bcfebd3181b919edf3862e7f9e15d32097088"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/taproom-0.6.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b2c2c7c354f124ee184bf4a7edd10bef48963210c5a37d49e25e819d9322ad95"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "dd65178eda44852b0ec365fc2dba59b8bbdf50bdc903a80bbc833ba988b1e297"
    sha256 cellar: :any_skip_relocation, sequoia:       "2a835bf7bb91faea8fbdd3669329ff1b0c651ee861fa812f452e6a93add72732"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7b5f7e63dcd8e65ddc107bdcd6389116127e3021d77b27575d4a510a96720766"
    sha256 cellar: :any,                 x86_64_linux:  "1dd206e6ff867d318df427bb12115dfee5b0a3650bb7db6ec0de13406258eef6"
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
