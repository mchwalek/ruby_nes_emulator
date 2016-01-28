require 'test_helper'
require 'rom_reader/header_reader'

describe RubyNesEmulator::RomReader::HeaderReader do
  describe '#read' do
    let :flags_bytes_reader do
      Minitest::Mock.new
    end

    let :first_flag_byte do
      3
    end

    let :second_flag_byte do
      4
    end

    let :prg_ram_byte do
      "\x02"
    end

    let :header_bytes do
      "\x4E\x45\x53\x1A\x02\x01\x03\x04#{prg_ram_byte}"
    end

    before do
      flags_bytes_reader.expect(:read_flags, { flag1a: true, flag1b: false, flag2: true }, [first_flag_byte, second_flag_byte])
      flags_bytes_reader.expect(:read_mirroring, :test_mirroring, [first_flag_byte])
      flags_bytes_reader.expect(:read_mapper_number, 1234, [first_flag_byte, second_flag_byte])
    end

    subject do
      RubyNesEmulator::RomReader::HeaderReader.new(
        flags_bytes_reader: flags_bytes_reader
      )
    end

    let :expected_metadata do
      {
        prg_rom_size: 32768,
        chr_rom_size: 8192,
        prg_ram_size: 16384,
        flag1a: true,
        flag1b: false,
        flag2: true,
        mirroring: :test_mirroring,
        mapper_number: 1234
      }
    end

    describe 'sunny day' do
      it 'reads metadata from header bytes' do
        _(subject.read(header_bytes)).must_equal(expected_metadata)
        flags_bytes_reader.verify
      end
    end

    describe 'prg ram size byte is zero' do
      let :prg_ram_byte do
      "\x00"
    end

      it 'assumes 8 kbs as prg ram size' do
        _(subject.read(header_bytes)).must_equal(expected_metadata.merge(prg_ram_size: 8192))
        flags_bytes_reader.verify
      end
    end

    describe 'magic number not found' do
      let :header_bytes do
        "\x00\x00\x00\x00"
      end

      it 'raises an exception' do
        -> { subject.read(header_bytes) }.must_raise(ArgumentError, 'Invalid rom file')
      end
    end
  end
end
