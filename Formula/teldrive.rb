class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.8.3",
        revision: "d400a2df41db17ba220cd06973fc8df5c6f2854c"
  license "MIT"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/teldrive-1.8.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "3ed4bce94905dd76e11fdc1dd63e32a530caf57ab8f3e1f0a181bc2882cec808"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0f5c1bf02232bc84c011f5f11da8f5ef1d6e1aebeb4b48200a892a3103f3e7df"
    sha256 cellar: :any_skip_relocation, tahoe:         "4d9488a2718ad6c04eed6829248ceab328216d84597f132cd62ae02a68409df7"
    sha256 cellar: :any_skip_relocation, sequoia:       "4e88738f48151d4ab67beaf9c17beb60c41c750cb0e9224d79292cac9f75733f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "e84dd488910ce777b1558249a0e5127e70996f17108aa86b62614458a178f0a6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ceb3f7811cc0e291de958782e0a0de6dd76d8895d09887fa5831cdba826da19f"
  end

  depends_on "go" => :build
  depends_on "go-task" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ENV["GO111MODULE"] = "on"
    ldflags = %W[
      -extldflags=-static
      -s -w
      -X github.com/tgdrive/teldrive/internal/version.Version=#{version}
      -X github.com/tgdrive/teldrive/internal/version.CommitSHA=#{Utils.git_short_head(length: 7)}
    ]
    system "task", "ui"
    system "task", "gen"
    system "go", "build", "-trimpath", *std_go_args(ldflags:)
  end

  test do
    system bin/"teldrive", "version"
  end
end
