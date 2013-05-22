require 'debugger'

module IceCube

  module Validations::Until

    extend ::Deprecated

    # accessor
    def until_time
      @until
    end
    deprecated_alias :until_date, :until_time

    def until(time)
      @until = time
      replace_validations_for(:until, [Validation.new(time)])
      self
    end

    class Validation

      attr_reader :time

      def type
        :dealbreaker
      end

      def initialize(time)
        @time = time
      end

      def build_ical(builder)
        builder['UNTIL'] << IcalBuilder.ical_utc_format(time)
      end

      def build_hash(builder)
        builder[:until] = TimeUtil.serialize_time(time)
      end

      def build_s(builder)
        # FIX: stripping blank space before localized date shouldn't be necessary
        builder.piece(:until) << "#{I18n.t('ice_cube.until', date: I18n.l(time).strip)}"
      end

      def validate(t, schedule)
        raise UntilExceeded if t > time
      end

    end

  end

end
