class Fatrat < Formula
  desc "Download manager with BitTorrent, HTTP(S), FTP, a web UI and Python extensions"
  homepage "https://github.com/LubosD/fatrat"
  license "GPL-3.0-only"
  head "https://github.com/LubosD/fatrat.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "node" => :build
  depends_on "pkgconf" => :build
  depends_on "pybind11" => :build
  depends_on "boost"
  depends_on "curl"
  depends_on "libtorrent-rasterbar"
  depends_on "openssl@4"
  depends_on "python@3.15"
  depends_on "qt"

  def python3
    formula_opt_bin("python@3.15")/"python3.15"
  end

  def install
    ENV["NG_CLI_ANALYTICS"] = "false"

    args = %W[
      -DWITH_GUI=ON
      -DWITH_DBUS=OFF
      -DWITH_BITTORRENT=ON
      -DWITH_CURL=ON
      -DWITH_NLS=ON
      -DWITH_WEBINTERFACE=ON
      -DWITH_PYPLUGINS=ON
      -DPython3_EXECUTABLE=#{python3}
      -DOPENSSL_ROOT_DIR=#{formula_opt_prefix("openssl@4")}
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    ENV["QT_QPA_PLATFORM"] = "offscreen"
    assert_match "FatRat download manager", shell_output("#{bin}/fatrat --help")
  end
end
