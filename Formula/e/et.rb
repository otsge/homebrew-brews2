class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTerminal/"
  url "https://github.com/MisterTea/EternalTerminal/archive/refs/tags/et-v7.0.0.tar.gz"
  sha256 "3580962861589c0b69efd6b385ff92ad8fdf688c91d1a0edc1a83278205e28e8"
  license "Apache-2.0"
  head "https://github.com/MisterTea/EternalTerminal.git", branch: "master"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/et-6.2.11"
    sha256 cellar: :any,                 arm64_tahoe:   "7d721c44fdc74dd2359a80fb0ab612f18f54f02f8f4345a745a3b2f2893e8e6e"
    sha256 cellar: :any,                 arm64_sequoia: "b2a26751a35d228baa5a4fe092dce36a2edeb119d615c396abdadbbb0769829c"
    sha256 cellar: :any,                 tahoe:         "526f1c7bd88c018d693eb91b618364855f63e982ff8335755f8d04e0b57e3776"
    sha256 cellar: :any,                 sequoia:       "35bcda0f2340e54e33d42f187a37670ae0d5edde5992a329b56223a60ad8537d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c0e8bb9bcc2e1173b959287408d44ad17fbfd861609a8b31f078d938a84670e8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e628e68684a7498462a7eace2baa59da693fd39cb896d66e08551a9fb05c7ff0"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

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
      -DOPENSSL_ROOT_DIR=#{Formula["openssl@4"].opt_prefix}
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
