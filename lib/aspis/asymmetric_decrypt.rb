# frozen_string_literal: true

require 'rbnacl'
require 'fileutils'
require 'base64'
require 'json'

require_relative 'symmetric_decrypt.rb'

module AsymmetricDecrypt
  def self.decrypt(input, public_key, private_key, ask_pass)
    sender_public_key = File.read(public_key)
    sender_public_key = Base64.decode64(sender_public_key)

    recipient_private_key = File.read(private_key)
    recipient_private_key = SymmetricDecrypt.decrypt(recipient_private_key, ask_pass)

    box = RbNaCl::SimpleBox.from_keypair(sender_public_key, recipient_private_key)

    input = JSON.parse(input)
    ciphertext = input['ciphertext']
    ciphertext = Base64.decode64(ciphertext)
    box.decrypt(ciphertext)
  end
end
