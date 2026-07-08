class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTerminal/"
  url "https://github.com/MisterTea/EternalTerminal/archive/refs/tags/et-v7.0.0.tar.gz"
  sha256 "3580962861589c0b69efd6b385ff92ad8fdf688c91d1a0edc1a83278205e28e8"
  license "Apache-2.0"
  head "https://github.com/MisterTea/EternalTerminal.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/et-7.0.0"
    sha256 cellar: :any, arm64_tahoe:   "c2ccb2d291a6b2216e31c7848bd5445abfd63dcd4d8ad9bd0384626faa1bf331"
    sha256 cellar: :any, arm64_sequoia: "e62d6c4424a601bdb96a4b16839f518ac5531513455aac47cf66437513b7b5d8"
    sha256 cellar: :any, sequoia:       "0d25cf25d830042a486d63185eb674b5a61c7b1cc1d9eeba833dc918a4dcd46d"
    sha256 cellar: :any, arm64_linux:   "3bed9905999a40bb2b89dde295598f23d314aada885e99c5f3380b1a816c2576"
    sha256 cellar: :any, x86_64_linux:  "b62f8b44ba432530a07c1a4c3060a33731c74eb81bae8d94481510f0c0a1e8b1"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "libsodium"
  depends_on "otsge/brews2/openssl@4"
  depends_on "protobuf"

  on_linux do
    depends_on "brotli"
    depends_on "zlib-ng-compat"
  end

  def install
    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"
    # Avoid over-linkage to `abseil`.
    ENV.append "LDFLAGS", "-Wl,-dead_strip_dylibs" if OS.mac?

    args = %W[
      -DDISABLE_VCPKG=ON
      -DDISABLE_SENTRY=ON
      -DDISABLE_TELEMETRY=ON
      -DBUILD_TESTING=OFF
      -DBASH_COMPLETION_COMPLETIONSDIR=#{bash_completion}
      -DOPENSSL_ROOT_DIR=#{formula_opt_prefix("openssl@4")}
      -DPYTHON_EXECUTABLE=#{which("python3")}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    etc.install "etc/et.cfg"
  end

  service do
    run [opt_bin/"etserver", "--cfgfile", etc/"et.cfg"]
    keep_alive false
    working_dir HOMEBREW_PREFIX
    error_log_path "/tmp/etserver.err"
    log_path "/tmp/etserver.log"
    require_root true
  end

  test do
    port = free_port
    pid = fork do
      exec bin/"etserver", "--port", port.to_s, "--logtostdout"
    end

    begin
      require "socket"
      Timeout.timeout(60) do
        loop do
          TCPSocket.open("127.0.0.1", port).close
          break
        rescue Errno::ECONNREFUSED
          sleep 1
        end
      end
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
