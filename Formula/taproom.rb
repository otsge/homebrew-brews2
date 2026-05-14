class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "e4fc7e960fbb9bdca6f255f19e5edf8aa8be78925a8e36ab7b1344a7bb3dd505"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

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
