class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol"
  homepage "https://libssh2.org/"
  url "https://libssh2.org/download/libssh2-1.11.1.tar.gz"
  mirror "https://github.com/libssh2/libssh2/releases/download/libssh2-1.11.1/libssh2-1.11.1.tar.gz"
  mirror "http://download.openpkg.org/components/cache/libssh2/libssh2-1.11.1.tar.gz"
  sha256 "d9ec76cbe34db98eec3539fe2c899d26b0c837cb3eb466a56b0f109cabf658f7"
  license "BSD-3-Clause"

  livecheck do
    url "https://libssh2.org/download/"
    regex(/href=.*?libssh2[._-]v?(\d+(?:\.\d+)+)\./i)
  end

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/libssh2-1.11.1"
    sha256 cellar: :any,                 arm64_tahoe:   "a587acb35726120038b2875134bf1763a3e594fcf8bbfbf840001c8b6e46126a"
    sha256 cellar: :any,                 arm64_sequoia: "1d8d7619151a2e621f9d91295558eddb616ffdd8e211618f7ad06560f36ca8c3"
    sha256 cellar: :any,                 tahoe:         "f46f4c02447d6cdd586320f029c49bf36eca0dd673048703c267032459bb81c8"
    sha256 cellar: :any,                 sequoia:       "0190b97cb087736f54d331f0be1bd156d0ad55cceab2db5b82dd0a55e65a3b68"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "b1357a894588c0cd0e7702622ec43e9a2a4300660ac49e94f00662dc68f8405a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4e0ef389804acfe8dc377ac8dab247de7eccf61dc0f6ffcc1cff4f96003eefca"
  end

  head do
    url "https://github.com/libssh2/libssh2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "otsge/brews2/openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    args = %W[
      --disable-silent-rules
      --disable-examples-build
      --with-openssl
      --with-libz
      --with-libssl-prefix=#{Formula["openssl@4"].opt_prefix}
    ]

    system "./buildconf" if build.head?
    system "./configure", *std_configure_args, *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libssh2.h>

      int main(void)
      {
      libssh2_exit();
      return 0;
      }
    C

    system ENV.cc, "test.c", "-L#{lib}", "-lssh2", "-o", "test"
    system "./test"
  end
end
