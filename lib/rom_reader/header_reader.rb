require 'active_support/core_ext/numeric/bytes'

class RubyNesEmulator::RomReader::HeaderReader
  NES_MAGIC_NUMBER = "\x4E\x45\x53\x1A"
  MAGIC_NUMBER_INDICES = 0..3
  PRG_ROM_SIZE_INDEX = 4
  CHR_ROM_SIZE_INDEX = 5
  PRG_RAM_SIZE_INDEX = 8
  FIRST_FLAG_BYTE_INDEX = 6
  SECOND_FLAG_BYTE_INDEX = 7

  def initialize(deps)
    @flags_bytes_reader = deps.fetch(:flags_bytes_reader)
  end

  def read(header_bytes)
    magic_number = header_bytes[MAGIC_NUMBER_INDICES]
    raise ArgumentError, 'Invalid rom file' if magic_number != NES_MAGIC_NUMBER

    prg_rom_size = get_byte(header_bytes, PRG_ROM_SIZE_INDEX) * 16.kilobytes
    chr_rom_size = get_byte(header_bytes, CHR_ROM_SIZE_INDEX) * 8.kilobytes

    prg_ram_byte = get_byte(header_bytes, PRG_RAM_SIZE_INDEX)
    prg_ram_byte = 1 if prg_ram_byte == 0
    prg_ram_size = prg_ram_byte * 8.kilobytes

    first_flag_byte = get_byte(header_bytes, FIRST_FLAG_BYTE_INDEX)
    second_flag_byte = get_byte(header_bytes, SECOND_FLAG_BYTE_INDEX)

    flags = @flags_bytes_reader.read_flags(first_flag_byte, second_flag_byte)

    {
      prg_rom_size: prg_rom_size,
      chr_rom_size: chr_rom_size,
      prg_ram_size: prg_ram_size,
      mirroring: @flags_bytes_reader.read_mirroring(first_flag_byte),
      mapper_number: @flags_bytes_reader.read_mapper_number(first_flag_byte, second_flag_byte)
    }.merge(flags)
  end

  def get_byte(byte_string, index)
    byte_string[index].unpack('C').first
  end
end
