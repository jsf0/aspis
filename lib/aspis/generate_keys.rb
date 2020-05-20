# frozen_string_literal: true

require 'rbnacl'
require 'fileutils'
require 'base64'

require_relative 'symmetric_encrypt.rb'

module GenerateKeys
  def self.generate(opslimit, memlimit, ask_pass)
    aspis_dir = File.expand_path('~/.aspis')
    FileUtils.mkdir_p(aspis_dir) unless Dir.exist?(aspis_dir)

    private_key = RbNaCl::PrivateKey.generate
    public_key = private_key.public_key
    public_key = Base64.strict_encode64(public_key)

    # Encrypt private key before writing to disk
    private_key = SymmetricEncrypt.encrypt(private_key, opslimit, memlimit, ask_pass)

    File.write(aspis_dir + '/private_key', private_key)
    File.write(aspis_dir + '/public_key', public_key)
    puts('Keys created in ~/.aspis')
  end
end
