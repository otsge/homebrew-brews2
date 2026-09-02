class CurlQuiche < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server with HTTP/3 support using quiche"
  homepage "https://curl.se"
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
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/curl-quiche-8.21.0"
    sha256 cellar: :any, arm64_tahoe:   "549e0ade6254b3ae65e0015d2b91cd9ef228be5ef769e43812b495c222562431"
    sha256 cellar: :any, arm64_sequoia: "f32b8db396e9a1edfa2921222e38761bc9ae0d3ac0dff654390ea2af88f5e77a"
    sha256 cellar: :any, sequoia:       "9c583721e2038901ad838ae9116689aa0499daf44038f31f77429340fd5cf37f"
    sha256 cellar: :any, arm64_linux:   "c52fd8943f02d370a7329ea620fbfed516dd123ebf779228a277b51c9019ef26"
    sha256 cellar: :any, x86_64_linux:  "e51f6c113e376a222e83ee05d5eb6cbddea85e10ef9790f5c0b935771f1a651e"
  end

  head do
    url "https://github.com/curl/curl.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build

    resource "quiche" do
      url "https://github.com/cloudflare/quiche.git", branch: "master"
    end
  end

  keg_only "it conflicts with curl"

  depends_on "cmake" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "rust" => :build
  depends_on "brotli"
  depends_on "libnghttp2"
  depends_on "otsge/brews2/libssh2"
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "openldap"

  on_system :linux, macos: :monterey_or_older do
    depends_on "libidn2"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  conflicts_with "curl", because: "both install `curl` binaries"

  resource "quiche" do
    url "https://github.com/cloudflare/quiche.git",
    tag:      "0.28.0",
    revision: "a9cb314563a5c13791bd7e5a1e32821e53114e75"
    # mirror "http://www.surge.box.ca/files/quiche-0.28.0.tar.bz2"
    # sha256 "50b17243afaa87367e19d916832274d92da68585d7f8b43a0cb6b78e044358e5"
  end

  def install
    tag_name = "curl-#{version.to_s.tr(".", "_")}"
    if build.stable? && stable.mirrors.grep(%r{\Ahttps?://(www\.)?github\.com/}).first.exclude?(tag_name)
      odie "Tag name #{tag_name} is not found in the GitHub mirror URL! " \
           "Please make sure the URL is correct."
    end

    # Use our `curl` formula with `wcurl`
    inreplace "scripts/wcurl", 'CMD="curl "', "CMD=\"#{opt_bin}/curl \""

    # Build with quiche:
    #  https://github.com/curl/curl/blob/master/docs/HTTP3.md#quiche-version
    quiche = buildpath/"quiche/quiche"
    # boring = buildpath/"quiche/quiche/deps/boringssl"
    # quiche_pc_path = buildpath/"quiche/target/release/quiche.pc"
    resource("quiche").stage quiche.parent
    cd "quiche" do
      # ENV["CARGO_C_LIBDIR"] = lib.to_s
      # ln_sf boring/"src", buildpath/"boringssl"

      # Build static libs only
      inreplace quiche/"Cargo.toml", /^crate-type = .*/, "crate-type = [\"staticlib\"]"
      inreplace quiche/"Cargo.toml", /^cmake = "0.1"/, "cmake = \"0.1.45\""
      inreplace "./Cargo.toml", /^debug = true/, "debug = false"

      system "cargo", "build", "--lib", "--package", "quiche", "--features", "ffi,pkg-config-meta,qlog", "--release"
      (quiche/"deps/boringssl/src/lib").install Pathname.glob("target/release/build/*/out/build/lib{crypto,ssl}.a")
      # (buildpath/"boringssl/lib").install Pathname.glob("target/release/build/*/out/build/lib{crypto,ssl}.a")
      # lib.install quiche.parent/"target/release/libquiche.a"
      # include.install quiche/"include/quiche.h"
      # inreplace quiche_pc_path do |s|
      #   s.gsub!(/includedir=.+/, "includedir=#{include}")
      #   s.gsub!(/libdir=.+/, "libdir=#{lib}")
      # end
      # (lib/"pkgconfig").install quiche_pc_path
    end

    system "autoreconf", "--force", "--install", "--verbose" if build.head?

    args = %W[
      --disable-silent-rules
      --with-openssl=#{quiche}/deps/boringssl/src
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-default-ssl-backend=openssl
      --with-libssh2
      --with-quiche=#{quiche.parent}/target/release
      --without-libpsl
      --with-zsh-functions-dir=#{zsh_completion}
      --with-fish-functions-dir=#{fish_completion}
      --enable-ech
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

    # system "./configure", "LDFLAGS=#{ENV.ldflags}", *args, *std_configure_args
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
    %w[brotli GSS-API HTTP2 HTTP3 IDN libz SSL zstd].each do |feature|
      assert_includes curl_features, feature
    end
    curl_protocols = shell_output("#{bin}/curl-config --protocols").split("\n")
    %w[LDAPS SCP SFTP].each do |protocol|
      assert_includes curl_protocols, protocol
    end

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_path_exists testpath/"test.pem"
    assert_path_exists testpath/"certdata.txt"
  end
end
