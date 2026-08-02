class KeepassxcSshAgent < Formula
  include Language::Python::Virtualenv

  desc "SSH IdentityAgent proxy that triggers KeePassXC database unlock via TouchID"
  homepage "https://github.com/mietzen/keepassxc-ssh-agent"
  url "https://files.pythonhosted.org/packages/7d/e3/ec5966a7165f619e063b37d26a8c55d4c0bf5a2632c081d16005b9c8c6c7/keepassxc_ssh_agent-1.6.0.tar.gz"
  sha256 "aa9f6bcbf9a863faf59e445fd213900933697c5a3eedffc98fc10faf092bb28a"
  license "MIT"

  depends_on "libsodium"
  depends_on :macos
  depends_on "python@3.13"

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/57/5f/ff100cae70ebe9d8df1c01a00e510e45d9adb5c1fdda84791b199141de97/cffi-2.1.0.tar.gz"
    sha256 "efc1cdd798b1aaf39b4610bba7aad28c9bea9b910f25c784ccf9ec1fa719d1f9"
  end

  resource "keepassxc-browser-api" do
    url "https://files.pythonhosted.org/packages/3b/ab/3831d535e693757ba3136921df980f4afc45b2e714b7203fdf22e36098ec/keepassxc_browser_api-1.5.0.tar.gz"
    sha256 "1e429818c0aa0ab2a99203eaa625815974894cc24d6ad259330adcfe71abeda0"
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
