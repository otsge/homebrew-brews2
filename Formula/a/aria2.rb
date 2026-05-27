class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/aria2-1.37.0"
    sha256 cellar: :any,                 arm64_tahoe:   "f31e50cf69fb8ab9f2e663147740e01062db9fb93599488dc58cec822d1a9573"
    sha256 cellar: :any,                 arm64_sequoia: "58d3d0e8d5b55fc04fce36c4b1f2ba6f5d69032216391598b4a3fb701da0cf36"
    sha256 cellar: :any,                 tahoe:         "d037eaa88598dac4cc29da157ea1fdd6401d44c149212a493341b801e24c1698"
    sha256 cellar: :any,                 sequoia:       "aa46f620c8a95c7944b6307d99d17cf7fa29ad5bad725dab9afe76af5b9a4a6c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0b1bf204cb56e6c6b09da887ac1ab4af7fa53a1dc43ea730c793bf869d9613bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6a1693ab261c4dc9e8df27609d3c695c664ffbb65de92282e1940682de8cdab4"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "c-ares"
  depends_on "otsge/brews2/libssh2"
  depends_on "otsge/brews2/openssl@4"
  depends_on "sqlite"

  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  patch :DATA

  def install
    ENV.cxx11
    ENV.append "LIBS", "-framework Security" if OS.mac?

    if build.head?
      ENV.append_to_cflags "-march=native -O3 -pipe -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %w[
      --disable-silent-rules
      --disable-nls
      --with-libssh2
      --without-gnutls
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
      --without-appletls
      --with-openssl
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system bin/"aria2c", "https://brew.sh/"
    assert_path_exists testpath/"index.html", "Failed to create index.html!"
  end
end

__END__
--- a/src/LibsslTLSSession.cc
+++ b/src/LibsslTLSSession.cc
@@ -279,17 +279,17 @@ int OpenSSLTLSSession::tlsConnect(const std::string& hostname,
           dnsNames.push_back(std::string(name, name + len));
         }
         else if (altName->type == GEN_IPADD) {
-          const unsigned char* ipAddr = altName->d.iPAddress->data;
+          auto ipAddr = ASN1_STRING_get0_data(altName->d.iPAddress);
           if (!ipAddr) {
             continue;
           }
-          size_t len = altName->d.iPAddress->length;
+          size_t len = ASN1_STRING_length(altName->d.iPAddress);
           ipAddrs.push_back(
               std::string(reinterpret_cast<const char*>(ipAddr), len));
         }
       }
     }
-    X509_NAME* subjectName = X509_get_subject_name(peerCert);
+    const X509_NAME* subjectName = X509_get_subject_name(peerCert);
     if (!subjectName) {
       handshakeErr = "could not get X509 name object from the certificate.";
       return TLS_ERR_ERROR;
@@ -301,7 +301,7 @@ int OpenSSLTLSSession::tlsConnect(const std::string& hostname,
       if (lastpos == -1) {
         break;
       }
-      X509_NAME_ENTRY* entry = X509_NAME_get_entry(subjectName, lastpos);
+      const X509_NAME_ENTRY* entry = X509_NAME_get_entry(subjectName, lastpos);
       unsigned char* out;
       int outlen = ASN1_STRING_to_UTF8(&out, X509_NAME_ENTRY_get_data(entry));
       if (outlen < 0) {
