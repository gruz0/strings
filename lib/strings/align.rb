# frozen_string_literal: true

require 'unicode/display_width'

require_relative 'ansi'

module Strings
  # Responsible for text alignment
  module Align
    SPACE   = ' '.freeze

    # Aligns text within the width.
    #
    # If the text is greater than the width then unmodified
    # string is returned.
    #
    # @param [String] text
    #   the text to align lines of
    # @param [Integer] width
    #   the maximum width to align to
    #
    # @example
    #   text = "the madness of men"
    #
    #   Strings::Align.align(22, :left)
    #   # => "the madness of men      "
    #
    #   Strings::Align.align(22, :center)
    #   # => "   the madness of men   "
    #
    #   Strings::Align(22, :right)
    #   # => "      the madness of men"
    #
    #   Strings::Align.align(22, :center, fill: '*)
    #   # => "***the madness of men***"
    #
    # @api public
    def align(text, width, direction = :left, **options)
      method = to_alignment(direction)
      send(method, text, width, options)
    end
    module_function :align

    # Aligns text to the left at given length
    #
    # @return [String]
    #
    # @api public
    def align_left(text, width, fill: SPACE)
      each_line(text) do |line|
        width_diff = width - display_width(line)
        if width_diff > 0
          line + fill * width_diff
        else
          line
        end
      end
    end
    module_function :align_left

    # Centers text within the width
    #
    # @return [String]
    #
    # @api public
    def align_center(text, width, fill: SPACE)
      each_line(text) do |line|
        width_diff = width - display_width(line)
        if width_diff > 0
          right_count = (width_diff.to_f / 2).ceil
          left_count  =  width_diff - right_count
          [fill * left_count, line, fill * right_count].join
        else
          text
        end
      end
    end
    module_function :align_center

    # Aligns text to the right at given length
    #
    # @return [String]
    #
    # @api public
    def align_right(text, width, fill: SPACE)
      each_line(text) do |line|
        width_diff = width - display_width(line)
        if width_diff > 0
          fill * width_diff + line
        else
          line
        end
      end
    end
    module_function :align_right

    # @api private
    def to_alignment(direction)
      case direction.to_sym
      when :left   then :align_left
      when :right  then :align_right
      when :center then :center_justify
      else
        raise ArgumentError, "Unknown alignment `#{direction}`."
      end
    end
    module_function :to_alignment

    # Enumerate text line by line
    #
    # @param [String] text
    #
    # @return [String]
    #
    # @api private
    def each_line(text)
      lines = text.split(NEWLINE)
      return yield(text) if text.empty?
      lines.reduce([]) do |aligned, line|
        aligned << yield(line)
      end.join(NEWLINE)
    end
    module_function :each_line

    # Visible width of a string
    #
    # @api private
    def display_width(string)
      Unicode::DisplayWidth.of(Strings::ANSI.sanitize(string))
    end
    module_function :display_width
  end # Align
end # Strings