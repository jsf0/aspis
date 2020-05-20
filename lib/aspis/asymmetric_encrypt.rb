# frozen_string_literal: true

require 'rbnacl'
require 'fileutils'
require 'base64'
require 'json'

require_relative 'symmetric_decrypt.rb'
require_relative 'version.rb'

module AsymmetricEncrypt
  def self.encrypt(plaintext, public_key, private_key, ask_pass)
    recipient_public_key = File.read(public_key)
    recipient_public_key = Base64.decode64(recipient_public_key)

    sender_private_key = File.read(private_key)
    sender_private_key = SymmetricDecrypt.decrypt(sender_private_key, ask_pass)

    box = RbNaCl::SimpleBox.from_keypair(recipient_public_key, sender_private_key)
    ciphertext = box.encrypt(plaintext)
    ciphertext = Base64.strict_encode64(ciphertext)

    output = { version: Aspis::VERSION,
               ciphertext: ciphertext }
    JSON.generate(output)
  end
end
