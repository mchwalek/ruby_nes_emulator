require 'test_helper'
require 'ruby_nes_emulator/rom_reader/chr_rom_reader'

describe RubyNesEmulator::RomReader::ChrRomReader do
  subject do
    RubyNesEmulator::RomReader::ChrRomReader.new
  end

  describe '#read' do
    describe 'sunny day' do

      let :chr_rom_bytes do
        "\xE7\x00\x00\x00\x18\x24\x42\x81\xFF\x18\x18\x18\x00\x00\x00\x00" \
        "\xC3\xC3\xC3\xC3\xC3\xC3\xC3\xC3\x03\x23\x33\x1B\x0F\x07\x03\x03"
      end

      let :result do
        {
          tile_definitions: [
            [
              [3, 3, 3, 2, 2, 3, 3, 3],
              [0, 0, 0, 2, 2, 0, 0, 0],
              [0, 0, 0, 2, 2, 0, 0, 0],
              [0, 0, 0, 2, 2, 0, 0, 0],
              [0, 0, 0, 1, 1, 0, 0, 0],
              [0, 0, 1, 0, 0, 1, 0, 0],
              [0, 1, 0, 0, 0, 0, 1, 0],
              [1, 0, 0, 0, 0, 0, 0, 1]
            ],
            [
              [1, 1, 0, 0, 0, 0, 3, 3],
              [1, 1, 2, 0, 0, 0, 3, 3],
              [1, 1, 2, 2, 0, 0, 3, 3],
              [1, 1, 0, 2, 2, 0, 3, 3],
              [1, 1, 0, 0, 2, 2, 3, 3],
              [1, 1, 0, 0, 0, 2, 3, 3],
              [1, 1, 0, 0, 0, 0, 3, 3],
              [1, 1, 0, 0, 0, 0, 3, 3]
            ]
          ]
        }
      end

      it 'returns tile definitions' do
        _(subject.read(chr_rom_bytes)).must_equal(result)
      end
    end

    describe 'chr rom size is not divisible by 16 bytes' do
      let :chr_rom_bytes do
        "\x00" * 17
      end

      it 'raises an exception' do
        -> { subject.read(chr_rom_bytes) }.must_raise(ArgumentError, 'CHR ROM size is not multiple of tile definition size (16 bytes)')
      end
    end
  end
end
