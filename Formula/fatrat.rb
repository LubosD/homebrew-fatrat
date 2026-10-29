class Fatrat < Formula
  desc "Download manager with BitTorrent, HTTP(S), FTP, a web UI and Python extensions"
  homepage "https://github.com/LubosD/fatrat"
  license "GPL-3.0-only"
  head "https://github.com/LubosD/fatrat.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "librsvg" => :build
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

    build_app_bundle
  end

  # FatRat finds its data through the absolute DATA_LOCATION, so the binary can
  # live inside the bundle; bin/fatrat stays as a symlink for terminal use
  def build_app_bundle
    app = prefix/"FatRat.app/Contents"
    (app/"MacOS").install bin/"fatrat"
    bin.install_symlink app/"MacOS/fatrat"

    # The logo is 1141x1378, so centre it on a square transparent page
    iconset = buildpath/"fatrat.iconset"
    iconset.mkpath
    [16, 32, 128, 256, 512].each do |size|
      { "" => size, "@2x" => size * 2 }.each do |suffix, px|
        width = px * 1141 / 1378
        system "rsvg-convert", "--height=#{px}", "--width=#{width}",
               "--page-width=#{px}", "--page-height=#{px}", "--left=#{(px - width) / 2}",
               "--output=#{iconset}/icon_#{size}x#{size}#{suffix}.png", "gfx/fatrat_logo.svg"
      end
    end
    (app/"Resources").mkpath
    system "iconutil", "--convert", "icns", "--output", app/"Resources/fatrat.icns", iconset

    (app/"Info.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleDisplayName</key>
        <string>FatRat</string>
        <key>CFBundleExecutable</key>
        <string>fatrat</string>
        <key>CFBundleIconFile</key>
        <string>fatrat.icns</string>
        <key>CFBundleIdentifier</key>
        <string>info.dolezel.fatrat</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>FatRat</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>#{version}</string>
        <key>CFBundleVersion</key>
        <string>#{version}</string>
        <key>NSHighResolutionCapable</key>
        <true/>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
      </dict>
      </plist>
    XML

    # The linker's ad-hoc signature doesn't cover the bundle's Info.plist and resources
    system "codesign", "--force", "--sign", "-", prefix/"FatRat.app"
  end

  def caveats
    <<~EOS
      FatRat.app was installed to:
        #{opt_prefix}/FatRat.app

      To make it available in /Applications, symlink it:
        ln -sf #{opt_prefix}/FatRat.app /Applications/FatRat.app
    EOS
  end

  test do
    assert_path_exists prefix/"FatRat.app/Contents/Resources/fatrat.icns"
    system "plutil", "-lint", prefix/"FatRat.app/Contents/Info.plist"
    system "codesign", "--verify", "--strict", prefix/"FatRat.app"
    ENV["QT_QPA_PLATFORM"] = "offscreen"
    assert_match "FatRat download manager", shell_output("#{bin}/fatrat --help")
  end
end
