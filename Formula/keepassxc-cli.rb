class KeepassxcCli < Formula
  include Language::Python::Virtualenv

  desc "CLI for KeePassXC using the browser extension protocol with biometric unlock"
  homepage "https://github.com/mietzen/keepassxc-cli"
  url "https://files.pythonhosted.org/packages/67/aa/d6309b5e0fad8ba50de58d4f935b1cec3f1d2d5c3ad0fdefc179242d6a3a/keepassxc_cli-0.2.0.tar.gz"
  sha256 "6fd6a40856692fb0c25c6a9507d46a7725ee30d64d8b9e7f009f957fd3f34011"
  license "MIT"

  depends_on "libsodium"
  depends_on :macos
  depends_on "python@3.13"

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/eb/56/b1ba7935a17738ae8453301356628e8147c79dbb825bcbc73dc7401f9846/cffi-2.0.0.tar.gz"
    sha256 "44d1b5909021139fe36001ae048dbdde8214afa20200eda0f64c068cac5d5529"
  end

  resource "keepassxc-browser-api" do
    url "https://files.pythonhosted.org/packages/46/16/9acca8341d118b73c8e758e4402b1c877de92f421ae1fa8b2625c1b036ae/keepassxc_browser_api-0.1.3.tar.gz"
    sha256 "2299067c18aee1acbb6153509c6a37f1972cf4b03f1ff745572fbab579f67633"
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
    url "https://files.pythonhosted.org/packages/f6/5b/55866e1cde0f86f5eec59dab5de8a66628cb0d53da74b8dbc15ad8dabda3/pyperclip-1.8.0.tar.gz"
    sha256 "b75b975160428d84608c26edba2dec146e7799566aea42c1fe1b32e72b6028f2"
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
