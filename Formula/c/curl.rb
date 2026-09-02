class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  # Don't forget to update both instances of the version in the GitHub mirror URL.
  url "https://curl.se/download/curl-8.22.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_22_0/curl-8.22.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.22.0.tar.bz2"
  sha256 "5d956a6a22b3c279f50c421ee5d3c9e9d660cb6f115dcf881b579e952130549c"
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/curl-8.22.0"
    sha256 cellar: :any, arm64_tahoe:   "5147bf21ff6993af5cad189c6ed5e25580f0684d54f0cdd2fa3fa27425c0a566"
    sha256 cellar: :any, arm64_sequoia: "9ff3dff80d490c4198c36189fca9afc6137f3add8a50bceb123b0913ed21c430"
    sha256 cellar: :any, sequoia:       "ceb16eac235d032e2ca0a71dd112ae33f8ea387c08af441a414c32daddca8c19"
    sha256 cellar: :any, arm64_linux:   "5b88e5f61874172825e8dc814cf4f5b426902c995138b62ced580fee24f55523"
    sha256 cellar: :any, x86_64_linux:  "574021dacaf25b5764f236b45c306a4c17a5d86d396c63d79efe3baba3caebe0"
  end

  head do
    url "https://github.com/curl/curl.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  depends_on "pkgconf" => [:build, :test]
  depends_on "brotli"
  depends_on "c-ares"
  depends_on "libnghttp2"
  depends_on "libnghttp3"
  depends_on "otsge/brews2/libngtcp2"
  depends_on "otsge/brews2/libssh2"
  depends_on "otsge/brews2/openssl@4"
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "openldap"

  on_system :linux, macos: :monterey_or_older do
    depends_on "libidn2"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    tag_name = "curl-#{version.to_s.tr(".", "_")}"
    if build.stable? && stable.mirrors.grep(%r{\Ahttps?://(www\.)?github\.com/}).first.exclude?(tag_name)
      odie "Tag name #{tag_name} is not found in the GitHub mirror URL! " \
           "Please make sure the URL is correct."
    end

    # Use our `curl` formula with `wcurl`
    inreplace "scripts/wcurl", 'CMD="curl "', "CMD=\"#{opt_bin}/curl \""

    system "autoreconf", "--force", "--install", "--verbose" if build.head?

    args = %W[
      --disable-silent-rules
      --with-openssl=#{formula_opt_prefix("openssl@4")}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-default-ssl-backend=openssl
      --with-libssh2
      --with-nghttp3
      --with-ngtcp2
      --without-libpsl
      --with-zsh-functions-dir=#{zsh_completion}
      --with-fish-functions-dir=#{fish_completion}
      --enable-ares
      --enable-ech
      --enable-httpsrr
      --enable-threaded-resolver
    ]

    args += if OS.mac?
      %w[
        --with-apple-sectrust
        --with-gssapi
      ]
    else
      ["--with-gssapi=#{formula_opt_prefix("krb5")}"]
    end

    args += if OS.mac? && MacOS.version >= :ventura
      %w[
        --with-apple-idn
        --without-libidn2
      ]
    else
      %w[
        --without-apple-idn
        --with-libidn2
      ]
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = testpath/"test.tar.gz"
    system bin/"curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    # Verify QUIC and HTTP3 support
    system bin/"curl", "--verbose", "--http3-only", "--head", "https://cloudflare-quic.com"

    # Check dependencies linked correctly
    curl_features = shell_output("#{bin}/curl-config --features").split("\n")
    %w[brotli ECH GSS-API HTTP2 HTTP3 HTTPSRR IDN libz SSL zstd].each do |feature|
      assert_includes curl_features, feature
    end
    curl_protocols = shell_output("#{bin}/curl-config --protocols").split("\n")
    %w[LDAPS SCP SFTP].each do |protocol|
      assert_includes curl_protocols, protocol
    end

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_path_exists testpath/"test.pem"
    assert_path_exists testpath/"certdata.txt"

    # ENV["PKG_CONFIG_PATH"] = lib/"pkgconfig"
    # ENV.append_path "PKG_CONFIG_PATH", Formula["zlib-ng-compat"].lib/"pkgconfig" unless OS.mac?
    # system "pkgconf", "--cflags", "libcurl"
  end
end
