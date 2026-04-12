class KeepassxcSshAgent < Formula
  include Language::Python::Virtualenv

  desc "SSH IdentityAgent proxy that triggers KeePassXC database unlock via TouchID"
  homepage "https://github.com/mietzen/keepassxc-ssh-agent"
  url "https://files.pythonhosted.org/packages/f5/64/1118da90b103471f7e98b3b934ba29b4fb7fe0e3aca22e2d196e800c8186/keepassxc_ssh_agent-1.1.2.tar.gz"
  sha256 "cbeaedfccb3fc87bc7045fdb12c596b704ae23f657bca183b904e71ad29d0b41"
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

        keepassxc-ssh-agent install --register-only

      Then start the background service:

        brew services start keepassxc-ssh-agent
    EOS
  end

  service do
    run [opt_bin/"keepassxc-ssh-agent", "run"]
    keep_alive true
    log_path var/"log/keepassxc-ssh-agent/out.log"
    error_log_path var/"log/keepassxc-ssh-agent/err.log"
  end

  test do
    assert_match "keepassxc-ssh-agent", shell_output("#{bin}/keepassxc-ssh-agent --help")
    assert_match "status", shell_output("#{bin}/keepassxc-ssh-agent --help")
  end
end
