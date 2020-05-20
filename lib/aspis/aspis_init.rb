# frozen_string_literal: true

# Copyright (c) 2020 Joseph Fierro <joseph.fierro@logosnetworks.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
require 'optparse'

require_relative 'asymmetric.rb'
require_relative 'symmetric.rb'
require_relative 'generate_keys.rb'
require_relative 'version.rb'

module AspisInit
  def self.init
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Encryption filter utility.\n"

      opts.version = Aspis::VERSION

      opts.on('-e', '--encrypt', 'Encrypt') do
        options[:mode] = 'encrypt'
      end

      opts.on('-d', '--decrypt', 'Decrypt') do
        options[:mode] = 'decrypt'
      end

      opts.on('-g', '--generate', 'Generate key pair') do
        options[:mode] = 'generate'
      end

      opts.on('-n', '--nopass', 'Use env variable ASPIS_PASS for passphrase') do
        options[:ask_pass] = false
      end

      opts.on('-p', '--pubkey public_key', String, "Recipient's public key") do |p|
        options[:public_key] = p
      end

      opts.on('-k', '--privatekey private_key', String, "Sender's private key") do |k|
        options[:private_key] = k
      end

      opts.on('-o', '--opslimit opslimit', Integer, 'Argon2i ops parameter') do |o|
        options[:opslimit] = o
      end

      opts.on('-m', '--memlimit memlimit', Integer, 'Argon2i memory in MiB') do |m|
        options[:memlimit] = m
      end

      opts.on('-h', '--help', 'Displays help') do
        puts opts
        exit
      end
    end.parse!

    abort('Fatal error: must enter -g, -e, or -d') unless options[:mode]

    run(options)
  end

  def self.run(options)
    if options[:public_key]
      unless options[:private_key]
        aspis_dir = File.expand_path('~/.aspis')
        options[:private_key] = aspis_dir + '/private_key'
      end
    end

    case options[:mode]
    when 'encrypt'
      if options[:public_key]
        puts Asymmetric.encrypt(ARGF.read, options[:public_key], options[:private_key], options[:ask_pass])
      else
        puts Symmetric.encrypt(ARGF.read, options[:opslimit], options[:memlimit], options[:ask_pass])
      end
    when 'decrypt'
      if options[:public_key]
        puts Asymmetric.decrypt(ARGF.read, options[:public_key], options[:private_key], options[:ask_pass])
      else
        puts Symmetric.decrypt(ARGF.read, options[:ask_pass])
      end
    when 'generate'
      GenerateKeys.generate(options[:opslimit], options[:memlimit], options[:ask_pass])
    end
  end
end
