require 'test_helper'
require 'ruby_nes_emulator/rom_reader'

describe RubyNesEmulator::RomReader do
  let :file_path do
    File.expand_path('../../../examples/dummy_rom.nes', __FILE__)
  end

  let :file_bytes do
    File.read(file_path, mode: 'rb')
  end

  let :header_bytes_indices do
    0..15
  end

  let :header_reader do
    Minitest::Mock.new
  end

  let :header_reader_result do
    {
      trainer_present: trainer_present,
      prg_rom_size: 3,
      chr_rom_size: 2,
      header_data1: 'header_val1',
      header_data2: 'header_val2'
    }
  end

  let :trainer_bytes_indices do
    16..527
  end

  let :trainer_reader do
    Minitest::Mock.new
  end

  let :trainer_reader_result do
    {
      trainer_reader_data: 'trainer_reader_val',
    }
  end

  let :prg_rom_bytes_indices do
    528..530
  end

  let :chr_rom_bytes_indices do
    531..532
  end

  let :chr_rom_reader do
    Minitest::Mock.new
  end

  let :chr_rom_reader_result do
    {
      chr_rom_reader_data: 'chr_rom_reader_val',
    }
  end

  let :rom_reader_result do
    {
      trainer_present: trainer_present,
      prg_rom_size: 3,
      chr_rom_size: 2,
      header_data1: 'header_val1',
      header_data2: 'header_val2',
      trainer_reader_data: 'trainer_reader_val',
      prg_rom_bytestring: file_bytes[prg_rom_bytes_indices],
      chr_rom_reader_data: 'chr_rom_reader_val'
    }
  end

  subject do
    RubyNesEmulator::RomReader.new(
      header_reader: header_reader,
      trainer_reader: trainer_reader,
      chr_rom_reader: chr_rom_reader
    )
  end

    describe '#read' do
      describe 'trainer present' do
        let :trainer_present do
          true
        end

        it 'reads data from rom file, including trainer data' do
          header_reader.expect(:read, header_reader_result, [file_bytes[header_bytes_indices]])
          trainer_reader.expect(:read, trainer_reader_result, [file_bytes[trainer_bytes_indices]])
          chr_rom_reader.expect(:read, chr_rom_reader_result, [file_bytes[chr_rom_bytes_indices]])

          _(subject.read(file_path)).must_equal(rom_reader_result)

          header_reader.verify
          trainer_reader.verify
          chr_rom_reader.verify
        end

      describe 'trainer not present' do
        let :trainer_present do
          false
        end

        let :prg_rom_bytes_indices do
          16..18
        end

        let :chr_rom_bytes_indices do
          19..20
        end

        let :rom_reader_result do
          {
            trainer_present: trainer_present,
            prg_rom_size: 3,
            chr_rom_size: 2,
            header_data1: 'header_val1',
            header_data2: 'header_val2',
            prg_rom_bytestring: file_bytes[prg_rom_bytes_indices],
            chr_rom_reader_data: 'chr_rom_reader_val'
          }
        end

        it 'reads data from rom file, excluding trainer data' do
          header_reader.expect(:read, header_reader_result, [file_bytes[header_bytes_indices]])
          chr_rom_reader.expect(:read, chr_rom_reader_result, [file_bytes[chr_rom_bytes_indices]])

          subject.read(file_path)

          header_reader.verify
          chr_rom_reader.verify
        end
      end
    end
  end
end
