class KeepassxcSshAgent < Formula
  include Language::Python::Virtualenv

  desc "SSH IdentityAgent proxy that triggers KeePassXC database unlock via TouchID"
  homepage "https://github.com/mietzen/keepassxc-ssh-agent"
  url "https://files.pythonhosted.org/packages/placeholder/keepassxc_ssh_agent-0.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on "libsodium"
  depends_on :macos
  depends_on "python@3.13"

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/placeholder/cffi-0.0.0.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/placeholder/pycparser-0.0.0.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  resource "pynacl" do
    url "https://files.pythonhosted.org/packages/placeholder/pynacl-0.0.0.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
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
