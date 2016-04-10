require 'bundler'
Bundler.require

require 'active_support/core_ext/integer/multiple'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/object/inclusion'

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

module RubyNesEmulator
  module Cpu
  end
  class RomReader
  end
end
