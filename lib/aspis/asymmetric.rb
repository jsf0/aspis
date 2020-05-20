# frozen_string_literal: true

require 'rbnacl'
require 'fileutils'
require 'base64'
require 'json'

require_relative 'symmetric.rb'
require_relative 'version.rb'

module Asymmetric
  def self.encrypt(plaintext, public_key, private_key, ask_pass)
    recipient_public_key = File.read(public_key)
    recipient_public_key = Base64.decode64(recipient_public_key)

    sender_private_key = File.read(private_key)
    sender_private_key = Symmetric.decrypt(sender_private_key, ask_pass)

    box = RbNaCl::SimpleBox.from_keypair(recipient_public_key, sender_private_key)
    ciphertext = box.encrypt(plaintext)
    ciphertext = Base64.strict_encode64(ciphertext)

    output = { version: Aspis::VERSION,
               ciphertext: ciphertext }
    JSON.generate(output)
  end

  def self.decrypt(input, public_key, private_key, ask_pass)
    sender_public_key = File.read(public_key)
    sender_public_key = Base64.decode64(sender_public_key)

    recipient_private_key = File.read(private_key)
    recipient_private_key = Symmetric.decrypt(recipient_private_key, ask_pass)

    box = RbNaCl::SimpleBox.from_keypair(sender_public_key, recipient_private_key)

    input = JSON.parse(input)
    ciphertext = input['ciphertext']
    ciphertext = Base64.decode64(ciphertext)
    box.decrypt(ciphertext)
  end
end
