
module SplitDatetime

  class << self
    def nil_time
      Time.parse "#{Time.now.hour}:0:0"
    end
    def nil_date
      Date.today
    end

    def to_time datetime
      datetime = self.nil_time if datetime.blank?
      datetime.to_formatted_s :time
    end
    def to_date datetime
      datetime = self.nil_date if datetime.blank?
      datetime.strftime '%d/%m/%Y'
    end
    def set_time datetime, value
      value = if value.blank?
                self.nil_time
              elsif value.kind_of? String
                Time.parse value
              else
                value.to_time
              end
      datetime = self.nil_date if datetime.blank?

      Time.mktime(datetime.year, datetime.month, datetime.day, value.hour, value.min, value.sec).to_datetime
    end
    def set_date datetime, value
      value = if value.blank?
                self.nil_date
              elsif value.kind_of? String
                DateTime.strptime value, '%d/%m/%Y'
              else
                value.to_time
              end
      datetime = nil_time if datetime.blank?

      Time.mktime(value.year, value.month, value.day, datetime.hour, datetime.min, datetime.sec).to_datetime
    end
  end

  module SplitMethods

    def split_datetime attr
      define_method "#{attr}_time" do
        datetime = send attr
        SplitDatetime.to_time datetime
      end
      define_method "#{attr}_date" do
        datetime = send attr
        SplitDatetime.to_date datetime
      end
      define_method "#{attr}_time=" do |value|
        datetime = send attr
        send "#{attr}=", SplitDatetime.set_time(datetime, value)
      end
      define_method "#{attr}_date=" do |value|
        datetime = send attr
        send "#{attr}=", SplitDatetime.set_date(datetime, value)
      end
    end

  end

end

Class.extend SplitDatetime::SplitMethods
ApplicationRecord.extend SplitDatetime::SplitMethods

