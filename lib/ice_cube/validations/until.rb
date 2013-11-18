module IceCube

  module Validations::Until

    extend Deprecated

    # Value reader for limit
    def until_time
      @until
    end
    deprecated_alias :until_date, :until_time

    def until(time)
      time = TimeUtil.ensure_time(time, true)
      @until = time
      replace_validations_for(:until, time.nil? ? nil : [Validation.new(time)])
      self
    end

    class Validation

      attr_reader :time

      def initialize(time)
        @time = time
      end

      def type
        :limit
      end

      def validate(step_time, schedule)
        raise UntilExceeded if step_time > time
      end

      def build_s(builder)
        # FIX: stripping blank space before localized date shouldn't be necessary
        builder.piece(:until) << "#{I18n.t('ice_cube.until', date: I18n.l(time.to_date, format: I18n.t("ice_cube.date.formats.default")).strip)}"
      end

      def build_hash(builder)
        builder[:until] = TimeUtil.serialize_time(time)
      end

      def build_ical(builder)
        builder['UNTIL'] << IcalBuilder.ical_utc_format(time)
      end

    end

  end

end
