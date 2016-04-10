class RubyNesEmulator::RomReader::ChrRomReader
  TILE_DEFINITION_SIZE = 16
  TILE_PLANE_OFFSET = 8

  def read(chr_rom_bytes)
    raise ArgumentError, "CHR ROM size is not multiple of tile definition size (#{TILE_DEFINITION_SIZE} bytes)" unless chr_rom_bytes.length.multiple_of?(TILE_DEFINITION_SIZE)

    { tile_definitions: get_tile_definitions(chr_rom_bytes) }
  end

  private

  def get_tile_definitions(chr_rom_bytes)
    [].tap do |tile_definitions|
      chr_rom_bytes.unpack('C*').each_slice(TILE_DEFINITION_SIZE) do |raw_tile_definition|
        tile_definitions << get_tile_definition(raw_tile_definition)
      end
    end
  end

  def get_tile_definition(raw_tile_definition)
    [].tap do |tile_definition|
      0.upto(7).each { |row_index| tile_definition << get_tile_row(raw_tile_definition, row_index) }
    end
  end

  def get_tile_row(raw_tile_definition, row_index)
    [].tap do |tile_row|
      first_plane_byte = raw_tile_definition[row_index]
      second_plane_byte = raw_tile_definition[row_index + TILE_PLANE_OFFSET]

      7.downto(0).each { |pixel_index| tile_row << get_pixel_color(first_plane_byte, second_plane_byte, pixel_index) }
    end
  end

  def get_pixel_color(first_plane_byte, second_plane_byte, pixel_index)
    first_plane_byte[pixel_index] | (second_plane_byte[pixel_index] << 1)
  end
end
