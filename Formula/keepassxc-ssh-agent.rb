class KeepassxcSshAgent < Formula
  include Language::Python::Virtualenv

  desc "SSH IdentityAgent proxy that triggers KeePassXC database unlock via TouchID"
  homepage "https://github.com/mietzen/keepassxc-ssh-agent"
  url "https://files.pythonhosted.org/packages/b2/62/22579364d06012f48f3b32f854b3318f79fe602436dc69276699faff1291/keepassxc_ssh_agent-1.1.1.tar.gz"
  sha256 "a91ff1f61fb05a7a29e7d9712dfd410017837804e67d3551876ea569b6ef43a1"
  license "MIT"

  depends_on "libsodium"
  depends_on :macos
  depends_on "python@3.13"

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/eb/56/b1ba7935a17738ae8453301356628e8147c79dbb825bcbc73dc7401f9846/cffi-2.0.0.tar.gz"
    sha256 "44d1b5909021139fe36001ae048dbdde8214afa20200eda0f64c068cac5d5529"
  end

  resource "keepassxc-browser-api" do
    url "https://files.pythonhosted.org/packages/68/e2/f33b379e9759600d13114792c6945d1b204eb48deb9f6dc9d6d90aa05793/keepassxc_browser_api-0.1.1.tar.gz"
    sha256 "05df7a5a300b4c66a1dbac3a4953b467458c30406744f4f82ea0a331518bf6c0"
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
