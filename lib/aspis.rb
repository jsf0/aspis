# frozen_string_literal: true

require 'aspis/version'
require 'aspis/asymmetric_encrypt'
require 'aspis/asymmetric_decrypt'
require 'aspis/symmetric_encrypt'
require 'aspis/symmetric_decrypt'
require 'aspis/generate_keys'
require 'aspis/aspis_init'

aspis_init if __FILE__ == $PROGRAM_NAME
