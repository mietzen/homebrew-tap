class KeepassxcCli < Formula
  include Language::Python::Virtualenv

  desc "CLI for KeePassXC using the browser extension protocol with biometric unlock"
  homepage "https://github.com/mietzen/keepassxc-cli"
  url "https://files.pythonhosted.org/packages/99/76/bd8b8c5c39112baf11dfdf7c7ef05c20f5e63153f6f0eeefdbe3ed7b7e27/keepassxc_cli-0.1.2.tar.gz"
  sha256 "180e595c0459929b17342f4db8745e5dcd9b3188b51d333090daaab8ef1fc53c"
  license "MIT"

  depends_on "libsodium"
  depends_on :macos
  depends_on "python@3.13"

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/eb/56/b1ba7935a17738ae8453301356628e8147c79dbb825bcbc73dc7401f9846/cffi-2.0.0.tar.gz"
    sha256 "44d1b5909021139fe36001ae048dbdde8214afa20200eda0f64c068cac5d5529"
  end

  resource "keepassxc-browser-api" do
    url "https://files.pythonhosted.org/packages/6d/42/d375ad1b7ecbd3c9ccca6b2c4974bf897a6940fe9fcc82f1f5539692f4a3/keepassxc_browser_api-0.1.2.tar.gz"
    sha256 "d047a13fdb0c38e2c86e6c671ad6fa0821e2a4eab8c9d6eac33955bb54476553"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/1b/7d/92392ff7815c21062bea51aa7b87d45576f649f16458d78b7cf94b9ab2e6/pycparser-3.0.tar.gz"
    sha256 "600f49d217304a5902ac3c37e1281c9fe94e4d0489de643a9504c5cdfdfc6b29"
  end

  resource "pynacl" do
    url "https://files.pythonhosted.org/packages/d9/9a/4019b524b03a13438637b11538c82781a5eda427394380381af8f04f467a/pynacl-1.6.2.tar.gz"
    sha256 "018494d6d696ae03c7e656e5e74cdfd8ea1326962cc401bcf018f1ed8436811c"
  end

  resource "pyperclip" do
    url "https://files.pythonhosted.org/packages/e8/52/d87eba7cb129b81563019d1679026e7a112ef76855d6159d24754dbd2a51/pyperclip-1.11.0.tar.gz"
    sha256 "244035963e4428530d9e3a6101a1ef97209c6825edab1567beac148ccc1db1b6"
  end

  def install
    ENV["SODIUM_INSTALL"] = "system"
    virtualenv_install_with_resources
  end

  def post_uninstall
    opoo "To remove configuration files, run: rm -rf ~/.keepassxc"
  end

  def caveats
    <<~EOS
      To associate with KeePassXC (browser integration must be enabled):

        keepassxc-cli setup

      Usage:

        keepassxc-cli --help
    EOS
  end

  test do
    assert_match "keepassxc-cli", shell_output("#{bin}/keepassxc-cli --help")
    assert_match "show", shell_output("#{bin}/keepassxc-cli --help")
  end
end
