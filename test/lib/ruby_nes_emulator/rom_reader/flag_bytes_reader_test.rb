require 'test_helper'
require 'ruby_nes_emulator/rom_reader/flag_bytes_reader'

describe RubyNesEmulator::RomReader::FlagBytesReader do
  subject do
    RubyNesEmulator::RomReader::FlagBytesReader.new
  end

  describe '#read_flags' do
    let :expected_flags do
      {
        trainer_present: true,
        persistent_memory_present: true,
        is_play_choice_10: true,
        is_vs_unisystem: true
      }
    end

    let :first_flag_byte do
      0b11111111
    end

    let :second_flag_byte do
      0b11111111
    end

    describe 'all flag bits are set' do
      it 'returns all flags set to true' do
        _(subject.read_flags(first_flag_byte, second_flag_byte)).must_equal(expected_flags)
      end
    end

    describe 'trainer present flag bit is cleared' do
       let :first_flag_byte do
      0b11111011
    end

      it 'returns trainer present flag set to false' do
        _(subject.read_flags(first_flag_byte, second_flag_byte)).must_equal(expected_flags.merge(trainer_present: false))
      end
    end

    describe 'persistent memory present flag bit is cleared' do
      let :first_flag_byte do
        0b11111101
      end

      it 'returns persistent memory present flag set to false' do
        _(subject.read_flags(first_flag_byte, second_flag_byte)).must_equal(expected_flags.merge(persistent_memory_present: false))
      end
    end

    describe 'is PlayChoice-10 flag bit is cleared' do
      let :second_flag_byte do
        0b11111101
      end

      it 'returns is PlayChoice-10 flag set to false' do
        _(subject.read_flags(first_flag_byte, second_flag_byte)).must_equal(expected_flags.merge(is_play_choice_10: false))
      end
    end

    describe 'is VS Unisystem flag bit is cleared' do
      let :second_flag_byte do
        0b11111110
      end

      it 'returns is VS Unisystem flag set to false' do
        _(subject.read_flags(first_flag_byte, second_flag_byte)).must_equal(expected_flags.merge(is_vs_unisystem: false))
      end
    end
  end

  describe '#read_mirroring' do
    describe 'no mirroring bit is set' do
      let :first_flag_byte do
        0b00001001
      end

      it 'returns :none mirroring' do
        _(subject.read_mirroring(first_flag_byte)).must_equal(:none)
      end
    end

    describe 'no mirroring bit is cleared and mirroring type bit is set' do
      let :first_flag_byte do
        0b00000001
      end

      it 'returns :vertical mirroring' do
        _(subject.read_mirroring(first_flag_byte)).must_equal(:vertical)
      end
    end

    describe 'no mirroring bit is cleared and mirroring type bit is cleared' do
      let :first_flag_byte do
        0b00000000
      end

      it 'returns :horizontal mirroring' do
        _(subject.read_mirroring(first_flag_byte)).must_equal(:horizontal)
      end
    end
  end

  describe '#read_mapper_number' do
    let :first_flag_byte do
      0b01010000
    end

    let :second_flag_byte do
      0b10100000
    end

    it 'reads mapper number using nibbles present in both flag bytes' do
      _(subject.read_mapper_number(first_flag_byte, second_flag_byte)).must_equal(0b10100101)
    end
  end
end
