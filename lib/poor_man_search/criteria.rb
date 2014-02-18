module PoorManSearch
  class Criteria
    attr_accessor :strings, :stringables, :numbers, :times, :time_range

    @s = nil

    def initialize irregularity = nil
      parse irregularity
    end

    private

    def parse irregularity
      self.strings = []
      self.stringables = []
      self.numbers = []
      self.times = []
      self.time_range = []

      words = irregularity.to_s.gsub /　/, " "
      words.split(" ").each do |word|
        num = number_parse word
        time = time_parse word

        self.strings << word unless num || time
        self.numbers << num if num
        self.times << time if time
      end

      self.time_range = [self.times.min, self.times.max] if self.times.count >= 2
    end

    DATE_FORMATS = {:date_hour_minute => [/^\d+(\/)\d+(-)\d+(:)\d+$/, '%m/%d-%H:%M'],
      :date_hour => [/^\d+(\/)\d+(-)\d+$/, '%m/%d-%H'],
      :date => [/^\d+(\/)\d+$/, '%m/%d'],
      :time => [/^\d+(:)\d+$/, '%H:%M']}

    def time_parse ss
      date   = parse_format(ss, DATE_FORMATS[:date_hour_minute])
      date ||= parse_format(ss, DATE_FORMATS[:date_hour])
      date ||= parse_format(ss, DATE_FORMATS[:date])
      date ||= parse_format(ss, DATE_FORMATS[:time])
      return date
    rescue Exception
      return nil
    end

    def parse_format(ss, format)
      return nil unless ss=~ format[0]
      return Time.strptime(ss, format[1])
    rescue Exception
      return nil
    end

    def number_parse s
      return nil unless s =~ /^(|-)\d+(|\.(|\d+))$/
      return BigDecimal.new s
    end
  end
end
