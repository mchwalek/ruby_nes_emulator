class RubyNesEmulator::RomReader::FlagBytesReader
  TRAINER_PRESENT_INDEX = 2
  PERSISTENT_MEMORY_PRESENT_INDEX = 1
  IS_PLAY_CHOICE_10_INDEX = 1
  IS_VS_UNISYSTEM_INDEX = 0
  NO_MIRRORING_INDEX = 3
  MIRRORING_TYPE_INDEX = 0

  UPPER_NIBBLE_MASK = 0b11110000

  def read_flags(first_flag_byte, second_flag_byte)
    {
      trainer_present: bit_set?(first_flag_byte, TRAINER_PRESENT_INDEX),
      persistent_memory_present: bit_set?(first_flag_byte, PERSISTENT_MEMORY_PRESENT_INDEX),
      is_play_choice_10: bit_set?(second_flag_byte, IS_PLAY_CHOICE_10_INDEX),
      is_vs_unisystem: bit_set?(second_flag_byte, IS_VS_UNISYSTEM_INDEX)
    }
  end

  def read_mirroring(first_flag_byte)
    if bit_set?(first_flag_byte, NO_MIRRORING_INDEX)
      :none
    else
      bit_set?(first_flag_byte, MIRRORING_TYPE_INDEX) ? :vertical : :horizontal
    end
  end

  def read_mapper_number(first_flag_byte, second_flag_byte)
    number_lower_nibble = get_upper_nibble(first_flag_byte)
    number_upper_nibble = get_upper_nibble(second_flag_byte)
    (number_upper_nibble << 4) | number_lower_nibble
  end

  private

  def bit_set?(byte, index)
    byte[index] == 1
  end

  def get_upper_nibble(byte)
    (byte & UPPER_NIBBLE_MASK) >> 4
  end
end
