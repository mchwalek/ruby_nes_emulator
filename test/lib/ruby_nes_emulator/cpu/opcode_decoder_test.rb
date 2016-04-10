require 'test_helper'
require 'ruby_nes_emulator/cpu/opcode_decoder'

describe RubyNesEmulator::Cpu::OpcodeDecoder do
  subject do
    RubyNesEmulator::Cpu::OpcodeDecoder.new
  end

  describe '#decode' do
    let :opcodes do
      (0..255).map { |i| [i].pack('C') }
    end

    let :expected_results do
      path = File.expand_path('../../../../examples/all_decoded_opcodes.json', __FILE__)
      JSON.load(File.read(path)).map(&:symbolize_keys)
    end

    it 'returns data for given opcode' do
      opcodes.each_with_index { |opcode, i| _(subject.decode(opcode)).must_equal(expected_results[i], "Assertion failed for opcode 0x%02X" % i) }
    end
  end
end
