module IceCube

  class StringBuilder

    attr_writer :base

    def initialize
      @types = {}
    end

    def piece(type, prefix = nil, suffix = nil)
      @types[type] ||= []
    end

    def to_s
      str = @base || ''
      res = @types.map do |type, segments|
        if f = self.class.formatter(type)
          str << ' ' + f.call(segments)
        else
          next if segments.empty?
          str << ' ' + self.class.sentence(segments)
        end
      end
      str
    end

    class << self

      def formatter(type)
        @formatters[type]
      end

      def register_formatter(type, &formatter)
        @formatters ||= {}
        @formatters[type] = formatter
      end

    end

    class << self

      # influenced by ActiveSupport's to_sentence
      def sentence(array)
        *enum, final = array
        enumeration = enum.join(I18n.t 'ice_cube.array.words_connector').presence
        [enumeration, final].compact.join(I18n.t 'ice_cube.array.last_word_connector')
      end

      def nice_number(number)
        literal_ordinal(number) || ordinalize(number)
      end

      def ordinalize(number)
        "#{number}#{ordinal(number)}"
      end

      def ordinal(number)
        I18n.t("ice_cube.integer.ordinals")[number] ||
        I18n.t("ice_cube.integer.ordinals")[number % 10] ||
        I18n.t('ice_cube.integer.ordinals')[:default]
      end

      def literal_ordinal(number)
        I18n.t("ice_cube.integer.literal_ordinals")[number]
      end

    end

  end

end
