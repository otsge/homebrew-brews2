class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.25.0.tar.gz"
  sha256 "766e48423e79359ea31e41db9e5c289675947a7fcf2efdcedb726ac9d0da3784"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/otsge/homebrew-brews2/releases/download/wget-1.25.0"
    sha256 arm64_tahoe:   "987fae3c92efb5ddd747a61b209eba336b003a5353314beac5bfacd8734667a6"
    sha256 arm64_sequoia: "c997e7b5e3fa96c4cb5914127e2f45511054ebc03a79683db63239fd744761b4"
    sha256 tahoe:         "5108bb3f256fd0593b5d297dee9fdfd8b06163bd08fb58e0000d67e52214c98c"
    sha256 sequoia:       "0fd6b5db60ae3e782f416c3d744cb445caf23e200645bd3afcb8b7ed25f5a3f4"
    sha256 arm64_linux:   "af0d3d7dfc0e56d9a9155407fb5460a19ecd9f107020ca892ab9a7ea3ecd7b1d"
    sha256 x86_64_linux:  "675793326ea957bd8ca344c75d2ae368ee1c370a43138d4e3b4344eba1547336"
  end

  head do
    url "https://gitlab.com/gnuwget/wget.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "xz" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "libidn2"
  depends_on "libmetalink"
  depends_on "otsge/brews2/openssl@4"

  on_macos do
    depends_on "gettext"
    depends_on "libunistring"
  end

  on_linux do
    depends_on "util-linux"
    depends_on "zlib-ng-compat"
  end

  def install
    inreplace "src/openssl.c", "#ifndef OPENSSL_NO_SSL3_METHOD",
              "#if !defined OPENSSL_NO_SSL3_METHOD && OPENSSL_VERSION_NUMBER < 0x40000000L"

    system "./bootstrap", "--skip-po" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--with-ssl=openssl",
                          "--with-libssl-prefix=#{Formula["openssl@4"].opt_prefix}",
                          "--with-metalink",
                          "--disable-pcre",
                          "--disable-pcre2",
                          "--without-libpsl",
                          "--without-included-regex"
    system "make", "install"
  end

  test do
    system bin/"wget", "-O", File::NULL, "https://google.com"
  end
end
