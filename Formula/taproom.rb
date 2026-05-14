class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "e4fc7e960fbb9bdca6f255f19e5edf8aa8be78925a8e36ab7b1344a7bb3dd505"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/taproom-0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "743fa4d08a232e1d687368e421ed53074d3eb28149479254a19398c3f5c47d7c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0bcd39cc5bc3d89e56e8040e2b663aaa7f861ede7f0967725daede2eacf4cbc3"
    sha256 cellar: :any_skip_relocation, tahoe:         "7a540c2f8710431701df5b57cfcdaf525ba2bafb9276956726fb994824d61ea4"
    sha256 cellar: :any_skip_relocation, sequoia:       "a71c8f1438c8214a0a1fc83c099057cf67df302a4e1f1f791861bb2942a368a2"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "418caa16f809288cd45f6215be10505dba87f43afb5d98fa56e2f34f322181b4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "bcbb57c033f7941570728b1a99777378f7b3d676ebbc192278385b99421e75db"
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
