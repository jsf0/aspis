# frozen_string_literal: true

require 'rbnacl'
require 'json'
require 'base64'

module SymmetricDecrypt
  def self.decrypt(input, ask_pass)
    input = JSON.parse(input)

    salt = input['salt']
    salt = Base64.decode64(salt)

    ops = input['ops']
    mem = input['mem']
    key_size = input['key_size']

    ciphertext = input['ciphertext']
    ciphertext = Base64.decode64(ciphertext)

    password = if ask_pass == false
                 ENV['ASPIS_PASS']
               else
                 IO.console.getpass 'Enter passphrase: '
               end

    key = RbNaCl::PasswordHash.argon2i(
      password,
      salt,
      ops,
      mem,
      key_size
    )

    box = RbNaCl::SimpleBox.from_secret_key(key)
    box.decrypt(ciphertext)
  end
end
