class KeepassxcSshAgent < Formula
  include Language::Python::Virtualenv

  desc "SSH IdentityAgent proxy that triggers KeePassXC database unlock via TouchID"
  homepage "https://github.com/mietzen/keepassxc-ssh-agent"
  url "https://files.pythonhosted.org/packages/b7/28/cfb014defef88dba85c5554517a2d4d84e42c0a17a9e77aca1ee866519a8/keepassxc_ssh_agent-1.3.0.tar.gz"
  sha256 "283e1575109f159cf7237154ce305c99bac68548b68750a0332a4056b8ec688e"
  license "MIT"

  depends_on "libsodium"
  depends_on :macos
  depends_on "python@3.13"

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/eb/56/b1ba7935a17738ae8453301356628e8147c79dbb825bcbc73dc7401f9846/cffi-2.0.0.tar.gz"
    sha256 "44d1b5909021139fe36001ae048dbdde8214afa20200eda0f64c068cac5d5529"
  end

  resource "keepassxc-browser-api" do
    url "https://files.pythonhosted.org/packages/6a/0f/7140a8f5c0eca859896ae50bcbf9074bbd25a58e9da4c7b9724e5f6a6281/keepassxc_browser_api-1.0.0.tar.gz"
    sha256 "9d48611a6f6c83b951c1f2e7654070cee51eab33ed5625fe285ff280ccfefb4b"
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
