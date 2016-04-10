class RubyNesEmulator::Cpu::OpcodeDecoder
  def decode(opcode)
    op_byte = opcode.bytes.first
    op_location = decode_opcode_matrix_location(op_byte)
    op_addressing_mode = decode_addressing_mode(op_location)

    {
      name: decode_name(op_location),
      addressing_mode: op_addressing_mode,
      cycles: decode_cycles(op_location),
      arg_length: decode_arg_length(op_addressing_mode),
      page_boundary_cross_aware?: decode_page_boundary_cross_aware(op_location, op_addressing_mode)
    }
  end

  private

  # Location is based on opcode matrix from http://wiki.nesdev.com/w/index.php/CPU_unofficial_opcodes

  def decode_opcode_matrix_location(op_byte)
    op_block = op_byte & 0b00000011
    op_column = (op_byte >> 2) & 0b00000111
    op_row = op_byte >> 5

    { block: op_block, column: op_column, row: op_row }
  end

  def decode_name(block:, column:, row:)
    return :HLT if (block == 2 && column == 0 && row.between?(0, 3)) || (block == 2 && column == 4)

    op_names = case block
    when 0
      case column
      when 2
        [:PHP, :PLP, :PHA, :PLA, :DEY, :TAY, :INY, :INX]
      when 4
        [:BPL, :BMI, :BVC, :BVS, :BCC, :BCS, :BNE, :BEQ]
      when 6
        [:CLC, :SEC, :CLI, :SEI, :TYA, :CLV, :CLD, :SED]
      else
        if row.between?(0, 3)
          if column == 0
            [:BRK, :JSR, :RTI, :RTS]
          else
            { 1 => :BIT, 2 => :JMP, 3 => :JMP } if column == 3 || (column == 1 && row == 1)
          end
        else
          fourth_row_name = { 0 => nil, 7 => :SHY }.fetch(column, :STY)

          { 4 => fourth_row_name, 5 => :LDY, 6 => :CPY, 7 => :CPX } unless (row.in?([6, 7]) && column.in?([5, 7]))
        end
      end
    when 1
      [:ORA, :AND, :EOR, :ADC, (:STA unless column == 2), :LDA, :CMP, :SBC]
    when 2
      if row.between?(0, 3)
        [:ASL, :ROL, :LSR, :ROR] unless column == 6
      else
        case column
        when 2
          { 4 => :TXA, 5 => :TAX, 6 => :DEX }
        when 6
          { 4 => :TXS, 5 => :TSX }
        else
          { 4 => (column == 7 ? :SHX : :STX), 5 => :LDX, 6 => :DEC, 7 => :INC } unless row != 5 && column == 0
        end
      end
    when 3
      if column == 2
        [:ANC, :ANC, :ALR, :ARR, :XAA, :ATX, :AXS, :SBC]
      else
        fourth_row_name = case column
        when 4, 7
          :AHX
        when 6
          :TAS
        else
          :SAX
        end

        fifth_row_name = column == 6 ? :LAS : :LAX

        [:ASO, :RLA, :LSE, :RRA, fourth_row_name, fifth_row_name, :DCP, :ISC]
      end
    end

    (op_names || [])[row] || :NOP
  end

  def decode_addressing_mode(block:, column:, row:)
    return :absolute if block == 0 && column == 0 && row == 1

    zeroth_column_mode = block.in?([1, 3]) ? :indirect_x : (:immediate if row.between?(4, 7))
    second_column_mode = { 0 => nil, 2 => (:accumulator if row.between?(0, 3)) }.fetch(block, :immediate)
    third_column_mode = block == 0 && row == 3 ? :indirect : :absolute
    fourth_column_mode = { 0 => :relative, 2 => nil }.fetch(block, :indirect_y)
    fifth_column_mode = block.in?([2, 3]) && row.in?([4, 5]) ? :zero_page_y : :zero_page_x
    sixth_column_mode = :absolute_y if block.in?([1, 3])
    seventh_column_mode = block.in?([2, 3]) && row.in?([4, 5]) ? :absolute_y : :absolute_x

    [
      zeroth_column_mode,
      :zero_page,
      second_column_mode,
      third_column_mode,
      fourth_column_mode,
      fifth_column_mode,
      sixth_column_mode,
      seventh_column_mode
    ][column] || :implied
  end

  def decode_cycles(block:, column:, row:)
    op_cycles = if (block == 0 && row.between?(4, 7)) || block == 1 || (block.in?([2, 3]) && row.in?([4, 5]))
      zeroth_column_cycles = block.in?([0, 2]) ? 2 : 6
      fourth_column_cycles = { 0 => 2, 2 => 0 }[block] || (row == 4 ? 6 : 5)
      sixth_column_cycles = block.in?([0, 2]) ? 2 : (row == 4 ? 5 : 4)
      seventh_column_cycles = row == 4 ? 5 : 4

      [zeroth_column_cycles, 3, 2, 4, fourth_column_cycles, 4, sixth_column_cycles, seventh_column_cycles]
    else
      if block == 0
        zeroth_column_cycles = row == 0 ? 7 : 6
        second_column_cycles = row.in?([0, 2]) ? 3 : 4
        third_column_cycles = { 2 => 3, 3 => 5 }[row] || 4

        [zeroth_column_cycles, 3, second_column_cycles, third_column_cycles, 2, 4, 2, 4]
      else
        zeroth_column_cycles = { 2 => (row.in?([6, 7]) ? 2 : 0) }[block] || 8
        fourth_column_cycles = block == 2 ? 0 : 8
        sixth_column_cycles = block == 2 ? 2 : 7

        [zeroth_column_cycles, 5, 2, 6, fourth_column_cycles, 6, sixth_column_cycles, 7]
      end
    end

    op_cycles[column]
  end

  def decode_arg_length(addressing_mode)
    case addressing_mode
    when :implied, :accumulator
      0
    when :immediate, :zero_page, :zero_page_x, :zero_page_y, :indirect_x, :indirect_y, :relative
      1
    when :absolute, :absolute_x, :absolute_y, :indirect
      2
    end
  end

  def decode_page_boundary_cross_aware(location, addressing_mode)
    block, row = location.slice(:block, :row).values

    return true if addressing_mode == :relative

    addressing_mode.in?([:absolute_x, :absolute_y, :indirect_y]) && (
      (block.in?([0, 1]) && row != 4) ||
      (block.in?([2, 3]) && row == 5)
    )
  end
end
