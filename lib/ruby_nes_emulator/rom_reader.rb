class RubyNesEmulator::RomReader
  HEADER_SIZE = 16
  TRAINER_SIZE = 512

  def initialize(deps)
    @header_reader = deps.fetch(:header_reader)
    @trainer_reader = deps.fetch(:trainer_reader)
    @chr_rom_reader = deps.fetch(:chr_rom_reader)
  end

  def read(file_path)
    {}.tap do |rom_data|
      File.open(file_path, 'rb') do |f|
        header_data = read_rata(f, HEADER_SIZE, @header_reader)
        rom_data.merge!(header_data)

        if header_data[:trainer_present]
          trainer_data = read_rata(f, TRAINER_SIZE, @trainer_reader)
          rom_data.merge!(trainer_data)
        end

        prg_rom_bytestring = read_rata(f, header_data.fetch(:prg_rom_size))
        rom_data.merge!(prg_rom_bytestring: prg_rom_bytestring)

        chr_rom_data = read_rata(f, header_data.fetch(:chr_rom_size), @chr_rom_reader)
        rom_data.merge!(chr_rom_data)
      end
    end
  end

  private

  def read_rata(file_stream, size, reader = nil)
    bytestring = file_stream.read(size)
    reader ? reader.read(bytestring) : bytestring
  end
end
