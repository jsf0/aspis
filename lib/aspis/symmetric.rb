# frozen_string_literal: true

require 'rbnacl'
require 'json'
require 'base64'
require 'io/console'

module Symmetric
  def self.timingsafe_compare(secret1, secret2)
    check = secret1.bytesize ^ secret2.bytesize
    secret1.bytes.zip(secret2.bytes) { |x, y| check |= x ^ y.to_i }
    check.zero?
  end

  def self.kdf_gen(salt, opslimit, memlimit, ask_pass)
    if ask_pass == false
      password = ENV['ASPIS_PASS']
    else
      password = IO.console.getpass('Enter passphrase: ')
      password2 = IO.console.getpass('Confirm passphrase: ')
      unless timingsafe_compare(password, password2)
        abort('Passphrases do not match')
      end
    end

    RbNaCl::PasswordHash.argon2i(
      password,
      salt,
      opslimit,
      memlimit,
      32
    )
  end

  def self.encrypt(plaintext, opslimit, memlimit, ask_pass)
    opslimit ||= 10
    abort('Error: KDF opslimit must be >= 3') if opslimit < 3

    memlimit ||= 1024
    abort('Error: KDF memory must be >= 64 MiB') if memlimit < 64
    memlimit = 1_048_576 * memlimit

    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::Argon2::SALTBYTES)

    key = kdf_gen(salt, opslimit, memlimit, ask_pass)

    box = RbNaCl::SimpleBox.from_secret_key(key)
    ciphertext = box.encrypt(plaintext)

    ciphertext = Base64.strict_encode64(ciphertext)
    salt = Base64.strict_encode64(salt)

    output = { version: Aspis::VERSION,
               salt: salt,
               ops: opslimit,
               mem: memlimit,
               key_size: 32,
               ciphertext: ciphertext }

    JSON.generate(output)
  end

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
