class Poom3d < Formula
  desc "Plays your Mac's audio from a stage in a measured concert hall"
  homepage "https://github.com/AshtonYoon/poom-3d"
  url "https://github.com/AshtonYoon/poom-3d/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "47c91b1aa1dd41472a3841c30e26a0a3da6e50fc44536c03188f65e2a4924cc3"
  # The code is MIT; the binary embeds the MAIR impulse responses (CC-BY-4.0)
  # and the SADIE II head-related impulse responses (Apache-2.0)
  license all_of: ["MIT", "CC-BY-4.0", "Apache-2.0"]
  head "https://github.com/AshtonYoon/poom-3d.git", branch: "main"

  depends_on "rust" => :build
  depends_on macos: :sonoma

  def install
    system "cargo", "install", *std_cargo_args(root: libexec)

    # macOS only asks for the System Audio Recording and Motion permissions
    # when the binary runs from a bundle whose Info.plist says what for
    app = prefix/"Poom3D.app"
    (app/"Contents/MacOS").install libexec/"bin/poom3d"
    (app/"Contents").install "bundle/Info.plist"
    system "codesign", "--force", "--sign", "-", app

    (bin/"poom3d").write <<~SH
      #!/bin/sh
      exec open "#{opt_prefix}/Poom3D.app" --args "$@"
    SH
  end

  def caveats
    <<~EOS
      Start Poom3D with:
        poom3d
      It lives in the menu bar; quit it from its menu.

      The first time, and again after every upgrade, macOS asks to let Poom3D
      record system audio. Choose Allow: without it there is no sound.

      With AirPods, turn their Spatial Audio off in Control Center.
    EOS
  end

  test do
    binary = prefix/"Poom3D.app/Contents/MacOS/poom3d"
    assert_match "usage: poom3d", shell_output("#{binary} --no-such-option 2>&1", 1)
  end
end
